import { useState, useCallback, useRef, useEffect } from 'react'
import type { Message, InterviewStage, Question, TestResult } from '../types'
import { streamChatCompletion } from '../services/llm'
import { buildSystemPrompt, parseFeedbackJson, parseMemoryJson, readAndClearWarmupHandoff, buildWarmupContextBlock, type PromptContext } from '../lib/promptBuilder'
import { runTests, formatResultsForAI } from '../services/codeRunner'
import { selectNextQuestion, fetchQuestionBySlug } from '../services/questionService'
import { buildProfileSummary, getTopicStats } from '../services/profileService'
import {
  createSession,
  endSession as dbEndSession,
  createAttempt,
  finalizeAttempt,
  getRecentlyAttemptedQuestionIds,
} from '../services/sessionService'
import { fetchSolutionsForPrompt } from '../services/solutionService'
import {
  loadSessionMemory,
  upsertMemories,
  expireOldSummaries,
  saveSessionContext,
} from '../services/memoryService'
import { rowToQuestion } from '../lib/questionAdapter'
import { TWO_SUM } from '../data/questions'

// Max live messages before older ones are summarized into a rolling context note
const MAX_LIVE_MESSAGES = 20

// ============================================================
// useInterview — interview state machine
// Manages: stage, messages, hints, code, test results
// ============================================================

interface UseInterviewReturn {
  stage: InterviewStage
  question: Question
  messages: Message[]
  isThinking: boolean
  hintsGiven: number
  askedClarifying: boolean
  testResults: TestResult[]
  isRunningTests: boolean
  isLoadingQuestion: boolean
  sendMessage: (text: string) => Promise<void>
  startWarmup: () => Promise<void>
  beginInterview: () => Promise<void>
  startSession: () => Promise<void>
  submitCode: (code: string) => Promise<void>
  runCode: (code: string) => Promise<void>
  requestHint: () => Promise<void>
  endSession: () => Promise<void>
  resetSession: () => void
}

function makeMessage(role: Message['role'], content: string): Message {
  return {
    id: crypto.randomUUID(),
    role,
    content,
    timestamp: Date.now(),
  }
}

