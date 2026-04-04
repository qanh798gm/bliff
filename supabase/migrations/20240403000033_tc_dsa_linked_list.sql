-- ============================================================
-- Test Cases: DSA — Linked List
-- Note: Linked list problems use array representations for input/output.
--       The test runner function signatures use arrays internally
--       and convert to linked list nodes, so inputs are arrays.
-- Questions: reverse-linked-list, merge-two-sorted-lists,
--            linked-list-cycle, remove-nth-from-end,
--            copy-list-random-pointer, add-two-numbers,
--            find-duplicate-number, lru-cache,
--            merge-k-sorted-lists, reverse-nodes-k-group
-- ============================================================

-- ── Reverse Linked List ──────────────────────────────────────
update questions set test_cases = '[
  {"input":{"head":[1,2,3,4,5]},"expected":[5,4,3,2,1],"description":"Basic: five nodes","tier":"basic"},
  {"input":{"head":[1,2]},"expected":[2,1],"description":"Basic: two nodes","tier":"basic"},
  {"input":{"head":[1]},"expected":[1],"description":"Edge: single node","tier":"edge"},
  {"input":{"head":[]},"expected":[],"description":"Edge: empty list","tier":"edge"},
  {"input":{"head":[1,2,3]},"expected":[3,2,1],"description":"Edge: three nodes","tier":"edge"},
  {"input":{"head":[1,1,1]},"expected":[1,1,1],"description":"Corner: all same values","tier":"corner"},
  {"input":{"head":[-1,-2,-3]},"expected":[-3,-2,-1],"description":"Corner: negative values","tier":"corner"},
  {"input":{"head":[1,2,3,4,5,6,7,8]},"expected":[8,7,6,5,4,3,2,1],"description":"Corner: eight nodes","tier":"corner"}
]'::jsonb where slug = 'reverse-linked-list';

-- ── Merge Two Sorted Lists ───────────────────────────────────
update questions set test_cases = '[
  {"input":{"list1":[1,2,4],"list2":[1,3,4]},"expected":[1,1,2,3,4,4],"description":"Basic: standard merge","tier":"basic"},
  {"input":{"list1":[],"list2":[]},"expected":[],"description":"Basic: both empty","tier":"basic"},
  {"input":{"list1":[],"list2":[0]},"expected":[0],"description":"Basic: one empty","tier":"basic"},
  {"input":{"list1":[1],"list2":[1]},"expected":[1,1],"description":"Edge: single equal elements","tier":"edge"},
  {"input":{"list1":[1,3,5],"list2":[2,4,6]},"expected":[1,2,3,4,5,6],"description":"Edge: perfectly interleaved","tier":"edge"},
  {"input":{"list1":[1,2,3],"list2":[4,5,6]},"expected":[1,2,3,4,5,6],"description":"Edge: all list1 before list2","tier":"edge"},
  {"input":{"list1":[-3,-1,0],"list2":[-2,1,2]},"expected":[-3,-2,-1,0,1,2],"description":"Corner: negative values","tier":"corner"},
  {"input":{"list1":[1,1,1],"list2":[1,1,1]},"expected":[1,1,1,1,1,1],"description":"Corner: all duplicates","tier":"corner"}
]'::jsonb where slug = 'merge-two-sorted-lists';

-- ── Linked List Cycle ─────────────────────────────────────────
-- Input: array + pos (index where tail connects; -1 = no cycle)
update questions set test_cases = '[
  {"input":{"head":[3,2,0,-4],"pos":1},"expected":true,"description":"Basic: cycle at node 1","tier":"basic"},
  {"input":{"head":[1,2],"pos":0},"expected":true,"description":"Basic: cycle back to head","tier":"basic"},
  {"input":{"head":[1],"pos":-1},"expected":false,"description":"Basic: single no cycle","tier":"basic"},
  {"input":{"head":[],"pos":-1},"expected":false,"description":"Edge: empty no cycle","tier":"edge"},
  {"input":{"head":[1,2,3,4,5],"pos":-1},"expected":false,"description":"Edge: five nodes no cycle","tier":"edge"},
  {"input":{"head":[1,2,3],"pos":2},"expected":true,"description":"Edge: cycle at last node","tier":"edge"},
  {"input":{"head":[1,2,3,4,5],"pos":0},"expected":true,"description":"Corner: tail back to head","tier":"corner"},
  {"input":{"head":[1,2],"pos":-1},"expected":false,"description":"Corner: two nodes no cycle","tier":"corner"}
]'::jsonb where slug = 'linked-list-cycle';

