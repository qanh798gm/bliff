-- ============================================================
-- Phase 3: Add onboarding columns to user_profile
-- ============================================================

alter table user_profile
  add column if not exists experience_level text not null default 'mid'
    check (experience_level in ('junior', 'mid', 'senior')),
  add column if not exists interview_focus text not null default 'dsa'
    check (interview_focus in ('dsa', 'frontend', 'both')),
  add column if not exists weekly_goal integer not null default 3,
  add column if not exists onboarding_completed boolean not null default false;
