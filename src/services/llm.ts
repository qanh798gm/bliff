import type { Message, LLMConfig } from '../types'

// ============================================================
// LLM Service — OpenAI-compatible API wrapper
// Supports streaming and non-streaming chat completions
// ============================================================

const config: LLMConfig = {
  baseUrl: import.meta.env.VITE_LLM_BASE_URL ?? 'https://api.openai.com/v1',
  apiKey: import.meta.env.VITE_LLM_API_KEY ?? '',
  model: import.meta.env.VITE_LLM_MODEL ?? 'gpt-4o',
}

// Filter out system messages for the API call — we inject system prompt separately
function toApiMessages(messages: Message[]): Array<{ role: string; content: string }> {
  return messages
    .filter((m) => m.role !== 'system')
    .map((m) => ({ role: m.role, content: m.content }))
}

// Non-streaming: returns full response text
export async function chatCompletion(
  systemPrompt: string,
  messages: Message[],
): Promise<string> {
  const response = await fetch(`${config.baseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${config.apiKey}`,
    },
    body: JSON.stringify({
      model: config.model,
      messages: [
        { role: 'system', content: systemPrompt },
        ...toApiMessages(messages),
      ],
      temperature: 0.7,
      max_tokens: 1024,
    }),
  })

  if (!response.ok) {
    const error = await response.text()
    throw new Error(`LLM API error ${response.status}: ${error}`)
  }

  const data = (await response.json()) as {
    choices: Array<{ message: { content: string } }>
  }

  return data.choices[0]?.message?.content ?? ''
}

// Streaming: calls onChunk with each text delta, returns full text when done
export async function streamChatCompletion(
  systemPrompt: string,
  messages: Message[],
  onChunk: (chunk: string) => void,
): Promise<string> {
  const response = await fetch(`${config.baseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${config.apiKey}`,
    },
    body: JSON.stringify({
      model: config.model,
      messages: [
        { role: 'system', content: systemPrompt },
        ...toApiMessages(messages),
      ],
      temperature: 0.7,
      max_tokens: 1024,
      stream: true,
    }),
  })

  if (!response.ok) {
    const error = await response.text()
    throw new Error(`LLM API error ${response.status}: ${error}`)
  }

  const reader = response.body?.getReader()
  const decoder = new TextDecoder()
  let fullText = ''

  if (!reader) throw new Error('No response body')

  while (true) {
    const { done, value } = await reader.read()
    if (done) break

    const chunk = decoder.decode(value, { stream: true })
    const lines = chunk.split('\n').filter((line) => line.trim() !== '')

    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data = line.slice(6)
        if (data === '[DONE]') break

        try {
          const parsed = JSON.parse(data) as {
            choices: Array<{ delta: { content?: string } }>
          }
          const delta = parsed.choices[0]?.delta?.content ?? ''
          if (delta) {
            fullText += delta
            onChunk(delta)
          }
        } catch {
          // Ignore malformed SSE lines
        }
      }
    }
  }

  return fullText
}
