-- ============================================================
-- Seed: Dynamic Programming Part 2 (2D DP, Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'dynamic-programming'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Unique Paths', 'unique-paths', 'medium', 'blind75',
    'There is a robot on an m x n grid. The robot is initially located at the top-left corner. The robot tries to move to the bottom-right corner. The robot can only move either down or right at any point in time. Given the two integers m and n, return the number of possible unique paths that the robot can take to reach the bottom-right corner.',
    '[{"input":"m = 3, n = 7","output":"28"},{"input":"m = 3, n = 2","output":"3"}]',
    array['1 <= m, n <= 100'],
    array['dp[i][j] = number of paths to cell (i, j).','dp[i][j] = dp[i-1][j] + dp[i][j-1].','First row and column are all 1s (only one way to reach any border cell).'],
    'DP: dp[i][j] = dp[i-1][j] + dp[i][j-1]. Border cells = 1.',
    'O(m*n)', 'O(m*n)',
    array['dynamic-programming','math'], 'uniquePaths',
    'function uniquePaths(m, n) { }', 62
  ),
  (
    'Longest Common Subsequence', 'longest-common-subsequence', 'medium', 'blind75',
    'Given two strings text1 and text2, return the length of their longest common subsequence. If there is no common subsequence, return 0. A subsequence is a sequence that can be derived from another sequence by deleting some or no elements without changing the order of the remaining elements.',
    '[{"input":"text1 = \"abcde\", text2 = \"ace\"","output":"3"},{"input":"text1 = \"abc\", text2 = \"abc\"","output":"3"},{"input":"text1 = \"abc\", text2 = \"def\"","output":"0"}]',
    array['1 <= text1.length, text2.length <= 1000','text1 and text2 consist of only lowercase English letters.'],
    array['dp[i][j] = LCS of text1[0..i] and text2[0..j].','If text1[i] == text2[j]: dp[i][j] = dp[i-1][j-1] + 1.','Else: dp[i][j] = max(dp[i-1][j], dp[i][j-1]).'],
    'DP table: if chars match dp[i][j] = dp[i-1][j-1]+1, else max of neighbors.',
    'O(m*n)', 'O(m*n)',
    array['dynamic-programming','string'], 'longestCommonSubsequence',
    'function longestCommonSubsequence(text1, text2) { }', 1143
  ),
  (
    'Best Time to Buy and Sell Stock with Cooldown', 'buy-sell-stock-cooldown', 'medium', 'neetcode150',
    'You are given an array prices where prices[i] is the price of a stock on the ith day. Find the maximum profit you can achieve. You may complete as many transactions as you like (i.e., buy one and sell one share of the stock multiple times) with the following restriction: After you sell your stock, you cannot buy stock on the next day (i.e., cooldown one day). Note: You may not engage in multiple transactions simultaneously.',
    '[{"input":"prices = [1,2,3,0,2]","output":"3"},{"input":"prices = [1]","output":"0"}]',
    array['1 <= prices.length <= 5000','0 <= prices[i] <= 1000'],
    array['State machine: define states holding, sold, cooldown.','holding: max(holding, cooldown - price).','sold: holding + price.','cooldown: max(cooldown, sold).'],
    'State machine DP: track holding, sold, cooldown states. Transition each day.',
    'O(n)', 'O(1)',
    array['dynamic-programming','array'], 'maxProfit',
    'function maxProfit(prices) { }', 309
  ),
  (
    'Coin Change II', 'coin-change-ii', 'medium', 'blind75',
    'You are given an integer array coins representing coins of different denominations and an integer amount representing a total amount of money. Return the number of combinations that make up that amount. If that amount of money cannot be made up by any combination of the coins, return 0.',
    '[{"input":"amount = 5, coins = [1,2,5]","output":"4"},{"input":"amount = 3, coins = [2]","output":"0"},{"input":"amount = 10, coins = [10]","output":"1"}]',
    array['1 <= coins.length <= 300','1 <= coins[i] <= 5000','All values of coins are unique.','0 <= amount <= 5000'],
    array['Unbounded knapsack problem.','dp[j] = number of ways to make amount j.','For each coin, iterate amounts from coin to amount: dp[j] += dp[j - coin].'],
    'Unbounded knapsack: dp[j] = ways to make amount j. Process each coin.',
    'O(coins * amount)', 'O(amount)',
    array['dynamic-programming','array'], 'change',
    'function change(amount, coins) { }', 518
  ),
  (
    'Target Sum', 'target-sum', 'medium', 'neetcode150',
    'You are given an integer array nums and an integer target. You want to build an expression out of nums by adding one of the symbols + and - before each integer in nums and then concatenate all the integers. Return the number of different expressions that you can build which evaluates to target.',
    '[{"input":"nums = [1,1,1,1,1], target = 3","output":"5"},{"input":"nums = [1], target = 1","output":"1"}]',
    array['1 <= nums.length <= 20','0 <= nums[i] <= 1000','0 <= sum(nums[i]) <= 1000','-1000 <= target <= 1000'],
    array['DFS/backtracking: try + and - for each number.','Or DP: dp[sum] = count of ways to reach sum. Update using current number with + and -.','Can reduce to subset sum problem.'],
    'DP with sum offset. dp[sum] = count. For each num: new_dp[sum + num] += dp[sum] and new_dp[sum - num] += dp[sum].',
    'O(n * sum)', 'O(sum)',
    array['dynamic-programming','backtracking','array'], 'findTargetSumWays',
    'function findTargetSumWays(nums, target) { }', 494
  ),
  (
    'Interleaving String', 'interleaving-string', 'medium', 'neetcode150',
    'Given strings s1, s2, and s3, find whether s3 is formed by an interleaving of s1 and s2. An interleaving of two strings s and t is a configuration where s and t are divided into n and m substrings respectively, and s and t are interleaved.',
    '[{"input":"s1 = \"aabcc\", s2 = \"dbbca\", s3 = \"aadbbcbcac\"","output":"true"},{"input":"s1 = \"aabcc\", s2 = \"dbbca\", s3 = \"aadbbbaccc\"","output":"false"},{"input":"s1 = \"\", s2 = \"\", s3 = \"\"","output":"true"}]',
    array['0 <= s1.length, s2.length <= 100','0 <= s3.length <= 200','s1, s2, and s3 consist of lowercase English letters.'],
    array['dp[i][j] = can s3[0..i+j] be formed by interleaving s1[0..i] and s2[0..j].','Transition: dp[i][j] = (dp[i-1][j] && s1[i-1]==s3[i+j-1]) || (dp[i][j-1] && s2[j-1]==s3[i+j-1]).'],
    '2D DP: dp[i][j] = interleaving possible using s1[0..i] and s2[0..j].',
    'O(m*n)', 'O(m*n)',
    array['dynamic-programming','string'], 'isInterleave',
    'function isInterleave(s1, s2, s3) { }', 97
  ),
  (
    'Longest Increasing Path in Matrix', 'longest-increasing-path-matrix', 'hard', 'neetcode150',
    'Given an m x n integers matrix, return the length of the longest increasing path in matrix. From each cell, you can either move in four directions: left, right, up, or down. You may not move diagonally or move outside the boundary.',
    '[{"input":"matrix = [[9,9,4],[6,6,8],[2,1,1]]","output":"4"},{"input":"matrix = [[3,4,5],[3,2,6],[2,2,1]]","output":"4"},{"input":"matrix = [[1]]","output":"1"}]',
    array['m == matrix.length','n == matrix[i].length','1 <= m, n <= 200','0 <= matrix[i][j] <= 2^31 - 1'],
    array['DFS from each cell, memoize results.','For each cell, longest path = 1 + max of all valid (strictly greater) neighbors.','Memoization ensures each cell is computed only once.'],
    'DFS + memoization. For each cell: 1 + max(DFS of neighbors with larger value).',
    'O(m*n)', 'O(m*n)',
    array['dynamic-programming','dfs','memoization','matrix'], 'longestIncreasingPath',
    'function longestIncreasingPath(matrix) { }', 329
  ),
  (
    'Distinct Subsequences', 'distinct-subsequences', 'hard', 'blind75',
    'Given two strings s and t, return the number of distinct subsequences of s which equals t.',
    '[{"input":"s = \"rabbbit\", t = \"rabbit\"","output":"3"},{"input":"s = \"babgbag\", t = \"bag\"","output":"5"}]',
    array['1 <= s.length, t.length <= 1000','s and t consist of English letters.'],
    array['dp[i][j] = number of ways to form t[0..j] from s[0..i].','If s[i] == t[j]: dp[i][j] = dp[i-1][j-1] + dp[i-1][j] (use or skip s[i]).','If s[i] != t[j]: dp[i][j] = dp[i-1][j] (skip s[i]).'],
    '2D DP: if chars match, dp[i][j] = dp[i-1][j-1] + dp[i-1][j], else dp[i-1][j].',
    'O(m*n)', 'O(m*n)',
    array['dynamic-programming','string'], 'numDistinct',
    'function numDistinct(s, t) { }', 115
  ),
  (
    'Edit Distance', 'edit-distance', 'medium', 'neetcode150',
    'Given two strings word1 and word2, return the minimum number of operations required to convert word1 to word2. You can insert, delete, or replace a character.',
    '[{"input":"word1 = \"horse\", word2 = \"ros\"","output":"3"},{"input":"word1 = \"intention\", word2 = \"execution\"","output":"5"}]',
    array['0 <= word1.length, word2.length <= 500','word1 and word2 consist of lowercase English letters.'],
    array['dp[i][j] = min operations to convert word1[0..i] to word2[0..j].','If chars match: dp[i][j] = dp[i-1][j-1].','Else: dp[i][j] = 1 + min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]).'],
    '2D DP (Levenshtein): if match dp[i-1][j-1], else 1 + min(delete, insert, replace).',
    'O(m*n)', 'O(m*n)',
    array['dynamic-programming','string'], 'minDistance',
    'function minDistance(word1, word2) { }', 72
  ),
  (
    'Burst Balloons', 'burst-balloons', 'hard', 'neetcode150',
    'You are given n balloons, indexed from 0 to n-1. Each balloon is painted with a number on it represented by an array nums. You are asked to burst all the balloons. If you burst the ith balloon, you get nums[i-1] * nums[i] * nums[i+1] coins. Return the maximum coins you can collect by bursting the balloons wisely.',
    '[{"input":"nums = [3,1,5,8]","output":"167"},{"input":"nums = [1,5]","output":"10"}]',
    array['n == nums.length','1 <= n <= 300','0 <= nums[i] <= 100'],
    array['Reverse thinking: instead of which balloon to burst first, think which to burst last in range [l, r].','dp[l][r] = max coins from bursting all balloons between l and r.','For each k in (l, r): dp[l][r] = max(dp[l][k] + dp[k][r] + nums[l]*nums[k]*nums[r]).'],
    'Interval DP: dp[l][r] = max coins bursting balloons in (l,r). Try each as last burst.',
    'O(n³)', 'O(n²)',
    array['dynamic-programming','divide-and-conquer'], 'maxCoins',
    'function maxCoins(nums) { }', 312
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
