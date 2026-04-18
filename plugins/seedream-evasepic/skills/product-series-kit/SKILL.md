---
name: product-series-kit
description: >-
  Transform a product brief (image + model + brand mood + features) into a 5-episode video series prompt kit. For each episode, output a PAIRED set: one Seedream image-generation prompt + one Seedance 2.0 video-generation prompt that uses that image as reference. Optimized for K-beauty and cosmetics but works for any product. Use when the user provides product info and asks for a video series, ad campaign, Reels/Shorts plan, 5-episode series, or wants a multi-clip cohesive video set. Korean triggers include 시리즈 기획, 5편 영상, 릴스 시리즈, 광고 캠페인, 제품 영상 시리즈.
---

# Product Series Kit — 5-Episode Seedream + Seedance 2.0

Turn a single product brief into a tightly-connected 5-episode video series. Each episode ships as a **paired prompt set**:

1. 🖼️ **Image prompt** — feed to Seedream 4.5 / Dreamina / fal.ai to generate the hero still
2. 🎬 **Video prompt** — feed to Seedance 2.0 with the still above as `referenceImages`

Both are tuned so the image looks like the exact first frame of the video.

---

## When to use this skill

Trigger when the user:
- Provides product info and asks for a "5-episode series", "영상 시리즈", "릴스 캠페인", "ad series"
- Wants a multi-clip cohesive campaign (not a single video)
- Mentions K-beauty, cosmetic, skincare, makeup, fragrance brand video
- Says "시리즈 기획", "5편으로", "여러 편 만들어", "캠페인으로"

If they only want a single video, use `generate-prompt-pair` sub-skill instead.
If they provide a reference video URL/file, run `analyze-reference-video` FIRST, then feed its output style into this skill.

---

## Workflow

### Step 1: Intake — fill the product brief

Read [templates/product-brief.yaml](templates/product-brief.yaml). Ask the user only for fields they haven't provided. Do NOT demand everything — infer sensibly.

**Required:**
- Product name + 2-3 core features/claims
- Model demographic (age range, vibe)
- Brand mood (1-2 adjectives + color direction)
- Platform (reels/shorts/tiktok → 9:16, or landscape → 16:9)

**Optional (auto-inferred if missing):**
- Product image path — if present, use as `@(img0)` anchor; if not, the Seedream prompt must generate the product from scratch using the feature description
- Color palette hex codes
- Voice/tone
- Reference video URL/file — if present, invoke `analyze-reference-video` first

### Step 2: Pick a series arc

Default: **Hook → Benefit → Demo → Testimonial → CTA** (5 episodes).

Alternative arcs in [series-templates/](series-templates/):
- `skincare-routine-5ep.yaml` — Morning routine arc (cleanse → serum → cream → SPF → glow)
- `makeup-tutorial-5ep.yaml` — Transformation arc (bare → prep → apply → finish → reveal)
- `premium-launch-5ep.yaml` — Dramatic unveil arc (void → ingredient story → texture → ritual → worn)

Read the chosen template, adapt beats to the user's product.

### Step 3: Apply the reference-video style (if provided)

If `analyze-reference-video` produced `reference-style.md`, read it. Apply its:
- **Structural patterns** (beat count, pacing, camera choices, edit style) to ALL 5 episodes
- **Tone/voice patterns** to dialogue
- **Lighting/technical signature** to the image prompts

Do NOT copy the reference video's specific content — only its style.

### Step 4: Read platform references

Before composing any prompt, read these in order:

1. [references/seedance-2-platform.md](references/seedance-2-platform.md) — Seedance 2.0 rules (prompt length 100-260 words, forbidden words, parameter schema)
2. [references/seedream-image-prompt.md](references/seedream-image-prompt.md) — Seedream 4.5 image prompt structure
3. [references/camera-movements.md](references/camera-movements.md) — 9 camera movement keywords
4. [references/forbidden-words.md](references/forbidden-words.md) — words to NEVER use
5. [references/k-beauty-mood-library.md](references/k-beauty-mood-library.md) — if cosmetics/K-beauty

