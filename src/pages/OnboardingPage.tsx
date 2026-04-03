import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import { saveProfile } from '../services/profileService'
import type { ExperienceLevel, InterviewFocus } from '../types'

// ============================================================
// OnboardingPage — multi-step profile setup wizard
// Steps: 1. Name  2. Experience  3. Focus  4. Goals
// ============================================================

const EXPERIENCE_OPTIONS: { value: ExperienceLevel; label: string; description: string }[] = [
  { value: 'junior', label: 'Junior (0–2 yrs)', description: 'Learning fundamentals, building first projects' },
  { value: 'mid', label: 'Mid-level (2–5 yrs)', description: 'Solid experience, aiming for stronger companies' },
  { value: 'senior', label: 'Senior (5+ yrs)', description: 'Deep expertise, targeting staff / principal roles' },
]

const FOCUS_OPTIONS: { value: InterviewFocus; label: string; icon: string }[] = [
  { value: 'dsa', label: 'Data Structures & Algorithms', icon: '🧩' },
  { value: 'frontend', label: 'Frontend Engineering', icon: '🖥️' },
  { value: 'both', label: 'Both DSA & Frontend', icon: '⚡' },
]

const TARGET_COMPANIES = [
  'Google', 'Meta', 'Apple', 'Amazon', 'Microsoft', 'Netflix',
  'Stripe', 'Airbnb', 'Uber', 'LinkedIn', 'Shopify', 'Figma',
]

const TOTAL_STEPS = 4

