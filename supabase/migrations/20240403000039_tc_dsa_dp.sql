-- Test Cases: DSA — Dynamic Programming (Parts 1 & 2)
-- climbing-stairs, min-cost-climbing-stairs, house-robber, house-robber-ii,
-- longest-palindromic-substring, palindromic-substrings, decode-ways,
-- coin-change, word-break, longest-increasing-subsequence,
-- partition-equal-subset-sum, unique-paths, longest-common-subsequence,
-- buy-sell-stock-cooldown, coin-change-ii, target-sum, edit-distance

update questions set test_cases = '[
  {"input":{"n":2},"expected":2,"description":"Basic: 2 steps","tier":"basic"},
  {"input":{"n":3},"expected":3,"description":"Basic: 3 steps","tier":"basic"},
  {"input":{"n":1},"expected":1,"description":"Edge: 1 step","tier":"edge"},
  {"input":{"n":5},"expected":8,"description":"Edge: 5 steps Fibonacci","tier":"edge"},
  {"input":{"n":10},"expected":89,"description":"Corner: 10 steps","tier":"corner"},
  {"input":{"n":45},"expected":1836311903,"description":"Corner: large n","tier":"corner"}
]'::jsonb where slug = 'climbing-stairs';

update questions set test_cases = '[
  {"input":{"cost":[10,15,20]},"expected":15,"description":"Basic: three steps","tier":"basic"},
  {"input":{"cost":[1,100,1,1,1,100,1,1,100,1]},"expected":6,"description":"Basic: avoid expensive steps","tier":"basic"},
  {"input":{"cost":[0,0]},"expected":0,"description":"Edge: free steps","tier":"edge"},
  {"input":{"cost":[1,2]},"expected":1,"description":"Edge: two steps","tier":"edge"},
  {"input":{"cost":[10,15]},"expected":10,"description":"Corner: start at 0 skip 1","tier":"corner"}
]'::jsonb where slug = 'min-cost-climbing-stairs';

update questions set test_cases = '[
  {"input":{"nums":[1,2,3,1]},"expected":4,"description":"Basic: skip adjacent","tier":"basic"},
  {"input":{"nums":[2,7,9,3,1]},"expected":12,"description":"Basic: every other house","tier":"basic"},
  {"input":{"nums":[1,2]},"expected":2,"description":"Edge: two houses","tier":"edge"},
  {"input":{"nums":[1]},"expected":1,"description":"Edge: single house","tier":"edge"},
  {"input":{"nums":[0,0]},"expected":0,"description":"Corner: all zeros","tier":"corner"},
  {"input":{"nums":[100,1,100]},"expected":200,"description":"Corner: skip middle","tier":"corner"}
]'::jsonb where slug = 'house-robber';

update questions set test_cases = '[
  {"input":{"nums":[2,3,2]},"expected":3,"description":"Basic: circle rob middle","tier":"basic"},
  {"input":{"nums":[1,2,3]},"expected":3,"description":"Basic: circle last house","tier":"basic"},
  {"input":{"nums":[1,2,3,1]},"expected":4,"description":"Basic: classic","tier":"basic"},
  {"input":{"nums":[1]},"expected":1,"description":"Edge: one house","tier":"edge"},
  {"input":{"nums":[2,3]},"expected":3,"description":"Edge: two houses","tier":"edge"},
  {"input":{"nums":[200,3,140,20,10]},"expected":340,"description":"Corner: large values","tier":"corner"}
]'::jsonb where slug = 'house-robber-ii';

update questions set test_cases = '[
  {"input":{"s":"babad"},"expected":"bab","description":"Basic: bab or aba valid","tier":"basic"},
  {"input":{"s":"cbbd"},"expected":"bb","description":"Basic: even palindrome","tier":"basic"},
  {"input":{"s":"a"},"expected":"a","description":"Edge: single char","tier":"edge"},
  {"input":{"s":"ac"},"expected":"a","description":"Edge: no palindrome > 1","tier":"edge"},
  {"input":{"s":"racecar"},"expected":"racecar","description":"Corner: whole string is palindrome","tier":"corner"},
  {"input":{"s":"aacabdkacaa"},"expected":"aca","description":"Corner: multiple options","tier":"corner"}
]'::jsonb where slug = 'longest-palindromic-substring';

