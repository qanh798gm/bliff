-- ============================================================
-- Test Cases: DSA — Sliding Window
-- Questions: best-time-buy-sell-sw, longest-substring-no-repeat,
--            longest-repeating-char-replacement, permutation-in-string,
--            minimum-window-substring, sliding-window-maximum
-- ============================================================

-- ── Best Time to Buy/Sell Stock (SW variant) ────────────────
update questions set test_cases = '[
  {"input":{"prices":[7,1,5,3,6,4]},"expected":5,"description":"Basic: buy at 1 sell at 6","tier":"basic"},
  {"input":{"prices":[7,6,4,3,1]},"expected":0,"description":"Basic: always declining","tier":"basic"},
  {"input":{"prices":[1,2]},"expected":1,"description":"Basic: two days","tier":"basic"},
  {"input":{"prices":[2,4,1]},"expected":2,"description":"Edge: sell before valley","tier":"edge"},
  {"input":{"prices":[1]},"expected":0,"description":"Edge: one day","tier":"edge"},
  {"input":{"prices":[3,3,3]},"expected":0,"description":"Edge: flat price","tier":"edge"},
  {"input":{"prices":[100,80,60,70,60,85,100]},"expected":40,"description":"Corner: wait for right day","tier":"corner"},
  {"input":{"prices":[1,10000]},"expected":9999,"description":"Corner: huge one-day jump","tier":"corner"}
]'::jsonb where slug = 'best-time-buy-sell-sw';

-- ── Longest Substring Without Repeating Characters ──────────
update questions set test_cases = '[
  {"input":{"s":"abcabcbb"},"expected":3,"description":"Basic: abc","tier":"basic"},
  {"input":{"s":"bbbbb"},"expected":1,"description":"Basic: all same","tier":"basic"},
  {"input":{"s":"pwwkew"},"expected":3,"description":"Basic: wke","tier":"basic"},
  {"input":{"s":""},"expected":0,"description":"Edge: empty string","tier":"edge"},
  {"input":{"s":" "},"expected":1,"description":"Edge: single space","tier":"edge"},
  {"input":{"s":"au"},"expected":2,"description":"Edge: two unique chars","tier":"edge"},
  {"input":{"s":"dvdf"},"expected":3,"description":"Corner: restart mid-string","tier":"corner"},
  {"input":{"s":"abba"},"expected":2,"description":"Corner: palindrome pattern","tier":"corner"}
]'::jsonb where slug = 'longest-substring-no-repeat';

-- ── Longest Repeating Character Replacement ─────────────────
update questions set test_cases = '[
  {"input":{"s":"ABAB","k":2},"expected":4,"description":"Basic: replace 2 to get AAAA","tier":"basic"},
  {"input":{"s":"AABABBA","k":1},"expected":4,"description":"Basic: replace 1","tier":"basic"},
  {"input":{"s":"AAAA","k":0},"expected":4,"description":"Basic: already uniform","tier":"basic"},
  {"input":{"s":"A","k":0},"expected":1,"description":"Edge: single char","tier":"edge"},
  {"input":{"s":"AB","k":1},"expected":2,"description":"Edge: two chars replace one","tier":"edge"},
  {"input":{"s":"ABCD","k":0},"expected":1,"description":"Edge: no replacements","tier":"edge"},
  {"input":{"s":"BAAAB","k":2},"expected":5,"description":"Corner: surround minority","tier":"corner"},
  {"input":{"s":"KQEP","k":4},"expected":4,"description":"Corner: k covers whole string","tier":"corner"}
]'::jsonb where slug = 'longest-repeating-char-replacement';

-- ── Permutation in String ────────────────────────────────────
update questions set test_cases = '[
  {"input":{"s1":"ab","s2":"eidbaooo"},"expected":true,"description":"Basic: ba is permutation","tier":"basic"},
  {"input":{"s1":"ab","s2":"eidboaoo"},"expected":false,"description":"Basic: no permutation","tier":"basic"},
  {"input":{"s1":"adc","s2":"dcda"},"expected":true,"description":"Basic: adc permutation","tier":"basic"},
  {"input":{"s1":"a","s2":"a"},"expected":true,"description":"Edge: single char exact match","tier":"edge"},
  {"input":{"s1":"a","s2":"b"},"expected":false,"description":"Edge: single char no match","tier":"edge"},
  {"input":{"s1":"abc","s2":"ccccbbbbaaaa"},"expected":false,"description":"Edge: chars present but not together","tier":"edge"},
  {"input":{"s1":"hello","s2":"ooolleoooleh"},"expected":false,"description":"Corner: h+e+l+l+o scattered","tier":"corner"},
  {"input":{"s1":"ab","s2":"ab"},"expected":true,"description":"Corner: exact match","tier":"corner"}
]'::jsonb where slug = 'permutation-in-string';

-- ── Minimum Window Substring ────────────────────────────────
update questions set test_cases = '[
  {"input":{"s":"ADOBECODEBANC","t":"ABC"},"expected":"BANC","description":"Basic: classic case","tier":"basic"},
  {"input":{"s":"a","t":"a"},"expected":"a","description":"Basic: exact match","tier":"basic"},
  {"input":{"s":"a","t":"aa"},"expected":"","description":"Basic: impossible","tier":"basic"},
  {"input":{"s":"abc","t":"b"},"expected":"b","description":"Edge: single char target","tier":"edge"},
  {"input":{"s":"abc","t":"abc"},"expected":"abc","description":"Edge: whole string","tier":"edge"},
  {"input":{"s":"ab","t":"b"},"expected":"b","description":"Edge: target at end","tier":"edge"},
  {"input":{"s":"ADOBECODEBANCABC","t":"ABC"},"expected":"ABC","description":"Corner: shorter window at end","tier":"corner"},
  {"input":{"s":"aaflslflsldkalskaaa","t":"aaa"},"expected":"aaa","description":"Corner: triple a at end","tier":"corner"}
]'::jsonb where slug = 'minimum-window-substring';

-- ── Sliding Window Maximum ───────────────────────────────────
update questions set test_cases = '[
  {"input":{"nums":[1,3,-1,-3,5,3,6,7],"k":3},"expected":[3,3,5,5,6,7],"description":"Basic: classic deque case","tier":"basic"},
  {"input":{"nums":[1],"k":1},"expected":[1],"description":"Basic: single element","tier":"basic"},
  {"input":{"nums":[1,-1],"k":1},"expected":[1,-1],"description":"Basic: k=1 returns all","tier":"basic"},
  {"input":{"nums":[9,11],"k":2},"expected":[11],"description":"Edge: k equals length","tier":"edge"},
  {"input":{"nums":[4,-2],"k":2},"expected":[4],"description":"Edge: k equals length with negative","tier":"edge"},
  {"input":{"nums":[-7,-8,7,5,7,1,6,0],"k":4},"expected":[7,7,7,7,7],"description":"Edge: mix of neg and pos","tier":"edge"},
  {"input":{"nums":[1,3,1,2,0,5],"k":3},"expected":[3,3,2,5],"description":"Corner: maximum moves","tier":"corner"},
  {"input":{"nums":[7,2,4],"k":2},"expected":[7,4],"description":"Corner: decreasing then jump","tier":"corner"}
]'::jsonb where slug = 'sliding-window-maximum';
