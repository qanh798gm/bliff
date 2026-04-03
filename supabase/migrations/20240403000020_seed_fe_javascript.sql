-- ============================================================
-- Seed: Frontend — JavaScript questions (fe-curated)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'fe-javascript'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Implement debounce()', 'implement-debounce', 'medium', 'fe-curated',
    'Implement a debounce(fn, delay) function. The returned function delays invoking fn until after delay milliseconds have elapsed since the last time the debounced function was invoked.',
    '[{"input":"debounce(log, 300) called 5 times in 100ms","output":"log called once after 300ms idle"},{"input":"debounce(log, 300) called then 400ms pass","output":"log called once"}]',
    array['delay is in milliseconds','The returned function should cancel any pending invocations when called again','Should preserve the this context and arguments of the last call'],
    array['Use setTimeout and clearTimeout.','Each call clears the previous timer and sets a new one.','The fn is only called after delay ms of no new calls.'],
    'Store timer ID in closure. Each call: clearTimeout(timer), timer = setTimeout(fn, delay).',
    'O(1)', 'O(1)',
    array['javascript','closures','timers','frontend'], 'debounce',
    'function debounce(fn, delay) { }', null::integer
  ),
  (
    'Implement throttle()', 'implement-throttle', 'medium', 'fe-curated',
    'Implement a throttle(fn, limit) function. The returned function invokes fn at most once per limit milliseconds. The first call executes immediately; subsequent calls within the limit period are ignored.',
    '[{"input":"throttle(log, 300) called 10 times in 1 second","output":"log called ~3 times"},{"input":"throttle(log, 1000) called once","output":"log called immediately"}]',
    array['limit is in milliseconds','First call should execute immediately','Calls during the limit window are dropped'],
    array['Track whether we are in a "throttle window" with a boolean flag.','On call: if not throttling, invoke fn and set a flag. Set a setTimeout to clear the flag.','Calls while the flag is set are ignored.'],
    'Boolean flag in closure. On call: if not throttled, invoke + set flag + setTimeout to clear flag.',
    'O(1)', 'O(1)',
    array['javascript','closures','timers','frontend'], 'throttle',
    'function throttle(fn, limit) { }', null::integer
  ),
  (
    'Implement curry()', 'implement-curry', 'medium', 'fe-curated',
    'Implement a curry(fn) function that transforms a function of N arguments into a curried version. The curried function should accept arguments one at a time and execute fn when all N arguments are supplied.',
    '[{"input":"curry(add)(1)(2)(3)","output":"6"},{"input":"curry(add)(1, 2)(3)","output":"6"},{"input":"curry(add)(1)(2, 3)","output":"6"}]',
    array['fn.length gives the number of expected arguments','The curried function should support partial application','Arguments can be passed one at a time or in groups'],
    array['Check if the accumulated arguments length >= fn.length.','If yes, call fn(...args). If no, return a new function that collects more args.','Use recursion or closure to accumulate arguments.'],
    'Recursive accumulator: if args.length >= fn.length call fn, else return fn that concatenates more args.',
    'O(n) per call chain', 'O(n)',
    array['javascript','closures','functional','frontend'], 'curry',
    'function curry(fn) { }', null::integer
  ),
  (
    'Implement Promise.all()', 'implement-promise-all', 'medium', 'fe-curated',
    'Implement your own version of Promise.all(promises). It should return a promise that resolves with an array of all resolved values (in order), or rejects as soon as any promise rejects.',
    '[{"input":"Promise.all([Promise.resolve(1), Promise.resolve(2)])","output":"[1, 2]"},{"input":"Promise.all([Promise.resolve(1), Promise.reject(\"error\")])","output":"rejects with \"error\""}]',
    array['Input is an array of promises (or values)','Order of results must match order of input','Rejects immediately on first rejection'],
    array['Create a counter for resolved promises and an array for results.','For each promise, when it resolves, store result at its index and check if all done.','If any rejects, reject the outer promise immediately.'],
    'New Promise wrapper. Track count of resolved. On each resolve store result[i]; on all resolved, resolve with results. On any reject, reject immediately.',
    'O(n)', 'O(n)',
    array['javascript','promises','async','frontend'], 'promiseAll',
    'function promiseAll(promises) { }', null::integer
  ),
  (
    'Implement EventEmitter', 'implement-event-emitter', 'medium', 'fe-curated',
    'Implement an EventEmitter class with on(event, listener), off(event, listener), emit(event, ...args), and once(event, listener) methods.',
    '[{"input":"emitter.on(\"data\", fn); emitter.emit(\"data\", 42)","output":"fn called with 42"},{"input":"emitter.once(\"click\", fn); emitter.emit(\"click\"); emitter.emit(\"click\")","output":"fn called once"}]',
    array['Multiple listeners can be registered for the same event','off() should remove only the specified listener','once() listener is automatically removed after first invocation'],
    array['Store listeners in a Map<string, Function[]>.','emit() calls all listeners for the event with provided args.','once() wraps the listener in a function that calls off() on itself after invocation.'],
    'Map of event -> listeners[]. once() wraps listener to auto-remove itself after first call.',
    'O(n) for emit', 'O(n)',
    array['javascript','design-patterns','events','frontend'], 'EventEmitter',
    'class EventEmitter { on(event, listener) {} off(event, listener) {} emit(event, ...args) {} once(event, listener) {} }', null::integer
  ),
  (
    'Implement deep equal', 'implement-deep-equal', 'medium', 'fe-curated',
    'Implement a deepEqual(a, b) function that returns true if two values are deeply equal. Handle primitives, arrays, objects, null, and undefined.',
    '[{"input":"deepEqual({a: 1, b: {c: 2}}, {a: 1, b: {c: 2}})","output":"true"},{"input":"deepEqual([1, [2, 3]], [1, [2, 4]])","output":"false"},{"input":"deepEqual(null, null)","output":"true"}]',
    array['Handle all primitive types','Recursively compare nested objects and arrays','Null and undefined should be handled correctly','Extra keys in either object means not equal'],
    array['Base case: if a === b, return true.','Check types: if typeof differs, return false.','For arrays: check length and recurse on each index.','For objects: check same keys and recurse on each value.'],
    'Recursive. Base: strict equal. Arrays: check length + recurse indices. Objects: check keys + recurse values.',
    'O(n) where n = total nodes', 'O(d) where d = max depth',
    array['javascript','recursion','objects','frontend'], 'deepEqual',
    'function deepEqual(a, b) { }', null::integer
  ),
  (
    'Implement deep clone', 'implement-deep-clone', 'medium', 'fe-curated',
    'Implement a deepClone(obj) function that creates a deep copy of an object. Handle nested objects, arrays, primitives, null, and circular references.',
    '[{"input":"deepClone({a: 1, b: {c: 2}})","output":"new object {a: 1, b: {c: 2}}"},{"input":"const a = {}; a.self = a; deepClone(a)","output":"clone with circular ref handled"}]',
    array['Handle nested objects and arrays','Handle null and primitives','Bonus: handle circular references using a WeakMap'],
    array['Use a WeakMap to track already-cloned objects (handles circular refs).','For arrays, clone each element recursively.','For plain objects, clone each property recursively.','Primitives and null are returned as-is.'],
    'Recursive with WeakMap for circular ref tracking. Clone arrays/objects element by element.',
    'O(n)', 'O(n)',
    array['javascript','recursion','objects','frontend'], 'deepClone',
    'function deepClone(obj) { }', null::integer
  ),
  (
    'Implement Array.flat()', 'implement-array-flat', 'easy', 'fe-curated',
    'Implement a myFlat(arr, depth) function that flattens a nested array up to the specified depth. If depth is Infinity, flatten completely.',
    '[{"input":"myFlat([1, [2, [3, [4]]]], 1)","output":"[1, 2, [3, [4]]]"},{"input":"myFlat([1, [2, [3]]], Infinity)","output":"[1, 2, 3]"}]',
    array['depth defaults to 1 if not provided','Infinity depth means fully flatten','Non-array elements are kept as-is'],
    array['Recursively iterate elements.','If an element is an array and depth > 0, recurse with depth - 1.','Otherwise push the element to result.'],
    'Recursive reduce. If element is array and depth > 0, spread myFlat(el, depth-1) into result.',
    'O(n)', 'O(n)',
    array['javascript','arrays','recursion','frontend'], 'myFlat',
    'function myFlat(arr, depth = 1) { }', null::integer
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
