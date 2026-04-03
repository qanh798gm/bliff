-- ============================================================
-- Seed: Binary Search questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'binary-search'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Binary Search', 'binary-search', 'easy', 'neetcode150',
    'Given an array of integers nums which is sorted in ascending order, and an integer target, write a function to search target in nums. If target exists, then return its index. Otherwise, return -1. You must write an algorithm with O(log n) runtime complexity.',
    '[{"input":"nums = [-1,0,3,5,9,12], target = 9","output":"4"},{"input":"nums = [-1,0,3,5,9,12], target = 2","output":"-1"}]',
    array['1 <= nums.length <= 10^4','-10^4 < nums[i], target < 10^4','All the integers in nums are unique.','nums is sorted in ascending order.'],
    array['Use left and right pointers.','Find mid = (left + right) / 2.','If nums[mid] == target return mid. If < target move left up. If > target move right down.'],
    'Classic binary search: left/right pointers, check mid, adjust bounds.',
    'O(log n)', 'O(1)',
    array['binary-search','array'], 'search',
    'function search(nums, target) { }', 704
  ),
  (
    'Search a 2D Matrix', 'search-2d-matrix', 'medium', 'blind75',
    'You are given an m x n integer matrix with the following two properties: Each row is sorted in non-decreasing order. The first integer of each row is greater than the last integer of the previous row. Given an integer target, return true if target is in the matrix or false otherwise. You must write a solution in O(log(m * n)) time complexity.',
    '[{"input":"matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 3","output":"true"},{"input":"matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 13","output":"false"}]',
    array['m == matrix.length','n == matrix[i].length','1 <= m, n <= 100','-10^4 <= matrix[i][j], target <= 10^4'],
    array['Treat the 2D matrix as a 1D sorted array of m*n elements.','For mid index i in the flattened array: row = Math.floor(i/n), col = i % n.','Apply standard binary search.'],
    'Treat as flattened sorted array. Binary search with index mapping to row/col.',
    'O(log(m*n))', 'O(1)',
    array['binary-search','matrix'], 'searchMatrix',
    'function searchMatrix(matrix, target) { }', 74
  ),
  (
    'Koko Eating Bananas', 'koko-eating-bananas', 'medium', 'neetcode150',
    'Koko loves to eat bananas. There are n piles of bananas, the ith pile has piles[i] bananas. The guards have gone and will come back in h hours. Koko can decide her bananas-per-hour eating speed of k. Each hour, she chooses some pile of bananas and eats k bananas from that pile. If the pile has less than k bananas, she eats all of them instead. Koko likes to eat slowly but wants to finish eating all the bananas before the guards return. Return the minimum integer k such that she can eat all the bananas within h hours.',
    '[{"input":"piles = [3,6,7,11], h = 8","output":"4"},{"input":"piles = [30,11,23,4,20], h = 5","output":"30"},{"input":"piles = [30,11,23,4,20], h = 6","output":"23"}]',
    array['1 <= piles.length <= 10^4','piles.length <= h <= 10^9','1 <= piles[i] <= 10^9'],
    array['Binary search on the answer (speed k), not on the array.','Low = 1, high = max(piles).','For a given speed k, check if she can finish in h hours: sum of ceil(pile/k) for all piles.'],
    'Binary search on speed (1 to max pile). Check feasibility with ceil division sum.',
    'O(n log m) where m = max pile', 'O(1)',
    array['binary-search','greedy'], 'minEatingSpeed',
    'function minEatingSpeed(piles, h) { }', 875
  ),
  (
    'Find Minimum in Rotated Sorted Array', 'find-min-rotated-bs', 'medium', 'neetcode150',
    'Given the sorted rotated array nums of unique elements, return the minimum element. You must write an algorithm that runs in O(log n) time.',
    '[{"input":"nums = [3,4,5,1,2]","output":"1"},{"input":"nums = [4,5,6,7,0,1,2]","output":"0"},{"input":"nums = [11,13,15,17]","output":"11"}]',
    array['n == nums.length','1 <= n <= 5000','-5000 <= nums[i] <= 5000','All the integers of nums are unique.','nums is sorted and rotated between 1 and n times.'],
    array['The minimum is at the rotation inflection point.','If nums[mid] > nums[right], the min is in the right half.','Otherwise the min is in the left half (including mid).'],
    'Binary search: compare mid to right boundary to determine which half has minimum.',
    'O(log n)', 'O(1)',
    array['binary-search','array'], 'findMin',
    'function findMin(nums) { }', 153
  ),
  (
    'Search in Rotated Sorted Array', 'search-rotated-sorted-bs', 'medium', 'neetcode150',
    'Given the sorted rotated array nums and a target, return the index of target if it is in nums, or -1 if it is not. You must write an algorithm with O(log n) runtime.',
    '[{"input":"nums = [4,5,6,7,0,1,2], target = 0","output":"4"},{"input":"nums = [4,5,6,7,0,1,2], target = 3","output":"-1"},{"input":"nums = [1], target = 0","output":"-1"}]',
    array['1 <= nums.length <= 5000','-10^4 <= nums[i] <= 10^4','All values unique.'],
    array['Identify which half is sorted by comparing nums[left] and nums[mid].','If left half sorted and target in range [left, mid], search left; else search right.','If right half sorted and target in range [mid, right], search right; else search left.'],
    'Modified binary search: find sorted half, check if target is in it, search accordingly.',
    'O(log n)', 'O(1)',
    array['binary-search','array'], 'search',
    'function search(nums, target) { }', 33
  ),
  (
    'Time Based Key-Value Store', 'time-based-key-value-store', 'medium', 'neetcode150',
    'Design a time-based key-value data structure that can store multiple values for the same key at different time stamps and retrieve the key''s value at a certain timestamp. Implement TimeMap with set(key, value, timestamp) and get(key, timestamp) methods. get should return the value with the largest timestamp <= given timestamp.',
    '[{"input":"[\"TimeMap\",\"set\",\"get\",\"get\",\"set\",\"get\",\"get\"] [[],[\"foo\",\"bar\",1],[\"foo\",1],[\"foo\",3],[\"foo\",\"bar2\",4],[\"foo\",4],[\"foo\",5]]","output":"[null,null,\"bar\",\"bar\",null,\"bar2\",\"bar2\"]"}]',
    array['1 <= key.length, value.length <= 100','key and value consist of lowercase English letters and digits.','1 <= timestamp <= 10^7','All timestamps of set are strictly increasing.','At most 2 * 10^5 calls will be made to set and get.'],
    array['Store values as list of [value, timestamp] pairs per key.','For get, binary search through the list for the largest timestamp <= query timestamp.','Since timestamps are strictly increasing when set, the list is already sorted.'],
    'HashMap of key -> sorted list of [timestamp, value]. Binary search on get.',
    'O(1) set, O(log n) get', 'O(n)',
    array['binary-search','design','hash-map'], 'TimeMap',
    'class TimeMap { constructor() { } set(key, value, timestamp) { } get(key, timestamp) { } }', 981
  ),
  (
    'Median of Two Sorted Arrays', 'median-two-sorted-arrays', 'hard', 'blind75',
    'Given two sorted arrays nums1 and nums2 of size m and n respectively, return the median of the two sorted arrays. The overall run time complexity should be O(log (m+n)).',
    '[{"input":"nums1 = [1,3], nums2 = [2]","output":"2.00000"},{"input":"nums1 = [1,2], nums2 = [3,4]","output":"2.50000"}]',
    array['nums1.length == m','nums2.length == n','0 <= m <= 1000','0 <= n <= 1000','1 <= m + n <= 2000','-10^6 <= nums1[i], nums2[i] <= 10^6'],
    array['Binary search on the smaller array to find the correct partition.','A valid partition means: max(leftA, leftB) <= min(rightA, rightB).','The median is then computed from the partition boundary elements.'],
    'Binary search on smaller array partition. Valid partition: maxLeft <= minRight on both sides.',
    'O(log(min(m,n)))', 'O(1)',
    array['binary-search','array','divide-and-conquer'], 'findMedianSortedArrays',
    'function findMedianSortedArrays(nums1, nums2) { }', 4
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