update questions set test_cases = '[
  {"input":{"s":"abc"},"expected":3,"description":"Basic: 3 single-char palindromes","tier":"basic"},
  {"input":{"s":"aaa"},"expected":6,"description":"Basic: all palindromes","tier":"basic"},
  {"input":{"s":"a"},"expected":1,"description":"Edge: single char","tier":"edge"},
  {"input":{"s":"aa"},"expected":3,"description":"Edge: two same chars","tier":"edge"},
  {"input":{"s":"fdsklf"},"expected":6,"description":"Corner: only single chars","tier":"corner"}
]'::jsonb where slug = 'palindromic-substrings';

update questions set test_cases = '[
  {"input":{"s":"12"},"expected":2,"description":"Basic: AB or L","tier":"basic"},
  {"input":{"s":"226"},"expected":3,"description":"Basic: BZ or VF or BBF","tier":"basic"},
  {"input":{"s":"06"},"expected":0,"description":"Basic: leading zero invalid","tier":"basic"},
  {"input":{"s":"0"},"expected":0,"description":"Edge: single zero","tier":"edge"},
  {"input":{"s":"1"},"expected":1,"description":"Edge: single one","tier":"edge"},
  {"input":{"s":"11106"},"expected":2,"description":"Corner: zero in middle","tier":"corner"},
  {"input":{"s":"10"},"expected":1,"description":"Corner: J encoding","tier":"corner"}
]'::jsonb where slug = 'decode-ways';

update questions set test_cases = '[
  {"input":{"coins":[1,5,10,25],"amount":36},"expected":3,"description":"Basic: 25+10+1","tier":"basic"},
  {"input":{"coins":[1,2,5],"amount":11},"expected":3,"description":"Basic: 5+5+1","tier":"basic"},
  {"input":{"coins":[2],"amount":3},"expected":-1,"description":"Basic: impossible","tier":"basic"},
  {"input":{"coins":[1],"amount":0},"expected":0,"description":"Edge: zero amount","tier":"edge"},
  {"input":{"coins":[2],"amount":2},"expected":1,"description":"Edge: exact one coin","tier":"edge"},
  {"input":{"coins":[1,2147483647],"amount":2},"expected":2,"description":"Corner: large denomination","tier":"corner"}
]'::jsonb where slug = 'coin-change';

update questions set test_cases = '[
  {"input":{"s":"leetcode","wordDict":["leet","code"]},"expected":true,"description":"Basic: split into two words","tier":"basic"},
  {"input":{"s":"applepenapple","wordDict":["apple","pen"]},"expected":true,"description":"Basic: reuse words","tier":"basic"},
  {"input":{"s":"catsandog","wordDict":["cats","dog","sand","and","cat"]},"expected":false,"description":"Basic: cannot complete","tier":"basic"},
  {"input":{"s":"a","wordDict":["a"]},"expected":true,"description":"Edge: single char match","tier":"edge"},
  {"input":{"s":"a","wordDict":["b"]},"expected":false,"description":"Edge: single char no match","tier":"edge"},
  {"input":{"s":"aaaaaaa","wordDict":["aaaa","aaa"]},"expected":true,"description":"Corner: overlapping dict words","tier":"corner"}
]'::jsonb where slug = 'word-break';

update questions set test_cases = '[
  {"input":{"nums":[10,9,2,5,3,7,101,18]},"expected":4,"description":"Basic: classic LIS","tier":"basic"},
  {"input":{"nums":[0,1,0,3,2,3]},"expected":4,"description":"Basic: multiple options","tier":"basic"},
  {"input":{"nums":[7,7,7,7,7]},"expected":1,"description":"Edge: all same","tier":"edge"},
  {"input":{"nums":[1]},"expected":1,"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[1,3,6,7,9,4,10,5,6]},"expected":6,"description":"Corner: longer sequence","tier":"corner"}
]'::jsonb where slug = 'longest-increasing-subsequence';

update questions set test_cases = '[
  {"input":{"nums":[1,5,11,5]},"expected":true,"description":"Basic: equal partition","tier":"basic"},
  {"input":{"nums":[1,2,3,5]},"expected":false,"description":"Basic: odd sum no partition","tier":"basic"},
  {"input":{"nums":[1,1]},"expected":true,"description":"Edge: two equal elements","tier":"edge"},
  {"input":{"nums":[2,2,3,5]},"expected":false,"description":"Edge: no equal split","tier":"edge"},
  {"input":{"nums":[1,2,5]},"expected":false,"description":"Corner: odd sum","tier":"corner"},
  {"input":{"nums":[14,9,8,4,3,2]},"expected":true,"description":"Corner: multiple elements","tier":"corner"}
]'::jsonb where slug = 'partition-equal-subset-sum';

