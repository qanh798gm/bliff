import { supabase } from '../lib/supabase'
import type { QuestionRow, TopicRow } from '../types/database'

// ── Fetch all topics ────────────────────────────────────────
export async function fetchTopics(): Promise<TopicRow[]> {
  const { data, error } = await supabase
    .from('topics')
    .select('*')
    .order('display_order')

  if (error) throw error
  return data
}

// ── Fetch a single question by slug ─────────────────────────
export async function fetchQuestionBySlug(slug: string): Promise<QuestionRow> {
  const { data, error } = await supabase
    .from('questions')
    .select('*')
    .eq('slug', slug)
    .eq('is_active', true)
    .single()

  if (error) throw error
  return data
}

// ── Fetch a single question by id ───────────────────────────
export async function fetchQuestionById(id: string): Promise<QuestionRow> {
  const { data, error } = await supabase
    .from('questions')
    .select('*')
    .eq('id', id)
    .single()

  if (error) throw error
  return data
}

// ── Fetch questions for a topic ──────────────────────────────
export async function fetchQuestionsByTopic(
  topicSlug: string
): Promise<QuestionRow[]> {
  const { data, error } = await supabase
    .from('questions')
    .select('*, topics!inner(slug)')
    .eq('topics.slug', topicSlug)
    .eq('is_active', true)
    .order('difficulty')

  if (error) throw error
  return data
}

// ── Adaptive question selection ──────────────────────────────
// Picks the next question based on:
// 1. Topics with highest weight (weighted round-robin)
// 2. Within topic: prefer unsolved or lowest-score questions
// 3. Difficulty scaling based on mastery level
export async function selectNextQuestion(
  excludeIds: string[] = []
): Promise<QuestionRow | null> {
  // Get topic stats ordered by weight descending
  const { data: stats, error: statsError } = await supabase
    .from('user_topic_stats')
    .select('*, topics!inner(slug, category)')
    .order('weight', { ascending: false })

  if (statsError) throw statsError
  if (!stats || stats.length === 0) return null

  // Weighted random selection: pick from top 3 weighted topics
  const topTopics = stats.slice(0, 3)
  const totalWeight = topTopics.reduce((sum, s) => sum + s.weight, 0)
  let rand = Math.random() * totalWeight
  let chosenStat = topTopics[0]
  for (const stat of topTopics) {
    rand -= stat.weight
    if (rand <= 0) { chosenStat = stat; break }
  }

  // Map mastery level to difficulty preference
  const difficultyMap: Record<string, string[]> = {
    beginner:   ['easy', 'medium'],
    developing: ['easy', 'medium'],
    proficient: ['medium', 'hard'],
    mastered:   ['hard', 'medium'],
  }
  const preferredDifficulties = difficultyMap[chosenStat.mastery_level] ?? ['easy', 'medium']

  // Fetch questions from chosen topic with preferred difficulty
  let query = supabase
    .from('questions')
    .select('*')
    .eq('topic_id', chosenStat.topic_id)
    .eq('is_active', true)
    .in('difficulty', preferredDifficulties)

  if (excludeIds.length > 0) {
    query = query.not('id', 'in', `(${excludeIds.join(',')})`)
  }

  const { data: candidates, error: qError } = await query

  if (qError) throw qError
  if (!candidates || candidates.length === 0) {
    // Fallback: any active question not already attempted
    let fallbackQuery = supabase
      .from('questions')
      .select('*')
      .eq('is_active', true)

    if (excludeIds.length > 0) {
      fallbackQuery = fallbackQuery.not('id', 'in', `(${excludeIds.join(',')})`)
    }

    const { data: fallback, error: fbError } = await fallbackQuery.limit(20)
    if (fbError) throw fbError
    if (!fallback || fallback.length === 0) return null
    return fallback[Math.floor(Math.random() * fallback.length)]
  }

  // Random pick among candidates
  return candidates[Math.floor(Math.random() * candidates.length)]
}

// ── Update topic stats after an attempt ─────────────────────
export async function updateTopicStats(
  topicId: string,
  score: number,
  durationSeconds: number,
  status: 'solved' | 'partial' | 'gave_up'
): Promise<void> {
  const { data: existing, error: fetchError } = await supabase
    .from('user_topic_stats')
    .select('*')
    .eq('topic_id', topicId)
    .single()

  if (fetchError) throw fetchError

  const newTotal = existing.total_attempts + 1
  const newAvgScore = (existing.avg_score * existing.total_attempts + score) / newTotal
  const newAvgDuration =
    (existing.avg_duration_seconds * existing.total_attempts + durationSeconds) / newTotal

  const solvedCount = existing.solved_count + (status === 'solved' ? 1 : 0)
  const partialCount = existing.partial_count + (status === 'partial' ? 1 : 0)
  const gaveUpCount = existing.gave_up_count + (status === 'gave_up' ? 1 : 0)

  // Mastery thresholds: solved% and avg score
  const solvedRate = solvedCount / newTotal
  let mastery_level: string = existing.mastery_level
  if (solvedRate >= 0.8 && newAvgScore >= 8) mastery_level = 'mastered'
  else if (solvedRate >= 0.6 && newAvgScore >= 6) mastery_level = 'proficient'
  else if (solvedRate >= 0.3 && newAvgScore >= 4) mastery_level = 'developing'
  else mastery_level = 'beginner'

  // Weight: lower for mastered topics, higher for beginner (focus on weak areas)
  const weightMap: Record<string, number> = {
    beginner: 1.5, developing: 1.2, proficient: 0.9, mastered: 0.5,
  }
  const weight = weightMap[mastery_level] ?? 1.0

  const { error: updateError } = await supabase
    .from('user_topic_stats')
    .update({
      total_attempts: newTotal,
      solved_count: solvedCount,
      partial_count: partialCount,
      gave_up_count: gaveUpCount,
      avg_score: newAvgScore,
      avg_duration_seconds: newAvgDuration,
      last_attempted_at: new Date().toISOString(),
      mastery_level,
      weight,
    })
    .eq('topic_id', topicId)

  if (updateError) throw updateError
}
