-- ============================================================
-- Test Cases: DSA — Two Pointers
-- Questions: valid-palindrome, two-sum-ii-sorted,
--            three-sum-closest, trapping-rain-water,
--            remove-duplicates-sorted-array, move-zeroes
-- ============================================================

-- ── Valid Palindrome ─────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"s":"A man, a plan, a canal: Panama"},"expected":true,"description":"Basic: classic palindrome with punctuation","tier":"basic"},
  {"input":{"s":"race a car"},"expected":false,"description":"Basic: not a palindrome","tier":"basic"},
  {"input":{"s":" "},"expected":true,"description":"Basic: single space is palindrome","tier":"basic"},
  {"input":{"s":""},"expected":true,"description":"Edge: empty string","tier":"edge"},
  {"input":{"s":"a"},"expected":true,"description":"Edge: single char","tier":"edge"},
  {"input":{"s":".,"},"expected":true,"description":"Edge: only punctuation","tier":"edge"},
  {"input":{"s":"0P"},"expected":false,"description":"Corner: digit vs letter","tier":"corner"},
  {"input":{"s":"ab_a"},"expected":true,"description":"Corner: underscore ignored","tier":"corner"}
]'::jsonb where slug = 'valid-palindrome';

-- ── Two Sum II (Sorted Input) ────────────────────────────────
update questions set test_cases = '[
  {"input":{"numbers":[2,7,11,15],"target":9},"expected":[1,2],"description":"Basic: first pair","tier":"basic"},
  {"input":{"numbers":[2,3,4],"target":6},"expected":[1,3],"description":"Basic: ends","tier":"basic"},
  {"input":{"numbers":[-1,0],"target":-1},"expected":[1,2],"description":"Basic: negative + zero","tier":"basic"},
  {"input":{"numbers":[1,2,3,4,5,6,7,8,9,10],"target":19},"expected":[9,10],"description":"Edge: last two","tier":"edge"},
  {"input":{"numbers":[-4,-1,1,3,5],"target":2},"expected":[3,4],"description":"Edge: mixed signs","tier":"edge"},
  {"input":{"numbers":[1,3],"target":4},"expected":[1,2],"description":"Edge: two elements","tier":"edge"},
  {"input":{"numbers":[-1000,0,1000],"target":0},"expected":[1,3],"description":"Corner: large range","tier":"corner"},
  {"input":{"numbers":[2,2,9,10],"target":4},"expected":[1,2],"description":"Corner: duplicate values at start","tier":"corner"}
]'::jsonb where slug = 'two-sum-ii-sorted';

-- ── Three Sum Closest ────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[-1,2,1,-4],"target":1},"expected":2,"description":"Basic: classic case","tier":"basic"},
  {"input":{"nums":[0,0,0],"target":1},"expected":0,"description":"Basic: all zeros","tier":"basic"},
  {"input":{"nums":[1,1,1,0],"target":-100},"expected":2,"description":"Basic: best is minimum sum","tier":"basic"},
  {"input":{"nums":[-1,0,1,2],"target":3},"expected":3,"description":"Edge: exact match possible","tier":"edge"},
  {"input":{"nums":[1,2,5,10,11],"target":12},"expected":13,"description":"Edge: skip large values","tier":"edge"},
  {"input":{"nums":[-100,-99,-98],"target":0},"expected":-297,"description":"Edge: all large negatives","tier":"edge"},
  {"input":{"nums":[1,1,1],"target":3},"expected":3,"description":"Corner: all same exact match","tier":"corner"},
  {"input":{"nums":[-1,0,1,1,55],"target":3},"expected":2,"description":"Corner: duplicates present","tier":"corner"}
]'::jsonb where slug = 'three-sum-closest';

-- ── Trapping Rain Water ──────────────────────────────────────
update questions set test_cases = '[
  {"input":{"height":[0,1,0,2,1,0,1,3,2,1,2,1]},"expected":6,"description":"Basic: classic case","tier":"basic"},
  {"input":{"height":[4,2,0,3,2,5]},"expected":9,"description":"Basic: valley","tier":"basic"},
  {"input":{"height":[3,0,2,0,4]},"expected":7,"description":"Basic: two valleys","tier":"basic"},
  {"input":{"height":[]},"expected":0,"description":"Edge: empty","tier":"edge"},
  {"input":{"height":[1]},"expected":0,"description":"Edge: single bar","tier":"edge"},
  {"input":{"height":[1,2]},"expected":0,"description":"Edge: two bars no trap","tier":"edge"},
  {"input":{"height":[0,0,0,0]},"expected":0,"description":"Corner: all zeros","tier":"corner"},
  {"input":{"height":[5,5,5,5]},"expected":0,"description":"Corner: flat — no water","tier":"corner"}
]'::jsonb where slug = 'trapping-rain-water';

-- ── Remove Duplicates from Sorted Array ─────────────────────
update questions set test_cases = '[
  {"input":{"nums":[1,1,2]},"expected":2,"description":"Basic: one duplicate","tier":"basic"},
  {"input":{"nums":[0,0,1,1,1,2,2,3,3,4]},"expected":5,"description":"Basic: multiple duplicates","tier":"basic"},
  {"input":{"nums":[1,2,3]},"expected":3,"description":"Basic: no duplicates","tier":"basic"},
  {"input":{"nums":[1]},"expected":1,"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[1,1]},"expected":1,"description":"Edge: two same elements","tier":"edge"},
  {"input":{"nums":[1,1,1,1,1]},"expected":1,"description":"Edge: all same","tier":"edge"},
  {"input":{"nums":[-3,-1,-1,0,0,1]},"expected":4,"description":"Corner: negatives with duplicates","tier":"corner"},
  {"input":{"nums":[0,0,0,1,1,2,2,3]},"expected":4,"description":"Corner: many dups across zeros","tier":"corner"}
]'::jsonb where slug = 'remove-duplicates-sorted-array';

-- ── Move Zeroes ──────────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[0,1,0,3,12]},"expected":[1,3,12,0,0],"description":"Basic: zeroes scattered","tier":"basic"},
  {"input":{"nums":[0]},"expected":[0],"description":"Basic: single zero","tier":"basic"},
  {"input":{"nums":[1,0,1]},"expected":[1,1,0],"description":"Basic: middle zero","tier":"basic"},
  {"input":{"nums":[0,0,1]},"expected":[1,0,0],"description":"Edge: leading zeros","tier":"edge"},
  {"input":{"nums":[1,2,3]},"expected":[1,2,3],"description":"Edge: no zeros","tier":"edge"},
  {"input":{"nums":[0,0,0]},"expected":[0,0,0],"description":"Edge: all zeros","tier":"edge"},
  {"input":{"nums":[0,1,0,0,2,0,3]},"expected":[1,2,3,0,0,0,0],"description":"Corner: many zeros","tier":"corner"},
  {"input":{"nums":[-1,0,-2,0,3]},"expected":[-1,-2,3,0,0],"description":"Corner: negatives with zeros","tier":"corner"}
]'::jsonb where slug = 'move-zeroes';
