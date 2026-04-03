import type { Question } from '../types'

// ============================================================
// QuestionPanel — displays the problem statement
// ============================================================

interface QuestionPanelProps {
  question: Question
}

const DIFFICULTY_COLORS = {
  easy: 'text-green-400 bg-green-900/20 border-green-800/30',
  medium: 'text-yellow-400 bg-yellow-900/20 border-yellow-800/30',
  hard: 'text-red-400 bg-red-900/20 border-red-800/30',
}

export function QuestionPanel({ question }: QuestionPanelProps) {
  return (
    <div className="flex flex-col gap-4 overflow-y-auto h-full text-sm">
      {/* Title + meta */}
      <div>
        <div className="flex items-center gap-2 flex-wrap mb-1">
          <h2 className="text-lg font-bold text-gray-100">{question.title}</h2>
          <span
            className={`px-2 py-0.5 rounded-full text-xs font-medium border ${
              DIFFICULTY_COLORS[question.difficulty]
            }`}
          >
            {question.difficulty.charAt(0).toUpperCase() + question.difficulty.slice(1)}
          </span>
          <span className="px-2 py-0.5 rounded-full text-xs font-medium text-indigo-400 bg-indigo-900/20 border border-indigo-800/30">
            {question.topic}
          </span>
        </div>
      </div>

      {/* Description */}
      <div className="text-gray-300 leading-relaxed whitespace-pre-wrap">
        <FormattedText text={question.description} />
      </div>

      {/* Examples */}
      <div>
        <h3 className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">
          Examples
        </h3>
        <div className="flex flex-col gap-3">
          {question.examples.map((ex, i) => (
            <div
              key={i}
              className="bg-gray-800/60 rounded-lg p-3 border border-gray-700/50 font-mono text-xs"
            >
              <div className="text-gray-400">
                <span className="text-gray-500">Input: </span>
                <span className="text-gray-200">{ex.input}</span>
              </div>
              <div className="text-gray-400">
                <span className="text-gray-500">Output: </span>
                <span className="text-green-300">{ex.output}</span>
              </div>
              {ex.explanation && (
                <div className="text-gray-500 mt-1 font-sans text-xs">
                  {ex.explanation}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Constraints */}
      <div>
        <h3 className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-2">
          Constraints
        </h3>
        <ul className="flex flex-col gap-1">
          {question.constraints.map((c, i) => (
            <li key={i} className="flex items-start gap-2 text-gray-400 font-mono text-xs">
              <span className="text-gray-600 mt-0.5">•</span>
              <span>{c}</span>
            </li>
          ))}
        </ul>
      </div>
    </div>
  )
}

// Renders backtick inline code in constraint/description text
function FormattedText({ text }: { text: string }) {
  const parts = text.split(/(`[^`]+`)/g)
  return (
    <>
      {parts.map((part, i) => {
        if (part.startsWith('`') && part.endsWith('`')) {
          return (
            <code
              key={i}
              className="bg-gray-800 text-orange-300 rounded px-1 py-0.5 text-xs font-mono"
            >
              {part.slice(1, -1)}
            </code>
          )
        }
        return <span key={i}>{part}</span>
      })}
    </>
  )
}
