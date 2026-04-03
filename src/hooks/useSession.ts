import { useState, useRef, useCallback } from 'react'
import {
  createSession,
  endSession,
  createAttempt,
  finalizeAttempt,
  appendConversationMessage,
  getRecentlyAttemptedQuestionIds,
} from '../services/sessionService'
import { updateTopicStats } from '../services/questionService'
import type { SessionRow, AttemptRow, ConversationMessage, AiFeedback } from '../types/database'

interface UseSessionReturn {
  session: SessionRow | null
  currentAttempt: AttemptRow | null
  recentlyAttemptedIds: string[]
  startSession: (mode?: 'interview' | 'practice' | 'review') => Promise<void>
  stopSession: (overallScore?: number, summary?: string) => Promise<void>
  startAttempt: (questionId: string) => Promise<void>
  completeAttempt: (params: CompleteAttemptParams) => Promise<void>
  logMessage: (message: ConversationMessage) => Promise<void>
  loadRecentlyAttempted: () => Promise<void>
}

interface CompleteAttemptParams {
  status: 'solved' | 'partial' | 'gave_up'
  solutionCode?: string
  approachUsed?: string
  timeComplexityGiven?: string
  spaceComplexityGiven?: string
  hintsUsed?: number
  askedClarifying?: boolean
  aiScore?: number
  aiFeedback?: AiFeedback
  conversationLog?: ConversationMessage[]
  topicId?: string
}

export function useSession(): UseSessionReturn {
  const [session, setSession] = useState<SessionRow | null>(null)
  const [currentAttempt, setCurrentAttempt] = useState<AttemptRow | null>(null)
  const [recentlyAttemptedIds, setRecentlyAttemptedIds] = useState<string[]>([])

  // Keep a ref to the current attempt ID to avoid stale closure issues
  const attemptIdRef = useRef<string | null>(null)

  const startSession = useCallback(
    async (mode: 'interview' | 'practice' | 'review' = 'interview') => {
      try {
        const s = await createSession(mode)
        setSession(s)
      } catch (err) {
        console.error('[useSession] startSession error:', err)
        throw err
      }
    },
    []
  )

  const stopSession = useCallback(
    async (overallScore?: number, summary?: string) => {
      if (!session) return
      try {
        await endSession(session.id, overallScore, summary)
        setSession(null)
        setCurrentAttempt(null)
        attemptIdRef.current = null
      } catch (err) {
        console.error('[useSession] stopSession error:', err)
      }
    },
    [session]
  )

  const startAttempt = useCallback(
    async (questionId: string) => {
      if (!session) {
        console.warn('[useSession] startAttempt called without active session')
        return
      }
      try {
        const attempt = await createAttempt(session.id, questionId)
        setCurrentAttempt(attempt)
        attemptIdRef.current = attempt.id
      } catch (err) {
        console.error('[useSession] startAttempt error:', err)
        throw err
      }
    },
    [session]
  )

  const completeAttempt = useCallback(
    async (params: CompleteAttemptParams) => {
      const id = attemptIdRef.current
      if (!id) {
        console.warn('[useSession] completeAttempt called without active attempt')
        return
      }
      try {
        await finalizeAttempt(id, {
          status: params.status,
          solutionCode: params.solutionCode,
          approachUsed: params.approachUsed,
          timeComplexityGiven: params.timeComplexityGiven,
          spaceComplexityGiven: params.spaceComplexityGiven,
          hintsUsed: params.hintsUsed ?? 0,
          askedClarifying: params.askedClarifying ?? false,
          aiScore: params.aiScore,
          aiFeedback: params.aiFeedback,
          conversationLog: params.conversationLog,
        })

        // Update topic stats if topic is known
        if (params.topicId && params.aiScore !== undefined) {
          const duration = currentAttempt
            ? Math.floor(
                (Date.now() - new Date(currentAttempt.started_at).getTime()) / 1000
              )
            : 0
          await updateTopicStats(
            params.topicId,
            params.aiScore,
            duration,
            params.status
          )
        }

        setCurrentAttempt(null)
        attemptIdRef.current = null
      } catch (err) {
        console.error('[useSession] completeAttempt error:', err)
        throw err
      }
    },
    [currentAttempt]
  )

  const logMessage = useCallback(async (message: ConversationMessage) => {
    const id = attemptIdRef.current
    if (!id) return
    try {
      await appendConversationMessage(id, message)
    } catch (err) {
      // Non-critical — log but don't throw
      console.warn('[useSession] logMessage error (non-critical):', err)
    }
  }, [])

  const loadRecentlyAttempted = useCallback(async () => {
    try {
      const ids = await getRecentlyAttemptedQuestionIds(5)
      setRecentlyAttemptedIds(ids)
    } catch (err) {
      console.warn('[useSession] loadRecentlyAttempted error:', err)
    }
  }, [])

  return {
    session,
    currentAttempt,
    recentlyAttemptedIds,
    startSession,
    stopSession,
    startAttempt,
    completeAttempt,
    logMessage,
    loadRecentlyAttempted,
  }
}
