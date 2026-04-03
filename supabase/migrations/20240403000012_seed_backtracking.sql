-- ============================================================
-- Seed: Backtracking questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'backtracking'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Subsets', 'subsets', 'medium', 'blind75',
    'Given an integer array nums of unique elements, return all possible subsets (the power set). The solution set must not contain duplicate subsets. Return the solution in any order.',
    '[{"input":"nums = [1,2,3]","output":"[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]"},{"input":"nums = [0]","output":"[[],[0]]"}]',
    array['1 <= nums.length <= 10','All the numbers of nums are unique.','-10 <= nums[i] <= 10'],
    array['Use backtracking: at each index, decide to include or exclude.','Start with an empty subset and explore both choices.','Add current subset to result at every recursive call.'],
    'Backtracking: at each index choose include/exclude. Add subset at each node.',
    'O(2^n)', 'O(n)',
    array['backtracking','array'], 'subsets',
    'function subsets(nums) { }', 78
  ),
  (
    'Combination Sum', 'combination-sum', 'medium', 'blind75',
    'Given an array of distinct integers candidates and a target integer target, return a list of all unique combinations of candidates where the chosen numbers sum to target. The same number may be chosen from candidates an unlimited number of times. The combinations may be returned in any order.',
    '[{"input":"candidates = [2,3,6,7], target = 7","output":"[[2,2,3],[7]]"},{"input":"candidates = [2,3], target = 6","output":"[[2,2,2],[3,3]]"}]',
    array['1 <= candidates.length <= 30','2 <= candidates[i] <= 40','All elements of candidates are distinct.','1 <= target <= 40'],
    array['Use backtracking. At each step, try each candidate starting from current index.','Subtract candidate from target as you recurse.','When target == 0, add current combination to results.'],
    'Backtracking: try each candidate from current index, subtract from target, recurse.',
    'O(2^t/m) where t = target, m = min candidate', 'O(t/m)',
    array['backtracking','array'], 'combinationSum',
    'function combinationSum(candidates, target) { }', 39
  ),
  (
    'Combination Sum II', 'combination-sum-ii', 'medium', 'neetcode150',
    'Given a collection of candidate numbers (candidates) and a target number (target), find all unique combinations in candidates where the candidate numbers sum to target. Each number in candidates may only be used once in the combination. The solution set must not contain duplicate combinations.',
    '[{"input":"candidates = [10,1,2,7,6,1,5], target = 8","output":"[[1,1,6],[1,2,5],[1,7],[2,6]]"},{"input":"candidates = [2,5,2,1,2], target = 5","output":"[[1,2,2],[5]]"}]',
    array['1 <= candidates.length <= 100','1 <= candidates[i] <= 50','1 <= target <= 30'],
    array['Sort candidates first to handle duplicates.','Skip duplicates at the same recursion level: if i > start && candidates[i] == candidates[i-1], skip.','Each element can only be used once, so start from i+1 in recursion.'],
    'Sort + backtracking. Skip duplicate values at same level. Use each element at most once.',
    'O(2^n)', 'O(n)',
    array['backtracking','sorting','array'], 'combinationSum2',
    'function combinationSum2(candidates, target) { }', 40
  ),
  (
    'Permutations', 'permutations', 'medium', 'blind75',
    'Given an array nums of distinct integers, return all the possible permutations. You can return the answer in any order.',
    '[{"input":"nums = [1,2,3]","output":"[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]"},{"input":"nums = [0,1]","output":"[[0,1],[1,0]]"},{"input":"nums = [1]","output":"[[1]]"}]',
    array['1 <= nums.length <= 6','-10 <= nums[i] <= 10','All the integers of nums are unique.'],
    array['Use backtracking with a visited array or by swapping elements.','At each level, try each unused number.','When current permutation length == nums.length, add to results.'],
    'Backtracking: track used elements. When perm is complete (length n), add to result.',
    'O(n! * n)', 'O(n)',
    array['backtracking','array'], 'permute',
    'function permute(nums) { }', 46
  ),
  (
    'Subsets II', 'subsets-ii', 'medium', 'neetcode150',
    'Given an integer array nums that may contain duplicates, return all possible subsets (the power set). The solution set must not contain duplicate subsets. Return the solution in any order.',
    '[{"input":"nums = [1,2,2]","output":"[[],[1],[1,2],[1,2,2],[2],[2,2]]"},{"input":"nums = [0]","output":"[[],[0]]"}]',
    array['1 <= nums.length <= 10','-10 <= nums[i] <= 10'],
    array['Sort nums first.','Use backtracking same as Subsets.','Skip duplicate elements at the same recursion level: if i > start && nums[i] == nums[i-1], skip.'],
    'Sort + backtracking. Skip duplicates at same recursion level.',
    'O(2^n)', 'O(n)',
    array['backtracking','sorting','array'], 'subsetsWithDup',
    'function subsetsWithDup(nums) { }', 90
  ),
  (
    'Word Search', 'word-search', 'medium', 'blind75',
    'Given an m x n grid of characters board and a string word, return true if word exists in the grid. The word can be constructed from letters of sequentially adjacent cells, where adjacent cells are horizontally or vertically neighboring. The same letter cell may not be used more than once.',
    '[{"input":"board = [[\"A\",\"B\",\"C\",\"E\"],[\"S\",\"F\",\"C\",\"S\"],[\"A\",\"D\",\"E\",\"E\"]], word = \"ABCCED\"","output":"true"},{"input":"board = [[\"A\",\"B\",\"C\",\"E\"],[\"S\",\"F\",\"C\",\"S\"],[\"A\",\"D\",\"E\",\"E\"]], word = \"SEE\"","output":"true"},{"input":"board = [[\"A\",\"B\",\"C\",\"E\"],[\"S\",\"F\",\"C\",\"S\"],[\"A\",\"D\",\"E\",\"E\"]], word = \"ABCB\"","output":"false"}]',
    array['m == board.length','n = board[i].length','1 <= m, n <= 6','1 <= word.length <= 15','board and word consists of only lowercase and uppercase English letters.'],
    array['DFS + backtracking from each cell.','Mark cell as visited (e.g., set to #) before recursing, unmark after.','If current char matches, recurse in 4 directions for next char.'],
    'DFS backtracking: mark visited, explore 4 dirs, unmark on return.',
    'O(m * n * 4^L) where L = word length', 'O(L)',
    array['backtracking','dfs','matrix'], 'exist',
    'function exist(board, word) { }', 79
  ),
  (
    'Palindrome Partitioning', 'palindrome-partitioning', 'medium', 'blind75',
    'Given a string s, partition s such that every substring of the partition is a palindrome. Return all possible palindrome partitioning of s.',
    '[{"input":"s = \"aab\"","output":"[[\"a\",\"a\",\"b\"],[\"aa\",\"b\"]]"},{"input":"s = \"a\"","output":"[[\"a\"]]"}]',
    array['1 <= s.length <= 16','s contains only lowercase English letters.'],
    array['Backtracking: at each position, try all substrings starting there.','If the substring is a palindrome, recurse on the remainder.','Add to result when you reach the end of the string.'],
    'Backtracking: try each prefix, check if palindrome, recurse on suffix.',
    'O(2^n * n)', 'O(n)',
    array['backtracking','string','dynamic-programming'], 'partition',
    'function partition(s) { }', 131
  ),
  (
    'Letter Combinations of a Phone Number', 'letter-combinations-phone', 'medium', 'blind75',
    'Given a string containing digits from 2-9 inclusive, return all possible letter combinations that the number could represent. Return the answer in any order.',
    '[{"input":"digits = \"23\"","output":"[\"ad\",\"ae\",\"af\",\"bd\",\"be\",\"bf\",\"cd\",\"ce\",\"cf\"]"},{"input":"digits = \"\"","output":"[]"},{"input":"digits = \"2\"","output":"[\"a\",\"b\",\"c\"]"}]',
    array['0 <= digits.length <= 4','digits[i] is a digit in the range [''2'', ''9''].'],
    array['Map each digit to its letters.','Backtracking: for each digit, try each letter and recurse on remaining digits.','When combination length equals digits length, add to result.'],
    'Backtracking with digit-to-letters map. Try each letter per digit, recurse.',
    'O(4^n * n)', 'O(n)',
    array['backtracking','string'], 'letterCombinations',
    'function letterCombinations(digits) { }', 17
  ),
  (
    'N-Queens', 'n-queens', 'hard', 'blind75',
    'The n-queens puzzle is the problem of placing n queens on an n x n chessboard such that no two queens attack each other. Given an integer n, return all distinct solutions to the n-queens puzzle.',
    '[{"input":"n = 4","output":"[[\".Q..\",\"...Q\",\"Q...\",\"..Q.\"],[\".Q..\",\"...Q\",\"Q...\",\"..Q.\"]]"},{"input":"n = 1","output":"[[\"Q\"]]"}]',
    array['1 <= n <= 9'],
    array['Place queens row by row using backtracking.','Track which columns, diagonals (row-col), and anti-diagonals (row+col) are attacked.','If a position is safe, place queen and recurse to next row.'],
    'Backtrack row by row. Track attacked cols, diags, anti-diags with sets.',
    'O(n!)', 'O(n²)',
    array['backtracking','array'], 'solveNQueens',
    'function solveNQueens(n) { }', 51
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
