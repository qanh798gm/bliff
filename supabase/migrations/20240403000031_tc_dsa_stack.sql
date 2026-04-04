-- ============================================================
-- Test Cases: DSA — Stack
-- Questions: valid-parentheses, min-stack, evaluate-reverse-polish-notation,
--            generate-parentheses, daily-temperatures,
--            car-fleet, largest-rectangle-histogram
-- ============================================================

-- ── Valid Parentheses ────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"s":"()"},"expected":true,"description":"Basic: single pair","tier":"basic"},
  {"input":{"s":"()[]{}"},"expected":true,"description":"Basic: all three types","tier":"basic"},
  {"input":{"s":"(]"},"expected":false,"description":"Basic: mismatched","tier":"basic"},
  {"input":{"s":""},"expected":true,"description":"Edge: empty string","tier":"edge"},
  {"input":{"s":"["},"expected":false,"description":"Edge: single open","tier":"edge"},
  {"input":{"s":"(((((("},"expected":false,"description":"Edge: all opens","tier":"edge"},
  {"input":{"s":"([)]"},"expected":false,"description":"Corner: interleaved mismatch","tier":"corner"},
  {"input":{"s":"{[]}"},"expected":true,"description":"Corner: nested all types","tier":"corner"}
]'::jsonb where slug = 'valid-parentheses';

-- ── Min Stack ─────────────────────────────────────────────────
-- Note: min-stack is a design problem; test the push/pop/getMin sequence
update questions set test_cases = '[
  {"input":{"ops":["push","push","push","getMin","pop","top","getMin"],"vals":[-2,0,-3,null,null,null,null]},"expected":[null,null,null,-3,null,0,-2],"description":"Basic: classic sequence","tier":"basic"},
  {"input":{"ops":["push","getMin"],"vals":[5,null]},"expected":[null,5],"description":"Basic: single element","tier":"basic"},
  {"input":{"ops":["push","push","getMin","pop","getMin"],"vals":[0,1,null,null,null]},"expected":[null,null,0,null,0],"description":"Edge: pop max keeps min","tier":"edge"},
  {"input":{"ops":["push","push","push","pop","pop","getMin"],"vals":[3,2,1,null,null,null]},"expected":[null,null,null,null,null,3],"description":"Edge: pop all below","tier":"edge"},
  {"input":{"ops":["push","push","getMin","pop","getMin"],"vals":[1,1,null,null,null]},"expected":[null,null,1,null,1],"description":"Corner: duplicate minimums","tier":"corner"},
  {"input":{"ops":["push","push","push","push","getMin"],"vals":[4,3,2,1,null]},"expected":[null,null,null,null,1],"description":"Corner: descending push","tier":"corner"}
]'::jsonb where slug = 'min-stack';

-- ── Evaluate Reverse Polish Notation ────────────────────────
update questions set test_cases = '[
  {"input":{"tokens":["2","1","+","3","*"]},"expected":9,"description":"Basic: (2+1)*3","tier":"basic"},
  {"input":{"tokens":["4","13","5","/","+"]},"expected":6,"description":"Basic: 4+(13/5)","tier":"basic"},
  {"input":{"tokens":["10","6","9","3","+","-11","*","/","*","17","+","5","+"]},"expected":22,"description":"Basic: complex expression","tier":"basic"},
  {"input":{"tokens":["3"]},"expected":3,"description":"Edge: single number","tier":"edge"},
  {"input":{"tokens":["2","1","-"]},"expected":1,"description":"Edge: subtraction","tier":"edge"},
  {"input":{"tokens":["3","4","*"]},"expected":12,"description":"Edge: multiplication","tier":"edge"},
  {"input":{"tokens":["5","1","2","+","4","*","+","3","-"]},"expected":14,"description":"Corner: nested ops","tier":"corner"},
  {"input":{"tokens":["-2","3","*"]},"expected":-6,"description":"Corner: negative operand","tier":"corner"}
]'::jsonb where slug = 'evaluate-reverse-polish-notation';

