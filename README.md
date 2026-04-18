# seedream_evasepic

> **Product brief in → 5-episode cinematic series prompt kit out.**
> Built for Seedream (image) + Seedance 2.0 (video) by ByteDance.
> Optimized for K-beauty / cosmetics brands.

A Claude Code plugin that turns a single product brief into **10 paired prompts** — 5 image prompts (Seedream) and 5 video prompts (Seedance 2.0), one pair per episode, all visually and narratively consistent across a series.

You can also drop a **reference video URL** and the plugin will reverse-engineer its style into a reusable template before composing your series.

---

## Quick Start

### 1. Add the marketplace
```
/plugin marketplace add https://github.com/passeth/seedream_evasepic.git
```

### 2. Install the plugin
```
/plugin install seedream-evasepic
```

### 3. Restart Claude Code

### 4. Start a series

Drop a product brief into the conversation:

```
제품: CERACLINIC 세라마이드 앰플
특징: 고농축 세라마이드 5종, 민감성 진정
모델: 30대 초반 여성, 전문가적 신뢰감
무드: 클리니컬 미니멀, 따뜻한 화이트톤
플랫폼: 인스타 릴스 (9:16)
참고영상: https://www.youtube.com/watch?v=...   # 선택
→ 5-에피소드 시리즈로 만들어줘
```

Claude will:
1. Analyze the reference video (if provided) — frames, audio, 8-dimension breakdown
2. Plan 5 connected episodes (Hook → Benefit → Demo → Testimonial → CTA)
3. For each episode, output a **pair**:
   - 🖼️ **Image prompt** (Seedream 4.5 / Dreamina / fal.ai)
   - 🎬 **Video prompt** (Seedance 2.0, using that image as reference)
4. Generate QA checklist + optional ffmpeg stitch command

---

## What's inside

Three sub-skills compose the workflow:

| Skill | Purpose |
|-------|---------|
| **product-series-kit** | Brief → 5-episode structured series plan with paired prompts |
| **analyze-reference-video** | Reference video (URL or file) → reusable style template |
| **generate-prompt-pair** | One-shot: generate a single image+video prompt pair |

All three are invoked automatically when Claude detects your intent.

---

## Key Features

- **Paired output** — image prompt and video prompt are built together so the still-frame and the motion match perfectly
- **5-episode arc templates** — Hook / Benefit / Demo / Testimonial / CTA (skincare, makeup, fragrance, premium launch arcs included)
- **Reference video analyzer** — drop a YouTube/TikTok/Instagram URL, plugin extracts frames + transcript + 8-dimension style analysis
- **Seedance 2.0 compliant** — 100-260 word prompts, forbidden-word filter, Subject+Action+Camera+Style+Constraints order, camera movement cheat sheet built in
- **K-beauty mood library** — curated color palettes, lighting setups, model types, and voice tones for Korean cosmetics
- **No API keys required** — the plugin generates prompts; you paste them into Dreamina / fal.ai / Seedance platform of choice

---

## Requirements

**Required:**
- Claude Code
- `ffmpeg` + `ffprobe` (only if using reference video analysis)

**Optional:**
- `yt-dlp` for downloading YouTube/TikTok reference videos (auto-installed by [insane-search](https://github.com/fivetaku/insane-search) if present)
- `whisper` for audio transcription: `pip install openai-whisper`

The plugin auto-detects missing tools and guides you through install.

---

## File Structure

```
plugins/seedream-evasepic/skills/
├── product-series-kit/
│   ├── SKILL.md                    # Main workflow entry
│   ├── templates/                  # Input/output YAML templates
│   ├── references/                 # Platform rules (Seedance 2.0, Seedream 4.5, etc.)
│   ├── episode-archetypes/         # 5 episode blueprints
│   ├── series-templates/           # Skincare / Makeup / Premium launch arcs
│   ├── curated-prompts/            # Styles pulled from awesome-seedance-2-prompts
│   └── examples/                   # Full worked example
├── analyze-reference-video/
│   ├── SKILL.md
│   ├── scripts/                    # ffmpeg + download + whisper helpers
│   └── references/                 # 8-dimension analysis framework
└── generate-prompt-pair/
    ├── SKILL.md
    └── templates/                  # Image + video prompt templates
```

---

## Acknowledgements

Built by distilling patterns from:
- [krusemediallc/arcads-claude-code](https://github.com/krusemediallc/arcads-claude-code) — layered prompt formulas, analyze-video approach
- [YouMind-OpenLab/awesome-seedance-2-prompts](https://github.com/YouMind-OpenLab/awesome-seedance-2-prompts) — 1,936 curated community prompts
- [ByteDance Seedance 2.0 official prompt guide](https://docs.byteplus.com/en/docs/ModelArk/1631633)

---

## License

MIT — use freely, credit appreciated.
