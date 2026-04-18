# Style Extraction Guide — Compressing to 15s

Reference videos are often 30-60s (or longer). Seedance 2.0 maxes at 15s per clip, and the user's series is 5 × 15s.

This guide shows how to distill a long reference into a 15-second essence that still carries the style's signature.

---

## The compression method

### Step 1: Identify the "definer beats"

Watch the reference with ALL your frames extracted. Rank every beat by this question:

> **"If I removed this beat, would the style still feel like itself?"**

- **Essential** — removing it breaks the style's identity
- **Supportive** — strengthens but not critical
- **Decorative** — content-specific, doesn't transfer

Count the essentials. Usually 2-3 per 15 seconds of source footage.

---

### Step 2: Map essentials to a 3-beat skeleton

Every 15-second Seedance clip maxes at 3 beats (5s each). So the compressed style needs to fit:

```
Beat 1 (0-5s)  → HOOK (attention, setup)
Beat 2 (5-10s) → CORE (the signature moment)
Beat 3 (10-15s) → KICKER (payoff, resolution)
```

Map the reference's essentials onto this skeleton. If the source has:
- **1 essential** → place in Beat 2, build Beat 1 and Beat 3 from supportive material
- **2 essentials** → one per beat (2 and 3), Beat 1 is hook-style entry
- **3 essentials** → exact 1:1 map
- **4+ essentials** → merge similar ones OR split across multiple clips

---

### Step 3: Dialogue compression

Count the source transcript's word count. Divide by duration. That's the WPM (words per minute) of the reference.

For 15 seconds at ~2.5 words/sec = **37 words max**.

**If reference WPM > 150:** The source is dialogue-dense. Your template needs compressed short lines — 2 spoken beats, 1 silent beat.

**If reference WPM < 100:** The source is contemplative. Your template should emphasize silence — 1 spoken beat, 2 silent beats.

**Typical K-beauty UGC:** 120-180 WPM, fits 2-3 short lines in 15s with a silent beat.

---

### Step 4: Lighting & camera signature

Pick the **ONE** lighting pattern that appears in 80%+ of the reference's beats. That's the style's lighting DNA.

Pick the **ONE** camera movement (or lack of movement) that's most recognizable. That becomes the template's default camera.

Other lighting/camera choices become "alternatives" noted in the template for variation across the 5 episodes.

---

## Multi-clip strategy for longer sources

If the source video is 60+ seconds and feels like it needs more than 15s to capture, the style is **multi-clip** by nature. This is good — it maps directly to a 5-episode series.

### How to split a long reference into 5 episode styles:

| Source timeframe | → Maps to |
|------------------|-----------|
| First 10-20% | Episode 1 (Hook) |
| Next 20% | Episode 2 (Benefit) |
| Middle 20-30% (demo/peak) | Episode 3 (Demo) |
| Next 20% | Episode 4 (Testimonial) |
| Last 10-20% | Episode 5 (CTA) |

Within each segment, identify the 2-3 essential beats. Those become that episode's template.

---

## What the compressed template should document

In `reference-style.md`, compress to:

```markdown
## 15-second compression plan

**Essential beats (map to 3-beat skeleton):**
- Beat 1 (0-5s, HOOK): {transferable essence of reference's opening}
- Beat 2 (5-10s, CORE): {the ONE signature moment that defines this style}
- Beat 3 (10-15s, KICKER): {transferable essence of reference's close}

**Dialogue cap:** {N} words total, mapped to {M} spoken beats and {K} silent beats

**Single defining visual:** {the one shot this style MUST have — e.g., "extreme macro of product meeting skin with single light highlight"}

**Recommended camera per beat:**
- Beat 1: {movement}
- Beat 2: {movement}
- Beat 3: {movement}

**Lighting DNA (applies to all beats):** {the 80%+ consistent lighting pattern}

**Style anchor word:** {one of: documentary / photorealistic / editorial / handheld / dramatic}
```

---

## Episode arc adaptation table

Document how the style's 3-beat skeleton adapts to each of the 5 episode archetypes:

```markdown
## Recommended adaptation for 5-episode series

| Episode | Beat 1 (0-5s) | Beat 2 (5-10s) | Beat 3 (10-15s) |
|---------|---------------|-----------------|------------------|
| 1. Hook | Style's hook essence + pattern interrupt | — | Product tease |
| 2. Benefit | Quick context | Signature visual + benefit | Credibility anchor |
| 3. Demo | Approach | CORE signature moment | Sensory finish |
| 4. Testimonial | Setup | Style's emotional peak | Result / smile |
| 5. CTA | Callback to Ep1 | Product hero | Spoken CTA |
```

---

## Validation test

Before handing off `reference-style.md` to `product-series-kit`:

- [ ] The template is product-agnostic (no reference to the source video's specific product/person)
- [ ] 3-beat skeleton is defined with clear beat lengths
- [ ] Dialogue word cap is specified
- [ ] Single defining visual is named
- [ ] Camera and lighting DNA are documented
- [ ] Style anchor word picked (1 of 5 allowed)
- [ ] Can a different product/person/setting be swapped in without breaking the style?

If any fail, re-compress.

---

## Example (hypothetical — K-drama-inspired beauty reel)

**Source:** 45s Instagram Reel, K-drama aesthetic, dramatic lighting, voice-over

**After compression:**

```markdown
Style: K-Drama-Inspired Clinical Reveal

3-beat skeleton:
- Beat 1 (0-5s, HOOK): Extreme close-up of eye/cheek with soft backlight, voice-over starts ("They say...")
- Beat 2 (5-10s, CORE): SIGNATURE — slow orbit around product on a dark marble surface with single warm side rim light (this is THE shot)
- Beat 3 (10-15s, KICKER): Pull-back to model in soft window light, small knowing smile, one spoken line

Dialogue cap: 24 words total (1 voice-over beat, 1 spoken beat, 1 silent beat)

Single defining visual: slow orbit around product, dark backdrop, single warm side rim light

Recommended camera per beat:
- Beat 1: extreme close-up, static or micro push-in
- Beat 2: slow orbit, gimbal-smooth
- Beat 3: slow pull-back to medium shot

Lighting DNA: single warm side rim light against dark-to-neutral backdrop — appears in every beat

Style anchor: editorial
```

This compression is now ready to feed into `product-series-kit` as the style guide for all 5 episodes.
