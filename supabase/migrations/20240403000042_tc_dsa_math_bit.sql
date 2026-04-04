-- Test Cases: DSA — Math & Bit Manipulation
-- number-of-1-bits, counting-bits, reverse-bits, missing-number,
-- sum-two-integers, reverse-integer, power-of-two, detect-square

update questions set test_cases = '[
  {"input":{"n":11},"expected":3,"description":"Basic: 1011 has 3 bits","tier":"basic"},
  {"input":{"n":128},"expected":1,"description":"Basic: power of 2","tier":"basic"},
  {"input":{"n":0},"expected":0,"description":"Edge: zero bits","tier":"edge"},
  {"input":{"n":1},"expected":1,"description":"Edge: single bit","tier":"edge"},
  {"input":{"n":4294967295},"expected":32,"description":"Corner: all 32 bits set","tier":"corner"},
  {"input":{"n":2147483645},"expected":30,"description":"Corner: near max","tier":"corner"}
]'::jsonb where slug = 'number-of-1-bits';

update questions set test_cases = '[
  {"input":{"n":2},"expected":[0,1,1],"description":"Basic: n=2","tier":"basic"},
  {"input":{"n":5},"expected":[0,1,1,2,1,2],"description":"Basic: n=5","tier":"basic"},
  {"input":{"n":0},"expected":[0],"description":"Edge: n=0","tier":"edge"},
  {"input":{"n":1},"expected":[0,1],"description":"Edge: n=1","tier":"edge"},
  {"input":{"n":8},"expected":[0,1,1,2,1,2,2,3,1],"description":"Corner: includes power of 2","tier":"corner"}
]'::jsonb where slug = 'counting-bits';

update questions set test_cases = '[
  {"input":{"n":43261596},"expected":964176192,"description":"Basic: reverse bits","tier":"basic"},
  {"input":{"n":4294967293},"expected":3221225471,"description":"Basic: near max reversed","tier":"basic"},
  {"input":{"n":0},"expected":0,"description":"Edge: zero stays zero","tier":"edge"},
  {"input":{"n":1},"expected":2147483648,"description":"Edge: bit 0 becomes bit 31","tier":"edge"},
  {"input":{"n":2147483648},"expected":1,"description":"Corner: bit 31 becomes bit 0","tier":"corner"}
]'::jsonb where slug = 'reverse-bits';

update questions set test_cases = '[
  {"input":{"nums":[3,0,1]},"expected":2,"description":"Basic: missing 2","tier":"basic"},
  {"input":{"nums":[0,1]},"expected":2,"description":"Basic: missing last","tier":"basic"},
  {"input":{"nums":[9,6,4,2,3,5,7,0,1]},"expected":8,"description":"Basic: missing 8","tier":"basic"},
  {"input":{"nums":[0]},"expected":1,"description":"Edge: only zero","tier":"edge"},
  {"input":{"nums":[1]},"expected":0,"description":"Edge: only one","tier":"edge"},
  {"input":{"nums":[0,1,2,3,5]},"expected":4,"description":"Corner: missing in middle","tier":"corner"}
]'::jsonb where slug = 'missing-number';

update questions set test_cases = '[
  {"input":{"a":1,"b":2},"expected":3,"description":"Basic: 1+2=3","tier":"basic"},
  {"input":{"a":2,"b":3},"expected":5,"description":"Basic: 2+3=5","tier":"basic"},
  {"input":{"a":0,"b":0},"expected":0,"description":"Edge: zeros","tier":"edge"},
  {"input":{"a":-1,"b":1},"expected":0,"description":"Edge: cancel out","tier":"edge"},
  {"input":{"a":-10,"b":3},"expected":-7,"description":"Corner: negative plus positive","tier":"corner"},
  {"input":{"a":100,"b":-100},"expected":0,"description":"Corner: large cancel","tier":"corner"}
]'::jsonb where slug = 'sum-two-integers';

update questions set test_cases = '[
  {"input":{"x":123},"expected":321,"description":"Basic: three digits","tier":"basic"},
  {"input":{"x":-123},"expected":-321,"description":"Basic: negative","tier":"basic"},
  {"input":{"x":120},"expected":21,"description":"Basic: trailing zero drops","tier":"basic"},
  {"input":{"x":0},"expected":0,"description":"Edge: zero","tier":"edge"},
  {"input":{"x":9},"expected":9,"description":"Edge: single digit","tier":"edge"},
  {"input":{"x":1534236469},"expected":0,"description":"Corner: overflow returns 0","tier":"corner"}
]'::jsonb where slug = 'reverse-integer';

update questions set test_cases = '[
  {"input":{"n":1},"expected":true,"description":"Basic: 1 is power of 2","tier":"basic"},
  {"input":{"n":16},"expected":true,"description":"Basic: 16 is power of 2","tier":"basic"},
  {"input":{"n":3},"expected":false,"description":"Basic: 3 is not","tier":"basic"},
  {"input":{"n":0},"expected":false,"description":"Edge: zero is not","tier":"edge"},
  {"input":{"n":-1},"expected":false,"description":"Edge: negative is not","tier":"edge"},
  {"input":{"n":1073741824},"expected":true,"description":"Corner: 2^30","tier":"corner"},
  {"input":{"n":2147483647},"expected":false,"description":"Corner: max int not power of 2","tier":"corner"}
]'::jsonb where slug = 'power-of-two';

update questions set test_cases = '[
  {"input":{"points":[[1,0],[0,0],[0,1],[1,1]],"queries":[[0,0,1]]},"expected":[1],"description":"Basic: one square found","tier":"basic"},
  {"input":{"points":[[0,0]],"queries":[[0,0,1]]},"expected":[0],"description":"Edge: single point no square","tier":"edge"},
  {"input":{"points":[[1,1],[2,2],[1,2],[2,1]],"queries":[[1,1,1]]},"expected":[1],"description":"Edge: exact square query","tier":"edge"},
  {"input":{"points":[[0,0],[1,0],[0,1],[1,1],[2,0],[2,1]],"queries":[[0,0,2]]},"expected":[2],"description":"Corner: multiple squares","tier":"corner"}
]'::jsonb where slug = 'detect-square';
