-- ============================================================
-- Seed: Arrays questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'arrays'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Two Sum', 'two-sum', 'easy', 'blind75',
    'Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target. You may assume that each input would have exactly one solution, and you may not use the same element twice.',
    '[{"input":"nums = [2,7,11,15], target = 9","output":"[0,1]","explanation":"Because nums[0] + nums[1] == 9, we return [0, 1]."},{"input":"nums = [3,2,4], target = 6","output":"[1,2]"},{"input":"nums = [3,3], target = 6","output":"[0,1]"}]',
    array['2 <= nums.length <= 10^4','-10^9 <= nums[i] <= 10^9','-10^9 <= target <= 10^9','Only one valid answer exists.'],
    array['Think about what complement each number needs.','A hash map gives O(1) lookup. What would you store?','For each num, check if (target - num) is already in the map.'],
    'Hash map: store each number and index. For each num check if complement exists.',
    'O(n)', 'O(n)',
    array['hash-map','array'], 'twoSum',
    'function twoSum(nums, target) { }', 1
  ),
  (
    'Best Time to Buy and Sell Stock', 'best-time-to-buy-sell-stock', 'easy', 'blind75',
    'You are given an array prices where prices[i] is the price of a given stock on the ith day. You want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock. Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return 0.',
    '[{"input":"prices = [7,1,5,3,6,4]","output":"5","explanation":"Buy on day 2 (price=1) and sell on day 5 (price=6), profit = 6-1 = 5."},{"input":"prices = [7,6,4,3,1]","output":"0","explanation":"No profit is possible."}]',
    array['1 <= prices.length <= 10^5','0 <= prices[i] <= 10^4'],
    array['Track the minimum price seen so far as you iterate.','At each day, profit = current price - min price seen so far.','Keep updating max profit.'],
    'Track min price and max profit in a single pass.',
    'O(n)', 'O(1)',
    array['greedy','array'], 'maxProfit',
    'function maxProfit(prices) { }', 121
  ),
  (
    'Contains Duplicate', 'contains-duplicate', 'easy', 'blind75',
    'Given an integer array nums, return true if any value appears at least twice in the array, and return false if every element is distinct.',
    '[{"input":"nums = [1,2,3,1]","output":"true"},{"input":"nums = [1,2,3,4]","output":"false"},{"input":"nums = [1,1,1,3,3,4,3,2,4,2]","output":"true"}]',
    array['1 <= nums.length <= 10^5','-10^9 <= nums[i] <= 10^9'],
    array['A Set automatically removes duplicates.','If Set size < array length, there was a duplicate.'],
    'Use a Set. If any element already exists in Set, return true.',
    'O(n)', 'O(n)',
    array['hash-set','array'], 'containsDuplicate',
    'function containsDuplicate(nums) { }', 217
  ),
  (
    'Product of Array Except Self', 'product-except-self', 'medium', 'blind75',
    'Given an integer array nums, return an array answer such that answer[i] is equal to the product of all the elements of nums except nums[i]. The product of any prefix or suffix of nums is guaranteed to fit in a 32-bit integer. You must write an algorithm that runs in O(n) time and without using the division operation.',
    '[{"input":"nums = [1,2,3,4]","output":"[24,12,8,6]"},{"input":"nums = [-1,1,0,-3,3]","output":"[0,0,9,0,0]"}]',
    array['2 <= nums.length <= 10^5','-30 <= nums[i] <= 30','The product of any prefix or suffix fits in a 32-bit integer.'],
    array['For each index, you need product of everything to its left and right.','Build a prefix product array left to right.','Then multiply by suffix product right to left.'],
    'Prefix products pass + suffix products pass. O(n) time, O(1) extra space.',
    'O(n)', 'O(1)',
    array['prefix-sum','array'], 'productExceptSelf',
    'function productExceptSelf(nums) { }', 238
  ),
  (
    'Maximum Subarray', 'maximum-subarray', 'medium', 'blind75',
    'Given an integer array nums, find the subarray with the largest sum, and return its sum.',
    '[{"input":"nums = [-2,1,-3,4,-1,2,1,-5,4]","output":"6","explanation":"The subarray [4,-1,2,1] has the largest sum 6."},{"input":"nums = [1]","output":"1"},{"input":"nums = [5,4,-1,7,8]","output":"23"}]',
    array['1 <= nums.length <= 10^5','-10^4 <= nums[i] <= 10^4'],
    array['Kadane''s algorithm: should you extend the current subarray or start fresh?','If current sum drops below 0, reset it to 0.','Track the max sum seen at any point.'],
    'Kadane''s algorithm: track current sum, reset to 0 when negative, track max.',
    'O(n)', 'O(1)',
    array['dynamic-programming','kadane','array'], 'maxSubArray',
    'function maxSubArray(nums) { }', 53
  ),
  (
    'Maximum Product Subarray', 'maximum-product-subarray', 'medium', 'blind75',
    'Given an integer array nums, find a subarray that has the largest product, and return the product.',
    '[{"input":"nums = [2,3,-2,4]","output":"6","explanation":"[2,3] has the largest product 6."},{"input":"nums = [-2,0,-1]","output":"0","explanation":"The result cannot be 2, because [-2,-1] is not a subarray."}]',
    array['1 <= nums.length <= 2 * 10^4','-10 <= nums[i] <= 10','The product of any prefix of nums is guaranteed to fit in a 32-bit integer.'],
    array['A negative times a negative becomes positive — track both max and min.','Track current max product and current min product at each step.','Reset when you hit 0.'],
    'Track both max and min products at each step (negatives can flip).',
    'O(n)', 'O(1)',
    array['dynamic-programming','array'], 'maxProduct',
    'function maxProduct(nums) { }', 152
  ),
  (
    'Find Minimum in Rotated Sorted Array', 'find-min-rotated-sorted-array', 'medium', 'blind75',
    'Suppose an array of length n sorted in ascending order is rotated between 1 and n times. Given the sorted rotated array nums of unique elements, return the minimum element of this array. You must write an algorithm that runs in O(log n) time.',
    '[{"input":"nums = [3,4,5,1,2]","output":"1"},{"input":"nums = [4,5,6,7,0,1,2]","output":"0"},{"input":"nums = [11,13,15,17]","output":"11"}]',
    array['n == nums.length','1 <= n <= 5000','-5000 <= nums[i] <= 5000','All the integers of nums are unique.','nums is sorted and rotated between 1 and n times.'],
    array['Use binary search. The minimum is at the rotation point.','If nums[mid] > nums[right], the min is in the right half.','Otherwise min is in the left half (including mid).'],
    'Binary search: compare mid to right to determine which half has the minimum.',
    'O(log n)', 'O(1)',
    array['binary-search','array'], 'findMin',
    'function findMin(nums) { }', 153
  ),
  (
    'Search in Rotated Sorted Array', 'search-rotated-sorted-array', 'medium', 'blind75',
    'There is an integer array nums sorted in ascending order (with distinct values). Given the array nums after the possible rotation and an integer target, return the index of target if it is in nums, or -1 if it is not in nums. You must write an algorithm with O(log n) runtime complexity.',
    '[{"input":"nums = [4,5,6,7,0,1,2], target = 0","output":"4"},{"input":"nums = [4,5,6,7,0,1,2], target = 3","output":"-1"},{"input":"nums = [1], target = 0","output":"-1"}]',
    array['1 <= nums.length <= 5000','-10^4 <= nums[i] <= 10^4','All values of nums are unique.','nums is an ascending array that is possibly rotated.','-10^4 <= target <= 10^4'],
    array['Binary search still works but you need to figure out which side is sorted.','If nums[left] <= nums[mid], the left half is sorted.','Check if target is in the sorted half; if not, search the other half.'],
    'Modified binary search: determine which half is sorted, then decide which half to search.',
    'O(log n)', 'O(1)',
    array['binary-search','array'], 'search',
    'function search(nums, target) { }', 33
  ),
  (
    '3Sum', 'three-sum', 'medium', 'blind75',
    'Given an integer array nums, return all the triplets [nums[i], nums[j], nums[k]] such that i != j, i != k, and j != k, and nums[i] + nums[j] + nums[k] == 0. Notice that the solution set must not contain duplicate triplets.',
    '[{"input":"nums = [-1,0,1,2,-1,-4]","output":"[[-1,-1,2],[-1,0,1]]"},{"input":"nums = [0,1,1]","output":"[]"},{"input":"nums = [0,0,0]","output":"[[0,0,0]]"}]',
    array['3 <= nums.length <= 3000','-10^5 <= nums[i] <= 10^5'],
    array['Sort the array first to enable two-pointer technique and skip duplicates.','Fix one element, then use two pointers for the remaining sum.','Skip duplicate values at each pointer to avoid duplicate triplets.'],
    'Sort + two pointers. Fix i, use left/right pointers to find pairs summing to -nums[i].',
    'O(n²)', 'O(1)',
    array['two-pointers','sorting','array'], 'threeSum',
    'function threeSum(nums) { }', 15
  ),
  (
    'Container With Most Water', 'container-with-most-water', 'medium', 'blind75',
    'You are given an integer array height of length n. There are n vertical lines drawn such that the two endpoints of the ith line are (i, 0) and (i, height[i]). Find two lines that together with the x-axis form a container, such that the container contains the most water. Return the maximum amount of water a container can store.',
    '[{"input":"height = [1,8,6,2,5,4,8,3,7]","output":"49"},{"input":"height = [1,1]","output":"1"}]',
    array['n == height.length','2 <= n <= 10^5','0 <= height[i] <= 10^4'],
    array['Use two pointers at both ends.','Area = min(height[left], height[right]) * (right - left).','Move the pointer with the smaller height inward.'],
    'Two pointers: always move the shorter side inward to potentially find a taller container.',
    'O(n)', 'O(1)',
    array['two-pointers','greedy','array'], 'maxArea',
    'function maxArea(height) { }', 11
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
