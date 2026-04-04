// ============================================================
// Auto-typed Supabase database schema
// Matches supabase/migrations/20240403000001_initial_schema.sql
// ============================================================

export type Difficulty = 'easy' | 'medium' | 'hard'
export type QuestionSource = 'blind75' | 'neetcode150' | 'fe-curated' | 'custom'
export type TopicCategory = 'dsa' | 'frontend'
export type MasteryLevel = 'beginner' | 'developing' | 'proficient' | 'mastered'
export type SessionMode = 'interview' | 'practice' | 'review'
export type AttemptStatus = 'solved' | 'partial' | 'gave_up' | 'in_progress'

// ---- Row types (as returned by SELECT) -----------------------

export interface TopicRow {
  id: string
  name: string
  slug: string
  category: TopicCategory
  display_order: number
}

export interface QuestionExample {
  input: string
  output: string
  explanation?: string
}

export type TestCaseTier = 'basic' | 'edge' | 'corner' | 'performance'

export interface TestCaseRow {
  input: Record<string, unknown>
  expected: unknown
  description?: string
  tier?: TestCaseTier           // basic | edge | corner | performance
  orderIndependent?: boolean    // true for index-pair problems (Two Sum etc.)
}

export interface QuestionRow {
  id: string
  title: string
  slug: string
  topic_id: string
  difficulty: Difficulty
  source: QuestionSource
  description: string
  examples: QuestionExample[]
  constraints: string[]
  hints: string[]
  expected_approach: string | null
  expected_time_complexity: string | null
  expected_space_complexity: string | null
  tags: string[]
  entry_point: string | null
  function_signature: string | null
  leetcode_number: number | null
  test_cases: TestCaseRow[]
  is_active: boolean
  created_at: string
}

export interface UserProfileRow {
  id: string
  display_name: string
  experience_years: number
  experience_level: 'junior' | 'mid' | 'senior'
  primary_role: string
  interview_focus: 'dsa' | 'frontend' | 'both'
  target_companies: string[]
  preferred_languages: string[]
  voice_language: string
  strengths: string[]
  weaknesses: string[]
  notes: string | null
  current_streak: number
  longest_streak: number
  last_session_date: string | null
  weekly_goal: number
  onboarding_completed: boolean
  created_at: string
  updated_at: string
}

// ---- Materialized view: topic_stats (joined with topics) ------
export interface TopicStatRow {
  topic_id: string
  topic_name: string
  attempts_count: number
  solved_count: number
  mastery_score: number   // 0–1 float
  last_attempted_at: string | null
}

export interface UserTopicStatsRow {
  id: string
  topic_id: string
  total_attempts: number
  solved_count: number
  partial_count: number
  gave_up_count: number
  avg_score: number
  avg_duration_seconds: number
  last_attempted_at: string | null
  mastery_level: MasteryLevel
  weight: number
  practice_attempts: number   // practice-mode runs (no mock interview required)
  practice_solved: number     // practice runs where all basic+edge tests passed
}

// ---- user_solutions — ranked solutions per user per question ----
export interface UserSolutionRow {
  id: string
  user_id: string
  question_id: string
  attempt_id: string | null    // linked to interview session attempt if applicable
  label: string                // "Brute Force", "Hash Map", "Optimized", "Alternative"
  rank: number                 // 1 = first saved, 2 = improved, ...
  code: string
  language: string             // "javascript", "python", etc.
  time_complexity: string | null
  space_complexity: string | null
  ai_notes: string | null      // AI commentary on this specific solution
  is_best: boolean
  created_at: string
  updated_at: string
}

export type SolutionLabel =
  | 'Brute Force'
  | 'Better'
  | 'Optimal'
  | 'Alternative'
  | string   // free-form custom label

// ---- user_memory — Phase 5: AI long-term memory ────────────────
export type MemoryType =
  | 'habit'          // behavioral pattern across sessions
  | 'skill_pattern'  // cross-topic skill observation
  | 'topic_insight'  // detailed insight about a specific topic
  | 'weekly_summary' // weekly rollup, expires after 30 days
  | 'session_note'   // one-off note from a specific session

