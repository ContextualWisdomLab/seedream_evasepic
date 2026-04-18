# Video Prompt Template — Seedance 2.0

Fill in the `{{VARIABLES}}` to produce a Seedance 2.0 video prompt that animates the Seedream 4.5 starting frame.

**Critical:** 100-260 words. 4-15 seconds. 9:16 or 16:9. NO forbidden words.

---

## The 5-part scaffold

```
{{SUBJECT_BLOCK}} {{ACTION_BLOCK}} {{CAMERA_BLOCK}} {{STYLE_BLOCK}} {{CONSTRAINTS_BLOCK}}
```

---

## Block 1: Subject (match the Seedream image)

```
A {{MODEL_DESCRIPTION_MATCHING_IMAGE}} in {{SETTING_MATCHING_IMAGE}}, {{INITIAL_POSE}}
holding @(img1) ({{PRODUCT_DESCRIPTION}}).
```

**Must match the image prompt's subject and scene.** The video animates FROM this still, so the opening frame must be described identically.

Include the `@(img1)` token to reference the uploaded image.

---

## Block 2: Action (timestamped beats)

**For single-beat (5s clip):**
```
She {{SLOW_ADVERB}} {{PRIMARY_ACTION}}, {{SECONDARY_DETAIL}}.
```

**For multi-beat (10-15s clip) — use timestamps:**
```
[00:00] {{BEAT_1_ACTION}}. {{BEAT_1_FRAMING}}.
[00:05] {{BEAT_2_ACTION}}. {{BEAT_2_FRAMING}}.
[00:10] {{BEAT_3_ACTION}}. {{BEAT_3_FRAMING}}.
```

**Action rules:**
- Present tense, ONE primary motion per beat
- Include degree adverbs: `slowly`, `gently`, `deliberately`, `steadily`, `quietly`
- Each beat = ONE framing change
- At least one silent beat per clip (no dialogue)

**If dialogue:** Insert as:
```
She speaks: "{{LINE}}"
```
Fits 15s at ~2.5 words/sec = ~30-35 words total across the clip.

---

## Block 3: Camera (exactly ONE primary movement)

```
Camera: {{SPEED}} {{MOVEMENT}} {{DIRECTION}}, {{SHOT_TYPE}}, {{STABILITY}}.
```

**Pick ONE:**
- `slow dolly-in` — tension builds toward product
- `gentle pan right` — reveals wider scene
- `subtle tilt down` — follows a motion vertically
- `steady orbit around product` — 180° reveal
- `handheld selfie angle, natural shake` — UGC authenticity
- `static shot, tripod-locked` — clean hero
- `slow crane up from product to model's face` — emotional lift

**Speed:** `slow`, `smooth`, `gentle`, `steady`, `subtle`.

**Shot type:** `close-up`, `medium close-up`, `medium shot`, `wide shot`, `extreme close-up`.

**Stability:** `tripod-locked`, `gimbal-smooth`, `steadicam`, `handheld natural shake`.

---

## Block 4: Style

```
{{LIGHTING_MATCHING_IMAGE}}. {{STYLE_ANCHOR}} {{MOOD_DESCRIPTOR}}.
```

**Style anchor (pick ONE):**
- `documentary`
- `photorealistic`
- `editorial`
- `handheld`
- `commercial` (use sparingly)
- `dramatic` (for premium only)

**Mood descriptor:** describe the energy in 2-3 adjectives — `warm and quiet`, `restrained and precise`, `intimate and meditative`, `bright and candid`.

**Lighting:** MUST match the Seedream image's lighting description verbatim (model can't infer lighting from motion).

---

## Block 5: Constraints (anti-artifact guards)

```
The product from @(img1) must remain visually unchanged in every shot — same bottle
shape, same label, same cap. Maintain the model's face, hair, and wardrobe unchanged
across all beats. Steady motion, no distortion, no warping of hands or fingers.
{{ADDITIONAL_CONSTRAINT}}
```

**Common additional constraints:**
- `No text overlays, no watermarks, no subtitles.`
- `Exactly two hands visible with five fingers each.`
- `Hair movement is subtle and natural — no exaggerated blow.`
- `Product label text remains crisp and readable throughout.`
- `Lighting direction stays consistent from first to last frame.`

---

## Complete example (CERACLINIC Episode 1 — Hook, animates the image template example)

```
A 30s Korean woman with glossy dark brown hair in a soft low ponytail, natural skin
texture with light freckles, wearing an ivory silk shirt, standing in a minimalist
bathroom with a marble counter. She holds @(img1) (a frosted glass 30ml ampoule bottle
with matte gold dropper cap, minimalist white label "CERACLINIC") near chest height.

[00:00] She looks at the camera with calm confident eyes, gently rotating the bottle
so the label faces forward. Medium close-up.

[00:05] She slowly brings the bottle closer to her face, tilting it toward the light,
eyes tracking the dropper. Camera holds steady on her hands and face.

[00:10] She speaks: "속당김 이제 진짜 끝났어요." A subtle smile. She lowers the bottle
gently, label still visible to camera.

Camera: slow dolly-in, medium close-up, tripod-locked. Soft diffused overhead lightbox,
even fill with no harsh shadows, cool-neutral 5600K color temperature, gentle
highlight along the bottle curve throughout.

Documentary, warm and quiet. The product from @(img1) must remain visually unchanged
in every shot — same bottle shape, same label, same cap. Maintain the model's face,
hair, and ivory silk shirt unchanged across all beats. Steady motion, no distortion,
no warping of hands. Product label text remains crisp and readable throughout. No
overlays, no watermarks, no subtitles.
```

~185 words. 15s. 9:16. 3 beats with timestamps. ONE camera movement (slow dolly-in). Lighting matches image. Consistency anchors present. No forbidden words.

---

## Quick checklist

- [ ] 100-260 words
- [ ] Subject matches the Seedream image exactly
- [ ] `@(img1)` token included
- [ ] 4-15 seconds (integer)
- [ ] 9:16 (reels/shorts/tiktok) or 16:9 (landscape)
- [ ] ONE primary camera movement only
- [ ] Shot type specified
- [ ] Lighting description matches image
- [ ] Degree adverbs on all actions (slowly, gently, steadily)
- [ ] Timestamps if 2+ beats
- [ ] Dialogue (if any) fits runtime at natural 2.5 words/sec pace
- [ ] At least one silent beat
- [ ] Consistency anchors for product AND model
- [ ] No forbidden words (cinematic, professional, stunning, 8k, studio, perfect, flawless)

---

## API usage (Seedance 2.0 via Dreamina / fal.ai / etc.)

Upload the Seedream image first, then submit:

```json
{
  "model": "seedance-2.0",
  "prompt": "<video prompt above>",
  "aspectRatio": "9:16",
  "duration": 15,
  "resolution": "720p",
  "audioEnabled": true,
  "referenceImages": ["<uploaded-image-filePath>"]
}
```

Poll `GET /v1/assets/{id}` until `status: "generated"`.
