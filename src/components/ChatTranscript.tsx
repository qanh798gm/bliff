import { useEffect, useRef } from 'react'
import type { Message } from '../types'

// ============================================================
// ChatTranscript — scrollable conversation history
// ============================================================

interface ChatTranscriptProps {
  messages: Message[]
  isThinking: boolean
}

export function ChatTranscript({ messages, isThinking }: ChatTranscriptProps) {
  const bottomRef = useRef<HTMLDivElement>(null)

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  const visibleMessages = messages.filter((m) => m.role !== 'system')

  if (visibleMessages.length === 0 && !isThinking) {
    return (
      <div className="flex items-center justify-center h-full text-gray-500 text-sm">
        <p>Bliff is waiting to begin...</p>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-4 overflow-y-auto h-full px-1 py-2">
      {visibleMessages.map((msg) => (
        <MessageBubble key={msg.id} message={msg} />
      ))}

      {/* Thinking indicator */}
      {isThinking && (
        <div className="flex items-start gap-3">
          <Avatar role="assistant" />
          <div className="bg-gray-800 rounded-2xl rounded-tl-sm px-4 py-3">
            <ThinkingDots />
          </div>
        </div>
      )}

      <div ref={bottomRef} />
    </div>
  )
}

function MessageBubble({ message }: { message: Message }) {
  const isUser = message.role === 'user'

  return (
    <div className={`flex items-start gap-3 ${isUser ? 'flex-row-reverse' : ''}`}>
      <Avatar role={message.role} />
      <div
        className={`
          max-w-[75%] rounded-2xl px-4 py-3 text-sm leading-relaxed
          ${isUser
            ? 'bg-indigo-600 text-white rounded-tr-sm'
            : 'bg-gray-800 text-gray-100 rounded-tl-sm border border-gray-700'
          }
        `}
      >
        <FormattedContent content={message.content} />
      </div>
    </div>
  )
}

function Avatar({ role }: { role: Message['role'] }) {
  if (role === 'user') {
    return (
      <div className="flex-shrink-0 w-8 h-8 rounded-full bg-indigo-700 flex items-center justify-center text-white text-xs font-bold">
        U
      </div>
    )
  }
  return (
    <div className="flex-shrink-0 w-8 h-8 rounded-full bg-gradient-to-br from-violet-600 to-indigo-700 flex items-center justify-center text-white text-xs font-bold">
      B
    </div>
  )
}

// Simple markdown-like renderer for code blocks and inline code
function FormattedContent({ content }: { content: string }) {
  if (!content) return null

  // Split by code blocks ```...```
  const parts = content.split(/(```[\s\S]*?```)/g)

  return (
    <>
      {parts.map((part, i) => {
        if (part.startsWith('```')) {
          const lines = part.slice(3, -3).split('\n')
          const lang = lines[0]?.trim() ?? ''
          const code = lines.slice(lang ? 1 : 0).join('\n').trim()
          return (
            <pre
              key={i}
              className="mt-2 mb-2 bg-gray-950 rounded-lg p-3 overflow-x-auto text-xs font-mono text-green-300 border border-gray-700"
            >
              <code>{code}</code>
            </pre>
          )
        }

        // Process inline code and line breaks
        return (
          <span key={i}>
            {part.split(/(`[^`]+`)/g).map((segment, j) => {
              if (segment.startsWith('`') && segment.endsWith('`')) {
                return (
                  <code
                    key={j}
                    className="bg-gray-900 text-orange-300 rounded px-1 py-0.5 text-xs font-mono"
                  >
                    {segment.slice(1, -1)}
                  </code>
                )
              }
              return segment.split('\n').map((line, k) => (
                <span key={k}>
                  {line}
                  {k < segment.split('\n').length - 1 && <br />}
                </span>
              ))
            })}
          </span>
        )
      })}
    </>
  )
}

function ThinkingDots() {
  return (
    <div className="flex gap-1 items-center h-5">
      {[0, 1, 2].map((i) => (
        <div
          key={i}
          className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce"
          style={{ animationDelay: `${i * 0.15}s` }}
        />
      ))}
    </div>
  )
}
