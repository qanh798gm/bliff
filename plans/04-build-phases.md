# Bliff — Build Phases

## Phase 1: MVP — Voice + Single Question + Claude Working

**Goal**: End-to-end proof of concept. You can speak to an AI interviewer and it responds.

### Deliverables
1. **Project scaffolding** — Vite + React + TypeScript + Tailwind + ESLint
2. **Vercel serverless proxy** — `/api/chat` endpoint that forwards to Claude API with key stored server-side
3. **Voice hook** (`useVoice.ts`) — Web Speech API for STT and TTS, language toggle EN/VI
4. **Interview room UI** — Single page with:
   - Mic button to start/stop recording
   - Chat transcript display
   - Text input fallback
   - Language toggle
5. **Hardcoded question** — "Two Sum" baked into the prompt
6. **Static system prompt** — Simplified version of the prompt design, no DB injection yet
7. **Basic interview flow** — Present problem → listen → respond → give hints
8. **Deploy to Vercel** — Working URL you can use on any device

### What is NOT in Phase 1
- No auth, no database, no code editor, no dashboard
- Single hardcoded question only
- No session persistence

---

## Phase 2: Supabase + Question Bank + Adaptive Logic

**Goal**: Real data layer. Login, question bank, session tracking, basic adaptation.

### Deliverables
1. **Supabase project setup** — Create project, configure environment variables
2. **Database schema** — All tables from schema design, migrations, seed data
3. **Auth integration** — Google login via Supabase Auth, protected routes
4. **User profile page** — Edit name, target companies, preferred language, etc.
5. **Question bank seed** — Import Blind 75 + NeetCode 150 metadata into `questions` table
6. **FE question bank seed** — Curated frontend interview questions
7. **Dynamic system prompt** — `promptBuilder.ts` assembles prompt from profile + stats + question
8. **Question selection engine** — `adaptiveEngine.ts` with weighted random selection:
   - Higher weight for weak topics
   - Re-queue failed questions
   - Lower weight for mastered questions
9. **Session tracking** — Create session on start, create attempt per question, save on end
10. **Post-session feedback** — AI generates structured JSON feedback, stored in `attempts.ai_feedback`
11. **Topic stats updater** — After each attempt, recalculate `user_topic_stats`
12. **Monaco code editor** — Embedded editor for writing solutions during interview

### Adaptive Engine Algorithm
```
For each eligible question:
  base_weight = 1.0
  
  // Topic weakness boost
  if topic.mastery_level == 'beginner': weight *= 3.0
  if topic.mastery_level == 'developing': weight *= 2.0
  if topic.mastery_level == 'proficient': weight *= 1.0
  if topic.mastery_level == 'mastered': weight *= 0.3
  
  // Previous failure boost
  if user failed this question before: weight *= 2.5
  if user partially solved: weight *= 1.5
  if user solved perfectly: weight *= 0.2
  
  // Recency penalty — avoid repeating recent questions
  if attempted in last 3 days: weight *= 0.1
  if attempted in last 7 days: weight *= 0.5
  
  // Difficulty preference — start with easy/medium, increase over time
  apply difficulty curve based on overall mastery

Select question via weighted random from top candidates.
```

---

## Phase 3: Dashboard + Auth + Polish ✅ COMPLETED

**Goal**: Full experience. Visual progress, streak tracking, auth, routing.

### Deliverables — All Completed

1. ✅ **Auth flow** — Supabase magic link login, `AuthContext`, `useAuth` hook, protected routes, guest routes
2. ✅ **Onboarding wizard** — Multi-step profile setup (role, experience, focus areas, target companies, weekly goal)
3. ✅ **Progress dashboard** — Recharts radar chart by topic, streak counter, weak area spotlight, quick-start CTA
4. ✅ **Session history page** — Past sessions list with AI feedback summaries, per-attempt detail, expandable view
5. ✅ **Interview room refinements** — Stage indicator (Warm-up → Interview → Feedback), countdown timer, stage-aware UI
6. ✅ **Warm-up / free-chat mode** — Casual AI conversation before interview, AI greets user by name
7. ✅ **Question browser page** (`/questions`) — Browse all 150+ questions by topic, filter by difficulty, search by title, launch to practice, category tabs (DSA / Frontend)
8. ✅ **LLM API test page** (`/llm-test`) — Dev health-check tool: non-streaming ping, streaming test, custom prompt sandbox, env var inspector
9. ✅ **React Router v6** — Full routing setup with `BrowserRouter`, protected `RequireAuth`, guest `RequireGuest`
10. ✅ **Dashboard nav links** — Questions, History, API test, Sign out

