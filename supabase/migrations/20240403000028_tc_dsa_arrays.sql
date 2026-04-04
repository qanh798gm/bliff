-- ============================================================
-- Test Cases: DSA — Arrays
-- Questions: two-sum, contains-duplicate, product-except-self,
--            best-time-to-buy-sell-stock, maximum-subarray,
--            maximum-product-subarray, 3Sum, container-with-most-water
-- Tiers: basic | edge | corner
-- orderIndependent: true for index-pair results (Two Sum, 3Sum)
-- ============================================================

-- ── Two Sum ─────────────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[2,7,11,15],"target":9},"expected":[0,1],"description":"Basic: first two sum to target","tier":"basic","orderIndependent":true},
  {"input":{"nums":[3,2,4],"target":6},"expected":[1,2],"description":"Basic: non-adjacent pair","tier":"basic","orderIndependent":true},
  {"input":{"nums":[3,3],"target":6},"expected":[0,1],"description":"Basic: duplicate values","tier":"basic","orderIndependent":true},
  {"input":{"nums":[1,2,3,4,5],"target":9},"expected":[3,4],"description":"Edge: last two elements","tier":"edge","orderIndependent":true},
  {"input":{"nums":[-1,-2,-3,-4,-5],"target":-8},"expected":[2,4],"description":"Edge: all negatives","tier":"edge","orderIndependent":true},
  {"input":{"nums":[0,4,3,0],"target":0},"expected":[0,3],"description":"Edge: zeros in array","tier":"edge","orderIndependent":true},
  {"input":{"nums":[1000000000,999999999,1],"target":1000000001},"expected":[0,2],"description":"Corner: large values","tier":"corner","orderIndependent":true},
  {"input":{"nums":[2,5,5,11],"target":10},"expected":[1,2],"description":"Corner: duplicate values both valid","tier":"corner","orderIndependent":true}
]'::jsonb where slug = 'two-sum';

-- ── Contains Duplicate ──────────────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[1,2,3,1]},"expected":true,"description":"Basic: duplicate at ends","tier":"basic"},
  {"input":{"nums":[1,2,3,4]},"expected":false,"description":"Basic: no duplicates","tier":"basic"},
  {"input":{"nums":[1,1,1,3,3,4,3,2,4,2]},"expected":true,"description":"Basic: many duplicates","tier":"basic"},
  {"input":{"nums":[]},"expected":false,"description":"Edge: empty array","tier":"edge"},
  {"input":{"nums":[1]},"expected":false,"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[0,0]},"expected":true,"description":"Edge: two zeros","tier":"edge"},
  {"input":{"nums":[-1,-1,2]},"expected":true,"description":"Corner: negative duplicate","tier":"corner"},
  {"input":{"nums":[2147483647,2147483647]},"expected":true,"description":"Corner: max int duplicate","tier":"corner"}
]'::jsonb where slug = 'contains-duplicate';

-- ── Product of Array Except Self ────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[1,2,3,4]},"expected":[24,12,8,6],"description":"Basic: standard case","tier":"basic"},
  {"input":{"nums":[-1,1,0,-3,3]},"expected":[0,-9,0,9,0],"description":"Basic: contains zero","tier":"basic"},
  {"input":{"nums":[2,3]},"expected":[3,2],"description":"Basic: two elements","tier":"basic"},
  {"input":{"nums":[0,0]},"expected":[0,0],"description":"Edge: two zeros","tier":"edge"},
  {"input":{"nums":[1,1,1,1]},"expected":[1,1,1,1],"description":"Edge: all ones","tier":"edge"},
  {"input":{"nums":[-1,-1,-1,-1]},"expected":[-1,-1,-1,-1],"description":"Edge: all negative ones","tier":"edge"},
  {"input":{"nums":[0,1,2,3,4]},"expected":[24,0,0,0,0],"description":"Corner: zero at start","tier":"corner"},
  {"input":{"nums":[1,2,3,0]},"expected":[0,0,0,6],"description":"Corner: zero at end","tier":"corner"}
]'::jsonb where slug = 'product-except-self';

-- ── Best Time to Buy and Sell Stock ─────────────────────────
update questions set test_cases = '[
  {"input":{"prices":[7,1,5,3,6,4]},"expected":5,"description":"Basic: buy low sell high","tier":"basic"},
  {"input":{"prices":[7,6,4,3,1]},"expected":0,"description":"Basic: decreasing prices no profit","tier":"basic"},
  {"input":{"prices":[1,2]},"expected":1,"description":"Basic: two days","tier":"basic"},
  {"input":{"prices":[2,4,1]},"expected":2,"description":"Edge: sell before drop","tier":"edge"},
  {"input":{"prices":[1]},"expected":0,"description":"Edge: single day","tier":"edge"},
  {"input":{"prices":[2,1,2,0,1]},"expected":1,"description":"Edge: multiple valleys","tier":"edge"},
  {"input":{"prices":[3,3,3,3]},"expected":0,"description":"Corner: all same price","tier":"corner"},
  {"input":{"prices":[1,10000]},"expected":9999,"description":"Corner: huge jump","tier":"corner"}
]'::jsonb where slug = 'best-time-to-buy-sell-stock';

