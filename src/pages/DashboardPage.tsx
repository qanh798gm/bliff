import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  RadarChart, Radar, PolarGrid, PolarAngleAxis,
  ResponsiveContainer, Tooltip,
} from 'recharts'
import { useAuth } from '../contexts/AuthContext'
import { loadProfile, loadTopicStats } from '../services/profileService'
import type { UserProfileRow, TopicStatRow } from '../types/database'

// ============================================================
// DashboardPage — progress overview
// ============================================================

interface RadarDatum {
  topic: string
  score: number
  fullMark: number
}

function masteryToScore(mastery: number): number {
  // mastery is 0–1, map to 0–100 for display
  return Math.round(mastery * 100)
}

function buildRadarData(stats: TopicStatRow[]): RadarDatum[] {
  return stats
    .filter(s => s.attempts_count > 0)
    .map(s => ({
      topic: s.topic_name.replace('Frontend: ', 'FE: '),
      score: masteryToScore(s.mastery_score),
      fullMark: 100,
    }))
}

function StreakBadge({ streak }: { streak: number }) {
  if (streak === 0) return null
  return (
    <div className="flex items-center gap-1.5 bg-orange-950/50 border border-orange-800/50 rounded-full px-3 py-1">
      <span className="text-lg">🔥</span>
      <span className="text-orange-300 text-sm font-semibold">{streak} day streak</span>
    </div>
  )
}

function StatCard({ label, value, sub }: { label: string; value: string | number; sub?: string }) {
  return (
    <div className="bg-gray-900 border border-gray-800 rounded-xl p-4 text-center">
      <div className="text-2xl font-bold text-white">{value}</div>
      <div className="text-xs text-gray-400 mt-0.5">{label}</div>
      {sub && <div className="text-xs text-gray-600 mt-0.5">{sub}</div>}
    </div>
  )
}

