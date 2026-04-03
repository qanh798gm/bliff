-- ============================================================
-- Seed: Two Pointers questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'two-pointers'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Valid Palindrome', 'valid-palindrome', 'easy', 'blind75',
    'A phrase is a palindrome if, after converting all uppercase letters into lowercase letters and removing all non-alphanumeric characters, it reads the same forward and backward. Given a string s, return true if it is a palindrome, or false otherwise.',
    '[{"input":"s = \"A man, a plan, a canal: Panama\"","output":"true"},{"input":"s = \"race a car\"","output":"false"},{"input":"s = \" \"","output":"true"}]',
    array['1 <= s.length <= 2 * 10^5','s consists only of printable ASCII characters'],
    array['Use two pointers, one from each end.','Skip non-alphanumeric characters.','Compare characters after converting to lowercase.'],
    'Two pointers from both ends, skip non-alphanumeric, compare lowercase.',
    'O(n)', 'O(1)',
    array['two-pointers','string'], 'isPalindrome',
    'function isPalindrome(s) { }', 125
  ),
  (
    'Two Sum II - Input Array Is Sorted', 'two-sum-ii-sorted', 'medium', 'neetcode150',
    'Given a 1-indexed array of integers numbers that is already sorted in non-decreasing order, find two numbers such that they add up to a specific target number. Return the indices of the two numbers, index1 and index2, added by one as an integer array [index1, index2] of length 2. You may not use the same element twice. You must use only constant extra space.',
    '[{"input":"numbers = [2,7,11,15], target = 9","output":"[1,2]"},{"input":"numbers = [2,3,4], target = 6","output":"[1,3]"},{"input":"numbers = [-1,0], target = -1","output":"[1,2]"}]',
    array['2 <= numbers.length <= 3 * 10^4','-1000 <= numbers[i] <= 1000','numbers is sorted in non-decreasing order.','-1000 <= target <= 1000','The tests are generated such that there is exactly one solution.'],
    array['Since array is sorted, use two pointers at the start and end.','If sum > target, move right pointer left.','If sum < target, move left pointer right.'],
    'Two pointers: left at start, right at end. Move based on sum vs target.',
    'O(n)', 'O(1)',
    array['two-pointers','binary-search','array'], 'twoSum',
    'function twoSum(numbers, target) { }', 167
  ),
  (
    '3Sum Closest', 'three-sum-closest', 'medium', 'neetcode150',
    'Given an integer array nums of length n and an integer target, find three integers in nums such that the sum is closest to target. Return the sum of the three integers.',
    '[{"input":"nums = [-1,2,1,-4], target = 1","output":"2"},{"input":"nums = [0,0,0], target = 1","output":"0"}]',
    array['3 <= nums.length <= 500','-1000 <= nums[i] <= 1000','-10^4 <= target <= 10^4'],
    array['Sort the array first.','Fix one element and use two pointers for the rest.','Track the closest sum seen so far.'],
    'Sort + two pointers. For each i, find the closest pair summing to target - nums[i].',
    'O(n²)', 'O(1)',
    array['two-pointers','sorting'], 'threeSumClosest',
    'function threeSumClosest(nums, target) { }', 16
  ),
  (
    'Trapping Rain Water', 'trapping-rain-water', 'hard', 'blind75',
    'Given n non-negative integers representing an elevation map where the width of each bar is 1, compute how much water it can trap after raining.',
    '[{"input":"height = [0,1,0,2,1,0,1,3,2,1,2,1]","output":"6"},{"input":"height = [4,2,0,3,2,5]","output":"9"}]',
    array['n == height.length','1 <= n <= 2 * 10^4','0 <= height[i] <= 10^5'],
    array['Water at each bar = min(maxLeft, maxRight) - height[bar].','Precompute max left and max right for each position, or use two pointers.','Two pointer approach: track leftMax and rightMax, process the smaller side.'],
    'Two pointers: track leftMax and rightMax. Process the side with smaller max, add water, move pointer.',
    'O(n)', 'O(1)',
    array['two-pointers','stack','array'], 'trap',
    'function trap(height) { }', 42
  ),
  (
    'Remove Duplicates from Sorted Array', 'remove-duplicates-sorted-array', 'easy', 'neetcode150',
    'Given an integer array nums sorted in non-decreasing order, remove the duplicates in-place such that each unique element appears only once. The relative order of the elements should be kept the same. Return k after placing the final result in the first k slots of nums.',
    '[{"input":"nums = [1,1,2]","output":"2, nums = [1,2,_]"},{"input":"nums = [0,0,1,1,1,2,2,3,3,4]","output":"5, nums = [0,1,2,3,4,_,_,_,_,_]"}]',
    array['1 <= nums.length <= 3 * 10^4','-100 <= nums[i] <= 100','nums is sorted in non-decreasing order'],
    array['Use a slow pointer to track the write position.','Fast pointer scans ahead for the next unique element.','When nums[fast] != nums[slow], write it to slow+1 position.'],
    'Two pointers: slow tracks write index, fast scans for new unique values.',
    'O(n)', 'O(1)',
    array['two-pointers','array'], 'removeDuplicates',
    'function removeDuplicates(nums) { }', 26
  ),
  (
    'Move Zeroes', 'move-zeroes', 'easy', 'neetcode150',
    'Given an integer array nums, move all 0s to the end of it while maintaining the relative order of the non-zero elements. Note that you must do this in-place without making a copy of the array.',
    '[{"input":"nums = [0,1,0,3,12]","output":"[1,3,12,0,0]"},{"input":"nums = [0]","output":"[0]"}]',
    array['1 <= nums.length <= 10^4','nums[i] is either 0 or non-zero integer'],
    array['Use a slow pointer tracking where next non-zero should go.','Scan with fast pointer. When non-zero found, swap with slow position.'],
    'Two pointers: slow = next write position. Swap non-zero elements to slow, advance slow.',
    'O(n)', 'O(1)',
    array['two-pointers','array'], 'moveZeroes',
    'function moveZeroes(nums) { }', 283
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
