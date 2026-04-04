-- Test Cases: DSA — Trees (Part 1)
-- Tree inputs use null-padded BFS arrays (LeetCode format).
-- invert-binary-tree, max-depth-binary-tree, diameter-binary-tree,
-- balanced-binary-tree, same-tree, subtree-of-another-tree,
-- lowest-common-ancestor-bst, binary-tree-level-order,
-- binary-tree-right-side-view, count-good-nodes-binary-tree

update questions set test_cases = '[
  {"input":{"root":[4,2,7,1,3,6,9]},"expected":[4,7,2,9,6,3,1],"description":"Basic: full binary tree","tier":"basic"},
  {"input":{"root":[2,1,3]},"expected":[2,3,1],"description":"Basic: three nodes","tier":"basic"},
  {"input":{"root":[]},"expected":[],"description":"Edge: empty tree","tier":"edge"},
  {"input":{"root":[1]},"expected":[1],"description":"Edge: single node","tier":"edge"},
  {"input":{"root":[1,2]},"expected":[1,null,2],"description":"Edge: left child only","tier":"edge"},
  {"input":{"root":[1,null,2]},"expected":[1,2],"description":"Edge: right child only","tier":"edge"},
  {"input":{"root":[1,2,3,4,5,6,7]},"expected":[1,3,2,7,6,5,4],"description":"Corner: perfect tree depth 3","tier":"corner"},
  {"input":{"root":[3,9,20,null,null,15,7]},"expected":[3,20,9,null,null,7,15],"description":"Corner: uneven tree","tier":"corner"}
]'::jsonb where slug = 'invert-binary-tree';

update questions set test_cases = '[
  {"input":{"root":[3,9,20,null,null,15,7]},"expected":3,"description":"Basic: depth 3","tier":"basic"},
  {"input":{"root":[1,null,2]},"expected":2,"description":"Basic: right-skewed","tier":"basic"},
  {"input":{"root":[]},"expected":0,"description":"Edge: empty tree","tier":"edge"},
  {"input":{"root":[1]},"expected":1,"description":"Edge: single node","tier":"edge"},
  {"input":{"root":[1,2]},"expected":2,"description":"Edge: two nodes","tier":"edge"},
  {"input":{"root":[1,2,3,4,5]},"expected":3,"description":"Corner: left-heavy","tier":"corner"},
  {"input":{"root":[1,null,2,null,3,null,4]},"expected":4,"description":"Corner: right-skewed chain","tier":"corner"}
]'::jsonb where slug = 'max-depth-binary-tree';

update questions set test_cases = '[
  {"input":{"root":[1,2,3,4,5]},"expected":3,"description":"Basic: diameter through root","tier":"basic"},
  {"input":{"root":[1,2]},"expected":1,"description":"Basic: two nodes","tier":"basic"},
  {"input":{"root":[1]},"expected":0,"description":"Edge: single node","tier":"edge"},
  {"input":{"root":[]},"expected":0,"description":"Edge: empty tree","tier":"edge"},
  {"input":{"root":[4,2,1,3,null,null,5]},"expected":4,"description":"Corner: diameter not through root","tier":"corner"},
  {"input":{"root":[1,2,3,4,5,null,null,null,null,6,7]},"expected":6,"description":"Corner: deep left subtree","tier":"corner"}
]'::jsonb where slug = 'diameter-binary-tree';

update questions set test_cases = '[
  {"input":{"root":[3,9,20,null,null,15,7]},"expected":true,"description":"Basic: balanced tree","tier":"basic"},
  {"input":{"root":[1,2,2,3,3,null,null,4,4]},"expected":false,"description":"Basic: unbalanced","tier":"basic"},
  {"input":{"root":[]},"expected":true,"description":"Edge: empty is balanced","tier":"edge"},
  {"input":{"root":[1]},"expected":true,"description":"Edge: single node","tier":"edge"},
  {"input":{"root":[1,2,null,3]},"expected":false,"description":"Edge: left-skewed 3 deep","tier":"edge"},
  {"input":{"root":[1,2,3,4,5,6,null]},"expected":true,"description":"Corner: nearly complete","tier":"corner"}
]'::jsonb where slug = 'balanced-binary-tree';

