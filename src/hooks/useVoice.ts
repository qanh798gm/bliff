import { useState, useRef, useCallback, useEffect } from 'react'
import type { VoiceStatus, VoiceLanguage } from '../types'
import { GroqSttRecorder } from '../services/groqStt'

// ============================================================
// useVoice — unified voice hook
//
// STT provider is selected by VITE_STT_PROVIDER env var:
//   "webspeech" (default) — browser Web Speech API (free, lower quality)
//   "groq"                — Groq Whisper API (push-to-talk, high quality)
//
// TTS always uses browser SpeechSynthesis (free, good enough for now).
// ============================================================

// ── Web Speech API types (not fully typed in lib.dom.d.ts) ──

interface ISpeechRecognitionResult {
  readonly isFinal: boolean
  readonly length: number
  item(index: number): ISpeechRecognitionAlternative
  [index: number]: ISpeechRecognitionAlternative
}

interface ISpeechRecognitionAlternative {
  readonly transcript: string
  readonly confidence: number
}

interface ISpeechRecognitionResultList {
  readonly length: number
  item(index: number): ISpeechRecognitionResult
  [index: number]: ISpeechRecognitionResult
}

interface ISpeechRecognitionEvent extends Event {
  readonly resultIndex: number
  readonly results: ISpeechRecognitionResultList
}

interface ISpeechRecognitionErrorEvent extends Event {
  readonly error: string
  readonly message: string
}

interface ISpeechRecognition extends EventTarget {
  lang: string
  continuous: boolean
  interimResults: boolean
  maxAlternatives: number
  start: () => void
  stop: () => void
  abort: () => void
  onstart: ((this: ISpeechRecognition, ev: Event) => void) | null
  onend: ((this: ISpeechRecognition, ev: Event) => void) | null
  onresult: ((this: ISpeechRecognition, ev: ISpeechRecognitionEvent) => void) | null
  onerror: ((this: ISpeechRecognition, ev: ISpeechRecognitionErrorEvent) => void) | null
}

interface ISpeechRecognitionConstructor {
  new (): ISpeechRecognition
}

declare global {
  interface Window {
    SpeechRecognition?: ISpeechRecognitionConstructor
    webkitSpeechRecognition?: ISpeechRecognitionConstructor
  }
}

// ── Hook types ───────────────────────────────────────────────

interface UseVoiceOptions {
  language?: VoiceLanguage
  /** Current question title — passed to Whisper prompt priming for better vocabulary recognition */
  questionTitle?: string
  onTranscript?: (text: string, isFinal: boolean) => void
  onSpeechEnd?: () => void
}

interface UseVoiceReturn {
  status: VoiceStatus
  isSupported: boolean
  isListening: boolean
  isSpeaking: boolean
  interimTranscript: string
  language: VoiceLanguage
  provider: 'webspeech' | 'groq'
  startListening: () => void
  stopListening: () => void
  speak: (text: string, onEnd?: () => void) => void
  stopSpeaking: () => void
  setLanguage: (lang: VoiceLanguage) => void
  setQuestionTitle: (title: string) => void
  toggleListening: () => void
}

// ── Read env config once ─────────────────────────────────────
const STT_PROVIDER = (import.meta.env.VITE_STT_PROVIDER ?? 'webspeech') as 'webspeech' | 'groq'
const GROQ_API_KEY = import.meta.env.VITE_GROQ_API_KEY as string | undefined

