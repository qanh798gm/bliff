-- ============================================================
-- Seed: Greedy questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'greedy'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Maximum Subarray', 'maximum-subarray-greedy', 'medium', 'neetcode150',
    'Given an integer array nums, find the subarray with the largest sum, and return its sum. (Kadane''s algorithm is greedy)',
    '[{"input":"nums = [-2,1,-3,4,-1,2,1,-5,4]","output":"6"},{"input":"nums = [1]","output":"1"},{"input":"nums = [5,4,-1,7,8]","output":"23"}]',
    array['1 <= nums.length <= 10^5','-10^4 <= nums[i] <= 10^4'],
    array['Kadane''s algorithm: greedily decide whether to extend current subarray or start fresh.','If current sum < 0, reset to 0 (start new subarray).','Track the max sum seen.'],
    'Kadane: curSum = max(curSum + num, num). Track maxSum.',
    'O(n)', 'O(1)',
    array['greedy','dynamic-programming','array'], 'maxSubArray',
    'function maxSubArray(nums) { }', 53
  ),
  (
    'Jump Game', 'jump-game', 'medium', 'blind75',
    'You are given an integer array nums. You are initially positioned at the array''s first index, and each element in the array represents your maximum jump length at that position. Return true if you can reach the last index, or false otherwise.',
    '[{"input":"nums = [2,3,1,1,4]","output":"true"},{"input":"nums = [3,2,1,0,4]","output":"false"}]',
    array['1 <= nums.length <= 10^4','0 <= nums[i] <= 10^5'],
    array['Greedy: track the farthest index reachable so far.','Iterate: if current index > farthest, return false.','Update farthest = max(farthest, i + nums[i]).'],
    'Greedy: track maxReach. If i > maxReach at any point, return false.',
    'O(n)', 'O(1)',
    array['greedy','array'], 'canJump',
    'function canJump(nums) { }', 55
  ),
  (
    'Jump Game II', 'jump-game-ii', 'medium', 'blind75',
    'You are given a 0-indexed array of integers nums of length n. You are initially positioned at nums[0]. Each element nums[i] represents the maximum length of a forward jump from index i. Return the minimum number of jumps to reach nums[n-1].',
    '[{"input":"nums = [2,3,1,1,4]","output":"2"},{"input":"nums = [2,3,0,1,4]","output":"2"}]',
    array['1 <= nums.length <= 10^4','0 <= nums[i] <= 1000','It is guaranteed that you can reach nums[n - 1].'],
    array['Greedy BFS: within each jump range, find the farthest reachable point.','When you exhaust the current jump range, increment jumps and set new range.'],
    'Greedy: track current range end and farthest reachable. Jump when reaching end of range.',
    'O(n)', 'O(1)',
    array['greedy','array'], 'jump',
    'function jump(nums) { }', 45
  ),
  (
    'Gas Station', 'gas-station', 'medium', 'neetcode150',
    'There are n gas stations along a circular route. You are given two integer arrays gas and cost. Return the starting gas station''s index if you can travel around the circuit once in the clockwise direction, otherwise return -1. If a solution exists, it is guaranteed to be unique.',
    '[{"input":"gas = [1,2,3,4,5], cost = [3,4,5,1,2]","output":"3"},{"input":"gas = [2,3,4], cost = [3,4,3]","output":"-1"}]',
    array['n == gas.length == cost.length','1 <= n <= 10^5','0 <= gas[i], cost[i] <= 10^4'],
    array['If total gas >= total cost, a solution exists.','Greedily find the starting point: if cumulative tank < 0, reset start to next station.','The greedy choice works because if you can''t reach i from j, you can''t reach i from any station between j and i.'],
    'If total>=0 solution exists. Greedy: reset start when tank<0.',
    'O(n)', 'O(1)',
    array['greedy','array'], 'canCompleteCircuit',
    'function canCompleteCircuit(gas, cost) { }', 134
  ),
  (
    'Hand of Straights', 'hand-of-straights', 'medium', 'neetcode150',
    'Alice has some number of cards and she wants to rearrange the cards into groups so that each group is of size groupSize, and consists of groupSize consecutive cards. Given an integer array hand and an integer groupSize, return true if she can rearrange the cards, or false otherwise.',
    '[{"input":"hand = [1,2,3,6,2,3,4,7,8], groupSize = 3","output":"true"},{"input":"hand = [1,2,3,4,5], groupSize = 4","output":"false"}]',
    array['1 <= hand.length <= 10^4','0 <= hand[i] <= 10^9','1 <= groupSize <= hand.length'],
    array['Count frequency of each card.','Sort unique card values.','Greedily form groups starting from smallest card. Subtract 1 from each of groupSize consecutive cards.'],
    'Sort + greedy: for smallest card, try to extend groupSize cards. Use frequency map.',
    'O(n log n)', 'O(n)',
    array['greedy','sorting','hash-map'], 'isNStraightHand',
    'function isNStraightHand(hand, groupSize) { }', 846
  ),
  (
    'Merge Triplets to Form Target Triplet', 'merge-triplets-target', 'medium', 'neetcode150',
    'A triplet is an array of three integers. You are given a 2D integer array triplets, where triplets[i] = [ai, bi, ci] describes the ith triplet. You are also given an integer array target = [x, y, z] that is a triplet. To obtain the target, you may merge triplets. If you merge triplets[i] and triplets[j], the resulting triplet is [max(ai, aj), max(bi, bj), max(ci, cj)]. Return true if it is possible to obtain the target triplet.',
    '[{"input":"triplets = [[2,5,3],[1,8,4],[1,7,5]], target = [2,7,5]","output":"true"},{"input":"triplets = [[3,4,5],[4,5,6]], target = [3,2,5]","output":"false"}]',
    array['1 <= triplets.length <= 10^5','triplets[i].length == target.length == 3','1 <= ai, bi, ci, x, y, z <= 1000'],
    array['Filter out triplets where any value exceeds the target (they can''t be used).','Among remaining triplets, check if the max of each position equals target.'],
    'Filter triplets exceeding target. Check if remaining triplets'' max equals target.',
    'O(n)', 'O(1)',
    array['greedy','array'], 'mergeTriplets',
    'function mergeTriplets(triplets, target) { }', 1899
  ),
  (
    'Partition Labels', 'partition-labels', 'medium', 'neetcode150',
    'You are given a string s. We want to partition the string into as many parts as possible so that each letter appears in at most one part. Return a list of integers representing the size of these parts.',
    '[{"input":"s = \"ababcbacadefegdehijhklij\"","output":"[9,7,8]"},{"input":"s = \"eccbbbbdec\"","output":"[10]"}]',
    array['1 <= s.length <= 500','s consists of lowercase English letters.'],
    array['Find the last occurrence of each character.','Greedily extend the current partition to include the last occurrence of all chars seen so far.','When current index == current partition end, record partition size and start new partition.'],
    'Track last occurrence of each char. Greedy: extend partition to max last occurrence seen.',
    'O(n)', 'O(1)',
    array['greedy','string','two-pointers'], 'partitionLabels',
    'function partitionLabels(s) { }', 763
  ),
  (
    'Valid Parenthesis String', 'valid-parenthesis-string', 'medium', 'neetcode150',
    'Given a string s containing only ''('', '')'', and ''*'', return true if s is valid. ''*'' can be treated as ''('', '')'' or an empty string.',
    '[{"input":"s = \"()\"","output":"true"},{"input":"s = \"(*)\"","output":"true"},{"input":"s = \"(*))\"","output":"true"}]',
    array['1 <= s.length <= 100','s[i] is ''('', '')'' or ''*''.'],
    array['Track the range of possible open parenthesis counts [minOpen, maxOpen].','On ''('': increment both. On '')'': decrement both. On ''*'': minOpen--, maxOpen++.','If maxOpen < 0, return false. Clamp minOpen to 0. At end, minOpen must be 0.'],
    'Greedy: track [minOpen, maxOpen] range. Update per char. Valid if minOpen==0 at end.',
    'O(n)', 'O(1)',
    array['greedy','string','stack'], 'checkValidString',
    'function checkValidString(s) { }', 678
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
