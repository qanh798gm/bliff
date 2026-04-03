-- ============================================================
-- Phase 3b: Add user_id to sessions (and attempts) for multi-user auth
-- ============================================================

-- Add user_id to sessions (nullable first so existing rows don't fail)
alter table sessions
  add column if not exists user_id uuid references auth.users(id) on delete cascade;

-- Add user_id to attempts as well (for direct per-user queries)
alter table attempts
  add column if not exists user_id uuid references auth.users(id) on delete cascade;

-- Back-fill existing rows with a sentinel value (dev only — prod has no rows)
-- We leave them NULL; queries that filter by user_id simply skip old rows.

-- Index for fast per-user lookups
create index if not exists idx_sessions_user_id on sessions(user_id);
create index if not exists idx_attempts_user_id on attempts(user_id);

-- Enable RLS
alter table sessions enable row level security;
alter table attempts enable row level security;

-- RLS: users see only their own sessions
create policy "sessions: owner access"
  on sessions for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- RLS: users see only their own attempts
create policy "attempts: owner access"
  on attempts for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
