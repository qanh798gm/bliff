-- ============================================================
-- Seed: Graphs Part 1 (basic traversal + connectivity, Blind 75 + NeetCode 150)
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
    'Number of Islands', 'number-of-islands', 'medium', 'blind75',
    'Given an m x n 2D binary grid which represents a map of ''1''s (land) and ''0''s (water), return the number of islands. An island is surrounded by water and is formed by connecting adjacent lands horizontally or vertically.',
    '[{"input":"grid = [[\"1\",\"1\",\"1\",\"1\",\"0\"],[\"1\",\"1\",\"0\",\"1\",\"0\"],[\"1\",\"1\",\"0\",\"0\",\"0\"],[\"0\",\"0\",\"0\",\"0\",\"0\"]]","output":"1"},{"input":"grid = [[\"1\",\"1\",\"0\",\"0\",\"0\"],[\"1\",\"1\",\"0\",\"0\",\"0\"],[\"0\",\"0\",\"1\",\"0\",\"0\"],[\"0\",\"0\",\"0\",\"1\",\"1\"]]","output":"3"}]',
    array['m == grid.length','n == grid[i].length','1 <= m, n <= 300','grid[i][j] is ''0'' or ''1''.'],
    array['DFS or BFS from each unvisited land cell.','When you find a ''1'', increment island count and DFS to mark all connected land as visited.','Mark visited cells as ''0'' or use a visited set.'],
    'DFS/BFS: for each unvisited ''1'', increment count and flood-fill (mark visited).',
    'O(m*n)', 'O(m*n)',
    array['graphs','dfs','bfs','matrix'], 'numIslands',
    'function numIslands(grid) { }', 200
  ),
  (
    'Max Area of Island', 'max-area-of-island', 'medium', 'neetcode150',
    'You are given an m x n binary matrix grid. An island is a group of 1s connected 4-directionally. The area of an island is the number of cells with value 1 in the island. Return the maximum area of an island in grid. If there is no island, return 0.',
    '[{"input":"grid = [[0,0,1,0,0,0,0,1,0,0,0,0,0],[0,0,0,0,0,0,0,1,1,1,0,0,0],[0,1,1,0,1,0,0,0,0,0,0,0,0]]","output":"6"},{"input":"grid = [[0,0,0,0,0,0,0,0]]","output":"0"}]',
    array['m == grid.length','n == grid[i].length','1 <= m, n <= 50','grid[i][j] is either 0 or 1.'],
    array['DFS from each unvisited land cell, count and return the area.','Track global max area.','Mark visited cells to avoid re-counting.'],
    'DFS returning area of each island. Track max.',
    'O(m*n)', 'O(m*n)',
    array['graphs','dfs','matrix'], 'maxAreaOfIsland',
    'function maxAreaOfIsland(grid) { }', 695
  ),
  (
    'Clone Graph', 'clone-graph', 'medium', 'blind75',
    'Given a reference of a node in a connected undirected graph, return a deep copy (clone) of the graph. Each node in the graph contains a value (int) and a list of its neighbors.',
    '[{"input":"adjList = [[2,4],[1,3],[2,4],[1,3]]","output":"[[2,4],[1,3],[2,4],[1,3]]"},{"input":"adjList = [[]]","output":"[[]]"},{"input":"adjList = []","output":"[]"}]',
    array['The number of nodes in the graph is in the range [0, 100]','1 <= Node.val <= 100','Node.val is unique for each node','There are no repeated edges and no self-loops in the graph.'],
    array['Use a hash map to map original nodes to their clones.','DFS: if node already cloned, return its clone.','Otherwise create clone, add to map, then recursively clone all neighbors.'],
    'DFS + HashMap: old->new. If already cloned return it. Else create, map, clone neighbors.',
    'O(V + E)', 'O(V)',
    array['graphs','dfs','bfs','hash-map'], 'cloneGraph',
    'function cloneGraph(node) { }', 133
  ),
  (
    'Walls and Gates', 'walls-and-gates', 'medium', 'neetcode150',
    'You are given a m x n 2D grid initialized with three possible values: -1 (wall), 0 (gate), INF (2^31-1, empty room). Fill each empty room with the distance to its nearest gate. If it is impossible to reach a gate, leave it as INF.',
    '[{"input":"rooms = [[2147483647,-1,0,2147483647],[2147483647,2147483647,2147483647,-1],[2147483647,-1,2147483647,-1],[0,-1,2147483647,2147483647]]","output":"[[3,-1,0,1],[2,2,1,-1],[1,-1,2,-1],[0,-1,3,4]]"}]',
    array['m == rooms.length','n == rooms[i].length','1 <= m, n <= 250','rooms[i][j] is one of: -1, 0, or 2^31 - 1'],
    array['Multi-source BFS starting from all gates simultaneously.','Add all gate positions (value 0) to the queue first.','BFS naturally gives shortest distance from any gate.'],
    'Multi-source BFS: enqueue all gates. BFS outward, update distances.',
    'O(m*n)', 'O(m*n)',
    array['graphs','bfs','matrix'], 'wallsAndGates',
    'function wallsAndGates(rooms) { }', 286
  ),
  (
    'Rotting Oranges', 'rotting-oranges', 'medium', 'neetcode150',
    'You are given an m x n grid where each cell can have value 0 (empty), 1 (fresh orange), or 2 (rotten orange). Every minute, any fresh orange adjacent to a rotten orange becomes rotten. Return the minimum number of minutes that must elapse until no cell has a fresh orange. Return -1 if impossible.',
    '[{"input":"grid = [[2,1,1],[1,1,0],[0,1,1]]","output":"4"},{"input":"grid = [[2,1,1],[0,1,1],[1,0,1]]","output":"-1"},{"input":"grid = [[0,2]]","output":"0"}]',
    array['m == grid.length','n == grid[i].length','1 <= m, n <= 10','grid[i][j] is 0, 1, or 2'],
    array['Multi-source BFS starting from all rotten oranges.','Count fresh oranges initially.','BFS each minute, decrement fresh count as oranges rot. Return minutes or -1 if fresh remain.'],
    'Multi-source BFS from all rotten oranges. Count minutes and remaining fresh.',
    'O(m*n)', 'O(m*n)',
    array['graphs','bfs','matrix'], 'orangesRotting',
    'function orangesRotting(grid) { }', 994
  ),
  (
    'Pacific Atlantic Water Flow', 'pacific-atlantic-water-flow', 'medium', 'blind75',
    'There is an m x n rectangular island with heights. Rain water can flow to the Pacific ocean (top and left edges) and Atlantic ocean (bottom and right edges). Water flows to adjacent cells with equal or lower height. Return a list of grid coordinates where water can flow to both oceans.',
    '[{"input":"heights = [[1,2,2,3,5],[3,2,3,4,4],[2,4,5,3,1],[6,7,1,4,5],[5,1,1,2,4]]","output":"[[0,4],[1,3],[1,4],[2,2],[3,0],[3,1],[4,0]]"}]',
    array['m == heights.length','n == heights[i].length','1 <= m, n <= 200','0 <= heights[i][j] <= 10^5'],
    array['Instead of flowing down, reverse: BFS/DFS upward from each ocean.','Pacific reachable = BFS from top row + left col.','Atlantic reachable = BFS from bottom row + right col.','Answer = intersection of both sets.'],
    'Reverse BFS from both oceans. Intersection = cells that can reach both.',
    'O(m*n)', 'O(m*n)',
    array['graphs','dfs','bfs','matrix'], 'pacificAtlantic',
    'function pacificAtlantic(heights) { }', 417
  ),
  (
    'Surrounded Regions', 'surrounded-regions', 'medium', 'neetcode150',
    'Given an m x n matrix board containing ''X'' and ''O'', capture all regions that are 4-directionally surrounded by ''X''. A region is captured by flipping all ''O''s into ''X''s in that surrounded region. Note: An ''O'' on the border cannot be captured.',
    '[{"input":"board = [[\"X\",\"X\",\"X\",\"X\"],[\"X\",\"O\",\"O\",\"X\"],[\"X\",\"X\",\"O\",\"X\"],[\"X\",\"O\",\"X\",\"X\"]]","output":"[[\"X\",\"X\",\"X\",\"X\"],[\"X\",\"X\",\"X\",\"X\"],[\"X\",\"X\",\"X\",\"X\"],[\"X\",\"O\",\"X\",\"X\"]]"}]',
    array['m == board.length','n == board[i].length','1 <= m, n <= 200','board[i][j] is ''X'' or ''O''.'],
    array['DFS from all border ''O'' cells. Mark them as safe (e.g., ''S'').','All remaining ''O'' cells are surrounded — flip to ''X''.','Flip ''S'' back to ''O''.'],
    'DFS from border O cells to mark safe. Flip remaining O to X, S back to O.',
    'O(m*n)', 'O(m*n)',
    array['graphs','dfs','matrix'], 'solve',
    'function solve(board) { }', 130
  ),
  (
    'Course Schedule', 'course-schedule', 'medium', 'blind75',
    'There are a total of numCourses courses you have to take, labeled from 0 to numCourses - 1. You are given an array prerequisites where prerequisites[i] = [ai, bi] indicates that you must take course bi first if you want to take course ai. Return true if you can finish all courses, otherwise return false.',
    '[{"input":"numCourses = 2, prerequisites = [[1,0]]","output":"true"},{"input":"numCourses = 2, prerequisites = [[1,0],[0,1]]","output":"false"}]',
    array['1 <= numCourses <= 2000','0 <= prerequisites.length <= 5000','prerequisites[i].length == 2','0 <= ai, bi < numCourses','All the pairs prerequisites[i] are unique.'],
    array['This is a cycle detection problem in a directed graph.','Build adjacency list, then DFS each node.','Track visiting (in-progress) and visited (done) states. Cycle if you revisit an in-progress node.'],
    'DFS cycle detection with 3 states: unvisited, visiting, visited.',
    'O(V + E)', 'O(V + E)',
    array['graphs','dfs','topological-sort'], 'canFinish',
    'function canFinish(numCourses, prerequisites) { }', 207
  ),
  (
    'Course Schedule II', 'course-schedule-ii', 'medium', 'blind75',
    'Given numCourses and prerequisites, return the ordering of courses you should take to finish all courses. If there are multiple valid answers, return any of them. If it is impossible to finish all courses, return an empty array.',
    '[{"input":"numCourses = 2, prerequisites = [[1,0]]","output":"[0,1]"},{"input":"numCourses = 4, prerequisites = [[1,0],[2,0],[3,1],[3,2]]","output":"[0,2,1,3]"},{"input":"numCourses = 1, prerequisites = []","output":"[0]"}]',
    array['1 <= numCourses <= 2000','0 <= prerequisites.length <= numCourses * (numCourses - 1)'],
    array['Topological sort using DFS post-order.','After visiting all neighbors of a node, add it to the result.','If cycle detected, return [].'],
    'DFS topological sort: add node to result in post-order. Reverse for topo order.',
    'O(V + E)', 'O(V + E)',
    array['graphs','dfs','topological-sort'], 'findOrder',
    'function findOrder(numCourses, prerequisites) { }', 210
  ),
  (
    'Number of Connected Components in Undirected Graph', 'number-connected-components', 'medium', 'blind75',
    'You have a graph of n nodes. You are given an integer n and an array edges where edges[i] = [ai, bi] indicates that there is an edge between nodes ai and bi. Return the number of connected components in the graph.',
    '[{"input":"n = 5, edges = [[0,1],[1,2],[3,4]]","output":"2"},{"input":"n = 5, edges = [[0,1],[1,2],[2,3],[3,4]]","output":"1"}]',
    array['1 <= n <= 2000','1 <= edges.length <= 5000','edges[i].length == 2','0 <= ai <= bi < n','ai != bi','There are no repeated edges.'],
    array['DFS/BFS from each unvisited node, increment component count.','Or use Union-Find (Disjoint Set Union).','With Union-Find, start with n components, merge for each edge.'],
    'DFS from each unvisited node or Union-Find. Count components.',
    'O(V + E)', 'O(V + E)',
    array['graphs','dfs','union-find'], 'countComponents',
    'function countComponents(n, edges) { }', 323
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