-- ── Remove Nth Node From End ──────────────────────────────────
update questions set test_cases = '[
  {"input":{"head":[1,2,3,4,5],"n":2},"expected":[1,2,3,5],"description":"Basic: remove second from end","tier":"basic"},
  {"input":{"head":[1],"n":1},"expected":[],"description":"Basic: remove only node","tier":"basic"},
  {"input":{"head":[1,2],"n":1},"expected":[1],"description":"Basic: remove last","tier":"basic"},
  {"input":{"head":[1,2],"n":2},"expected":[2],"description":"Edge: remove head (2-node list)","tier":"edge"},
  {"input":{"head":[1,2,3],"n":3},"expected":[2,3],"description":"Edge: remove head (3-node list)","tier":"edge"},
  {"input":{"head":[1,2,3,4,5],"n":5},"expected":[2,3,4,5],"description":"Edge: remove head (5-node list)","tier":"edge"},
  {"input":{"head":[1,2,3],"n":2},"expected":[1,3],"description":"Corner: remove middle","tier":"corner"},
  {"input":{"head":[1,2,3,4,5],"n":1},"expected":[1,2,3,4],"description":"Corner: remove last (5-node list)","tier":"corner"}
]'::jsonb where slug = 'remove-nth-from-end';

-- ── Add Two Numbers ───────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"l1":[2,4,3],"l2":[5,6,4]},"expected":[7,0,8],"description":"Basic: 342+465=807","tier":"basic"},
  {"input":{"l1":[0],"l2":[0]},"expected":[0],"description":"Basic: zero plus zero","tier":"basic"},
  {"input":{"l1":[9,9,9,9,9,9,9],"l2":[9,9,9,9]},"expected":[8,9,9,9,0,0,0,1],"description":"Basic: carry propagation","tier":"basic"},
  {"input":{"l1":[1],"l2":[9,9]},"expected":[0,0,1],"description":"Edge: different lengths carry","tier":"edge"},
  {"input":{"l1":[5],"l2":[5]},"expected":[0,1],"description":"Edge: single digit carry","tier":"edge"},
  {"input":{"l1":[1,8],"l2":[0]},"expected":[1,8],"description":"Edge: second is zero","tier":"edge"},
  {"input":{"l1":[9],"l2":[1,9,9,9,9,9,9,9,9,9]},"expected":[0,0,0,0,0,0,0,0,0,0,1],"description":"Corner: long carry chain","tier":"corner"},
  {"input":{"l1":[2,4,9],"l2":[5,6,4,9]},"expected":[7,0,4,0,1],"description":"Corner: different length with carry","tier":"corner"}
]'::jsonb where slug = 'add-two-numbers';

-- ── Find the Duplicate Number ─────────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[1,3,4,2,2]},"expected":2,"description":"Basic: duplicate at middle","tier":"basic"},
  {"input":{"nums":[3,1,3,4,2]},"expected":3,"description":"Basic: duplicate at index 0 and 2","tier":"basic"},
  {"input":{"nums":[1,1]},"expected":1,"description":"Basic: smallest possible","tier":"basic"},
  {"input":{"nums":[2,2,2,2,2]},"expected":2,"description":"Edge: all duplicates same","tier":"edge"},
  {"input":{"nums":[1,2,3,4,4]},"expected":4,"description":"Edge: duplicate at end","tier":"edge"},
  {"input":{"nums":[4,3,1,4,2]},"expected":4,"description":"Edge: duplicate spread out","tier":"edge"},
  {"input":{"nums":[2,5,9,6,9,3,8,9,7,1]},"expected":9,"description":"Corner: large array","tier":"corner"},
  {"input":{"nums":[1,2,3,4,5,6,7,8,9,9]},"expected":9,"description":"Corner: duplicate at very end","tier":"corner"}
]'::jsonb where slug = 'find-duplicate-number';