-- ── Generate Parentheses ─────────────────────────────────────
update questions set test_cases = '[
  {"input":{"n":3},"expected":["((()))","(()())","(())()","()(())","()()()"],"description":"Basic: n=3 five combinations","tier":"basic"},
  {"input":{"n":1},"expected":["()"],"description":"Basic: n=1","tier":"basic"},
  {"input":{"n":2},"expected":["(())","()()"],"description":"Basic: n=2","tier":"basic"},
  {"input":{"n":4},"expected":["(((())))","((()()))","((())())","((()))()","(()(()))","(()()())","(()())()","(())(())","(())()()","()((())) ","()((()))","()(()())","()(())()","()()(())","()()()()"],"description":"Edge: n=4 many combinations","tier":"edge"}
]'::jsonb where slug = 'generate-parentheses';

-- ── Daily Temperatures ───────────────────────────────────────
update questions set test_cases = '[
  {"input":{"temperatures":[73,74,75,71,69,72,76,73]},"expected":[1,1,4,2,1,1,0,0],"description":"Basic: classic monotonic stack","tier":"basic"},
  {"input":{"temperatures":[30,40,50,60]},"expected":[1,1,1,0],"description":"Basic: ascending","tier":"basic"},
  {"input":{"temperatures":[30,60,90]},"expected":[1,1,0],"description":"Basic: always warmer next day","tier":"basic"},
  {"input":{"temperatures":[90]},"expected":[0],"description":"Edge: single temperature","tier":"edge"},
  {"input":{"temperatures":[90,80,70]},"expected":[0,0,0],"description":"Edge: descending never warmer","tier":"edge"},
  {"input":{"temperatures":[70,70,70]},"expected":[0,0,0],"description":"Edge: all same","tier":"edge"},
  {"input":{"temperatures":[55,38,53,81,61,93,97,32,43,78]},"expected":[3,1,1,2,1,1,0,2,1,0],"description":"Corner: varied sequence","tier":"corner"},
  {"input":{"temperatures":[34,80,80,34,34,80,80,80,80,34]},"expected":[1,0,0,2,1,0,0,0,0,0],"description":"Corner: repeated groups","tier":"corner"}
]'::jsonb where slug = 'daily-temperatures';

-- ── Car Fleet ────────────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"target":12,"position":[10,8,0,5,3],"speed":[2,4,1,1,3]},"expected":3,"description":"Basic: three fleets","tier":"basic"},
  {"input":{"target":10,"position":[3],"speed":[3]},"expected":1,"description":"Basic: single car","tier":"basic"},
  {"input":{"target":100,"position":[0,2,4],"speed":[4,2,1]},"expected":1,"description":"Basic: all merge into one","tier":"basic"},
  {"input":{"target":10,"position":[6,8],"speed":[3,2]},"expected":2,"description":"Edge: faster behind slower","tier":"edge"},
  {"input":{"target":10,"position":[0,4,2],"speed":[2,1,3]},"expected":1,"description":"Edge: rear catches front","tier":"edge"},
  {"input":{"target":10,"position":[8,3,7,4,6,5],"speed":[4,4,4,4,4,4]},"expected":6,"description":"Edge: all same speed","tier":"edge"},
  {"input":{"target":10,"position":[9],"speed":[1]},"expected":1,"description":"Corner: one car one step away","tier":"corner"},
  {"input":{"target":10,"position":[0,2,4,6,8],"speed":[5,4,3,2,1]},"expected":5,"description":"Corner: each slower but already ahead","tier":"corner"}
]'::jsonb where slug = 'car-fleet';

-- ── Largest Rectangle in Histogram ──────────────────────────
update questions set test_cases = '[
  {"input":{"heights":[2,1,5,6,2,3]},"expected":10,"description":"Basic: classic histogram","tier":"basic"},
  {"input":{"heights":[2,4]},"expected":4,"description":"Basic: two bars","tier":"basic"},
  {"input":{"heights":[1,1]},"expected":2,"description":"Basic: two same","tier":"basic"},
  {"input":{"heights":[1]},"expected":1,"description":"Edge: single bar","tier":"edge"},
  {"input":{"heights":[0]},"expected":0,"description":"Edge: zero height","tier":"edge"},
  {"input":{"heights":[5,5,5,5]},"expected":20,"description":"Edge: all same height","tier":"edge"},
  {"input":{"heights":[6,7,5,2,4,5,9,3]},"expected":16,"description":"Corner: varied heights","tier":"corner"},
  {"input":{"heights":[1,2,3,4,5]},"expected":9,"description":"Corner: ascending staircase","tier":"corner"}
]'::jsonb where slug = 'largest-rectangle-histogram';
