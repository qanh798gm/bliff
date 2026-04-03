import { useState, useEffect, useRef, useCallback } from 'react'
import { useInterview } from '../hooks/useInterview'
import { useVoice } from '../hooks/useVoice'
import { ChatTranscript } from './ChatTranscript'
import { CodeEditor } from './CodeEditor'
import { VoiceControls } from './VoiceControls'
import { QuestionPanel } from './QuestionPanel'
import { TestResultsPanel } from './TestResultsPanel'
import type { VoiceLanguage } from '../types'

// ============================================================
// InterviewRoom — main interview UI
// Layout: left panel (question) | center (chat+voice) | right (code)
// ============================================================

type ActiveTab = 'question' | 'chat'
type RightTab = 'editor' | 'tests'

export function InterviewRoom() {
  const interview = useInterview()
  const [code, setCode] = useState(interview.question.functionSignature)
  const [textInput, setTextInput] = useState('')
  const [activeLeftTab, setActiveLeftTab] = useState<ActiveTab>('question')
  const [activeRightTab, setActiveRightTab] = useState<RightTab>('editor')
  const [language, setLanguage] = useState<VoiceLanguage>('en-US')

  // When AI responds, speak the latest assistant message
  const lastSpokenRef = useRef<string>('')

  const voice = useVoice({
    language,
    onTranscript: (text, isFinal) => {
      if (isFinal) {
        void interview.sendMessage(text)
      }
    },
  })

  // Speak new AI messages via TTS
  const latestAssistantMessage = [...interview.messages]
    .reverse()
    .find((m) => m.role === 'assistant')

  useEffect(() => {
    if (
      latestAssistantMessage &&
      latestAssistantMessage.content &&
      latestAssistantMessage.content !== lastSpokenRef.current &&
      !interview.isThinking
    ) {
      lastSpokenRef.current = latestAssistantMessage.content
      voice.speak(latestAssistantMessage.content)
    }
  }, [latestAssistantMessage, interview.isThinking, voice])

  const handleSendText = useCallback(() => {
    if (!textInput.trim()) return
    void interview.sendMessage(textInput.trim())
    setTextInput('')
  }, [textInput, interview])

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSendText()
    }
  }

  const handleRunCode = useCallback(() => {
    setActiveRightTab('tests')
    void interview.runCode(code)
  }, [code, interview])

  const handleSubmit = useCallback(() => {
    setActiveRightTab('tests')
    void interview.submitCode(code)
  }, [code, interview])

  const stageLabel: Record<typeof interview.stage, string> = {
    idle: '● Ready',
    present: '● Problem Presented',
    clarify: '● Clarifying',
    solve: '● Solving',
    review: '● Reviewing',
    feedback: '● Feedback',
  }

  const stageColor: Record<typeof interview.stage, string> = {
    idle: 'text-gray-500',
    present: 'text-blue-400',
    clarify: 'text-yellow-400',
    solve: 'text-green-400',
    review: 'text-orange-400',
    feedback: 'text-purple-400',
  }

  return (
    <div className="flex flex-col h-screen bg-gray-950 text-gray-100">
      {/* Top bar */}
      <header className="flex items-center justify-between px-4 py-2 border-b border-gray-800 bg-gray-900 flex-shrink-0">
        <div className="flex items-center gap-3">
          <span className="text-xl font-bold text-indigo-400">Bliff</span>
          <span className="text-xs text-gray-500">DSA Interview Coach</span>
        </div>

        <div className="flex items-center gap-4">
          <span className={`text-xs font-medium ${stageColor[interview.stage]}`}>
            {stageLabel[interview.stage]}
          </span>

          {interview.hintsGiven > 0 && (
            <span className="text-xs text-amber-400">
              💡 {interview.hintsGiven}/{interview.question.hints.length} hints
            </span>
          )}
        </div>

        {/* Session controls */}
        <div className="flex items-center gap-2">
          {interview.stage === 'idle' ? (
            <button
              onClick={() => void interview.startSession()}
              className="px-4 py-1.5 bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-medium rounded-lg transition-colors"
            >
              Start Interview
            </button>
          ) : (
            <>
              <button
                onClick={() => void interview.requestHint()}
                disabled={interview.isThinking}
                className="px-3 py-1.5 bg-amber-700/50 hover:bg-amber-700 text-amber-300 text-xs font-medium rounded-lg transition-colors disabled:opacity-40"
              >
                Hint
              </button>
              <button
                onClick={() => void interview.endSession()}
                disabled={interview.isThinking}
                className="px-3 py-1.5 bg-purple-700/50 hover:bg-purple-700 text-purple-300 text-xs font-medium rounded-lg transition-colors disabled:opacity-40"
              >
                End &amp; Feedback
              </button>
              <button
                onClick={interview.resetSession}
                className="px-3 py-1.5 bg-gray-700 hover:bg-gray-600 text-gray-300 text-xs font-medium rounded-lg transition-colors"
              >
                Reset
              </button>
            </>
          )}
        </div>
      </header>

      {/* Main 3-column layout */}
      <div className="flex flex-1 overflow-hidden">
        {/* LEFT PANEL — Question description */}
        <div className="w-80 flex-shrink-0 flex flex-col border-r border-gray-800">
          {/* Tabs */}
          <div className="flex border-b border-gray-800">
            {(['question', 'chat'] as ActiveTab[]).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveLeftTab(tab)}
                className={`flex-1 py-2 text-xs font-medium capitalize transition-colors ${
                  activeLeftTab === tab
                    ? 'text-indigo-400 border-b-2 border-indigo-500'
                    : 'text-gray-500 hover:text-gray-300'
                }`}
              >
                {tab === 'chat' ? 'Transcript' : 'Problem'}
              </button>
            ))}
          </div>
          <div className="flex-1 overflow-hidden p-4">
            {activeLeftTab === 'question' ? (
              <QuestionPanel question={interview.question} />
            ) : (
              <ChatTranscript
                messages={interview.messages}
                isThinking={interview.isThinking}
              />
            )}
          </div>
        </div>

        {/* CENTER PANEL — Voice + text input */}
        <div className="flex-1 flex flex-col min-w-0">
          {/* Chat transcript (center main area) */}
          <div className="flex-1 overflow-hidden p-4">
            <ChatTranscript
              messages={interview.messages}
              isThinking={interview.isThinking}
            />
          </div>

          {/* Voice + text input bar */}
          <div className="flex-shrink-0 border-t border-gray-800 p-4 bg-gray-900">
            <VoiceControls
              status={voice.status}
              isSupported={voice.isSupported}
              isSpeaking={voice.isSpeaking}
              language={language}
              interimTranscript={voice.interimTranscript}
              onToggleListen={voice.toggleListening}
              onStopSpeaking={voice.stopSpeaking}
              onLanguageChange={setLanguage}
            />

            {/* Text input fallback */}
            <div className="flex gap-2 mt-3">
              <textarea
                value={textInput}
                onChange={(e) => setTextInput(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Type a message... (Enter to send, Shift+Enter for newline)"
                rows={2}
                className="flex-1 bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-sm text-gray-100 placeholder-gray-500 resize-none focus:outline-none focus:border-indigo-500 transition-colors"
              />
              <button
                onClick={handleSendText}
                disabled={!textInput.trim() || interview.isThinking}
                className="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-40 disabled:cursor-not-allowed text-white text-sm font-medium rounded-lg transition-colors self-end"
              >
                Send
              </button>
            </div>
          </div>
        </div>

        {/* RIGHT PANEL — Code editor + test results */}
        <div className="w-[480px] flex-shrink-0 flex flex-col border-l border-gray-800">
          {/* Tabs */}
          <div className="flex border-b border-gray-800">
            {(['editor', 'tests'] as RightTab[]).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveRightTab(tab)}
                className={`flex-1 py-2 text-xs font-medium capitalize transition-colors ${
                  activeRightTab === tab
                    ? 'text-indigo-400 border-b-2 border-indigo-500'
                    : 'text-gray-500 hover:text-gray-300'
                }`}
              >
                {tab === 'tests'
                  ? `Tests ${interview.testResults.length > 0 ? `(${interview.testResults.filter((r) => r.passed).length}/${interview.testResults.length})` : ''}`
                  : 'Editor'}
              </button>
            ))}
          </div>

          {/* Editor */}
          <div className="flex-1 overflow-hidden p-3 flex flex-col gap-3">
            {activeRightTab === 'editor' ? (
              <CodeEditor
                value={code}
                onChange={setCode}
                height="calc(100vh - 200px)"
              />
            ) : (
              <div className="overflow-y-auto flex-1">
                <TestResultsPanel
                  results={interview.testResults}
                  isRunning={interview.isRunningTests}
                />
              </div>
            )}
          </div>

          {/* Code action buttons */}
          <div className="flex-shrink-0 border-t border-gray-800 p-3 flex gap-2">
            <button
              onClick={handleRunCode}
              disabled={interview.isRunningTests || interview.stage === 'idle'}
              className="flex-1 py-2 bg-gray-700 hover:bg-gray-600 disabled:opacity-40 disabled:cursor-not-allowed text-gray-200 text-sm font-medium rounded-lg transition-colors"
            >
              {interview.isRunningTests ? 'Running...' : '▶ Run Tests'}
            </button>
            <button
              onClick={handleSubmit}
              disabled={interview.isRunningTests || interview.stage === 'idle'}
              className="flex-1 py-2 bg-green-700 hover:bg-green-600 disabled:opacity-40 disabled:cursor-not-allowed text-white text-sm font-medium rounded-lg transition-colors"
            >
              ✓ Submit
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
