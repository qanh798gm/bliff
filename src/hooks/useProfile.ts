import { useState, useEffect, useCallback } from 'react'
import {
  getProfile,
  updateProfile,
  updateStreak,
  getTopicStats,
  buildProfileSummary,
  type TopicStatsWithMeta,
} from '../services/profileService'
import type { UserProfileRow } from '../types/database'

interface UseProfileReturn {
  profile: UserProfileRow | null
  topicStats: TopicStatsWithMeta[]
  profileSummary: string
  loading: boolean
  error: string | null
  refresh: () => Promise<void>
  saveProfile: (updates: Partial<Omit<UserProfileRow, 'id' | 'created_at'>>) => Promise<void>
  markSessionComplete: () => Promise<void>
}

export function useProfile(): UseProfileReturn {
  const [profile, setProfile] = useState<UserProfileRow | null>(null)
  const [topicStats, setTopicStats] = useState<TopicStatsWithMeta[]>([])
  const [profileSummary, setProfileSummary] = useState<string>('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const load = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const [p, stats, summary] = await Promise.all([
        getProfile(),
        getTopicStats(),
        buildProfileSummary(),
      ])

      setProfile(p)
      setTopicStats(stats)
      setProfileSummary(summary)
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Failed to load profile'
      setError(msg)
      console.error('[useProfile] load error:', err)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    load()
  }, [load])

  const saveProfile = useCallback(
    async (updates: Partial<Omit<UserProfileRow, 'id' | 'created_at'>>) => {
      try {
        const updated = await updateProfile(updates)
        setProfile(updated)
        // Rebuild summary after profile change
        const summary = await buildProfileSummary()
        setProfileSummary(summary)
      } catch (err) {
        console.error('[useProfile] saveProfile error:', err)
        throw err
      }
    },
    []
  )

  const markSessionComplete = useCallback(async () => {
    try {
      await updateStreak()
      await load()
    } catch (err) {
      console.error('[useProfile] markSessionComplete error:', err)
    }
  }, [load])

  return {
    profile,
    topicStats,
    profileSummary,
    loading,
    error,
    refresh: load,
    saveProfile,
    markSessionComplete,
  }
}
