-- Test Cases: DSA — Graphs
-- number-of-islands, max-area-of-island, clone-graph,
-- walls-and-gates, rotting-oranges, pacific-atlantic-water-flow,
-- surrounded-regions, course-schedule, course-schedule-ii,
-- number-connected-components, graph-valid-tree,
-- word-ladder

update questions set test_cases = '[
  {"input":{"grid":[["1","1","1","1","0"],["1","1","0","1","0"],["1","1","0","0","0"],["0","0","0","0","0"]]},"expected":1,"description":"Basic: one large island","tier":"basic"},
  {"input":{"grid":[["1","1","0","0","0"],["1","1","0","0","0"],["0","0","1","0","0"],["0","0","0","1","1"]]},"expected":3,"description":"Basic: three islands","tier":"basic"},
  {"input":{"grid":[["1"]]},"expected":1,"description":"Edge: single land cell","tier":"edge"},
  {"input":{"grid":[["0"]]},"expected":0,"description":"Edge: single water cell","tier":"edge"},
  {"input":{"grid":[["1","0","1"],["0","1","0"],["1","0","1"]]},"expected":5,"description":"Corner: checkerboard","tier":"corner"},
  {"input":{"grid":[["1","1","1"],["0","1","0"],["1","1","1"]]},"expected":1,"description":"Corner: ring island","tier":"corner"}
]'::jsonb where slug = 'number-of-islands';

update questions set test_cases = '[
  {"input":{"grid":[[0,0,1,0,0,0,0,1,0,0,0,0,0],[0,0,0,0,0,0,0,1,1,1,0,0,0],[0,1,1,0,1,0,0,0,0,0,0,0,0],[0,1,0,0,1,1,0,0,1,0,1,0,0],[0,1,0,0,1,1,0,0,1,1,1,0,0],[0,0,0,0,0,0,0,0,0,0,1,0,0],[0,0,0,0,0,0,0,1,1,1,0,0,0],[0,0,0,0,0,0,0,1,1,0,0,0,0]]},"expected":6,"description":"Basic: largest island is 6","tier":"basic"},
  {"input":{"grid":[[0,0,0,0,0,0,0,0]]},"expected":0,"description":"Edge: no islands","tier":"edge"},
  {"input":{"grid":[[1]]},"expected":1,"description":"Edge: single cell island","tier":"edge"},
  {"input":{"grid":[[1,1],[1,1]]},"expected":4,"description":"Corner: entire grid is island","tier":"corner"}
]'::jsonb where slug = 'max-area-of-island';

update questions set test_cases = '[
  {"input":{"numCourses":2,"prerequisites":[[1,0]]},"expected":true,"description":"Basic: simple dependency","tier":"basic"},
  {"input":{"numCourses":2,"prerequisites":[[1,0],[0,1]]},"expected":false,"description":"Basic: circular dependency","tier":"basic"},
  {"input":{"numCourses":1,"prerequisites":[]},"expected":true,"description":"Edge: single course","tier":"edge"},
  {"input":{"numCourses":3,"prerequisites":[[1,0],[2,1]]},"expected":true,"description":"Edge: linear chain","tier":"edge"},
  {"input":{"numCourses":4,"prerequisites":[[1,0],[2,1],[3,2],[1,3]]},"expected":false,"description":"Corner: cycle in longer chain","tier":"corner"},
  {"input":{"numCourses":5,"prerequisites":[[1,4],[2,4],[3,1],[3,2]]},"expected":true,"description":"Corner: diamond dependency","tier":"corner"}
]'::jsonb where slug = 'course-schedule';

update questions set test_cases = '[
  {"input":{"numCourses":2,"prerequisites":[[1,0]]},"expected":[0,1],"description":"Basic: simple order","tier":"basic"},
  {"input":{"numCourses":4,"prerequisites":[[1,0],[2,0],[3,1],[3,2]]},"expected":[0,1,2,3],"description":"Basic: diamond topology","tier":"basic"},
  {"input":{"numCourses":2,"prerequisites":[[0,1],[1,0]]},"expected":[],"description":"Basic: cycle no order","tier":"basic"},
  {"input":{"numCourses":1,"prerequisites":[]},"expected":[0],"description":"Edge: single course","tier":"edge"},
  {"input":{"numCourses":3,"prerequisites":[]},"expected":[0,1,2],"description":"Edge: no prerequisites","tier":"edge"}
]'::jsonb where slug = 'course-schedule-ii';

