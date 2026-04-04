import { useState, useCallback, useRef, useEffect } from 'react'
import type { Question, Message, TestResult, UserSolution, PracticeAiMode } from '../types'
import { TWO_SUM } from '../data/questions'
import { fetchQuestionBySlug } from '../services/questionService'
import { rowToQuestion } from '../lib/questionAdapter'
import { runTests } from '../services/codeRunner'
import { streamChatCompletion } from '../services/llm'
import { buildSystemPrompt } from '../lib/promptBuilder'
import { buildProfileSummary } from '../services/profileService'
import {
  fetchSolutionsForQuestion,
  saveSolution,
  markAsBest,
  deleteSolution,
  fetchSolutionsForPrompt,
} from '../services/solutionService'
import { createSession, endSession as dbEndSession, createAttempt, finalizeAttempt } from '../services/sessionService'

// ============================================================
// usePractice — state machine for Practice Mode
// No stage machine — user-driven. AI is opt-in.
// ============================================================

interface UsePracticeReturn {
  question: Question
  isLoadingQuestion: boolean

  // Code & testing
  testResults: TestResult[]
  isRunningTests: boolean
  runTests: (code: string) => Promise<void>

  // Solutions
  solutions: UserSolution[]
  isLoadingSolutions: boolean
  isSavingSolution: boolean
  saveSolution: (params: {
    code: string
    label: string
    timeComplexity: string
    spaceComplexity: string
  }) => Promise<void>
  markSolutionAsBest: (id: string) => Promise<void>
  deleteSolution: (id: string) => Promise<void>

  // AI chat (opt-in)
  aiMode: PracticeAiMode
  setAiMode: (mode: PracticeAiMode) => void
  messages: Message[]
  isThinking: boolean
  sendMessage: (text: string) => Promise<void>
  clearChat: () => void
}

function makeMessage(role: Message['role'], content: string): Message {
  return {
    id: crypto.randomUUID(),
    role,
    content,
    timestamp: Date.now(),
  }
}

