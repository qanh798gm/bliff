-- ============================================================
-- Seed: Heap / Priority Queue questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'heap'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Kth Largest Element in a Stream', 'kth-largest-in-stream', 'easy', 'neetcode150',
    'Design a class to find the kth largest element in a stream. Note that it is the kth largest element in the sorted order, not the kth distinct element. Implement KthLargest with add(val) which appends val to the stream and returns the kth largest element.',
    '[{"input":"[\"KthLargest\",\"add\",\"add\",\"add\",\"add\",\"add\"] [[3,[4,5,8,2]],[3],[5],[10],[9],[4]]","output":"[null,4,5,5,8,8]"}]',
    array['1 <= k <= 10^4','0 <= nums.length <= 10^4','-10^4 <= nums[i] <= 10^4','-10^4 <= val <= 10^4','At most 10^4 calls will be made to add.','It is guaranteed that there will be at least k elements in the array when you search for the kth element.'],
    array['Maintain a min-heap of size k.','The top (minimum) of the heap is always the kth largest element.','On add: push to heap. If size > k, pop the minimum.'],
    'Min-heap of size k. Top = kth largest. On add: push, pop if size > k.',
    'O(log k) per add', 'O(k)',
    array['heap','design','stream'], 'KthLargest',
    'class KthLargest { constructor(k, nums) { } add(val) { } }', 703
  ),
  (
    'Last Stone Weight', 'last-stone-weight', 'easy', 'neetcode150',
    'You are given an array of integers stones where stones[i] is the weight of the ith stone. We are playing a game: each turn, we choose the heaviest two stones and smash them together. If they are equal both are destroyed. If not equal, the smaller is destroyed and the larger gets weight = difference. Return the weight of the last remaining stone, or 0 if none remain.',
    '[{"input":"stones = [2,7,4,1,8,1]","output":"1"},{"input":"stones = [1]","output":"1"}]',
    array['1 <= stones.length <= 30','1 <= stones[i] <= 1000'],
    array['Use a max-heap to always access the two heaviest stones.','JavaScript doesn''t have a built-in heap — simulate with sorted array or implement one.','Pop two max, compute difference, push back if non-zero.'],
    'Max-heap. Repeatedly pop two largest, push difference if > 0. Return last or 0.',
    'O(n log n)', 'O(n)',
    array['heap','greedy'], 'lastStoneWeight',
    'function lastStoneWeight(stones) { }', 1046
  ),
  (
    'K Closest Points to Origin', 'k-closest-points-origin', 'medium', 'neetcode150',
    'Given an array of points where points[i] = [xi, yi] represents a point on the X-Y plane and an integer k, return the k closest points to the origin (0, 0). The distance is the Euclidean distance. You may return the answer in any order.',
    '[{"input":"points = [[1,3],[-2,2]], k = 1","output":"[[-2,2]]"},{"input":"points = [[3,3],[5,-1],[-2,4]], k = 2","output":"[[3,3],[-2,4]]"}]',
    array['1 <= k <= points.length <= 10^4','-10^4 <= xi, yi <= 10^4'],
    array['Distance squared = x² + y² (no need for sqrt).','Use a max-heap of size k — if current distance < heap max, swap.','Or simply sort all points by distance and take first k.'],
    'Max-heap of size k by distance. Or sort by x²+y² and slice first k.',
    'O(n log k) heap, O(n log n) sort', 'O(k)',
    array['heap','sorting','math'], 'kClosest',
    'function kClosest(points, k) { }', 973
  ),
  (
    'Kth Largest Element in an Array', 'kth-largest-in-array', 'medium', 'neetcode150',
    'Given an integer array nums and an integer k, return the kth largest element in the array. Note that it is the kth largest element in the sorted order, not the kth distinct element. Can you solve it without sorting?',
    '[{"input":"nums = [3,2,1,5,6,4], k = 2","output":"5"},{"input":"nums = [3,2,3,1,2,4,5,5,6], k = 4","output":"4"}]',
    array['1 <= k <= nums.length <= 10^5','-10^4 <= nums[i] <= 10^4'],
    array['Min-heap of size k: top is always the kth largest.','Or use QuickSelect for average O(n).','For interviews, the heap approach is simpler to explain.'],
    'Min-heap of size k. Top = kth largest. Process all elements.',
    'O(n log k) heap, O(n) avg QuickSelect', 'O(k)',
    array['heap','sorting','quickselect'], 'findKthLargest',
    'function findKthLargest(nums, k) { }', 215
  ),
  (
    'Task Scheduler', 'task-scheduler', 'medium', 'blind75',
    'Given a characters array tasks, representing the tasks a CPU needs to do, where each letter represents a different task. Tasks could be done in any order. Each task is done in one unit of time. For each unit of time, the CPU could complete either one task or just be idle. However, there is a non-negative integer n that represents the cooldown interval between two same tasks. Return the least number of intervals the CPU will take to finish all the given tasks.',
    '[{"input":"tasks = [\"A\",\"A\",\"A\",\"B\",\"B\",\"B\"], n = 2","output":"8"},{"input":"tasks = [\"A\",\"A\",\"A\",\"B\",\"B\",\"B\"], n = 0","output":"6"},{"input":"tasks = [\"A\",\"A\",\"A\",\"A\",\"A\",\"A\",\"B\",\"C\",\"D\",\"E\",\"F\",\"G\"], n = 2","output":"16"}]',
    array['1 <= task.length <= 10^4','tasks[i] is upper-case English letter','n is in the range [0, 100]'],
    array['The most frequent task determines the minimum time.','Formula: max(tasks.length, (maxFreq - 1) * (n + 1) + countOfMaxFreq).','Or simulate with a max-heap and a cooldown queue.'],
    'Math formula: (maxFreq-1)*(n+1) + count of tasks with maxFreq. Take max with total tasks.',
    'O(n)', 'O(1)',
    array['heap','greedy','math'], 'leastInterval',
    'function leastInterval(tasks, n) { }', 621
  ),
  (
    'Design Twitter', 'design-twitter', 'medium', 'neetcode150',
    'Design a simplified version of Twitter where users can post tweets, follow/unfollow another user, and get the 10 most recent tweets in the user''s news feed (tweets from themselves and people they follow).',
    '[{"input":"[\"Twitter\",\"postTweet\",\"getNewsFeed\",\"follow\",\"postTweet\",\"getNewsFeed\",\"unfollow\",\"getNewsFeed\"] [[],[1,5],[1],[1,2],[2,6],[1],[1,2],[1]]","output":"[null,null,[5],null,null,[6,5],null,[5]]"}]',
    array['1 <= userId, followerId, followeeId <= 500','0 <= tweetId <= 10^4','All the tweets have unique IDs.','At most 3 * 10^4 calls will be made to postTweet, getNewsFeed, follow and unfollow.'],
    array['Use a map of userId -> list of tweets (with timestamps).','Use a map of userId -> set of followees.','For getNewsFeed: collect tweets from self + followees, merge using a max-heap by timestamp, return top 10.'],
    'HashMap for tweets/follows. getNewsFeed: merge k sorted lists with max-heap, top 10.',
    'O(n log n) for feed', 'O(n)',
    array['heap','design','hash-map'], 'Twitter',
    'class Twitter { constructor() { } postTweet(userId, tweetId) { } getNewsFeed(userId) { } follow(followerId, followeeId) { } unfollow(followerId, followeeId) { } }', 355
  ),
  (
    'Find Median from Data Stream', 'find-median-data-stream', 'hard', 'blind75',
    'The median is the middle value in an ordered integer list. If the size of the list is even, there is no middle value, and the median is the mean of the two middle values. Implement the MedianFinder class with addNum(num) and findMedian() methods.',
    '[{"input":"[\"MedianFinder\",\"addNum\",\"findMedian\",\"addNum\",\"findMedian\"] [[],[1],[],[2],[]]","output":"[null,null,1.0,null,1.5]"}]',
    array['At most 5 * 10^4 calls will be made to addNum and findMedian.','-10^5 <= num <= 10^5','There will be at least one element in the data structure before calling findMedian.'],
    array['Use two heaps: a max-heap for the lower half and a min-heap for the upper half.','Balance the heaps so their sizes differ by at most 1.','Median = top of larger heap or average of both tops.'],
    'Two heaps: maxHeap (lower half) + minHeap (upper half). Balance on insert. Median from tops.',
    'O(log n) insert, O(1) findMedian', 'O(n)',
    array['heap','design'], 'MedianFinder',
    'class MedianFinder { constructor() { } addNum(num) { } findMedian() { } }', 295
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
