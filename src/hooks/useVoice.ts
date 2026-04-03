import { useState, useRef, useCallback, useEffect } from 'react'
import type { VoiceStatus, VoiceLanguage } from '../types'

// ============================================================
// useVoice — Web Speech API hook
// STT: SpeechRecognition (push-to-talk or VAD)
// TTS: SpeechSynthesis
// Phase 2+: swap to Groq provider via VITE_STT_PROVIDER env
// ============================================================

// The Web Speech API is not fully typed in lib.dom.d.ts — declare all needed types manually

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

interface UseVoiceOptions {
  language?: VoiceLanguage
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
  startListening: () => void
  stopListening: () => void
  speak: (text: string, onEnd?: () => void) => void
  stopSpeaking: () => void
  setLanguage: (lang: VoiceLanguage) => void
  toggleListening: () => void
}

export function useVoice(options: UseVoiceOptions = {}): UseVoiceReturn {
  const { language: initialLanguage = 'en-US', onTranscript, onSpeechEnd } = options

  const [status, setStatus] = useState<VoiceStatus>('idle')
  const [language, setLanguage] = useState<VoiceLanguage>(initialLanguage)
  const [interimTranscript, setInterimTranscript] = useState('')
  const [isSpeaking, setIsSpeaking] = useState(false)

  const recognitionRef = useRef<ISpeechRecognition | null>(null)
  const synthRef = useRef<SpeechSynthesis>(window.speechSynthesis)
  const isListeningRef = useRef(false)

  // Check browser support
  const isSupported =
    typeof window !== 'undefined' &&
    ('SpeechRecognition' in window || 'webkitSpeechRecognition' in window)

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      recognitionRef.current?.stop()
      synthRef.current?.cancel()
    }
  }, [])

  const buildRecognition = useCallback((): ISpeechRecognition | null => {
    if (!isSupported) return null

    const SpeechRecognitionImpl =
      window.SpeechRecognition ?? window.webkitSpeechRecognition
    if (!SpeechRecognitionImpl) return null
    const recognition = new SpeechRecognitionImpl()

    recognition.lang = language
    recognition.continuous = false       // Single utterance per activation
    recognition.interimResults = true    // Show real-time partial results
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
        onTranscript?.(final.trim(), true)
      } else if (interim) {
        onTranscript?.(interim, false)
      }
    }

    recognition.onend = () => {
      setStatus('idle')
      isListeningRef.current = false
      setInterimTranscript('')
      onSpeechEnd?.()
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
  }, [isSupported, language, onTranscript, onSpeechEnd])

  const startListening = useCallback(() => {
    if (!isSupported) {
      setStatus('unsupported')
      return
    }

    // Don't start if AI is speaking
    if (isSpeaking) {
      synthRef.current?.cancel()
      setIsSpeaking(false)
    }

    if (isListeningRef.current) return

    const recognition = buildRecognition()
    if (!recognition) return

    recognitionRef.current = recognition

    try {
      recognition.start()
    } catch (err) {
      console.error('Failed to start recognition:', err)
      setStatus('error')
    }
  }, [isSupported, isSpeaking, buildRecognition])

  const stopListening = useCallback(() => {
    recognitionRef.current?.stop()
    isListeningRef.current = false
    setStatus('idle')
  }, [])

  const toggleListening = useCallback(() => {
    if (isListeningRef.current) {
      stopListening()
    } else {
      startListening()
    }
  }, [startListening, stopListening])

  const speak = useCallback(
    (text: string, onEnd?: () => void) => {
      if (!('speechSynthesis' in window)) return

      // Cancel any current speech
      synthRef.current?.cancel()

      // Strip markdown formatting for cleaner TTS
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

      // Prefer a natural voice if available
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
    startListening,
    stopListening,
    speak,
    stopSpeaking,
    setLanguage,
    toggleListening,
  }
}
