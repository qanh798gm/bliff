-- ============================================================
-- Seed: Intervals questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'intervals'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Insert Interval', 'insert-interval', 'medium', 'blind75',
    'You are given an array of non-overlapping intervals sorted in ascending order by start time. Insert a newInterval into intervals such that the result is still sorted and non-overlapping (merge if necessary). Return the resulting array of intervals.',
    '[{"input":"intervals = [[1,3],[6,9]], newInterval = [2,5]","output":"[[1,5],[6,9]]"},{"input":"intervals = [[1,2],[3,5],[6,7],[8,10],[12,16]], newInterval = [4,8]","output":"[[1,2],[3,10],[12,16]]"}]',
    array['0 <= intervals.length <= 10^4','intervals[i].length == 2','0 <= starti <= endi <= 10^5','intervals is sorted by starti in ascending order.','newInterval.length == 2','0 <= start <= end <= 10^5'],
    array['Add all intervals that end before newInterval starts.','Merge all intervals that overlap with newInterval (update newInterval start/end).','Add all intervals that start after newInterval ends.'],
    'Three passes: add before, merge overlapping, add after.',
    'O(n)', 'O(n)',
    array['intervals','array'], 'insert',
    'function insert(intervals, newInterval) { }', 57
  ),
  (
    'Merge Intervals', 'merge-intervals', 'medium', 'blind75',
    'Given an array of intervals where intervals[i] = [starti, endi], merge all overlapping intervals, and return an array of the non-overlapping intervals that cover all the intervals in the input.',
    '[{"input":"intervals = [[1,3],[2,6],[8,10],[15,18]]","output":"[[1,6],[8,10],[15,18]]"},{"input":"intervals = [[1,4],[4,5]]","output":"[[1,5]]"}]',
    array['1 <= intervals.length <= 10^4','intervals[i].length == 2','0 <= starti <= endi <= 10^4'],
    array['Sort intervals by start time.','Iterate: if current interval overlaps with last merged (current.start <= last.end), merge by extending end.','Otherwise add current interval to result.'],
    'Sort by start. Iterate: extend last interval if overlap, else append new.',
    'O(n log n)', 'O(n)',
    array['intervals','sorting','array'], 'merge',
    'function merge(intervals) { }', 56
  ),
  (
    'Non-overlapping Intervals', 'non-overlapping-intervals', 'medium', 'blind75',
    'Given an array of intervals where intervals[i] = [starti, endi], return the minimum number of intervals you need to remove to make the rest of the intervals non-overlapping.',
    '[{"input":"intervals = [[1,2],[2,3],[3,4],[1,3]]","output":"1"},{"input":"intervals = [[1,2],[1,2],[1,2]]","output":"2"},{"input":"intervals = [[1,2],[2,3]]","output":"0"}]',
    array['1 <= intervals.length <= 10^5','intervals[i].length == 2','-5 * 10^4 <= starti < endi <= 5 * 10^4'],
    array['Sort by end time (greedy: keep intervals that end earliest).','Greedily select intervals that don''t overlap.','Count removed = total - kept.'],
    'Sort by end time. Greedy: keep interval if it doesn''t overlap with last kept.',
    'O(n log n)', 'O(1)',
    array['intervals','greedy','sorting'], 'eraseOverlapIntervals',
    'function eraseOverlapIntervals(intervals) { }', 435
  ),
  (
    'Meeting Rooms', 'meeting-rooms', 'easy', 'blind75',
    'Given an array of meeting time intervals where intervals[i] = [starti, endi], determine if a person could attend all meetings.',
    '[{"input":"intervals = [[0,30],[5,10],[15,20]]","output":"false"},{"input":"intervals = [[7,10],[2,4]]","output":"true"}]',
    array['0 <= intervals.length <= 10^4','intervals[i].length == 2','0 <= starti < endi <= 10^6'],
    array['Sort by start time.','Check if any adjacent meetings overlap: if intervals[i].start < intervals[i-1].end, return false.'],
    'Sort by start. Check consecutive overlap.',
    'O(n log n)', 'O(1)',
    array['intervals','sorting'], 'canAttendMeetings',
    'function canAttendMeetings(intervals) { }', 252
  ),
  (
    'Meeting Rooms II', 'meeting-rooms-ii', 'medium', 'blind75',
    'Given an array of meeting time intervals intervals where intervals[i] = [starti, endi], return the minimum number of conference rooms required.',
    '[{"input":"intervals = [[0,30],[5,10],[15,20]]","output":"2"},{"input":"intervals = [[7,10],[2,4]]","output":"1"}]',
    array['1 <= intervals.length <= 10^4','0 <= starti < endi <= 10^6'],
    array['Sort by start time. Use a min-heap to track earliest ending meeting.','For each new meeting: if heap top ends <= new start, reuse that room (pop and push).','Otherwise allocate new room (just push). Answer = heap size.'],
    'Sort by start. Min-heap of end times. Reuse room if earliest end <= new start.',
    'O(n log n)', 'O(n)',
    array['intervals','heap','greedy','sorting'], 'minMeetingRooms',
    'function minMeetingRooms(intervals) { }', 253
  ),
  (
    'Minimum Interval to Include Each Query', 'min-interval-include-query', 'hard', 'neetcode150',
    'You are given a 2D integer array intervals, where intervals[i] = [lefti, righti] describes the ith interval starting at lefti and ending at righti (inclusive). The size of an interval is defined as the number of integers it contains, or more formally righti - lefti + 1. You are also given an integer array queries. The answer to the jth query is the size of the smallest interval i such that lefti <= queries[j] <= righti. Return an array containing the answers to the queries.',
    '[{"input":"intervals = [[1,4],[2,4],[3,6],[4,4]], queries = [2,3,4,5]","output":"[3,3,1,4]"},{"input":"intervals = [[2,3],[2,5],[1,8],[20,25]], queries = [2,19,5,22]","output":"[2,-1,4,6]"}]',
    array['1 <= intervals.length <= 10^5','1 <= lefti <= righti <= 10^9','1 <= queries.length <= 10^5','1 <= queries[j] <= 10^9'],
    array['Sort intervals by start and queries by value.','Use a min-heap sorted by interval size.','Process queries in sorted order: add all intervals starting <= query, remove intervals ending < query.'],
    'Sort queries + intervals by start. Sweep with min-heap (size, end). Answer each sorted query.',
    'O((n + q) log n)', 'O(n + q)',
    array['intervals','heap','sorting','sweep-line'], 'minInterval',
    'function minInterval(intervals, queries) { }', 1851
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
