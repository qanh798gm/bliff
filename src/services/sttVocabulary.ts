// ============================================================
// STT Vocabulary — Whisper prompt priming + post-processing
// ============================================================
//
// Whisper accepts a `prompt` field (up to ~224 tokens) that biases
// the transcription toward specific spellings and terms.
// We also run a lightweight regex pass after transcription to fix
// common misrecognitions that survive even with prompt priming.
//
// Usage:
//   buildSttPrompt(questionTitle?)  → string passed to Groq API
//   postProcessTranscript(text)     → corrected transcript string
// ============================================================

// ── App-specific proper nouns ─────────────────────────────────
const APP_TERMS = [
  'Bliff',
  'LeetCode',
  'NeetCode',
  'Blind 75',
  'FAANG',
  'Supabase',
  'Monaco',
  'TypeScript',
  'JavaScript',
  'React',
  'Vite',
  'Tailwind',
]

// ── DSA — Data Structures ─────────────────────────────────────
const DATA_STRUCTURES = [
  // Arrays & Pointers
  'array', 'subarray', 'two-pointer', 'sliding window',
  // Hash Structures
  'HashMap', 'HashSet', 'hash map', 'hash set', 'hash table',
  // Stack & Queue
  'stack', 'queue', 'deque', 'monotonic stack', 'priority queue',
  // Linked Lists
  'linked list', 'singly linked list', 'doubly linked list',
  'ListNode', 'dummy node', 'fast pointer', 'slow pointer', 'Floyd\'s cycle',
  // Trees
  'binary tree', 'binary search tree', 'BST', 'AVL tree', 'B-tree',
  'TreeNode', 'root', 'leaf node', 'parent node', 'child node',
  'inorder', 'preorder', 'postorder', 'level order',
  // Tries
  'Trie', 'prefix tree', 'TrieNode', 'autocomplete',
  // Heaps
  'heap', 'min-heap', 'max-heap', 'heapify', 'heappush', 'heappop',
  // Graphs
  'graph', 'directed graph', 'undirected graph', 'weighted graph',
  'adjacency list', 'adjacency matrix', 'edge', 'vertex', 'node',
  'connected component', 'strongly connected component', 'cycle',
  'topological sort', 'topological order',
  // Intervals
  'interval', 'overlapping intervals', 'merge intervals',
  // Math & Bit
  'bitmask', 'bitwise AND', 'bitwise OR', 'XOR', 'left shift', 'right shift',
  'modulo', 'GCD', 'LCM', 'prime', 'Sieve of Eratosthenes',
]

// ── DSA — Algorithms ─────────────────────────────────────────
const ALGORITHMS = [
  // Search
  'binary search', 'linear search', 'BFS', 'DFS',
  'breadth-first search', 'depth-first search',
  // Graph algorithms
  'Dijkstra', 'Bellman-Ford', 'Floyd-Warshall',
  'Kruskal', 'Prim', 'union-find', 'disjoint set',
  // Sorting
  'quicksort', 'mergesort', 'heapsort', 'bubble sort', 'insertion sort',
  'counting sort', 'radix sort', 'bucket sort',
  // Dynamic Programming
  'dynamic programming', 'memoization', 'tabulation', 'bottom-up', 'top-down',
  'DP table', 'subproblem', 'recurrence relation', 'base case',
  'knapsack', '0/1 knapsack', 'longest common subsequence', 'LCS',
  'longest increasing subsequence', 'LIS',
  'edit distance', 'Levenshtein', 'coin change', 'climbing stairs',
  'house robber', 'word break', 'palindrome partitioning',
  // Backtracking
  'backtracking', 'pruning', 'N-queens', 'permutation', 'combination',
  'subset', 'power set',
  // Greedy
  'greedy', 'greedy algorithm', 'activity selection',
  // Two-pointer & sliding window
  'two-pointer technique', 'fast and slow pointer',
  'fixed window', 'variable window', 'shrink', 'expand',
]

// ── Complexity notation ───────────────────────────────────────
const COMPLEXITY = [
  'O(1)', 'O(log n)', 'O(n)', 'O(n log n)', 'O(n²)', 'O(n^2)',
  'O(n³)', 'O(2^n)', 'O(n!)',
  'time complexity', 'space complexity', 'auxiliary space',
  'amortized', 'amortized O(1)', 'worst case', 'average case', 'best case',
  'constant time', 'logarithmic', 'linear', 'linearithmic',
  'quadratic', 'exponential', 'factorial',
]

