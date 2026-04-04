# Bliff 🎙️

> A personal DSA Interview Coach that talks back.

Bliff is a voice-first web app that simulates real FAANG-style technical interviews. You speak, it listens, it asks you clarifying questions, gives progressive hints, and evaluates your solution — just like a real interviewer.

Built for one person: a 6-year frontend engineer grinding toward FAANG.

---

## What It Does

- 🎙️ **Voice Interaction** — Talk to Bliff like a real interviewer. It speaks back via Text-to-Speech. Supports English and Vietnamese.
- 🧠 **Personalized Memory** — Tracks your strengths, weaknesses, and history. Every session adapts to where you are.
- 📊 **Adaptive Questions** — Weak topics get more questions. Problems you failed come back. Mastered ones appear less.
- 💻 **Code Editor** — Monaco editor (VS Code engine) embedded in-browser. Write solutions, run tests, submit.
- 🔬 **In-Browser Testing** — Test cases run instantly in the browser. No external judge service needed.
- 📈 **Progress Dashboard** — Visual breakdown by topic, streak tracking, weak area spotlight.
- 🗂️ **Question Browser** — Browse 150+ questions by topic, difficulty, and category (DSA + Frontend).

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18 + TypeScript + Vite + Tailwind CSS |
| Routing | React Router v6 |
| Code Editor | Monaco Editor (`@monaco-editor/react`) |
| Code Execution | Browser `Function()` sandbox + Web Worker |
| Voice STT | Web Speech API (browser-native) |
| Voice TTS | Browser SpeechSynthesis |
| AI / LLM | OpenAI-compatible API (configurable proxy) |
| Database | Supabase (PostgreSQL + Auth) |
| Auth | Supabase Auth — Email magic link / Google |
| Charts | Recharts |

---

## Project Status

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1 — MVP | ✅ Done | Voice + Monaco editor + LLM + Two Sum working locally |
| Phase 2 — Data Layer | ✅ Done | Supabase schema + 150+ questions + adaptive engine |
| Phase 3 — Dashboard & Auth | ✅ Done | Auth, onboarding, dashboard, session history, routing |
| Phase 4 — Practice & Solutions | ✅ Done | Practice mode, multi-solution tracking, rich test tiers, layout redesign |
| Phase 5 — AI Memory | 🚧 In Progress | Long-term memory layer, coach insights, session context snapshots |

### Phase 5 — In Progress

**Goal:** Give Bliff a persistent AI memory layer and a voice-first mentor on the dashboard.

**Completed so far:**
- `user_memory` + `session_context` DB migrations applied
- `memoryService.ts` — `loadSessionMemory`, `upsertMemories`, `expireOldSummaries`, `saveSessionContext`
- `promptBuilder.ts` — `buildMemorySection`, `parseMemoryJson`, `buildWarmupContext`, `parseMentorRecommendations`
- `useInterview.ts` + `usePractice.ts` — load session context at start, save AI memory at end, rolling 20-message window, warmup handoff from mentor
- `useMentorChat` hook — personalised auto-greeting, free-form chat, recommendation cards
- `MentorChatPanel` — voice-first chat panel (STT mic, TTS speaker button), recommendation cards that navigate with warmup context
- Dashboard layout → 3-column `[description | stats+radar | AI mentor]`
- Interview + Practice screens → 3-column `[problem | editor+tests | AI chat]`
- Bug fixes: `maybeSingle()` for empty profile, correct column names in stats query, SSE stream `[DONE]` exit, React Strict Mode double-invoke guard

See [`plans/10-phase5-memory-architecture.md`](plans/10-phase5-memory-architecture.md) for full design.

### Phase 4 — What Was Built

- **Practice Mode** (`/practice/:slug`) — code-first, AI opt-in, silent stat tracking
- **Multi-solution tracking** — `user_solutions` table; save ranked Brute Force → Optimal solutions per question; AI references prior solutions in prompts
- **Rich test case tiers** — basic / edge / corner / performance schema; `practice_attempts` + `practice_solved` stats
- **Layout redesign** — editor + test results always visible; AI chat in left panel
- **Question Browser** — dual hover buttons: `▶ Practice` and `🎙 Interview`
- **Fixes** — clickable question rows, stale question panel bug (Two Sum default)

### Phase 3 — What Was Built

- **Auth flow** — Supabase magic link login, protected routes, onboarding wizard
- **Dashboard** — Recharts radar chart by topic, streak counter, weak areas, quick-start
- **Session History** — Full past-session browser with AI feedback summaries
- **Interview Room** — Timer, stage indicator (Warm-up → Interview → Feedback), voice controls
- **Question Browser** — Browse all 150+ questions by topic + category (DSA / Frontend), filter by difficulty, search by title, launch directly into practice
- **LLM Test Page** — `/llm-test` developer tool: ping test, streaming test, custom prompt sandbox, env var inspector
- **Warm-up mode** — Free-chat stage before interview starts; AI greets the user, builds rapport
- **Fixes** — DB column alignment, cursor-pointer global base style, LLM env var usage, question browser navigates via `/interview/:slug` URL param (bookmarkable + refresh-safe)
- **Fix: stale question on slug change** — `KeyedInterviewRoom` wrapper in router forces full remount of `InterviewRoom` on slug change so stage/messages/code/question all reset cleanly; editor `code` state now syncs to `interview.question.functionSignature` via `useEffect`

