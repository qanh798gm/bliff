import type { Question, TestCase } from '../types'
import type { QuestionRow } from '../types/database'

// ── Convert a Supabase QuestionRow to the local Question type ──
// The local Question type is used throughout the app for interview logic.
// The DB QuestionRow has snake_case fields; this maps them cleanly.
export function rowToQuestion(row: QuestionRow): Question {
  const testCases: TestCase[] = (row.test_cases ?? []).map((tc, i) => ({
    id: i + 1,
    description: tc.description ?? `Test ${i + 1}`,
    input: tc.input as Record<string, unknown>,
    expected: tc.expected,
    tier: tc.tier,
    orderIndependent: tc.orderIndependent,
  }))

  return {
    id: row.id,
    title: row.title,
    slug: row.slug,
    difficulty: row.difficulty,
    topic: row.topic_id, // will be overridden with topic name by callers if needed
    description: row.description,
    examples: row.examples ?? [],
    constraints: row.constraints ?? [],
    hints: row.hints ?? [],
    expectedApproach: row.expected_approach ?? '',
    expectedTimeComplexity: row.expected_time_complexity ?? 'O(?)',
    expectedSpaceComplexity: row.expected_space_complexity ?? 'O(?)',
    testCases,
    entryPoint: row.entry_point ?? 'solution',
    functionSignature: row.function_signature ?? 'function solution() { }',
  }
}
