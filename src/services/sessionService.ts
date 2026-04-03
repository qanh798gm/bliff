import { supabase } from '../lib/supabase'
import type {
  SessionRow,
  AttemptRow,
  ConversationMessage,
  AiFeedback,
  AttemptStatus,
  SessionMode,
} from '../types/database'

// ── Create a new session ─────────────────────────────────────
export async function createSession(
  mode: SessionMode = 'interview',
  voiceLanguage = 'en-US'
): Promise<SessionRow> {
  const { data, error } = await supabase
    .from('sessions')
    .insert({ mode, voice_language: voiceLanguage })
    .select()
    .single()

  if (error) throw error
  return data
}

// ── End a session ────────────────────────────────────────────
export async function endSession(
  sessionId: string,
  overallScore?: number,
  aiFeedbackSummary?: string
): Promise<void> {
  const { error } = await supabase
    .from('sessions')
    .update({
      ended_at: new Date().toISOString(),
      overall_score: overallScore ?? null,
      ai_feedback_summary: aiFeedbackSummary ?? null,
    })
    .eq('id', sessionId)

  if (error) throw error
}

// ── Create an attempt for a question in a session ────────────
export async function createAttempt(
  sessionId: string,
  questionId: string
): Promise<AttemptRow> {
  const { data, error } = await supabase
    .from('attempts')
    .insert({
      session_id: sessionId,
      question_id: questionId,
      status: 'in_progress',
    })
    .select()
    .single()

  if (error) throw error
  return data
}

// ── Update attempt with solution + outcome ───────────────────
export async function finalizeAttempt(
  attemptId: string,
  updates: {
    status: AttemptStatus
    solutionCode?: string
    approachUsed?: string
    timeComplexityGiven?: string
    spaceComplexityGiven?: string
    hintsUsed?: number
    askedClarifying?: boolean
    aiScore?: number
    aiFeedback?: AiFeedback
    conversationLog?: ConversationMessage[]
  }
): Promise<void> {
  const endedAt = new Date().toISOString()

  // Compute duration
  const { data: existing } = await supabase
    .from('attempts')
    .select('started_at')
    .eq('id', attemptId)
    .single()

  const durationSeconds = existing
    ? Math.floor(
        (new Date(endedAt).getTime() - new Date(existing.started_at).getTime()) / 1000
      )
    : null

  const { error } = await supabase
    .from('attempts')
    .update({
      ended_at: endedAt,
      duration_seconds: durationSeconds,
      status: updates.status,
      solution_code: updates.solutionCode ?? null,
      approach_used: updates.approachUsed ?? null,
      time_complexity_given: updates.timeComplexityGiven ?? null,
      space_complexity_given: updates.spaceComplexityGiven ?? null,
      hints_used: updates.hintsUsed ?? 0,
      asked_clarifying: updates.askedClarifying ?? false,
      ai_score: updates.aiScore ?? null,
      ai_feedback: updates.aiFeedback ?? null,
      conversation_log: updates.conversationLog ?? [],
    })
    .eq('id', attemptId)

  if (error) throw error
}

// ── Append a message to conversation log ────────────────────
export async function appendConversationMessage(
  attemptId: string,
  message: ConversationMessage
): Promise<void> {
  const { data: existing, error: fetchError } = await supabase
    .from('attempts')
    .select('conversation_log')
    .eq('id', attemptId)
    .single()

  if (fetchError) throw fetchError

  const log: ConversationMessage[] = existing.conversation_log ?? []
  log.push(message)

  const { error } = await supabase
    .from('attempts')
    .update({ conversation_log: log })
    .eq('id', attemptId)

  if (error) throw error
}

// ── Get recent sessions ──────────────────────────────────────
export async function getRecentSessions(limit = 20): Promise<SessionRow[]> {
  const { data, error } = await supabase
    .from('sessions')
    .select('*')
    .order('started_at', { ascending: false })
    .limit(limit)

  if (error) throw error
  return data ?? []
}

// ── Get attempts for a session ───────────────────────────────
export async function getSessionAttempts(sessionId: string): Promise<AttemptRow[]> {
  const { data, error } = await supabase
    .from('attempts')
    .select('*')
    .eq('session_id', sessionId)
    .order('started_at')

  if (error) throw error
  return data ?? []
}

// ── Get question IDs attempted in the last N sessions ────────
export async function getRecentlyAttemptedQuestionIds(
  sessionCount = 5
): Promise<string[]> {
  const sessions = await getRecentSessions(sessionCount)
  if (sessions.length === 0) return []

  const sessionIds = sessions.map(s => s.id)

  const { data, error } = await supabase
    .from('attempts')
    .select('question_id')
    .in('session_id', sessionIds)

  if (error) throw error
  return [...new Set((data ?? []).map(a => a.question_id))]
}
