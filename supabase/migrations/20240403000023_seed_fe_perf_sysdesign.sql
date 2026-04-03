-- ============================================================
-- Seed: Frontend — Performance questions (fe-curated)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'fe-performance'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Core Web Vitals explained', 'core-web-vitals', 'medium', 'fe-curated',
    'Explain Google Core Web Vitals: LCP, FID/INP, and CLS. What does each measure? What are the good/needs improvement/poor thresholds? Give one concrete optimization for each.',
    '[{"input":"Interviewer: Walk me through Core Web Vitals","output":"Candidate explains LCP (loading), INP (interactivity), CLS (visual stability) with thresholds and optimizations"}]',
    array['Cover all three metrics: LCP, INP (replaced FID in 2024), CLS','Give thresholds: good / needs improvement / poor','Give at least one optimization per metric'],
    array['LCP (Largest Contentful Paint): loading. Good < 2.5s. Optimize: preload hero image, CDN, remove render-blocking resources.','INP (Interaction to Next Paint): responsiveness. Good < 200ms. Optimize: break up long tasks, use web workers, code splitting.','CLS (Cumulative Layout Shift): visual stability. Good < 0.1. Optimize: set explicit width/height on images, avoid dynamic content above fold.'],
    'LCP < 2.5s (preload, CDN). INP < 200ms (task splitting, workers). CLS < 0.1 (explicit dimensions, avoid injecting content).',
    'N/A', 'N/A',
    array['performance','web-vitals','conceptual','frontend'], null, null, null::integer
  ),
  (
    'Critical rendering path', 'critical-rendering-path', 'medium', 'fe-curated',
    'Explain the browser critical rendering path. What steps happen from receiving HTML bytes to pixels on screen? What is render-blocking? How do you optimize it?',
    '[{"input":"Interviewer: Explain the critical rendering path","output":"Candidate covers: bytes -> tokens -> DOM/CSSOM -> Render tree -> Layout -> Paint -> Composite"}]',
    array['Cover all steps: bytes, tokens, DOM, CSSOM, render tree, layout, paint, composite','Explain what render-blocking resources are','Give at least 3 optimization techniques'],
    array['Bytes -> parse HTML -> DOM. Simultaneously parse CSS -> CSSOM.','DOM + CSSOM = Render tree. Layout calculates positions. Paint draws pixels. Composite combines layers.','Render-blocking: CSS blocks rendering; synchronous JS blocks HTML parsing.','Optimizations: defer/async scripts, inline critical CSS, preload key resources, remove unused CSS.'],
    'DOM+CSSOM->render tree->layout->paint->composite. Render-blocking: CSS + sync JS. Fix: async/defer, critical CSS inline, preload.',
    'N/A', 'N/A',
    array['performance','browser-internals','conceptual','frontend'], null, null, null::integer
  ),
  (
    'Optimize a slow React app', 'optimize-slow-react-app', 'medium', 'fe-curated',
    'A React application feels sluggish — components re-render too often and the initial load is slow. Walk through your debugging and optimization strategy.',
    '[{"input":"Interviewer: The app is slow, how do you fix it?","output":"Candidate systematically diagnoses with DevTools, then applies appropriate optimizations"}]',
    array['Discuss both runtime performance (re-renders) and load performance (bundle size)','Mention profiling tools before jumping to solutions','Cover at least 5 concrete optimizations'],
    array['Profile first: React DevTools Profiler, Chrome Performance tab.','Re-render fixes: React.memo, useMemo, useCallback, move state down, avoid creating objects/functions in render.','Load fixes: code splitting (lazy/Suspense), tree shaking, image optimization, CDN, caching headers.','Bundle analysis: webpack-bundle-analyzer or vite-plugin-inspect.'],
    'Profile first. Re-renders: memo/useMemo/useCallback. Load: code splitting + lazy, tree shaking, image opt, CDN. Measure after each change.',
    'N/A', 'N/A',
    array['performance','react','optimization','frontend'], null, null, null::integer
  ),
  (
    'Implement image lazy loading', 'implement-lazy-loading', 'easy', 'fe-curated',
    'Describe and implement image lazy loading. How does the native loading="lazy" work? When would you implement it manually using IntersectionObserver?',
    '[{"input":"<img src=\"photo.jpg\" loading=\"lazy\" />","output":"browser defers loading until image is near viewport"},{"input":"manual implementation","output":"IntersectionObserver triggers src assignment when element is visible"}]',
    array['Explain native loading="lazy" attribute','Show manual IntersectionObserver implementation','Discuss when each approach is appropriate'],
    array['Native: loading="lazy" on img/iframe. Browser defers download until ~threshold from viewport.','Manual: store real src in data-src. Use IntersectionObserver to set img.src = img.dataset.src when visible, then unobserve.','Use native first. Manual for older browser support or custom threshold/animation needs.'],
    'Native loading="lazy". Manual: IntersectionObserver on [data-src], swap src on intersection, unobserve after load.',
    'O(n) for setup', 'O(n)',
    array['performance','lazy-loading','browser-api','frontend'], null, null, null::integer
  ),
  (
    'Web Worker for heavy computation', 'web-worker-computation', 'medium', 'fe-curated',
    'Explain Web Workers. When should you use them? Implement a React component that offloads a heavy computation (e.g. sorting 1M items) to a Web Worker to keep the main thread responsive.',
    '[{"input":"sort 1 million items without blocking UI","output":"Web Worker runs computation, main thread stays responsive, result posted back via message"}]',
    array['Explain main thread vs worker thread','Show worker creation and message passing','Show React integration pattern','Discuss Comlink or other abstractions'],
    array['Workers run in separate thread. No DOM access. Communicate via postMessage/onmessage.','Create: new Worker("worker.js") or URL.createObjectURL(blob).','In React: create worker in useEffect, listen to onmessage for results, terminate on cleanup.','Comlink library wraps workers in Proxy for async function call syntax.'],
    'new Worker in useEffect. postMessage(data) to send. onmessage = (e) => setResult(e.data) to receive. Terminate on cleanup.',
    'O(n log n) in worker', 'O(n)',
    array['performance','web-workers','javascript','frontend'], null, null, null::integer
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;

-- ============================================================
-- Seed: Frontend — System Design questions (fe-curated)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'fe-system-design'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Design an autocomplete component', 'design-autocomplete', 'medium', 'fe-curated',
    'Design a production-ready autocomplete/typeahead component. Cover: debouncing, caching, keyboard navigation, accessibility (ARIA), loading states, and error handling.',
    '[{"input":"user types in search box","output":"debounced API call, cached results shown, keyboard navigable dropdown, ARIA combobox pattern"}]',
    array['Discuss API design, debouncing strategy, caching, accessibility','Cover keyboard navigation (arrow keys, Enter, Escape)','Mention ARIA roles: combobox, listbox, option'],
    array['Debounce input at 300ms to limit API calls.','Cache results by query string to avoid duplicate requests.','Keyboard: ArrowDown/Up navigate options, Enter selects, Escape closes.','ARIA: role="combobox" on input, aria-expanded, role="listbox" on dropdown, role="option" on items, aria-activedescendant.','Handle loading spinner, empty state, and error state.'],
    'Debounce -> cache check -> API call -> render listbox. Keyboard nav with activeIndex state. ARIA combobox pattern. Abort stale requests.',
    'N/A', 'N/A',
    array['system-design','accessibility','performance','frontend'], null, null, null::integer
  ),
  (
    'Design a real-time collaborative editor', 'design-collaborative-editor', 'hard', 'fe-curated',
    'Design the frontend architecture for a real-time collaborative text editor (like Google Docs). Focus on: syncing strategies, conflict resolution, WebSocket management, and local-first UX.',
    '[{"input":"two users edit same document simultaneously","output":"changes merge correctly without conflicts, each user sees other edits in real-time"}]',
    array['Discuss operational transformation (OT) or CRDT for conflict resolution','Cover WebSocket management and reconnection','Address optimistic updates and offline support'],
    array['Two approaches: Operational Transformation (OT) or CRDT (e.g. Yjs/Automerge).','OT: server orders operations and transforms them. CRDT: distributed, no coordination needed.','Frontend: apply local changes optimistically, send to server, handle incoming changes.','WebSocket: reconnect with exponential backoff, resync state on reconnect.','Show awareness (cursors): broadcast cursor positions via presence channel.'],
    'CRDT (Yjs) preferred for frontend. Local-first apply. Sync via WebSocket. Reconnect + resync on disconnect. Broadcast cursor presence.',
    'N/A', 'N/A',
    array['system-design','real-time','websocket','crdt','frontend'], null, null, null::integer
  ),
  (
    'Design an infinite scroll feed', 'design-infinite-scroll-feed', 'medium', 'fe-curated',
    'Design an infinite scroll news/social feed. Cover: pagination strategy (cursor vs offset), IntersectionObserver trigger, loading states, error recovery, and performance optimizations for long lists.',
    '[{"input":"user scrolls to bottom","output":"next page fetches, items append, sentinel moves to bottom"},{"input":"10000 items loaded","output":"virtualization prevents DOM bloat"}]',
    array['Compare cursor-based vs offset-based pagination','Show IntersectionObserver sentinel pattern','Cover list virtualization for long lists'],
    array['Cursor pagination is preferred: stable even if new items are inserted, use cursor = last item ID.','IntersectionObserver on a sentinel div at the bottom of the list.','When sentinel intersects, fetch next page and update cursor.','For long lists (1000+), integrate virtual list to keep DOM manageable.','Loading state: skeleton cards. Error state: retry button. Empty state: message.'],
    'Cursor pagination. IntersectionObserver sentinel at list bottom. Append items on intersect. Virtualize at 100+ items. Skeleton/error/empty states.',
    'N/A', 'N/A',
    array['system-design','performance','pagination','frontend'], null, null, null::integer
  ),
  (
    'Design a design system component library', 'design-component-library', 'hard', 'fe-curated',
    'You are tasked with building a shared component library (design system) for a large organization with multiple frontend teams. Design the architecture, tooling, versioning, and distribution strategy.',
    '[{"input":"Interviewer: Design a component library for 20 product teams","output":"Candidate covers: monorepo, atomic design, tokens, versioning, documentation, distribution"}]',
    array['Cover technical architecture: monorepo vs polyrepo, component structure','Cover design tokens for theming','Cover versioning (semver, changesets) and distribution (npm, CDN)','Cover documentation (Storybook) and testing strategy'],
    array['Monorepo (Nx/Turborepo) with packages per component domain.','Design tokens: CSS custom properties or style-dictionary for colors, spacing, typography.','Atomic design: atoms (Button, Input) -> molecules (FormField) -> organisms (LoginForm).','Storybook for interactive docs. Chromatic for visual regression testing.','Versioning: semver + conventional commits + changesets for automated changelog.','Distribution: publish to npm org scope (@myorg/ui). Peer deps: React version stays with consumer.'],
    'Monorepo + atomic design + tokens. Storybook docs. Automated versioning via changesets. npm org publish. Peer React dep.',
    'N/A', 'N/A',
    array['system-design','architecture','design-system','frontend'], null, null, null::integer
  ),
  (
    'Design client-side state management', 'design-state-management', 'medium', 'fe-curated',
    'Compare different React state management approaches: useState/useContext, Redux Toolkit, Zustand, React Query, Jotai/Recoil. When would you choose each? Design the state architecture for a medium-complexity SPA.',
    '[{"input":"Interviewer: How do you decide which state management to use?","output":"Candidate categorizes state types and maps each to the right tool"}]',
    array['Categorize state: server state, UI state, form state, global shared state','Map each category to the right tool','Discuss tradeoffs, not just list features'],
    array['Server state (fetched data) -> React Query / SWR. Handles caching, revalidation, loading/error states.','Global UI state (auth, theme, modal) -> Zustand or Context. Zustand avoids prop drilling without boilerplate.','Complex domain state with actions -> Redux Toolkit (if team knows Redux and needs devtools).','Atomic/derived state -> Jotai/Recoil for fine-grained subscriptions.','Form state -> React Hook Form (not in global store).','URL state -> URL params (shareable, bookmarkable).'],
    'Server state: React Query. Global UI: Zustand. Forms: RHF. Complex domain: RTK. Atomic: Jotai. URL state: search params.',
    'N/A', 'N/A',
    array['system-design','state-management','architecture','frontend'], null, null, null::integer
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
