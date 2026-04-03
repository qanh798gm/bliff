-- ============================================================
-- Seed: Dynamic Programming Part 1 (1D DP, Blind 75 + NeetCode 150)
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
    'Climbing Stairs', 'climbing-stairs', 'easy', 'blind75',
    'You are climbing a staircase. It takes n steps to reach the top. Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?',
    '[{"input":"n = 2","output":"2"},{"input":"n = 3","output":"3"}]',
    array['1 <= n <= 45'],
    array['To reach step n, you came from step n-1 or step n-2.','dp[n] = dp[n-1] + dp[n-2].','This is the Fibonacci sequence.'],
    'DP: dp[i] = dp[i-1] + dp[i-2]. Base: dp[1]=1, dp[2]=2.',
    'O(n)', 'O(1)',
    array['dynamic-programming','fibonacci'], 'climbStairs',
    'function climbStairs(n) { }', 70
  ),
  (
    'Min Cost Climbing Stairs', 'min-cost-climbing-stairs', 'easy', 'neetcode150',
    'You are given an integer array cost where cost[i] is the cost of ith step on a staircase. Once you pay the cost, you can either climb one or two steps. You can either start from step 0 or step 1. Return the minimum cost to reach the top of the floor.',
    '[{"input":"cost = [10,15,20]","output":"15"},{"input":"cost = [1,100,1,1,1,100,1,1,100,1]","output":"6"}]',
    array['2 <= cost.length <= 1000','0 <= cost[i] <= 999'],
    array['dp[i] = min cost to reach step i.','dp[i] = min(dp[i-1], dp[i-2]) + cost[i].','Answer is min(dp[n-1], dp[n-2]).'],
    'DP: dp[i] = cost[i] + min(dp[i-1], dp[i-2]). Answer = min(dp[n-1], dp[n-2]).',
    'O(n)', 'O(1)',
    array['dynamic-programming','array'], 'minCostClimbingStairs',
    'function minCostClimbingStairs(cost) { }', 746
  ),
  (
    'House Robber', 'house-robber', 'medium', 'blind75',
    'You are a professional robber planning to rob houses along a street. Each house has a certain amount of money stashed. Adjacent houses have security systems and will alert the police if two adjacent houses are broken into on the same night. Given an integer array nums representing the amount of money of each house, return the maximum amount of money you can rob tonight without alerting the police.',
    '[{"input":"nums = [1,2,3,1]","output":"4"},{"input":"nums = [2,7,9,3,1]","output":"12"}]',
    array['1 <= nums.length <= 100','0 <= nums[i] <= 400'],
    array['At each house, decide: rob it (add to rob[i-2]) or skip (use rob[i-1]).','dp[i] = max(dp[i-1], dp[i-2] + nums[i]).','Only need to track previous two values.'],
    'DP: dp[i] = max(dp[i-1], dp[i-2] + nums[i]). Only need 2 variables.',
    'O(n)', 'O(1)',
    array['dynamic-programming','array'], 'rob',
    'function rob(nums) { }', 198
  ),
  (
    'House Robber II', 'house-robber-ii', 'medium', 'blind75',
    'All houses are arranged in a circle. The first and last house are adjacent. Given an integer array nums, return the maximum amount you can rob without robbing adjacent houses.',
    '[{"input":"nums = [2,3,2]","output":"3"},{"input":"nums = [1,2,3,1]","output":"4"},{"input":"nums = [1,2,3]","output":"3"}]',
    array['1 <= nums.length <= 100','0 <= nums[i] <= 1000'],
    array['Since first and last are adjacent, you can''t rob both.','Run house robber twice: once on nums[0..n-2] and once on nums[1..n-1].','Return the maximum of the two results.'],
    'Run linear house robber on [0..n-2] and [1..n-1]. Return max of both.',
    'O(n)', 'O(1)',
    array['dynamic-programming','array'], 'rob',
    'function rob(nums) { }', 213
  ),
  (
    'Longest Palindromic Substring', 'longest-palindromic-substring', 'medium', 'blind75',
    'Given a string s, return the longest palindromic substring in s.',
    '[{"input":"s = \"babad\"","output":"\"bab\""},{"input":"s = \"cbbd\"","output":"\"bb\""}]',
    array['1 <= s.length <= 1000','s consist of only digits and English letters.'],
    array['Expand around center approach: for each character, expand outward while chars match.','Try both odd length (single center) and even length (two center chars) palindromes.','Track the longest palindrome seen.'],
    'Expand around center: for each index try odd and even expansion. Track longest.',
    'O(n²)', 'O(1)',
    array['dynamic-programming','string','two-pointers'], 'longestPalindrome',
    'function longestPalindrome(s) { }', 5
  ),
  (
    'Palindromic Substrings', 'palindromic-substrings', 'medium', 'neetcode150',
    'Given a string s, return the number of palindromic substrings in it. A string is a palindrome when it reads the same backward as forward. A substring is a contiguous sequence of characters within the string.',
    '[{"input":"s = \"abc\"","output":"3"},{"input":"s = \"aaa\"","output":"6"}]',
    array['1 <= s.length <= 1000','s consists of lowercase English letters.'],
    array['Expand around center for each possible center.','Count each palindrome found during expansion.','Total count = sum of all palindromes found.'],
    'Expand around center. For each center (odd and even), count palindromes.',
    'O(n²)', 'O(1)',
    array['dynamic-programming','string'], 'countSubstrings',
    'function countSubstrings(s) { }', 647
  ),
  (
    'Decode Ways', 'decode-ways', 'medium', 'blind75',
    'A message containing letters from A-Z can be encoded into numbers using A=1, B=2, ..., Z=26. Given a string s containing only digits, return the number of ways to decode it.',
    '[{"input":"s = \"12\"","output":"2"},{"input":"s = \"226\"","output":"3"},{"input":"s = \"06\"","output":"0"}]',
    array['1 <= s.length <= 100','s contains only digits and may contain leading zeros.'],
    array['DP: dp[i] = number of ways to decode s[0..i].','If s[i] != ''0'', dp[i] += dp[i-1] (single digit decode).','If s[i-1..i] forms a valid two-digit code (10-26), dp[i] += dp[i-2].'],
    'DP: dp[i] += dp[i-1] if valid single, dp[i] += dp[i-2] if valid double.',
    'O(n)', 'O(1)',
    array['dynamic-programming','string'], 'numDecodings',
    'function numDecodings(s) { }', 91
  ),
  (
    'Coin Change', 'coin-change', 'medium', 'blind75',
    'You are given an integer array coins representing coins of different denominations and an integer amount representing a total amount of money. Return the fewest number of coins that you need to make up that amount. If that amount of money cannot be made up by any combination of the coins, return -1.',
    '[{"input":"coins = [1,2,5], amount = 11","output":"3"},{"input":"coins = [2], amount = 3","output":"-1"},{"input":"coins = [1], amount = 0","output":"0"}]',
    array['1 <= coins.length <= 12','1 <= coins[i] <= 2^31 - 1','0 <= amount <= 10^4'],
    array['DP: dp[i] = min coins to make amount i.','For each amount i, try every coin: dp[i] = min(dp[i], dp[i-coin] + 1).','Initialize dp with Infinity, dp[0] = 0.'],
    'Bottom-up DP: dp[amount] = min coins. For each amount try all coins.',
    'O(amount * coins)', 'O(amount)',
    array['dynamic-programming','breadth-first-search'], 'coinChange',
    'function coinChange(coins, amount) { }', 322
  ),
  (
    'Maximum Product Subarray', 'max-product-subarray-dp', 'medium', 'neetcode150',
    'Given an integer array nums, find a subarray that has the largest product, and return the product. The test cases are generated so that the answer will fit in a 32-bit integer.',
    '[{"input":"nums = [2,3,-2,4]","output":"6"},{"input":"nums = [-2,0,-1]","output":"0"}]',
    array['1 <= nums.length <= 2 * 10^4','-10 <= nums[i] <= 10','The product of any prefix of nums is guaranteed to fit in a 32-bit integer.'],
    array['Track both max and min product at each position (negatives flip sign).','maxProd = max(num, maxProd * num, minProd * num)','minProd = min(num, maxProd * num, minProd * num)'],
    'Track curMax and curMin at each step. Negatives can flip max/min. Track global max.',
    'O(n)', 'O(1)',
    array['dynamic-programming','array'], 'maxProduct',
    'function maxProduct(nums) { }', 152
  ),
  (
    'Word Break', 'word-break', 'medium', 'blind75',
    'Given a string s and a dictionary of strings wordDict, return true if s can be segmented into a space-separated sequence of one or more dictionary words.',
    '[{"input":"s = \"leetcode\", wordDict = [\"leet\",\"code\"]","output":"true"},{"input":"s = \"applepenapple\", wordDict = [\"apple\",\"pen\"]","output":"true"},{"input":"s = \"catsandog\", wordDict = [\"cats\",\"dog\",\"sand\",\"and\",\"cat\"]","output":"false"}]',
    array['1 <= s.length <= 300','1 <= wordDict.length <= 1000','1 <= wordDict[i].length <= 20','s and wordDict[i] consist of only lowercase English letters.','All the strings of wordDict are unique.'],
    array['DP: dp[i] = can we reach index i using words from dict.','For each i, try all words: if dp[i - word.length] is true and s ends with word at i.','Or BFS from index 0.'],
    'DP: dp[i] = true if s[0..i] can be segmented. Try all words ending at i.',
    'O(n² * m) where m = avg word length', 'O(n)',
    array['dynamic-programming','string','trie'], 'wordBreak',
    'function wordBreak(s, wordDict) { }', 139
  ),
  (
    'Longest Increasing Subsequence', 'longest-increasing-subsequence', 'medium', 'blind75',
    'Given an integer array nums, return the length of the longest strictly increasing subsequence.',
    '[{"input":"nums = [10,9,2,5,3,7,101,18]","output":"4"},{"input":"nums = [0,1,0,3,2,3]","output":"4"},{"input":"nums = [7,7,7,7,7,7,7]","output":"1"}]',
    array['1 <= nums.length <= 2500','-10^4 <= nums[i] <= 10^4'],
    array['dp[i] = LIS ending at index i.','For each i, check all j < i: if nums[j] < nums[i], dp[i] = max(dp[i], dp[j]+1).','O(n log n) solution uses patience sorting / binary search.'],
    'O(n²) DP: dp[i] = max LIS ending at i. Or O(n log n) with patience sorting.',
    'O(n log n)', 'O(n)',
    array['dynamic-programming','binary-search','array'], 'lengthOfLIS',
    'function lengthOfLIS(nums) { }', 300
  ),
  (
    'Partition Equal Subset Sum', 'partition-equal-subset-sum', 'medium', 'blind75',
    'Given an integer array nums, return true if you can partition the array into two subsets such that the sum of the elements in both subsets is equal or false otherwise.',
    '[{"input":"nums = [1,5,11,5]","output":"true"},{"input":"nums = [1,2,3,5]","output":"false"}]',
    array['1 <= nums.length <= 200','1 <= nums[i] <= 100'],
    array['Total sum must be even. Target = sum / 2.','0/1 knapsack: can we select elements that sum to target?','dp[j] = can we reach sum j? For each num, update dp from right to left.'],
    '0/1 knapsack DP. dp[j] = can we achieve sum j. Target = totalSum / 2.',
    'O(n * sum)', 'O(sum)',
    array['dynamic-programming','array'], 'canPartition',
    'function canPartition(nums) { }', 416
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
