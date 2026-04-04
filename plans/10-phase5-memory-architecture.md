# Bliff — Phase 5: AI Memory Architecture

> **Goal**: Give Bliff's AI mentor genuine long-term memory so it builds a continuously
> improving model of you — not just raw stats, but patterns, habits, and insights —
> without over-engineering for a single-user personal tool.

---

## Phase 4 → Phase 5 Transition

Phase 4 delivered the core learning platform:
- ✅ Practice Mode (`/practice/:slug`) — code-first, AI opt-in
- ✅ Multi-solution tracking (`user_solutions` table, `solutionService.ts`)
- ✅ Rich test case tiers (basic / edge / corner / performance schema)
- ✅ Solution history injected into AI prompts (`promptBuilder.ts`)
- ✅ Silent practice stat tracking (`practice_attempts`, `practice_solved`)

Phase 5 is about **intelligence quality** — making the AI mentor smarter about *you*
across sessions, not just within them.

---

## The Problem: Stateless AI Between Sessions

Today, every session re-assembles the same flat context:

```
system prompt = role + user_profile + topic_stats (22 rows) + question + solutions
```

This works. But it has a ceiling:

| Limitation | Impact |
|---|---|
| No pattern recognition across sessions | AI can't say "you always forget edge cases in DP" |
| Raw counts only (total_attempts, avg_score) | No insight into *why* scores are what they are |
| No temporal awareness | AI doesn't know if you've improved or regressed this week |
| Prompt bloat at scale | 500+ sessions means context assembly gets noisy |

The fix is **not** RAG (wrong tool for structured behavioral data) and **not** a knowledge
graph (too complex for a single-user tool). The right fit is **hierarchical summarization**:
the AI writes notes about you at session end, and reads them at session start.

---

## Memory Model: Two Layers

### Layer 1 — Short-Term Memory (per-session, ephemeral)

Short-term memory is everything the AI is actively working with *right now*:

```
short_term = {
  session_context,        // snapshot loaded from long-term at session start
  conversation_log[],     // live message history (already in attempts.conversation_log)
  test_run_log[],         // pass/fail results within this session
  current_question,       // full question object
  current_stage,          // idle / warmup / present / clarify / solve / review / feedback
}
```

**Key properties:**
- Lives only in browser memory (React state) during the session
- `conversation_log` is persisted to `attempts` when session ends
- `session_context` is a **frozen snapshot** of long-term at session start — it does NOT
  update mid-session (avoids inconsistency)
- Short-term is **overwritten** every new session — by design, this is correct

**Context window management** (already partially done, needs formalization):
- Keep last 20 messages live in the prompt
- If conversation exceeds 20 messages, prepend a 2-sentence rolling summary
- Session start injects a `[SESSION CONTEXT]` block before the first user message

### Layer 2 — Long-Term Memory (persistent, grows over time)

Long-term memory is everything stored in Supabase that persists across sessions:

```
long_term = {
  user_profile,           // static traits (already exists)
  user_topic_stats[],     // aggregated metrics per topic (already exists)
  user_solutions[],       // saved ranked solutions per question (Phase 4, done)
  attempts[],             // raw session history (already exists)
  user_memory[],          // AI-written insights — THE NEW PIECE
}
```

---

## The New Piece: `user_memory` Table

This is the single most impactful addition. The AI writes notes about you at session end.
It reads them at session start. This is how a real coach remembers you.

### Schema

```sql
CREATE TABLE user_memory (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  memory_type     text NOT NULL CHECK (memory_type IN (
                    'habit',           -- behavioral pattern (asking clarifying Qs, etc.)
                    'skill_pattern',   -- topic-specific skill observation
                    'topic_insight',   -- detailed insight about a specific topic
                    'weekly_summary',  -- weekly rollup (expires after 30 days)
                    'session_note'     -- one-off note from a specific session
                  )),
  topic_id        uuid REFERENCES topics(id) ON DELETE CASCADE,  -- NULL = global
  content         text NOT NULL,        -- natural language, AI-written, 1-3 sentences
  evidence_count  integer NOT NULL DEFAULT 1,    -- sessions supporting this observation
  confidence      float NOT NULL DEFAULT 0.5,    -- 0.0-1.0, rises with more evidence
  source_session_id uuid REFERENCES sessions(id) ON DELETE SET NULL,
  valid_until     timestamptz,          -- NULL = evergreen; weekly_summary expires 30d
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX user_memory_user_topic ON user_memory (user_id, topic_id);
CREATE INDEX user_memory_user_type  ON user_memory (user_id, memory_type);
CREATE INDEX user_memory_confidence ON user_memory (user_id, confidence DESC);

-- RLS
ALTER TABLE user_memory ENABLE ROW LEVEL SECURITY;
CREATE POLICY "own memory" ON user_memory USING (auth.uid() = user_id);
```

