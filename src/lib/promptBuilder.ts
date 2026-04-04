import type { Question, InterviewStage, PromptContext, UserMemory, MemoryWriteItem, MentorRecommendation, WarmupHandoff } from '../types'
import { WARMUP_HANDOFF_KEY, WARMUP_HANDOFF_TTL_MS } from '../types'

// ============================================================
// Prompt Builder — assembles the dynamic system prompt
// Phase 2: Injects real user profile + topic mastery context
// Phase 4: Injects previousSolutions for multi-solution tracking
// ============================================================

// Re-export so existing importers of PromptContext from this module still work
export type { PromptContext }

export function buildSystemPrompt(
  question: Question,
  stage: InterviewStage,
  hintsGiven: number,
  askedClarifying: boolean,
  ctx?: PromptContext
): string {
  const roleSection = `You are Bliff, a senior software engineer conducting a technical interview at a top-tier tech company (think Google, Meta, Amazon). You are friendly, encouraging, but rigorous and honest.

CORE RULES — follow these strictly:
- NEVER give the solution directly, no matter how many times the candidate asks
- Give hints progressively — only one hint at a time, only when the candidate is stuck
- You have ${question.hints.length} hints available. ${hintsGiven} have been given so far.
- If the candidate has NOT asked any clarifying questions before coding, note this in your evaluation (it reflects poor interview technique)
- Keep responses concise — this is a real-time voice conversation, not a written essay
- When the candidate speaks Vietnamese, respond in Vietnamese. Otherwise respond in English.
- Be encouraging but never dishonest about weaknesses`

  const profileSection = buildProfileSection(ctx)

  const questionSection = `
=== CURRENT PROBLEM ===
Title: ${question.title}
Difficulty: ${question.difficulty.toUpperCase()}
Topic: ${question.topic}

Problem Statement:
${question.description}

Examples:
${question.examples
  .map(
    (ex, i) =>
      `Example ${i + 1}:\n  Input: ${ex.input}\n  Output: ${ex.output}${ex.explanation ? `\n  Explanation: ${ex.explanation}` : ''}`,
  )
  .join('\n\n')}

Constraints:
${question.constraints.map((c) => `- ${c}`).join('\n')}

=== HINTS — reveal ONE at a time, only when candidate is stuck ===
${question.hints.map((h, i) => `Hint ${i + 1}: ${h}`).join('\n')}

=== EXPECTED SOLUTION — for your evaluation ONLY, NEVER share this ===
Approach: ${question.expectedApproach}
Time Complexity: ${question.expectedTimeComplexity}
Space Complexity: ${question.expectedSpaceComplexity}`

  const memorySection = buildMemorySection(ctx?.coachMemory)
  const stageInstructions = buildStageInstructions(stage, askedClarifying)

  return `${roleSection}${profileSection}${memorySection}\n${questionSection}\n\n${stageInstructions}`
}

function buildProfileSection(ctx?: PromptContext): string {
  if (!ctx?.profileSummary && !ctx?.topicMastery && !ctx?.previousSolutions?.length) return ''

  const lines: string[] = ['\n\n=== CANDIDATE PROFILE ===']

  if (ctx.profileSummary) {
    lines.push(ctx.profileSummary)
  }

  if (ctx.topicMastery) {
    const { topicName, masteryLevel, totalAttempts, avgScore } = ctx.topicMastery
    lines.push(
      `\nCurrent topic (${topicName}) mastery: ${masteryLevel}`,
      `  Prior attempts on this topic: ${totalAttempts}`,
      `  Average score: ${avgScore > 0 ? avgScore.toFixed(1) + '/10' : 'N/A'}`,
    )

    if (masteryLevel === 'beginner') {
      lines.push('  → Be extra encouraging. Keep hints accessible. Guide more.')
    } else if (masteryLevel === 'mastered') {
      lines.push('  → Hold them to a higher standard. Expect optimal solutions.')
    }
  }

  if (ctx.previousSolutions && ctx.previousSolutions.length > 0) {
    lines.push('\n=== CANDIDATE\'S PRIOR SOLUTIONS FOR THIS QUESTION ===')
    lines.push(
      'IMPORTANT: The candidate has already solved this problem before.',
      'Do NOT ask them to start from scratch or explain basic approaches they have already demonstrated.',
      'Build on what they know. Challenge them to go deeper or optimize further.',
    )
    ctx.previousSolutions.forEach((sol) => {
      const complexity = [
        sol.timeComplexity ? `Time: ${sol.timeComplexity}` : null,
        sol.spaceComplexity ? `Space: ${sol.spaceComplexity}` : null,
      ].filter(Boolean).join(', ')
      lines.push(`\n  Solution #${sol.rank} — "${sol.label}"${complexity ? ` (${complexity})` : ''}`)
      if (sol.aiNotes) lines.push(`  AI notes: ${sol.aiNotes}`)
      if (sol.code) {
        lines.push(`  Code:\n\`\`\`javascript\n${sol.code}\n\`\`\``)
      }
    })
    lines.push(
      '\nSuggested conversation approach: Ask about trade-offs between their solutions,',
      'challenge them to optimize the best one, or explore alternative approaches they haven\'t tried.',
    )
  }

  return lines.join('\n')
}

