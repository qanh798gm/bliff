import { useState } from 'react'
import { useAuth } from '../contexts/AuthContext'

// ============================================================
// LoginPage — supports both magic link AND email/password
// ============================================================

type AuthMode = 'magic' | 'password'

export function LoginPage() {
  const { signIn, signInWithPassword, signUpWithPassword } = useAuth()
  const [authMode, setAuthMode] = useState<AuthMode>('password')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [status, setStatus] = useState<'idle' | 'loading' | 'sent' | 'error'>('idle')
  const [errorMsg, setErrorMsg] = useState('')
  const [isSignUp, setIsSignUp] = useState(false)

  const handleMagicLink = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email.trim()) return
    setStatus('loading')
    setErrorMsg('')
    const { error } = await signIn(email.trim())
    if (error) { setErrorMsg(error); setStatus('error') }
    else setStatus('sent')
  }

  const handlePassword = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email.trim() || !password.trim()) return
    setStatus('loading')
    setErrorMsg('')
    const fn = isSignUp ? signUpWithPassword : signInWithPassword
    const { error } = await fn(email.trim(), password)
    if (error) { setErrorMsg(error); setStatus('error') }
    else setStatus('idle')
  }

  return (
    <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-10">
          <h1 className="text-4xl font-bold text-white tracking-tight">
            bli<span className="text-indigo-400">ff</span>
          </h1>
          <p className="mt-2 text-gray-400 text-sm">AI-powered technical interview practice</p>
        </div>

        <div className="bg-gray-900 border border-gray-800 rounded-2xl p-8 shadow-xl">
          {/* Mode toggle */}
          <div className="flex bg-gray-800 rounded-lg p-1 mb-6">
            <button
              onClick={() => { setAuthMode('password'); setStatus('idle'); setErrorMsg('') }}
              className={`flex-1 text-sm py-1.5 rounded-md font-medium transition-colors ${
                authMode === 'password' ? 'bg-gray-700 text-white' : 'text-gray-400 hover:text-gray-200'
              }`}
            >
              Email + password
            </button>
            <button
              onClick={() => { setAuthMode('magic'); setStatus('idle'); setErrorMsg('') }}
              className={`flex-1 text-sm py-1.5 rounded-md font-medium transition-colors ${
                authMode === 'magic' ? 'bg-gray-700 text-white' : 'text-gray-400 hover:text-gray-200'
              }`}
            >
              Magic link
            </button>
          </div>

          {/* Magic link flow */}
          {authMode === 'magic' && (
            <>
              {status === 'sent' ? (
                <div className="text-center py-4">
                  <div className="text-4xl mb-4">📬</div>
                  <h2 className="text-white font-semibold text-lg mb-2">Check your inbox</h2>
                  <p className="text-gray-400 text-sm mb-2">
                    Magic link sent to <span className="text-indigo-300 font-medium">{email}</span>.
                  </p>
                  <p className="text-gray-500 text-xs">
                    Local dev? Open{' '}
                    <a
                      href="http://127.0.0.1:54334"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-indigo-400 underline"
                    >
                      Mailpit
                    </a>{' '}
                    to see the email.
                  </p>
                  <button
                    onClick={() => { setStatus('idle'); setEmail('') }}
                    className="mt-5 text-sm text-gray-500 hover:text-gray-300 transition-colors"
                  >
                    Use a different email
                  </button>
                </div>
              ) : (
                <form onSubmit={handleMagicLink} className="space-y-4">
                  <div>
                    <label className="block text-sm text-gray-400 mb-1.5">Email address</label>
                    <input
                      type="email"
                      value={email}
                      onChange={e => setEmail(e.target.value)}
                      placeholder="you@example.com"
                      required
                      autoFocus
                      className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2.5 text-white placeholder-gray-500 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
                    />
                  </div>
                  {status === 'error' && <p className="text-red-400 text-sm">{errorMsg}</p>}
                  <button
                    type="submit"
                    disabled={status === 'loading'}
                    className="w-full bg-indigo-600 hover:bg-indigo-500 disabled:opacity-60 text-white font-medium py-2.5 rounded-lg text-sm transition-colors"
                  >
                    {status === 'loading' ? 'Sending…' : 'Send magic link'}
                  </button>
                </form>
              )}
            </>
          )}

          {/* Email + password flow */}
          {authMode === 'password' && (
            <form onSubmit={handlePassword} className="space-y-4">
              <div>
                <label className="block text-sm text-gray-400 mb-1.5">Email address</label>
                <input
                  type="email"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  placeholder="you@example.com"
                  required
                  autoFocus
                  className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2.5 text-white placeholder-gray-500 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
                />
              </div>
              <div>
                <label className="block text-sm text-gray-400 mb-1.5">Password</label>
                <input
                  type="password"
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  placeholder="••••••••"
                  required
                  minLength={6}
                  className="w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2.5 text-white placeholder-gray-500 text-sm focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500"
                />
              </div>
              {status === 'error' && <p className="text-red-400 text-sm">{errorMsg}</p>}
              <button
                type="submit"
                disabled={status === 'loading'}
                className="w-full bg-indigo-600 hover:bg-indigo-500 disabled:opacity-60 text-white font-medium py-2.5 rounded-lg text-sm transition-colors"
              >
                {status === 'loading'
                  ? (isSignUp ? 'Creating account…' : 'Signing in…')
                  : (isSignUp ? 'Create account' : 'Sign in')}
              </button>
              <button
                type="button"
                onClick={() => { setIsSignUp(s => !s); setErrorMsg(''); setStatus('idle') }}
                className="w-full text-sm text-gray-500 hover:text-gray-300 transition-colors"
              >
                {isSignUp ? 'Already have an account? Sign in' : "Don't have an account? Create one"}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  )
}
