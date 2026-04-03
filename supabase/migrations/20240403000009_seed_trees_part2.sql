-- ============================================================
-- Seed: Trees questions Part 2 (BST + hard, Blind 75 + NeetCode 150)
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
    'Validate Binary Search Tree', 'validate-bst', 'medium', 'blind75',
    'Given the root of a binary tree, determine if it is a valid binary search tree (BST). A valid BST is defined as: the left subtree of a node contains only nodes with keys less than the node''s key, the right subtree only nodes with keys greater, and both left and right subtrees must also be valid BSTs.',
    '[{"input":"root = [2,1,3]","output":"true"},{"input":"root = [5,1,4,null,null,3,6]","output":"false"}]',
    array['The number of nodes in the tree is in the range [1, 10^4].','-2^31 <= Node.val <= 2^31 - 1'],
    array['Inorder traversal of a BST gives sorted values — check if inorder is strictly increasing.','Or pass min/max bounds in recursion: each node must satisfy min < val < max.','Left child: max bound becomes parent val. Right child: min bound becomes parent val.'],
    'DFS with min/max bounds. Each node must satisfy minBound < val < maxBound.',
    'O(n)', 'O(h)',
    array['tree','bst','dfs'], 'isValidBST',
    'function isValidBST(root) { }', 98
  ),
  (
    'Kth Smallest Element in a BST', 'kth-smallest-bst', 'medium', 'blind75',
    'Given the root of a binary search tree, and an integer k, return the kth smallest value (1-indexed) of all the values of the nodes in the tree.',
    '[{"input":"root = [3,1,4,null,2], k = 1","output":"1"},{"input":"root = [5,3,6,2,4,null,null,1], k = 3","output":"3"}]',
    array['The number of nodes in the tree is n.','1 <= k <= n <= 10^4','0 <= Node.val <= 10^4'],
    array['Inorder traversal of BST gives elements in sorted order.','Stop when you''ve visited k elements.','Can be done iteratively with a stack to avoid full traversal.'],
    'Inorder traversal (left, root, right) on BST. Stop at kth element.',
    'O(h + k)', 'O(h)',
    array['tree','bst','dfs','inorder'], 'kthSmallest',
    'function kthSmallest(root, k) { }', 230
  ),
  (
    'Construct Binary Tree from Preorder and Inorder Traversal', 'construct-tree-preorder-inorder', 'medium', 'blind75',
    'Given two integer arrays preorder and inorder where preorder is the preorder traversal of a binary tree and inorder is the inorder traversal of the same tree, construct and return the binary tree.',
    '[{"input":"preorder = [3,9,20,15,7], inorder = [9,3,15,20,7]","output":"[3,9,20,null,null,15,7]"},{"input":"preorder = [-1], inorder = [-1]","output":"[-1]"}]',
    array['1 <= preorder.length <= 3000','inorder.length == preorder.length','-3000 <= preorder[i], inorder[i] <= 3000','preorder and inorder consist of unique values.','Each value of inorder also appears in preorder.','preorder is guaranteed to be the preorder traversal of the tree.','inorder is guaranteed to be the inorder traversal of the tree.'],
    array['First element of preorder is always the root.','Find root in inorder array — elements to its left are left subtree, right are right subtree.','Recursively build left and right subtrees.'],
    'Preorder[0] = root. Find in inorder to split. Recurse on left/right halves.',
    'O(n)', 'O(n)',
    array['tree','recursion','divide-and-conquer'], 'buildTree',
    'function buildTree(preorder, inorder) { }', 105
  ),
  (
    'Binary Tree Maximum Path Sum', 'binary-tree-max-path-sum', 'hard', 'blind75',
    'A path in a binary tree is a sequence of nodes where each pair of adjacent nodes in the sequence has an edge connecting them. A node can only appear in the sequence at most once. The path does not need to pass through the root. Given the root of a binary tree, return the maximum path sum of any non-empty path.',
    '[{"input":"root = [1,2,3]","output":"6"},{"input":"root = [-3]","output":"-3"},{"input":"root = [-10,9,20,null,null,15,7]","output":"42"}]',
    array['The number of nodes in the tree is in the range [1, 3 * 10^4].','-1000 <= Node.val <= 1000'],
    array['DFS returning the max gain from a single path going down (left or right, not both).','At each node, compute: val + max(leftGain, 0) + max(rightGain, 0) as candidate for max path.','Update global max, but return val + max(leftGain, rightGain, 0) to parent.'],
    'DFS: at each node compute path through node = val + max(left,0) + max(right,0). Track global max.',
    'O(n)', 'O(h)',
    array['tree','dfs','dynamic-programming'], 'maxPathSum',
    'function maxPathSum(root) { }', 124
  ),
  (
    'Serialize and Deserialize Binary Tree', 'serialize-deserialize-binary-tree', 'hard', 'blind75',
    'Design an algorithm to serialize and deserialize a binary tree. Serialization is the process of converting a data structure or object into a sequence of bits so that it can be stored in a file or memory buffer, or transmitted across a network connection link to be reconstructed later. There is no restriction on how your serialization/deserialization algorithm should work.',
    '[{"input":"root = [1,2,3,null,null,4,5]","output":"[1,2,3,null,null,4,5]"}]',
    array['The number of nodes in the tree is in the range [0, 10^4].','-1000 <= Node.val <= 1000'],
    array['Use preorder DFS with null markers for missing nodes.','Serialize: preorder traversal, append "null" for missing nodes.','Deserialize: process preorder list, recursively reconstruct.'],
    'Preorder DFS serialize with null markers. Deserialize by consuming values recursively.',
    'O(n)', 'O(n)',
    array['tree','dfs','bfs','design'], 'Codec',
    'class Codec { serialize(root) { } deserialize(data) { } }', 297
  ),
  (
    'Path Sum', 'path-sum', 'easy', 'neetcode150',
    'Given the root of a binary tree and an integer targetSum, return true if the tree has a root-to-leaf path such that adding up all the values along the path equals targetSum.',
    '[{"input":"root = [5,4,8,11,null,13,4,7,2,null,null,null,1], targetSum = 22","output":"true"},{"input":"root = [1,2,3], targetSum = 5","output":"false"},{"input":"root = [], targetSum = 0","output":"false"}]',
    array['The number of nodes in the tree is in the range [0, 5000].','-1000 <= Node.val <= 1000','-1000 <= targetSum <= 1000'],
    array['DFS: subtract node val from target as you go down.','At a leaf, check if remaining target == 0.'],
    'DFS: reduce target by node val. At leaf, return target - val == 0.',
    'O(n)', 'O(h)',
    array['tree','dfs','recursion'], 'hasPathSum',
    'function hasPathSum(root, targetSum) { }', 112
  ),
  (
    'Lowest Common Ancestor of a Binary Tree', 'lowest-common-ancestor-bt', 'medium', 'neetcode150',
    'Given a binary tree, find the lowest common ancestor (LCA) of two given nodes in the tree.',
    '[{"input":"root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 1","output":"3"},{"input":"root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 4","output":"5"}]',
    array['The number of nodes in the tree is in the range [2, 10^5].','-10^9 <= Node.val <= 10^9','All Node.val are unique.','p != q','p and q will exist in the tree.'],
    array['If current node is p or q, return it.','Recurse left and right.','If both return non-null, current node is LCA. Otherwise return the non-null result.'],
    'DFS: if node is p or q return it. If left and right both return values, node is LCA.',
    'O(n)', 'O(h)',
    array['tree','dfs','recursion'], 'lowestCommonAncestor',
    'function lowestCommonAncestor(root, p, q) { }', 236
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
