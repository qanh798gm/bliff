-- ============================================================
-- Seed: Frontend — React questions (fe-curated)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'fe-react'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Implement useLocalStorage hook', 'implement-use-local-storage', 'medium', 'fe-curated',
    'Implement a custom React hook useLocalStorage(key, initialValue) that syncs state with localStorage. The hook should behave like useState but persist the value.',
    '[{"input":"const [name, setName] = useLocalStorage(\"name\", \"Alice\")","output":"state persists across page reloads"},{"input":"setName(\"Bob\")","output":"localStorage[\"name\"] = \"Bob\" and re-render"}]',
    array['Handle JSON serialization/deserialization','Gracefully handle localStorage errors (e.g. private browsing)','Support function updaters like setState(prev => prev + 1)'],
    array['Initialize state by reading from localStorage (parse JSON).','Wrap setState to also write to localStorage.','Use try/catch around localStorage operations in case it is disabled.'],
    'useState initialized from localStorage.getItem(). Custom setter calls both setState and localStorage.setItem().',
    'O(1)', 'O(1)',
    array['react','hooks','custom-hooks','frontend'], 'useLocalStorage',
    'function useLocalStorage(key, initialValue) { }', null::integer
  ),
  (
    'Implement useFetch hook', 'implement-use-fetch', 'medium', 'fe-curated',
    'Implement a custom React hook useFetch(url) that fetches data from a URL. It should return { data, loading, error } and handle cleanup to prevent state updates on unmounted components.',
    '[{"input":"useFetch(\"https://api.example.com/data\")","output":"{ data: null, loading: true, error: null } initially, then { data: ..., loading: false, error: null }"}]',
    array['Should handle loading, success, and error states','Should cancel/ignore the fetch if the component unmounts','Should re-fetch when the URL changes'],
    array['Use useEffect with url as dependency.','Use an AbortController to cancel in-flight requests on cleanup.','Track isMounted or use AbortController signal to prevent state updates after unmount.'],
    'useEffect with AbortController. fetch(url, { signal }). On cleanup, abort(). Track loading/data/error with useState.',
    'O(1)', 'O(1)',
    array['react','hooks','async','fetch','frontend'], 'useFetch',
    'function useFetch(url) { }', null::integer
  ),
  (
    'Implement useDebounce hook', 'implement-use-debounce', 'easy', 'fe-curated',
    'Implement a custom React hook useDebounce(value, delay) that returns a debounced version of the value. The returned value only updates after the specified delay has passed since the last change.',
    '[{"input":"useDebounce(searchQuery, 300)","output":"debouncedQuery updates 300ms after searchQuery stops changing"}]',
    array['delay is in milliseconds','When value changes, start a timer','If value changes again before timer fires, reset the timer'],
    array['Store debounced value in useState.','In useEffect, set a setTimeout to update debouncedValue after delay.','Return the cleanup function to clearTimeout on value change.'],
    'useState for debouncedValue. useEffect: clearTimeout + setTimeout to update debouncedValue. Return debouncedValue.',
    'O(1)', 'O(1)',
    array['react','hooks','custom-hooks','timers','frontend'], 'useDebounce',
    'function useDebounce(value, delay) { }', null::integer
  ),
  (
    'Implement a virtualized list', 'implement-virtualized-list', 'hard', 'fe-curated',
    'Implement a VirtualList component that renders only the visible items in a large list for performance. Given items[], itemHeight (fixed), and containerHeight, render only the items visible in the viewport.',
    '[{"input":"items = 10000 items, itemHeight = 50, containerHeight = 500","output":"only ~10 items rendered in DOM at any time"},{"input":"user scrolls","output":"rendered items update to reflect new viewport"}]',
    array['Each item has a fixed height (itemHeight)','The container has a fixed height (containerHeight)','Use a scrollable container with absolute positioning'],
    array['Listen to scroll events on the container div.','Calculate startIndex = Math.floor(scrollTop / itemHeight).','Calculate endIndex = startIndex + Math.ceil(containerHeight / itemHeight).','Render only items[startIndex..endIndex] with top offset = startIndex * itemHeight.'],
    'Scroll handler computes visible range. Render slice with position:absolute and top = index*itemHeight. Total height div = items.length*itemHeight.',
    'O(visible items)', 'O(visible items)',
    array['react','performance','virtualization','frontend'], 'VirtualList',
    'function VirtualList({ items, itemHeight, containerHeight, renderItem }) { }', null::integer
  ),
  (
    'Implement useIntersectionObserver hook', 'implement-use-intersection-observer', 'medium', 'fe-curated',
    'Implement a custom React hook useIntersectionObserver(ref, options) that uses the IntersectionObserver API to detect when an element enters or leaves the viewport.',
    '[{"input":"const [ref, isVisible] = useIntersectionObserver()","output":"isVisible is true when element is in viewport"},{"input":"element leaves viewport","output":"isVisible becomes false"}]',
    array['Accept IntersectionObserver options (threshold, rootMargin)','Return a ref to attach to the target element and a boolean isVisible','Clean up the observer on unmount'],
    array['Create an IntersectionObserver in useEffect.','Observe the element at ref.current.','Update state when intersection changes.','Return () => observer.disconnect() as cleanup.'],
    'useRef + useState(false). useEffect: new IntersectionObserver(([entry]) => setIsVisible(entry.isIntersecting)). observe(ref.current). Cleanup: disconnect().',
    'O(1)', 'O(1)',
    array['react','hooks','browser-api','frontend'], 'useIntersectionObserver',
    'function useIntersectionObserver(options = {}) { }', null::integer
  ),
  (
    'Design a React modal system', 'react-modal-system', 'medium', 'fe-curated',
    'Design and implement a reusable modal system in React. Create a ModalProvider, useModal hook, and Modal component. The hook should expose open(content) and close() functions.',
    '[{"input":"const { open } = useModal(); open(<MyForm />)","output":"modal appears with MyForm rendered"},{"input":"close()","output":"modal dismisses"}]',
    array['Modals should render in a portal (outside the main DOM tree)','Support backdrop click to close','Only one modal at a time is required','The modal content should be flexible (any React node)'],
    array['Use React Context to share modal state.','Store the modal content in context state.','Use ReactDOM.createPortal to render to document.body.','Expose open(content) and close() through the context.'],
    'Context with content state. open(node) sets content. close() clears it. Modal renders via createPortal when content is set.',
    'O(1)', 'O(1)',
    array['react','design-patterns','context','portals','frontend'], 'ModalProvider',
    'function ModalProvider({ children }) { }', null::integer
  ),
  (
    'Implement React error boundary', 'implement-react-error-boundary', 'medium', 'fe-curated',
    'Implement an ErrorBoundary class component that catches JavaScript errors in its child component tree. It should display a fallback UI when an error is caught.',
    '[{"input":"<ErrorBoundary fallback={<p>Error!</p>}><BrokenComponent /></ErrorBoundary>","output":"renders fallback UI instead of crashing the whole app"}]',
    array['Must be a class component (hooks cannot catch render errors)','Implement getDerivedStateFromError to update state on error','Implement componentDidCatch to log error details','Accept a fallback prop for custom error UI'],
    array['Class component with state { hasError: false }.','static getDerivedStateFromError(error) { return { hasError: true }; }','componentDidCatch(error, info) { logError(error, info); }','In render: if hasError, return this.props.fallback.'],
    'Class component. getDerivedStateFromError sets hasError=true. componentDidCatch logs. render() returns fallback if hasError.',
    'O(1)', 'O(1)',
    array['react','error-handling','class-components','frontend'], 'ErrorBoundary',
    'class ErrorBoundary extends React.Component { }', null::integer
  ),
  (
    'Explain React reconciliation', 'react-reconciliation', 'medium', 'fe-curated',
    'Explain how React reconciliation works. What is the virtual DOM diffing algorithm? What are keys and why are they important? When does React re-render a component?',
    '[{"input":"Interviewer: Explain reconciliation","output":"Candidate explains VDOM, diffing, keys, and render triggers"}]',
    array['This is a conceptual/verbal question','Discuss: virtual DOM, diffing heuristics, keys, re-render triggers','Mention React Fiber if you know it'],
    array['React maintains a virtual DOM tree. On state/props change, it creates a new VDOM and diffs with previous.','Diffing heuristics: (1) different type = unmount old + mount new, (2) same type = update in place.','Keys help React match list items across renders without re-creating them.','Re-renders trigger on: setState, prop change, context change, parent re-render, forceUpdate.'],
    'VDOM diff (O(n) heuristic), key-based list reconciliation, re-render triggers: state/props/context change.',
    'N/A — conceptual', 'N/A',
    array['react','internals','conceptual','frontend'], null,
    null, null::integer
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
