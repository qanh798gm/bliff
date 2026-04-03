-- ============================================================
-- Bliff DSA Interview Coach — Full Schema Migration
-- No auth required: single-user app, user_id is a fixed constant
-- ============================================================

-- Enable UUID generation
create extension if not exists "pgcrypto";

-- ============================================================
-- TOPICS — static reference data
-- ============================================================
create table if not exists topics (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  slug        text not null unique,
  category    text not null check (category in ('dsa', 'frontend')),
  display_order integer not null default 0
);

-- ============================================================
-- QUESTIONS — the full question bank
-- ============================================================
create table if not exists questions (
  id                        uuid primary key default gen_random_uuid(),
  title                     text not null,
  slug                      text not null unique,
  topic_id                  uuid not null references topics(id),
  difficulty                text not null check (difficulty in ('easy', 'medium', 'hard')),
  source                    text not null check (source in ('blind75', 'neetcode150', 'fe-curated', 'custom')),
  description               text not null,
  examples                  jsonb not null default '[]',
  constraints               text[] not null default '{}',
  hints                     text[] not null default '{}',
  expected_approach         text,
  expected_time_complexity  text,
  expected_space_complexity text,
  tags                      text[] not null default '{}',
  test_cases                jsonb not null default '[]',
  entry_point               text,
  function_signature        text,
  leetcode_number           integer,
  is_active                 boolean not null default true,
  created_at                timestamptz not null default now()
);

-- ============================================================
-- USER_PROFILE — single row for the one user
-- ============================================================
create table if not exists user_profile (
  id                  uuid primary key default gen_random_uuid(),
  display_name        text not null default 'Anh',
  experience_years    integer not null default 6,
  primary_role        text not null default 'Frontend Engineer',
  target_companies    text[] not null default '{"Google","Meta","Amazon"}',
  preferred_languages text[] not null default '{"javascript","typescript"}',
  voice_language      text not null default 'en-US',
  strengths           text[] not null default '{}',
  weaknesses          text[] not null default '{}',
  notes               text,
  current_streak      integer not null default 0,
  longest_streak      integer not null default 0,
  last_session_date   date,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- ============================================================
-- USER_TOPIC_STATS — aggregated per-topic performance
-- ============================================================
create table if not exists user_topic_stats (
  id                    uuid primary key default gen_random_uuid(),
  topic_id              uuid not null references topics(id),
  total_attempts        integer not null default 0,
  solved_count          integer not null default 0,
  partial_count         integer not null default 0,
  gave_up_count         integer not null default 0,
  avg_score             float not null default 0,
  avg_duration_seconds  float not null default 0,
  last_attempted_at     timestamptz,
  mastery_level         text not null default 'beginner' check (mastery_level in ('beginner','developing','proficient','mastered')),
  weight                float not null default 1.0,
  unique (topic_id)
);

-- ============================================================
-- SESSIONS — one row per interview practice session
-- ============================================================
create table if not exists sessions (
  id                   uuid primary key default gen_random_uuid(),
  started_at           timestamptz not null default now(),
  ended_at             timestamptz,
  mode                 text not null default 'interview' check (mode in ('interview','practice','review')),
  voice_language       text not null default 'en-US',
  overall_score        integer check (overall_score between 1 and 10),
  ai_feedback_summary  text,
  created_at           timestamptz not null default now()
);

-- ============================================================
-- ATTEMPTS — each question attempted within a session
-- ============================================================
create table if not exists attempts (
  id                        uuid primary key default gen_random_uuid(),
  session_id                uuid not null references sessions(id) on delete cascade,
  question_id               uuid not null references questions(id),
  started_at                timestamptz not null default now(),
  ended_at                  timestamptz,
  duration_seconds          integer,
  status                    text not null default 'in_progress' check (status in ('solved','partial','gave_up','in_progress')),
  hints_used                integer not null default 0,
  asked_clarifying          boolean not null default false,
  solution_code             text,
  approach_used             text,
  time_complexity_given     text,
  space_complexity_given    text,
  ai_score                  integer check (ai_score between 1 and 10),
  ai_feedback               jsonb,
  conversation_log          jsonb not null default '[]',
  created_at                timestamptz not null default now()
);

-- ============================================================
-- INDEXES
-- ============================================================
create index if not exists idx_attempts_question_id on attempts(question_id);
create index if not exists idx_attempts_status on attempts(status);
create index if not exists idx_attempts_session_id on attempts(session_id);
create index if not exists idx_sessions_started_at on sessions(started_at desc);
create index if not exists idx_questions_topic_id on questions(topic_id);
create index if not exists idx_questions_difficulty on questions(difficulty);
create index if not exists idx_questions_source on questions(source);

-- ============================================================
-- SEED: Topics
-- ============================================================
insert into topics (name, slug, category, display_order) values
  -- DSA topics
  ('Arrays',              'arrays',               'dsa', 1),
  ('Two Pointers',        'two-pointers',         'dsa', 2),
  ('Sliding Window',      'sliding-window',       'dsa', 3),
  ('Stack',               'stack',                'dsa', 4),
  ('Binary Search',       'binary-search',        'dsa', 5),
  ('Linked List',         'linked-list',          'dsa', 6),
  ('Trees',               'trees',                'dsa', 7),
  ('Tries',               'tries',                'dsa', 8),
  ('Heap / Priority Queue','heap',                'dsa', 9),
  ('Backtracking',        'backtracking',         'dsa', 10),
  ('Graphs',              'graphs',               'dsa', 11),
  ('Dynamic Programming', 'dynamic-programming',  'dsa', 12),
  ('Greedy',              'greedy',               'dsa', 13),
  ('Intervals',           'intervals',            'dsa', 14),
  ('Math & Bit Manipulation', 'math-bit',         'dsa', 15),
  -- Frontend topics
  ('Frontend: JavaScript', 'fe-javascript',       'frontend', 20),
  ('Frontend: TypeScript', 'fe-typescript',       'frontend', 21),
  ('Frontend: React',      'fe-react',            'frontend', 22),
  ('Frontend: CSS',        'fe-css',              'frontend', 23),
  ('Frontend: Performance','fe-performance',      'frontend', 24),
  ('Frontend: System Design','fe-system-design',  'frontend', 25)
on conflict (slug) do nothing;

-- ============================================================
-- SEED: User Profile (single user, no auth)
-- ============================================================
insert into user_profile (
  display_name, experience_years, primary_role,
  target_companies, preferred_languages, voice_language
) values (
  'Anh', 6, 'Frontend Engineer',
  '{"Google","Meta","Amazon","Apple"}',
  '{"javascript","typescript"}',
  'en-US'
)
on conflict do nothing;

-- ============================================================
-- SEED: User Topic Stats (one row per topic, starting weights)
-- ============================================================
insert into user_topic_stats (topic_id, mastery_level, weight)
select id, 'beginner', 1.0
from topics
on conflict (topic_id) do nothing;