// ── Frontend — JavaScript ────────────────────────────────────
const FRONTEND_JS = [
  // Core JS
  'closure', 'hoisting', 'prototype', 'prototype chain',
  'event loop', 'call stack', 'task queue', 'microtask queue',
  'Promise', 'async/await', 'callback', 'higher-order function',
  'arrow function', 'spread operator', 'rest parameter', 'destructuring',
  'Map', 'Set', 'WeakMap', 'WeakSet',
  'Symbol', 'BigInt', 'typeof', 'instanceof',
  'null', 'undefined', 'NaN', 'Infinity',
  'strict mode', 'let', 'const', 'var',
  'generator', 'iterator', 'Symbol.iterator',
  'Proxy', 'Reflect', 'Object.keys', 'Object.entries',
  // DOM
  'DOM', 'virtual DOM', 'shadow DOM',
  'querySelector', 'getElementById', 'addEventListener',
  'event delegation', 'event bubbling', 'event capturing',
  'preventDefault', 'stopPropagation',
  'innerHTML', 'textContent', 'setAttribute',
  // Browser APIs
  'localStorage', 'sessionStorage', 'IndexedDB',
  'fetch', 'XMLHttpRequest', 'WebSocket',
  'requestAnimationFrame', 'setTimeout', 'setInterval',
  'MutationObserver', 'IntersectionObserver', 'ResizeObserver',
  'Service Worker', 'Web Worker',
]

// ── Frontend — React ─────────────────────────────────────────
const FRONTEND_REACT = [
  'React', 'JSX', 'TSX',
  'useState', 'useEffect', 'useCallback', 'useMemo', 'useRef',
  'useContext', 'useReducer', 'useLayoutEffect', 'useId',
  'custom hook', 'hook',
  'props', 'state', 'context', 'ref',
  'component', 'functional component', 'class component',
  'lifecycle', 'mounting', 'unmounting', 're-render',
  'reconciliation', 'diffing algorithm', 'fiber',
  'React.memo', 'React.lazy', 'Suspense',
  'controlled component', 'uncontrolled component',
  'higher-order component', 'HOC', 'render props',
  'React Router', 'useNavigate', 'useParams',
  'Redux', 'Zustand', 'Jotai', 'Recoil',
  'React Query', 'SWR',
]

// ── Frontend — TypeScript ─────────────────────────────────────
const FRONTEND_TS = [
  'TypeScript', 'interface', 'type alias', 'generic', 'enum',
  'union type', 'intersection type', 'tuple', 'never', 'unknown', 'any',
  'type guard', 'narrowing', 'assertion', 'non-null assertion',
  'readonly', 'partial', 'required', 'pick', 'omit', 'record',
  'infer', 'conditional type', 'mapped type', 'template literal type',
]

// ── Frontend — CSS ────────────────────────────────────────────
const FRONTEND_CSS = [
  'CSS', 'Tailwind', 'CSS-in-JS', 'styled-components', 'Sass', 'SCSS',
  'flexbox', 'CSS Grid', 'grid', 'media query', 'responsive design',
  'box model', 'margin', 'padding', 'border', 'z-index',
  'position', 'relative', 'absolute', 'fixed', 'sticky',
  'BEM', 'CSS modules', 'CSS variables', 'custom properties',
  'animation', 'transition', 'transform', 'keyframe',
  'specificity', 'cascade', 'inheritance',
]

// ── Frontend — Performance & System Design ────────────────────
const FRONTEND_PERF = [
  // Performance
  'code splitting', 'lazy loading', 'tree shaking', 'bundle size',
  'minification', 'compression', 'gzip', 'brotli',
  'caching', 'CDN', 'HTTP cache', 'cache-control',
  'LCP', 'FID', 'CLS', 'FCP', 'TTFB', 'Core Web Vitals',
  'debounce', 'throttle', 'memoize',
  'critical rendering path', 'render blocking',
  'Web Vitals', 'Lighthouse', 'Webpack', 'Vite', 'Rollup', 'Parcel',
  // System Design
  'REST', 'GraphQL', 'WebSocket', 'Server-Sent Events', 'SSE',
  'SSR', 'SSG', 'CSR', 'ISR', 'hydration',
  'Next.js', 'Nuxt.js', 'Remix',
  'micro-frontend', 'monorepo', 'module federation',
  'authentication', 'authorization', 'JWT', 'OAuth', 'session',
  'CORS', 'CSP', 'XSS', 'CSRF',
  'rate limiting', 'pagination', 'infinite scroll', 'virtual list',
  'optimistic update', 'stale-while-revalidate',
]

