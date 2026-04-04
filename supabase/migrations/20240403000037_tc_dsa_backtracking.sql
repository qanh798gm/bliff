-- Test Cases: DSA — Backtracking
-- subsets, combination-sum, combination-sum-ii, permutations,
-- subsets-ii, word-search, palindrome-partitioning,
-- letter-combinations-phone, n-queens

update questions set test_cases = '[
  {"input":{"nums":[1,2,3]},"expected":[[],[1],[1,2],[1,2,3],[1,3],[2],[2,3],[3]],"description":"Basic: three elements","tier":"basic"},
  {"input":{"nums":[0]},"expected":[[],[0]],"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[1,2]},"expected":[[],[1],[1,2],[2]],"description":"Edge: two elements","tier":"edge"},
  {"input":{"nums":[1,2,3,4]},"expected":[[],[1],[1,2],[1,2,3],[1,2,3,4],[1,2,4],[1,3],[1,3,4],[1,4],[2],[2,3],[2,3,4],[2,4],[3],[3,4],[4]],"description":"Corner: four elements 16 subsets","tier":"corner"}
]'::jsonb where slug = 'subsets';

update questions set test_cases = '[
  {"input":{"candidates":[2,3,6,7],"target":7},"expected":[[2,2,3],[7]],"description":"Basic: two combinations","tier":"basic"},
  {"input":{"candidates":[2,3,5],"target":8},"expected":[[2,2,2,2],[2,3,3],[3,5]],"description":"Basic: three combinations","tier":"basic"},
  {"input":{"candidates":[2],"target":1},"expected":[],"description":"Edge: no valid combination","tier":"edge"},
  {"input":{"candidates":[1],"target":1},"expected":[[1]],"description":"Edge: single match","tier":"edge"},
  {"input":{"candidates":[1],"target":2},"expected":[[1,1]],"description":"Corner: reuse single element","tier":"corner"}
]'::jsonb where slug = 'combination-sum';

update questions set test_cases = '[
  {"input":{"candidates":[10,1,2,7,6,1,5],"target":8},"expected":[[1,1,6],[1,2,5],[1,7],[2,6]],"description":"Basic: duplicates in input","tier":"basic"},
  {"input":{"candidates":[2,5,2,1,2],"target":5},"expected":[[1,2,2],[5]],"description":"Basic: repeated candidates","tier":"basic"},
  {"input":{"candidates":[1,2],"target":4},"expected":[[1,1,2],[2,2]],"description":"Edge: small candidates","tier":"edge"},
  {"input":{"candidates":[1,1,1,2],"target":2},"expected":[[1,1],[2]],"description":"Corner: many duplicates","tier":"corner"}
]'::jsonb where slug = 'combination-sum-ii';

update questions set test_cases = '[
  {"input":{"nums":[1,2,3]},"expected":[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]],"description":"Basic: three elements six perms","tier":"basic"},
  {"input":{"nums":[0,1]},"expected":[[0,1],[1,0]],"description":"Edge: two elements","tier":"edge"},
  {"input":{"nums":[1]},"expected":[[1]],"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[1,2,3,4]},"expected":24,"description":"Corner: four elements count only","tier":"corner"}
]'::jsonb where slug = 'permutations';

update questions set test_cases = '[
  {"input":{"nums":[1,2,2]},"expected":[[],[1],[1,2],[1,2,2],[2],[2,2]],"description":"Basic: one duplicate","tier":"basic"},
  {"input":{"nums":[0]},"expected":[[],[0]],"description":"Edge: single element","tier":"edge"},
  {"input":{"nums":[1,2,3]},"expected":[[],[1],[1,2],[1,2,3],[1,3],[2],[2,3],[3]],"description":"Edge: no duplicates","tier":"edge"},
  {"input":{"nums":[1,1,2,2]},"expected":[[],[1],[1,1],[1,1,2],[1,1,2,2],[1,2],[1,2,2],[2],[2,2]],"description":"Corner: two pairs of duplicates","tier":"corner"}
]'::jsonb where slug = 'subsets-ii';

update questions set test_cases = '[
  {"input":{"board":[["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]],"word":"ABCCED"},"expected":true,"description":"Basic: word exists","tier":"basic"},
  {"input":{"board":[["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]],"word":"SEE"},"expected":true,"description":"Basic: diagonal path","tier":"basic"},
  {"input":{"board":[["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]],"word":"ABCB"},"expected":false,"description":"Basic: cannot reuse cell","tier":"basic"},
  {"input":{"board":[["a"]],"word":"a"},"expected":true,"description":"Edge: 1x1 match","tier":"edge"},
  {"input":{"board":[["a"]],"word":"b"},"expected":false,"description":"Edge: 1x1 no match","tier":"edge"},
  {"input":{"board":[["A","A","A"],["A","A","A"]],"word":"AAAAAAA"},"expected":false,"description":"Corner: 7 As in 2x3 grid impossible","tier":"corner"}
]'::jsonb where slug = 'word-search';

update questions set test_cases = '[
  {"input":{"s":"aab"},"expected":[["a","a","b"],["aa","b"]],"description":"Basic: two partitions","tier":"basic"},
  {"input":{"s":"a"},"expected":[["a"]],"description":"Edge: single char","tier":"edge"},
  {"input":{"s":"ab"},"expected":[["a","b"]],"description":"Edge: two different chars","tier":"edge"},
  {"input":{"s":"aaa"},"expected":[["a","a","a"],["a","aa"],["aa","a"],["aaa"]],"description":"Corner: all same chars","tier":"corner"}
]'::jsonb where slug = 'palindrome-partitioning';

update questions set test_cases = '[
  {"input":{"digits":"23"},"expected":["ad","ae","af","bd","be","bf","cd","ce","cf"],"description":"Basic: 2 and 3","tier":"basic"},
  {"input":{"digits":""},"expected":[],"description":"Edge: empty digits","tier":"edge"},
  {"input":{"digits":"2"},"expected":["a","b","c"],"description":"Edge: single digit","tier":"edge"},
  {"input":{"digits":"7"},"expected":["p","q","r","s"],"description":"Edge: digit 7 has 4 letters","tier":"edge"},
  {"input":{"digits":"234"},"expected":["adg","adh","adi","aeg","aeh","aei","afg","afh","afi","bdg","bdh","bdi","beg","beh","bei","bfg","bfh","bfi","cdg","cdh","cdi","ceg","ceh","cei","cfg","cfh","cfi"],"description":"Corner: three digits 27 combinations","tier":"corner"}
]'::jsonb where slug = 'letter-combinations-phone';

update questions set test_cases = '[
  {"input":{"n":1},"expected":[["Q"]],"description":"Edge: n=1 one solution","tier":"edge"},
  {"input":{"n":2},"expected":[],"description":"Edge: n=2 no solution","tier":"edge"},
  {"input":{"n":3},"expected":[],"description":"Edge: n=3 no solution","tier":"edge"},
  {"input":{"n":4},"expected":[[".Q..","...Q","Q...","..Q."],["..Q.","Q...","...Q",".Q.."]],"description":"Basic: n=4 two solutions","tier":"basic"}
]'::jsonb where slug = 'n-queens';
