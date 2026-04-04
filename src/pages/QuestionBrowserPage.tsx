import { useEffect, useState, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { fetchTopics, fetchQuestionsByTopic } from '../services/questionService'
import type { TopicRow, QuestionRow, Difficulty } from '../types/database'

// ============================================================
// Question Browser Page
// Browse all questions by topic, filter by difficulty, search
// ============================================================

const DIFFICULTY_COLORS: Record<Difficulty, string> = {
  easy: 'text-green-400 bg-green-950/50 border-green-800/50',
  medium: 'text-yellow-400 bg-yellow-950/50 border-yellow-800/50',
  hard: 'text-red-400 bg-red-950/50 border-red-800/50',
}

const DIFFICULTY_ORDER: Difficulty[] = ['easy', 'medium', 'hard']

function DifficultyBadge({ difficulty }: { difficulty: Difficulty }) {
  return (
    <span
      className={`text-xs font-medium px-2 py-0.5 rounded-full border capitalize ${DIFFICULTY_COLORS[difficulty]}`}
    >
      {difficulty}
    </span>
  )
}

export function QuestionBrowserPage() {
  const navigate = useNavigate()

  const [topics, setTopics] = useState<TopicRow[]>([])
  const [activeTopic, setActiveTopic] = useState<TopicRow | null>(null)
  const [questions, setQuestions] = useState<QuestionRow[]>([])
  const [isLoadingTopics, setIsLoadingTopics] = useState(true)
  const [isLoadingQ, setIsLoadingQ] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Filters
  const [search, setSearch] = useState('')
  const [diffFilter, setDiffFilter] = useState<Difficulty | 'all'>('all')
  const [categoryFilter, setCategoryFilter] = useState<'all' | 'dsa' | 'frontend'>('all')

  // Load topics once
  useEffect(() => {
    fetchTopics()
      .then((rows) => {
        setTopics(rows)
        if (rows.length > 0) setActiveTopic(rows[0])
      })
      .catch((e: Error) => setError(e.message))
      .finally(() => setIsLoadingTopics(false))
  }, [])

  // Load questions when active topic changes
  useEffect(() => {
    if (!activeTopic) return
    setIsLoadingQ(true)
    setQuestions([])
    fetchQuestionsByTopic(activeTopic.id)
      .then(setQuestions)
      .catch((e: Error) => setError(e.message))
      .finally(() => setIsLoadingQ(false))
  }, [activeTopic])

  // Filtered questions
  const filtered = useMemo(() => {
    return questions.filter((q) => {
      if (diffFilter !== 'all' && q.difficulty !== diffFilter) return false
      if (search.trim() && !q.title.toLowerCase().includes(search.toLowerCase())) return false
      return true
    })
  }, [questions, diffFilter, search])

  const dsa = topics.filter((t) => t.category === 'dsa')
  const fe = topics.filter((t) => t.category === 'frontend')

  function renderTopicList(list: TopicRow[]) {
    return list.map((t) => (
      <button
        key={t.id}
        onClick={() => setActiveTopic(t)}
        className={`w-full text-left px-3 py-2 rounded-lg text-sm transition-colors ${
          activeTopic?.id === t.id
            ? 'bg-indigo-600 text-white'
            : 'text-gray-400 hover:text-white hover:bg-gray-800'
        }`}
      >
        {t.name}
      </button>
    ))
  }

  return (
    <div className="min-h-screen bg-gray-950 text-white flex flex-col">
      {/* Nav */}
      <nav className="border-b border-gray-800 px-6 py-3 flex items-center gap-4 flex-shrink-0">
        <button
          onClick={() => navigate('/dashboard')}
          className="text-gray-400 hover:text-white text-sm transition-colors"
        >
          ← Dashboard
        </button>
        <h1 className="text-lg font-semibold">Question Browser</h1>
        <span className="text-gray-600 text-sm ml-auto">
          {topics.length} topics
        </span>
      </nav>

      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar: topic list */}
        <aside className="w-56 border-r border-gray-800 flex flex-col overflow-hidden flex-shrink-0">
          {/* Category tabs */}
          <div className="flex border-b border-gray-800 text-xs">
            {(['all', 'dsa', 'frontend'] as const).map((cat) => (
              <button
                key={cat}
                onClick={() => setCategoryFilter(cat)}
                className={`flex-1 py-2 font-medium capitalize transition-colors ${
                  categoryFilter === cat
                    ? 'text-white border-b-2 border-indigo-500'
                    : 'text-gray-500 hover:text-gray-300'
                }`}
              >
                {cat === 'all' ? 'All' : cat === 'dsa' ? 'DSA' : 'Frontend'}
              </button>
            ))}
          </div>

          <div className="flex-1 overflow-y-auto py-2 px-2 space-y-0.5">
            {isLoadingTopics ? (
              <div className="text-gray-600 text-xs px-3 py-4 animate-pulse">Loading topics…</div>
            ) : (
              <>
                {(categoryFilter === 'all' || categoryFilter === 'dsa') && dsa.length > 0 && (
                  <>
                    {categoryFilter === 'all' && (
                      <p className="text-gray-600 text-[10px] font-semibold uppercase tracking-wider px-3 pt-2 pb-1">
                        DSA
                      </p>
                    )}
                    {renderTopicList(categoryFilter === 'all' ? dsa : topics.filter(t => t.category === 'dsa'))}
                  </>
                )}
                {(categoryFilter === 'all' || categoryFilter === 'frontend') && fe.length > 0 && (
                  <>
                    {categoryFilter === 'all' && (
                      <p className="text-gray-600 text-[10px] font-semibold uppercase tracking-wider px-3 pt-3 pb-1">
                        Frontend
                      </p>
                    )}
                    {renderTopicList(categoryFilter === 'all' ? fe : topics.filter(t => t.category === 'frontend'))}
                  </>
                )}
              </>
            )}
          </div>
        </aside>

        {/* Main: question list */}
        <main className="flex-1 flex flex-col overflow-hidden">
          {/* Toolbar */}
          <div className="flex items-center gap-3 px-5 py-3 border-b border-gray-800 flex-shrink-0">
            <input
              type="search"
              placeholder="Search questions…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="flex-1 bg-gray-900 border border-gray-700 rounded-lg px-3 py-1.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-indigo-500"
            />
            <div className="flex items-center gap-1">
              {(['all', ...DIFFICULTY_ORDER] as const).map((d) => (
                <button
                  key={d}
                  onClick={() => setDiffFilter(d)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors capitalize ${
                    diffFilter === d
                      ? 'bg-indigo-600 text-white'
                      : 'bg-gray-800 text-gray-400 hover:text-white'
                  }`}
                >
                  {d === 'all' ? 'All' : d}
                </button>
              ))}
            </div>
          </div>

          {/* List */}
          <div className="flex-1 overflow-y-auto">
            {error ? (
              <div className="text-red-400 text-sm px-5 py-8">{error}</div>
            ) : isLoadingQ ? (
              <div className="text-gray-500 text-sm px-5 py-8 animate-pulse">Loading questions…</div>
            ) : filtered.length === 0 ? (
              <div className="text-gray-500 text-sm px-5 py-8">
                {search || diffFilter !== 'all' ? 'No questions match your filters.' : 'No questions in this topic yet.'}
              </div>
            ) : (
              <table className="w-full text-sm">
                <thead>
                  <tr className="text-gray-500 text-xs border-b border-gray-800">
                    <th className="text-left px-5 py-2 font-medium w-8">#</th>
                    <th className="text-left px-2 py-2 font-medium">Title</th>
                    <th className="text-left px-2 py-2 font-medium w-24">Difficulty</th>
                    <th className="text-left px-2 py-2 font-medium w-24">Source</th>
                    <th className="px-5 py-2 w-36"></th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.map((q, idx) => (
                    <tr
                      key={q.id}
                      onClick={() => navigate(`/practice/${q.slug}`)}
                      className="border-b border-gray-800/50 hover:bg-gray-900/60 transition-colors group cursor-pointer"
                    >
                      <td className="px-5 py-3 text-gray-600 tabular-nums">{idx + 1}</td>
                      <td className="px-2 py-3">
                        <span className="text-white font-medium group-hover:text-indigo-300 transition-colors">
                          {q.title}
                        </span>
                        {q.tags && q.tags.length > 0 && (
                          <span className="ml-2 text-gray-600 text-xs">
                            {q.tags.slice(0, 2).join(', ')}
                          </span>
                        )}
                      </td>
                      <td className="px-2 py-3">
                        <DifficultyBadge difficulty={q.difficulty} />
                      </td>
                      <td className="px-2 py-3 text-gray-500 capitalize text-xs">
                        {q.source ?? '—'}
                      </td>
                      <td className="px-5 py-3 text-right">
                        {/* Stop propagation so individual buttons don't double-fire the row click */}
                        <div
                          className="flex items-center justify-end gap-1.5 opacity-0 group-hover:opacity-100 transition-all"
                          onClick={(e) => e.stopPropagation()}
                        >
                          <button
                            onClick={() => navigate(`/practice/${q.slug}`)}
                            className="px-2.5 py-1 bg-gray-700 hover:bg-gray-600 text-gray-200 text-xs font-medium rounded-lg transition-colors"
                          >
                            ▶ Practice
                          </button>
                          <button
                            onClick={() => navigate(`/interview/${q.slug}`)}
                            className="px-2.5 py-1 bg-indigo-700/60 hover:bg-indigo-600 text-indigo-200 text-xs font-medium rounded-lg transition-colors"
                          >
                            🎙 Interview
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>

          {/* Footer count */}
          {!isLoadingQ && filtered.length > 0 && (
            <div className="px-5 py-2 border-t border-gray-800 text-xs text-gray-600">
              Showing {filtered.length} of {questions.length} questions
            </div>
          )}
        </main>
      </div>
    </div>
  )
}
