import { useState } from 'react'
import type { SolutionLabel } from '../types'

// ============================================================
// SaveSolutionModal — save a ranked solution for a question
// ============================================================

const LABEL_OPTIONS: SolutionLabel[] = [
  'Brute Force',
  'Better',
  'Optimal',
  'Alternative',
]

interface SaveSolutionModalProps {
  isOpen: boolean
  onClose: () => void
  onSave: (params: {
    label: string
    timeComplexity: string
    spaceComplexity: string
  }) => Promise<void>
  /** Pre-fill if AI has already analyzed complexity */
  initialTimeComplexity?: string
  initialSpaceComplexity?: string
  isSaving?: boolean
}

export function SaveSolutionModal({
  isOpen,
  onClose,
  onSave,
  initialTimeComplexity = '',
  initialSpaceComplexity = '',
  isSaving = false,
}: SaveSolutionModalProps) {
  const [label, setLabel] = useState<string>('Brute Force')
  const [customLabel, setCustomLabel] = useState('')
  const [timeComplexity, setTimeComplexity] = useState(initialTimeComplexity)
  const [spaceComplexity, setSpaceComplexity] = useState(initialSpaceComplexity)
  const [useCustomLabel, setUseCustomLabel] = useState(false)
  const [error, setError] = useState<string | null>(null)

  if (!isOpen) return null

  const finalLabel = useCustomLabel ? customLabel.trim() : label

  async function handleSave() {
    if (!finalLabel) {
      setError('Please enter a label for this solution.')
      return
    }
    setError(null)
    await onSave({
      label: finalLabel,
      timeComplexity: timeComplexity.trim(),
      spaceComplexity: spaceComplexity.trim(),
    })
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative bg-gray-900 border border-gray-700 rounded-xl shadow-2xl w-full max-w-sm mx-4 p-6">
        <h2 className="text-lg font-semibold text-white mb-4">Save Solution</h2>

        {/* Label selector */}
        <div className="mb-4">
          <label className="block text-xs font-medium text-gray-400 mb-1.5">
            Solution type
          </label>
          <div className="flex flex-wrap gap-2 mb-2">
            {LABEL_OPTIONS.map((opt) => (
              <button
                key={opt}
                onClick={() => { setLabel(opt); setUseCustomLabel(false) }}
                className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
                  !useCustomLabel && label === opt
                    ? 'bg-indigo-600 text-white'
                    : 'bg-gray-800 text-gray-400 hover:text-white hover:bg-gray-700'
                }`}
              >
                {opt}
              </button>
            ))}
            <button
              onClick={() => setUseCustomLabel(true)}
              className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
                useCustomLabel
                  ? 'bg-indigo-600 text-white'
                  : 'bg-gray-800 text-gray-400 hover:text-white hover:bg-gray-700'
              }`}
            >
              Custom…
            </button>
          </div>
          {useCustomLabel && (
            <input
              type="text"
              value={customLabel}
              onChange={(e) => setCustomLabel(e.target.value)}
              placeholder="e.g. Two Pointers, BFS, etc."
              autoFocus
              className="w-full bg-gray-800 border border-gray-600 rounded-lg px-3 py-1.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-indigo-500"
            />
          )}
        </div>

        {/* Complexity fields */}
        <div className="grid grid-cols-2 gap-3 mb-4">
          <div>
            <label className="block text-xs font-medium text-gray-400 mb-1.5">
              Time complexity
            </label>
            <input
              type="text"
              value={timeComplexity}
              onChange={(e) => setTimeComplexity(e.target.value)}
              placeholder="e.g. O(n)"
              className="w-full bg-gray-800 border border-gray-600 rounded-lg px-3 py-1.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-indigo-500"
            />
          </div>
          <div>
            <label className="block text-xs font-medium text-gray-400 mb-1.5">
              Space complexity
            </label>
            <input
              type="text"
              value={spaceComplexity}
              onChange={(e) => setSpaceComplexity(e.target.value)}
              placeholder="e.g. O(1)"
              className="w-full bg-gray-800 border border-gray-600 rounded-lg px-3 py-1.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-indigo-500"
            />
          </div>
        </div>

        {error && (
          <p className="text-red-400 text-xs mb-3">{error}</p>
        )}

        {/* Actions */}
        <div className="flex gap-2 justify-end">
          <button
            onClick={onClose}
            disabled={isSaving}
            className="px-4 py-2 bg-gray-800 hover:bg-gray-700 text-gray-300 text-sm font-medium rounded-lg transition-colors disabled:opacity-40"
          >
            Cancel
          </button>
          <button
            onClick={() => void handleSave()}
            disabled={isSaving || !finalLabel}
            className="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-medium rounded-lg transition-colors disabled:opacity-40"
          >
            {isSaving ? 'Saving…' : 'Save Solution'}
          </button>
        </div>
      </div>
    </div>
  )
}
