import { useState, useRef, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { streamChatCompletion, chatCompletion } from '../services/llm'
import { GroqSttRecorder } from '../services/groqStt'
import type { Message } from '../types'

// ============================================================
// LLM API Test Page
// Developer tool: health-check the LLM proxy endpoint
// ============================================================

type TestStatus = 'idle' | 'running' | 'ok' | 'error'

interface TestResult {
  label: string
  status: TestStatus
  latencyMs?: number
  response?: string
  error?: string
}

const SYSTEM_PROMPT =
  'You are a helpful assistant. Keep replies brief (1-2 sentences).'

const TEST_CASES: Array<{ label: string; prompt: string }> = [
  { label: 'Ping (non-streaming)', prompt: 'Reply with exactly: PONG' },
  { label: 'Streaming', prompt: 'Count from 1 to 5, one number per line.' },
]

function StatusDot({ status }: { status: TestStatus }) {
  const map: Record<TestStatus, string> = {
    idle: 'bg-gray-600',
    running: 'bg-yellow-400 animate-pulse',
    ok: 'bg-green-400',
    error: 'bg-red-400',
  }
  return <span className={`inline-block w-2 h-2 rounded-full ${map[status]}`} />
}

export function LlmTestPage() {
  const navigate = useNavigate()
  const [results, setResults] = useState<TestResult[]>(
    TEST_CASES.map((t) => ({ label: t.label, status: 'idle' })),
  )
  const [customPrompt, setCustomPrompt] = useState('Tell me a very short joke.')
  const [customResult, setCustomResult] = useState<string>('')
  const [customStatus, setCustomStatus] = useState<TestStatus>('idle')
  const [customLatency, setCustomLatency] = useState<number | undefined>()
  const streamBuf = useRef('')

  function setResult(idx: number, patch: Partial<TestResult>) {
    setResults((prev) => prev.map((r, i) => (i === idx ? { ...r, ...patch } : r)))
  }

  async function runAll() {
    // Reset
    setResults(TEST_CASES.map((t) => ({ label: t.label, status: 'running' })))

    // Non-streaming
    const t0 = Date.now()
    try {
      const msg: Message = { id: '1', role: 'user', content: TEST_CASES[0].prompt, timestamp: Date.now() }
      const resp = await chatCompletion(SYSTEM_PROMPT, [msg])
      setResult(0, { status: 'ok', latencyMs: Date.now() - t0, response: resp })
    } catch (e) {
      setResult(0, { status: 'error', latencyMs: Date.now() - t0, error: String(e) })
    }

    // Streaming
    const t1 = Date.now()
    try {
      let buf = ''
      const msg: Message = { id: '2', role: 'user', content: TEST_CASES[1].prompt, timestamp: Date.now() }
      setResult(1, { status: 'running', response: '' })
      await streamChatCompletion(SYSTEM_PROMPT, [msg], (chunk) => {
        buf += chunk
        setResult(1, { status: 'running', response: buf })
      })
      setResult(1, { status: 'ok', latencyMs: Date.now() - t1, response: buf })
    } catch (e) {
      setResult(1, { status: 'error', latencyMs: Date.now() - t1, error: String(e) })
    }
  }

  async function runCustom() {
    if (!customPrompt.trim()) return
    setCustomStatus('running')
    setCustomResult('')
    setCustomLatency(undefined)
    streamBuf.current = ''
    const t0 = Date.now()
    try {
      const msg: Message = { id: 'c', role: 'user', content: customPrompt, timestamp: Date.now() }
      await streamChatCompletion(SYSTEM_PROMPT, [msg], (chunk) => {
        streamBuf.current += chunk
        setCustomResult(streamBuf.current)
      })
      setCustomStatus('ok')
      setCustomLatency(Date.now() - t0)
    } catch (e) {
      setCustomStatus('error')
      setCustomResult(String(e))
      setCustomLatency(Date.now() - t0)
    }
  }

  const allOk = results.every((r) => r.status === 'ok')
  const anyError = results.some((r) => r.status === 'error')

  return (
    <div className="min-h-screen bg-gray-950 text-white">
      {/* Nav */}
      <nav className="border-b border-gray-800 px-6 py-3 flex items-center gap-4">
        <button
          onClick={() => navigate('/dashboard')}
          className="text-gray-400 hover:text-white text-sm transition-colors"
        >
          ← Dashboard
        </button>
        <h1 className="text-lg font-semibold">LLM API Test</h1>
        <span className="text-gray-600 text-xs ml-auto">
          {import.meta.env.VITE_LLM_BASE_URL ?? 'https://api.openai.com/v1'} ·{' '}
          {import.meta.env.VITE_LLM_MODEL ?? 'gpt-4o'}
        </span>
      </nav>

      <div className="max-w-2xl mx-auto px-6 py-10 space-y-8">
        {/* Status summary */}
        <div
          className={`rounded-xl border px-5 py-4 flex items-center gap-3 ${
            allOk
              ? 'border-green-700 bg-green-950/40'
              : anyError
              ? 'border-red-700 bg-red-950/40'
              : 'border-gray-700 bg-gray-900/40'
          }`}
        >
          <span className="text-2xl">
            {allOk ? '✅' : anyError ? '❌' : '⚙️'}
          </span>
          <div>
            <p className="font-medium text-sm">
              {allOk
                ? 'All tests passed — LLM endpoint is healthy'
                : anyError
                ? 'One or more tests failed'
                : 'Run the tests below to verify your LLM connection'}
            </p>
            <p className="text-gray-500 text-xs mt-0.5">
              API key and endpoint are read from VITE_LLM_* env vars
            </p>
          </div>
          <button
            onClick={() => void runAll()}
            className="ml-auto px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-medium rounded-lg transition-colors"
          >
            Run Tests
          </button>
        </div>

        {/* Automated tests */}
        <section className="space-y-3">
          <h2 className="text-sm font-semibold text-gray-400 uppercase tracking-wider">
            Automated Tests
          </h2>
          {results.map((r) => (
            <div
              key={r.label}
              className="bg-gray-900 border border-gray-800 rounded-xl px-5 py-4 space-y-2"
            >
              <div className="flex items-center gap-2">
                <StatusDot status={r.status} />
                <span className="font-medium text-sm">{r.label}</span>
                {r.latencyMs !== undefined && (
                  <span className="ml-auto text-xs text-gray-500 tabular-nums">
                    {r.latencyMs} ms
                  </span>
                )}
              </div>
              {r.response && (
                <pre className="text-xs text-gray-300 bg-gray-950 rounded-lg p-3 whitespace-pre-wrap font-mono overflow-auto max-h-32">
                  {r.response}
                </pre>
              )}
              {r.error && (
                <p className="text-xs text-red-400 font-mono">{r.error}</p>
              )}
            </div>
          ))}
        </section>

        {/* Custom prompt sandbox */}
        <section className="space-y-3">
          <h2 className="text-sm font-semibold text-gray-400 uppercase tracking-wider">
            Custom Prompt (streaming)
          </h2>
          <div className="bg-gray-900 border border-gray-800 rounded-xl px-5 py-4 space-y-3">
            <textarea
              value={customPrompt}
              onChange={(e) => setCustomPrompt(e.target.value)}
              rows={3}
              className="w-full bg-gray-950 border border-gray-700 rounded-lg px-3 py-2 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-indigo-500 resize-none font-mono"
              placeholder="Enter a prompt…"
            />
            <div className="flex items-center gap-3">
              <button
                onClick={() => void runCustom()}
                disabled={customStatus === 'running' || !customPrompt.trim()}
                className="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white text-sm font-medium rounded-lg transition-colors"
              >
                {customStatus === 'running' ? 'Streaming…' : 'Send'}
              </button>
              <div className="flex items-center gap-2">
                <StatusDot status={customStatus} />
                {customLatency !== undefined && (
                  <span className="text-xs text-gray-500 tabular-nums">{customLatency} ms</span>
                )}
              </div>
            </div>
            {customResult && (
              <pre className="text-xs text-gray-300 bg-gray-950 rounded-lg p-3 whitespace-pre-wrap font-mono overflow-auto max-h-48">
                {customResult}
              </pre>
            )}
          </div>
        </section>

        {/* ── Voice Test section ── */}
        <VoiceTestSection />

        {/* Env var reference */}
        <section className="space-y-2">
          <h2 className="text-sm font-semibold text-gray-400 uppercase tracking-wider">
            Environment Variables
          </h2>
          <div className="bg-gray-900 border border-gray-800 rounded-xl px-5 py-4 text-xs font-mono space-y-1.5">
            {[
              ['VITE_LLM_BASE_URL', import.meta.env.VITE_LLM_BASE_URL],
              ['VITE_LLM_MODEL', import.meta.env.VITE_LLM_MODEL],
              ['VITE_LLM_API_KEY', import.meta.env.VITE_LLM_API_KEY ? '••••••••' : '(not set)'],
              ['VITE_SUPABASE_URL', import.meta.env.VITE_SUPABASE_URL],
              ['VITE_STT_PROVIDER', import.meta.env.VITE_STT_PROVIDER ?? 'webspeech (default)'],
              ['VITE_GROQ_API_KEY', import.meta.env.VITE_GROQ_API_KEY ? '••••••••' : '(not set)'],
            ].map(([key, val]) => (
              <div key={key} className="flex gap-3">
                <span className="text-indigo-400 w-48 shrink-0">{key}</span>
                <span className={val ? 'text-gray-300' : 'text-red-400'}>{val ?? '(not set)'}</span>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  )
}

// ── Voice Test Section ───────────────────────────────────────

type VoiceTestStatus = 'idle' | 'recording' | 'processing' | 'done' | 'error'

function VoiceTestSection() {
  const [status, setStatus] = useState<VoiceTestStatus>('idle')
  const [transcript, setTranscript] = useState('')
  const [error, setError] = useState('')
  const [latencyMs, setLatencyMs] = useState<number | undefined>()
  const recorderRef = useRef<GroqSttRecorder | null>(null)

  const provider = (import.meta.env.VITE_STT_PROVIDER ?? 'webspeech') as string
  const groqKey = import.meta.env.VITE_GROQ_API_KEY as string | undefined
  const isGroq = provider === 'groq' && !!groqKey

  const startRecording = useCallback(async () => {
    setStatus('recording')
    setTranscript('')
    setError('')
    setLatencyMs(undefined)

    if (isGroq) {
      try {
        recorderRef.current = new GroqSttRecorder(groqKey!, 'en-US')
        await recorderRef.current.startRecording()
      } catch (e) {
        setStatus('error')
        setError(String(e))
      }
    } else {
      // Web Speech API quick test — use unknown cast to avoid re-declaring the full interfaces
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const win = window as any
      const SpeechRecognitionImpl = win.SpeechRecognition ?? win.webkitSpeechRecognition
      if (!SpeechRecognitionImpl) {
        setStatus('error')
        setError('SpeechRecognition not supported in this browser')
        return
      }
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const rec: any = new SpeechRecognitionImpl()
      rec.lang = 'en-US'
      rec.interimResults = false
      rec.maxAlternatives = 1
      const t0 = Date.now()
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      rec.onresult = (e: any) => {
        const text = e.results[0][0].transcript as string
        setTranscript(text)
        setLatencyMs(Date.now() - t0)
        setStatus('done')
      }
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      rec.onerror = (e: any) => {
        setStatus('error')
        setError(`SpeechRecognition error: ${String(e.error)}`)
      }
      rec.onend = () => {
        if (status === 'recording') setStatus('idle')
      }
      rec.start()
    }
  }, [isGroq, groqKey, status])

  const stopRecording = useCallback(async () => {
    if (!isGroq || !recorderRef.current) return
    setStatus('processing')
    const t0 = Date.now()
    try {
      const result = await recorderRef.current.stopAndTranscribe()
      setTranscript(result.text)
      setLatencyMs(Date.now() - t0)
      setStatus('done')
    } catch (e) {
      setStatus('error')
      setError(String(e))
    }
  }, [isGroq])

  const statusColors: Record<VoiceTestStatus, string> = {
    idle: 'border-gray-700 bg-gray-900',
    recording: 'border-red-700 bg-red-950/30',
    processing: 'border-yellow-700 bg-yellow-950/30',
    done: 'border-green-700 bg-green-950/30',
    error: 'border-red-700 bg-red-950/40',
  }

  const statusLabel: Record<VoiceTestStatus, string> = {
    idle: 'Ready',
    recording: '🔴 Recording…',
    processing: '⏳ Transcribing…',
    done: '✅ Done',
    error: '❌ Error',
  }

  return (
    <section className="space-y-3">
      <h2 className="text-sm font-semibold text-gray-400 uppercase tracking-wider">
        Voice Test (STT)
      </h2>
      <div className={`border rounded-xl px-5 py-4 space-y-4 transition-colors ${statusColors[status]}`}>
        {/* Provider info */}
        <div className="flex items-center gap-3 text-xs">
          <span className="text-gray-500">Provider:</span>
          <span className={`font-semibold ${isGroq ? 'text-green-400' : 'text-yellow-400'}`}>
            {isGroq ? '🚀 Groq Whisper (whisper-large-v3-turbo)' : '🌐 Web Speech API (browser built-in)'}
          </span>
        </div>

        {!isGroq && provider === 'groq' && (
          <p className="text-xs text-red-400">
            ⚠️ VITE_STT_PROVIDER=groq but VITE_GROQ_API_KEY is missing — falling back to Web Speech API
          </p>
        )}

        {/* Controls */}
        <div className="flex items-center gap-3">
          {status !== 'recording' ? (
            <button
              onClick={() => void startRecording()}
              disabled={status === 'processing'}
              className="flex items-center gap-2 px-4 py-2 bg-red-600 hover:bg-red-500 disabled:opacity-40 text-white text-sm font-medium rounded-lg transition-colors"
            >
              🎙 {status === 'processing' ? 'Transcribing…' : 'Start Recording'}
            </button>
          ) : (
            isGroq ? (
              <button
                onClick={() => void stopRecording()}
                className="flex items-center gap-2 px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white text-sm font-medium rounded-lg transition-colors"
              >
                ⏹ Stop & Transcribe
              </button>
            ) : (
              <span className="text-sm text-red-400 animate-pulse">🔴 Listening… (speak now)</span>
            )
          )}

          <span className="text-xs text-gray-500">{statusLabel[status]}</span>
          {latencyMs !== undefined && (
            <span className="text-xs text-gray-500 tabular-nums ml-auto">{latencyMs} ms</span>
          )}
        </div>

        {/* Instructions */}
        {status === 'idle' && (
          <p className="text-xs text-gray-600">
            {isGroq
              ? 'Click Start → speak → click Stop & Transcribe. The audio will be sent to Groq Whisper.'
              : 'Click Start → speak. The browser will transcribe locally using Web Speech API.'}
          </p>
        )}

        {/* Transcript */}
        {transcript && (
          <div>
            <p className="text-xs text-gray-500 mb-1">Transcript:</p>
            <pre className="text-sm text-gray-100 bg-gray-950 rounded-lg p-3 whitespace-pre-wrap font-mono">
              {transcript}
            </pre>
          </div>
        )}

        {/* Error */}
        {error && (
          <p className="text-xs text-red-400 font-mono">{error}</p>
        )}
      </div>
    </section>
  )
}