-- ── Maximum Subarray (Kadane) ───────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[-2,1,-3,4,-1,2,1,-5,4]},"expected":6,"description":"Basic: classic Kadane","tier":"basic"},
  {"input":{"nums":[1]},"expected":1,"description":"Basic: single element","tier":"basic"},
  {"input":{"nums":[5,4,-1,7,8]},"expected":23,"description":"Basic: mostly positive","tier":"basic"},
  {"input":{"nums":[-1,-2,-3]},"expected":-1,"description":"Edge: all negative — largest single","tier":"edge"},
  {"input":{"nums":[0,0,0]},"expected":0,"description":"Edge: all zeros","tier":"edge"},
  {"input":{"nums":[-2,-1]},"expected":-1,"description":"Edge: two negatives","tier":"edge"},
  {"input":{"nums":[100,-50,100]},"expected":150,"description":"Corner: bridge over negative","tier":"corner"},
  {"input":{"nums":[-100,200,-100]},"expected":200,"description":"Corner: isolated large positive","tier":"corner"}
]'::jsonb where slug = 'maximum-subarray';

-- ── Maximum Product Subarray ────────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[2,3,-2,4]},"expected":6,"description":"Basic: break at negative","tier":"basic"},
  {"input":{"nums":[-2,0,-1]},"expected":0,"description":"Basic: zero resets product","tier":"basic"},
  {"input":{"nums":[2,3,4]},"expected":24,"description":"Basic: all positive","tier":"basic"},
  {"input":{"nums":[-2,-3,-4]},"expected":12,"description":"Edge: all negative even count","tier":"edge"},
  {"input":{"nums":[-2,-3,-4,-5]},"expected":60,"description":"Edge: all negative pick best pair","tier":"edge"},
  {"input":{"nums":[0,2]},"expected":2,"description":"Edge: leading zero","tier":"edge"},
  {"input":{"nums":[-1,0,-2]},"expected":0,"description":"Corner: zero between negatives","tier":"corner"},
  {"input":{"nums":[2,-5,-2,-4,3]},"expected":24,"description":"Corner: complex product","tier":"corner"}
]'::jsonb where slug = 'maximum-product-subarray';

-- ── 3Sum ────────────────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[-1,0,1,2,-1,-4]},"expected":[[-1,-1,2],[-1,0,1]],"description":"Basic: two valid triplets","tier":"basic"},
  {"input":{"nums":[0,1,1]},"expected":[],"description":"Basic: no valid triplet","tier":"basic"},
  {"input":{"nums":[0,0,0]},"expected":[[0,0,0]],"description":"Basic: all zeros","tier":"basic"},
  {"input":{"nums":[]},"expected":[],"description":"Edge: empty","tier":"edge"},
  {"input":{"nums":[0]},"expected":[],"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[-2,0,0,2,2]},"expected":[[-2,0,2]],"description":"Edge: duplicates filtered","tier":"edge"},
  {"input":{"nums":[-4,-1,-1,0,1,2]},"expected":[[-4,1,3],[-1,-1,2],[-1,0,1]],"description":"Corner: multiple triplets with dups","tier":"corner"},
  {"input":{"nums":[1,2,-2,-1]},"expected":[],"description":"Corner: close but no match","tier":"corner"}
]'::jsonb where slug = '3Sum';

-- ── Container With Most Water ───────────────────────────────
update questions set test_cases = '[
  {"input":{"height":[1,8,6,2,5,4,8,3,7]},"expected":49,"description":"Basic: classic case","tier":"basic"},
  {"input":{"height":[1,1]},"expected":1,"description":"Basic: two elements","tier":"basic"},
  {"input":{"height":[4,3,2,1,4]},"expected":16,"description":"Basic: same height at ends","tier":"basic"},
  {"input":{"height":[1,2,1]},"expected":2,"description":"Edge: symmetric short","tier":"edge"},
  {"input":{"height":[1,2,3,4,5]},"expected":6,"description":"Edge: increasing heights","tier":"edge"},
  {"input":{"height":[5,4,3,2,1]},"expected":6,"description":"Edge: decreasing heights","tier":"edge"},
  {"input":{"height":[10000,1,10000]},"expected":20000,"description":"Corner: tall pillars with tiny middle","tier":"corner"},
  {"input":{"height":[1,1,1,1,1,1]},"expected":5,"description":"Corner: all same height","tier":"corner"}
]'::jsonb where slug = 'container-with-most-water';
