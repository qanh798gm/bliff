import { useState, useCallback, useRef, useEffect } from 'react'
import type { Message, MentorRecommendation } from '../types'
import { streamChatCompletion } from '../services/llm'
import { buildMentorSystemPrompt, parseMentorRecommendations, type MentorContext } from '../lib/promptBuilder'
import { buildProfileSummary, loadTopicStats } from '../services/profileService'
import { loadSessionMemory, expireOldSummaries } from '../services/memoryService'

// ============================================================
// useMentorChat — Dashboard mentor chat
// Phase 5: AI strategic advisor with full long-term memory.
//
// Short-term: messages[] lives in React state only.
// Long-term:  reads user_memory + user_topic_stats from Supabase.
// ============================================================

interface UseMentorChatReturn {
  messages: Message[]
  recommendations: MentorRecommendation[]
  isThinking: boolean
  isInitializing: boolean
  lastAiText: string           // latest AI response text — for TTS in component
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

function stripRecommendations(text: string): string {
  return text.replace(/<recommendations>[\s\S]*?<\/recommendations>/g, '').trim()
}

export function useMentorChat(userId: string | undefined): UseMentorChatReturn {
  const [messages, setMessages] = useState<Message[]>([])
  const [recommendations, setRecommendations] = useState<MentorRecommendation[]>([])
  const [isThinking, setIsThinking] = useState(false)
  const [isInitializing, setIsInitializing] = useState(true)
  const [lastAiText, setLastAiText] = useState('')

  const systemPromptRef = useRef<string>('')
  const greetedRef = useRef(false)

  // ── Build mentor context — all calls are individually try/catched ──
  async function buildMentorContext(): Promise<MentorContext> {
    // Each data source degrades gracefully — nothing blocks the greeting
    const profileSummary = await buildProfileSummary().catch(() => '')

    const topicStatRows = userId
      ? await loadTopicStats(userId).catch(() => [])
      : []

    // user_memory table may not exist yet if migrations haven't been applied
    const memories = await loadSessionMemory(null).catch(() => [])

    // Expire stale summaries — non-fatal
    expireOldSummaries().catch(() => {})

    const topicStats = topicStatRows.map((row) => ({
      topicName: row.topic_name,
      masteryScore: row.mastery_score,
      attemptsCount: row.attempts_count,
      solvedCount: row.solved_count,
      lastAttemptedAt: row.last_attempted_at,
    }))

    // Extract display name from profile summary (best-effort)
    const nameMatch = profileSummary.match(/Name:\s*([^\n]+)/)
    const displayName = nameMatch ? nameMatch[1].trim() : 'there'

    console.debug('[mentor] context built, displayName=', displayName)
    return { displayName, profileSummary, topicStats, memories }
  }

  // ── Fire auto-greeting on mount ───────────────────────────
  useEffect(() => {
    if (!userId || greetedRef.current) return
    greetedRef.current = true

    let cancelled = false

    async function initAndGreet() {
      setIsInitializing(true)

      let ctx: MentorContext
      try {
        ctx = await buildMentorContext()
      } catch {
        ctx = { displayName: 'there', profileSummary: '', topicStats: [], memories: [] }
      }

      if (cancelled) return

      systemPromptRef.current = buildMentorSystemPrompt(ctx)
      setIsInitializing(false)
      setIsThinking(true)

      const assistantMsg = makeMessage('assistant', '')
      setMessages([assistantMsg])

      try {
        let fullResponse = ''
        const greetMsg: Message = makeMessage(
          'user',
          'Hello! Give me a brief personalized assessment of where I stand and suggest what I should focus on today.',
        )

        await streamChatCompletion(
          systemPromptRef.current,
          [greetMsg],
          (chunk) => {
            if (cancelled) return
            fullResponse += chunk
            setMessages([{ ...assistantMsg, content: fullResponse }])
          },
        )

        if (!cancelled) {
          const recs = parseMentorRecommendations(fullResponse)
          if (recs.length > 0) setRecommendations(recs)
          const clean = stripRecommendations(fullResponse)
          setMessages([{ ...assistantMsg, content: clean }])
          setLastAiText(clean)
        }
      } catch (err) {
        if (!cancelled) {
          console.error('[useMentorChat] greeting error:', err)
          const fallback = "Hey! I'm Bliff. I'm having trouble connecting right now — but I'm here to help. What would you like to work on?"
          setMessages([{ ...assistantMsg, content: fallback }])
          setLastAiText(fallback)
        }
      } finally {
        if (!cancelled) setIsThinking(false)
      }
    }

    void initAndGreet()
    return () => {
      cancelled = true
      // Reset so React Strict Mode double-invoke (dev) doesn't block the real run
      greetedRef.current = false
    }
  }, [userId]) // eslint-disable-line react-hooks/exhaustive-deps

  // ── Free chat ─────────────────────────────────────────────
  const sendMessage = useCallback(async (text: string) => {
    if (!text.trim() || isThinking) return

    const userMsg = makeMessage('user', text)
    setMessages((prev) => [...prev, userMsg])
    setIsThinking(true)

    const assistantMsg = makeMessage('assistant', '')
    setMessages((prev) => [...prev, assistantMsg])

    try {
      // Build Message[] for API — strip recommendation blocks from assistant turns
      const historyForApi: Message[] = [...messages, userMsg].map((m) =>
        m.role === 'assistant'
          ? { ...m, content: stripRecommendations(m.content) }
          : m,
      )

      let fullResponse = ''

      await streamChatCompletion(
        systemPromptRef.current,
        historyForApi,
        (chunk) => {
          fullResponse += chunk
          setMessages((prev) =>
            prev.map((m) => (m.id === assistantMsg.id ? { ...m, content: fullResponse } : m)),
          )
        },
      )

      const recs = parseMentorRecommendations(fullResponse)
      if (recs.length > 0) setRecommendations(recs)

      const clean = stripRecommendations(fullResponse)
      setMessages((prev) =>
        prev.map((m) => (m.id === assistantMsg.id ? { ...m, content: clean } : m)),
      )
      setLastAiText(clean)
    } catch (err) {
      console.error('[useMentorChat] sendMessage error:', err)
      const errMsg = 'Sorry, I had trouble connecting. Please try again.'
      setMessages((prev) =>
        prev.map((m) => (m.id === assistantMsg.id ? { ...m, content: errMsg } : m)),
      )
      setLastAiText(errMsg)
    } finally {
      setIsThinking(false)
    }
  }, [messages, isThinking])

  const clearChat = useCallback(() => {
    setMessages([])
    setRecommendations([])
    setLastAiText('')
    greetedRef.current = false
  }, [])

  return { messages, recommendations, isThinking, isInitializing, lastAiText, sendMessage, clearChat }
}