// ── Interview / Process terms ─────────────────────────────────
const INTERVIEW_TERMS = [
  'edge case', 'base case', 'off-by-one', 'overflow', 'underflow',
  'null pointer', 'null check', 'empty array', 'empty string',
  'negative number', 'integer overflow', 'index out of bounds',
  'brute force', 'optimize', 'trade-off', 'bottleneck',
  'clarifying question', 'constraint', 'assumption',
  'walk through', 'trace through', 'dry run', 'test case',
  'runtime', 'in-place', 'mutate', 'immutable',
  'pointer', 'index', 'iterator', 'enumerate',
  'increment', 'decrement', 'initialize', 'instantiate',
]

// ── Priority order: most impactful terms first ───────────────
// Groq hard limit: 896 characters for the prompt field.
// We fill up to the limit in priority order, then truncate cleanly.
const PRIORITY_TERMS: string[] = [
  // App name — highest priority
  ...APP_TERMS,
  // Complexity notation — very commonly misrecognised
  ...COMPLEXITY,
  // Core interview / DSA vocabulary
  ...INTERVIEW_TERMS,
  // Core data structures + algorithms
  ...DATA_STRUCTURES,
  ...ALGORITHMS,
  // Frontend (lower priority — less likely to appear in DSA sessions)
  ...FRONTEND_REACT,
  ...FRONTEND_TS,
  ...FRONTEND_JS,
  ...FRONTEND_CSS,
  ...FRONTEND_PERF,
]

const GROQ_PROMPT_LIMIT = 896

/**
 * Build the Whisper prompt string, staying within Groq's 896-character limit.
 *
 * Terms are added in priority order (app name → complexity → DSA → frontend).
 * If a question title is provided it is prepended and counts toward the limit.
 *
 * @param questionTitle  Optional current question title to include for better
 *                       recognition of domain-specific problem names.
 */
export function buildSttPrompt(questionTitle?: string): string {
  const prefix = questionTitle ? `${questionTitle}. ` : ''
  const available = GROQ_PROMPT_LIMIT - prefix.length

  let result = ''
  for (const term of PRIORITY_TERMS) {
    const candidate = result ? `${result}, ${term}` : term
    if (candidate.length > available) break
    result = candidate
  }

  return prefix + result
}

// ── Post-processing corrections ───────────────────────────────
// Applied after transcription to fix stubborn misrecognitions.
// Each entry: [pattern, replacement]
// Keep the list targeted — only add terms Whisper consistently gets wrong
// even when they appear in the prompt.

const CORRECTIONS: Array<[RegExp, string]> = [
  // App name
  [/\bbliss\b/gi, 'Bliff'],
  [/\bbliff\b/gi, 'Bliff'],            // normalize casing
  // LeetCode
  [/\blead code\b/gi, 'LeetCode'],
  [/\bleet code\b/gi, 'LeetCode'],
  [/\blead coder\b/gi, 'LeetCode'],
  // Complexity
  [/\bo of one\b/gi, 'O(1)'],
  [/\bo of n\b/gi, 'O(n)'],
  [/\bo of log n\b/gi, 'O(log n)'],
  [/\bo of n log n\b/gi, 'O(n log n)'],
  [/\bo of n squared\b/gi, 'O(n²)'],
  [/\bo of n \^ 2\b/gi, 'O(n²)'],
  [/\bo of 2 to the n\b/gi, 'O(2^n)'],
  [/\bo of n factorial\b/gi, 'O(n!)'],
  // Data structures
  [/\bhash map\b/gi, 'HashMap'],
  [/\bhash set\b/gi, 'HashSet'],
  [/\blinked list\b/gi, 'linked list'],  // normalize
  [/\bbinary search tree\b/gi, 'BST'],
  [/\bbreadth first search\b/gi, 'BFS'],
  [/\bdepth first search\b/gi, 'DFS'],
  [/\bdynamic programming\b/gi, 'DP'],
  // React hooks
  [/\buse state\b/gi, 'useState'],
  [/\buse effect\b/gi, 'useEffect'],
  [/\buse callback\b/gi, 'useCallback'],
  [/\buse memo\b/gi, 'useMemo'],
  [/\buse ref\b/gi, 'useRef'],
  [/\buse context\b/gi, 'useContext'],
  [/\buse reducer\b/gi, 'useReducer'],
]

/**
 * Apply post-processing corrections to a raw Whisper transcript.
 * Runs all regex substitutions in order.
 */
export function postProcessTranscript(text: string): string {
  return CORRECTIONS.reduce((t, [pattern, replacement]) => t.replace(pattern, replacement), text)
}
