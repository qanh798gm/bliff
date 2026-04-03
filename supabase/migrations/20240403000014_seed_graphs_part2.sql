-- ============================================================
-- Seed: Graphs Part 2 (advanced, Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'graphs'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Graph Valid Tree', 'graph-valid-tree', 'medium', 'blind75',
    'You have a graph of n nodes labeled from 0 to n - 1. You are given an integer n and a list of edges where edges[i] = [ai, bi] indicates that there is an undirected edge between nodes ai and bi. Return true if the edges of the given graph make up a valid tree, and false otherwise.',
    '[{"input":"n = 5, edges = [[0,1],[0,2],[0,3],[1,4]]","output":"true"},{"input":"n = 5, edges = [[0,1],[1,2],[2,3],[1,3],[1,4]]","output":"false"}]',
    array['1 <= n <= 2000','0 <= edges.length <= 5000'],
    array['A valid tree has exactly n-1 edges and is connected (no cycles).','Check: edges.length == n-1 first.','Then verify the graph is fully connected with DFS/BFS or Union-Find.'],
    'Valid tree = n-1 edges + no cycle. Check edge count then DFS/Union-Find for connectivity.',
    'O(V + E)', 'O(V + E)',
    array['graphs','dfs','union-find'], 'validTree',
    'function validTree(n, edges) { }', 261
  ),
  (
    'Redundant Connection', 'redundant-connection', 'medium', 'neetcode150',
    'In this problem, a tree is an undirected graph that is connected and has no cycles. You are given a graph that started as a tree with n nodes labeled from 1 to n, with one additional edge added. Return an edge that can be removed so that the resulting graph is a tree. If there are multiple answers, return the one that occurs last in the input.',
    '[{"input":"edges = [[1,2],[1,3],[2,3]]","output":"[2,3]"},{"input":"edges = [[1,2],[2,3],[3,4],[1,4],[1,5]]","output":"[1,4]"}]',
    array['n == edges.length','3 <= n <= 1000','edges[i].length == 2','1 <= ai < bi <= n','ai != bi','There are no repeated edges.','The given graph is connected.'],
    array['Use Union-Find. Process edges one by one.','If both endpoints are already in the same component, this edge creates a cycle — return it.','Otherwise union the two components.'],
    'Union-Find: process edges. If both endpoints share root, this edge is redundant.',
    'O(n * alpha(n))', 'O(n)',
    array['graphs','union-find'], 'findRedundantConnection',
    'function findRedundantConnection(edges) { }', 684
  ),
  (
    'Word Ladder', 'word-ladder', 'hard', 'blind75',
    'A transformation sequence from word beginWord to word endWord using a dictionary wordList is a sequence where each adjacent pair of words differs by a single letter and every word is in the dictionary. Given beginWord, endWord, and wordList, return the number of words in the shortest transformation sequence, or 0 if no such sequence exists.',
    '[{"input":"beginWord = \"hit\", endWord = \"cog\", wordList = [\"hot\",\"dot\",\"dog\",\"lot\",\"log\",\"cog\"]","output":"5"},{"input":"beginWord = \"hit\", endWord = \"cog\", wordList = [\"hot\",\"dot\",\"dog\",\"lot\",\"log\"]","output":"0"}]',
    array['1 <= beginWord.length <= 10','endWord.length == beginWord.length','1 <= wordList.length <= 5000','wordList[i].length == beginWord.length','beginWord, endWord, and wordList[i] consist of lowercase English letters.','beginWord != endWord','All the strings in wordList are unique.'],
    array['This is a shortest path problem — use BFS.','For each word in queue, try changing each character to a-z. If new word is in dictionary, enqueue it.','Use a set for O(1) lookup and remove words when visited.'],
    'BFS: treat words as nodes, single-char changes as edges. BFS for shortest path.',
    'O(M² * N) where M = word length, N = wordList size', 'O(M² * N)',
    array['graphs','bfs','string'], 'ladderLength',
    'function ladderLength(beginWord, endWord, wordList) { }', 127
  ),
  (
    'Network Delay Time', 'network-delay-time', 'medium', 'neetcode150',
    'You are given a network of n nodes, labeled from 1 to n. You are also given times, a list of travel times as directed edges times[i] = (ui, vi, wi), where ui is the source node, vi is the target node, and wi is the time it takes for a signal to travel from source to target. We will send a signal from a given node k. Return the minimum time it takes for all n nodes to receive the signal. If it is impossible, return -1.',
    '[{"input":"times = [[2,1,1],[2,3,1],[3,4,1]], n = 4, k = 2","output":"2"},{"input":"times = [[1,2,1]], n = 2, k = 1","output":"1"},{"input":"times = [[1,2,1]], n = 2, k = 2","output":"-1"}]',
    array['1 <= k <= n <= 100','1 <= times.length <= 6000','times[i].length == 3','1 <= ui, vi <= n','ui != vi','0 <= wi <= 100','All the pairs (ui, vi) are unique.'],
    array['This is a single-source shortest path problem.','Use Dijkstra''s algorithm with a min-heap (priority queue).','After Dijkstra, answer = max distance to all nodes. If any node unreachable, return -1.'],
    'Dijkstra from node k. Answer = max distance. Return -1 if any unreachable.',
    'O(E log V)', 'O(V + E)',
    array['graphs','dijkstra','shortest-path'], 'networkDelayTime',
    'function networkDelayTime(times, n, k) { }', 743
  ),
  (
    'Swim in Rising Water', 'swim-in-rising-water', 'hard', 'neetcode150',
    'You are given an n x n integer matrix grid where each value grid[i][j] represents the elevation at that point (i, j). The rain starts to fall. At time t, the depth of the water everywhere is t. You can swim from a square to another 4-directionally adjacent square if and only if the elevation of both squares individually are at most t. Return the least time until you can reach the bottom right square (n-1, n-1) from the top left square (0, 0).',
    '[{"input":"grid = [[0,2],[1,3]]","output":"3"},{"input":"grid = [[0,1,2,3,4],[24,23,22,21,5],[12,13,14,15,16],[11,17,18,19,20],[10,9,8,7,6]]","output":"16"}]',
    array['n == grid.length','n == grid[i].length','1 <= n <= 50','0 <= grid[i][j] < n^2','Each value grid[i][j] is unique.'],
    array['Binary search on the answer t, check if path exists with DFS/BFS.','Or use Dijkstra where edge weight = max(current max, neighbor elevation).','The answer is the minimax path from (0,0) to (n-1, n-1).'],
    'Dijkstra/min-heap: cost to reach cell = max elevation on path. Find min cost to (n-1, n-1).',
    'O(n² log n)', 'O(n²)',
    array['graphs','dijkstra','binary-search','matrix'], 'swimInWater',
    'function swimInWater(grid) { }', 778
  ),
  (
    'Alien Dictionary', 'alien-dictionary', 'hard', 'blind75',
    'There is a new alien language that uses the English alphabet. However, the order among the letters is unknown to you. You are given a list of strings words from the alien language''s dictionary, where the strings in words are sorted lexicographically by the rules of this new language. Derive the order of letters in this language. If the order is invalid, return "". If there are multiple valid orders, return any of them.',
    '[{"input":"words = [\"wrt\",\"wrf\",\"er\",\"ett\",\"rftt\"]","output":"\"wertf\""},{"input":"words = [\"z\",\"x\"]","output":"\"zx\""},{"input":"words = [\"z\",\"x\",\"z\"]","output":"\"\""}]',
    array['1 <= words.length <= 100','1 <= words[i].length <= 100','words[i] consists of only lowercase English letters.'],
    array['Compare adjacent words to extract character ordering constraints.','Build a directed graph of these constraints.','Topological sort of the graph gives the alien alphabet order.','If a cycle exists, return "".'],
    'Extract ordering from adjacent word pairs. Build DAG. Topological sort (DFS or Kahn).',
    'O(C) where C = total characters in all words', 'O(1) (26 chars max)',
    array['graphs','topological-sort','dfs'], 'alienOrder',
    'function alienOrder(words) { }', 269
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
