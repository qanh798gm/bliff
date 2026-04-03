-- ============================================================
-- Seed: Math & Bit Manipulation questions (Blind 75 + NeetCode 150)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'math-bit'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Number of 1 Bits', 'number-of-1-bits', 'easy', 'blind75',
    'Write a function that takes the binary representation of a positive integer and returns the number of set bits (also known as the Hamming weight).',
    '[{"input":"n = 11","output":"3","explanation":"11 = 1011 in binary, which has 3 set bits."},{"input":"n = 128","output":"1"},{"input":"n = 2147483645","output":"30"}]',
    array['1 <= n <= 2^31 - 1'],
    array['Use n & 1 to check the last bit, then right-shift n.','Or use n & (n-1) which clears the lowest set bit — count iterations until n = 0.','In JS, use >>> for unsigned right shift.'],
    'n & (n-1) clears lowest set bit. Count iterations until n == 0.',
    'O(k) where k = number of set bits', 'O(1)',
    array['bit-manipulation','math'], 'hammingWeight',
    'function hammingWeight(n) { }', 191
  ),
  (
    'Counting Bits', 'counting-bits', 'easy', 'neetcode150',
    'Given an integer n, return an array ans of length n + 1 such that for each i (0 <= i <= n), ans[i] is the number of 1s in the binary representation of i.',
    '[{"input":"n = 2","output":"[0,1,1]"},{"input":"n = 5","output":"[0,1,1,2,1,2]"}]',
    array['0 <= n <= 10^5'],
    array['DP: dp[i] = dp[i >> 1] + (i & 1).','The number of bits in i = bits in i/2 + the last bit.'],
    'DP: dp[i] = dp[i >> 1] + (i & 1).',
    'O(n)', 'O(n)',
    array['bit-manipulation','dynamic-programming','math'], 'countBits',
    'function countBits(n) { }', 338
  ),
  (
    'Reverse Bits', 'reverse-bits', 'easy', 'blind75',
    'Reverse bits of a given 32-bit unsigned integer.',
    '[{"input":"n = 43261596","output":"964176192","explanation":"43261596 = 00000010100101000001111010011100, reversed = 00111001011110000010100101000000 = 964176192"},{"input":"n = 4294967293","output":"3221225471"}]',
    array['The input must be a binary string of length 32'],
    array['Iterate 32 times.','Each iteration: result = (result << 1) | (n & 1), then n >>= 1.','In JS, use unsigned right shift >>> and bitwise OR.'],
    'Loop 32 times: shift result left, OR with LSB of n, right-shift n.',
    'O(1) — always 32 iterations', 'O(1)',
    array['bit-manipulation','math'], 'reverseBits',
    'function reverseBits(n) { }', 190
  ),
  (
    'Missing Number', 'missing-number', 'easy', 'blind75',
    'Given an array nums containing n distinct numbers in the range [0, n], return the only number in the range that is missing from the array.',
    '[{"input":"nums = [3,0,1]","output":"2"},{"input":"nums = [0,1]","output":"2"},{"input":"nums = [9,6,4,2,3,5,7,0,1]","output":"8"}]',
    array['n == nums.length','1 <= n <= 10^4','0 <= nums[i] <= n','All the numbers of nums are unique.'],
    array['Expected sum = n*(n+1)/2. Missing = expectedSum - actualSum.','Or XOR approach: XOR all indices and all values, the result is the missing number.'],
    'Sum formula: n*(n+1)/2 - sum(nums). Or XOR all indices ^ all values.',
    'O(n)', 'O(1)',
    array['bit-manipulation','math','array'], 'missingNumber',
    'function missingNumber(nums) { }', 268
  ),
  (
    'Sum of Two Integers', 'sum-of-two-integers', 'medium', 'blind75',
    'Given two integers a and b, return the sum of the two integers without using the operators + and -.',
    '[{"input":"a = 1, b = 2","output":"3"},{"input":"a = 2, b = 3","output":"5"}]',
    array['-1000 <= a, b <= 1000'],
    array['XOR gives sum without carry: a ^ b.','AND gives carry bits: (a & b) << 1.','Repeat until no carry remains.','In JS handle 32-bit overflow with masking.'],
    'Bitwise: sum = a^b (no carry), carry = (a&b)<<1. Repeat until carry=0.',
    'O(1) — at most 32 iterations', 'O(1)',
    array['bit-manipulation','math'], 'getSum',
    'function getSum(a, b) { }', 371
  ),
  (
    'Single Number', 'single-number', 'easy', 'blind75',
    'Given a non-empty array of integers nums, every element appears twice except for one. Find that single one. You must implement a solution with a linear runtime complexity and use only constant extra space.',
    '[{"input":"nums = [2,2,1]","output":"1"},{"input":"nums = [4,1,2,1,2]","output":"4"},{"input":"nums = [1]","output":"1"}]',
    array['1 <= nums.length <= 3 * 10^4','-3 * 10^4 <= nums[i] <= 3 * 10^4','Each element in the array appears twice except for one element which appears only once.'],
    array['XOR of two equal numbers is 0. XOR of any number with 0 is the number itself.','XOR all elements. Pairs cancel out, leaving the single number.'],
    'XOR all elements. Pairs cancel (n^n=0). Result = the lone element.',
    'O(n)', 'O(1)',
    array['bit-manipulation','array'], 'singleNumber',
    'function singleNumber(nums) { }', 136
  ),
  (
    'Power of Two', 'power-of-two', 'easy', 'neetcode150',
    'Given an integer n, return true if it is a power of two. Otherwise, return false. An integer n is a power of two, if there exists an integer x such that n == 2^x.',
    '[{"input":"n = 1","output":"true"},{"input":"n = 16","output":"true"},{"input":"n = 3","output":"false"}]',
    array['-2^31 <= n <= 2^31 - 1'],
    array['A power of two has exactly one bit set in binary.','n & (n-1) clears the lowest set bit. If n > 0 and n & (n-1) == 0, it''s a power of two.'],
    'n > 0 && (n & (n-1)) == 0.',
    'O(1)', 'O(1)',
    array['bit-manipulation','math'], 'isPowerOfTwo',
    'function isPowerOfTwo(n) { }', 231
  ),
  (
    'Reverse Integer', 'reverse-integer', 'medium', 'neetcode150',
    'Given a signed 32-bit integer x, return x with its digits reversed. If reversing x causes the value to go outside the signed 32-bit integer range [-2^31, 2^31 - 1], return 0.',
    '[{"input":"x = 123","output":"321"},{"input":"x = -123","output":"-321"},{"input":"x = 120","output":"21"}]',
    array['-2^31 <= x <= 2^31 - 1'],
    array['Pop the last digit with x % 10 and push to result * 10 + digit.','Check for overflow before multiplying: if result > Integer.MAX_VALUE / 10, overflow.','Handle negative numbers by working with sign separately.'],
    'Pop digits one by one and push to reversed. Check 32-bit overflow.',
    'O(log x)', 'O(1)',
    array['math'], 'reverse',
    'function reverse(x) { }', 7
  ),
  (
    'Encode and Decode Strings', 'encode-decode-strings', 'medium', 'blind75',
    'Design an algorithm to encode a list of strings to a single string. The encoded string is then sent over the network and is decoded back to the original list of strings. Implement encode(strs) and decode(s) methods.',
    '[{"input":"strs = [\"Hello\",\"World\"]","output":"[\"Hello\",\"World\"]"},{"input":"strs = [\"abc\"]","output":"[\"abc\"]"}]',
    array['1 <= strs.length <= 200','0 <= strs[i].length <= 200','strs[i] contains any possible characters out of 256 valid ASCII characters.'],
    array['Use a length-prefix encoding: encode each string as "length#string".','For decode, read the number before #, then read that many characters.','This handles all special characters including # within strings.'],
    'Length-prefix: encode as "len#str". Decode by reading len, then reading len chars.',
    'O(n) where n = total chars', 'O(n)',
    array['string','design','math'], 'encode',
    'function encode(strs) { } function decode(s) { }', 271
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
