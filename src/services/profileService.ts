import { supabase } from '../lib/supabase'
import type { UserProfileRow, UserTopicStatsRow, TopicRow, TopicStatRow } from '../types/database'

// ── Upsert practice stats for a topic ───────────────────────
// Called by usePractice after each "Run Tests" execution.
// Increments practice_attempts by 1; if `solved` is true also increments practice_solved.
export async function upsertPracticeStats(
  topicId: string,
  solved: boolean
): Promise<void> {
  // Try to fetch the existing row first
  const { data: existing } = await supabase
    .from('user_topic_stats')
    .select('id, practice_attempts, practice_solved')
    .eq('topic_id', topicId)
    .maybeSingle()

  if (existing) {
    const { error } = await supabase
      .from('user_topic_stats')
      .update({
        practice_attempts: existing.practice_attempts + 1,
        practice_solved: solved ? existing.practice_solved + 1 : existing.practice_solved,
        last_attempted_at: new Date().toISOString(),
      })
      .eq('id', existing.id)
    if (error) throw error
  } else {
    const { error } = await supabase
      .from('user_topic_stats')
      .insert({
        topic_id: topicId,
        practice_attempts: 1,
        practice_solved: solved ? 1 : 0,
        last_attempted_at: new Date().toISOString(),
      })
    if (error) throw error
  }
}

// ── Get the single user profile ─────────────────────────────
export async function getProfile(): Promise<UserProfileRow | null> {
  const { data, error } = await supabase
    .from('user_profile')
    .select('*')
    .limit(1)
    .maybeSingle()

  if (error) throw error
  return data
}

// ── Update user profile fields ───────────────────────────────
export async function updateProfile(
  updates: Partial<Omit<UserProfileRow, 'id' | 'created_at'>>
): Promise<UserProfileRow> {
  const profile = await getProfile()
  if (!profile) throw new Error('No user profile found')

  const { data, error } = await supabase
    .from('user_profile')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', profile.id)
    .select()
    .single()

  if (error) throw error
  return data
}

// ── Update streak after a session ───────────────────────────
export async function updateStreak(): Promise<void> {
  const profile = await getProfile()
  if (!profile) return

  const today = new Date().toISOString().split('T')[0]
  const lastDate = profile.last_session_date

  let newStreak = profile.current_streak
  if (!lastDate) {
    newStreak = 1
  } else {
    const daysDiff = Math.floor(
      (new Date(today).getTime() - new Date(lastDate).getTime()) / 86_400_000
    )
    if (daysDiff === 1) {
      newStreak += 1 // consecutive day
    } else if (daysDiff === 0) {
      // same day, no change
    } else {
      newStreak = 1 // streak broken
    }
  }

  const longestStreak = Math.max(newStreak, profile.longest_streak)

  await updateProfile({
    current_streak: newStreak,
    longest_streak: longestStreak,
    last_session_date: today,
  })
}

// ── Get all topic stats with topic metadata ──────────────────
export interface TopicStatsWithMeta extends UserTopicStatsRow {
  topic: TopicRow
}

export async function getTopicStats(): Promise<TopicStatsWithMeta[]> {
  const { data, error } = await supabase
    .from('user_topic_stats')
    .select('*, topic:topics(*)')
    .order('weight', { ascending: false })

  if (error) throw error
  return (data ?? []) as TopicStatsWithMeta[]
}

// ── Build profile summary string for LLM prompt ─────────────
export async function buildProfileSummary(): Promise<string> {
  const [profile, topicStats] = await Promise.all([getProfile(), getTopicStats()])
  if (!profile) return 'Single user, no profile data loaded.'

  const masteredTopics = topicStats
    .filter(s => s.mastery_level === 'mastered')
    .map(s => s.topic.name)

  const weakTopics = topicStats
    .filter(s => s.mastery_level === 'beginner' && s.total_attempts > 0)
    .map(s => s.topic.name)

  const lines = [
    `Name: ${profile.display_name}`,
    `Experience: ${profile.experience_years} years as ${profile.primary_role}`,
    `Target companies: ${profile.target_companies.join(', ')}`,
    `Preferred languages: ${profile.preferred_languages.join(', ')}`,
    `Current streak: ${profile.current_streak} days`,
    masteredTopics.length > 0 ? `Mastered topics: ${masteredTopics.join(', ')}` : '',
    weakTopics.length > 0 ? `Needs work: ${weakTopics.join(', ')}` : '',
    profile.strengths.length > 0 ? `Known strengths: ${profile.strengths.join(', ')}` : '',
    profile.weaknesses.length > 0 ? `Known weaknesses: ${profile.weaknesses.join(', ')}` : '',
    profile.notes ? `Notes: ${profile.notes}` : '',
  ].filter(Boolean)

  return lines.join('\n')
}

// ── Load profile ─────────────────────────────────────────────
export async function loadProfile(userId: string): Promise<UserProfileRow | null> {
  const { data, error } = await supabase
    .from('user_profile')
    .select('*')
    .eq('id', userId)
    .single()

  if (error?.code === 'PGRST116') return null // not found
  if (error) throw error
  return data as UserProfileRow
}

// ── Load topic stats (joined with topic name) ────────────────
export async function loadTopicStats(userId: string): Promise<TopicStatRow[]> {
  const { data, error } = await supabase
    .from('user_topic_stats')
    .select('topic_id, attempts_count, solved_count, mastery_level, last_attempted_at, topics(name)')
    .eq('user_id', userId)

  if (error) throw error
  if (!data) return []

  return (data as unknown as Array<{
    topic_id: string
    attempts_count: number
    solved_count: number
    mastery_level: string
    last_attempted_at: string | null
    topics: { name: string } | null
  }>).map(row => ({
    topic_id: row.topic_id,
    topic_name: row.topics?.name ?? row.topic_id,
    attempts_count: row.attempts_count,
    solved_count: row.solved_count,
    mastery_score: masteryLevelToScore(row.mastery_level),
    last_attempted_at: row.last_attempted_at,
  }))
}

function masteryLevelToScore(level: string): number {
  switch (level) {
    case 'not_started': return 0
    case 'learning': return 0.2
    case 'practicing': return 0.45
    case 'proficient': return 0.7
    case 'mastered': return 0.95
    default: return 0
  }
}

// ── Create or update full profile (used by onboarding) ──────
export async function saveProfile(
  userId: string,
  data: {
    display_name: string
    experience_level: string
    interview_focus: string
    target_companies: string[]
    weekly_goal: number
    onboarding_completed: boolean
  }
): Promise<void> {
  const { error } = await supabase
    .from('user_profile')
    .upsert(
      {
        id: userId,
        display_name: data.display_name,
        experience_level: data.experience_level,
        interview_focus: data.interview_focus,
        target_companies: data.target_companies,
        weekly_goal: data.weekly_goal,
        onboarding_completed: data.onboarding_completed,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'id' }
    )

  if (error) throw error
}