### Step 5: Build 5 episode pairs

For EACH of the 5 episodes, read the matching [episode-archetypes/](episode-archetypes/) file and produce:

#### 🖼️ Image prompt (Seedream 4.5)

Structure (see `references/seedream-image-prompt.md`):
```
[Subject description] [Scene/setting] [Lighting] [Mood/style] [Composition/camera angle] [Technical quality]
```
- 80-150 words
- Natural language sentences, NOT keyword soup
- Include shot type (close-up / medium / wide)
- Specify lighting direction and color temperature
- Reference brand palette hex or mood adjective
- If product image is provided, describe product EXACTLY matching `@(img0)` appearance

#### 🎬 Video prompt (Seedance 2.0, uses above image as startFrame/referenceImages)

Structure (see `references/seedance-2-platform.md`):
```
Subject + Action + Camera + Style + Constraints
```
- 100-260 words
- One primary camera movement, degree adverbs on action
- Timestamps `[00:00]`, `[00:05]`, `[00:10]` for multi-beat
- 15 seconds default (4-15s range)
- `@(img1)` consistency anchor if product image provided
- Dialogue in quotes if speaking
- NO forbidden words (cinematic, professional, stunning, 8k, studio, perfect)

### Step 6: Cross-episode consistency

Before finalizing, verify across all 5 episodes:

- [ ] **Model consistency** — same age/hair/skin description in every image prompt
- [ ] **Product consistency** — same product description, same `@(img0)` reference
- [ ] **Wardrobe consistency** — same outfit OR thematic wardrobe progression
- [ ] **Setting consistency** — same location OR deliberate location arc
- [ ] **Color palette** — brand hex codes referenced in every image prompt
- [ ] **Voice/tone** — same model, same speaking style, same energy
- [ ] **Visual signature** — lighting style consistent (e.g., all golden hour, all clinical white)

### Step 7: Output format

Present ALL 5 episodes in a single structured document:

```markdown
# 📽️ {Product Name} — 5-Episode Series

**Series arc:** Hook → Benefit → Demo → Testimonial → CTA
**Platform:** Instagram Reels (9:16)
**Total runtime:** ~75s (5 × 15s)

---

## Episode 1 — {Arc Name}: "{Episode Title}"

### 🖼️ Image Prompt (Seedream 4.5)
```
{image prompt, 80-150 words}
```

### 🎬 Video Prompt (Seedance 2.0, uses Image 1 as referenceImages)
```
{video prompt, 100-260 words, 15s, 9:16}
```

### ✅ Episode Checks
- Model/product/wardrobe anchors present
- No forbidden words
- Runtime fits at natural speaking pace

---

## Episode 2 — ... (same format)
## Episode 3 — ...
## Episode 4 — ...
## Episode 5 — ...

---

## 🎞️ Series Production Checklist

1. Generate all 5 images in Seedream first (parallelizable).
2. Review images for model/product consistency across all 5.
3. Upload each image as Seedance 2.0 `referenceImages`.
4. Generate all 5 videos (i2v mode).
5. Stitch for opus-version reveal:
   ```bash
   printf "file '%s'\n" ep1.mp4 ep2.mp4 ep3.mp4 ep4.mp4 ep5.mp4 > list.txt
   ffmpeg -f concat -safe 0 -i list.txt -c copy series.mp4
   ```
```

### Step 8: Offer next actions

After presenting the kit, ask:
- "Generate test image for Episode 1 first? (approve before mass-producing)"
- "Adjust any episode's tone/camera/beat?"
- "Export as separate .txt files for copy-paste?"

---

## Examples

See [examples/ceraclinic-example-set.md](examples/ceraclinic-example-set.md) — full worked example for a real EVAS cosmetic product.

## Related skills

- [analyze-reference-video](../analyze-reference-video/SKILL.md) — run FIRST if user provides a reference video
- [generate-prompt-pair](../generate-prompt-pair/SKILL.md) — single-pair output when user doesn't need a full series