### Bug Fixes Applied
- Fixed LLM base URL hardcoded to OpenAI — now reads `VITE_LLM_BASE_URL`
- Fixed `sessions` table column (`uid` → `user_id`) causing SessionHistory crash
- Added `cursor-pointer` to all buttons via Tailwind CSS base layer

---

## Phase 4: Practice & Solutions — ✅ COMPLETED

**Goal**: Transform Bliff from a single-mode interview simulator into a full learning platform with practice mode, multi-solution tracking, and a redesigned layout.

### Deliverables — All Completed

1. ✅ **Practice Mode** (`/practice/:slug`) — code-first, no stage machine, AI opt-in via collapsible panel; silent stat tracking always on
2. ✅ **Multi-solution tracking** — `user_solutions` table with RLS + indexes; save ranked Brute Force → Optimized solutions per question
3. ✅ **`solutionService.ts`** — fetch, save, update, delete, markAsBest operations
4. ✅ **Save Solution modal** — label dropdown, time/space complexity fields, notes
5. ✅ **Solution History panel** — ranked list of saved solutions in Practice left panel; view + set best
6. ✅ **Rich test case tiers** — `basic | edge | corner | performance` schema documented; `practice_attempts` + `practice_solved` columns on `user_topic_stats`
7. ✅ **Layout redesign** — editor + test results always-visible split; AI chat in left panel in both Practice and Interview modes
8. ✅ **Question Browser dual buttons** — `▶ Practice` → `/practice/:slug` and `🎙 Interview` → `/interview/:slug` on row hover
9. ✅ **AI solution context** — `promptBuilder.ts` injects `previousSolutions` into system prompt; AI references prior solutions in Interview mode without spoiling code
10. ✅ **`usePractice.ts`** — practice mode state: run count, time on page, AI toggle, solution management
11. ✅ **Bug fixes** — clickable question rows, stale question panel (Two Sum default fixed)

---

## Phase 5: AI Memory Architecture — 🚧 In Progress

**Goal**: Give Bliff's AI mentor genuine long-term memory across sessions — patterns, habits, and topic insights — so it builds a continuously improving model of you.

> See full design: [`plans/10-phase5-memory-architecture.md`](10-phase5-memory-architecture.md)

### Architecture Decision: Why NOT RAG or Graph

- **RAG (vector search)**: Wrong tool for this domain. RAG retrieves unstructured documents by semantic similarity. Bliff's memory is structured behavioral data (scores, patterns, history) — vectors add noise, not signal.
- **Knowledge Graph**: Theoretically elegant but operationally overkill for a single-user personal tool. 80% infrastructure work, 20% value.
- **Hierarchical Summarization** ✅: The AI writes notes about you at session end and reads them at session start. Natural fit. Mirrors how a real human coach would work.

### Memory Layers

**Short-term** (per-session, ephemeral, already exists):
- Live `conversation_log[]` in React state → persisted to `attempts.conversation_log` at session end
- Frozen `session_context` snapshot loaded from long-term at session start
- Rolling 20-message window with inline summarization of older messages

**Long-term** (persistent in Supabase, grows over time):
- `user_profile` — static traits (exists)
- `user_topic_stats` — aggregated metrics per topic (exists)
- `user_solutions` — saved ranked code solutions (Phase 4, done)
- `attempts` — raw session history (exists)
- `user_memory` — **NEW**: AI-written natural language insights

### Deliverables

1. [ ] **`user_memory` table** — migration `044_user_memory.sql`; types: `habit | skill_pattern | topic_insight | weekly_summary | session_note`; RLS + indexes; `confidence` score + optional `valid_until` TTL
2. [ ] **`session_context` column** — migration `045_session_context.sql`; JSONB snapshot of what context was loaded at session start (for audit/replay)
3. [ ] **Types** — `UserMemoryRow`, `MemoryType` in `database.ts`; `UserMemory`, extended `PromptContext` in `index.ts`
4. [ ] **`memoryService.ts`** — `loadSessionMemory(userId, topicId)`, `upsertMemories(userId, sessionId, items[])`, `expireOldSummaries()`
5. [ ] **`promptBuilder.ts` — read** — `buildMemorySection(memories[])` injects `=== COACH MEMORY ===` block (~250 tokens) into every system prompt
6. [ ] **`promptBuilder.ts` — write** — `<memory_json>` output prompt added to feedback stage; `parseMemoryJson()` parser (mirrors existing `parseFeedbackJson`)
7. [ ] **`useInterview.ts`** — `loadSessionContext()` at session start; `saveSessionMemory()` after feedback parsed; `trimConversation()` rolling 20-message window
8. [ ] **`usePractice.ts`** — `loadSessionContext()` for AI panel memory injection
