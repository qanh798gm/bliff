import type { TestResult } from '../types'

// ============================================================
// TestResultsPanel — displays test case pass/fail results
// ============================================================

interface TestResultsPanelProps {
  results: TestResult[]
  isRunning: boolean
}

export function TestResultsPanel({ results, isRunning }: TestResultsPanelProps) {
  if (isRunning) {
    return (
      <div className="rounded-lg bg-gray-800 border border-gray-700 p-4">
        <div className="flex items-center gap-2 text-gray-400">
          <div className="w-4 h-4 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin" />
          <span className="text-sm">Running tests...</span>
        </div>
      </div>
    )
  }

  if (results.length === 0) return null

  const passed = results.filter((r) => r.passed).length
  const total = results.length
  const allPassed = passed === total

  return (
    <div className="rounded-lg bg-gray-800 border border-gray-700 overflow-hidden">
      {/* Header */}
      <div
        className={`px-4 py-2 flex items-center justify-between border-b border-gray-700 ${
          allPassed ? 'bg-green-900/30' : 'bg-red-900/30'
        }`}
      >
        <span className="text-sm font-medium text-gray-200">
          Test Results
        </span>
        <span
          className={`text-sm font-bold ${
            allPassed ? 'text-green-400' : 'text-red-400'
          }`}
        >
          {passed}/{total} passed
        </span>
      </div>

      {/* Individual results */}
      <div className="divide-y divide-gray-700/50">
        {results.map((r) => (
          <div key={r.id} className="px-4 py-3">
            <div className="flex items-center gap-2 mb-1">
              <span className={r.passed ? 'text-green-400' : 'text-red-400'}>
                {r.passed ? '✅' : '❌'}
              </span>
              <span className="text-sm font-medium text-gray-200">
                {r.description}
              </span>
              <span className="ml-auto text-xs text-gray-500">
                {r.durationMs.toFixed(1)}ms
              </span>
            </div>
            <div className="ml-6 space-y-0.5">
              <div className="text-xs text-gray-400 font-mono">
                <span className="text-gray-500">Input: </span>
                {JSON.stringify(r.input)}
              </div>
              <div className="text-xs text-gray-400 font-mono">
                <span className="text-gray-500">Expected: </span>
                {JSON.stringify(r.expected)}
              </div>
              {!r.passed && (
                <div className="text-xs font-mono">
                  {r.error ? (
                    <span className="text-red-400">
                      <span className="text-gray-500">Error: </span>
                      {r.error}
                    </span>
                  ) : (
                    <span className="text-orange-400">
                      <span className="text-gray-500">Got: </span>
                      {JSON.stringify(r.actual)}
                    </span>
                  )}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
