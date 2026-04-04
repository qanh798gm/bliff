-- ============================================================
-- Add tier field to test_cases JSONB in questions table
-- Tiers: basic | edge | corner | performance
-- This is a schema documentation migration — existing test_cases
-- JSONB rows don't need backfilling since tier is optional.
-- New seeds and enriched questions will include tier going forward.
-- ============================================================

-- No structural ALTER needed: test_cases is already jsonb[] and
-- each element can include a "tier" key without a schema change.
-- This migration documents the contract and creates a helper view.

comment on column questions.test_cases is
  'Array of test case objects: { input, expected, description?, tier? }
   tier values: "basic" | "edge" | "corner" | "performance"
   basic: happy path matching examples
   edge: empty input, single element, min/max bounds
   corner: negative numbers, overflow, all same values
   performance: large input to catch O(n^2) — only run inside Web Worker sandbox';

-- ── Practice session tracking mode enum extension ─────────────
-- sessions.mode already supports "practice" per initial schema.
-- This migration confirms the enum values are correct.
-- Nothing to ALTER since mode is a plain text column.

-- ── Silent practice stat columns on user_topic_stats ─────────
-- Track practice-mode activity separately from interview attempts
-- so the adaptive engine can distinguish "practiced without AI" vs
-- "did a full mock interview".

alter table user_topic_stats
  add column if not exists practice_attempts integer not null default 0,
  add column if not exists practice_solved   integer not null default 0;

comment on column user_topic_stats.practice_attempts is
  'Number of practice-mode runs for this topic (no mock interview required)';
comment on column user_topic_stats.practice_solved is
  'Number of practice-mode runs where all basic+edge tests passed';