export interface UserMemoryRow {
  id: string
  user_id: string
  memory_type: MemoryType
  topic_id: string | null         // NULL = global/cross-topic
  content: string                 // natural language, 1-3 sentences
  evidence_count: number          // sessions corroborating this memory
  confidence: number              // 0.0–1.0
  source_session_id: string | null
  valid_until: string | null      // ISO timestamp or null (evergreen)
  created_at: string
  updated_at: string
}

export interface SessionRow {
  id: string
  user_id: string | null
  started_at: string
  ended_at: string | null
  mode: SessionMode
  voice_language: string
  overall_score: number | null
  ai_feedback_summary: string | null
  session_context: SessionContextSnapshot | null   // Phase 5: what AI knew at session start
  conversation_summary: string | null              // Phase 5: rolling summary of trimmed messages
  created_at: string
}

// ---- session_context JSONB shape (Phase 5) ────────────────────
export interface SessionContextSnapshot {
  profile_snapshot: {
    display_name: string
    experience_years: number
    primary_role: string
    target_companies: string[]
    strengths: string[]
    weaknesses: string[]
  }
  topic_mastery: {
    topicName: string
    masteryLevel: string
    totalAttempts: number
    avgScore: number
  } | null
  memories_loaded: number
  solutions_loaded: number
  context_assembled_at: string   // ISO timestamp
}

export interface ConversationMessage {
  role: 'user' | 'assistant' | 'system'
  content: string
  timestamp: string
}

export interface AiFeedback {
  correctness: number
  efficiency: number
  communication: number
  summary: string
  strengths: string[]
  improvements: string[]
}

export interface AttemptRow {
  id: string
  session_id: string
  question_id: string
  user_id: string | null
  started_at: string
  ended_at: string | null
  duration_seconds: number | null
  status: AttemptStatus
  hints_used: number
  asked_clarifying: boolean
  solution_code: string | null
  approach_used: string | null
  time_complexity_given: string | null
  space_complexity_given: string | null
  ai_score: number | null
  ai_feedback: AiFeedback | null
  conversation_log: ConversationMessage[]
  created_at: string
}

// ---- Supabase Database type (for createClient<Database>) ------

export interface Database {
  public: {
    Tables: {
      topics: {
        Row: TopicRow
        Insert: Omit<TopicRow, 'id'> & { id?: string }
        Update: Partial<Omit<TopicRow, 'id'>>
      }
      questions: {
        Row: QuestionRow
        Insert: Omit<QuestionRow, 'id' | 'created_at'> & { id?: string; created_at?: string }
        Update: Partial<Omit<QuestionRow, 'id' | 'created_at'>>
      }
      user_profile: {
        Row: UserProfileRow
        Insert: Omit<UserProfileRow, 'id' | 'created_at' | 'updated_at'> & { id?: string }
        Update: Partial<Omit<UserProfileRow, 'id' | 'created_at'>>
      }
      user_topic_stats: {
        Row: UserTopicStatsRow
        Insert: Omit<UserTopicStatsRow, 'id'> & { id?: string }
        Update: Partial<Omit<UserTopicStatsRow, 'id'>>
      }
      sessions: {
        Row: SessionRow
        Insert: Omit<SessionRow, 'id' | 'created_at'> & { id?: string }
        Update: Partial<Omit<SessionRow, 'id' | 'created_at'>>
      }
      attempts: {
        Row: AttemptRow
        Insert: Omit<AttemptRow, 'id' | 'created_at'> & { id?: string }
        Update: Partial<Omit<AttemptRow, 'id' | 'created_at'>>
      }
      user_solutions: {
        Row: UserSolutionRow
        Insert: Omit<UserSolutionRow, 'id' | 'created_at' | 'updated_at'> & { id?: string }
        Update: Partial<Omit<UserSolutionRow, 'id' | 'created_at' | 'updated_at'>>
      }
      user_memory: {
        Row: UserMemoryRow
        Insert: Omit<UserMemoryRow, 'id' | 'created_at' | 'updated_at'> & { id?: string }
        Update: Partial<Omit<UserMemoryRow, 'id' | 'created_at' | 'updated_at'>>
      }
    }
    Views: Record<string, never>
    Functions: Record<string, never>
    Enums: Record<string, never>
  }
}
