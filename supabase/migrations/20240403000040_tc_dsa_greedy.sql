-- Test Cases: DSA — Greedy
-- jump-game, jump-game-ii, gas-station, hand-of-straights,
-- merge-triplets-target, partition-labels, valid-parenthesis-string

update questions set test_cases = '[
  {"input":{"nums":[2,3,1,1,4]},"expected":true,"description":"Basic: can reach end","tier":"basic"},
  {"input":{"nums":[3,2,1,0,4]},"expected":false,"description":"Basic: stuck at zero","tier":"basic"},
  {"input":{"nums":[1]},"expected":true,"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[0]},"expected":true,"description":"Edge: already at end","tier":"edge"},
  {"input":{"nums":[2,0,0]},"expected":true,"description":"Edge: jump over zeros","tier":"edge"},
  {"input":{"nums":[0,1]},"expected":false,"description":"Corner: stuck at start","tier":"corner"},
  {"input":{"nums":[1,0,1,0]},"expected":false,"description":"Corner: alternating zeros","tier":"corner"}
]'::jsonb where slug = 'jump-game';

update questions set test_cases = '[
  {"input":{"nums":[2,3,1,1,4]},"expected":2,"description":"Basic: 2 jumps","tier":"basic"},
  {"input":{"nums":[2,3,0,1,4]},"expected":2,"description":"Basic: skip zero","tier":"basic"},
  {"input":{"nums":[1]},"expected":0,"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[1,2]},"expected":1,"description":"Edge: two elements","tier":"edge"},
  {"input":{"nums":[5,9,3,2,1,0,2,3,3,1,0,0]},"expected":3,"description":"Corner: long greedy","tier":"corner"},
  {"input":{"nums":[1,1,1,1,1]},"expected":4,"description":"Corner: all ones","tier":"corner"}
]'::jsonb where slug = 'jump-game-ii';

update questions set test_cases = '[
  {"input":{"gas":[1,2,3,4,5],"cost":[3,4,5,1,2]},"expected":3,"description":"Basic: start at index 3","tier":"basic"},
  {"input":{"gas":[2,3,4],"cost":[3,4,3]},"expected":-1,"description":"Basic: impossible circuit","tier":"basic"},
  {"input":{"gas":[5],"cost":[4]},"expected":0,"description":"Edge: single station surplus","tier":"edge"},
  {"input":{"gas":[1],"cost":[2]},"expected":-1,"description":"Edge: single station deficit","tier":"edge"},
  {"input":{"gas":[3,1,1],"cost":[1,2,2]},"expected":0,"description":"Corner: start at 0","tier":"corner"},
  {"input":{"gas":[1,2,3,4,5],"cost":[5,4,3,2,1]},"expected":2,"description":"Corner: start mid-array","tier":"corner"}
]'::jsonb where slug = 'gas-station';

update questions set test_cases = '[
  {"input":{"hand":[1,2,3,6,2,3,4,7,8],"groupSize":3},"expected":true,"description":"Basic: three groups","tier":"basic"},
  {"input":{"hand":[1,2,3,4,5],"groupSize":4},"expected":false,"description":"Basic: not divisible","tier":"basic"},
  {"input":{"hand":[1],"groupSize":1},"expected":true,"description":"Edge: single card","tier":"edge"},
  {"input":{"hand":[1,2,3],"groupSize":3},"expected":true,"description":"Edge: one group","tier":"edge"},
  {"input":{"hand":[8,10,12],"groupSize":3},"expected":false,"description":"Corner: gaps in sequence","tier":"corner"},
  {"input":{"hand":[1,2,3,4,5,6],"groupSize":2},"expected":true,"description":"Corner: pairs","tier":"corner"}
]'::jsonb where slug = 'hand-of-straights';

update questions set test_cases = '[
  {"input":{"triplets":[[2,5,3],[1,8,4],[1,7,5]],"target":[2,7,5]},"expected":true,"description":"Basic: achievable","tier":"basic"},
  {"input":{"triplets":[[3,4,5],[4,5,6]],"target":[3,2,5]},"expected":false,"description":"Basic: 2 not achievable","tier":"basic"},
  {"input":{"triplets":[[2,5,3],[2,3,4],[1,2,5],[5,2,3]],"target":[5,5,5]},"expected":true,"description":"Basic: merge multiple","tier":"basic"},
  {"input":{"triplets":[[1,1,1]],"target":[1,1,1]},"expected":true,"description":"Edge: exact match","tier":"edge"},
  {"input":{"triplets":[[5,7,8]],"target":[5,7,8]},"expected":true,"description":"Edge: single triplet match","tier":"edge"}
]'::jsonb where slug = 'merge-triplets-target';

update questions set test_cases = '[
  {"input":{"s":"ababcbacadefegdehijhklij"},"expected":[9,7,8],"description":"Basic: classic","tier":"basic"},
  {"input":{"s":"eccbbbbdec"},"expected":[10],"description":"Basic: one partition","tier":"basic"},
  {"input":{"s":"a"},"expected":[1],"description":"Edge: single char","tier":"edge"},
  {"input":{"s":"ab"},"expected":[1,1],"description":"Edge: two different chars","tier":"edge"},
  {"input":{"s":"aab"},"expected":[2,1],"description":"Corner: aa then b","tier":"corner"},
  {"input":{"s":"abac"},"expected":[3,1],"description":"Corner: a appears twice","tier":"corner"}
]'::jsonb where slug = 'partition-labels';

update questions set test_cases = '[
  {"input":{"s":"()"},"expected":true,"description":"Basic: simple valid","tier":"basic"},
  {"input":{"s":"(*)"},"expected":true,"description":"Basic: star as empty","tier":"basic"},
  {"input":{"s":"(*))"},"expected":true,"description":"Basic: star as open","tier":"basic"},
  {"input":{"s":"((*)"},"expected":true,"description":"Basic: star closes","tier":"basic"},
  {"input":{"s":"()"},"expected":true,"description":"Edge: no stars","tier":"edge"},
  {"input":{"s":"*"},"expected":true,"description":"Edge: just a star","tier":"edge"},
  {"input":{"s":"(*"},"expected":true,"description":"Edge: unmatched open with star","tier":"edge"},
  {"input":{"s":"(((((*(()((((*((**(((()()*)()()()*((((**)())*)*)))))))(())(()))())((*()()(((()((()*(())*(()**)()(())"},"expected":false,"description":"Corner: complex invalid","tier":"corner"}
]'::jsonb where slug = 'valid-parenthesis-string';
