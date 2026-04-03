# Bliff — Build Phases

## Phase 1: MVP — Voice + Single Question + Claude Working

**Goal**: End-to-end proof of concept. You can speak to an AI interviewer and it responds.

### Deliverables
1. **Project scaffolding** — Vite + React + TypeScript + Tailwind + ESLint
2. **Vercel serverless proxy** — `/api/chat` endpoint that forwards to Claude API with key stored server-side
3. **Voice hook** (`useVoice.ts`) — Web Speech API for STT and TTS, language toggle EN/VI
4. **Interview room UI** — Single page with:
   - Mic button to start/stop recording
   - Chat transcript display
   - Text input fallback
   - Language toggle
5. **Hardcoded question** — "Two Sum" baked into the prompt
6. **Static system prompt** — Simplified version of the prompt design, no DB injection yet
7. **Basic interview flow** — Present problem → listen → respond → give hints
8. **Deploy to Vercel** — Working URL you can use on any device

### What is NOT in Phase 1
- No auth, no database, no code editor, no dashboard
- Single hardcoded question only
- No session persistence

---

## Phase 2: Supabase + Question Bank + Adaptive Logic

**Goal**: Real data layer. Login, question bank, session tracking, basic adaptation.

### Deliverables
1. **Supabase project setup** — Create project, configure environment variables
2. **Database schema** — All tables from schema design, migrations, seed data
3. **Auth integration** — Google login via Supabase Auth, protected routes
4. **User profile page** — Edit name, target companies, preferred language, etc.
5. **Question bank seed** — Import Blind 75 + NeetCode 150 metadata into `questions` table
6. **FE question bank seed** — Curated frontend interview questions
7. **Dynamic system prompt** — `promptBuilder.ts` assembles prompt from profile + stats + question
8. **Question selection engine** — `adaptiveEngine.ts` with weighted random selection:
   - Higher weight for weak topics
   - Re-queue failed questions
   - Lower weight for mastered questions
9. **Session tracking** — Create session on start, create attempt per question, save on end
10. **Post-session feedback** — AI generates structured JSON feedback, stored in `attempts.ai_feedback`
11. **Topic stats updater** — After each attempt, recalculate `user_topic_stats`
12. **Monaco code editor** — Embedded editor for writing solutions during interview

### Adaptive Engine Algorithm
```
For each eligible question:
  base_weight = 1.0
  
  // Topic weakness boost
  if topic.mastery_level == 'beginner': weight *= 3.0
  if topic.mastery_level == 'developing': weight *= 2.0
  if topic.mastery_level == 'proficient': weight *= 1.0
  if topic.mastery_level == 'mastered': weight *= 0.3
  
  // Previous failure boost
  if user failed this question before: weight *= 2.5
  if user partially solved: weight *= 1.5
  if user solved perfectly: weight *= 0.2
  
  // Recency penalty — avoid repeating recent questions
  if attempted in last 3 days: weight *= 0.1
  if attempted in last 7 days: weight *= 0.5
  
  // Difficulty preference — start with easy/medium, increase over time
  apply difficulty curve based on overall mastery

Select question via weighted random from top candidates.
```

---

## Phase 3: Dashboard + Auth + Polish ✅ COMPLETED

**Goal**: Full experience. Visual progress, streak tracking, auth, routing.

### Deliverables — All Completed

1. ✅ **Auth flow** — Supabase magic link login, `AuthContext`, `useAuth` hook, protected routes, guest routes
2. ✅ **Onboarding wizard** — Multi-step profile setup (role, experience, focus areas, target companies, weekly goal)
3. ✅ **Progress dashboard** — Recharts radar chart by topic, streak counter, weak area spotlight, quick-start CTA
4. ✅ **Session history page** — Past sessions list with AI feedback summaries, per-attempt detail, expandable view
5. ✅ **Interview room refinements** — Stage indicator (Warm-up → Interview → Feedback), countdown timer, stage-aware UI
6. ✅ **Warm-up / free-chat mode** — Casual AI conversation before interview, AI greets user by name
7. ✅ **Question browser page** (`/questions`) — Browse all 150+ questions by topic, filter by difficulty, search by title, launch to practice, category tabs (DSA / Frontend)
8. ✅ **LLM API test page** (`/llm-test`) — Dev health-check tool: non-streaming ping, streaming test, custom prompt sandbox, env var inspector
9. ✅ **React Router v6** — Full routing setup with `BrowserRouter`, protected `RequireAuth`, guest `RequireGuest`
10. ✅ **Dashboard nav links** — Questions, History, API test, Sign out

### Bug Fixes Applied
- Fixed LLM base URL hardcoded to OpenAI — now reads `VITE_LLM_BASE_URL`
- Fixed `sessions` table column (`uid` → `user_id`) causing SessionHistory crash
- Added `cursor-pointer` to all buttons via Tailwind CSS base layer

---

## Phase 4: Polish & Production — Next Up

**Goal**: Safe code execution, mobile support, real OAuth, production deploy.

### Planned Deliverables

1. **Web Worker code sandbox** — Move `Function()` evaluation off main thread; isolated sandbox with timeout kill
2. **Multi-language editor support** — Python, Java, Go stubs + test runner adapters
3. **Google OAuth login** — Swap magic link for Google provider in Supabase Auth
4. **Mobile-responsive layout** — Touch-friendly controls, responsive grid, voice UX on mobile
5. **Streaks + calendar heatmap** — Visual practice history on dashboard
6. **Spaced repetition scheduler** — SM-2 algorithm to auto-schedule question reviews
7. **Session export** — PDF/Markdown report of session with AI feedback
8. **Groq Whisper STT** — Replace Web Speech API with Groq Whisper for better accuracy + language support
9. **Production deployment** — Vercel (frontend) + Supabase hosted project (DB + Auth)
10. **Custom question import** — Add personal questions to question bank
