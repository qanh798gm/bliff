import type { TestCase, TestResult } from '../types'

// ============================================================
// Code Runner — executes JavaScript in a browser sandbox
// Uses Web Worker for isolation and TLE protection
// ============================================================

const TIMEOUT_MS = 3000

/**
 * Run user code against all test cases.
 * Executes in a Web Worker to prevent UI freezing and enforce TLE.
 */
export async function runTests(
  userCode: string,
  testCases: TestCase[],
  entryPoint: string,
): Promise<TestResult[]> {
  const results: TestResult[] = []

  for (const tc of testCases) {
    const result = await runSingleTest(userCode, tc, entryPoint)
    results.push(result)
  }

  return results
}

function runSingleTest(
  userCode: string,
  tc: TestCase,
  entryPoint: string,
): Promise<TestResult> {
  return new Promise((resolve) => {
    const workerCode = buildWorkerCode(userCode, tc, entryPoint)
    const blob = new Blob([workerCode], { type: 'application/javascript' })
    const workerUrl = URL.createObjectURL(blob)
    const worker = new Worker(workerUrl)
    const start = performance.now()

    const timeout = setTimeout(() => {
      worker.terminate()
      URL.revokeObjectURL(workerUrl)
      resolve({
        id: tc.id,
        passed: false,
        description: tc.description,
        input: tc.input,
        expected: tc.expected,
        actual: undefined,
        error: `Time Limit Exceeded (>${TIMEOUT_MS}ms)`,
        durationMs: TIMEOUT_MS,
      })
    }, TIMEOUT_MS)

    worker.onmessage = (e: MessageEvent<{ actual: unknown; error?: string }>) => {
      clearTimeout(timeout)
      worker.terminate()
      URL.revokeObjectURL(workerUrl)

      const durationMs = performance.now() - start
      const { actual, error } = e.data

      if (error) {
        resolve({
          id: tc.id,
          passed: false,
          description: tc.description,
          input: tc.input,
          expected: tc.expected,
          actual: undefined,
          error,
          durationMs,
        })
      } else {
        const passed = deepEqual(actual, tc.expected)
        resolve({
          id: tc.id,
          passed,
          description: tc.description,
          input: tc.input,
          expected: tc.expected,
          actual,
          durationMs,
        })
      }
    }

    worker.onerror = (e) => {
      clearTimeout(timeout)
      worker.terminate()
      URL.revokeObjectURL(workerUrl)
      resolve({
        id: tc.id,
        passed: false,
        description: tc.description,
        input: tc.input,
        expected: tc.expected,
        actual: undefined,
        error: e.message,
        durationMs: performance.now() - start,
      })
    }
  })
}

function buildWorkerCode(userCode: string, tc: TestCase, entryPoint: string): string {
  const inputValues = JSON.stringify(Object.values(tc.input))

  return `
self.onmessage = function() {
  try {
    ${userCode}
    
    const args = ${inputValues};
    const result = ${entryPoint}(...args);
    self.postMessage({ actual: result });
  } catch (err) {
    self.postMessage({ actual: undefined, error: err.message || String(err) });
  }
};

// Trigger immediately
self.dispatchEvent(new MessageEvent('message'));
`
}

// Deep equality check for test results (handles arrays, objects, primitives)
function deepEqual(a: unknown, b: unknown): boolean {
  if (a === b) return true
  if (a === null || b === null) return a === b
  if (typeof a !== typeof b) return false

  if (Array.isArray(a) && Array.isArray(b)) {
    if (a.length !== b.length) return false
    // For Two Sum style problems, sort both arrays before comparing
    const sortedA = [...a].sort((x, y) => Number(x) - Number(y))
    const sortedB = [...b].sort((x, y) => Number(x) - Number(y))
    return sortedA.every((val, i) => deepEqual(val, sortedB[i]))
  }

  if (typeof a === 'object' && typeof b === 'object') {
    const keysA = Object.keys(a as object)
    const keysB = Object.keys(b as object)
    if (keysA.length !== keysB.length) return false
    return keysA.every((key) =>
      deepEqual((a as Record<string, unknown>)[key], (b as Record<string, unknown>)[key]),
    )
  }

  return false
}

// Format test results summary for sending to AI
export function formatResultsForAI(results: TestResult[]): string {
  const passed = results.filter((r) => r.passed).length
  const total = results.length
  const lines = [`Test Results: ${passed}/${total} passed`, '']

  for (const r of results) {
    const status = r.passed ? '✅ PASSED' : '❌ FAILED'
    lines.push(`${status} — ${r.description} (${r.durationMs.toFixed(1)}ms)`)
    lines.push(`  Input: ${JSON.stringify(r.input)}`)
    lines.push(`  Expected: ${JSON.stringify(r.expected)}`)
    if (!r.passed) {
      lines.push(`  Got: ${r.error ?? JSON.stringify(r.actual)}`)
    }
    lines.push('')
  }

  return lines.join('\n')
}
