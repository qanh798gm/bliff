import { useState, useCallback, useRef } from 'react'
import type { Message, InterviewStage, Question, TestResult } from '../types'
import { streamChatCompletion } from '../services/llm'
import { buildSystemPrompt } from '../lib/promptBuilder'
import { runTests, formatResultsForAI } from '../services/codeRunner'
import { TWO_SUM } from '../data/questions'

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
  sendMessage: (text: string) => Promise<void>
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

export function useInterview(): UseInterviewReturn {
  const [stage, setStage] = useState<InterviewStage>('idle')
  const [messages, setMessages] = useState<Message[]>([])
  const [isThinking, setIsThinking] = useState(false)
  const [hintsGiven, setHintsGiven] = useState(0)
  const [askedClarifying, setAskedClarifying] = useState(false)
  const [testResults, setTestResults] = useState<TestResult[]>([])
  const [isRunningTests, setIsRunningTests] = useState(false)

  // Phase 1: single hardcoded question
  const question = TWO_SUM

  // Track stage in a ref so callbacks always see latest value
  const stageRef = useRef<InterviewStage>('idle')
  const setStageSync = (s: InterviewStage) => {
    stageRef.current = s
    setStage(s)
  }

  const appendMessage = useCallback((msg: Message) => {
    setMessages((prev) => [...prev, msg])
  }, [])

  const getSystemPrompt = useCallback(
    (currentStage: InterviewStage) =>
      buildSystemPrompt(question, currentStage, hintsGiven, askedClarifying),
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

      // Build current conversation for API
      const currentMessages = [...messages, userMsg]
      const systemPrompt = getSystemPrompt(stageRef.current)

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

  // Start a new interview session
  const startSession = useCallback(async () => {
    setStageSync('present')
    setHintsGiven(0)
    setAskedClarifying(false)
    setTestResults([])
    setMessages([])
    setIsThinking(true)

    const systemPrompt = buildSystemPrompt(question, 'present', 0, false)
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
  }, [question])

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

  // End session and get final feedback
  const endSession = useCallback(async () => {
    setStageSync('feedback')
    await sendMessage(
      'The interview session is now complete. Please give me your full structured feedback on my performance.',
    )
  }, [sendMessage])

  // Reset everything
  const resetSession = useCallback(() => {
    setStageSync('idle')
    setMessages([])
    setHintsGiven(0)
    setAskedClarifying(false)
    setTestResults([])
    setIsThinking(false)
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
    sendMessage,
    startSession,
    submitCode,
    runCode,
    requestHint,
    endSession,
    resetSession,
  }
}
