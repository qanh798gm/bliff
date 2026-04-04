-- ============================================================
-- user_memory — AI-written long-term memory about the user
-- Written by the LLM at session end; read at session start.
-- This is the "coach's notebook" — natural language insights
-- that persist across sessions and shape AI behavior.
-- ============================================================

create table if not exists user_memory (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references auth.users(id) on delete cascade,

  -- Type of memory entry
  memory_type       text not null check (memory_type in (
                      'habit',           -- behavioral pattern (e.g. skips clarifying questions)
                      'skill_pattern',   -- cross-topic skill observation
                      'topic_insight',   -- detailed insight about a specific topic
                      'weekly_summary',  -- weekly rollup, expires after 30 days
                      'session_note'     -- one-off note from a specific session
                    )),

  -- Optional: link to a specific topic (NULL = global/cross-topic memory)
  topic_id          uuid references topics(id) on delete cascade,

  -- The memory itself — natural language, AI-written, 1-3 sentences
  content           text not null,

  -- How many sessions support this observation (increases with corroborating evidence)
  evidence_count    integer not null default 1,

  -- Confidence 0.0–1.0 — rises as evidence_count grows; AI sets initial value
  confidence        float not null default 0.5 check (confidence >= 0 and confidence <= 1),

  -- Link to the session that created/last updated this memory (nullable on cascade delete)
  source_session_id uuid references sessions(id) on delete set null,

  -- Optional expiry — NULL = evergreen; weekly_summary rows set this to now() + 30 days
  valid_until       timestamptz,

  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- ── Indexes ──────────────────────────────────────────────────────────────────

-- Primary lookup: all memories for a user filtered by topic
create index if not exists user_memory_user_topic
  on user_memory (user_id, topic_id);

-- For loading top memories by confidence (session start query)
create index if not exists user_memory_user_confidence
  on user_memory (user_id, confidence desc);

-- For filtering by type (e.g. expire weekly summaries)
create index if not exists user_memory_user_type
  on user_memory (user_id, memory_type);

-- ── Auto-update updated_at ────────────────────────────────────────────────────

create or replace function update_user_memory_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_user_memory_updated_at on user_memory;
create trigger trg_user_memory_updated_at
  before update on user_memory
  for each row execute function update_user_memory_updated_at();

-- ── Row Level Security ────────────────────────────────────────────────────────

alter table user_memory enable row level security;

create policy "users can read own memory"
  on user_memory for select
  using (auth.uid() = user_id);

create policy "users can insert own memory"
  on user_memory for insert
  with check (auth.uid() = user_id);

create policy "users can update own memory"
  on user_memory for update
  using (auth.uid() = user_id);

create policy "users can delete own memory"
  on user_memory for delete
  using (auth.uid() = user_id);

-- ── Comments ─────────────────────────────────────────────────────────────────

comment on table user_memory is
  'AI-written long-term memory entries for the user. Written by the LLM at session end
   via parseMemoryJson(), read at session start via loadSessionMemory().
   The AI injects these into the === COACH MEMORY === system prompt section.';

comment on column user_memory.memory_type is
  'habit: behavioral pattern observed across sessions
   skill_pattern: cross-topic skill strength/weakness
   topic_insight: detailed observation about a specific topic
   weekly_summary: weekly rollup — set valid_until = now() + 30 days
   session_note: one-off note not expected to generalize';

comment on column user_memory.confidence is
  '0.0–1.0 — AI sets initial value; app increments when evidence_count grows.
   Suggested thresholds: <0.4 tentative, 0.4-0.7 moderate, >0.7 high confidence.
   Only memories with confidence >= 0.5 are injected into the system prompt.';

comment on column user_memory.valid_until is
  'NULL = evergreen (habits, skill_patterns, topic_insights).
   weekly_summary rows should set this to now() + interval 30 days.
   Expired rows are excluded from session context loading but not deleted automatically.';
