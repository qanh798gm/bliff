# Bliff — Technical Risks and Mitigations

## Risk 1: API Key Security
**Severity**: Critical
**Issue**: Calling Claude API directly from the browser exposes your API key in network requests and bundled code. Anyone can steal it and rack up charges.
**Mitigation**: Use a Vercel serverless function at `/api/chat` as a proxy. The API key lives only in Vercel environment variables, never in the frontend.

## Risk 2: Web Speech API Browser Support
**Severity**: Medium
**Issue**: `SpeechRecognition` is well-supported in Chrome/Edge but has limited or no support in Firefox and Safari. Vietnamese language support varies.
**Details**:
- Chrome: Full support for both EN and VI
- Firefox: No SpeechRecognition support
- Safari: Partial support, inconsistent
- Mobile browsers: Generally good on Android Chrome, mixed on iOS Safari
**Mitigation**: 
- Always provide a text input fallback
- Show a clear warning if the browser does not support speech
- Test Vietnamese recognition quality early — if poor, consider Whisper API as a fallback for Phase 4

## Risk 3: Text-to-Speech Quality
**Severity**: Low-Medium
**Issue**: Browser TTS voices vary wildly by OS. Windows, macOS, and mobile each have different built-in voices with different quality levels. Vietnamese TTS voices may sound robotic.
**Mitigation**:
- Let user choose from available voices in settings
- For Phase 4, consider ElevenLabs or OpenAI TTS for high-quality voice
- TTS is a nice-to-have — text response is always visible

## Risk 4: Claude API Cost
**Severity**: Medium
**Issue**: Each interview session involves multiple back-and-forth messages with a large system prompt. Claude Sonnet costs ~$3/M input tokens and ~$15/M output tokens. A 20-message session with 1500-token system prompt could cost ~$0.10-0.20 per session.
**Mitigation**:
- Use Claude Haiku for routine exchanges, Sonnet for evaluation/feedback only
- Cache the system prompt — Anthropic supports prompt caching
- Set a per-session message limit to 30 messages
- Track spending in the dashboard

## Risk 5: Supabase Free Tier Limits
**Severity**: Low — for single user
**Issue**: Free tier allows 500MB database, 1GB file storage, 50k monthly active users, 500k Edge Function invocations.
**For a personal app**: This is more than enough. A single user will never hit these limits.
**If scaling later**: Would need to upgrade to Pro at $25/month.

## Risk 6: Question Data Population
**Severity**: Medium
**Issue**: You need ~200+ questions with full descriptions, examples, hints, and expected approaches. Manually writing all this is tedious and error-prone.
**Mitigation**:
- Use Claude to generate question metadata in bulk from a list of titles
- Start with Blind 75 only for Phase 2, then expand
- Store just titles and topic mappings initially; let the AI interviewer present problems from its own knowledge in Phase 1
- Gradually enrich question data over time

## Risk 7: Interview State Management
**Severity**: Medium
**Issue**: The interview has multiple stages with complex state transitions. Voice interruptions, network drops, or accidental page refreshes could lose progress.
**Mitigation**:
- Use a state machine pattern for interview flow
- Persist conversation to localStorage as a backup
- Save to Supabase periodically, not just at session end
- Add a "resume session" feature for interrupted interviews

## Risk 8: Prompt Engineering Reliability
**Severity**: Medium
**Issue**: Claude may not always follow the system prompt perfectly. It might accidentally reveal answers, give too many hints at once, or not produce valid JSON for feedback.
**Mitigation**:
- Iterate on prompt wording extensively during Phase 1
- Use structured output where possible
- Validate JSON responses with a parser and retry on failure
- Add guardrails in the frontend — dont display raw AI output without checking format

## Risk 9: Mobile Experience
**Severity**: Low — for Phase 1-2
**Issue**: Monaco Editor is heavy on mobile. Voice interaction on mobile has different UX considerations like mic permissions and background noise.
**Mitigation**:
- Defer mobile optimization to Phase 3
- Consider CodeMirror as a lighter alternative to Monaco
- Test voice on mobile early to identify issues

## Risk 10: Conversation Context Window
**Severity**: Low
**Issue**: Long interview sessions could exceed Claude context window, though Claude Sonnet supports 200k tokens, so this is unlikely for a single session.
**Mitigation**:
- Monitor token count per session
- If approaching limit, summarize earlier messages
- Typical session of 30 messages should be well under 10k tokens total
