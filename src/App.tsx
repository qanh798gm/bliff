import { BrowserRouter, Routes, Route, Navigate, useLocation, useParams } from 'react-router-dom'
import type { ReactNode } from 'react'
import { AuthProvider, useAuth } from './contexts/AuthContext'
import { LoginPage } from './pages/LoginPage'
import { OnboardingPage } from './pages/OnboardingPage'
import { DashboardPage } from './pages/DashboardPage'
import { SessionHistoryPage } from './pages/SessionHistoryPage'
import { QuestionBrowserPage } from './pages/QuestionBrowserPage'
import { LlmTestPage } from './pages/LlmTestPage'
import { InterviewRoom } from './components/InterviewRoom'

// ============================================================
// Route guards
// ============================================================

/** Redirect unauthenticated users to /login */
function RequireAuth({ children }: { children: ReactNode }) {
  const { user, isLoading } = useAuth()
  const location = useLocation()

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <span className="text-gray-500 text-sm animate-pulse">Loading…</span>
      </div>
    )
  }

  if (!user) {
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  return <>{children}</>
}

/** Redirect authenticated users away from /login */
function RequireGuest({ children }: { children: ReactNode }) {
  const { user, isLoading } = useAuth()

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <span className="text-gray-500 text-sm animate-pulse">Loading…</span>
      </div>
    )
  }

  if (user) {
    return <Navigate to="/dashboard" replace />
  }

  return <>{children}</>
}

// ============================================================
// Keyed wrapper — forces full remount when slug changes so all
// hook state (stage, messages, code) resets cleanly
// ============================================================

function KeyedInterviewRoom() {
  const { slug } = useParams<{ slug?: string }>()
  return <InterviewRoom key={slug ?? '__no_slug__'} />
}

// ============================================================
// App routes
// ============================================================

function AppRoutes() {
  return (
    <Routes>
      {/* Public */}
      <Route
        path="/login"
        element={
          <RequireGuest>
            <LoginPage />
          </RequireGuest>
        }
      />

      {/* Onboarding — auth required but no onboarding check needed */}
      <Route
        path="/onboarding"
        element={
          <RequireAuth>
            <OnboardingPage />
          </RequireAuth>
        }
      />

      {/* Protected app routes */}
      <Route
        path="/dashboard"
        element={
          <RequireAuth>
            <DashboardPage />
          </RequireAuth>
        }
      />
      <Route
        path="/history"
        element={
          <RequireAuth>
            <SessionHistoryPage />
          </RequireAuth>
        }
      />
      <Route
        path="/interview/:slug?"
        element={
          <RequireAuth>
            <KeyedInterviewRoom />
          </RequireAuth>
        }
      />
      <Route
        path="/questions"
        element={
          <RequireAuth>
            <QuestionBrowserPage />
          </RequireAuth>
        }
      />
      {/* Dev-only LLM health-check — accessible without auth */}
      <Route path="/llm-test" element={<LlmTestPage />} />

      {/* Default redirects */}
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  )
}
