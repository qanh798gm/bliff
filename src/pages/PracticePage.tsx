import { useState, useCallback } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { usePractice } from '../hooks/usePractice'
import { useVoice } from '../hooks/useVoice'
import { QuestionPanel } from '../components/QuestionPanel'
import { CodeEditor } from '../components/CodeEditor'
import { TestResultsPanel } from '../components/TestResultsPanel'
import { ChatTranscript } from '../components/ChatTranscript'
import { SaveSolutionModal } from '../components/SaveSolutionModal'
import { SolutionHistory, SolutionViewer } from '../components/SolutionHistory'
import type { UserSolution, VoiceLanguage } from '../types'

// ============================================================
// PracticePage — self-directed practice mode
// Route: /practice/:slug
// Layout: Left (problem + AI chat + solution history) |
//         Right (editor top + test results bottom)
// ============================================================

export function PracticePage() {
  const { slug } = useParams<{ slug?: string }>()
  const navigate = useNavigate()
  const practice = usePractice(slug)

  const [code, setCode] = useState(practice.question.functionSignature)
  const [textInput, setTextInput] = useState('')
  const [showSaveModal, setShowSaveModal] = useState(false)
  const [viewingSolution, setViewingSolution] = useState<UserSolution | null>(null)
  // Sync editor to question signature when question loads
  const [lastSignature, setLastSignature] = useState(practice.question.functionSignature)
  if (practice.question.functionSignature !== lastSignature) {
    setLastSignature(practice.question.functionSignature)
    setCode(practice.question.functionSignature)
  }

  const voice = useVoice({
    questionTitle: practice.question.title,
    onTranscript: (text, isFinal) => {
      if (isFinal && practice.aiMode === 'chat') {
        void practice.sendMessage(text)
      }
    },
  })
  const language = voice.language
  const setLanguage = voice.setLanguage

  const handleRunTests = useCallback(() => {
    void practice.runTests(code)
  }, [code, practice])

  const handleSendText = useCallback(() => {
    if (!textInput.trim()) return
    void practice.sendMessage(textInput.trim())
    setTextInput('')
  }, [textInput, practice])

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSendText()
    }
  }

  const handleSaveSolution = useCallback(async (params: {
    label: string
    timeComplexity: string
    spaceComplexity: string
  }) => {
    await practice.saveSolution({ code, ...params })
    setShowSaveModal(false)
  }, [code, practice])

  const passCount = practice.testResults.filter((r) => r.passed).length
  const totalCount = practice.testResults.length

  return (
    <div className="flex flex-col h-screen bg-gray-950 text-gray-100">
      {/* Top bar */}
      <header className="flex items-center justify-between px-4 py-2 border-b border-gray-800 bg-gray-900 flex-shrink-0">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate('/dashboard')}
            className="text-indigo-400 font-bold text-xl hover:text-indigo-300 transition-colors"
          >
            bli<span className="text-white">ff</span>
          </button>
          <span className="text-xs text-gray-500">Practice</span>
          {practice.question.title && (
            <>
              <span className="text-gray-700">/</span>
              <span className="text-sm text-gray-300">{practice.question.title}</span>
            </>
          )}
        </div>

        <div className="flex items-center gap-2">
          {/* Navigate to interview mode for this question */}
          {slug && (
            <button
              onClick={() => navigate(`/interview/${slug}`)}
              className="flex items-center gap-1.5 px-3 py-1.5 bg-indigo-700/40 hover:bg-indigo-700/70 text-indigo-300 text-xs font-medium rounded-lg transition-colors border border-indigo-700/50"
            >
              🎙 Mock Interview
            </button>
          )}
          <button
            onClick={() => navigate('/questions')}
            className="px-3 py-1.5 text-gray-400 hover:text-white text-xs transition-colors"
          >
            ← Questions
          </button>
        </div>
      </header>

      {/* Main 3-column layout: description (1) | editor+tests (2) | AI chat+solutions (1) */}
      <div className="flex flex-1 overflow-hidden">

        {/* ── COL 1 (1fr): Problem description ──────────── */}
        <div className="w-72 flex-shrink-0 flex flex-col border-r border-gray-800 overflow-hidden">
          <div className="flex-1 overflow-y-auto p-4 min-h-0">
            {practice.isLoadingQuestion ? (
              <div className="text-gray-600 text-sm animate-pulse">Loading question…</div>
            ) : (
              <QuestionPanel question={practice.question} />
            )}
          </div>
        </div>

        {/* ── COL 2 (2fr): Editor + action bar + test results ── */}
        <div className="flex-1 flex flex-col min-w-0 overflow-hidden border-r border-gray-800">
          {/* Editor (upper, flex-1) */}
          <div className="flex-1 overflow-hidden p-3 flex flex-col gap-2 min-h-0">
            <CodeEditor
              value={code}
              onChange={setCode}
              height="100%"
            />
          </div>

          {/* Action bar between editor and tests */}
          <div className="flex items-center gap-2 px-3 py-2 border-t border-b border-gray-800 bg-gray-900/50 flex-shrink-0">
            <button
              onClick={handleRunTests}
              disabled={practice.isRunningTests}
              className="px-4 py-1.5 bg-gray-700 hover:bg-gray-600 disabled:opacity-40 disabled:cursor-not-allowed text-gray-200 text-sm font-medium rounded-lg transition-colors"
            >
              {practice.isRunningTests ? 'Running…' : '▶ Run Tests'}
            </button>
            <button
              onClick={() => setShowSaveModal(true)}
              disabled={practice.isSavingSolution}
              className="px-4 py-1.5 bg-green-700/60 hover:bg-green-700 disabled:opacity-40 text-green-200 text-sm font-medium rounded-lg transition-colors border border-green-700/50"
            >
              💾 Save Solution
            </button>

            {/* Test results summary */}
            {totalCount > 0 && (
              <span className={`ml-auto text-xs font-medium ${
                passCount === totalCount ? 'text-green-400' : 'text-yellow-400'
              }`}>
                {passCount}/{totalCount} passed
              </span>
            )}
          </div>

          {/* Test results (lower, fixed height, scrollable) */}
          <div className="flex-shrink-0 overflow-y-auto" style={{ minHeight: '160px', maxHeight: '40%' }}>
            <TestResultsPanel
              results={practice.testResults}
              isRunning={practice.isRunningTests}
            />
          </div>
        </div>{/* end col 2 */}

        {/* ── COL 3 (1fr): AI chat + solution history ───── */}
        <div className="w-80 flex-shrink-0 flex flex-col overflow-hidden">

          {/* AI mode toggle bar */}
          <div className="flex items-center justify-between px-3 py-2 border-b border-gray-800 bg-gray-900/50 flex-shrink-0">
            <span className="text-xs font-medium text-gray-400">AI Coach</span>
            <div className="flex items-center gap-1">
              <button
                onClick={() => practice.setAiMode('off')}
                className={`px-2 py-0.5 rounded text-[10px] font-medium transition-colors ${
                  practice.aiMode === 'off'
                    ? 'bg-gray-700 text-gray-200'
                    : 'text-gray-500 hover:text-gray-300'
                }`}
              >
                Off
              </button>
              <button
                onClick={() => practice.setAiMode('chat')}
                className={`px-2 py-0.5 rounded text-[10px] font-medium transition-colors ${
                  practice.aiMode === 'chat'
                    ? 'bg-indigo-600 text-white'
                    : 'text-gray-500 hover:text-gray-300'
                }`}
              >
                Chat
              </button>
            </div>
          </div>

          {/* Chat transcript */}
          <div className="flex-1 overflow-y-auto p-3 min-h-0">
            {practice.aiMode === 'chat' ? (
              practice.messages.length === 0 ? (
                <p className="text-gray-600 text-xs">
                  Ask for a hint, request code analysis, or discuss trade-offs.
                </p>
              ) : (
                <ChatTranscript
                  messages={practice.messages}
                  isThinking={practice.isThinking}
                />
              )
            ) : (
              <p className="text-gray-700 text-xs">AI Coach is off. Enable Chat to get help.</p>
            )}
          </div>

          {/* Text input (chat mode only) */}
          {practice.aiMode === 'chat' && (
            <>
              <div className="flex gap-2 p-2 border-t border-gray-800">
                <textarea
                  value={textInput}
                  onChange={(e) => setTextInput(e.target.value)}
                  onKeyDown={handleKeyDown}
                  placeholder="Ask AI for help…"
                  rows={1}
                  className="flex-1 bg-gray-800 border border-gray-700 rounded-lg px-2 py-1.5 text-xs text-gray-100 placeholder-gray-500 resize-none focus:outline-none focus:border-indigo-500 transition-colors"
                />
                <button
                  onClick={handleSendText}
                  disabled={!textInput.trim() || practice.isThinking}
                  className="px-2 py-1.5 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-40 text-white text-xs font-medium rounded-lg transition-colors self-end"
                >
                  ↑
                </button>
              </div>

              {/* Voice toggle */}
              <div className="flex items-center gap-2 px-2 pb-2 border-t border-gray-800 pt-1">
                <button
                  onClick={voice.toggleListening}
                  disabled={!voice.isSupported}
                  className={`flex items-center gap-1 px-2 py-1 rounded text-[10px] font-medium transition-colors ${
                    voice.status === 'listening'
                      ? 'bg-red-600/30 text-red-400 border border-red-700/50'
                      : 'bg-gray-800 text-gray-500 hover:text-gray-300'
                  }`}
                >
                  {voice.status === 'listening' ? '🔴 Listening…' : '🎙 Voice'}
                </button>
                <select
                  value={language}
                  onChange={(e) => setLanguage(e.target.value as VoiceLanguage)}
                  className="bg-gray-800 text-gray-500 text-[10px] rounded px-1 py-0.5 border border-gray-700 focus:outline-none"
                >
                  <option value="en-US">EN</option>
                  <option value="vi-VN">VI</option>
                </select>
              </div>
            </>
          )}

          {/* Solution History */}
          <div className="flex-shrink-0 border-t border-gray-800">
            <div className="px-3 py-2">
              <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">
                Solutions ({practice.solutions.length})
              </span>
            </div>
            <div className="px-3 pb-3 max-h-56 overflow-y-auto">
              <SolutionHistory
                solutions={practice.solutions}
                onMarkBest={(id) => void practice.markSolutionAsBest(id)}
                onView={(sol) => setViewingSolution(sol)}
                onDelete={(id) => void practice.deleteSolution(id)}
                isLoading={practice.isLoadingSolutions}
              />
            </div>
          </div>
        </div>{/* end col 3 */}

      </div>

      {/* Modals */}
      <SaveSolutionModal
        isOpen={showSaveModal}
        onClose={() => setShowSaveModal(false)}
        onSave={handleSaveSolution}
        isSaving={practice.isSavingSolution}
      />
      <SolutionViewer
        solution={viewingSolution}
        onClose={() => setViewingSolution(null)}
      />
    </div>
  )
}