### Example Rows

| memory_type | topic_id | content | confidence |
|---|---|---|---|
| `habit` | NULL | "Almost never asks clarifying questions before coding — seen in 12 of 15 sessions." | 0.85 |
| `skill_pattern` | NULL | "Strong at recognizing when a hash map reduces time complexity, but struggles with the follow-up space optimization trade-off." | 0.75 |
| `topic_insight` | dp-topic-uuid | "Understands DP subproblem structure but makes off-by-one errors in dp[] initialization. Consistent across 4 of 6 DP attempts." | 0.80 |
| `topic_insight` | trees-topic-uuid | "Solid on BFS/DFS traversal. Recently improved — solved 3 tree problems in a row." | 0.70 |
| `weekly_summary` | NULL | "Week of Mar 31: 3 sessions (2 solved, 1 gave up). Notable improvement on Trees. DP still the main weak area." | 0.90 |

---

## Memory Flow: Write and Read

### Write — at session end

After the feedback stage, the AI is asked to output a structured memory block alongside
its verbal feedback. This is added to the existing `feedback` stage prompt in
[`promptBuilder.ts`](../src/lib/promptBuilder.ts):

```
After your verbal feedback, also output a memory block for your own records:
<memory_json>
[
  {
    "memory_type": "habit" | "skill_pattern" | "topic_insight" | "session_note",
    "topic_slug": "<slug or null>",
    "content": "<1-3 sentence natural language observation>",
    "confidence": <0.1-1.0>
  },
  ...
]
</memory_json>

Write 2-4 memories maximum. Focus on patterns you observed this session.
Only write high-confidence observations (>0.6). Skip trivial facts.
```

The frontend parses `<memory_json>` (same pattern as existing `<feedback_json>` parsing
in [`parseFeedbackJson()`](../src/lib/promptBuilder.ts:179)) and upserts rows into
`user_memory`. If a memory with the same `memory_type + topic_id + similar content`
already exists, increment `evidence_count` and update `confidence`.

### Read — at session start

When building the system prompt, load the most relevant memories:

```ts
// New: loadSessionMemory(userId, topicId) → UserMemoryRow[]
SELECT * FROM user_memory
WHERE user_id = $userId
  AND (topic_id = $topicId OR topic_id IS NULL)
  AND (valid_until IS NULL OR valid_until > now())
ORDER BY confidence DESC, updated_at DESC
LIMIT 8
```

These 8 rows are injected as a new `=== COACH MEMORY ===` section in the system prompt —
approximately 200-300 tokens total. Compact and effective.

---

## Updated Prompt Structure

New section added between CANDIDATE PROFILE and CURRENT PROBLEM:

```
=== COACH MEMORY — your accumulated notes on this candidate ===
[Read these before starting. These are patterns you have observed across sessions.]

GLOBAL HABITS:
- Almost never asks clarifying questions before coding (confidence: high, seen 12x)
- Strong communicator — thinks out loud consistently

SKILL PATTERNS:
- Reliably identifies hash map optimizations; struggles with follow-on space trade-offs

TOPIC: Dynamic Programming (current topic)
- Understands subproblem structure but makes dp[] initialization errors (seen 4x)
- Improving — scored 7/10 last DP session (up from avg 5.2)

[Use this to calibrate your approach. Do not mention these notes explicitly unless relevant.]
```

---

## Session Context Snapshot

A new `session_context` JSONB column on `sessions` captures what was loaded at start:

```sql
ALTER TABLE sessions
  ADD COLUMN IF NOT EXISTS session_context jsonb;
```

Structure:
```json
{
  "profile_snapshot": { "display_name": "Anh", "experience_years": 6, ... },
  "topic_mastery": { "topicName": "Dynamic Programming", "masteryLevel": "developing", ... },
  "memories_loaded": 6,
  "solutions_loaded": 2,
  "context_assembled_at": "2026-04-04T10:00:00Z"
}
```

