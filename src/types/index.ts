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

export interface PromptContext {
  profileSummary?: string
  topicMastery?: {
    topicName: string
    masteryLevel: string
    totalAttempts: number
    avgScore: number
  }
  previousSolutions?: PreviousSolutionContext[]   // solution history for this question
}

// --- Practice Mode AI panel mode ---
export type PracticeAiMode = 'off' | 'chat'