---

## Local Development

### Prerequisites
- Node.js 20+
- A Supabase project (free tier) OR run locally via `supabase start`
- An OpenAI-compatible LLM API key

### Setup

```bash
# Clone and install
git clone https://github.com/your-username/bliff.git
cd bliff
npm install

# Start local Supabase (optional — or point to hosted project)
npx supabase start
npx supabase db reset   # applies all migrations + seeds

# Configure environment
cp .env.example .env.local
# Edit .env.local with your keys (see below)

# Run
npm run dev
```

### Environment Variables

Create `.env.local` in the project root:

```bash
# LLM — OpenAI-compatible endpoint
VITE_LLM_BASE_URL=https://your-proxy.com/v1
VITE_LLM_API_KEY=sk-...
VITE_LLM_MODEL=gpt-4o

# Supabase (local dev defaults shown)
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=eyJ...

# Voice (optional — defaults to browser Web Speech API)
# VITE_STT_PROVIDER=webspeech   # or "groq"
# VITE_TTS_PROVIDER=webspeech   # or "groq"
# VITE_GROQ_API_KEY=gsk_...
```

### Verify LLM Connection

Navigate to `http://localhost:5173/llm-test` after `npm run dev` — runs a non-streaming ping and a streaming test against your configured endpoint.

---

## App Routes

| Route | Description |
|-------|-------------|
| `/login` | Email magic link + OAuth login |
| `/onboarding` | First-time profile setup wizard |
| `/dashboard` | Main hub: radar chart, streak, quick-start |
| `/interview` | Live interview room (voice + code + AI) |
| `/questions` | Question browser — browse & launch practice |
| `/history` | Past sessions with AI feedback |
| `/llm-test` | Dev tool: LLM API health check |

---

## Architecture

See the [`/plans`](./plans) directory for full architecture documentation:

- [`01-architecture-overview.md`](plans/01-architecture-overview.md) — System design and component map
- [`02-supabase-schema.md`](plans/02-supabase-schema.md) — Full database schema
- [`03-system-prompt-design.md`](plans/03-system-prompt-design.md) — Dynamic AI prompt structure
- [`04-build-phases.md`](plans/04-build-phases.md) — Phased delivery plan
- [`05-technical-risks.md`](plans/05-technical-risks.md) — Risk register
- [`06-voice-architecture-revised.md`](plans/06-voice-architecture-revised.md) — Voice pipeline design
- [`07-provider-comparison.md`](plans/07-provider-comparison.md) — STT/TTS/LLM provider comparison
- [`08-code-editor-execution.md`](plans/08-code-editor-execution.md) — Code editor and test runner design

---

## How a Session Works

1. Open the app — you're greeted by name on the dashboard
2. Click **Start Practice** or pick a question from the browser
3. Bliff opens with a **Warm-up** — casual chat to get you comfortable
4. Say *"Let's start"* — Bliff presents the problem out loud
5. Ask clarifying questions (Bliff notes if you don't — real interviewers do too)
6. Write your solution in the Monaco editor
7. Click **Run Tests** — see results instantly in the browser
8. Talk through your approach, complexity, trade-offs
9. Click **Submit** — Bliff gives structured feedback: approach, complexity, edge cases, communication
10. Stats update — topic mastery recalculated, session saved to Supabase

---

## Question Bank

- **Arrays & Hashing** — Two Sum, Valid Anagram, Group Anagrams, and more
- **Two Pointers** — Valid Palindrome, Container With Most Water, 3Sum
- **Sliding Window** — Best Time to Buy/Sell Stock, Longest Substring Without Repeating
- **Stack, Binary Search, Linked List, Trees, Tries**
- **Heap / Priority Queue, Backtracking, Graphs, Dynamic Programming**
- **Greedy, Intervals, Math & Bit Manipulation**
- **Frontend — JavaScript, React, TypeScript, CSS, Performance, System Design**

Total: **150+ questions** across **19 topics**

---

## Phase 4 Roadmap

- [x] Clickable question rows in Question Browser
- [x] Fix stale question panel (always showed Two Sum regardless of selected question)
- [ ] Web Worker sandbox for safe code execution (no eval in main thread)
- [ ] Multi-language support in editor (Python, Java, Go)
- [ ] Google OAuth login (production)
- [ ] Mobile-responsive layout
- [ ] Streaks + calendar heatmap on dashboard
- [ ] Export session as PDF
- [ ] Groq Whisper STT + Groq TTS integration
- [ ] Production deployment (Vercel + Supabase hosted)

---

## License

Personal use. Not intended for redistribution.
