import type { Question } from '../types'

// ============================================================
// Phase 1: Hardcoded question bank (Two Sum)
// Phase 2+: Will be replaced by Supabase queries
// ============================================================

export const TWO_SUM: Question = {
  id: 'two-sum',
  title: 'Two Sum',
  slug: 'two-sum',
  difficulty: 'easy',
  topic: 'Arrays',
  description: `Given an array of integers \`nums\` and an integer \`target\`, return the indices of the two numbers such that they add up to \`target\`.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

You can return the answer in any order.`,
  examples: [
    {
      input: 'nums = [2,7,11,15], target = 9',
      output: '[0,1]',
      explanation: 'Because nums[0] + nums[1] == 9, we return [0, 1].',
    },
    {
      input: 'nums = [3,2,4], target = 6',
      output: '[1,2]',
      explanation: 'Because nums[1] + nums[2] == 6, we return [1, 2].',
    },
    {
      input: 'nums = [3,3], target = 6',
      output: '[0,1]',
    },
  ],
  constraints: [
    '2 <= nums.length <= 10^4',
    '-10^9 <= nums[i] <= 10^9',
    '-10^9 <= target <= 10^9',
    'Only one valid answer exists.',
  ],
  hints: [
    'Think about what information you need to find the complement of each number.',
    'A hash map can give you O(1) lookup time. What would you store as the key and value?',
    'As you iterate, check if the complement (target - nums[i]) already exists in your map. If yes, you found your answer. If not, store nums[i] and its index.',
  ],
  expectedApproach:
    'Use a hash map to store each number and its index as you iterate. For each number, check if its complement (target - num) exists in the map. This gives O(n) time and O(n) space.',
  expectedTimeComplexity: 'O(n)',
  expectedSpaceComplexity: 'O(n)',
  testCases: [
    {
      id: 1,
      description: 'Basic case',
      input: { nums: [2, 7, 11, 15], target: 9 },
      expected: [0, 1],
    },
    {
      id: 2,
      description: 'Middle elements',
      input: { nums: [3, 2, 4], target: 6 },
      expected: [1, 2],
    },
    {
      id: 3,
      description: 'Duplicate elements',
      input: { nums: [3, 3], target: 6 },
      expected: [0, 1],
    },
    {
      id: 4,
      description: 'Negative numbers',
      input: { nums: [-1, -2, -3, -4, -5], target: -8 },
      expected: [2, 4],
    },
    {
      id: 5,
      description: 'Large array',
      input: {
        nums: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        target: 19,
      },
      expected: [8, 9],
    },
  ],
  entryPoint: 'twoSum',
  functionSignature: `/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number[]}
 */
function twoSum(nums, target) {
  // Your solution here
}`,
}

// Phase 1: single question. Phase 2 will fetch from Supabase.
export const QUESTION_BANK: Question[] = [TWO_SUM]

export function getQuestionById(id: string): Question | undefined {
  return QUESTION_BANK.find((q) => q.id === id)
}

export function getRandomQuestion(): Question {
  return QUESTION_BANK[Math.floor(Math.random() * QUESTION_BANK.length)] ?? TWO_SUM
}