export function usePractice(slug?: string): UsePracticeReturn {
  const [question, setQuestion] = useState<Question>(TWO_SUM)
  const [isLoadingQuestion, setIsLoadingQuestion] = useState(false)

  const [testResults, setTestResults] = useState<TestResult[]>([])
  const [isRunningTests, setIsRunningTests] = useState(false)

  const [solutions, setSolutions] = useState<UserSolution[]>([])
  const [isLoadingSolutions, setIsLoadingSolutions] = useState(false)
  const [isSavingSolution, setIsSavingSolution] = useState(false)

  const [aiMode, setAiMode] = useState<PracticeAiMode>('off')
  const [messages, setMessages] = useState<Message[]>([])
  const [isThinking, setIsThinking] = useState(false)

  // Practice session tracking refs
  const dbSessionIdRef = useRef<string | null>(null)
  const dbAttemptIdRef = useRef<string | null>(null)
  const runCountRef = useRef(0)
  const startTimeRef = useRef<number>(Date.now())

  // ── Load question from slug on mount ──────────────────────
  useEffect(() => {
    if (!slug) return
    setIsLoadingQuestion(true)
    fetchQuestionBySlug(slug)
      .then((row) => {
        const q = rowToQuestion(row)
        setQuestion(q)
        // Load solutions for this question
        loadSolutions(q.id)
        // Start silent tracking session
        void startPracticeSession(q.id)
      })
      .catch(() => { /* keep TWO_SUM fallback */ })
      .finally(() => setIsLoadingQuestion(false))
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [slug])

  // ── Load saved solutions ──────────────────────────────────
  function loadSolutions(questionId: string) {
    setIsLoadingSolutions(true)
    fetchSolutionsForQuestion(questionId)
      .then(setSolutions)
      .catch(() => setSolutions([]))
      .finally(() => setIsLoadingSolutions(false))
  }

  // ── Silent session tracking (practice mode) ───────────────
  async function startPracticeSession(questionId: string) {
    try {
      startTimeRef.current = Date.now()
      const session = await createSession('practice').catch(() => null)
      if (session) {
        dbSessionIdRef.current = session.id
        const attempt = await createAttempt(session.id, questionId).catch(() => null)
        if (attempt) dbAttemptIdRef.current = attempt.id
      }
    } catch {
      // Non-fatal — practice works without DB
    }
  }

  // Finalize practice session when component unmounts
  useEffect(() => {
    return () => {
      const attemptId = dbAttemptIdRef.current
      const sessionId = dbSessionIdRef.current
      const durationMs = Date.now() - startTimeRef.current

      if (attemptId) {
        finalizeAttempt(attemptId, {
          status: testResults.some((r) => r.passed) ? 'partial' : 'in_progress',
          hintsUsed: 0,
          askedClarifying: false,
          conversationLog: [],
        }).catch(() => {})
      }
      if (sessionId) {
        dbEndSession(sessionId).catch(() => {})
      }
      void durationMs // suppress unused warning
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  // ── Run tests ─────────────────────────────────────────────
  const handleRunTests = useCallback(async (code: string) => {
    setIsRunningTests(true)
    setTestResults([])
    runCountRef.current += 1
    try {
      const results = await runTests(code, question.testCases, question.entryPoint)
      setTestResults(results)
    } catch (err) {
      console.error('[usePractice] runTests error:', err)
    } finally {
      setIsRunningTests(false)
    }
  }, [question])

  // ── Save solution ─────────────────────────────────────────
  const handleSaveSolution = useCallback(async (params: {
    code: string
    label: string
    timeComplexity: string
    spaceComplexity: string
  }) => {
    setIsSavingSolution(true)
    try {
      const saved = await saveSolution({
        questionId: question.id,
        label: params.label,
        code: params.code,
        timeComplexity: params.timeComplexity || undefined,
        spaceComplexity: params.spaceComplexity || undefined,
        attemptId: dbAttemptIdRef.current ?? undefined,
      })
      setSolutions((prev) => [...prev, saved].sort((a, b) => a.rank - b.rank))
    } finally {
      setIsSavingSolution(false)
    }
  }, [question.id])

  // ── Mark solution as best ─────────────────────────────────
  const handleMarkBest = useCallback(async (id: string) => {
    await markAsBest(id, question.id)
    setSolutions((prev) => prev.map((s) => ({ ...s, isBest: s.id === id })))
  }, [question.id])

  // ── Delete solution ───────────────────────────────────────
  const handleDeleteSolution = useCallback(async (id: string) => {
    await deleteSolution(id)
    setSolutions((prev) => prev.filter((s) => s.id !== id))
  }, [])

  // ── AI chat ───────────────────────────────────────────────
  const sendMessage = useCallback(async (text: string) => {
    if (isThinking) return

    const userMsg = makeMessage('user', text)
    setMessages((prev) => [...prev, userMsg])
    setIsThinking(true)

    try {
      // Build practice-mode AI context (includes full code of saved solutions)
      const [profileSummary, previousSolutions] = await Promise.all([
        buildProfileSummary().catch(() => ''),
        fetchSolutionsForPrompt(question.id, true).catch(() => []),
      ])

      const systemPrompt = buildSystemPrompt(question, 'solve', 0, false, {
        profileSummary,
        previousSolutions,
      })

      const assistantMsg = makeMessage('assistant', '')
      setMessages((prev) => [...prev, assistantMsg])

      let fullText = ''
      await streamChatCompletion(
        systemPrompt + '\n\n=== PRACTICE MODE ===\nThe candidate is in self-directed practice mode. Be a helpful coach — give hints, analyze their approach, compare solutions, explain trade-offs. You may reveal approaches when asked, unlike in interview mode.',
        [...messages, userMsg],
        (chunk) => {
          fullText += chunk
          setMessages((prev) =>
            prev.map((m) => m.id === assistantMsg.id ? { ...m, content: fullText } : m)
          )
        }
      )
    } catch (err) {
      const errorText = `Error: ${err instanceof Error ? err.message : 'Unknown error'}`
      setMessages((prev) => {
        const last = prev[prev.length - 1]
        if (last?.role === 'assistant' && last.content === '') {
          return prev.map((m, i) => i === prev.length - 1 ? { ...m, content: errorText } : m)
        }
        return [...prev, makeMessage('assistant', errorText)]
      })
    } finally {
      setIsThinking(false)
    }
  }, [isThinking, messages, question])

  const clearChat = useCallback(() => {
    setMessages([])
  }, [])

  return {
    question,
    isLoadingQuestion,
    testResults,
    isRunningTests,
    runTests: handleRunTests,
    solutions,
    isLoadingSolutions,
    isSavingSolution,
    saveSolution: handleSaveSolution,
    markSolutionAsBest: handleMarkBest,
    deleteSolution: handleDeleteSolution,
    aiMode,
    setAiMode,
    messages,
    isThinking,
    sendMessage,
    clearChat,
  }
}
