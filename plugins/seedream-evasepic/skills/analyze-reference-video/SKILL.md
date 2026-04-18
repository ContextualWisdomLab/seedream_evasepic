---
name: analyze-reference-video
description: >-
  Analyze a reference video (YouTube/TikTok/Instagram URL or local file) and reverse-engineer its visual style, pacing, camera work, edit rhythm, and tone into a reusable style template (reference-style.md). Designed to feed into product-series-kit so the user's 5-episode series matches a target style. Uses ffmpeg for frame extraction and whisper for transcription. Use when the user provides a video URL/file and says "make it like this", "이 스타일로", "분석해줘", "이 영상 참고해서", "이런 느낌으로", "레퍼런스 영상".
---

# Analyze Reference Video — Style Extraction

Deconstruct a reference video into a **transferable style template**. Output is `reference-style.md` — a self-contained style descriptor that `product-series-kit` can consume to make every episode look/feel like the reference.

**This skill extracts STYLE only, not content.** The user's product/model/brand replaces the reference's subject matter — only the structural and aesthetic patterns carry over.

---

## When to use

Trigger when the user:
- Drops a video URL (YouTube, TikTok, Instagram, Vimeo, X/Twitter)
- Drops a local `.mp4` / `.mov` / `.webm` file
- Says "이 스타일로 만들어줘", "analyze this video", "이런 느낌으로", "make it like this", "레퍼런스로 삼아"
- Mentions wanting their series to match a specific look/feel they saw

If they just want a single video (no series), still run this — then hand off to `generate-prompt-pair`.

---

## Dependencies

**Required:**
- `ffmpeg` + `ffprobe` — frame + audio extraction
  - macOS: `brew install ffmpeg`
  - Verify: `which ffmpeg`

**Optional but recommended:**
- `yt-dlp` — download from YouTube/TikTok/etc.
  - macOS: `brew install yt-dlp` or `pip install yt-dlp`
  - If the `insane-search` plugin is installed, it auto-installs yt-dlp on demand
- `whisper` — audio transcription
  - `pip install openai-whisper`
  - Skip if user provides dialogue manually

---

## Inputs

| Input | Required | Format |
|-------|----------|--------|
| Video URL or file path | yes | YouTube URL, TikTok URL, Instagram URL, X URL, local `.mp4`/`.mov`/`.webm` |
| Style name (optional) | no | e.g., "korean-drama", "clinical-beauty", "ugc-raw". Auto-named if omitted. |
| Focus hint (optional) | no | e.g., "focus on lighting" / "focus on pacing" — biases analysis depth |

---

## Workflow

### Step 0: Resolve the input to a local file

- **If URL** — run `scripts/download-reference.sh <url> /tmp/ref-video.mp4`
- **If local path** — verify file exists
- **If URL fails** (Instagram login, TikTok geo-block, etc.) — ask user to download manually OR fall back to browser-based extraction via `insane-search` plugin

### Step 1: Extract frames + audio

```bash
bash scripts/extract-frames.sh "<video_path>" "/tmp/ref-analysis" <num_frames>
```

Frame count rule:
| Duration | Frames |
|----------|--------|
| Under 10s | 8 |
| 10-20s | 12 |
| 20-30s | 16 |
| Over 30s | 20 |
| Over 60s | 24 (cap) |

Outputs: `/tmp/ref-analysis/frame_001.jpg … frame_NNN.jpg`, `audio.wav`, `metadata.txt`.

Read `metadata.txt` for duration/resolution/fps.

### Step 2: Transcribe audio (if present)

```bash
bash scripts/transcribe.sh /tmp/ref-analysis/audio.wav
```

If whisper missing and user can't install, ask them to paste dialogue manually. Silent videos skip this step.

### Step 3: Analyze across 8 dimensions

Read ALL frames. Read the transcript. For each dimension, write 2-4 bullets identifying **transferable patterns** (not specific content).

Use [references/analysis-dimensions.md](references/analysis-dimensions.md) as the detailed rubric:

1. **Structure & pacing** — beat count, beat lengths, narrative arc
2. **Camera & framing** — POV, movement types, shot rhythm
3. **Edit style** — cut type, rhythm, visual motifs
4. **Dialogue & script** — hook format, speech patterns, silent-vs-spoken ratio
5. **Tone & energy** — emotion words, energy arc, viewer relationship
6. **Lighting & quality** — light sources, color grading, intentional "flaws"
7. **Product/subject handling** — how the hero subject is revealed/featured
8. **Distinctiveness** — the 2-3 things that make THIS style unique

