-- Test Cases: DSA — Intervals
-- insert-interval, merge-intervals, non-overlapping-intervals,
-- meeting-rooms, meeting-rooms-ii, min-interval-include-query

update questions set test_cases = '[
  {"input":{"intervals":[[1,3],[6,9]],"newInterval":[2,5]},"expected":[[1,5],[6,9]],"description":"Basic: merge with first","tier":"basic"},
  {"input":{"intervals":[[1,2],[3,5],[6,7],[8,10],[12,16]],"newInterval":[4,8]},"expected":[[1,2],[3,10],[12,16]],"description":"Basic: merge multiple","tier":"basic"},
  {"input":{"intervals":[],"newInterval":[5,7]},"expected":[[5,7]],"description":"Edge: empty intervals","tier":"edge"},
  {"input":{"intervals":[[1,5]],"newInterval":[2,3]},"expected":[[1,5]],"description":"Edge: new inside existing","tier":"edge"},
  {"input":{"intervals":[[1,5]],"newInterval":[6,8]},"expected":[[1,5],[6,8]],"description":"Edge: append at end","tier":"edge"},
  {"input":{"intervals":[[3,5],[6,9]],"newInterval":[1,2]},"expected":[[1,2],[3,5],[6,9]],"description":"Corner: prepend at start","tier":"corner"},
  {"input":{"intervals":[[1,2],[3,5],[6,7],[8,10],[12,16]],"newInterval":[0,20]},"expected":[[0,20]],"description":"Corner: covers all","tier":"corner"}
]'::jsonb where slug = 'insert-interval';

update questions set test_cases = '[
  {"input":{"intervals":[[1,3],[2,6],[8,10],[15,18]]},"expected":[[1,6],[8,10],[15,18]],"description":"Basic: one merge","tier":"basic"},
  {"input":{"intervals":[[1,4],[4,5]]},"expected":[[1,5]],"description":"Basic: touching intervals","tier":"basic"},
  {"input":{"intervals":[[1,4],[2,3]]},"expected":[[1,4]],"description":"Edge: contained interval","tier":"edge"},
  {"input":{"intervals":[[1,4]]},"expected":[[1,4]],"description":"Edge: single interval","tier":"edge"},
  {"input":{"intervals":[[1,3],[2,6],[8,10],[9,18]]},"expected":[[1,6],[8,18]],"description":"Corner: chain merges","tier":"corner"},
  {"input":{"intervals":[[2,3],[4,5],[6,7],[8,9],[1,10]]},"expected":[[1,10]],"description":"Corner: one covers all","tier":"corner"}
]'::jsonb where slug = 'merge-intervals';

update questions set test_cases = '[
  {"input":{"intervals":[[1,2],[2,3],[3,4],[1,3]]},"expected":1,"description":"Basic: remove one","tier":"basic"},
  {"input":{"intervals":[[1,2],[1,2],[1,2]]},"expected":2,"description":"Basic: remove two duplicates","tier":"basic"},
  {"input":{"intervals":[[1,2],[2,3]]},"expected":0,"description":"Edge: no overlap","tier":"edge"},
  {"input":{"intervals":[[1,2]]},"expected":0,"description":"Edge: single interval","tier":"edge"},
  {"input":{"intervals":[[0,2],[1,3],[2,4],[3,5],[4,6]]},"expected":2,"description":"Corner: chain of overlaps","tier":"corner"},
  {"input":{"intervals":[[1,100],[11,22],[1,11],[2,12]]},"expected":2,"description":"Corner: large spanning interval","tier":"corner"}
]'::jsonb where slug = 'non-overlapping-intervals';

update questions set test_cases = '[
  {"input":{"intervals":[[0,30],[5,10],[15,20]]},"expected":false,"description":"Basic: overlap exists","tier":"basic"},
  {"input":{"intervals":[[7,10],[2,4]]},"expected":true,"description":"Basic: no overlap","tier":"basic"},
  {"input":{"intervals":[[1,2]]},"expected":true,"description":"Edge: single meeting","tier":"edge"},
  {"input":{"intervals":[[1,2],[2,3]]},"expected":true,"description":"Edge: adjacent meetings ok","tier":"edge"},
  {"input":{"intervals":[[1,5],[2,3],[4,6]]},"expected":false,"description":"Corner: multiple overlaps","tier":"corner"}
]'::jsonb where slug = 'meeting-rooms';

update questions set test_cases = '[
  {"input":{"intervals":[[0,30],[5,10],[15,20]]},"expected":2,"description":"Basic: two rooms needed","tier":"basic"},
  {"input":{"intervals":[[7,10],[2,4]]},"expected":1,"description":"Basic: one room enough","tier":"basic"},
  {"input":{"intervals":[[1,2]]},"expected":1,"description":"Edge: single meeting","tier":"edge"},
  {"input":{"intervals":[[1,4],[2,5],[3,6]]},"expected":3,"description":"Edge: all overlap","tier":"edge"},
  {"input":{"intervals":[[1,10],[2,7],[3,19],[8,12],[10,20],[11,30]]},"expected":3,"description":"Corner: varied overlaps","tier":"corner"},
  {"input":{"intervals":[[1,2],[2,3],[3,4]]},"expected":1,"description":"Corner: sequential meetings","tier":"corner"}
]'::jsonb where slug = 'meeting-rooms-ii';

update questions set test_cases = '[
  {"input":{"intervals":[[1,4],[2,4],[3,6],[4,4]],"queries":[2,3,4,5]},"expected":[3,3,1,4],"description":"Basic: various queries","tier":"basic"},
  {"input":{"intervals":[[2,3],[2,5],[1,8],[20,25]],"queries":[2,19,5,22]},"expected":[2,-1,4,6],"description":"Basic: some no match","tier":"basic"},
  {"input":{"intervals":[[1,1]],"queries":[1]},"expected":[1],"description":"Edge: single interval single query","tier":"edge"},
  {"input":{"intervals":[[1,3],[2,4]],"queries":[5]},"expected":[-1],"description":"Edge: query outside all intervals","tier":"edge"},
  {"input":{"intervals":[[1,10],[2,3],[3,4]],"queries":[3]},"expected":[2],"description":"Corner: pick smallest containing","tier":"corner"}
]'::jsonb where slug = 'min-interval-include-query';
