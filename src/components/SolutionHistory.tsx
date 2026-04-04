import type { UserSolution } from '../types'

// ============================================================
// SolutionHistory — ranked list of saved solutions per question
// Shown in the Practice Mode left panel
// ============================================================

interface SolutionHistoryProps {
  solutions: UserSolution[]
  onMarkBest: (id: string) => void
  onView: (solution: UserSolution) => void
  onDelete: (id: string) => void
  isLoading?: boolean
}

const COMPLEXITY_COLORS: Record<string, string> = {
  'O(1)': 'text-green-400',
  'O(log n)': 'text-green-300',
  'O(n)': 'text-yellow-400',
  'O(n log n)': 'text-yellow-300',
  'O(n²)': 'text-orange-400',
  'O(2^n)': 'text-red-400',
}

function ComplexityBadge({ value }: { value: string | null }) {
  if (!value) return <span className="text-gray-600 text-xs">—</span>
  const color = COMPLEXITY_COLORS[value] ?? 'text-gray-400'
  return <span className={`text-xs font-mono ${color}`}>{value}</span>
}

export function SolutionHistory({
  solutions,
  onMarkBest,
  onView,
  onDelete,
  isLoading = false,
}: SolutionHistoryProps) {
  if (isLoading) {
    return (
      <div className="text-gray-600 text-xs px-1 py-2 animate-pulse">
        Loading solutions…
      </div>
    )
  }

  if (solutions.length === 0) {
    return (
      <div className="text-gray-600 text-xs px-1 py-2">
        No saved solutions yet.{' '}
        <span className="text-gray-500">Write code and click Save Solution to track your progress.</span>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-1">
      {solutions.map((sol) => (
        <div
          key={sol.id}
          className={`rounded-lg border px-3 py-2 transition-colors ${
            sol.isBest
              ? 'border-indigo-700/60 bg-indigo-950/40'
              : 'border-gray-800 bg-gray-900/40'
          }`}
        >
          {/* Header row */}
          <div className="flex items-center justify-between gap-2 mb-1">
            <div className="flex items-center gap-1.5 min-w-0">
              <span className="text-gray-500 text-xs tabular-nums shrink-0">#{sol.rank}</span>
              <span className="text-sm font-medium text-gray-200 truncate">{sol.label}</span>
              {sol.isBest && (
                <span className="shrink-0 text-[10px] font-semibold px-1.5 py-0.5 rounded-full bg-indigo-600/40 text-indigo-300 border border-indigo-700/50">
                  BEST
                </span>
              )}
            </div>

            {/* Actions */}
            <div className="flex items-center gap-1 shrink-0">
              <button
                onClick={() => onView(sol)}
                className="text-[10px] text-gray-500 hover:text-indigo-400 transition-colors"
                title="View code"
              >
                View
              </button>
              {!sol.isBest && (
                <button
                  onClick={() => onMarkBest(sol.id)}
                  className="text-[10px] text-gray-500 hover:text-green-400 transition-colors"
                  title="Mark as best solution"
                >
                  Set Best
                </button>
              )}
              <button
                onClick={() => onDelete(sol.id)}
                className="text-[10px] text-gray-500 hover:text-red-400 transition-colors"
                title="Delete solution"
              >
                ✕
              </button>
            </div>
          </div>

          {/* Complexity row */}
          <div className="flex items-center gap-3">
            <span className="text-[10px] text-gray-600">Time:</span>
            <ComplexityBadge value={sol.timeComplexity} />
            <span className="text-[10px] text-gray-600">Space:</span>
            <ComplexityBadge value={sol.spaceComplexity} />
          </div>

          {/* AI notes */}
          {sol.aiNotes && (
            <p className="text-[10px] text-gray-500 mt-1 leading-relaxed line-clamp-2">
              {sol.aiNotes}
            </p>
          )}
        </div>
      ))}
    </div>
  )
}

// ── Code viewer overlay ───────────────────────────────────────

interface SolutionViewerProps {
  solution: UserSolution | null
  onClose: () => void
}

export function SolutionViewer({ solution, onClose }: SolutionViewerProps) {
  if (!solution) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />
      <div className="relative bg-gray-900 border border-gray-700 rounded-xl shadow-2xl w-full max-w-2xl mx-4 flex flex-col max-h-[80vh]">
        {/* Header */}
        <div className="flex items-center justify-between px-5 py-3 border-b border-gray-800">
          <div className="flex items-center gap-2">
            <span className="text-gray-500 text-sm">#{solution.rank}</span>
            <h2 className="text-base font-semibold text-white">{solution.label}</h2>
            {solution.isBest && (
              <span className="text-[10px] font-semibold px-1.5 py-0.5 rounded-full bg-indigo-600/40 text-indigo-300 border border-indigo-700/50">
                BEST
              </span>
            )}
          </div>
          <div className="flex items-center gap-4 text-xs text-gray-500">
            {solution.timeComplexity && <span>Time: <span className="text-yellow-400 font-mono">{solution.timeComplexity}</span></span>}
            {solution.spaceComplexity && <span>Space: <span className="text-yellow-400 font-mono">{solution.spaceComplexity}</span></span>}
            <button onClick={onClose} className="text-gray-500 hover:text-white transition-colors text-base ml-2">✕</button>
          </div>
        </div>

        {/* Code */}
        <div className="flex-1 overflow-y-auto p-5">
          <pre className="text-sm text-gray-200 font-mono whitespace-pre-wrap leading-relaxed">
            {solution.code}
          </pre>
        </div>

        {/* AI notes */}
        {solution.aiNotes && (
          <div className="px-5 py-3 border-t border-gray-800 bg-gray-950/50">
            <p className="text-xs text-gray-500 font-semibold uppercase tracking-wider mb-1">AI Notes</p>
            <p className="text-sm text-gray-400 leading-relaxed">{solution.aiNotes}</p>
          </div>
        )}
      </div>
    </div>
  )
}
