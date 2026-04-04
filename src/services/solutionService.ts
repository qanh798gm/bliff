import { supabase } from '../lib/supabase'
import type { UserSolutionRow } from '../types/database'
import type { UserSolution, PreviousSolutionContext } from '../types'

// ============================================================
// solutionService — CRUD for user_solutions table
// Supports multi-solution tracking per question per user
// ============================================================

// ── Row → domain type mapper ─────────────────────────────────

function rowToSolution(row: UserSolutionRow): UserSolution {
  return {
    id: row.id,
    questionId: row.question_id,
    attemptId: row.attempt_id,
    label: row.label,
    rank: row.rank,
    code: row.code,
    language: row.language,
    timeComplexity: row.time_complexity,
    spaceComplexity: row.space_complexity,
    aiNotes: row.ai_notes,
    isBest: row.is_best,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

// ── Fetch all solutions for a question (current user) ────────

export async function fetchSolutionsForQuestion(
  questionId: string
): Promise<UserSolution[]> {
  const { data, error } = await supabase
    .from('user_solutions')
    .select('*')
    .eq('question_id', questionId)
    .order('rank', { ascending: true })

  if (error) throw error
  return (data as UserSolutionRow[]).map(rowToSolution)
}

// ── Fetch solutions as PromptContext format ───────────────────
// includecode: true for Practice Mode, false for Interview Mode

export async function fetchSolutionsForPrompt(
  questionId: string,
  includeCode = false
): Promise<PreviousSolutionContext[]> {
  const solutions = await fetchSolutionsForQuestion(questionId)
  return solutions.map((s) => ({
    label: s.label,
    rank: s.rank,
    timeComplexity: s.timeComplexity,
    spaceComplexity: s.spaceComplexity,
    aiNotes: s.aiNotes,
    ...(includeCode ? { code: s.code } : {}),
  }))
}

// ── Save a new solution ───────────────────────────────────────

export interface SaveSolutionParams {
  questionId: string
  label: string
  code: string
  language?: string
  timeComplexity?: string
  spaceComplexity?: string
  attemptId?: string
}

export async function saveSolution(params: SaveSolutionParams): Promise<UserSolution> {
  // Get the next rank for this user+question
  const { data: existing, error: fetchError } = await supabase
    .from('user_solutions')
    .select('rank')
    .eq('question_id', params.questionId)
    .order('rank', { ascending: false })
    .limit(1)

  if (fetchError) throw fetchError

  const nextRank = existing && existing.length > 0 ? (existing[0] as { rank: number }).rank + 1 : 1

  // First solution is always "best" by default
  const isBest = nextRank === 1

  const { data, error } = await supabase
    .from('user_solutions')
    .insert({
      question_id: params.questionId,
      attempt_id: params.attemptId ?? null,
      label: params.label,
      rank: nextRank,
      code: params.code,
      language: params.language ?? 'javascript',
      time_complexity: params.timeComplexity ?? null,
      space_complexity: params.spaceComplexity ?? null,
      is_best: isBest,
    })
    .select()
    .single()

  if (error) throw error
  return rowToSolution(data as UserSolutionRow)
}

// ── Update solution metadata ──────────────────────────────────

export interface UpdateSolutionParams {
  label?: string
  code?: string
  timeComplexity?: string
  spaceComplexity?: string
  aiNotes?: string
}

export async function updateSolution(
  id: string,
  updates: UpdateSolutionParams
): Promise<void> {
  const { error } = await supabase
    .from('user_solutions')
    .update({
      ...(updates.label !== undefined && { label: updates.label }),
      ...(updates.code !== undefined && { code: updates.code }),
      ...(updates.timeComplexity !== undefined && { time_complexity: updates.timeComplexity }),
      ...(updates.spaceComplexity !== undefined && { space_complexity: updates.spaceComplexity }),
      ...(updates.aiNotes !== undefined && { ai_notes: updates.aiNotes }),
    })
    .eq('id', id)

  if (error) throw error
}

// ── Mark a solution as "best" ─────────────────────────────────
// Clears is_best on all other solutions for this question, sets it on the chosen one

export async function markAsBest(id: string, questionId: string): Promise<void> {
  // Clear all
  const { error: clearError } = await supabase
    .from('user_solutions')
    .update({ is_best: false })
    .eq('question_id', questionId)

  if (clearError) throw clearError

  // Set chosen
  const { error: setError } = await supabase
    .from('user_solutions')
    .update({ is_best: true })
    .eq('id', id)

  if (setError) throw setError
}

// ── Delete a solution ─────────────────────────────────────────

export async function deleteSolution(id: string): Promise<void> {
  const { error } = await supabase
    .from('user_solutions')
    .delete()
    .eq('id', id)

  if (error) throw error
}

// ── Add AI notes to a solution (called after AI analysis) ────

export async function addAiNotes(id: string, aiNotes: string): Promise<void> {
  const { error } = await supabase
    .from('user_solutions')
    .update({ ai_notes: aiNotes })
    .eq('id', id)

  if (error) throw error
}
