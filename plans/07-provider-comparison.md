# Bliff — STT, TTS, and LLM Provider Comparison

## Part 1: Speech-to-Text (STT) — You Talking to the App

| Provider | Cost | Quality EN | Quality VI | Latency | Browser Support | Notes |
|----------|------|-----------|-----------|---------|-----------------|-------|
| **Web Speech API** | Free | Good | Decent | ~0ms (real-time streaming) | Chrome/Edge only | Built into browser, no API key |
| **Groq Whisper** | Free tier: 7,200 min/month | Excellent | Excellent | ~0.5-1s per utterance | Any browser | Fastest Whisper inference, generous free tier |
| **OpenAI Whisper** | $0.006/min (~$0.18/hr) | Excellent | Excellent | ~1-2s per utterance | Any browser | Industry standard, needs real OpenAI key |
| **AssemblyAI** | Free tier: 100 hours/month | Excellent | Limited VI | ~0.5s | Any browser | Best for English, real-time streaming |
| **Deepgram** | Free tier: 12,000 min/month | Excellent | Limited VI | Real-time streaming | Any browser | Best latency for real-time, streaming support |
| **Azure Speech** | Free tier: 5 hours/month | Excellent | Excellent | Real-time streaming | Any browser | Best VI support among paid options |

**My recommendation for you**: 
- **Start**: Web Speech API (zero friction, works now)
- **Upgrade to**: Groq Whisper (free tier, any browser, great VI)

---

## Part 2: Text-to-Speech (TTS) — AI Talking to You

| Provider | Cost | Voice Quality | Vietnamese | Latency | Notes |
|----------|------|--------------|-----------|---------|-------|
| **Web Speech SpeechSynthesis** | Free | Robotic 2/5 | Basic | Instant | OS-dependent voices, no control |
| **OpenAI TTS** | $0.015/1k chars (~$0.02/response) | Excellent 4.5/5 | No native VI | ~0.5s streaming | Needs real OpenAI key, not proxy |
| **ElevenLabs** | Free: 10k chars/month, $5/mo: 30k chars | Best-in-class 5/5 | Limited | ~0.5-1s | Most natural, but free tier limited |
| **Groq TTS** | Free tier (PlayAI voices) | Very Good 4/5 | No VI | ~0.3s | New, fast, free with Groq account |
| **Google TTS** | Free tier: 1M chars/month (WaveNet: 1M chars free) | Good 4/5 | Good VI support | ~0.3s | Best free VI option, needs Google Cloud key |
| **Azure TTS** | Free tier: 0.5M chars/month neural | Excellent 4.5/5 | Excellent VI | ~0.3s streaming | Best VI quality, generous free tier |

**My recommendation for you**:
- **Start**: Web Speech SpeechSynthesis (zero friction, sounds acceptable)
- **Upgrade option A**: Groq TTS (same key as Groq STT, very fast, good quality)
- **Upgrade option B**: Google TTS (best free VI support, 1M chars free is huge)

---

## Part 3: LLM (Chat Brain) — The Interview Intelligence

| Provider | Cost per 1M tokens | Quality | Context | Streaming | OpenAI-compatible | Notes |
|----------|-------------------|---------|---------|-----------|-------------------|-------|
| **Your proxy** | Your deal | Depends on backend | Depends | Likely yes | Yes | Use this — you already pay for it |
| **OpenAI GPT-4o** | $2.50 in / $10 out | Excellent | 128k | Yes | Native | Smartest for coding interviews |
| **OpenAI GPT-4o-mini** | $0.15 in / $0.60 out | Very Good | 128k | Yes | Native | 90% quality at 6% of GPT-4o cost |
| **Claude Sonnet 3.7** | $3 in / $15 out | Excellent | 200k | Yes | Via wrapper | Best for long reasoning chains |
| **Groq llama-3.3-70b** | Free tier: generous limits | Good | 128k | Yes | Yes | Fast inference, good for casual use |
| **Groq DeepSeek-R1** | Free tier available | Very Good | 64k | Yes | Yes | Reasoning model, great for DSA |

**My recommendation for you**:
- **Use your proxy** — you already have the quota, it's free to you
- **If you want to experiment**: Groq's free tier gives you llama-3.3-70b and DeepSeek-R1 at no cost

---

## Optimal Free-Tier Stack for Your Use Case

If you want maximum quality at near-zero cost using only free tiers:

```
STT:  Groq Whisper          — 7,200 min/month free
LLM:  Your existing proxy   — free (already paid)
TTS:  Google Cloud TTS      — 1M chars/month free (best VI) 
      OR Groq TTS           — free, simpler same-key setup
```

**All three services use a single API key** if you consolidate to Groq:
```bash
VITE_STT_PROVIDER=groq
VITE_TTS_PROVIDER=groq
VITE_LLM_PROVIDER=your-proxy   # or switch to groq for everything
VITE_GROQ_API_KEY=gsk_...
```

Groq has become a full stack voice AI platform — STT + LLM + TTS all under one free tier key.

---

## Session Cost Estimate

### A typical 30-minute practice session:

| Component | Web Speech Free | Groq All-In Free | Mixed Paid |
|-----------|----------------|-----------------|------------|
| STT (30 min audio) | $0 | $0 (free tier) | $0.18 OpenAI |
| LLM (~50 messages x 2k tokens avg) | Your proxy | Your proxy or Groq free | $0.25 GPT-4o-mini |
| TTS (~3000 chars AI responses) | $0 | $0 (free tier) | $0.045 OpenAI |
| **Total per session** | **$0** | **$0** | **~$0.50** |

With your proxy for LLM and Groq for voice = **effectively $0 per session**.

---

## Decision Summary

| Decision | Recommendation | Reason |
|----------|---------------|--------|
| STT Phase 1 | Web Speech API | Zero friction, start coding now |
| STT Phase 2 | Groq Whisper | Free tier huge, any browser, great VI |
| TTS Phase 1 | Web Speech SpeechSynthesis | Zero friction |
| TTS Phase 2 | Groq TTS or Google TTS | Free, natural quality, VI support |
| LLM | Your existing proxy | Already free to you |
| Architecture | Provider abstraction | Switch any component via .env.local |