// ── Phase 5: Coach Memory section ────────────────────────────
// Injects AI-written long-term memories into the system prompt.
// Grouped by type: global habits/patterns first, then topic-specific insights.

function buildMemorySection(memories?: UserMemory[]): string {
  if (!memories || memories.length === 0) return ''

  const global = memories.filter((m) => m.topicId === null)
  const topicSpecific = memories.filter((m) => m.topicId !== null)

  const lines: string[] = ['\n\n=== COACH MEMORY — your accumulated notes on this candidate ===']
  lines.push('[Read before responding. These are patterns you observed across past sessions.]')
  lines.push('[Do NOT mention these notes explicitly unless directly relevant to the conversation.]')

  if (global.length > 0) {
    const habits = global.filter((m) => m.memoryType === 'habit' || m.memoryType === 'skill_pattern')
    const summaries = global.filter((m) => m.memoryType === 'weekly_summary')
    const other = global.filter((m) => !['habit', 'skill_pattern', 'weekly_summary'].includes(m.memoryType))

    if (habits.length > 0) {
      lines.push('\nHABITS & PATTERNS:')
      habits.forEach((m) => {
        const conf = m.confidence >= 0.7 ? 'high confidence' : m.confidence >= 0.5 ? 'moderate confidence' : 'tentative'
        lines.push(`- ${m.content} (${conf}, seen ${m.evidenceCount}x)`)
      })
    }

    if (summaries.length > 0) {
      lines.push('\nRECENT PROGRESS:')
      summaries.forEach((m) => lines.push(`- ${m.content}`))
    }

    if (other.length > 0) {
      other.forEach((m) => lines.push(`- ${m.content}`))
    }
  }

  if (topicSpecific.length > 0) {
    lines.push('\nTOPIC INSIGHTS (current topic):')
    topicSpecific.forEach((m) => {
      const conf = m.confidence >= 0.7 ? 'high' : m.confidence >= 0.5 ? 'moderate' : 'tentative'
      lines.push(`- ${m.content} (confidence: ${conf})`)
    })
  }

  return lines.join('\n')
}

