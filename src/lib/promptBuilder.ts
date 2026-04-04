import type { Question, InterviewStage, PromptContext } from '../types'

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

  const stageInstructions = buildStageInstructions(stage, askedClarifying)

  return `${roleSection}${profileSection}\n${questionSection}\n\n${stageInstructions}`
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

After your verbal feedback, output a JSON block (for the app to parse) in this exact format:
<feedback_json>
{
  "correctness": <1-10>,
  "efficiency": <1-10>,
  "communication": <1-10>,
  "summary": "<one sentence summary>",
  "strengths": ["<strength1>", "<strength2>"],
  "improvements": ["<improvement1>", "<improvement2>"]
}
</feedback_json>`

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
