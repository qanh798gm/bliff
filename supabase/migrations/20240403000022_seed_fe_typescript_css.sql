-- ============================================================
-- Seed: Frontend — TypeScript questions (fe-curated)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'fe-typescript'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'Implement a type-safe EventEmitter', 'ts-type-safe-event-emitter', 'hard', 'fe-curated',
    'Using TypeScript generics, implement a type-safe EventEmitter where the event names and their payload types are defined by a generic type map. Calling emit() with the wrong payload type should be a compile error.',
    '[{"input":"emitter.emit(\"data\", 42) where data is typed as number","output":"compiles fine"},{"input":"emitter.emit(\"data\", \"string\") where data is number","output":"TypeScript compile error"}]',
    array['Use a generic type parameter for the event map','Event map keys are string literals, values are payload types','on(), off(), emit() must all be type-safe'],
    array['Define EventMap as a generic: type EventMap = Record<string, unknown>.','Use keyof EventMap to constrain event name.','Use EventMap[K] to type the payload.'],
    'Generic class TypedEventEmitter<T extends Record<string, unknown>>. Methods use K extends keyof T for event, T[K] for payload.',
    'O(n) for emit', 'O(n)',
    array['typescript','generics','design-patterns','frontend'], 'TypedEventEmitter',
    'class TypedEventEmitter<T extends Record<string, unknown>> { }', null::integer
  ),
  (
    'Implement DeepReadonly utility type', 'ts-deep-readonly', 'medium', 'fe-curated',
    'Implement a TypeScript utility type DeepReadonly<T> that recursively makes all properties of an object (including nested objects and arrays) readonly.',
    '[{"input":"type A = DeepReadonly<{a: {b: number[]}}>","output":"{ readonly a: { readonly b: readonly number[] } }"}]',
    array['Must handle nested objects recursively','Must handle arrays','Primitives stay as-is'],
    array['Use conditional types to check if T is an object.','Use mapped types with readonly modifier.','Recurse on each property value: readonly [K in keyof T]: DeepReadonly<T[K]>'],
    'Mapped type with readonly + conditional recursion. Arrays: readonly DeepReadonly<T[number]>[]. Objects: { readonly [K in keyof T]: DeepReadonly<T[K]> }.',
    'N/A — compile-time type', 'N/A',
    array['typescript','utility-types','mapped-types','frontend'], null,
    'type DeepReadonly<T> = any', null::integer
  ),
  (
    'Implement ReturnType from scratch', 'ts-implement-return-type', 'medium', 'fe-curated',
    'Without using the built-in ReturnType<T>, implement your own MyReturnType<T> utility type that extracts the return type of a function type.',
    '[{"input":"type F = () => string; type R = MyReturnType<F>","output":"string"},{"input":"type G = (n: number) => boolean[]; type R = MyReturnType<G>","output":"boolean[]"}]',
    array['Must work with any function signature','Use infer keyword','Should only accept function types'],
    array['Use conditional types: T extends (...args: any[]) => infer R ? R : never.','The infer keyword captures the return type.'],
    'type MyReturnType<T> = T extends (...args: any[]) => infer R ? R : never',
    'N/A — compile-time type', 'N/A',
    array['typescript','utility-types','conditional-types','infer','frontend'], null,
    'type MyReturnType<T> = any', null::integer
  ),
  (
    'Implement discriminated union type guard', 'ts-discriminated-union-guard', 'medium', 'fe-curated',
    'Given a discriminated union type with a "type" field, implement a type guard function that narrows the union correctly. Then use it to safely access shape-specific properties.',
    '[{"input":"const shape: Shape = getShape(); if (isCircle(shape)) { shape.radius }","output":"TypeScript knows shape is Circle inside the if"},{"input":"isCircle({ type: \"square\", side: 5 })","output":"false"}]',
    array['Shape union: Circle (radius) | Square (side) | Triangle (base, height)','Type guard must use type predicates (param is Type)','Demonstrate usage with a calculateArea function'],
    array['Type guard signature: function isCircle(s: Shape): s is Circle { return s.type === "circle"; }','TypeScript narrows the type inside the if block.','calculateArea uses a switch on s.type or a series of type guards.'],
    'Discriminated union on "type" field. Type guards with "is" predicate. switch(shape.type) for exhaustive handling.',
    'O(1)', 'O(1)',
    array['typescript','type-guards','discriminated-union','frontend'], 'isCircle',
    'function isCircle(shape: Shape): shape is Circle { }', null::integer
  ),
  (
    'Explain TypeScript structural typing', 'ts-structural-typing', 'easy', 'fe-curated',
    'Explain structural typing vs nominal typing. Why does TypeScript use structural typing? Give an example where this matters and where it can surprise you.',
    '[{"input":"Interviewer: What is structural typing?","output":"Candidate explains duck typing, compatibility rules, and surprises like excess property checks"}]',
    array['This is a conceptual/verbal question','Cover: structural vs nominal, compatibility rules, excess property checks, brand types'],
    array['Structural: compatibility is based on shape, not name. If it has the required properties, it is compatible.','Contrast with nominal: Java/C# require explicit type names to match.','Surprise: object literal excess property checks — TypeScript warns, but once assigned to variable, the extra props are allowed.','Brand types: workaround to simulate nominal typing.'],
    'Duck typing by shape. Type compatibility = has required properties. Excess property checks on literals. Brand types for nominality.',
    'N/A — conceptual', 'N/A',
    array['typescript','type-system','conceptual','frontend'], null, null, null::integer
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;

-- ============================================================
-- Seed: Frontend — CSS questions (fe-curated)
-- ============================================================

insert into questions (
  title, slug, topic_id, difficulty, source,
  description, examples, constraints, hints,
  expected_approach, expected_time_complexity, expected_space_complexity,
  tags, entry_point, function_signature, leetcode_number
)
select
  q.title, q.slug,
  (select id from topics where slug = 'fe-css'),
  q.difficulty, q.source,
  q.description, q.examples::jsonb, q.constraints, q.hints,
  q.expected_approach, q.expected_tc, q.expected_sc,
  q.tags, q.entry_point, q.function_signature, q.lc_num
from (values
  (
    'CSS Box Model', 'css-box-model', 'easy', 'fe-curated',
    'Explain the CSS box model. What is the difference between content-box and border-box? If a div has width: 100px, padding: 10px, border: 2px, what is the actual rendered width in each box model?',
    '[{"input":"width: 100px, padding: 10px, border: 2px, box-sizing: content-box","output":"rendered width = 124px"},{"input":"same but box-sizing: border-box","output":"rendered width = 100px"}]',
    array['Discuss content, padding, border, margin','Explain box-sizing: content-box vs border-box','Give the formula for each'],
    array['content-box: total = width + 2*padding + 2*border.','border-box: total = width (padding and border are inside).','* { box-sizing: border-box } is a common global reset.'],
    'content-box: total = 100 + 20 + 4 = 124px. border-box: total = 100px (padding and border are included).',
    'N/A', 'N/A',
    array['css','box-model','conceptual','frontend'], null, null, null::integer
  ),
  (
    'CSS Flexbox layout', 'css-flexbox', 'easy', 'fe-curated',
    'Explain CSS Flexbox. What do justify-content, align-items, and flex-grow do? Implement a common pattern: horizontally and vertically center a div inside its parent.',
    '[{"input":"center a 200x200 div in a 100vh container","output":"display:flex; justify-content:center; align-items:center on parent"}]',
    array['Explain main axis vs cross axis','Discuss common properties: justify-content, align-items, flex-direction, flex-wrap, flex-grow','Show the centering solution'],
    array['display: flex turns on flex context.','justify-content controls main axis alignment; align-items controls cross axis.','For centering: display:flex + justify-content:center + align-items:center on parent.'],
    'display:flex on parent. justify-content:center (main axis). align-items:center (cross axis). No sizing needed on child.',
    'N/A', 'N/A',
    array['css','flexbox','layout','frontend'], null, null, null::integer
  ),
  (
    'CSS Specificity', 'css-specificity', 'medium', 'fe-curated',
    'Explain CSS specificity. How is specificity calculated? Given several conflicting CSS rules, which one wins? What does !important do and when should it be used?',
    '[{"input":"#id .class tag { color: red } vs .class.class { color: blue }","output":"#id rule wins (1-1-1 vs 0-2-0)"},{"input":"inline style vs #id rule","output":"inline style wins"}]',
    array['Cover the specificity calculation formula','Give examples of inline, ID, class, tag specificity','Discuss !important and when it breaks the cascade'],
    array['Specificity is (inline, ID, class/pseudo-class/attr, tag/pseudo-element) — e.g. (1,0,0,0) for inline.','Higher numbers in left positions win.','!important overrides everything (but is considered a code smell).','Equal specificity: last declared wins (cascade).'],
    'Specificity tuple: (inline, IDs, classes/pseudo-classes/attrs, tags). Compare left to right. !important overrides all.',
    'N/A', 'N/A',
    array['css','specificity','cascade','frontend'], null, null, null::integer
  ),
  (
    'Implement CSS sticky header', 'css-sticky-header', 'easy', 'fe-curated',
    'Implement a navigation header that sticks to the top of the viewport when the user scrolls past it. The header should have a shadow when sticky. Describe the CSS and any JS needed.',
    '[{"input":"page with long content","output":"header stays at top when scrolling"},{"input":"before scroll","output":"header is in normal document flow"}]',
    array['Use position: sticky if possible','Add visual feedback (shadow) when sticky','Note browser support considerations'],
    array['position: sticky + top: 0 on the header element.','It behaves like relative until the scroll threshold is hit, then sticks.','For the shadow: use IntersectionObserver on a sentinel div above the header to detect when it becomes sticky.'],
    'position:sticky + top:0. Shadow: IntersectionObserver on a 0-height sentinel div. When sentinel leaves viewport, add shadow class.',
    'N/A', 'N/A',
    array['css','layout','sticky','frontend'], null, null, null::integer
  ),
  (
    'Explain CSS BEM methodology', 'css-bem', 'easy', 'fe-curated',
    'Explain the BEM (Block, Element, Modifier) CSS naming methodology. Why is it used? Give an example of a card component with BEM naming for its title, image, and a featured variant.',
    '[{"input":"card component with featured variant","output":".card, .card__title, .card__image, .card--featured"}]',
    array['Explain Block, Element, Modifier naming','Show a real component example','Discuss tradeoffs vs CSS-in-JS or CSS Modules'],
    array['Block: standalone component (e.g. .card).','Element: part of block, uses __ (e.g. .card__title).','Modifier: variant, uses -- (e.g. .card--featured, .card__title--large).','Avoids specificity wars by keeping all selectors at class level.'],
    'Block: .card. Element: .card__title, .card__image. Modifier: .card--featured. All single-class selectors = equal specificity.',
    'N/A', 'N/A',
    array['css','bem','methodology','frontend'], null, null, null::integer
  )
) as q(title, slug, difficulty, source, description, examples, constraints, hints,
       expected_approach, expected_tc, expected_sc, tags, entry_point, function_signature, lc_num)
on conflict (slug) do nothing;