export function useVoice(options: UseVoiceOptions = {}): UseVoiceReturn {
  const { language: initialLanguage = 'en-US', questionTitle, onTranscript, onSpeechEnd } = options

  const [status, setStatus] = useState<VoiceStatus>('idle')
  const [language, setLanguage] = useState<VoiceLanguage>(initialLanguage)
  const [interimTranscript, setInterimTranscript] = useState('')
  const [isSpeaking, setIsSpeaking] = useState(false)

  // Decide provider: use groq only if key is present, else fall back to webspeech
  const provider: 'webspeech' | 'groq' =
    STT_PROVIDER === 'groq' && !!GROQ_API_KEY ? 'groq' : 'webspeech'

  // ── Web Speech refs ──────────────────────────────────────
  const recognitionRef = useRef<ISpeechRecognition | null>(null)
  const isListeningRef = useRef(false)

  // ── Groq recorder ref ────────────────────────────────────
  const groqRecorderRef = useRef<GroqSttRecorder | null>(null)

  // ── TTS ref (shared) ─────────────────────────────────────
  const synthRef = useRef<SpeechSynthesis>(window.speechSynthesis)

  // Check browser support
  const isWebSpeechSupported =
    typeof window !== 'undefined' &&
    ('SpeechRecognition' in window || 'webkitSpeechRecognition' in window)

  const isGroqSupported =
    typeof window !== 'undefined' &&
    typeof navigator.mediaDevices?.getUserMedia === 'function' &&
    typeof MediaRecorder !== 'undefined'

  const isSupported = provider === 'groq' ? isGroqSupported : isWebSpeechSupported

  // Keep Groq recorder in sync with language + question title changes
  useEffect(() => {
    groqRecorderRef.current?.setLanguage(language)
  }, [language])

  const questionTitleRef = useRef(questionTitle)
  // Keep ref in sync when the option changes (e.g. question navigated in same session)
  useEffect(() => {
    questionTitleRef.current = questionTitle
    groqRecorderRef.current?.setQuestionTitle(questionTitle ?? '')
  }, [questionTitle])

  const setQuestionTitle = useCallback((title: string) => {
    questionTitleRef.current = title
    groqRecorderRef.current?.setQuestionTitle(title)
  }, [])

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      recognitionRef.current?.stop()
      synthRef.current?.cancel()
      groqRecorderRef.current?.cancel()
    }
  }, [])

  // ── onTranscript callback ref (avoids stale closure in recorder) ──
  const onTranscriptRef = useRef(onTranscript)
  useEffect(() => { onTranscriptRef.current = onTranscript }, [onTranscript])

  const onSpeechEndRef = useRef(onSpeechEnd)
  useEffect(() => { onSpeechEndRef.current = onSpeechEnd }, [onSpeechEnd])

  // ============================================================
  // WEB SPEECH — build recognition instance
  // ============================================================
  const buildWebSpeechRecognition = useCallback((): ISpeechRecognition | null => {
    if (!isWebSpeechSupported) return null

    const SpeechRecognitionImpl =
      window.SpeechRecognition ?? window.webkitSpeechRecognition
    if (!SpeechRecognitionImpl) return null
    const recognition = new SpeechRecognitionImpl()

    recognition.lang = language
    recognition.continuous = false
    recognition.interimResults = true
    recognition.maxAlternatives = 1

    recognition.onstart = () => {
      setStatus('listening')
      isListeningRef.current = true
      setInterimTranscript('')
    }

    recognition.onresult = (event: ISpeechRecognitionEvent) => {
      let interim = ''
      let final = ''

      for (let i = event.resultIndex; i < event.results.length; i++) {
        const result = event.results[i]
        if (result.isFinal) {
          final += result[0].transcript
        } else {
          interim += result[0].transcript
        }
      }

      setInterimTranscript(interim)

      if (final) {
        setInterimTranscript('')
        onTranscriptRef.current?.(final.trim(), true)
      } else if (interim) {
        onTranscriptRef.current?.(interim, false)
      }
    }

    recognition.onend = () => {
      setStatus('idle')
      isListeningRef.current = false
      setInterimTranscript('')
      onSpeechEndRef.current?.()
    }

    recognition.onerror = (event: ISpeechRecognitionErrorEvent) => {
      console.error('SpeechRecognition error:', event.error)
      isListeningRef.current = false
      if (event.error === 'not-allowed') {
        setStatus('error')
      } else if (event.error === 'no-speech') {
        setStatus('idle')
      } else {
        setStatus('error')
      }
    }

    return recognition
  }, [isWebSpeechSupported, language])

  // ============================================================
  // GROQ — start recording
  // ============================================================
  const startGroqRecording = useCallback(async () => {
    if (!isGroqSupported || !GROQ_API_KEY) {
      setStatus('unsupported')
      return
    }
    if (isListeningRef.current) return

    try {
      if (!groqRecorderRef.current) {
        groqRecorderRef.current = new GroqSttRecorder(GROQ_API_KEY, language, questionTitleRef.current)
      } else {
        groqRecorderRef.current.setLanguage(language)
      }

      await groqRecorderRef.current.startRecording()
      isListeningRef.current = true
      setStatus('listening')
      setInterimTranscript('')
    } catch (err) {
      console.error('Groq recording start failed:', err)
      setStatus('error')
    }
  }, [isGroqSupported, language])

  // ============================================================
  // GROQ — stop recording + transcribe
  // ============================================================
  const stopGroqRecording = useCallback(async () => {
    if (!groqRecorderRef.current?.isRecording) {
      isListeningRef.current = false
      setStatus('idle')
      return
    }

    try {
      setStatus('processing')
      isListeningRef.current = false
      setInterimTranscript('Transcribing…')

      const result = await groqRecorderRef.current.stopAndTranscribe()

      setInterimTranscript('')
      setStatus('idle')

      if (result.text) {
        onTranscriptRef.current?.(result.text, true)
      }
    } catch (err) {
      console.error('Groq transcription failed:', err)
      setInterimTranscript('')
      setStatus('error')
    } finally {
      onSpeechEndRef.current?.()
    }
  }, [])

  // ============================================================
  // Public API — startListening / stopListening / toggleListening
  // ============================================================
  const startListening = useCallback(() => {
    if (!isSupported) {
      setStatus('unsupported')
      return
    }

    // Stop TTS if it's playing
    if (isSpeaking) {
      synthRef.current?.cancel()
      setIsSpeaking(false)
    }

    if (provider === 'groq') {
      void startGroqRecording()
    } else {
      if (isListeningRef.current) return
      const recognition = buildWebSpeechRecognition()
      if (!recognition) return
      recognitionRef.current = recognition
      try {
        recognition.start()
      } catch (err) {
        console.error('Failed to start Web Speech recognition:', err)
        setStatus('error')
      }
    }
  }, [isSupported, isSpeaking, provider, startGroqRecording, buildWebSpeechRecognition])

  const stopListening = useCallback(() => {
    if (provider === 'groq') {
      void stopGroqRecording()
    } else {
      recognitionRef.current?.stop()
      isListeningRef.current = false
      setStatus('idle')
    }
  }, [provider, stopGroqRecording])

  const toggleListening = useCallback(() => {
    if (isListeningRef.current || status === 'listening') {
      stopListening()
    } else {
      startListening()
    }
  }, [status, startListening, stopListening])

  // ============================================================
  // TTS — shared browser SpeechSynthesis
  // ============================================================
  const speak = useCallback(
    (text: string, onEnd?: () => void) => {
      if (!('speechSynthesis' in window)) return

      synthRef.current?.cancel()

      // Strip markdown for cleaner TTS
      const cleanText = text
        .replace(/```[\s\S]*?```/g, 'code block')
        .replace(/`[^`]+`/g, '')
        .replace(/\*\*([^*]+)\*\*/g, '$1')
        .replace(/\*([^*]+)\*/g, '$1')
        .replace(/#{1,6}\s/g, '')
        .replace(/\n+/g, ' ')
        .trim()

      const utterance = new SpeechSynthesisUtterance(cleanText)
      utterance.lang = language
      utterance.rate = 0.95
      utterance.pitch = 1.0
      utterance.volume = 1.0

      // Prefer a neural/natural voice if available
      const voices = synthRef.current?.getVoices() ?? []
      const preferred = voices.find(
        (v) =>
          v.lang === language &&
          (v.name.includes('Neural') ||
            v.name.includes('Natural') ||
            v.name.includes('Enhanced') ||
            !v.localService),
      )
      if (preferred) utterance.voice = preferred

      utterance.onstart = () => {
        setIsSpeaking(true)
        setStatus('speaking')
      }
      utterance.onend = () => {
        setIsSpeaking(false)
        setStatus('idle')
        onEnd?.()
      }
      utterance.onerror = () => {
        setIsSpeaking(false)
        setStatus('idle')
        onEnd?.()
      }

      synthRef.current?.speak(utterance)
    },
    [language],
  )

  const stopSpeaking = useCallback(() => {
    synthRef.current?.cancel()
    setIsSpeaking(false)
    setStatus('idle')
  }, [])

  return {
    status,
    isSupported,
    isListening: isListeningRef.current,
    isSpeaking,
    interimTranscript,
    language,
    provider,
    startListening,
    stopListening,
    speak,
    stopSpeaking,
    setLanguage,
    setQuestionTitle,
    toggleListening,
  }
}