update questions set test_cases = '[
  {"input":{"m":3,"n":7},"expected":28,"description":"Basic: 3x7","tier":"basic"},
  {"input":{"m":3,"n":2},"expected":3,"description":"Basic: 3x2","tier":"basic"},
  {"input":{"m":1,"n":1},"expected":1,"description":"Edge: 1x1","tier":"edge"},
  {"input":{"m":1,"n":10},"expected":1,"description":"Edge: single row","tier":"edge"},
  {"input":{"m":10,"n":1},"expected":1,"description":"Edge: single column","tier":"edge"},
  {"input":{"m":7,"n":3},"expected":28,"description":"Corner: transposed","tier":"corner"}
]'::jsonb where slug = 'unique-paths';

update questions set test_cases = '[
  {"input":{"text1":"abcde","text2":"ace"},"expected":3,"description":"Basic: ace","tier":"basic"},
  {"input":{"text1":"abc","text2":"abc"},"expected":3,"description":"Basic: identical strings","tier":"basic"},
  {"input":{"text1":"abc","text2":"def"},"expected":0,"description":"Basic: no common","tier":"basic"},
  {"input":{"text1":"a","text2":"a"},"expected":1,"description":"Edge: single char match","tier":"edge"},
  {"input":{"text1":"a","text2":"b"},"expected":0,"description":"Edge: single char no match","tier":"edge"},
  {"input":{"text1":"bl","text2":"yby"},"expected":1,"description":"Corner: short strings","tier":"corner"}
]'::jsonb where slug = 'longest-common-subsequence';

update questions set test_cases = '[
  {"input":{"prices":[1,2,3,0,2]},"expected":3,"description":"Basic: buy sell cooldown buy sell","tier":"basic"},
  {"input":{"prices":[1]},"expected":0,"description":"Edge: single price","tier":"edge"},
  {"input":{"prices":[2,1]},"expected":0,"description":"Edge: declining no profit","tier":"edge"},
  {"input":{"prices":[6,1,3,2,4,7]},"expected":6,"description":"Corner: multiple transactions","tier":"corner"}
]'::jsonb where slug = 'buy-sell-stock-cooldown';

update questions set test_cases = '[
  {"input":{"amount":5,"coins":[1,2,5]},"expected":4,"description":"Basic: 4 combinations","tier":"basic"},
  {"input":{"amount":3,"coins":[2]},"expected":0,"description":"Basic: impossible","tier":"basic"},
  {"input":{"amount":10,"coins":[10]},"expected":1,"description":"Edge: exact coin","tier":"edge"},
  {"input":{"amount":0,"coins":[1,2,3]},"expected":1,"description":"Edge: zero amount one way","tier":"edge"},
  {"input":{"amount":500,"coins":[1,2,5]},"expected":12701,"description":"Corner: large amount","tier":"corner"}
]'::jsonb where slug = 'coin-change-ii';

update questions set test_cases = '[
  {"input":{"nums":[1,1,1,1,1],"target":3},"expected":5,"description":"Basic: 5 ways","tier":"basic"},
  {"input":{"nums":[1],"target":1},"expected":1,"description":"Edge: single element exact","tier":"edge"},
  {"input":{"nums":[1],"target":2},"expected":0,"description":"Edge: impossible","tier":"edge"},
  {"input":{"nums":[1,0],"target":1},"expected":2,"description":"Corner: zero in array","tier":"corner"},
  {"input":{"nums":[0,0,0,0,0],"target":0},"expected":32,"description":"Corner: all zeros target zero","tier":"corner"}
]'::jsonb where slug = 'target-sum';

update questions set test_cases = '[
  {"input":{"word1":"horse","word2":"ros"},"expected":3,"description":"Basic: 3 ops","tier":"basic"},
  {"input":{"word1":"intention","word2":"execution"},"expected":5,"description":"Basic: 5 ops","tier":"basic"},
  {"input":{"word1":"","word2":"abc"},"expected":3,"description":"Edge: empty to string","tier":"edge"},
  {"input":{"word1":"abc","word2":""},"expected":3,"description":"Edge: string to empty","tier":"edge"},
  {"input":{"word1":"abc","word2":"abc"},"expected":0,"description":"Edge: identical","tier":"edge"},
  {"input":{"word1":"a","word2":"b"},"expected":1,"description":"Corner: single char replace","tier":"corner"}
]'::jsonb where slug = 'edit-distance';
