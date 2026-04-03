-- ============================================================
-- Seed: Sliding Window questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'sliding-window'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Best Time to Buy and Sell Stock', 'best-time-buy-sell-sw', 'easy', 'neetcode150',
    'You are given an array prices where prices[i] is the price of a stock on day i. Find the maximum profit you can achieve by buying on one day and selling on a future day. Return 0 if no profit is possible.',
    '[{"input":"prices = [7,1,5,3,6,4]","output":"5"},{"input":"prices = [7,6,4,3,1]","output":"0"}]',
    array['1 <= prices.length <= 10^5','0 <= prices[i] <= 10^4'],
    array['Think of this as a sliding window where the window tracks min buy price.','Track min price seen so far (left pointer). Current day is the sell day (right pointer).','Max profit = current price - min price.'],
    'Sliding window: left = min price day, right = current day. Expand right, update min and max profit.',
    'O(n)', 'O(1)',
    array['sliding-window','greedy'], 'maxProfit',
    'function maxProfit(prices) { }', 121
  ),
  (
    'Longest Substring Without Repeating Characters', 'longest-substring-no-repeat', 'medium', 'blind75',
    'Given a string s, find the length of the longest substring without repeating characters.',
    '[{"input":"s = \"abcabcbb\"","output":"3","explanation":"The answer is abc, with the length of 3."},{"input":"s = \"bbbbb\"","output":"1"},{"input":"s = \"pwwkew\"","output":"3"}]',
    array['0 <= s.length <= 5 * 10^4','s consists of English letters, digits, symbols and spaces'],
    array['Use a sliding window with a Set to track characters in current window.','When a duplicate is found, shrink window from the left until the duplicate is removed.','Track the maximum window size seen.'],
    'Sliding window with Set. Expand right, shrink left when duplicate found.',
    'O(n)', 'O(min(n,m)) where m is charset size',
    array['sliding-window','hash-set','string'], 'lengthOfLongestSubstring',
    'function lengthOfLongestSubstring(s) { }', 3
  ),
  (
    'Longest Repeating Character Replacement', 'longest-repeating-char-replacement', 'medium', 'blind75',
    'You are given a string s and an integer k. You can choose any character of the string and change it to any other uppercase English character. You can perform this operation at most k times. Return the length of the longest substring containing the same letter you can get after performing the above operations.',
    '[{"input":"s = \"ABAB\", k = 2","output":"4"},{"input":"s = \"AABABBA\", k = 1","output":"4"}]',
    array['1 <= s.length <= 10^5','s consists of only uppercase English letters','0 <= k <= s.length'],
    array['Use a sliding window. Track frequency of each character in the window.','The window is valid if (window size - max frequency) <= k.','Expand right always. Shrink left when window becomes invalid.'],
    'Sliding window: window valid when length - maxFreq <= k. Track max frequency character.',
    'O(n)', 'O(1)',
    array['sliding-window','string'], 'characterReplacement',
    'function characterReplacement(s, k) { }', 424
  ),
  (
    'Permutation in String', 'permutation-in-string', 'medium', 'neetcode150',
    'Given two strings s1 and s2, return true if s2 contains a permutation of s1, or false otherwise. In other words, return true if one of s1''s permutations is a substring of s2.',
    '[{"input":"s1 = \"ab\", s2 = \"eidbaooo\"","output":"true"},{"input":"s1 = \"ab\", s2 = \"eidboaoo\"","output":"false"}]',
    array['1 <= s1.length, s2.length <= 10^4','s1 and s2 consist of lowercase English letters'],
    array['Use a fixed-size sliding window of length s1.length.','Compare character frequency maps of the window and s1.','Use a count of matching characters instead of comparing full maps each time.'],
    'Fixed sliding window of size s1.length. Compare char frequencies. Track matches count.',
    'O(n)', 'O(1)',
    array['sliding-window','hash-map','string'], 'checkInclusion',
    'function checkInclusion(s1, s2) { }', 567
  ),
  (
    'Minimum Window Substring', 'minimum-window-substring', 'hard', 'blind75',
    'Given two strings s and t of lengths m and n respectively, return the minimum window substring of s such that every character in t (including duplicates) is included in the window. If there is no such substring, return the empty string "".',
    '[{"input":"s = \"ADOBECODEBANC\", t = \"ABC\"","output":"\"BANC\""},{"input":"s = \"a\", t = \"a\"","output":"\"a\""},{"input":"s = \"a\", t = \"aa\"","output":"\"\""}]',
    array['m == s.length','n == t.length','1 <= m, n <= 10^5','s and t consist of uppercase and lowercase English letters'],
    array['Use a sliding window. Expand right until all t chars are covered.','Then shrink from the left while the window still covers all t chars.','Track the minimum valid window seen.'],
    'Sliding window: expand right to cover t, shrink left while still valid, track minimum.',
    'O(m + n)', 'O(m + n)',
    array['sliding-window','hash-map','string'], 'minWindow',
    'function minWindow(s, t) { }', 76
  ),
  (
    'Sliding Window Maximum', 'sliding-window-maximum', 'hard', 'neetcode150',
    'You are given an array of integers nums, there is a sliding window of size k which is moving from the very left of the array to the very right. Return an array of the maximum values in each window position.',
    '[{"input":"nums = [1,3,-1,-3,5,3,6,7], k = 3","output":"[3,3,5,5,6,7]"},{"input":"nums = [1], k = 1","output":"[1]"}]',
    array['1 <= nums.length <= 10^5','-10^4 <= nums[i] <= 10^4','1 <= k <= nums.length'],
    array['A brute force O(nk) finds max in each window — can we do better?','Use a deque (monotonic decreasing queue) to track potential maximums.','The front of the deque is always the current window maximum.'],
    'Monotonic deque: maintain indices in decreasing order of values. Front = window max.',
    'O(n)', 'O(k)',
    array['sliding-window','deque','monotonic-queue'], 'maxSlidingWindow',
    'function maxSlidingWindow(nums, k) { }', 239
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