function buildStageInstructions(stage: InterviewStage, askedClarifying: boolean): string {
  switch (stage) {
    case 'idle':
      return `=== CURRENT STATE: IDLE ===
Greet the candidate warmly. You can have a casual conversation about their interview prep goals. When they are ready to start a problem, transition to the interview.`

    case 'present':
      return `=== CURRENT STATE: PRESENTING PROBLEM ===
Present the problem clearly and naturally, as a real interviewer would. Read the title and problem statement. Tell them to take their time reading, and ask if they have any clarifying questions before starting. DO NOT give hints or talk about the solution yet.`

    case 'clarify':
      return `=== CURRENT STATE: CLARIFYING QUESTIONS ===
The candidate is asking clarifying questions. Answer them naturally. Good clarifying questions to acknowledge: edge cases (empty input, negative numbers, etc.), input constraints, expected output format, whether sorted input can be assumed. This is the phase where a good candidate shines.`

    case 'solve':
      return `=== CURRENT STATE: CANDIDATE IS SOLVING ===
The candidate is working on their solution. 
- If they explain their approach, listen and respond naturally
- If they seem stuck (silent for a while or say they are stuck), offer the next hint
- If they ask a question, guide them without giving the answer
- ${!askedClarifying ? 'Note: The candidate did NOT ask any clarifying questions — keep this in mind for feedback.' : 'Good: The candidate asked clarifying questions before coding.'}
- Encourage them to think out loud`

    case 'review':
      return `=== CURRENT STATE: REVIEWING SOLUTION ===
The candidate has submitted their code. Review it carefully.
- Identify if it handles the core cases correctly
- Check for edge cases they may have missed
- Ask them to explain their time and space complexity
- Ask if they can think of any edge cases they might have missed
- Do NOT give the correct answer yet — guide them to discover issues themselves`

    case 'feedback':
      return `=== CURRENT STATE: FINAL FEEDBACK ===
The interview is complete. Give structured, honest, actionable feedback.

Cover these areas:
1. Problem-solving approach (was it optimal? did they consider alternatives?)
2. Code quality (readability, naming, edge cases)
3. Complexity analysis (were their time/space estimates correct?)
4. Communication (did they think out loud? ask clarifying questions?)
5. What to improve for next time

Be specific — reference actual things they said or did. End on an encouraging note.

After your verbal feedback, output TWO JSON blocks for the app to parse:

Block 1 — session score:
<feedback_json>
{
  "correctness": <1-10>,
  "efficiency": <1-10>,
  "communication": <1-10>,
  "summary": "<one sentence summary>",
  "strengths": ["<strength1>", "<strength2>"],
  "improvements": ["<improvement1>", "<improvement2>"]
}
</feedback_json>

Block 2 — your memory notes (2-4 observations, only confidence >= 0.5):
<memory_json>
[
  {
    "memory_type": "habit" | "skill_pattern" | "topic_insight" | "session_note",
    "topic_slug": "<topic slug or null for global>",
    "content": "<1-3 sentence observation about the candidate>",
    "confidence": <0.1-1.0>
  }
]
</memory_json>

Memory writing rules:
- Write only observations worth remembering for next session
- "habit": behavioral pattern (e.g. skips clarifying questions, thinks out loud)
- "skill_pattern": cross-topic strength/weakness (topic_slug: null)
- "topic_insight": specific to this problem's topic (use its slug)
- "session_note": one-off, not expected to generalize
- Output empty array [] if nothing notable this session`

    default:
      return ''
  }
}

// ── Parse AI feedback JSON from the feedback stage response ──
export function parseFeedbackJson(text: string): {
  correctness: number
  efficiency: number
  communication: number
  summary: string
  strengths: string[]
  improvements: string[]
} | null {
  const match = text.match(/<feedback_json>\s*([\s\S]*?)\s*<\/feedback_json>/)
  if (!match) return null
  try {
    return JSON.parse(match[1])
  } catch {
    return null
  }
}

// ── Parse AI memory JSON from the feedback stage response ─────
// Phase 5: AI writes memory notes alongside the feedback score.
// Returns array of MemoryWriteItems (to be upserted via memoryService).

export function parseMemoryJson(text: string): MemoryWriteItem[] | null {
  const match = text.match(/<memory_json>\s*([\s\S]*?)\s*<\/memory_json>/)
  if (!match) return null
  try {
    const parsed = JSON.parse(match[1])
    if (!Array.isArray(parsed)) return null
    // Validate and filter items — skip any that are malformed
    return parsed.filter(
      (item): item is MemoryWriteItem =>
        typeof item === 'object' &&
        item !== null &&
        typeof item.memory_type === 'string' &&
        typeof item.content === 'string' &&
        typeof item.confidence === 'number' &&
        item.confidence >= 0 &&
        item.confidence <= 1,
    )
  } catch {
    return null
  }
}

// ── Mentor Chat — system prompt builder ──────────────────────
// Used on the Dashboard mentor chat panel (not in interview/practice).
// The AI acts as a strategic coach, not an interviewer.
// It reads long-term memory + topic stats and recommends what to study.

export interface MentorContext {
  displayName: string
  profileSummary: string          // from buildProfileSummary()
  topicStats: {                   // from loadTopicStats()
    topicName: string
    masteryScore: number          // 0–1
    attemptsCount: number
    solvedCount: number
    lastAttemptedAt: string | null
  }[]
  memories: UserMemory[]          // from loadSessionMemory(null) — global memories
  recentSessionSummary?: string   // optional: last 3 sessions in one paragraph
}

