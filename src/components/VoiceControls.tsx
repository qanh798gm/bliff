import type { VoiceStatus, VoiceLanguage } from '../types'

// ============================================================
// VoiceControls — mic button, language toggle, status indicator
// ============================================================

interface VoiceControlsProps {
  status: VoiceStatus
  isSupported: boolean
  isSpeaking: boolean
  language: VoiceLanguage
  interimTranscript: string
  onToggleListen: () => void
  onStopSpeaking: () => void
  onLanguageChange: (lang: VoiceLanguage) => void
}

const STATUS_CONFIG: Record<VoiceStatus, { label: string; color: string; pulse: boolean }> = {
  idle: { label: 'Ready', color: 'text-gray-400', pulse: false },
  listening: { label: 'Listening...', color: 'text-green-400', pulse: true },
  processing: { label: 'Processing...', color: 'text-yellow-400', pulse: true },
  speaking: { label: 'Speaking...', color: 'text-indigo-400', pulse: true },
  error: { label: 'Error — check mic permissions', color: 'text-red-400', pulse: false },
  unsupported: { label: 'Voice not supported in this browser', color: 'text-red-400', pulse: false },
}

export function VoiceControls({
  status,
  isSupported,
  isSpeaking,
  language,
  interimTranscript,
  onToggleListen,
  onStopSpeaking,
  onLanguageChange,
}: VoiceControlsProps) {
  const isListening = status === 'listening'
  const config = STATUS_CONFIG[status]

  return (
    <div className="flex flex-col gap-3">
      {/* Main controls row */}
      <div className="flex items-center gap-3">
        {/* Mic button */}
        <button
          onClick={onToggleListen}
          disabled={!isSupported || isSpeaking}
          title={isListening ? 'Stop listening' : 'Start listening'}
          className={`
            relative flex items-center justify-center w-14 h-14 rounded-full
            font-medium transition-all duration-200 shadow-lg
            disabled:opacity-40 disabled:cursor-not-allowed
            ${isListening
              ? 'bg-red-500 hover:bg-red-600 scale-110'
              : 'bg-indigo-600 hover:bg-indigo-500'
            }
          `}
        >
          {/* Pulse ring when listening */}
          {isListening && (
            <span className="absolute inset-0 rounded-full bg-red-400 animate-ping opacity-40" />
          )}
          <MicIcon active={isListening} />
        </button>

        {/* Stop speaking button */}
        {isSpeaking && (
          <button
            onClick={onStopSpeaking}
            title="Stop AI speaking"
            className="flex items-center justify-center w-10 h-10 rounded-full bg-gray-700 hover:bg-gray-600 transition-colors"
          >
            <StopIcon />
          </button>
        )}

        {/* Status text */}
        <div className="flex flex-col gap-0.5">
          <span className={`text-sm font-medium ${config.color}`}>
            {config.label}
          </span>
          {interimTranscript && (
            <span className="text-xs text-gray-400 italic max-w-xs truncate">
              "{interimTranscript}"
            </span>
          )}
        </div>

        {/* Language toggle */}
        <div className="ml-auto flex rounded-lg overflow-hidden border border-gray-700">
          {(['en-US', 'vi-VN'] as VoiceLanguage[]).map((lang) => (
            <button
              key={lang}
              onClick={() => onLanguageChange(lang)}
              className={`px-3 py-1.5 text-xs font-medium transition-colors ${
                language === lang
                  ? 'bg-indigo-600 text-white'
                  : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
              }`}
            >
              {lang === 'en-US' ? '🇺🇸 EN' : '🇻🇳 VI'}
            </button>
          ))}
        </div>
      </div>

      {/* Browser support warning */}
      {!isSupported && (
        <p className="text-xs text-amber-400 bg-amber-900/20 rounded-lg px-3 py-2 border border-amber-800/30">
          ⚠️ Voice input requires Chrome or Edge. You can still type your responses below.
        </p>
      )}
    </div>
  )
}

function MicIcon({ active }: { active: boolean }) {
  return (
    <svg
      className="w-6 h-6 text-white"
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
    >
      {active ? (
        // Mic with waves when active
        <>
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
        </>
      ) : (
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
      )}
    </svg>
  )
}

function StopIcon() {
  return (
    <svg className="w-4 h-4 text-gray-300" fill="currentColor" viewBox="0 0 24 24">
      <rect x="6" y="6" width="12" height="12" rx="1" />
    </svg>
  )
}
