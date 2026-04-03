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

## Phase 3: Dashboard + Polish + Advanced Features

**Goal**: Full experience. Visual progress, streak tracking, refined AI behavior.

### Deliverables
1. **Progress dashboard page** with:
   - Topic mastery radar/bar chart (using Recharts or Chart.js)
   - Solved vs attempted vs gave-up per topic
   - Average score trend over time
   - Current streak display
2. **Streak system** — Calculate from `sessions` table, update `user_profiles`
3. **Weak area spotlight** — Highlight bottom 3 topics, suggest next question from those
4. **Session history page** — List of past sessions with:
   - Questions attempted
   - Scores received
   - Expandable AI feedback
   - Conversation replay
5. **Interview mode refinements**:
   - Visible timer with configurable duration
   - Stage indicator — shows current phase of interview
   - Hint counter display
6. **AI personality tuning** — Adjust interviewer style based on user preference
7. **Profile strength/weakness auto-update** — After each session, AI suggests updates to profile
8. **PWA support** — Service worker for offline shell, add-to-home-screen
9. **Mobile responsive** — Full mobile support for practice on the go

---

## Phase 4: Future Enhancements — Post-MVP Roadmap

Not planned in detail yet, but potential additions:

- **Code execution** — Judge0 API or similar for running tests
- **Multiplayer mock interviews** — Practice with friends
- **Spaced repetition** — SM-2 algorithm for question scheduling
- **Export progress** — PDF report of interview readiness
- **Custom question import** — Add your own questions
- **LeetCode integration** — Link to actual LC problems
