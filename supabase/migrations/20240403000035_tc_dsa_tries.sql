-- Test Cases: DSA — Tries
-- implement-trie, add-search-words, word-search-ii
-- Trie operations are modeled as op/args sequences.

-- ── Implement Trie ───────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"ops":["insert","search","search","startsWith","insert","search"],"args":["apple","apple","app","app","app","app"]},"expected":[null,true,false,true,null,true],"description":"Basic: insert and search","tier":"basic"},
  {"input":{"ops":["insert","search","search"],"args":["hello","hello","hell"]},"expected":[null,true,false],"description":"Basic: prefix not a word","tier":"basic"},
  {"input":{"ops":["insert","startsWith","startsWith"],"args":["ab","a","b"]},"expected":[null,true,false],"description":"Edge: prefix check","tier":"edge"},
  {"input":{"ops":["search"],"args":["a"]},"expected":[false],"description":"Edge: search empty trie","tier":"edge"},
  {"input":{"ops":["insert","insert","search","search"],"args":["a","a","a","aa"]},"expected":[null,null,true,false],"description":"Corner: duplicate inserts","tier":"corner"},
  {"input":{"ops":["insert","startsWith","search"],"args":["word","wor","wor"]},"expected":[null,true,false],"description":"Corner: prefix vs word","tier":"corner"}
]'::jsonb where slug = 'implement-trie';

-- ── Add and Search Words (with wildcard) ─────────────────────
update questions set test_cases = '[
  {"input":{"ops":["addWord","addWord","search","search","search","search"],"args":["bad","dad","pad","bad",".ad","b.."]},"expected":[null,null,false,true,true,true],"description":"Basic: wildcard matches","tier":"basic"},
  {"input":{"ops":["addWord","search","search"],"args":["a","a","."]}, "expected":[null,true,true],"description":"Basic: single char wildcard","tier":"basic"},
  {"input":{"ops":["addWord","search"],"args":["aa","a"]},"expected":[null,false],"description":"Edge: shorter query no match","tier":"edge"},
  {"input":{"ops":["addWord","search"],"args":["a",".."]}, "expected":[null,false],"description":"Edge: longer wildcard no match","tier":"edge"},
  {"input":{"ops":["addWord","addWord","search"],"args":["ab","cd",".."]}, "expected":[null,null,true],"description":"Corner: wildcard matches either","tier":"corner"}
]'::jsonb where slug = 'add-search-words';

-- ── Word Search II ────────────────────────────────────────────
update questions set test_cases = '[
  {"input":{"board":[["o","a","a","n"],["e","t","a","e"],["i","h","k","r"],["i","f","l","v"]],"words":["oath","pea","eat","rain"]},"expected":["eat","oath"],"description":"Basic: two words found","tier":"basic"},
  {"input":{"board":[["a","b"],["c","d"]],"words":["abcb"]},"expected":[],"description":"Basic: no reuse of cell","tier":"basic"},
  {"input":{"board":[["a"]],"words":["a"]},"expected":["a"],"description":"Edge: single cell match","tier":"edge"},
  {"input":{"board":[["a"]],"words":["b"]},"expected":[],"description":"Edge: single cell no match","tier":"edge"},
  {"input":{"board":[["a","b"],["c","d"]],"words":["ab","cd","ac","bd"]},"expected":["ab","ac","bd","cd"],"description":"Corner: multiple words different directions","tier":"corner"}
]'::jsonb where slug = 'word-search-ii';