-- ── LRU Cache ─────────────────────────────────────────────────
-- Operations as arrays: ["LRUCache","put","put","get","put","get","put","get","get","get"]
update questions set test_cases = '[
  {"input":{"capacity":2,"ops":["put","put","get","put","get","put","get","get","get"],"args":[[1,1],[2,2],[1],[3,3],[2],[4,4],[1],[3],[4]]},"expected":[null,null,1,null,-1,null,-1,3,4],"description":"Basic: classic LRU eviction","tier":"basic"},
  {"input":{"capacity":1,"ops":["put","put","get"],"args":[[1,1],[2,2],[2]]},"expected":[null,null,2],"description":"Basic: capacity 1","tier":"basic"},
  {"input":{"capacity":2,"ops":["put","get"],"args":[[1,10],[1]]},"expected":[null,10],"description":"Edge: put then get same key","tier":"edge"},
  {"input":{"capacity":2,"ops":["get"],"args":[[1]]},"expected":[-1],"description":"Edge: get from empty cache","tier":"edge"},
  {"input":{"capacity":2,"ops":["put","put","put","get","get"],"args":[[1,1],[2,2],[1,10],[1],[2]]},"expected":[null,null,null,10,2],"description":"Corner: update existing key","tier":"corner"},
  {"input":{"capacity":3,"ops":["put","put","put","get","put","get","get"],"args":[[1,1],[2,2],[3,3],[1],[4,4],[2],[3]]},"expected":[null,null,null,1,null,-1,3],"description":"Corner: access refreshes order","tier":"corner"}
]'::jsonb where slug = 'lru-cache';

-- ── Merge K Sorted Lists ──────────────────────────────────────
update questions set test_cases = '[
  {"input":{"lists":[[1,4,5],[1,3,4],[2,6]]},"expected":[1,1,2,3,4,4,5,6],"description":"Basic: three lists","tier":"basic"},
  {"input":{"lists":[]},"expected":[],"description":"Basic: empty input","tier":"basic"},
  {"input":{"lists":[[]]},"expected":[],"description":"Basic: single empty list","tier":"basic"},
  {"input":{"lists":[[1],[2],[3]]},"expected":[1,2,3],"description":"Edge: single element lists","tier":"edge"},
  {"input":{"lists":[[1,2,3],[4,5,6],[7,8,9]]},"expected":[1,2,3,4,5,6,7,8,9],"description":"Edge: non-overlapping ranges","tier":"edge"},
  {"input":{"lists":[[1,1,1],[1,1,1]]},"expected":[1,1,1,1,1,1],"description":"Edge: all duplicates","tier":"edge"},
  {"input":{"lists":[[-1,0,1],[-2,0,2],[-3,0,3]]},"expected":[-3,-2,-1,0,0,0,1,2,3],"description":"Corner: negatives mixed","tier":"corner"},
  {"input":{"lists":[[1,4,7],[2,5,8],[3,6,9]]},"expected":[1,2,3,4,5,6,7,8,9],"description":"Corner: perfectly interleaved","tier":"corner"}
]'::jsonb where slug = 'merge-k-sorted-lists';

-- ── Reverse Nodes in k-Group ──────────────────────────────────
update questions set test_cases = '[
  {"input":{"head":[1,2,3,4,5],"k":2},"expected":[2,1,4,3,5],"description":"Basic: k=2 odd length","tier":"basic"},
  {"input":{"head":[1,2,3,4,5],"k":3},"expected":[3,2,1,4,5],"description":"Basic: k=3 remainder stays","tier":"basic"},
  {"input":{"head":[1,2,3,4],"k":4},"expected":[4,3,2,1],"description":"Basic: k equals length","tier":"basic"},
  {"input":{"head":[1],"k":1},"expected":[1],"description":"Edge: single node k=1","tier":"edge"},
  {"input":{"head":[1,2],"k":2},"expected":[2,1],"description":"Edge: two nodes k=2","tier":"edge"},
  {"input":{"head":[1,2,3],"k":1},"expected":[1,2,3],"description":"Edge: k=1 no change","tier":"edge"},
  {"input":{"head":[1,2,3,4,5,6],"k":2},"expected":[2,1,4,3,6,5],"description":"Corner: even length even k","tier":"corner"},
  {"input":{"head":[1,2,3,4,5,6,7,8],"k":3},"expected":[3,2,1,6,5,4,7,8],"description":"Corner: k=3 remainder","tier":"corner"}
]'::jsonb where slug = 'reverse-nodes-k-group';