export function OnboardingPage() {
  const { user } = useAuth()
  const navigate = useNavigate()
  const [step, setStep] = useState(1)
  const [isSaving, setIsSaving] = useState(false)
  const [error, setError] = useState('')

  // Form state
  const [displayName, setDisplayName] = useState('')
  const [experience, setExperience] = useState<ExperienceLevel>('mid')
  const [focus, setFocus] = useState<InterviewFocus>('dsa')
  const [selectedCompanies, setSelectedCompanies] = useState<string[]>([])
  const [weeklyGoal, setWeeklyGoal] = useState(3)

  const toggleCompany = (c: string) =>
    setSelectedCompanies(prev =>
      prev.includes(c) ? prev.filter(x => x !== c) : [...prev, c]
    )

  const handleFinish = async () => {
    if (!user) return
    setIsSaving(true)
    setError('')
    try {
      await saveProfile(user.id, {
        display_name: (displayName.trim() || user.email?.split('@')[0]) ?? 'Candidate',
        experience_level: experience,
        interview_focus: focus,
        target_companies: selectedCompanies,
        weekly_goal: weeklyGoal,
        onboarding_completed: true,
      })
      navigate('/dashboard')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to save profile')
      setIsSaving(false)
    }
  }

  const canContinue = step === 1 ? true : true // all steps are optional except saving

  return (
    <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
      <div className="w-full max-w-lg">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-white">
            bli<span className="text-indigo-400">ff</span>
          </h1>
          <p className="mt-1 text-gray-400 text-sm">Let's set up your profile</p>
        </div>

        {/* Progress bar */}
        <div className="flex gap-1.5 mb-6">
          {Array.from({ length: TOTAL_STEPS }).map((_, i) => (
            <div
              key={i}
              className={`h-1 flex-1 rounded-full transition-colors ${
                i < step ? 'bg-indigo-500' : 'bg-gray-800'
              }`}
            />
          ))}
        </div>

        <div className="bg-gray-900 border border-gray-800 rounded-2xl p-8 shadow-xl min-h-[340px] flex flex-col">
          {/* Step 1 — Name */}
          {step === 1 && (
            <div className="flex-1">
              <h2 className="text-white font-semibold text-xl mb-1">What should we call you?</h2>
              <p className="text-gray-400 text-sm mb-6">Your name appears in session feedback and reports.</p>
              <input
                type="text"
                value={displayName}
                onChange={e => setDisplayName(e.target.value)}
                placeholder={user?.email?.split('@')[0] ?? 'Your name'}
                autoFocus
                className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2.5 text-white placeholder-gray-500 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
              />
            </div>
          )}

          {/* Step 2 — Experience */}
          {step === 2 && (
            <div className="flex-1">
              <h2 className="text-white font-semibold text-xl mb-1">What's your experience level?</h2>
              <p className="text-gray-400 text-sm mb-6">We'll calibrate question difficulty and feedback accordingly.</p>
              <div className="space-y-3">
                {EXPERIENCE_OPTIONS.map(opt => (
                  <button
                    key={opt.value}
                    onClick={() => setExperience(opt.value)}
                    className={`w-full text-left px-4 py-3 rounded-lg border transition-colors ${
                      experience === opt.value
                        ? 'border-indigo-500 bg-indigo-950/50 text-white'
                        : 'border-gray-700 bg-gray-800/50 text-gray-300 hover:border-gray-600'
                    }`}
                  >
                    <div className="font-medium text-sm">{opt.label}</div>
                    <div className="text-xs text-gray-500 mt-0.5">{opt.description}</div>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Step 3 — Interview focus */}
          {step === 3 && (
            <div className="flex-1">
              <h2 className="text-white font-semibold text-xl mb-1">What are you focusing on?</h2>
              <p className="text-gray-400 text-sm mb-6">We'll prioritize question topics and adaptive selection accordingly.</p>
              <div className="space-y-3">
                {FOCUS_OPTIONS.map(opt => (
                  <button
                    key={opt.value}
                    onClick={() => setFocus(opt.value)}
                    className={`w-full text-left px-4 py-3 rounded-lg border transition-colors flex items-center gap-3 ${
                      focus === opt.value
                        ? 'border-indigo-500 bg-indigo-950/50 text-white'
                        : 'border-gray-700 bg-gray-800/50 text-gray-300 hover:border-gray-600'
                    }`}
                  >
                    <span className="text-xl">{opt.icon}</span>
                    <span className="font-medium text-sm">{opt.label}</span>
                  </button>
                ))}
              </div>
            </div>
          )}

          {/* Step 4 — Goals */}
          {step === 4 && (
            <div className="flex-1">
              <h2 className="text-white font-semibold text-xl mb-1">Set your goals</h2>
              <p className="text-gray-400 text-sm mb-5">Optional — helps us track your progress.</p>

              {/* Weekly goal */}
              <div className="mb-5">
                <label className="block text-sm text-gray-400 mb-2">
                  Weekly practice sessions: <span className="text-white font-medium">{weeklyGoal}</span>
                </label>
                <input
                  type="range"
                  min={1}
                  max={7}
                  value={weeklyGoal}
                  onChange={e => setWeeklyGoal(Number(e.target.value))}
                  className="w-full accent-indigo-500"
                />
                <div className="flex justify-between text-xs text-gray-600 mt-1">
                  <span>1×/wk</span><span>7×/wk</span>
                </div>
              </div>

              {/* Target companies */}
              <div>
                <label className="block text-sm text-gray-400 mb-2">Target companies (optional)</label>
                <div className="flex flex-wrap gap-2">
                  {TARGET_COMPANIES.map(c => (
                    <button
                      key={c}
                      onClick={() => toggleCompany(c)}
                      className={`px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
                        selectedCompanies.includes(c)
                          ? 'border-indigo-500 bg-indigo-950/50 text-indigo-300'
                          : 'border-gray-700 bg-gray-800/50 text-gray-400 hover:border-gray-600'
                      }`}
                    >
                      {c}
                    </button>
                  ))}
                </div>
              </div>

              {error && <p className="mt-4 text-red-400 text-sm">{error}</p>}
            </div>
          )}

          {/* Navigation */}
          <div className="flex justify-between items-center mt-8">
            <button
              onClick={() => step > 1 ? setStep(s => s - 1) : undefined}
              className={`text-sm text-gray-500 hover:text-gray-300 transition-colors ${step === 1 ? 'invisible' : ''}`}
            >
              ← Back
            </button>

            {step < TOTAL_STEPS ? (
              <button
                onClick={() => setStep(s => s + 1)}
                disabled={!canContinue}
                className="px-6 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-50 text-white text-sm font-medium rounded-lg transition-colors"
              >
                Continue →
              </button>
            ) : (
              <button
                onClick={handleFinish}
                disabled={isSaving}
                className="px-6 py-2 bg-indigo-600 hover:bg-indigo-500 disabled:opacity-60 text-white text-sm font-medium rounded-lg transition-colors"
              >
                {isSaving ? 'Saving…' : 'Start practising 🚀'}
              </button>
            )}
          </div>
        </div>

        <p className="text-center text-xs text-gray-700 mt-4">
          Step {step} of {TOTAL_STEPS}
        </p>
      </div>
    </div>
  )
}
