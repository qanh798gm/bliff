// ============================================================
// groqStt — Groq Whisper STT service
// Records audio via MediaRecorder (push-to-talk), then POSTs
// to Groq's /openai/v1/audio/transcriptions endpoint.
//
// UX flow:
//   startRecording() → user speaks → stopRecording() → transcribe()
//   → returns { text, language }
//
// Browser support: any browser that supports MediaRecorder + getUserMedia
// ============================================================

import { buildSttPrompt, postProcessTranscript } from './sttVocabulary'

const GROQ_BASE = 'https://api.groq.com/openai/v1'
const STT_MODEL = 'whisper-large-v3-turbo' // best speed/accuracy balance

export type GroqSttResult = {
  text: string
  language: string
}

export class GroqSttRecorder {
  private apiKey: string
  private language: string
  private questionTitle?: string
  private mediaRecorder: MediaRecorder | null = null
  private chunks: Blob[] = []
  private stream: MediaStream | null = null

  constructor(apiKey: string, language = 'en', questionTitle?: string) {
    this.apiKey = apiKey
    // Groq expects ISO 639-1 (e.g. "en", "vi") not BCP-47 ("en-US", "vi-VN")
    this.language = language.split('-')[0]
    this.questionTitle = questionTitle
  }

  setLanguage(language: string) {
    this.language = language.split('-')[0]
  }

  /** Update the current question title so the Whisper prompt stays relevant */
  setQuestionTitle(title: string) {
    this.questionTitle = title
  }

  get isRecording(): boolean {
    return this.mediaRecorder?.state === 'recording'
  }

  // Request mic permission + start recording
  async startRecording(): Promise<void> {
    if (this.isRecording) return

    this.stream = await navigator.mediaDevices.getUserMedia({
      audio: {
        channelCount: 1,
        sampleRate: 16000,    // Whisper prefers 16kHz
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl: true,
      },
    })

    // Prefer webm/opus — best compression, widely supported
    const mimeType = MediaRecorder.isTypeSupported('audio/webm;codecs=opus')
      ? 'audio/webm;codecs=opus'
      : MediaRecorder.isTypeSupported('audio/webm')
        ? 'audio/webm'
        : 'audio/ogg;codecs=opus'

    this.chunks = []
    this.mediaRecorder = new MediaRecorder(this.stream, { mimeType })
    this.mediaRecorder.ondataavailable = (e) => {
      if (e.data.size > 0) this.chunks.push(e.data)
    }
    this.mediaRecorder.start(100) // collect chunks every 100ms
  }

  // Stop recording and return the audio blob
  stopRecording(): Promise<Blob> {
    return new Promise((resolve, reject) => {
      if (!this.mediaRecorder || this.mediaRecorder.state !== 'recording') {
        reject(new Error('Not recording'))
        return
      }

      this.mediaRecorder.onstop = () => {
        const mimeType = this.mediaRecorder?.mimeType ?? 'audio/webm'
        const blob = new Blob(this.chunks, { type: mimeType })
        this.chunks = []
        // Release mic
        this.stream?.getTracks().forEach((t) => t.stop())
        this.stream = null
        resolve(blob)
      }

      this.mediaRecorder.stop()
    })
  }

  // POST audio blob to Groq Whisper
  async transcribe(audioBlob: Blob): Promise<GroqSttResult> {
    const formData = new FormData()

    // Groq accepts webm, mp4, mpeg, mpga, m4a, wav, ogg
    // Derive extension from MIME type
    const ext = audioBlob.type.includes('ogg') ? 'ogg'
      : audioBlob.type.includes('mp4') ? 'mp4'
      : 'webm'

    formData.append('file', audioBlob, `audio.${ext}`)
    formData.append('model', STT_MODEL)
    formData.append('language', this.language)
    formData.append('response_format', 'json')

    // Vocabulary priming — biases Whisper toward DSA/frontend terms and the
    // current question title. Up to ~224 tokens; buildSttPrompt stays well under.
    formData.append('prompt', buildSttPrompt(this.questionTitle))

    const response = await fetch(`${GROQ_BASE}/audio/transcriptions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        // Do NOT set Content-Type — browser sets it with boundary for FormData
      },
      body: formData,
    })

    if (!response.ok) {
      const err = await response.text()
      throw new Error(`Groq STT error ${response.status}: ${err}`)
    }

    const data = await response.json() as { text: string; language?: string }
    // Apply post-processing corrections after the raw transcript is received
    const corrected = postProcessTranscript(data.text.trim())
    return {
      text: corrected,
      language: data.language ?? this.language,
    }
  }

  // Convenience: stop + transcribe in one call
  async stopAndTranscribe(): Promise<GroqSttResult> {
    const blob = await this.stopRecording()
    return this.transcribe(blob)
  }

  // Emergency cleanup
  cancel() {
    if (this.mediaRecorder?.state === 'recording') {
      this.mediaRecorder.stop()
    }
    this.stream?.getTracks().forEach((t) => t.stop())
    this.stream = null
    this.chunks = []
  }
}
