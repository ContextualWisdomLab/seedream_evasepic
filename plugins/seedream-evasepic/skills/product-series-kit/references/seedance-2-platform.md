# Seedance 2.0 — Platform Reference

Everything you need to know to write a Seedance 2.0 prompt that actually works. Distilled from ByteDance's official prompt guide + community learnings.

---

## Model overview

**Seedance 2.0** is ByteDance's flagship video generation model.

- Text-to-video, Image-to-video (i2v), Video-to-video (v2v), Audio-driven
- Up to **1080p**, **4–15 seconds** per clip (continuous, not enum)
- Auto dubbing + background music
- Supports simultaneous quad-modal input: image + video + audio + text
- Native multi-shot narrative in a single prompt

**Platforms to use it:** Dreamina (ByteDance), fal.ai, WaveSpeed AI, Segmind, Replicate.

---

## Prompt structure — the 5-part formula

Seedance 2.0 responds best to this ORDER:

```
Subject + Action + Camera + Style + Constraints
```

1. **Subject** — who/what is in the scene (person description, product, setting)
2. **Action** — what happens (present tense, one primary motion per shot)
3. **Camera** — framing (wide/medium/close-up) + one movement (dolly/pan/tracking)
4. **Style** — lighting, color grading, atmosphere (NOT "cinematic")
5. **Constraints** — anti-artifact guards ("maintain face consistency", "no distortion")

Keep it as **ONE clear paragraph**, not a pile of keywords.

---

## Prompt length

**Sweet spot: 100–260 words.**

- Under 100 → vague results, model makes things up
- Over 260 → model loses focus on key details
- 150–200 → usually the best tradeoff

---

## API parameters (CreateVideoDto)

| Field | Required | Value / Range | Notes |
|-------|----------|---------------|-------|
| `model` | yes | `"seedance-2.0"` | |
| `prompt` | yes | string | 100–260 words |
| `aspectRatio` | no | `"9:16"`, `"16:9"` | NO `1:1` support |
| `duration` | no | 4–15 (integer seconds) | Continuous range. Default 15 for no-dialogue. |
| `resolution` | no | `"480p"`, `"720p"`, `"1080p"` | Default `720p` |
| `referenceImages` | no | array of `filePath` (max 3) | i2v mode |
| `referenceVideos` | no | array of `filePath` (max 1 in practice) | v2v mode — mutually exclusive with referenceImages |
| `referenceAudios` | no | array of `filePath` (max 3) | Can combine with image OR video |
| `audioEnabled` | no | boolean | Enables dialogue/music |

**Not supported on Seedance 2.0:** `startFrame`, `endFrame`, negative prompts (`--no blur` syntax).

**Mutually exclusive:** `referenceImages` + `referenceVideos` in the same call returns 500.

---

## FORBIDDEN words (absolute)

Never use these in a Seedance 2.0 prompt:

- ❌ `cinematic`
- ❌ `professional`
- ❌ `stunning`
- ❌ `8k` (or any resolution keyword)
- ❌ `studio`
- ❌ `perfect`

For premium/dramatic looks, use instead: `dramatic`, `premium`, `editorial`, `high-fashion`, `moody`, `luminous`.

---

## Be explicit about motion

The model can't guess intensity from a still. Spell it out with **degree adverbs**:

| Vague | Specific |
|-------|----------|
| "she picks up the bottle" | "she slowly picks up the bottle with her right hand, turning it toward the camera" |
| "the camera moves" | "slow dolly-in over 3 seconds" |
| "wind blows" | "a gentle breeze lifts stray hairs by her ear" |

**Degree adverb bank:** slowly, gently, quickly, casually, deliberately, smoothly, abruptly, softly, tenderly, confidently.

---

## Timestamps for multi-beat sequences

For 2+ beats in a single clip, use timestamps to control pacing:

```
[00:00] A woman stands in a warm-lit bathroom holding the ampoule bottle. Medium shot. Soft backlight.
[00:05] She unscrews the cap, close-up of the dropper emerging. Slow tilt down.
[00:10] She presses the dropper onto the back of her hand, watches the serum pool. Extreme close-up.
```