update questions set test_cases = '[
  {"input":{"n":5,"edges":[[0,1],[1,2],[3,4]]},"expected":2,"description":"Basic: two components","tier":"basic"},
  {"input":{"n":5,"edges":[[0,1],[1,2],[2,3],[3,4]]},"expected":1,"description":"Basic: one chain","tier":"basic"},
  {"input":{"n":1,"edges":[]},"expected":1,"description":"Edge: single node","tier":"edge"},
  {"input":{"n":3,"edges":[]},"expected":3,"description":"Edge: no edges isolated nodes","tier":"edge"},
  {"input":{"n":4,"edges":[[0,1],[2,3]]},"expected":2,"description":"Corner: two pairs","tier":"corner"}
]'::jsonb where slug = 'number-connected-components';

update questions set test_cases = '[
  {"input":{"n":5,"edges":[[0,1],[0,2],[0,3],[1,4]]},"expected":true,"description":"Basic: valid tree","tier":"basic"},
  {"input":{"n":5,"edges":[[0,1],[1,2],[2,3],[1,3],[1,4]]},"expected":false,"description":"Basic: cycle present","tier":"basic"},
  {"input":{"n":1,"edges":[]},"expected":true,"description":"Edge: single node","tier":"edge"},
  {"input":{"n":2,"edges":[[0,1]]},"expected":true,"description":"Edge: two nodes one edge","tier":"edge"},
  {"input":{"n":4,"edges":[[0,1],[2,3]]},"expected":false,"description":"Corner: disconnected","tier":"corner"},
  {"input":{"n":4,"edges":[[0,1],[1,2],[2,3],[0,3]]},"expected":false,"description":"Corner: cycle of four","tier":"corner"}
]'::jsonb where slug = 'graph-valid-tree';

update questions set test_cases = '[
  {"input":{"grid":[[2,1,1],[1,1,0],[0,1,1]]},"expected":4,"description":"Basic: 4 minutes","tier":"basic"},
  {"input":{"grid":[[2,1,1],[0,1,1],[1,0,1]]},"expected":-1,"description":"Basic: impossible","tier":"basic"},
  {"input":{"grid":[[0,2]]},"expected":0,"description":"Edge: no fresh oranges","tier":"edge"},
  {"input":{"grid":[[2]]},"expected":0,"description":"Edge: single rotten","tier":"edge"},
  {"input":{"grid":[[1]]},"expected":-1,"description":"Edge: isolated fresh","tier":"edge"},
  {"input":{"grid":[[2,1,1],[1,1,1],[0,1,2]]},"expected":2,"description":"Corner: two rotten sources","tier":"corner"}
]'::jsonb where slug = 'rotting-oranges';

update questions set test_cases = '[
  {"input":{"heights":[[1,2,2,3,5],[3,2,3,4,4],[2,4,5,3,1],[6,7,1,4,5],[5,1,1,2,4]]},"expected":[[0,4],[1,3],[1,4],[2,2],[3,0],[3,1],[4,0]],"description":"Basic: several flow points","tier":"basic"},
  {"input":{"heights":[[1]]},"expected":[[0,0]],"description":"Edge: single cell flows to both","tier":"edge"},
  {"input":{"heights":[[1,1],[1,1]]},"expected":[[0,0],[0,1],[1,0],[1,1]],"description":"Corner: all cells equal","tier":"corner"}
]'::jsonb where slug = 'pacific-atlantic-water-flow';

update questions set test_cases = '[
  {"input":{"beginWord":"hit","endWord":"cog","wordList":["hot","dot","dog","lot","log","cog"]},"expected":5,"description":"Basic: length 5 path","tier":"basic"},
  {"input":{"beginWord":"hit","endWord":"cog","wordList":["hot","dot","dog","lot","log"]},"expected":0,"description":"Basic: end word not in list","tier":"basic"},
  {"input":{"beginWord":"a","endWord":"c","wordList":["a","b","c"]},"expected":2,"description":"Edge: single char words","tier":"edge"},
  {"input":{"beginWord":"hot","endWord":"dog","wordList":["hot","dog"]},"expected":0,"description":"Edge: no path exists","tier":"edge"}
]'::jsonb where slug = 'word-ladder';
