-- ============================================================
-- user_solutions — stores ranked solutions per user per question
-- Supports multi-solution tracking: brute force → optimized tiers
-- ============================================================

create table if not exists user_solutions (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references auth.users(id) on delete cascade,
  question_id       uuid not null references questions(id) on delete cascade,
  attempt_id        uuid references attempts(id) on delete set null,
  label             text not null,               -- "Brute Force", "Hash Map", "Optimized", etc.
  rank              integer not null,             -- 1 = first solved, 2 = improved, ...
  code              text not null,
  language          text not null default 'javascript',
  time_complexity   text,                         -- e.g. "O(n)"
  space_complexity  text,                         -- e.g. "O(n)"
  ai_notes          text,                         -- AI commentary on this specific solution
  is_best           boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (user_id, question_id, rank)
);

-- ── Indexes ──────────────────────────────────────────────────
create index if not exists user_solutions_user_question
  on user_solutions (user_id, question_id);

create index if not exists user_solutions_user_id
  on user_solutions (user_id);

-- ── Auto-update updated_at ────────────────────────────────────
create or replace function update_user_solutions_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_user_solutions_updated_at on user_solutions;
create trigger trg_user_solutions_updated_at
  before update on user_solutions
  for each row execute function update_user_solutions_updated_at();

-- ── Row Level Security ────────────────────────────────────────
alter table user_solutions enable row level security;

create policy "users can read own solutions"
  on user_solutions for select
  using (auth.uid() = user_id);

create policy "users can insert own solutions"
  on user_solutions for insert
  with check (auth.uid() = user_id);

create policy "users can update own solutions"
  on user_solutions for update
  using (auth.uid() = user_id);

create policy "users can delete own solutions"
  on user_solutions for delete
  using (auth.uid() = user_id);
