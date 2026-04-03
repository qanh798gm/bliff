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

export interface TestCaseRow {
  input: Record<string, unknown>
  expected: unknown
  description?: string
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
  primary_role: string
  target_companies: string[]
  preferred_languages: string[]
  voice_language: string
  strengths: string[]
  weaknesses: string[]
  notes: string | null
  current_streak: number
  longest_streak: number
  last_session_date: string | null
  created_at: string
  updated_at: string
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
}

export interface SessionRow {
  id: string
  started_at: string
  ended_at: string | null
  mode: SessionMode
  voice_language: string
  overall_score: number | null
  ai_feedback_summary: string | null
  created_at: string
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
    }
    Views: Record<string, never>
    Functions: Record<string, never>
    Enums: Record<string, never>
  }
}
