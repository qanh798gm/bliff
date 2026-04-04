import { useState, useRef, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import type { MentorRecommendation } from '../types'
import { WARMUP_HANDOFF_KEY } from '../types'
import { useMentorChat } from '../hooks/useMentorChat'
import { useVoice } from '../hooks/useVoice'
import type { Message } from '../types'

// ============================================================
// MentorChatPanel — Dashboard AI mentor chat + voice
// Phase 5: Voice-first chat with Bliff mentor.
// Primary input: microphone (STT). AI speaks back (TTS).
// Fallback: keyboard input.
// Short-term memory only — cleared every new dashboard visit.
// ============================================================

interface Props {
  userId: string | undefined
}

function buildHandoffSummary(messages: Message[]): string {
  // Take last 2 AI messages — compressed into a summary sentence
  const aiMessages = messages
    .filter((m) => m.role === 'assistant' && m.content.trim())
    .slice(-2)
  if (aiMessages.length === 0) return ''
  return aiMessages
    .map((m) => m.content.slice(0, 200).replace(/\n+/g, ' ').trim())
    .join(' … ')
}

function RecommendationCard({
  rec,
  messages,
}: {
  rec: MentorRecommendation
  messages: Message[]
}) {
  const navigate = useNavigate()
  const icon = rec.type === 'interview' ? '🎙' : '▶'
  const label = rec.type === 'interview' ? 'Interview' : 'Practice'
  const path = rec.type === 'interview' ? `/interview/${rec.slug}` : `/practice/${rec.slug}`
  const colorClass = rec.type === 'interview'
    ? 'border-indigo-800/60 hover:border-indigo-600 bg-indigo-950/30'
    : 'border-emerald-800/60 hover:border-emerald-600 bg-emerald-950/30'

  function handleClick() {
    // Save warmup handoff to sessionStorage before navigating
    const summary = buildHandoffSummary(messages)
    if (summary) {
      sessionStorage.setItem(
        WARMUP_HANDOFF_KEY,
        JSON.stringify({
          summary,
          recommendedSlug: rec.slug,
          recommendedType: rec.type,
          timestamp: Date.now(),
        }),
      )
    }
    navigate(path)
  }

  return (
    <button
      onClick={handleClick}
      className={`w-full text-left rounded-lg border p-3 transition-colors ${colorClass} group`}
    >
      <div className="flex items-start justify-between gap-2">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-1.5 mb-0.5">
            <span className="text-xs font-medium text-gray-400">{icon} {label}</span>
          </div>
          <div className="text-sm font-medium text-white truncate">{rec.title}</div>
          <div className="text-xs text-gray-400 mt-0.5 line-clamp-2">{rec.reason}</div>
        </div>
        <span className="text-gray-600 group-hover:text-gray-400 transition-colors text-sm mt-0.5 shrink-0">→</span>
      </div>
    </button>
  )
}

function TypingDots() {
  return (
    <span className="inline-flex items-center gap-1 px-1">
      <span className="w-1.5 h-1.5 rounded-full bg-indigo-400 animate-bounce [animation-delay:-0.3s]" />
      <span className="w-1.5 h-1.5 rounded-full bg-indigo-400 animate-bounce [animation-delay:-0.15s]" />
      <span className="w-1.5 h-1.5 rounded-full bg-indigo-400 animate-bounce" />
    </span>
  )
}

export function MentorChatPanel({ userId }: Props) {
  const {
    messages,
    recommendations,
    isThinking,
    isInitializing,
    lastAiText,
    sendMessage,
  } = useMentorChat(userId)

  const [textInput, setTextInput] = useState('')
  const [showTextInput, setShowTextInput] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)

  // Track whether last user input came from mic (user gesture) — safe to auto-speak
  const speakAfterMicRef = useRef(false)

  // Voice — STT + TTS
  const voice = useVoice({
    onTranscript: (text, isFinal) => {
      if (isFinal && text.trim()) {
        speakAfterMicRef.current = true   // mic input → safe to auto-speak response
        void sendMessage(text.trim())
      }
    },
  })

  // Auto-speak AI response ONLY when the prior input was via mic (has user gesture)
  // For the greeting and keyboard inputs, user can click 🔊 on the message bubble
  useEffect(() => {
    if (lastAiText && speakAfterMicRef.current) {
      speakAfterMicRef.current = false
      voice.speak(lastAiText)
    }
  }, [lastAiText]) // eslint-disable-line react-hooks/exhaustive-deps

  // Auto-scroll
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, isThinking])

  async function handleTextSend() {
    const text = textInput.trim()
    if (!text) return
    setTextInput('')
    await sendMessage(text)
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLTextAreaElement>) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      void handleTextSend()
    }
  }

  const busy = isInitializing || isThinking
  const micActive = voice.isListening

  return (
    <div className="flex flex-col h-full bg-gray-900 border border-gray-800 rounded-xl overflow-hidden">

      {/* Header */}
      <div className="flex items-center gap-2.5 px-4 py-3 border-b border-gray-800 shrink-0">
        <div className="w-7 h-7 rounded-full bg-indigo-600 flex items-center justify-center text-sm">🧠</div>
        <div>
          <div className="text-sm font-semibold text-white">Bliff Mentor</div>
          <div className="text-xs text-gray-500">
            {isInitializing ? 'Loading your history…' : voice.isSpeaking ? 'Speaking…' : micActive ? 'Listening…' : 'Your personal coach'}
          </div>
        </div>
        {/* Text toggle */}
        <button
          onClick={() => setShowTextInput((v) => !v)}
          className="ml-auto text-xs text-gray-600 hover:text-gray-400 transition-colors"
          title="Toggle text input"
        >
          ⌨️
        </button>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-3 space-y-3 min-h-0">
        {isInitializing && messages.length === 0 && (
          <div className="flex justify-start">
            <div className="bg-gray-800 rounded-2xl rounded-tl-sm px-3 py-2">
              <TypingDots />
            </div>
          </div>
        )}

        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div className={`max-w-[85%] flex flex-col gap-1 ${msg.role === 'user' ? 'items-end' : 'items-start'}`}>
              <div
                className={`rounded-2xl px-3 py-2 text-sm whitespace-pre-wrap ${
                  msg.role === 'user'
                    ? 'bg-indigo-600 text-white rounded-tr-sm'
                    : 'bg-gray-800 text-gray-100 rounded-tl-sm'
                }`}
              >
                {msg.content || (isThinking && msg.role === 'assistant' ? <TypingDots /> : null)}
              </div>
              {/* 🔊 play button on completed AI messages */}
              {msg.role === 'assistant' && msg.content && !isThinking && (
                <button
                  onClick={() => voice.speak(msg.content)}
                  className="text-gray-600 hover:text-gray-400 transition-colors px-1"
                  title="Read aloud"
                >
                  <svg className="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z"/>
                  </svg>
                </button>
              )}
            </div>
          </div>
        ))}

        {/* Interim transcript while mic is active */}
        {voice.interimTranscript && (
          <div className="flex justify-end">
            <div className="max-w-[85%] rounded-2xl px-3 py-2 text-sm bg-indigo-900/50 text-indigo-300 italic rounded-tr-sm">
              {voice.interimTranscript}
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Recommendation cards */}
      {recommendations.length > 0 && (
        <div className="px-4 py-2 border-t border-gray-800 space-y-1.5 shrink-0">
          <div className="text-xs text-gray-500 font-medium mb-1">Suggested for you</div>
          {recommendations.slice(0, 3).map((rec) => (
            <RecommendationCard key={`${rec.type}-${rec.slug}`} rec={rec} messages={messages} />
          ))}
        </div>
      )}

      {/* Voice + text controls */}
      <div className="px-4 pb-4 pt-3 border-t border-gray-800 shrink-0">

        {/* Primary: mic button */}
        <div className="flex items-center justify-center gap-3">
          {/* Stop speaking button (visible while AI talks) */}
          {voice.isSpeaking && (
            <button
              onClick={() => voice.stopSpeaking()}
              className="w-9 h-9 rounded-full bg-gray-700 hover:bg-gray-600 flex items-center justify-center transition-colors"
              title="Stop speaking"
            >
              <svg className="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 24 24">
                <rect x="6" y="6" width="12" height="12" rx="1" />
              </svg>
            </button>
          )}

          {/* Mic button */}
          <button
            onClick={() => {
              if (micActive) {
                voice.stopListening()
              } else {
                voice.startListening()
              }
            }}
            disabled={busy || voice.isSpeaking}
            className={`w-14 h-14 rounded-full flex items-center justify-center transition-all shadow-lg ${
              micActive
                ? 'bg-red-600 hover:bg-red-500 scale-110 shadow-red-900/50'
                : 'bg-indigo-600 hover:bg-indigo-500 disabled:opacity-40 disabled:cursor-not-allowed'
            }`}
            title={micActive ? 'Stop listening' : 'Speak to Bliff'}
          >
            {micActive ? (
              // Animated mic icon when listening
              <span className="relative flex items-center justify-center">
                <span className="absolute w-10 h-10 rounded-full bg-red-500/30 animate-ping" />
                <svg className="w-6 h-6 text-white relative" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z" />
                  <path strokeLinecap="round" strokeLinejoin="round" d="M19 10v2a7 7 0 0 1-14 0v-2M12 19v4M8 23h8" />
                </svg>
              </span>
            ) : (
              <svg className="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z" />
                <path strokeLinecap="round" strokeLinejoin="round" d="M19 10v2a7 7 0 0 1-14 0v-2M12 19v4M8 23h8" />
              </svg>
            )}
          </button>
        </div>

        <p className="text-center text-xs text-gray-600 mt-2">
          {micActive ? 'Listening — tap to stop' : busy ? 'Thinking…' : 'Tap mic to speak'}
        </p>

        {/* Optional text input (toggled by ⌨️ button) */}
        {showTextInput && (
          <div className="flex items-end gap-2 mt-3">
            <textarea
              value={textInput}
              onChange={(e) => setTextInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Type a message…"
              disabled={busy}
              rows={1}
              className="flex-1 bg-gray-800 border border-gray-700 rounded-xl px-3 py-2 text-sm text-white placeholder-gray-500 resize-none focus:outline-none focus:border-indigo-600 disabled:opacity-50 transition-colors"
              style={{ maxHeight: '80px', overflowY: 'auto' }}
            />
            <button
              onClick={() => void handleTextSend()}
              disabled={!textInput.trim() || busy}
              className="w-8 h-8 rounded-xl bg-indigo-600 hover:bg-indigo-500 disabled:opacity-40 flex items-center justify-center transition-colors shrink-0"
            >
              <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
              </svg>
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