export function DashboardPage() {
  const { user, signOut } = useAuth()
  const navigate = useNavigate()
  const [profile, setProfile] = useState<UserProfileRow | null>(null)
  const [stats, setStats] = useState<TopicStatRow[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    if (!user) return
    Promise.all([loadProfile(user.id), loadTopicStats(user.id)])
      .then(([prof, topicStats]) => {
        setProfile(prof)
        setStats(topicStats)
      })
      .finally(() => setIsLoading(false))
  }, [user])

  const radarData = buildRadarData(stats)
  const totalAttempts = stats.reduce((sum, s) => sum + s.attempts_count, 0)
  const totalSolved = stats.reduce((sum, s) => sum + s.solved_count, 0)
  const weakTopics = stats
    .filter(s => s.attempts_count > 0)
    .sort((a, b) => a.mastery_score - b.mastery_score)
    .slice(0, 3)

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <div className="text-gray-500 text-sm animate-pulse">Loading dashboard…</div>
      </div>
    )
  }

  const displayName = profile?.display_name ?? user?.email?.split('@')[0] ?? 'Candidate'

  return (
    <div className="min-h-screen bg-gray-950 text-white">
      {/* Nav */}
      <nav className="border-b border-gray-800 px-6 py-3 flex items-center justify-between">
        <h1 className="text-xl font-bold">
          bli<span className="text-indigo-400">ff</span>
        </h1>
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate('/questions')}
            className="text-sm text-gray-400 hover:text-white transition-colors"
          >
            Questions
          </button>
          <button
            onClick={() => navigate('/history')}
            className="text-sm text-gray-400 hover:text-white transition-colors"
          >
            History
          </button>
          <button
            onClick={() => navigate('/llm-test')}
            className="text-sm text-gray-600 hover:text-gray-400 transition-colors"
            title="LLM API health check"
          >
            ⚙ API
          </button>
          <button
            onClick={() => signOut()}
            className="text-sm text-gray-500 hover:text-gray-300 transition-colors"
          >
            Sign out
          </button>
        </div>
      </nav>

      <div className="max-w-5xl mx-auto px-6 py-8 space-y-8">
        {/* Header */}
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div>
            <h2 className="text-2xl font-bold">Hey, {displayName} 👋</h2>
            <p className="text-gray-400 text-sm mt-0.5">
              {totalAttempts === 0
                ? 'Ready to start your first practice session?'
                : `${totalAttempts} attempts · ${totalSolved} solved`}
            </p>
          </div>
          <div className="flex items-center gap-3">
            {profile && <StreakBadge streak={profile.current_streak} />}
            <button
              onClick={() => navigate('/interview')}
              className="px-5 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-medium rounded-lg text-sm transition-colors"
            >
              Start interview →
            </button>
          </div>
        </div>

        {/* Stats row */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
          <StatCard label="Total attempts" value={totalAttempts} />
          <StatCard label="Problems solved" value={totalSolved} />
          <StatCard
            label="Current streak"
            value={profile?.current_streak ?? 0}
            sub="days"
          />
          <StatCard
            label="Longest streak"
            value={profile?.longest_streak ?? 0}
            sub="days"
          />
        </div>

        {/* Main content */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Radar chart */}
          <div className="bg-gray-900 border border-gray-800 rounded-xl p-5">
            <h3 className="text-sm font-semibold text-gray-300 mb-4">Topic mastery</h3>
            {radarData.length === 0 ? (
              <div className="h-48 flex items-center justify-center text-gray-600 text-sm">
                Complete some sessions to see your radar chart
              </div>
            ) : (
              <ResponsiveContainer width="100%" height={260}>
                <RadarChart data={radarData}>
                  <PolarGrid stroke="#374151" />
                  <PolarAngleAxis
                    dataKey="topic"
                    tick={{ fill: '#9CA3AF', fontSize: 10 }}
                  />
                  <Radar
                    name="Mastery"
                    dataKey="score"
                    stroke="#6366F1"
                    fill="#6366F1"
                    fillOpacity={0.3}
                  />
                  <Tooltip
                    contentStyle={{ backgroundColor: '#111827', border: '1px solid #374151', borderRadius: 8 }}
                    formatter={(v: unknown) => [`${v}%`, 'Mastery']}
                  />
                </RadarChart>
              </ResponsiveContainer>
            )}
          </div>

          {/* Weak areas + topic list */}
          <div className="space-y-4">
            {/* Weak areas */}
            {weakTopics.length > 0 && (
              <div className="bg-gray-900 border border-gray-800 rounded-xl p-5">
                <h3 className="text-sm font-semibold text-gray-300 mb-3">Focus areas</h3>
                <div className="space-y-2">
                  {weakTopics.map(t => (
                    <div key={t.topic_id} className="flex items-center justify-between">
                      <span className="text-sm text-gray-300">{t.topic_name}</span>
                      <div className="flex items-center gap-2">
                        <div className="w-24 h-1.5 bg-gray-800 rounded-full overflow-hidden">
                          <div
                            className="h-full bg-indigo-500 rounded-full"
                            style={{ width: `${masteryToScore(t.mastery_score)}%` }}
                          />
                        </div>
                        <span className="text-xs text-gray-500 w-8 text-right">
                          {masteryToScore(t.mastery_score)}%
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* All topics */}
            <div className="bg-gray-900 border border-gray-800 rounded-xl p-5">
              <h3 className="text-sm font-semibold text-gray-300 mb-3">All topics</h3>
              <div className="space-y-2 max-h-48 overflow-y-auto pr-1">
                {stats.length === 0 ? (
                  <p className="text-gray-600 text-sm">No sessions yet</p>
                ) : (
                  stats.map(t => (
                    <div key={t.topic_id} className="flex items-center justify-between">
                      <span className="text-xs text-gray-400">{t.topic_name}</span>
                      <div className="flex items-center gap-2">
                        <span className="text-xs text-gray-600">{t.attempts_count} attempts</span>
                        <div className="w-16 h-1 bg-gray-800 rounded-full overflow-hidden">
                          <div
                            className="h-full bg-indigo-500 rounded-full"
                            style={{ width: `${masteryToScore(t.mastery_score)}%` }}
                          />
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Empty state CTA */}
        {totalAttempts === 0 && (
          <div className="bg-indigo-950/30 border border-indigo-800/40 rounded-xl p-6 text-center">
            <div className="text-3xl mb-3">🎯</div>
            <h3 className="text-white font-semibold mb-1">Ready for your first mock interview?</h3>
            <p className="text-gray-400 text-sm mb-4">
              Bliff will pick the best question for your level and track your progress over time.
            </p>
            <button
              onClick={() => navigate('/interview')}
              className="px-6 py-2 bg-indigo-600 hover:bg-indigo-500 text-white font-medium rounded-lg text-sm transition-colors"
            >
              Start now →
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
