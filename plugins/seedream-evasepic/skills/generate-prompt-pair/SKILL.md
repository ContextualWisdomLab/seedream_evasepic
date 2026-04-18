---
name: generate-prompt-pair
description: >-
  Generate a single paired prompt set (one Seedream image prompt + one Seedance 2.0 video prompt where the image is the starting frame). Use when the user wants just ONE video pair, not a full 5-episode series. Useful for quick tests, single-purpose ads, or when iterating on a specific concept. Triggers include "한 편만", "single video", "one prompt pair", "테스트로", "이 컨셉만".
---

# Generate Prompt Pair — One Image + One Video

Single-shot sibling of `product-series-kit`. Produces exactly ONE paired prompt set.

Use this when the user:
- Only needs one video, not a series
- Wants to test a concept before committing to 5 episodes
- Already has 4 episodes done and needs to add a 6th

For full campaigns, use `product-series-kit`.

---

## Inputs

Ask for (or infer from prior context):
- Product name + 1-2 features
- Model demographic
- Brand mood
- Episode intent (hook / benefit / demo / testimonial / CTA / custom)
- Platform (9:16 or 16:9)
- Reference style (optional — from `analyze-reference-video` output)

---

## Workflow

### Step 1: Read platform references

- `../product-series-kit/references/seedance-2-platform.md`
- `../product-series-kit/references/seedream-image-prompt.md`
- `../product-series-kit/references/camera-movements.md`
- `../product-series-kit/references/forbidden-words.md`
- `../product-series-kit/references/k-beauty-mood-library.md` (if cosmetics)

### Step 2: Compose the pair

Use [templates/image-prompt-template.md](templates/image-prompt-template.md) and [templates/video-prompt-template.md](templates/video-prompt-template.md).

### Step 3: Output

```markdown
# 📽️ {Product Name} — {Episode Intent}

## 🖼️ Image Prompt (Seedream 4.5)
```
{image prompt, 80-150 words}
```
**Target platform:** Dreamina / fal.ai / Seedream API
**Aspect:** 9:16 or 16:9
**Resolution:** 1080p recommended

## 🎬 Video Prompt (Seedance 2.0)
```
{video prompt, 100-260 words, 15s, 9:16}
```
**Reference image:** Upload the Seedream output as `referenceImages`
**Duration:** 15s (default)
**Resolution:** 720p (default) or 1080p

## ✅ Checks
- [ ] Model/product consistency anchors present
- [ ] No forbidden words
- [ ] Word count within bounds (image 80-150, video 100-260)
- [ ] Camera: single primary movement only
- [ ] Dialogue fits runtime at natural pace (if speaking)
```

---

## Tip: pair → series upgrade

If after generating a pair the user says "make 4 more like this", hand off to `product-series-kit` and use the current pair as Episode 1 seed.
