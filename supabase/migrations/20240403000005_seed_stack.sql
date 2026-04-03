-- ============================================================
-- Seed: Stack questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'stack'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Valid Parentheses', 'valid-parentheses', 'easy', 'blind75',
    'Given a string s containing just the characters ''('', '')'', ''{'', ''}'', ''['' and '']'', determine if the input string is valid. An input string is valid if: open brackets must be closed by the same type of brackets, and open brackets must be closed in the correct order, and every close bracket has a corresponding open bracket of the same type.',
    '[{"input":"s = \"()\"","output":"true"},{"input":"s = \"()[]{}\"","output":"true"},{"input":"s = \"(]\"","output":"false"}]',
    array['1 <= s.length <= 10^4','s consists of parentheses only ''()[]{}''.'],
    array['Push opening brackets onto a stack.','When you see a closing bracket, check if the top of the stack matches.','At the end, the stack should be empty.'],
    'Stack: push open brackets, pop and verify match on close brackets.',
    'O(n)', 'O(n)',
    array['stack','string'], 'isValid',
    'function isValid(s) { }', 20
  ),
  (
    'Min Stack', 'min-stack', 'medium', 'blind75',
    'Design a stack that supports push, pop, top, and retrieving the minimum element in constant time. Implement the MinStack class with push(val), pop(), top(), and getMin() methods.',
    '[{"input":"[\"MinStack\",\"push\",\"push\",\"push\",\"getMin\",\"pop\",\"top\",\"getMin\"] [[],[-2],[0],[-3],[],[],[],[]]","output":"[null,null,null,null,-3,null,0,-2]"}]',
    array['Methods pop, top and getMin operations will always be called on non-empty stacks.','-2^31 <= val <= 2^31 - 1','At most 3 * 10^4 calls will be made to push, pop, top, and getMin.'],
    array['Use two stacks: one for values, one for minimums.','When pushing, also push current minimum to the min stack.','When popping, pop from both stacks.'],
    'Two stacks: main stack and a min-tracking stack that mirrors minimums at each level.',
    'O(1) all operations', 'O(n)',
    array['stack','design'], 'MinStack',
    'class MinStack { constructor() { } push(val) { } pop() { } top() { } getMin() { } }', 155
  ),
  (
    'Evaluate Reverse Polish Notation', 'evaluate-reverse-polish-notation', 'medium', 'neetcode150',
    'You are given an array of strings tokens that represents an arithmetic expression in Reverse Polish Notation. Evaluate the expression. Return an integer that represents the value of the expression. Valid operators are +, -, *, /. Integer division truncates toward zero.',
    '[{"input":"tokens = [\"2\",\"1\",\"+\",\"3\",\"*\"]","output":"9"},{"input":"tokens = [\"4\",\"13\",\"5\",\"/\",\"+\"]","output":"6"},{"input":"tokens = [\"10\",\"6\",\"9\",\"3\",\"+\",\"-11\",\"*\",\"/\",\"*\",\"17\",\"+\",\"5\",\"+\"]","output":"22"}]',
    array['1 <= tokens.length <= 10^4','tokens[i] is either an operator: "+", "-", "*", or "/", or an integer in the range [-200, 200]'],
    array['Use a stack. Push numbers, pop two operands when you see an operator.','Apply the operator and push the result back.','Be careful: for subtraction and division, order matters (second popped is the left operand).'],
    'Stack: push numbers; on operator pop two, apply, push result. Watch operand order.',
    'O(n)', 'O(n)',
    array['stack','math'], 'evalRPN',
    'function evalRPN(tokens) { }', 150
  ),
  (
    'Generate Parentheses', 'generate-parentheses', 'medium', 'blind75',
    'Given n pairs of parentheses, write a function to generate all combinations of well-formed parentheses.',
    '[{"input":"n = 3","output":"[\"((()))\",\"(()())\",\"(())()\",\"()(())\",\"()()()\"]"},{"input":"n = 1","output":"[\"()\"]"}]',
    array['1 <= n <= 8'],
    array['Use backtracking/recursion. Track open and close counts.','You can add an open paren if open < n.','You can add a close paren if close < open.'],
    'Backtracking: recurse with open/close counts. Add ( if open<n, add ) if close<open.',
    'O(4^n / sqrt(n))', 'O(n)',
    array['backtracking','stack','string'], 'generateParenthesis',
    'function generateParenthesis(n) { }', 22
  ),
  (
    'Daily Temperatures', 'daily-temperatures', 'medium', 'neetcode150',
    'Given an array of integers temperatures represents the daily temperatures, return an array answer such that answer[i] is the number of days you have to wait after the ith day to get a warmer temperature. If there is no future day for which this is possible, keep answer[i] == 0.',
    '[{"input":"temperatures = [73,74,75,71,69,72,76,73]","output":"[1,1,4,2,1,1,0,0]"},{"input":"temperatures = [30,40,50,60]","output":"[1,1,1,0]"},{"input":"temperatures = [30,60,90]","output":"[1,1,0]"}]',
    array['1 <= temperatures.length <= 10^5','30 <= temperatures[i] <= 100'],
    array['Use a monotonic decreasing stack storing indices.','When current temperature > temperature at stack top, that day has found its warmer day.','Pop and record the difference in indices.'],
    'Monotonic decreasing stack of indices. When warmer day found, pop and compute days diff.',
    'O(n)', 'O(n)',
    array['stack','monotonic-stack','array'], 'dailyTemperatures',
    'function dailyTemperatures(temperatures) { }', 739
  ),
  (
    'Car Fleet', 'car-fleet', 'medium', 'neetcode150',
    'There are n cars going to the same destination along a one-lane road. The destination is target miles away. You are given two integer array position and speed, where position[i] is the position of the ith car and speed[i] is the speed of the ith car (in miles per hour). A car can never pass another car ahead of it, but it can catch up to it and drive bumper to bumper at the same speed. Return the number of car fleets that will arrive at the destination.',
    '[{"input":"target = 12, position = [10,8,0,5,3], speed = [2,4,1,1,3]","output":"3"},{"input":"target = 10, position = [3], speed = [3]","output":"1"},{"input":"target = 100, position = [0,2,4], speed = [4,2,1]","output":"1"}]',
    array['n == position.length == speed.length','1 <= n <= 10^5','0 < target <= 10^6','0 <= position[i] < target','All the values of position are unique.','0 < speed[i] <= 10^6'],
    array['Sort cars by position in descending order (closest to target first).','Compute time for each car to reach target.','Use a stack: if current car''s time >= stack top, it forms a new fleet.'],
    'Sort by position descending. Stack of arrival times. New fleet if current time >= top.',
    'O(n log n)', 'O(n)',
    array['stack','sorting','greedy'], 'carFleet',
    'function carFleet(target, position, speed) { }', 853
  ),
  (
    'Largest Rectangle in Histogram', 'largest-rectangle-histogram', 'hard', 'blind75',
    'Given an array of integers heights representing the histogram bar heights where the width of each bar is 1, return the area of the largest rectangle in the histogram.',
    '[{"input":"heights = [2,1,5,6,2,3]","output":"10"},{"input":"heights = [2,4]","output":"4"}]',
    array['1 <= heights.length <= 10^5','0 <= heights[i] <= 10^4'],
    array['Brute force is O(n²). Can we use a stack?','Use a monotonic increasing stack storing indices.','When a shorter bar is found, pop taller bars and compute their max rectangle.'],
    'Monotonic increasing stack. When shorter bar found, pop and compute width * height.',
    'O(n)', 'O(n)',
    array['stack','monotonic-stack','array'], 'largestRectangleArea',
    'function largestRectangleArea(heights) { }', 84
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