export function useInterview(slug?: string): UseInterviewReturn {
  const [stage, setStage] = useState<InterviewStage>('idle')
  const [messages, setMessages] = useState<Message[]>([])
  const [isThinking, setIsThinking] = useState(false)
  const [hintsGiven, setHintsGiven] = useState(0)
  const [askedClarifying, setAskedClarifying] = useState(false)
  const [testResults, setTestResults] = useState<TestResult[]>([])
  const [isRunningTests, setIsRunningTests] = useState(false)

  // Phase 2: dynamic question from DB (fallback to TWO_SUM while DB not set up)
  const [question, setQuestion] = useState<Question>(TWO_SUM)
  const [isLoadingQuestion, setIsLoadingQuestion] = useState(false)

  // Eagerly load the question from slug as soon as the hook mounts so that
  // QuestionPanel shows the correct problem before the session even starts.
  useEffect(() => {
    if (!slug) return
    setIsLoadingQuestion(true)
    fetchQuestionBySlug(slug)
      .then((row) => setQuestion(rowToQuestion(row)))
      .catch(() => { /* keep TWO_SUM fallback */ })
      .finally(() => setIsLoadingQuestion(false))
  }, [slug])

  // Phase 2: DB persistence refs
  const dbSessionIdRef = useRef<string | null>(null)
  const dbAttemptIdRef = useRef<string | null>(null)
  const promptCtxRef = useRef<PromptContext>({})
  const conversationLogRef = useRef<{ role: string; content: string; timestamp: string }[]>([])
  // Phase 5: warmup handoff — read once from sessionStorage (consumed immediately)
  const warmupBlockRef = useRef<string>('')

  // Track stage in a ref so callbacks always see latest value
  const stageRef = useRef<InterviewStage>('idle')
  const setStageSync = (s: InterviewStage) => {
    stageRef.current = s
    setStage(s)
  }

  // Phase 5: read warmup handoff once on mount (consumed from sessionStorage)
  useEffect(() => {
    const handoff = readAndClearWarmupHandoff()
    if (handoff) {
      warmupBlockRef.current = buildWarmupContextBlock(handoff)
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  const appendMessage = useCallback((msg: Message) => {
    setMessages((prev) => [...prev, msg])
  }, [])

  const getSystemPrompt = useCallback(
    (currentStage: InterviewStage) => {
      const base = buildSystemPrompt(question, currentStage, hintsGiven, askedClarifying, promptCtxRef.current)
      return warmupBlockRef.current ? base + warmupBlockRef.current : base
    },
    [question, hintsGiven, askedClarifying],
  )

  // Send a user message and get AI response
  const sendMessage = useCallback(
    async (text: string) => {
      if (isThinking) return

      const userMsg = makeMessage('user', text)
      appendMessage(userMsg)

      // Detect if user is asking a clarifying question (during present/clarify stage)
      if (
        stageRef.current === 'present' ||
        stageRef.current === 'clarify'
      ) {
        const clarifyKeywords = ['what', 'can', 'should', 'is', 'are', 'will', 'does', 'do', 'could', 'would', '?']
        const looksLikeClarification = clarifyKeywords.some((kw) =>
          text.toLowerCase().includes(kw),
        )
        if (looksLikeClarification) {
          setAskedClarifying(true)
          setStageSync('clarify')
        }
      }

      // Transition from clarify → solve when user says they're ready
      if (stageRef.current === 'clarify') {
        const readyPhrases = ["i'll start", "let me start", "i'm ready", "ready", "let's go", "let me code", "bắt đầu", "tôi sẵn sàng"]
        if (readyPhrases.some((p) => text.toLowerCase().includes(p))) {
          setStageSync('solve')
        }
      }

      setIsThinking(true)

      // Phase 5: rolling conversation window — keep last MAX_LIVE_MESSAGES live.
      // Older messages are summarized into a single system note prepended to the prompt.
      // This bounds token cost without losing critical context.
      let activeMessages = [...messages, userMsg]
      let conversationPreamble = ''
      if (activeMessages.length > MAX_LIVE_MESSAGES) {
        const toSummarize = activeMessages.slice(0, activeMessages.length - MAX_LIVE_MESSAGES)
        activeMessages = activeMessages.slice(activeMessages.length - MAX_LIVE_MESSAGES)
        // Build a compact inline summary of the trimmed messages
        const summaryLines = toSummarize
          .filter((m) => m.role !== 'system')
          .map((m) => `${m.role === 'user' ? 'Candidate' : 'You'}: ${m.content.slice(0, 120)}${m.content.length > 120 ? '...' : ''}`)
        conversationPreamble = `[Earlier in this session (summarized):\n${summaryLines.join('\n')}]\n\n`
      }

      // Build current conversation for API
      const currentMessages = activeMessages
      const rawSystemPrompt = getSystemPrompt(stageRef.current)
      const systemPrompt = conversationPreamble
        ? `${rawSystemPrompt}\n\n${conversationPreamble}`
        : rawSystemPrompt

      // Stream the AI response
      const assistantMsg = makeMessage('assistant', '')
      appendMessage(assistantMsg)

      try {
        let fullText = ''
        await streamChatCompletion(systemPrompt, currentMessages, (chunk) => {
          fullText += chunk
          setMessages((prev) =>
            prev.map((m) =>
              m.id === assistantMsg.id ? { ...m, content: fullText } : m,
            ),
          )
        })
      } catch (err) {
        const errorText = `Sorry, I encountered an error: ${err instanceof Error ? err.message : 'Unknown error'}. Please check your API configuration.`
        setMessages((prev) =>
          prev.map((m) =>
            m.id === assistantMsg.id ? { ...m, content: errorText } : m,
          ),
        )
      } finally {
        setIsThinking(false)
      }
    },
    [isThinking, messages, appendMessage, getSystemPrompt],
  )

  // Start a new interview session — Phase 2: loads DB question + profile context
  const startSession = useCallback(async () => {
    setStageSync('present')
    setHintsGiven(0)
    setAskedClarifying(false)
    setTestResults([])
    setMessages([])
    conversationLogRef.current = []
    setIsThinking(true)
    setIsLoadingQuestion(true)

    // Phase 2: load profile context for prompts
    let activeQuestion = question
    try {
      const [profileSummary, topicStats, recentIds] = await Promise.all([
        buildProfileSummary().catch(() => ''),
        getTopicStats().catch(() => []),
        getRecentlyAttemptedQuestionIds(5).catch(() => []),
      ])

      // Build prompt context from profile data
      promptCtxRef.current = { profileSummary }

      // If a specific question was requested (from question browser), load it;
      // otherwise fall back to the adaptive selector
      const row = slug
        ? await fetchQuestionBySlug(slug).catch(() => null)
        : await selectNextQuestion(recentIds).catch(() => null)
      if (row) {
        const q = rowToQuestion(row)
        // Enrich topic mastery context
        const stat = topicStats.find(s => s.topic_id === row.topic_id)
        if (stat) {
          promptCtxRef.current.topicMastery = {
            topicName: stat.topic?.name ?? row.topic_id,
            masteryLevel: stat.mastery_level,
            totalAttempts: stat.total_attempts,
            avgScore: stat.avg_score,
          }
        }
        // Phase 4: inject previous solutions (without code — no spoilers in interview mode)
        const previousSolutions = await fetchSolutionsForPrompt(row.id, false).catch(() => [])
        if (previousSolutions.length > 0) {
          promptCtxRef.current.previousSolutions = previousSolutions
        }

        // Phase 5: load long-term coach memory for this topic
        await expireOldSummaries().catch(() => {})
        const topicIdForMemory = row.topic_id ?? null
        const memories = await loadSessionMemory(topicIdForMemory).catch(() => [])
        if (memories.length > 0) {
          promptCtxRef.current.coachMemory = memories
        }

        setQuestion(q)
        activeQuestion = q
      }

      // Create DB session + attempt
      const dbSession = await createSession('interview').catch(() => null)
      if (dbSession) {
        dbSessionIdRef.current = dbSession.id
        const attempt = await createAttempt(dbSession.id, activeQuestion.id).catch(() => null)
        if (attempt) dbAttemptIdRef.current = attempt.id

        // Phase 5: save context snapshot — what the AI knew at session start
        saveSessionContext(dbSession.id, {
          profile_snapshot: {
            display_name: '',   // profileSummary is a string; snapshot is best-effort
            experience_years: 0,
            primary_role: '',
            target_companies: [],
            strengths: [],
            weaknesses: [],
          },
          topic_mastery: promptCtxRef.current.topicMastery ?? null,
          memories_loaded: promptCtxRef.current.coachMemory?.length ?? 0,
          solutions_loaded: promptCtxRef.current.previousSolutions?.length ?? 0,
        }).catch(() => {})
      }
    } catch (err) {
      console.warn('[useInterview] Phase 2 init error (non-fatal):', err)
    } finally {
      setIsLoadingQuestion(false)
    }

    const systemPrompt = buildSystemPrompt(activeQuestion, 'present', 0, false, promptCtxRef.current)
    const kickoffMsg = makeMessage('user', 'I am ready to start the interview. Please present the problem.')
    setMessages([kickoffMsg])

    const assistantMsg = makeMessage('assistant', '')
    setMessages((prev) => [...prev, assistantMsg])

    try {
      let fullText = ''
      await streamChatCompletion(systemPrompt, [kickoffMsg], (chunk) => {
        fullText += chunk
        setMessages((prev) =>
          prev.map((m) =>
            m.id === assistantMsg.id ? { ...m, content: fullText } : m,
          ),
        )
      })
      setStageSync('clarify')
    } catch (err) {
      setMessages((prev) =>
        prev.map((m) =>
          m.id === assistantMsg.id
            ? { ...m, content: `Failed to start session: ${err instanceof Error ? err.message : 'Unknown error'}` }
            : m,
        ),
      )
    } finally {
      setIsThinking(false)
    }
  }, [question, slug])

  // Run test cases without submitting
  const runCode = useCallback(async (code: string) => {
    setIsRunningTests(true)
    setTestResults([])
    try {
      const results = await runTests(code, question.testCases, question.entryPoint)
      setTestResults(results)
    } catch (err) {
      console.error('Code runner error:', err)
    } finally {
      setIsRunningTests(false)
    }
  }, [question])

  // Submit code — run tests + ask AI to evaluate
  const submitCode = useCallback(
    async (code: string) => {
      setIsRunningTests(true)
      setStageSync('review')

      let results: TestResult[] = []
      try {
        results = await runTests(code, question.testCases, question.entryPoint)
        setTestResults(results)
      } finally {
        setIsRunningTests(false)
      }

      const passed = results.filter((r) => r.passed).length
      const total = results.length
      const testSummary = formatResultsForAI(results)

      const submissionText = `I've finished my solution. Here is my code:\n\n\`\`\`javascript\n${code}\n\`\`\`\n\n${testSummary}\n\n${passed === total ? 'All tests passed! Can you review my solution?' : `${passed}/${total} tests passed. Can you help me understand what I might be missing?`}`

      await sendMessage(submissionText)
    },
    [question, sendMessage],
  )

  // Request the next progressive hint
  const requestHint = useCallback(async () => {
    if (hintsGiven >= question.hints.length) {
      await sendMessage("I'm stuck and I've used all the hints. Can you explain the approach?")
      return
    }
    setHintsGiven((prev) => prev + 1)
    await sendMessage(`I'm stuck. Can I get hint ${hintsGiven + 1}?`)
  }, [hintsGiven, question.hints.length, sendMessage])

  // End session and get final feedback + persist to DB
  const endSession = useCallback(async () => {
    setStageSync('feedback')
    await sendMessage(
      'The interview session is now complete. Please give me your full structured feedback on my performance.',
    )

    // Phase 2: finalize DB attempt after feedback is delivered
    const attemptId = dbAttemptIdRef.current
    const sessionId = dbSessionIdRef.current

    // Grab last AI message — should contain both <feedback_json> and <memory_json>
    const lastAI = [...messages].reverse().find(m => m.role === 'assistant')

    if (attemptId) {
      const feedbackRaw = lastAI ? parseFeedbackJson(lastAI.content) : null
      const aiScore = feedbackRaw
        ? Math.round((feedbackRaw.correctness + feedbackRaw.efficiency + feedbackRaw.communication) / 3)
        : undefined

      finalizeAttempt(attemptId, {
        status: 'solved',
        hintsUsed: hintsGiven,
        askedClarifying,
        aiScore,
        aiFeedback: feedbackRaw ?? undefined,
        conversationLog: conversationLogRef.current as never,
      }).catch(err => console.warn('[useInterview] finalizeAttempt error:', err))
    }

    // Phase 5: parse and save AI memory notes
    if (sessionId && lastAI) {
      const memoryItems = parseMemoryJson(lastAI.content)
      if (memoryItems && memoryItems.length > 0) {
        upsertMemories(sessionId, memoryItems)
          .catch(err => console.warn('[useInterview] upsertMemories error:', err))
      }
    }

    if (sessionId) {
      dbEndSession(sessionId).catch(err => console.warn('[useInterview] endSession DB error:', err))
    }
  }, [sendMessage, messages, hintsGiven, askedClarifying])

  // ── Warm-up mode: free chat with AI before any problem ──────
  const startWarmup = useCallback(async () => {
    setStageSync('warmup')
    setMessages([])
    conversationLogRef.current = []
    setIsThinking(true)

    const profileSummary = await buildProfileSummary().catch(() => '')
    const warmupSystemPrompt = [
      'You are Bliff, a friendly AI technical interview coach.',
      'The candidate has just opened the interview room.',
      'This is the warm-up phase — have a casual, encouraging conversation.',
      'You can: greet them, ask how they are feeling, briefly review topics they want to focus on,',
      'give a quick pep-talk, or answer general algorithm questions.',
      'Do NOT present any coding problems yet — that happens when they click "Begin Interview".',
      profileSummary ? `\nCandidate profile:\n${profileSummary}` : '',
    ].filter(Boolean).join('\n')

    const greeting: Message = {
      id: crypto.randomUUID(),
      role: 'assistant',
      content: '',
      timestamp: Date.now(),
    }
    setMessages([greeting])

    // Use a single synthetic user message to trigger the greeting
    const initMsg: Message = {
      id: crypto.randomUUID(),
      role: 'user',
      content: 'Hi, I just opened the interview room.',
      timestamp: Date.now(),
    }

    try {
      let full = ''
      await streamChatCompletion(warmupSystemPrompt, [initMsg], (chunk: string) => {
        full += chunk
        setMessages([{ ...greeting, content: full }])
      })
      conversationLogRef.current = [
        { role: 'assistant', content: full, timestamp: new Date().toISOString() },
      ]
    } catch {
      setMessages([{
        ...greeting,
        content: `Hi! I'm Bliff, your interview coach. Ready when you are — click "Begin Interview" to start!`,
      }])
    } finally {
      setIsThinking(false)
    }
  }, [])

  // ── Transition warm-up → full interview session ──────────────
  const beginInterview = useCallback(async () => {
    setMessages([])
    conversationLogRef.current = []
    await startSession()
  }, [startSession])

  // Reset everything
  const resetSession = useCallback(() => {
    setStageSync('idle')
    setMessages([])
    setHintsGiven(0)
    setAskedClarifying(false)
    setTestResults([])
    setIsThinking(false)
    setQuestion(TWO_SUM)
    dbSessionIdRef.current = null
    dbAttemptIdRef.current = null
    promptCtxRef.current = {}
    conversationLogRef.current = []
  }, [])

  return {
    stage,
    question,
    messages,
    isThinking,
    hintsGiven,
    askedClarifying,
    testResults,
    isRunningTests,
    isLoadingQuestion,
    sendMessage,
    startWarmup,
    beginInterview,
    startSession,
    submitCode,
    runCode,
    requestHint,
    endSession,
    resetSession,
  }
}
