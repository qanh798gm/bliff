-- ============================================================
-- Seed: Linked List questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'linked-list'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Reverse Linked List', 'reverse-linked-list', 'easy', 'blind75',
    'Given the head of a singly linked list, reverse the list, and return the reversed list.',
    '[{"input":"head = [1,2,3,4,5]","output":"[5,4,3,2,1]"},{"input":"head = [1,2]","output":"[2,1]"},{"input":"head = []","output":"[]"}]',
    array['The number of nodes in the list is the range [0, 5000].','-5000 <= Node.val <= 5000'],
    array['Use three pointers: prev, curr, next.','Iterate: save next, flip curr.next to prev, move prev and curr forward.','Return prev when curr is null.'],
    'Iterative: prev=null, curr=head. At each step: save next, flip pointer, advance.',
    'O(n)', 'O(1)',
    array['linked-list'], 'reverseList',
    'function reverseList(head) { }', 206
  ),
  (
    'Merge Two Sorted Lists', 'merge-two-sorted-lists', 'easy', 'blind75',
    'You are given the heads of two sorted linked lists list1 and list2. Merge the two lists into one sorted list. The list should be made by splicing together the nodes of the first two lists. Return the head of the merged linked list.',
    '[{"input":"list1 = [1,2,4], list2 = [1,3,4]","output":"[1,1,2,3,4,4]"},{"input":"list1 = [], list2 = []","output":"[]"},{"input":"list1 = [], list2 = [0]","output":"[0]"}]',
    array['The number of nodes in both lists is in the range [0, 50].','-100 <= Node.val <= 100','Both list1 and list2 are sorted in non-decreasing order.'],
    array['Use a dummy head node to simplify edge cases.','Compare list1 and list2 heads, attach smaller to result.','When one list exhausted, attach the other.'],
    'Dummy node + iterate comparing heads. Attach smaller, advance that pointer.',
    'O(m + n)', 'O(1)',
    array['linked-list'], 'mergeTwoLists',
    'function mergeTwoLists(list1, list2) { }', 21
  ),
  (
    'Linked List Cycle', 'linked-list-cycle', 'easy', 'blind75',
    'Given head, the head of a linked list, determine if the linked list has a cycle in it. Return true if there is a cycle, otherwise return false.',
    '[{"input":"head = [3,2,0,-4], pos = 1","output":"true"},{"input":"head = [1,2], pos = 0","output":"false"},{"input":"head = [1], pos = -1","output":"false"}]',
    array['The number of the nodes in the list is in the range [0, 10^4].','-10^5 <= Node.val <= 10^5','pos is -1 or a valid index in the linked-list.'],
    array['Use Floyd''s cycle detection (slow and fast pointers).','Fast moves 2 steps, slow moves 1 step.','If they ever meet, there is a cycle.'],
    'Floyd''s tortoise and hare: slow += 1, fast += 2. If they meet, cycle exists.',
    'O(n)', 'O(1)',
    array['linked-list','two-pointers','fast-slow-pointers'], 'hasCycle',
    'function hasCycle(head) { }', 141
  ),
  (
    'Remove Nth Node From End of List', 'remove-nth-from-end', 'medium', 'blind75',
    'Given the head of a linked list, remove the nth node from the end of the list and return its head.',
    '[{"input":"head = [1,2,3,4,5], n = 2","output":"[1,2,3,5]"},{"input":"head = [1], n = 1","output":"[]"},{"input":"head = [1,2], n = 1","output":"[1]"}]',
    array['The number of nodes in the list is sz.','1 <= sz <= 30','0 <= Node.val <= 100','1 <= n <= sz'],
    array['Use two pointers with a gap of n nodes between them.','Move both at the same speed. When fast reaches end, slow is at the node before target.','Handle edge case: removing the head node.'],
    'Two pointers with gap n: advance fast n steps, then move both until fast.next is null.',
    'O(n)', 'O(1)',
    array['linked-list','two-pointers'], 'removeNthFromEnd',
    'function removeNthFromEnd(head, n) { }', 19
  ),
  (
    'Copy List with Random Pointer', 'copy-list-random-pointer', 'medium', 'blind75',
    'A linked list of length n is given such that each node contains an additional random pointer, which could point to any node in the list, or null. Construct a deep copy of the list.',
    '[{"input":"head = [[7,null],[13,0],[11,4],[10,2],[1,0]]","output":"[[7,null],[13,0],[11,4],[10,2],[1,0]]"}]',
    array['0 <= n <= 1000','-10^4 <= Node.val <= 10^4','Node.random is null or is pointing to some node in the linked list.'],
    array['Use a hash map to map original nodes to their copies.','First pass: create all new nodes.','Second pass: assign next and random pointers using the map.'],
    'HashMap: old node -> new node. Two passes: create nodes, then assign pointers.',
    'O(n)', 'O(n)',
    array['linked-list','hash-map'], 'copyRandomList',
    'function copyRandomList(head) { }', 138
  ),
  (
    'Add Two Numbers', 'add-two-numbers', 'medium', 'blind75',
    'You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order, and each of their nodes contains a single digit. Add the two numbers and return the sum as a linked list.',
    '[{"input":"l1 = [2,4,3], l2 = [5,6,4]","output":"[7,0,8]","explanation":"342 + 465 = 807"},{"input":"l1 = [0], l2 = [0]","output":"[0]"},{"input":"l1 = [9,9,9,9,9,9,9], l2 = [9,9,9,9]","output":"[8,9,9,9,0,0,0,1]"}]',
    array['The number of nodes in each linked list is in the range [1, 100]','0 <= Node.val <= 9','It is guaranteed that the list represents a number that does not have leading zeros.'],
    array['Traverse both lists simultaneously, add digits and carry.','Create new nodes for each sum digit.','Handle remaining carry after both lists exhausted.'],
    'Traverse both lists with carry. Create new list nodes. Handle leftover carry at end.',
    'O(max(m,n))', 'O(max(m,n))',
    array['linked-list','math'], 'addTwoNumbers',
    'function addTwoNumbers(l1, l2) { }', 2
  ),
  (
    'Find the Duplicate Number', 'find-duplicate-number', 'medium', 'blind75',
    'Given an array of integers nums containing n + 1 integers where each integer is in the range [1, n] inclusive, there is only one repeated number in nums, return this repeated number. You must solve the problem without modifying the array nums and uses only constant extra space.',
    '[{"input":"nums = [1,3,4,2,2]","output":"2"},{"input":"nums = [3,1,3,4,2]","output":"3"}]',
    array['1 <= n <= 10^5','nums.length == n + 1','1 <= nums[i] <= n','All the integers in nums appear only once except for precisely one integer which appears two or more times.'],
    array['Treat the array as a linked list: index i points to nums[i].','Since there is a duplicate, there must be a cycle (like Linked List Cycle II).','Use Floyd''s cycle detection to find the entry point of the cycle.'],
    'Floyd''s cycle detection on array-as-linked-list. Duplicate = cycle entry point.',
    'O(n)', 'O(1)',
    array['linked-list','fast-slow-pointers','array','binary-search'], 'findDuplicate',
    'function findDuplicate(nums) { }', 287
  ),
  (
    'LRU Cache', 'lru-cache', 'medium', 'blind75',
    'Design a data structure that follows the constraints of a Least Recently Used (LRU) cache. Implement the LRUCache class with get(key) and put(key, value) methods. get returns value or -1. put inserts or updates. When cache reaches capacity, evict the least recently used key. Both operations must run in O(1).',
    '[{"input":"[\"LRUCache\",\"put\",\"put\",\"get\",\"put\",\"get\",\"put\",\"get\",\"get\",\"get\"] [[2],[1,1],[2,2],[1],[3,3],[2],[4,4],[1],[3],[4]]","output":"[null,null,null,1,null,-1,null,-1,3,4]"}]',
    array['1 <= capacity <= 3000','0 <= key <= 10^4','0 <= value <= 10^5','At most 2 * 10^5 calls will be made to get and put.'],
    array['Use a doubly linked list + hash map.','Hash map: key -> node (O(1) lookup).','Doubly linked list: most recently used at head, LRU at tail.','On access: move node to head. On evict: remove from tail.'],
    'HashMap + doubly linked list. O(1) get/put. Move to head on access, evict from tail.',
    'O(1) all operations', 'O(capacity)',
    array['linked-list','hash-map','design'], 'LRUCache',
    'class LRUCache { constructor(capacity) { } get(key) { } put(key, value) { } }', 146
  ),
  (
    'Merge K Sorted Lists', 'merge-k-sorted-lists', 'hard', 'blind75',
    'You are given an array of k linked-lists lists, each linked-list is sorted in ascending order. Merge all the linked-lists into one sorted linked-list and return it.',
    '[{"input":"lists = [[1,4,5],[1,3,4],[2,6]]","output":"[1,1,2,3,4,4,5,6]"},{"input":"lists = []","output":"[]"},{"input":"lists = [[]]","output":"[]"}]',
    array['k == lists.length','0 <= k <= 10^4','0 <= lists[i].length <= 500','-10^4 <= lists[i][j] <= 10^4','lists[i] is sorted in ascending order.','The sum of lists[i].length will not exceed 10^4.'],
    array['A min-heap (priority queue) approach processes nodes in order.','Or use divide-and-conquer: merge pairs of lists recursively.','Divide and conquer is O(n log k) like merge sort.'],
    'Divide and conquer: merge pairs of lists. Each merge pass halves the list count.',
    'O(n log k)', 'O(1)',
    array['linked-list','heap','divide-and-conquer'], 'mergeKLists',
    'function mergeKLists(lists) { }', 23
  ),
  (
    'Reverse Nodes in k-Group', 'reverse-nodes-k-group', 'hard', 'blind75',
    'Given the head of a linked list, reverse the nodes of the list k at a time, and return the modified list. k is a positive integer and is less than or equal to the length of the linked list. If the number of nodes is not a multiple of k then left-out nodes, in the end, should remain as is.',
    '[{"input":"head = [1,2,3,4,5], k = 2","output":"[2,1,4,3,5]"},{"input":"head = [1,2,3,4,5], k = 3","output":"[3,2,1,4,5]"}]',
    array['The number of nodes in the list is n.','1 <= k <= n <= 5000','0 <= Node.val <= 1000'],
    array['Check if there are at least k nodes remaining before reversing.','Reverse k nodes in place, connect to next group.','Recursively (or iteratively) process the rest.'],
    'Check k nodes exist, reverse group, connect tail to recursive result of rest.',
    'O(n)', 'O(n/k) recursion stack',
    array['linked-list','recursion'], 'reverseKGroup',
    'function reverseKGroup(head, k) { }', 25
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