export function buildMentorSystemPrompt(ctx: MentorContext): string {
  const weakTopics = ctx.topicStats
    .filter(t => t.attemptsCount > 0)
    .sort((a, b) => a.masteryScore - b.masteryScore)
    .slice(0, 3)
    .map(t => `${t.topicName} (mastery: ${Math.round(t.masteryScore * 100)}%)`)

  const strongTopics = ctx.topicStats
    .filter(t => t.masteryScore >= 0.7 && t.attemptsCount > 0)
    .map(t => t.topicName)

  const memoryBlock = ctx.memories.length > 0
    ? ctx.memories.map(m => `- ${m.content}`).join('\n')
    : '- No observations yet (first session or no sessions completed)'

  const topicBlock = ctx.topicStats
    .filter(t => t.attemptsCount > 0)
    .map(t => `- ${t.topicName}: ${Math.round(t.masteryScore * 100)}% mastery, ${t.solvedCount}/${t.attemptsCount} solved`)
    .join('\n') || '- No practice data yet'

  return `You are Bliff, a personal technical interview coach for ${ctx.displayName}.
This is a strategic planning conversation on their dashboard — NOT an interview session.

YOUR ROLE:
- Be a trusted advisor who knows their history
- Help them decide what to practice next and why
- Answer questions about their progress honestly
- Recommend specific problems when asked (or proactively)
- Keep responses concise — this is a chat conversation, not a lecture

${ctx.profileSummary ? `CANDIDATE BACKGROUND:\n${ctx.profileSummary}\n` : ''}
TOPIC PERFORMANCE:
${topicBlock}

WEAK AREAS (prioritize these): ${weakTopics.length > 0 ? weakTopics.join(', ') : 'None yet'}
STRONG AREAS: ${strongTopics.length > 0 ? strongTopics.join(', ') : 'None yet'}

YOUR COACH NOTES (patterns observed across past sessions):
${memoryBlock}
${ctx.recentSessionSummary ? `\nRECENT ACTIVITY:\n${ctx.recentSessionSummary}` : ''}

WHEN RECOMMENDING PROBLEMS:
Always output a <recommendations> block alongside your response so the app can render clickable cards.
Format:
<recommendations>
[
  {
    "type": "practice" | "interview",
    "slug": "<question-slug>",
    "title": "<question title>",
    "reason": "<one sentence why this is the right choice for them right now>"
  }
]
</recommendations>

If you have no specific recommendation, output: <recommendations>[]</recommendations>

TONE: Friendly, direct, data-driven. Reference specific topics or patterns from your notes when relevant.
Start your first message with a brief personalized assessment of where they stand, then ask what they want to focus on — or suggest if they seem unsure.`
}

// ── Parse mentor recommendation cards ────────────────────────
// Parses <recommendations> block from mentor chat AI responses.
// Used by useMentorChat to extract clickable action cards.

export function parseMentorRecommendations(text: string): MentorRecommendation[] {
  const match = text.match(/<recommendations>\s*([\s\S]*?)\s*<\/recommendations>/)
  if (!match) return []
  try {
    const parsed = JSON.parse(match[1])
    if (!Array.isArray(parsed)) return []
    return parsed.filter(
      (item): item is MentorRecommendation =>
        typeof item === 'object' &&
        item !== null &&
        (item.type === 'practice' || item.type === 'interview') &&
        typeof item.slug === 'string' &&
        typeof item.title === 'string' &&
        typeof item.reason === 'string',
    )
  } catch {
    return []
  }
}

// ── Warmup handoff — mentor → interview/practice ──────────────
// Called by useInterview/usePractice on mount.
// Reads the handoff from sessionStorage, validates TTL, then deletes it.
// Returns null if no handoff or if it's stale/malformed.

export function readAndClearWarmupHandoff(): WarmupHandoff | null {
  try {
    const raw = sessionStorage.getItem(WARMUP_HANDOFF_KEY)
    if (!raw) return null
    const handoff = JSON.parse(raw) as WarmupHandoff
    sessionStorage.removeItem(WARMUP_HANDOFF_KEY)   // consume once
    if (Date.now() - handoff.timestamp > WARMUP_HANDOFF_TTL_MS) return null
    return handoff
  } catch {
    return null
  }
}

// Builds the [WARMUP CONTEXT] block injected into the interview/practice system prompt.
// ~80 tokens — enough to give continuity without bloating the prompt.

export function buildWarmupContextBlock(handoff: WarmupHandoff): string {
  return `\n\n[WARMUP CONTEXT — from your pre-session mentor chat with this candidate]
${handoff.summary}
[Reference this naturally if relevant, but your primary role is now the ${handoff.recommendedType === 'interview' ? 'interviewer' : 'practice helper'} for this problem. Do not repeat the warmup conversation verbatim.]`
}