update questions set test_cases = '[
  {"input":{"p":[1,2,3],"q":[1,2,3]},"expected":true,"description":"Basic: identical trees","tier":"basic"},
  {"input":{"p":[1,2],"q":[1,null,2]},"expected":false,"description":"Basic: different structure","tier":"basic"},
  {"input":{"p":[1,2,1],"q":[1,1,2]},"expected":false,"description":"Basic: different values","tier":"basic"},
  {"input":{"p":[],"q":[]},"expected":true,"description":"Edge: both empty","tier":"edge"},
  {"input":{"p":[1],"q":[]},"expected":false,"description":"Edge: one empty","tier":"edge"},
  {"input":{"p":[1],"q":[1]},"expected":true,"description":"Edge: single equal nodes","tier":"edge"}
]'::jsonb where slug = 'same-tree';

update questions set test_cases = '[
  {"input":{"root":[3,4,5,1,2],"subRoot":[4,1,2]},"expected":true,"description":"Basic: subtree exists","tier":"basic"},
  {"input":{"root":[3,4,5,1,2,null,null,null,null,0],"subRoot":[4,1,2]},"expected":false,"description":"Basic: almost subtree","tier":"basic"},
  {"input":{"root":[1],"subRoot":[1]},"expected":true,"description":"Edge: equal single nodes","tier":"edge"},
  {"input":{"root":[1,null,1,null,null,null,1],"subRoot":[1,null,1]},"expected":true,"description":"Corner: repeated patterns","tier":"corner"}
]'::jsonb where slug = 'subtree-of-another-tree';

update questions set test_cases = '[
  {"input":{"root":[6,2,8,0,4,7,9,null,null,3,5],"p":2,"q":8},"expected":6,"description":"Basic: LCA is root","tier":"basic"},
  {"input":{"root":[6,2,8,0,4,7,9,null,null,3,5],"p":2,"q":4},"expected":2,"description":"Basic: one is ancestor","tier":"basic"},
  {"input":{"root":[2,1],"p":2,"q":1},"expected":2,"description":"Edge: root and child","tier":"edge"},
  {"input":{"root":[6,2,8,0,4,7,9,null,null,3,5],"p":0,"q":5},"expected":2,"description":"Corner: deep nodes same subtree","tier":"corner"}
]'::jsonb where slug = 'lowest-common-ancestor-bst';

update questions set test_cases = '[
  {"input":{"root":[3,9,20,null,null,15,7]},"expected":[[3],[9,20],[15,7]],"description":"Basic: three levels","tier":"basic"},
  {"input":{"root":[1]},"expected":[[1]],"description":"Edge: single node","tier":"edge"},
  {"input":{"root":[]},"expected":[],"description":"Edge: empty tree","tier":"edge"},
  {"input":{"root":[1,2,3,4,5]},"expected":[[1],[2,3],[4,5]],"description":"Corner: three levels left-heavy","tier":"corner"}
]'::jsonb where slug = 'binary-tree-level-order';

update questions set test_cases = '[
  {"input":{"root":[1,2,3,null,5,null,4]},"expected":[1,3,4],"description":"Basic: right side view","tier":"basic"},
  {"input":{"root":[1,null,3]},"expected":[1,3],"description":"Basic: right child only","tier":"basic"},
  {"input":{"root":[]},"expected":[],"description":"Edge: empty tree","tier":"edge"},
  {"input":{"root":[1]},"expected":[1],"description":"Edge: single node","tier":"edge"},
  {"input":{"root":[1,2,3,4]},"expected":[1,3,4],"description":"Corner: left node visible at last level","tier":"corner"}
]'::jsonb where slug = 'binary-tree-right-side-view';

