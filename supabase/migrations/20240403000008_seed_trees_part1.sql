-- ============================================================
-- Seed: Trees questions Part 1 (easy + medium, Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'trees'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Invert Binary Tree', 'invert-binary-tree', 'easy', 'blind75',
    'Given the root of a binary tree, invert the tree, and return its root.',
    '[{"input":"root = [4,2,7,1,3,6,9]","output":"[4,7,2,9,6,3,1]"},{"input":"root = [2,1,3]","output":"[2,3,1]"},{"input":"root = []","output":"[]"}]',
    array['The number of nodes in the tree is in the range [0, 100].','-100 <= Node.val <= 100'],
    array['Swap the left and right children of every node.','Use recursion: invert left subtree, invert right subtree, then swap.','Base case: null node returns null.'],
    'Recursive: swap left/right, recursively invert both subtrees.',
    'O(n)', 'O(h) recursion stack',
    array['tree','recursion','dfs'], 'invertTree',
    'function invertTree(root) { }', 226
  ),
  (
    'Maximum Depth of Binary Tree', 'max-depth-binary-tree', 'easy', 'blind75',
    'Given the root of a binary tree, return its maximum depth. A binary tree''s maximum depth is the number of nodes along the longest path from the root node down to the farthest leaf node.',
    '[{"input":"root = [3,9,20,null,null,15,7]","output":"3"},{"input":"root = [1,null,2]","output":"2"}]',
    array['The number of nodes in the tree is in the range [0, 10^4].','-100 <= Node.val <= 100'],
    array['Use recursion: depth = 1 + max(left depth, right depth).','Or use BFS and count levels.'],
    'Recursive DFS: 1 + max(depth(left), depth(right)). Base: null = 0.',
    'O(n)', 'O(h)',
    array['tree','recursion','dfs','bfs'], 'maxDepth',
    'function maxDepth(root) { }', 104
  ),
  (
    'Diameter of Binary Tree', 'diameter-binary-tree', 'easy', 'neetcode150',
    'Given the root of a binary tree, return the length of the diameter of the tree. The diameter of a binary tree is the length of the longest path between any two nodes in a tree. This path may or may not pass through the root.',
    '[{"input":"root = [1,2,3,4,5]","output":"3"},{"input":"root = [1,2]","output":"1"}]',
    array['The number of nodes in the tree is in the range [1, 10^4].','-100 <= Node.val <= 100'],
    array['The diameter through any node = height(left) + height(right).','Use a DFS that returns height but also updates a global max diameter.','Diameter doesn''t have to pass through root.'],
    'DFS returning height. At each node: diameter = leftH + rightH. Track max.',
    'O(n)', 'O(h)',
    array['tree','dfs','recursion'], 'diameterOfBinaryTree',
    'function diameterOfBinaryTree(root) { }', 543
  ),
  (
    'Balanced Binary Tree', 'balanced-binary-tree', 'easy', 'neetcode150',
    'Given a binary tree, determine if it is height-balanced. A height-balanced binary tree is a binary tree in which the depth of the two subtrees of every node never differs by more than one.',
    '[{"input":"root = [3,9,20,null,null,15,7]","output":"true"},{"input":"root = [1,2,2,3,3,null,null,4,4]","output":"false"},{"input":"root = []","output":"true"}]',
    array['The number of nodes in the tree is in the range [0, 5000].','-10^4 <= Node.val <= 10^4'],
    array['A naive approach checks balance at each node separately — O(n²).','Better: DFS returning height, return -1 if subtree is unbalanced.','If either subtree returns -1, propagate -1 upward.'],
    'DFS returning height or -1 if unbalanced. Check |leftH - rightH| <= 1 at each node.',
    'O(n)', 'O(h)',
    array['tree','dfs','recursion'], 'isBalanced',
    'function isBalanced(root) { }', 110
  ),
  (
    'Same Tree', 'same-tree', 'easy', 'neetcode150',
    'Given the roots of two binary trees p and q, write a function to check if they are the same or not. Two binary trees are considered the same if they are structurally identical, and the nodes have the same value.',
    '[{"input":"p = [1,2,3], q = [1,2,3]","output":"true"},{"input":"p = [1,2], q = [1,null,2]","output":"false"},{"input":"p = [1,2,1], q = [1,1,2]","output":"false"}]',
    array['The number of nodes in both trees is in the range [0, 100].','-10^4 <= Node.val <= 10^4'],
    array['Recursively compare each node.','Both null: return true. One null: return false. Different values: return false.'],
    'Recursive: check p.val == q.val && same(p.left, q.left) && same(p.right, q.right).',
    'O(n)', 'O(h)',
    array['tree','dfs','recursion'], 'isSameTree',
    'function isSameTree(p, q) { }', 100
  ),
  (
    'Subtree of Another Tree', 'subtree-of-another-tree', 'easy', 'blind75',
    'Given the roots of two binary trees root and subRoot, return true if there is a subtree of root with the same structure and node values of subRoot and false otherwise. A subtree of a binary tree is a tree that consists of a node in tree and all of this node''s descendants.',
    '[{"input":"root = [3,4,5,1,2], subRoot = [4,1,2]","output":"true"},{"input":"root = [3,4,5,1,2,null,null,null,null,0], subRoot = [4,1,2]","output":"false"}]',
    array['The number of nodes in the root tree is in the range [1, 2000].','-10^4 <= root.val <= 10^4'],
    array['For each node in root, check if the subtree rooted there matches subRoot.','Reuse your isSameTree function.','DFS through root, call isSameTree at each node.'],
    'DFS through root. At each node call isSameTree. Return true if any match found.',
    'O(m*n)', 'O(m)',
    array['tree','dfs','recursion'], 'isSubtree',
    'function isSubtree(root, subRoot) { }', 572
  ),
  (
    'Lowest Common Ancestor of a BST', 'lowest-common-ancestor-bst', 'medium', 'blind75',
    'Given a binary search tree (BST), find the lowest common ancestor (LCA) node of two given nodes in the BST. The LCA is defined between two nodes p and q as the lowest node in T that has both p and q as descendants (where we allow a node to be a descendant of itself).',
    '[{"input":"root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 8","output":"6"},{"input":"root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 4","output":"2"}]',
    array['The number of nodes in the tree is in the range [2, 10^5].','-10^9 <= Node.val <= 10^9','All Node.val are unique.','p != q','p and q will exist in the BST.'],
    array['Use BST property: if both p and q are less than root, LCA is in left subtree.','If both greater, LCA is in right subtree.','Otherwise current root is the LCA.'],
    'BST property: split point where p and q diverge is the LCA. Iterative or recursive.',
    'O(h)', 'O(1)',
    array['tree','bst','recursion'], 'lowestCommonAncestor',
    'function lowestCommonAncestor(root, p, q) { }', 235
  ),
  (
    'Binary Tree Level Order Traversal', 'binary-tree-level-order', 'medium', 'blind75',
    'Given the root of a binary tree, return the level order traversal of its nodes'' values (i.e., from left to right, level by level).',
    '[{"input":"root = [3,9,20,null,null,15,7]","output":"[[3],[9,20],[15,7]]"},{"input":"root = [1]","output":"[[1]]"},{"input":"root = []","output":"[]"}]',
    array['The number of nodes in the tree is in the range [0, 2000].','-1000 <= Node.val <= 1000'],
    array['Use BFS with a queue.','Process all nodes at current level before moving to next.','Track level size to know when to start a new level array.'],
    'BFS with queue. For each level, process all nodes in queue, collect values, enqueue children.',
    'O(n)', 'O(n)',
    array['tree','bfs'], 'levelOrder',
    'function levelOrder(root) { }', 102
  ),
  (
    'Binary Tree Right Side View', 'binary-tree-right-side-view', 'medium', 'neetcode150',
    'Given the root of a binary tree, imagine yourself standing on the right side of it, return the values of the nodes you can see ordered from top to bottom.',
    '[{"input":"root = [1,2,3,null,5,null,4]","output":"[1,3,4]"},{"input":"root = [1,null,3]","output":"[1,3]"},{"input":"root = []","output":"[]"}]',
    array['The number of nodes in the tree is in the range [0, 100].','-100 <= Node.val <= 100'],
    array['Use BFS level order traversal.','The rightmost node at each level is the last node processed in that level.','Or use DFS, visiting right subtree first, adding the first node seen at each depth.'],
    'BFS: last node at each level is visible from right side.',
    'O(n)', 'O(n)',
    array['tree','bfs','dfs'], 'rightSideView',
    'function rightSideView(root) { }', 199
  ),
  (
    'Count Good Nodes in Binary Tree', 'count-good-nodes-binary-tree', 'medium', 'neetcode150',
    'Given a binary tree root, a node X in the tree is named good if in the path from root to X there are no nodes with a value greater than X.val. Return the number of good nodes in the binary tree.',
    '[{"input":"root = [3,1,4,3,null,1,5]","output":"4"},{"input":"root = [3,3,null,4,2]","output":"3"},{"input":"root = [1]","output":"1"}]',
    array['The number of nodes in the binary tree is in the range [1, 10^5].','-10^4 <= Node.val <= 10^4'],
    array['DFS: track the maximum value seen on the path from root to current node.','A node is good if its value >= max value on path.','Pass maxSoFar as a parameter in recursion.'],
    'DFS with max value on path. Node is good if val >= maxSoFar. Count good nodes.',
    'O(n)', 'O(h)',
    array['tree','dfs','recursion'], 'goodNodes',
    'function goodNodes(root) { }', 1448
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
