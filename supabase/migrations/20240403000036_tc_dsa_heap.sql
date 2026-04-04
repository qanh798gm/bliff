-- Test Cases: DSA — Heap / Priority Queue
-- kth-largest-in-stream, last-stone-weight, k-closest-points-origin,
-- kth-largest-in-array, task-scheduler, find-median-data-stream

-- ── Kth Largest Element in a Stream ─────────────────────────
update questions set test_cases = '[
  {"input":{"k":3,"nums":[4,5,8,2],"adds":[3,5,10,9,4]},"expected":[4,5,5,8,8],"description":"Basic: classic stream","tier":"basic"},
  {"input":{"k":1,"nums":[2],"adds":[3]},"expected":[3],"description":"Basic: k=1 always max","tier":"basic"},
  {"input":{"k":3,"nums":[],"adds":[1,2,3]},"expected":[null,null,1],"description":"Edge: empty init build up","tier":"edge"},
  {"input":{"k":2,"nums":[1],"adds":[1]},"expected":[1],"description":"Edge: duplicate values","tier":"edge"}
]'::jsonb where slug = 'kth-largest-in-stream';

-- ── Last Stone Weight ────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"stones":[2,7,4,1,8,1]},"expected":1,"description":"Basic: one stone remains","tier":"basic"},
  {"input":{"stones":[1]},"expected":1,"description":"Edge: single stone","tier":"edge"},
  {"input":{"stones":[1,1]},"expected":0,"description":"Edge: two equal stones","tier":"edge"},
  {"input":{"stones":[2,2]},"expected":0,"description":"Edge: both destroyed","tier":"edge"},
  {"input":{"stones":[3,7,2]},"expected":2,"description":"Corner: three stones","tier":"corner"},
  {"input":{"stones":[10,4,2,10]},"expected":2,"description":"Corner: multiple rounds","tier":"corner"}
]'::jsonb where slug = 'last-stone-weight';

-- ── K Closest Points to Origin ───────────────────────────────
update questions set test_cases = '[
  {"input":{"points":[[1,3],[-2,2]],"k":1},"expected":[[-2,2]],"description":"Basic: closest of two","tier":"basic"},
  {"input":{"points":[[3,3],[5,-1],[-2,4]],"k":2},"expected":[[3,3],[-2,4]],"description":"Basic: two closest","tier":"basic"},
  {"input":{"points":[[1,3]],"k":1},"expected":[[1,3]],"description":"Edge: single point","tier":"edge"},
  {"input":{"points":[[0,0],[1,1]],"k":1},"expected":[[0,0]],"description":"Edge: origin is closest","tier":"edge"},
  {"input":{"points":[[1,0],[0,1]],"k":2},"expected":[[1,0],[0,1]],"description":"Corner: equal distances","tier":"corner"}
]'::jsonb where slug = 'k-closest-points-origin';

-- ── Kth Largest Element in an Array ─────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[3,2,1,5,6,4],"k":2},"expected":5,"description":"Basic: 2nd largest","tier":"basic"},
  {"input":{"nums":[3,2,3,1,2,4,5,5,6],"k":4},"expected":4,"description":"Basic: 4th largest with dups","tier":"basic"},
  {"input":{"nums":[1],"k":1},"expected":1,"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[2,1],"k":2},"expected":1,"description":"Edge: k=2 of two elements","tier":"edge"},
  {"input":{"nums":[-1,-1],"k":2},"expected":-1,"description":"Corner: negative duplicates","tier":"corner"},
  {"input":{"nums":[7,6,5,4,3,2,1],"k":5},"expected":3,"description":"Corner: k=5 descending array","tier":"corner"}
]'::jsonb where slug = 'kth-largest-in-array';

-- ── Task Scheduler ────────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"tasks":["A","A","A","B","B","B"],"n":2},"expected":8,"description":"Basic: two tasks n=2","tier":"basic"},
  {"input":{"tasks":["A","A","A","B","B","B"],"n":0},"expected":6,"description":"Basic: no cooldown","tier":"basic"},
  {"input":{"tasks":["A","A","A","A","A","A","B","C","D","E","F","G"],"n":2},"expected":16,"description":"Basic: dominant task forces idles","tier":"basic"},
  {"input":{"tasks":["A"],"n":1},"expected":1,"description":"Edge: single task","tier":"edge"},
  {"input":{"tasks":["A","B"],"n":2},"expected":3,"description":"Edge: two tasks need idle","tier":"edge"},
  {"input":{"tasks":["A","A","A","B","B","C","C"],"n":1},"expected":7,"description":"Corner: no idle needed enough variety","tier":"corner"}
]'::jsonb where slug = 'task-scheduler';

-- ── Find Median from Data Stream ─────────────────────────────
update questions set test_cases = '[
  {"input":{"ops":["addNum","addNum","findMedian","addNum","findMedian"],"args":[1,2,null,3,null]},"expected":[null,null,1.5,null,2.0],"description":"Basic: growing stream","tier":"basic"},
  {"input":{"ops":["addNum","findMedian"],"args":[1,null]},"expected":[null,1.0],"description":"Edge: single element","tier":"edge"},
  {"input":{"ops":["addNum","addNum","findMedian"],"args":[2,1,null]},"expected":[null,null,1.5],"description":"Edge: two elements","tier":"edge"},
  {"input":{"ops":["addNum","addNum","addNum","findMedian"],"args":[1,1,1,null]},"expected":[null,null,null,1.0],"description":"Corner: all same values","tier":"corner"},
  {"input":{"ops":["addNum","addNum","addNum","addNum","findMedian"],"args":[-1,-2,-3,-4,null]},"expected":[null,null,null,null,-2.5],"description":"Corner: all negatives","tier":"corner"}
]'::jsonb where slug = 'find-median-data-stream';
