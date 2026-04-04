-- ============================================================
-- Test Cases: DSA — Binary Search
-- Questions: search-2d-matrix, koko-eating-bananas,
--            find-min-rotated-bs, search-rotated-sorted-bs,
--            time-based-key-value-store, median-two-sorted-arrays
-- ============================================================

-- ── Search a 2D Matrix ───────────────────────────────────────
update questions set test_cases = '[
  {"input":{"matrix":[[1,3,5,7],[10,11,16,20],[23,30,34,60]],"target":3},"expected":true,"description":"Basic: found in first row","tier":"basic"},
  {"input":{"matrix":[[1,3,5,7],[10,11,16,20],[23,30,34,60]],"target":13},"expected":false,"description":"Basic: not found","tier":"basic"},
  {"input":{"matrix":[[1]],"target":1},"expected":true,"description":"Basic: 1x1 matrix hit","tier":"basic"},
  {"input":{"matrix":[[1]],"target":2},"expected":false,"description":"Edge: 1x1 matrix miss","tier":"edge"},
  {"input":{"matrix":[[1,3]],"target":3},"expected":true,"description":"Edge: 1x2 found at end","tier":"edge"},
  {"input":{"matrix":[[1,3]],"target":0},"expected":false,"description":"Edge: less than minimum","tier":"edge"},
  {"input":{"matrix":[[1,3,5],[7,9,11],[13,15,17]],"target":13},"expected":true,"description":"Corner: first of third row","tier":"corner"},
  {"input":{"matrix":[[1,3,5],[7,9,11],[13,15,17]],"target":6},"expected":false,"description":"Corner: between rows","tier":"corner"}
]'::jsonb where slug = 'search-2d-matrix';

-- ── Koko Eating Bananas ──────────────────────────────────────
update questions set test_cases = '[
  {"input":{"piles":[3,6,7,11],"h":8},"expected":4,"description":"Basic: classic case","tier":"basic"},
  {"input":{"piles":[30,11,23,4,20],"h":5},"expected":30,"description":"Basic: must finish in exact hours","tier":"basic"},
  {"input":{"piles":[30,11,23,4,20],"h":6},"expected":23,"description":"Basic: one extra hour","tier":"basic"},
  {"input":{"piles":[1],"h":1},"expected":1,"description":"Edge: single pile exact","tier":"edge"},
  {"input":{"piles":[1,1,1,1],"h":4},"expected":1,"description":"Edge: all piles size 1","tier":"edge"},
  {"input":{"piles":[1000000000],"h":2},"expected":500000000,"description":"Edge: huge pile two hours","tier":"edge"},
  {"input":{"piles":[3,6,7,11],"h":4},"expected":11,"description":"Corner: minimum hours = num piles","tier":"corner"},
  {"input":{"piles":[2,2],"h":2},"expected":2,"description":"Corner: exact fit at pile max","tier":"corner"}
]'::jsonb where slug = 'koko-eating-bananas';

-- ── Find Min in Rotated Sorted Array ────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[3,4,5,1,2]},"expected":1,"description":"Basic: rotation in middle","tier":"basic"},
  {"input":{"nums":[4,5,6,7,0,1,2]},"expected":0,"description":"Basic: classic rotation","tier":"basic"},
  {"input":{"nums":[11,13,15,17]},"expected":11,"description":"Basic: no rotation","tier":"basic"},
  {"input":{"nums":[1]},"expected":1,"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[2,1]},"expected":1,"description":"Edge: two elements rotated","tier":"edge"},
  {"input":{"nums":[1,2]},"expected":1,"description":"Edge: two elements not rotated","tier":"edge"},
  {"input":{"nums":[5,1,2,3,4]},"expected":1,"description":"Corner: rotated to second position","tier":"corner"},
  {"input":{"nums":[2,3,4,5,1]},"expected":1,"description":"Corner: min at end","tier":"corner"}
]'::jsonb where slug = 'find-min-rotated-bs';

-- ── Search in Rotated Sorted Array ──────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[4,5,6,7,0,1,2],"target":0},"expected":4,"description":"Basic: target in right half","tier":"basic"},
  {"input":{"nums":[4,5,6,7,0,1,2],"target":3},"expected":-1,"description":"Basic: target not found","tier":"basic"},
  {"input":{"nums":[1],"target":0},"expected":-1,"description":"Basic: single element miss","tier":"basic"},
  {"input":{"nums":[1],"target":1},"expected":0,"description":"Edge: single element hit","tier":"edge"},
  {"input":{"nums":[3,1],"target":1},"expected":1,"description":"Edge: two elements rotated","tier":"edge"},
  {"input":{"nums":[1,3],"target":3},"expected":1,"description":"Edge: two elements not rotated","tier":"edge"},
  {"input":{"nums":[5,1,3],"target":5},"expected":0,"description":"Corner: target is rotation pivot","tier":"corner"},
  {"input":{"nums":[4,5,6,7,8,1,2,3],"target":8},"expected":4,"description":"Corner: target just before pivot","tier":"corner"}
]'::jsonb where slug = 'search-rotated-sorted-bs';

-- ── Time Based Key-Value Store ───────────────────────────────
-- Design problem: test set/get sequence as ops
update questions set test_cases = '[
  {"input":{"ops":["set","get","get","set","get","get"],"args":[["foo","bar",1],["foo",1],["foo",3],["foo","bar2",4],["foo",4],["foo",5]]},"expected":[null,"bar","bar",null,"bar2","bar2"],"description":"Basic: set then get at various timestamps","tier":"basic"},
  {"input":{"ops":["set","get"],"args":[["a","1",1],["a",2]]},"expected":[null,"1"],"description":"Basic: get after timestamp","tier":"basic"},
  {"input":{"ops":["set","get"],"args":[["a","1",5],["a",3]]},"expected":[null,""],"description":"Edge: get before earliest set","tier":"edge"},
  {"input":{"ops":["set","get"],"args":[["a","1",1],["a",1]]},"expected":[null,"1"],"description":"Edge: get at exact timestamp","tier":"edge"},
  {"input":{"ops":["set","set","get","get"],"args":[["a","v1",1],["a","v2",3],["a",2],["a",4]]},"expected":[null,null,"v1","v2"],"description":"Corner: two versions of same key","tier":"corner"}
]'::jsonb where slug = 'time-based-key-value-store';

-- ── Median of Two Sorted Arrays ──────────────────────────────
update questions set test_cases = '[
  {"input":{"nums1":[1,3],"nums2":[2]},"expected":2.0,"description":"Basic: odd total length","tier":"basic"},
  {"input":{"nums1":[1,2],"nums2":[3,4]},"expected":2.5,"description":"Basic: even total length","tier":"basic"},
  {"input":{"nums1":[],"nums2":[1]},"expected":1.0,"description":"Edge: one empty array","tier":"edge"},
  {"input":{"nums1":[],"nums2":[2,3]},"expected":2.5,"description":"Edge: empty + two elements","tier":"edge"},
  {"input":{"nums1":[1],"nums2":[1]},"expected":1.0,"description":"Edge: duplicate single elements","tier":"edge"},
  {"input":{"nums1":[1,2],"nums2":[1,2]},"expected":1.5,"description":"Corner: identical arrays","tier":"corner"},
  {"input":{"nums1":[1,3,5],"nums2":[2,4,6]},"expected":3.5,"description":"Corner: interleaved","tier":"corner"},
  {"input":{"nums1":[100000],"nums2":[100001]},"expected":100000.5,"description":"Corner: large values","tier":"corner"}
]'::jsonb where slug = 'median-two-sorted-arrays';
