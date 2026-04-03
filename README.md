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

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | React 18 + TypeScript + Vite + Tailwind CSS |
| Code Editor | Monaco Editor (`@monaco-editor/react`) |
| Code Execution | Browser `Function()` sandbox + Web Worker |
| Voice STT | Web Speech API → Groq Whisper (Phase 2) |
| Voice TTS | Browser SpeechSynthesis → Groq TTS (Phase 2) |
| AI / LLM | OpenAI-compatible API (configurable proxy) |
| Database | Supabase (PostgreSQL + Auth) |
| Auth | Supabase Auth — Google login |

---

## Project Status

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1 — MVP | 🚧 In Progress | Voice + single question + LLM working locally |
| Phase 2 — Data Layer | ⬜ Planned | Supabase + question bank + adaptive engine |
| Phase 3 — Dashboard | ⬜ Planned | Charts, streak, session history, mobile |

---

## Local Development

### Prerequisites
- Node.js 20+
- A Supabase project (free tier)
- An OpenAI-compatible LLM API key

### Setup

```bash
# Clone and install
git clone https://github.com/your-username/bliff.git
cd bliff
npm install

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

# Supabase
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...

# Voice (Phase 2 — optional, defaults to browser Web Speech API)
# VITE_STT_PROVIDER=webspeech   # or "groq"
# VITE_TTS_PROVIDER=webspeech   # or "groq"
# VITE_GROQ_API_KEY=gsk_...
```

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

1. Open the app — Bliff greets you by name
2. Say *"Give me a medium graph problem"* or *"Check my progress and pick something for me"*
3. Bliff presents the problem out loud
4. You ask clarifying questions (Bliff notes if you don't — real interviewers do too)
5. Write your solution in the Monaco editor
6. Click **Run Tests** — see results instantly
7. Talk through your approach, complexity, trade-offs
8. Click **Submit** — Bliff gives structured feedback on approach, complexity, edge cases, and communication
9. Stats update — topic mastery recalculated, session saved

---

## Question Bank

- **Blind 75** — Classic must-know problems
- **NeetCode 150** — Expanded coverage
- **Frontend Curated** — DOM, CSS, JS, React, performance, system design

---

## License

Personal use. Not intended for redistribution.
