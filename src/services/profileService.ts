import { supabase } from '../lib/supabase'
import type { UserProfileRow, UserTopicStatsRow, TopicRow } from '../types/database'

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