This is purely for debugging and audit — lets you replay "what did the AI know when this
session started?"

---

## Conversation Window Management

Formalize what currently works ad-hoc:

```
MAX_LIVE_MESSAGES = 20

If conversation_log.length > MAX_LIVE_MESSAGES:
  - Take messages[0..length-20] (the older ones)
  - Ask LLM to summarize them in 2 sentences
  - Replace those messages with a single system message:
      "[Earlier in this session: {summary}]"
  - Keep messages[length-20..] live
```

This keeps context window bounded without losing important context. Implement in
[`useInterview.ts`](../src/hooks/useInterview.ts) as a `trimConversation()` utility.

---

## New Files and Changes

| File | Change |
|---|---|
| `supabase/migrations/...044_user_memory.sql` | New `user_memory` table + indexes + RLS |
| `supabase/migrations/...045_session_context.sql` | Add `session_context` jsonb to `sessions` |
| `src/types/database.ts` | Add `UserMemoryRow`, `MemoryType` types |
| `src/types/index.ts` | Add `UserMemory` type, extend `PromptContext` with `coachMemory[]` |
| `src/services/memoryService.ts` | New — CRUD for `user_memory`: load, upsert, expire |
| `src/lib/promptBuilder.ts` | Add `buildMemorySection()`, add `<memory_json>` write prompt to feedback stage |
| `src/lib/promptBuilder.ts` | Add `parseMemoryJson()` (mirrors existing `parseFeedbackJson`) |
| `src/hooks/useInterview.ts` | Call `memoryService.loadForSession()` at start; call `memoryService.upsertFromSession()` at end; add `trimConversation()` |
| `src/hooks/usePractice.ts` | Load memories at start (for AI panel in Practice mode) |

---

## Implementation Order

```
Step 1: DB migrations
  044_user_memory.sql
  045_session_context.sql

Step 2: Types
  database.ts — UserMemoryRow, MemoryType
  index.ts — UserMemory, extend PromptContext

Step 3: memoryService.ts
  loadSessionMemory(userId, topicId) → UserMemoryRow[]
  upsertMemories(userId, sessionId, memories[]) → void
  expireOldSummaries() → void   (called at session start to clean up stale weekly_summary)

Step 4: promptBuilder.ts
  buildMemorySection(memories[]) → string
  parseMemoryJson(text) → MemoryWriteItem[] | null
  Add memory write prompt to feedback stage

Step 5: useInterview.ts
  loadSessionContext() — assembles profile + topic + memories at session start
  saveSessionMemory() — parses + upserts after feedback
  trimConversation() — rolling window at 20 messages

Step 6: usePractice.ts
  loadSessionContext() — same loader, used for AI panel
```

---

## What This Is NOT

Keeping scope tight:

- ❌ **No RAG / vector embeddings** — wrong tool for structured behavioral data; adds
  infrastructure cost with no quality gain for this domain
- ❌ **No knowledge graph** — operationally complex; overkill for single-user personal tool
- ❌ **No background sync jobs** — memory is written synchronously at session end, not via
  a cron or edge function; simpler and sufficient for one user
- ❌ **No cross-session conversation replay** — `conversation_log` stays per-session;
  long-term memory is the *distilled* version, not raw transcripts

---

## Token Budget Impact

| Section | Before Phase 5 | After Phase 5 |
|---|---|---|
| Role definition | ~200 | ~200 |
| Candidate profile | ~150 | ~150 |
| **Coach memory (new)** | 0 | ~250 |
| Performance history | ~300 | ~300 |
| Current question | ~600 | ~600 |
| Session state | ~50 | ~50 |
| **Total system prompt** | **~1,300** | **~1,550** |

Cost increase: ~250 tokens per call. At typical session length (20 turns), that's 5,000
extra input tokens per session — approximately $0.005 at current LLM pricing. Negligible.

---

## Success Criteria

Phase 5 is complete when:

1. After a session ends, `user_memory` rows are written to Supabase
2. The next session's system prompt includes a `=== COACH MEMORY ===` section with those rows
3. The AI visibly references past patterns in its conversation (e.g. "I noticed last time
   you jumped to coding before clarifying — let's try to avoid that today")
4. `session_context` is saved on each session row for audit
5. Conversation window stays bounded at 20 live messages with rolling summary