update questions set test_cases = '[
  {"input":{"root":[3,1,4,3,null,1,5]},"expected":4,"description":"Basic: multiple good nodes","tier":"basic"},
  {"input":{"root":[3,3,null,4,2]},"expected":3,"description":"Basic: equal values count","tier":"basic"},
  {"input":{"root":[1]},"expected":1,"description":"Edge: single node always good","tier":"edge"},
  {"input":{"root":[2,null,4,10,8,null,null,4]},"expected":4,"description":"Corner: right-skewed with branches","tier":"corner"}
]'::jsonb where slug = 'count-good-nodes-binary-tree';

update questions set test_cases = '[
  {"input":{"root":[5,1,4,null,null,3,6]},"expected":false,"description":"Basic: invalid BST","tier":"basic"},
  {"input":{"root":[2,1,3]},"expected":true,"description":"Basic: valid BST","tier":"basic"},
  {"input":{"root":[]},"expected":true,"description":"Edge: empty tree","tier":"edge"},
  {"input":{"root":[1]},"expected":true,"description":"Edge: single node","tier":"edge"},
  {"input":{"root":[5,4,6,null,null,3,7]},"expected":false,"description":"Corner: subtree violates BST","tier":"corner"},
  {"input":{"root":[2147483647]},"expected":true,"description":"Corner: max int value","tier":"corner"}
]'::jsonb where slug = 'validate-bst';

update questions set test_cases = '[
  {"input":{"root":[3,1,4,null,2],"k":1},"expected":1,"description":"Basic: smallest","tier":"basic"},
  {"input":{"root":[5,3,6,2,4,null,null,1],"k":3},"expected":3,"description":"Basic: middle element","tier":"basic"},
  {"input":{"root":[1],"k":1},"expected":1,"description":"Edge: single node","tier":"edge"},
  {"input":{"root":[2,1],"k":1},"expected":1,"description":"Edge: two nodes smallest","tier":"edge"},
  {"input":{"root":[5,3,6,2,4],"k":5},"expected":6,"description":"Corner: largest element","tier":"corner"}
]'::jsonb where slug = 'kth-smallest-bst';

update questions set test_cases = '[
  {"input":{"root":[-10,9,20,null,null,15,7]},"expected":42,"description":"Basic: path through right subtree","tier":"basic"},
  {"input":{"root":[1,2,3]},"expected":6,"description":"Basic: all three nodes","tier":"basic"},
  {"input":{"root":[-3]},"expected":-3,"description":"Edge: single negative node","tier":"edge"},
  {"input":{"root":[1,-2,-3,1,3,-2,null,-1]},"expected":3,"description":"Corner: negatives reduce path","tier":"corner"}
]'::jsonb where slug = 'binary-tree-max-path-sum';

update questions set test_cases = '[
  {"input":{"root":[5,4,8,11,null,13,4,7,2,null,null,null,1]},"expected":true,"description":"Basic: path exists 22","tier":"basic"},
  {"input":{"root":[1,2,3],"targetSum":5},"expected":false,"description":"Basic: no path sums to 5","tier":"basic"},
  {"input":{"root":[],"targetSum":0},"expected":false,"description":"Edge: empty tree","tier":"edge"},
  {"input":{"root":[1,2],"targetSum":1},"expected":false,"description":"Edge: sum stops at leaf only","tier":"edge"}
]'::jsonb where slug = 'path-sum';

update questions set test_cases = '[
  {"input":{"root":[3,5,1,6,2,0,8,null,null,7,4],"p":5,"q":1},"expected":3,"description":"Basic: LCA is root","tier":"basic"},
  {"input":{"root":[3,5,1,6,2,0,8,null,null,7,4],"p":5,"q":4},"expected":5,"description":"Basic: p is ancestor","tier":"basic"},
  {"input":{"root":[1,2],"p":1,"q":2},"expected":1,"description":"Edge: root and child","tier":"edge"}
]'::jsonb where slug = 'lowest-common-ancestor-bt';