### Step 4: Compress to a 15-second style template

Seedance 2.0 maxes at 15 seconds per clip. The user's series will be 5 × 15s.

So convert the reference into a **15-second essence**:
- Which 2-3 beats are essential?
- What's the minimum spoken-line count?
- What's the single defining visual signature?

Use [references/style-extraction-guide.md](references/style-extraction-guide.md) for the compression method.

### Step 5: Write `reference-style.md`

Save to `/tmp/ref-analysis/reference-style.md` with this structure:

```markdown
# Reference Style: {Style Name}

## Source
- Input: {URL or file path}
- Duration: Xs | Resolution: W×H | FPS: F
- Analyzed: YYYY-MM-DD

## Style summary (1 paragraph)
{2-3 sentences capturing the style's essence — the elevator pitch.}

## 8-dimension breakdown

### 1. Structure & pacing
- Beat count: {N}
- Average beat length: {Xs}
- Narrative arc: {hook → demo → verdict / etc.}
- Pacing rhythm: {fast cuts / held shots / mixed}

### 2. Camera & framing
- POV: {selfie / tripod / handheld / over-shoulder / drone}
- Movement signature: {dolly-in / handheld shake / static / mixed}
- Shot rhythm: {wide → medium → close / all close / etc.}

### 3. Edit style
- Cut type: {jump cuts / dissolves / match cuts}
- Visual motifs: {recurring close-up on X / before-after / etc.}

### 4. Dialogue & script
- Hook format: {question / bold claim / reaction}
- Speech pattern: {casual with filler / scripted / VO / text-on-screen}
- Silent-vs-spoken ratio: {e.g. 40% silent action, 60% dialogue}

### 5. Tone & energy
- Emotion words: {3-4}
- Energy arc: {builds / flat / peaks + drops}
- Relationship to viewer: {friend / expert / skeptic}

### 6. Lighting & quality
- Light source: {natural window / ring light / mixed practicals}
- Color grading: {warm / cool / desaturated / high-contrast}
- Intentional flaws: {phone grain / motion blur / auto-WB shifts}

### 7. Product/subject handling
- Reveal pattern: {gradual / immediate / in-hand always}
- Featured details: {texture / label / before-after}

### 8. Distinctive traits (the 2-3 that define this style)
1. {trait 1}
2. {trait 2}
3. {trait 3}

## 15-second compression plan
- Essential beats (map to 3-beat skeleton): {beat 1 / beat 2 / beat 3}
- Dialogue cap: {word count that fits 15s at natural pace}
- Single defining visual: {the one shot this style MUST have}

## Recommended adaptation for 5-episode series
- Per-episode beat count: {2 / 3}
- Episode arc mapping: Hook/Benefit/Demo/Testimonial/CTA → how to apply
- What changes vs stays: list
```

### Step 6: Hand off

Tell the user:
```
✅ Reference analyzed: {Style Name}

📄 reference-style.md written to /tmp/ref-analysis/reference-style.md

Key signature:
  - {distinctive trait 1}
  - {distinctive trait 2}
  - {distinctive trait 3}

Ready to build your 5-episode series in this style?
Provide your product brief (or I'll use the one from earlier).
```

Then invoke `product-series-kit` with `reference-style.md` path in context.

---

## Failure recovery

| Failure | Recovery |
|---------|----------|
| `ffmpeg` missing | `brew install ffmpeg`, try again |
| URL download blocked (403, login wall) | If `insane-search` plugin installed, ask it to fetch. Else ask user to download manually. |
| Video > 2 minutes | Offer to analyze a user-picked 30-60s segment. Ask for start/end timestamps. |
| Audio transcription fails | Ask user to paste dialogue manually OR proceed as silent-video analysis |
| Frame count hits 24 cap | Acceptable — 24 frames covers long videos well enough for style analysis |

## Related

- [product-series-kit](../product-series-kit/SKILL.md) — downstream consumer of `reference-style.md`
- [generate-prompt-pair](../generate-prompt-pair/SKILL.md) — single-pair downstream consumer
