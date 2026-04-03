import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { supabase } from '../lib/supabase'

// ============================================================
// SessionHistoryPage — list of past sessions with scores
// ============================================================

interface SessionListItem {
  id: string
  started_at: string
  ended_at: string | null
  overall_score: number | null
  ai_feedback_summary: string | null
  // from joined attempt + question + topic
  question_title: string | null
  topic_name: string | null
  outcome: string | null
  duration_seconds: number | null
}

const OUTCOME_LABELS: Record<string, { label: string; color: string }> = {
  solved:  { label: 'Solved',   color: 'text-green-400' },
  partial: { label: 'Partial',  color: 'text-yellow-400' },
  gave_up: { label: 'Gave up',  color: 'text-red-400' },
  timeout: { label: 'Timeout',  color: 'text-orange-400' },
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric',
  })
}

function formatDuration(seconds: number | null): string {
  if (!seconds) return '—'
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return `${m}m ${s}s`
}

function ScoreBadge({ score }: { score: number | null }) {
  if (score === null) return <span className="text-gray-600 text-xs">—</span>
  const pct = Math.round(score * 100)
  const color = pct >= 80 ? 'text-green-400' : pct >= 50 ? 'text-yellow-400' : 'text-red-400'
  return <span className={`font-semibold text-sm ${color}`}>{pct}%</span>
}

export function SessionHistoryPage() {
  const { user } = useAuth()
  const navigate = useNavigate()
  const [sessions, setSessions] = useState<SessionListItem[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    if (!user) return

    const fetchSessions = async () => {
      const { data, error: err } = await supabase
        .from('sessions')
        .select(`
          id, started_at, ended_at, overall_score, ai_feedback_summary,
          attempts(
            status, duration_seconds,
            questions(title, topics(name))
          )
        `)
        .eq('user_id', user.id)
        .order('started_at', { ascending: false })
        .limit(50)

      if (err) { setError(err.message); return }

      type RawSession = {
        id: string
        started_at: string
        ended_at: string | null
        overall_score: number | null
        ai_feedback_summary: string | null
        attempts: Array<{
          status: string
          duration_seconds: number | null
          questions: { title: string; topics: { name: string } | null } | null
        }>
      }

      const mapped: SessionListItem[] = ((data ?? []) as unknown as RawSession[]).map(s => ({
        id: s.id,
        started_at: s.started_at,
        ended_at: s.ended_at,
        overall_score: s.overall_score,
        ai_feedback_summary: s.ai_feedback_summary,
        question_title: s.attempts?.[0]?.questions?.title ?? null,
        topic_name: s.attempts?.[0]?.questions?.topics?.name ?? null,
        outcome: s.attempts?.[0]?.status ?? null,
        duration_seconds: s.attempts?.[0]?.duration_seconds ?? null,
      }))

      setSessions(mapped)
    }

    fetchSessions().finally(() => setIsLoading(false))
  }, [user])

  return (
    <div className="min-h-screen bg-gray-950 text-white">
      {/* Nav */}
      <nav className="border-b border-gray-800 px-6 py-3 flex items-center gap-4">
        <button
          onClick={() => navigate('/dashboard')}
          className="text-gray-400 hover:text-white text-sm transition-colors"
        >
          ← Dashboard
        </button>
        <h1 className="text-lg font-semibold">Session history</h1>
      </nav>

      <div className="max-w-3xl mx-auto px-6 py-8">
        {isLoading ? (
          <div className="text-gray-500 text-sm animate-pulse">Loading sessions…</div>
        ) : error ? (
          <div className="text-red-400 text-sm">{error}</div>
        ) : sessions.length === 0 ? (
          <div className="text-center py-16">
            <div className="text-4xl mb-4">📋</div>
            <h2 className="text-white font-semibold mb-2">No sessions yet</h2>
            <p className="text-gray-400 text-sm mb-6">Complete your first mock interview to see it here.</p>
            <button
              onClick={() => navigate('/interview')}
              className="px-5 py-2 bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-medium rounded-lg transition-colors"
            >
              Start interview →
            </button>
          </div>
        ) : (
          <div className="space-y-3">
            {sessions.map(s => {
              const outcomeStyle = OUTCOME_LABELS[s.outcome ?? ''] ?? { label: s.outcome ?? '—', color: 'text-gray-400' }
              return (
                <div
                  key={s.id}
                  className="bg-gray-900 border border-gray-800 rounded-xl p-4 flex items-start justify-between gap-4"
                >
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="text-white font-medium text-sm truncate">
                        {s.question_title ?? 'Unknown question'}
                      </span>
                      {s.topic_name && (
                        <span className="text-xs text-indigo-400 bg-indigo-950/50 border border-indigo-800/50 rounded-full px-2 py-0.5">
                          {s.topic_name}
                        </span>
                      )}
                    </div>
                    <div className="text-xs text-gray-500 mt-1">
                      {formatDate(s.started_at)} · {formatDuration(s.duration_seconds)}
                    </div>
                    {s.ai_feedback_summary && (
                      <p className="text-xs text-gray-400 mt-1.5 line-clamp-2">{s.ai_feedback_summary}</p>
                    )}
                  </div>
                  <div className="flex flex-col items-end gap-1 shrink-0">
                    <ScoreBadge score={s.overall_score} />
                    <span className={`text-xs ${outcomeStyle.color}`}>{outcomeStyle.label}</span>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}
