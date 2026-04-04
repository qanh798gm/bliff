// ============================================================
// Shared TypeScript types for Bliff
// ============================================================

// --- Interview Stage ---
export type InterviewStage =
  | 'idle'       // Not started
  | 'warmup'     // Free chat with AI before any problem (greeter / warm-up)
  | 'present'    // AI is presenting the problem
  | 'clarify'    // User is asking clarifying questions
  | 'solve'      // User is working on solution
  | 'review'     // User submitted, AI is reviewing
  | 'feedback'   // AI is giving final feedback

// --- Message in the chat / voice transcript ---
export interface Message {
  id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  timestamp: number
}

// --- Test case tier ---
export type TestCaseTier = 'basic' | 'edge' | 'corner' | 'performance'

// --- Test case for a question ---
export interface TestCase {
  id: number
  description: string
  input: Record<string, unknown>
  expected: unknown
  tier?: TestCaseTier           // basic=happy path, edge=bounds, corner=tricky, performance=large input
  orderIndependent?: boolean    // true for index-pair problems where result order doesn't matter (e.g. Two Sum)
}

// --- Result of running a test case ---
export interface TestResult {
  id: number
  passed: boolean
  description: string
  input: unknown
  expected: unknown
  actual: unknown
  error?: string
  durationMs: number
}

// --- A DSA question ---
export interface Question {
  id: string
  title: string
  slug: string
  difficulty: 'easy' | 'medium' | 'hard'
  topic: string
  description: string
  examples: Array<{
    input: string
    output: string
    explanation?: string
  }>
  constraints: string[]
  hints: string[]
  expectedApproach: string
  expectedTimeComplexity: string
  expectedSpaceComplexity: string
  testCases: TestCase[]
  entryPoint: string
  functionSignature: string
}

// --- AI structured feedback after a session ---
export interface AiFeedback {
  approachScore: number
  complexityScore: number
  edgeCasesScore: number
  communicationScore: number
  codeQualityScore: number
  strengths: string[]
  improvements: string[]
  summary: string
}

// --- Voice provider options ---
export type STTProvider = 'webspeech' | 'groq'
export type TTSProvider = 'webspeech' | 'groq'

// --- Voice state ---
export type VoiceStatus =
  | 'idle'
  | 'listening'
  | 'processing'
  | 'speaking'
  | 'error'
  | 'unsupported'

// --- Voice language ---
export type VoiceLanguage = 'en-US' | 'vi-VN'

// --- User profile types ---
export type ExperienceLevel = 'junior' | 'mid' | 'senior'
export type InterviewFocus = 'dsa' | 'frontend' | 'both'

// --- LLM config ---
export interface LLMConfig {
  baseUrl: string
  apiKey: string
  model: string
}

// --- A saved user solution (ranked per question) ---
export interface UserSolution {
  id: string
  questionId: string
  attemptId: string | null
  label: string                  // "Brute Force", "Hash Map", "Optimized", etc.
  rank: number                   // 1 = first, 2 = improved, ...
  code: string
  language: string
  timeComplexity: string | null
  spaceComplexity: string | null
  aiNotes: string | null
  isBest: boolean
  createdAt: string
  updatedAt: string
}

export type SolutionLabel = 'Brute Force' | 'Better' | 'Optimal' | 'Alternative' | string

// --- AI Prompt context — injected into system prompt builder ---
// Used in both Interview Mode and Practice Mode (AI-on)
export interface PreviousSolutionContext {
  label: string
  rank: number
  timeComplexity: string | null
  spaceComplexity: string | null
  aiNotes: string | null
  code?: string      // included in Practice Mode; omitted in Interview to avoid spoilers
}

// --- Phase 5: Long-term memory types ---
export type MemoryType =
  | 'habit'          // behavioral pattern across sessions
  | 'skill_pattern'  // cross-topic skill observation
  | 'topic_insight'  // detailed insight about a specific topic
  | 'weekly_summary' // weekly rollup, expires after 30 days
  | 'session_note'   // one-off note from a specific session

// App-layer representation of a user_memory row (camelCase)
export interface UserMemory {
  id: string
  memoryType: MemoryType
  topicId: string | null
  content: string
  evidenceCount: number
  confidence: number              // 0.0–1.0
  sourceSessionId: string | null
  validUntil: string | null
  createdAt: string
  updatedAt: string
}

// What the LLM outputs inside <memory_json>...</memory_json> at session end
export interface MemoryWriteItem {
  memory_type: MemoryType
  topic_slug: string | null       // resolved to topic_id by memoryService
  content: string
  confidence: number
}

export interface PromptContext {
  profileSummary?: string
  topicMastery?: {
    topicName: string
    masteryLevel: string
    totalAttempts: number
    avgScore: number
  }
  previousSolutions?: PreviousSolutionContext[]   // solution history for this question
  coachMemory?: UserMemory[]                      // Phase 5: long-term memory injected at session start
}

// --- Practice Mode AI panel mode ---
export type PracticeAiMode = 'off' | 'chat'

// --- Phase 5: Mentor Chat recommendation cards ---
// Parsed from <recommendations> block in mentor chat AI responses.
// Rendered as clickable cards on the Dashboard.
export interface MentorRecommendation {
  type: 'practice' | 'interview'
  slug: string
  title: string
  reason: string
}

// --- Phase 5: Warmup handoff — mentor → interview/practice ---
// Written to sessionStorage when user clicks a recommendation card.
// Read once by useInterview/usePractice on mount, then deleted.
export interface WarmupHandoff {
  /** 2-3 sentence summary of the mentor chat — injected as [WARMUP CONTEXT] */
  summary: string
  /** The problem slug that was recommended */
  recommendedSlug: string
  recommendedType: 'practice' | 'interview'
  /** Unix timestamp — used to reject stale handoffs (> 10 min old) */
  timestamp: number
}

export const WARMUP_HANDOFF_KEY = 'bliff_warmup_handoff'
export const WARMUP_HANDOFF_TTL_MS = 10 * 60 * 1000   // 10 minutes
