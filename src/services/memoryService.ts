import { supabase } from '../lib/supabase'
import type { UserMemoryRow } from '../types/database'
import type { UserMemory, MemoryWriteItem, MemoryType } from '../types'

// ============================================================
// memoryService — Phase 5: AI long-term memory
// Reads user_memory rows at session start (loadSessionMemory)
// Writes new memory rows at session end (upsertMemories)
// ============================================================

// Minimum confidence for a memory to be injected into the prompt
const MIN_CONFIDENCE_FOR_PROMPT = 0.5

// Maximum memories injected per session (keeps token cost bounded)
const MAX_MEMORIES_PER_SESSION = 8

// ── Row → domain type mapper ─────────────────────────────────

function rowToMemory(row: UserMemoryRow): UserMemory {
  return {
    id: row.id,
    memoryType: row.memory_type as MemoryType,
    topicId: row.topic_id,
    content: row.content,
    evidenceCount: row.evidence_count,
    confidence: row.confidence,
    sourceSessionId: row.source_session_id,
    validUntil: row.valid_until,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  }
}

// ── Load memories for session start ──────────────────────────
// Returns top memories relevant to current topic + global memories,
// filtered by confidence >= MIN_CONFIDENCE_FOR_PROMPT and not expired.
// topicId: null → only global memories loaded (e.g. Practice with no topic)

export async function loadSessionMemory(
  topicId: string | null
): Promise<UserMemory[]> {
  const now = new Date().toISOString()

  let query = supabase
    .from('user_memory')
    .select('*')
    .gte('confidence', MIN_CONFIDENCE_FOR_PROMPT)
    .or(`valid_until.is.null,valid_until.gt.${now}`)
    .order('confidence', { ascending: false })
    .order('updated_at', { ascending: false })
    .limit(MAX_MEMORIES_PER_SESSION)

  // If we have a topic, load both topic-specific AND global memories
  // If no topic, load only global memories (topic_id IS NULL)
  if (topicId) {
    query = query.or(`topic_id.eq.${topicId},topic_id.is.null`)
  } else {
    query = query.is('topic_id', null)
  }

  const { data, error } = await query

  if (error) {
    console.error('[memoryService] loadSessionMemory error:', error)
    return []
  }

  return (data as UserMemoryRow[]).map(rowToMemory)
}

// ── Resolve topic slug → topic id ────────────────────────────
// Memory write items from the LLM contain topic_slug (string).
// We need to resolve that to a UUID before inserting.

async function resolveTopicSlug(slug: string | null): Promise<string | null> {
  if (!slug) return null
  const { data, error } = await supabase
    .from('topics')
    .select('id')
    .eq('slug', slug)
    .single()
  if (error || !data) return null
  return (data as { id: string }).id
}

// ── Upsert memories written by the LLM at session end ────────
// items: parsed from <memory_json> block in LLM feedback response
// sessionId: the session that generated these memories
//
// Strategy: for each item, check if a similar memory (same type + topic)
// already exists. If yes, increment evidence_count and update confidence.
// If no, insert a new row.

export async function upsertMemories(
  sessionId: string,
  items: MemoryWriteItem[]
): Promise<void> {
  if (!items.length) return

  for (const item of items) {
    try {
      const topicId = await resolveTopicSlug(item.topic_slug)

      // Look for an existing memory of the same type + topic to merge into
      const { data: existing } = await supabase
        .from('user_memory')
        .select('id, evidence_count, confidence')
        .eq('memory_type', item.memory_type)
        .eq('topic_id', topicId ?? null)  // handles null via supabase filter
        .limit(1)
        .maybeSingle()

      if (existing) {
        // Merge: increment evidence, nudge confidence upward (capped at 1.0)
        const newEvidence = (existing as UserMemoryRow).evidence_count + 1
        const newConfidence = Math.min(
          1.0,
          // Weight: new confidence is average of existing + new, biased toward existing
          (existing as UserMemoryRow).confidence * 0.6 + item.confidence * 0.4
        )
        await supabase
          .from('user_memory')
          .update({
            content: item.content,          // replace with latest phrasing
            evidence_count: newEvidence,
            confidence: newConfidence,
            source_session_id: sessionId,
            // Reset valid_until for weekly_summary to +30 days
            ...(item.memory_type === 'weekly_summary'
              ? { valid_until: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString() }
              : {}),
          })
          .eq('id', (existing as UserMemoryRow).id)
      } else {
        // Insert new memory row
        await supabase.from('user_memory').insert({
          memory_type: item.memory_type,
          topic_id: topicId,
          content: item.content,
          evidence_count: 1,
          confidence: item.confidence,
          source_session_id: sessionId,
          valid_until:
            item.memory_type === 'weekly_summary'
              ? new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
              : null,
        })
      }
    } catch (err) {
      console.error('[memoryService] upsertMemories item error:', err, item)
      // Continue — don't let one bad item block the rest
    }
  }
}

// ── Expire stale weekly summaries ─────────────────────────────
// Called at session start to clean up rows past their valid_until.
// This is a soft cleanup — expired rows are excluded from loads via
// the valid_until filter, but this removes them from the DB entirely.

export async function expireOldSummaries(): Promise<void> {
  const now = new Date().toISOString()
  const { error } = await supabase
    .from('user_memory')
    .delete()
    .eq('memory_type', 'weekly_summary')
    .lt('valid_until', now)

  if (error) {
    console.error('[memoryService] expireOldSummaries error:', error)
  }
}

// ── Save session context snapshot ────────────────────────────
// Called at session start after context is assembled.
// Stores what the AI knew when this session began (for audit/replay).

export async function saveSessionContext(
  sessionId: string,
  context: {
    profile_snapshot: object
    topic_mastery: object | null
    memories_loaded: number
    solutions_loaded: number
  }
): Promise<void> {
  const { error } = await supabase
    .from('sessions')
    .update({
      session_context: {
        ...context,
        context_assembled_at: new Date().toISOString(),
      },
    })
    .eq('id', sessionId)

  if (error) {
    console.error('[memoryService] saveSessionContext error:', error)
  }
}

// ── Save conversation summary ─────────────────────────────────
// Called by trimConversation() when older messages are summarized.

export async function saveConversationSummary(
  sessionId: string,
  summary: string
): Promise<void> {
  const { error } = await supabase
    .from('sessions')
    .update({ conversation_summary: summary })
    .eq('id', sessionId)

  if (error) {
    console.error('[memoryService] saveConversationSummary error:', error)
  }
}