**Rules:**
- Max 3 beats for 15s (5s each)
- Each beat = ONE primary action
- Include camera framing change per beat

---

## Reference image consistency

When using `@(img1)` / `@(img2)` / `@(img3)` product images, add consistency anchors:

- "The product from @(img1) must remain visually unchanged in every shot."
- "Maintain product label design and bottle color throughout."
- "Keep the model's face, hair, and wardrobe unchanged across all cuts."

Without these, the product drifts subtly between shots.

---

## Camera movements (9 supported)

| Type | Keywords |
|------|----------|
| Dolly | `dolly in`, `dolly out`, `push in`, `pull back` |
| Pan | `pan left`, `pan right` |
| Tracking | `tracking shot`, `follow`, `sidearm` |
| Orbit | `orbit around`, `circling camera` |
| Crane | `crane up`, `crane down` |
| Zoom | `zoom in`, `zoom out` |
| Tilt | `tilt up`, `tilt down` |
| Static | `static shot`, `locked camera`, `tripod` |
| Handheld | `handheld`, `gimbal`, `steadicam` |

**RULE: Use exactly ONE primary camera movement per clip.** Combining multiple causes mushy, unstable output.

**Speed words:** `slow`, `smooth`, `gentle`, `steady` (good) — `fast`, `rapid`, `whip` (often degrade quality).

**Shot type (the single most impactful addition):** `close-up`, `extreme close-up`, `medium shot`, `wide shot`, `over-the-shoulder`, `top-down`.

See `camera-movements.md` for the full cheat sheet.

---

## Style anchors (always include ONE)

Pick from:
- `documentary` — natural, observational
- `photorealistic` — grounded, no stylization
- `editorial` — polished but restrained
- `handheld` — phone-filmed feel
- `commercial` — polished (use sparingly for UGC)
- `dramatic` — for premium/hero reveals (replaces "cinematic")

---

## Lighting is the #1 quality lever

Among all prompt elements, **lighting description has the biggest visible impact**. Always include at least one line about light.

| Style | Lighting keywords |
|-------|-------------------|
| Natural/UGC | `soft window light`, `morning sunlight through blinds`, `natural bedroom lighting` |
| Clinical | `even diffused white light`, `clinical lightbox`, `soft overhead key` |
| Premium/moody | `dramatic rim light`, `warm side backlight`, `low-key single practical` |
| K-beauty clean | `luminous soft box`, `high-key clean white`, `diffused beauty light` |
| Golden hour | `warm golden hour backlight`, `late afternoon side light`, `amber fill` |

---

## Dialogue & duration

Natural speaking pace: **~2.5 words/second** (~150 WPM).

| Script length | Duration |
|---------------|----------|
| 1–8 words | 4–5s |
| 9–15 words | 6–8s |
| 16–25 words | 9–12s |
| 26–35 words | 13–15s |
| 36+ words | Split into multiple clips |

Embed dialogue in prompt using: `She speaks: "text here"` or `He says: "line."`

ALWAYS read dialogue out loud at natural pace before finalizing — if you rush, cut words.

---

## Adaptation checklist (run before submitting)

- [ ] Word count 100–260
- [ ] Subject+Action+Camera+Style+Constraints order
- [ ] ONE primary camera movement
- [ ] ONE style anchor (documentary / photorealistic / editorial etc.)
- [ ] ONE lighting description
- [ ] Shot type specified (close/medium/wide)
- [ ] Degree adverbs on all actions
- [ ] Consistency anchors for product/model
- [ ] No forbidden words (cinematic/professional/stunning/8k/studio/perfect)
- [ ] Timestamps if multi-beat
- [ ] Dialogue fits runtime at natural pace
- [ ] Aspect ratio: 9:16 (vertical) or 16:9 (landscape), not 1:1
- [ ] Duration: 4-15s integer

---

## Official resources

- [ByteDance ModelArk — Seedance 2.0 official prompt guide](https://docs.byteplus.com/en/docs/ModelArk/1631633)
- [fal.ai Seedance docs](https://fal.ai/models/fal-ai/bytedance/seedance/v1/pro)
- [WaveSpeed Seedance guide](https://wavespeed.ai/)
