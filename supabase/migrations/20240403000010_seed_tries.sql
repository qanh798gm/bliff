-- ============================================================
-- Seed: Tries questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'tries'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Implement Trie (Prefix Tree)', 'implement-trie', 'medium', 'blind75',
    'A trie (pronounced as "try") or prefix tree is a tree data structure used to efficiently store and retrieve keys in a dataset of strings. Implement the Trie class with insert(word), search(word), and startsWith(prefix) methods.',
    '[{"input":"[\"Trie\",\"insert\",\"search\",\"search\",\"startsWith\",\"insert\",\"search\"] [[],[\"apple\"],[\"apple\"],[\"app\"],[\"app\"],[\"app\"],[\"app\"]]","output":"[null,null,true,false,true,null,true]"}]',
    array['1 <= word.length, prefix.length <= 2000','word and prefix consist only of lowercase English letters.','At most 3 * 10^4 calls in total will be made to insert, search, and startsWith.'],
    array['Each Trie node has children (map of char -> node) and an isEnd flag.','insert: traverse chars, create nodes as needed, mark last node as end.','search: traverse chars, return isEnd of last node. startsWith: same but just return true if path exists.'],
    'TrieNode with children map and isEnd flag. insert/search/startsWith traverse char by char.',
    'O(m) per operation where m = word length', 'O(m*n) total',
    array['trie','design','string'], 'Trie',
    'class Trie { constructor() { } insert(word) { } search(word) { } startsWith(prefix) { } }', 208
  ),
  (
    'Design Add and Search Words Data Structure', 'add-search-words', 'medium', 'blind75',
    'Design a data structure that supports adding new words and finding if a string matches any previously added string. Implement WordDictionary with addWord(word) and search(word) methods. search(word) may contain dots . where dots can match any letter.',
    '[{"input":"[\"WordDictionary\",\"addWord\",\"addWord\",\"addWord\",\"search\",\"search\",\"search\",\"search\"] [[],[\"bad\"],[\"dad\"],[\"mad\"],[\"pad\"],[\"bad\"],[\".ad\"],[\"b..\"]]","output":"[null,null,null,null,false,true,true,true]"}]',
    array['1 <= word.length <= 25','word in addWord consists of lowercase English letters.','word in search consists of . or lowercase English letters.','There will be at most 2 dots in word for search queries.','At most 10^4 calls will be made to addWord and search.'],
    array['Build a Trie for addWord.','For search with dots, use DFS/backtracking at each dot position.','At a dot, try all 26 children and recurse.'],
    'Trie + DFS for search. At dot character, recurse into all children.',
    'O(m) insert, O(26^d * m) search where d = number of dots', 'O(total chars)',
    array['trie','dfs','design','string'], 'WordDictionary',
    'class WordDictionary { constructor() { } addWord(word) { } search(word) { } }', 211
  ),
  (
    'Word Search II', 'word-search-ii', 'hard', 'blind75',
    'Given an m x n board of characters and a list of strings words, return all words on the board. Each word must be constructed from letters of sequentially adjacent cells, where adjacent cells are horizontally or vertically neighboring. The same letter cell may not be used more than once in a word.',
    '[{"input":"board = [[\"o\",\"a\",\"a\",\"n\"],[\"e\",\"t\",\"a\",\"e\"],[\"i\",\"h\",\"k\",\"r\"],[\"i\",\"f\",\"l\",\"v\"]], words = [\"oath\",\"pea\",\"eat\",\"rain\"]","output":"[\"eat\",\"oath\"]"},{"input":"board = [[\"a\",\"b\"],[\"c\",\"d\"]], words = [\"abcb\"]","output":"[]"}]',
    array['m == board.length','n == board[i].length','1 <= m, n <= 12','board[i][j] is a lowercase English letter.','1 <= words.length <= 3 * 10^4','1 <= words[i].length <= 10','words[i] consists of lowercase English letters.','All the strings in words are unique.'],
    array['Build a Trie from all words. Then DFS from each cell.','Trie pruning: if no trie path exists for current prefix, stop DFS early.','Mark cells visited during DFS and unmark on backtrack.'],
    'Build Trie from words. DFS from each board cell, prune with trie. Collect matches.',
    'O(m * n * 4 * 3^(L-1)) where L = max word length', 'O(total word chars)',
    array['trie','dfs','backtracking','matrix'], 'findWords',
    'function findWords(board, words) { }', 212
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
