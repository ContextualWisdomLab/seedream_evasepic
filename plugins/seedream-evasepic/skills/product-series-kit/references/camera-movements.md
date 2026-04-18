# Camera Movements — Seedance 2.0 Cheat Sheet

Seedance 2.0 supports **9 distinct camera movement types**. Use exactly ONE per clip. Combining causes mushy, unstable output.

---

## The 9 movements

### 1. Dolly (in/out)
Camera physically moves toward or away from subject.
- `slow dolly-in on the product`
- `gentle dolly-out reveals the wider setting`
- `smooth push-in from medium to close-up`
- `steady pull-back from extreme close-up to medium`

**Best for:** Product reveals, emotional reveals, tension building.

### 2. Pan (left/right)
Camera rotates horizontally from a fixed position.
- `slow pan right across the vanity, revealing the product on the counter`
- `gentle pan left following the model's gaze`

**Best for:** Revealing a wider scene, following eye-line.

### 3. Tracking shot
Camera moves parallel to a subject in motion.
- `tracking shot alongside the model as she walks toward the window`
- `side-rail tracking follows the hand carrying the product`

**Best for:** Walking shots, movement-driven scenes.

### 4. Orbit
Camera circles around a fixed subject.
- `slow orbit around the product bottle, 180 degrees over 5 seconds`
- `quarter orbit right revealing the product from multiple angles`

**Best for:** Product hero shots, textured reveals.

### 5. Crane (up/down)
Camera moves vertically through space.
- `slow crane up from the product on the counter to the model's face`
- `gentle crane down from ceiling-level to the vanity`

**Best for:** Scene-establishing moves, emotional lifts.

### 6. Zoom (in/out)
Focal length changes — camera body stationary, lens zooms.
- `subtle zoom in on the product label over 4 seconds`
- `slow zoom out from extreme close-up of texture to full product`

**Best for:** Focus pulls without physical movement.

**Note:** Dolly = physical movement, Zoom = lens only. Dolly feels more natural for cinematic work.

### 7. Tilt (up/down)
Camera pivots vertically from a fixed position.
- `slow tilt up from the product base to the model's face`
- `gentle tilt down following the dropper descending toward the hand`

**Best for:** Vertical reveals, product-to-model transitions.

### 8. Static
Locked-off camera — no movement at all.
- `static shot, tripod-locked, centered on the product`
- `locked camera, model and product fill the frame`

**Best for:** Hero beauty shots, dialogue-focused beats, clean compositions.

### 9. Handheld
Intentional camera shake — phone/gimbal feel.
- `handheld selfie angle, slight natural shake`
- `loose handheld, phone-in-one-hand wobble`
- `gimbal-smooth but with slight breathing motion`

**Best for:** UGC authenticity, documentary feel, in-the-moment energy.

---

## Speed modifiers

ALWAYS pair your movement with a speed word. Affects output quality significantly.

**Good (preserve quality):**
- `slow`
- `smooth`
- `gentle`
- `steady`
- `subtle`

**Risky (can degrade):**
- `fast` ⚠️
- `rapid` ⚠️
- `whip` ⚠️
- `aggressive` ⚠️

**Rule of thumb:** `fast camera + fast cuts + busy scene` = almost always jitter/artifacts.

---

## Stability modifiers

Add to clarify the physical setup:

- `tripod-locked` → no shake at all
- `steadicam` → smooth gliding motion
- `gimbal` → ultra-smooth, slight breathing
- `handheld` → natural shake
- `phone-propped` → UGC style, slight drift

---

## Shot types (pair with movement)

Shot type is the single most impactful thing you can add. Always specify:

| Shot | Framing | Use for |
|------|---------|---------|
| `extreme close-up` | Part of face/product fills frame | Texture, emotion, detail reveal |
| `close-up` | Head-and-shoulders, or full product | Product label, facial expression |
| `medium close-up` | Chest-up | Hand-and-product, conversational |
| `medium shot` | Waist-up | Standing with product, demonstration |
| `wide shot` | Full body + setting | Establishing scene, lifestyle |
| `over-the-shoulder` | Behind model, looking at product | POV-style, intimate |
| `top-down` / `overhead` | Bird's eye | Flat-lay, ingredient shots |
| `macro` | Microscopic detail | Texture, droplet, pore |

---

## Camera prompt template

```
Camera: {SPEED} {MOVEMENT} {DIRECTION}, {SHOT_TYPE}, {STABILITY}.
```

**Examples:**
- `Camera: slow dolly-in, medium close-up, tripod-locked.`
- `Camera: gentle pan right, wide shot, gimbal-smooth.`
- `Camera: subtle handheld, close-up on product, natural phone shake.`

---

## Multi-beat camera strategy

For a 15-second clip with 3 beats, use this structure:

| Beat | Second | Shot | Movement |
|------|--------|------|----------|
| 1 (Hook) | 0-5s | Medium shot | Static or gentle push-in |
| 2 (Demo) | 5-10s | Close-up or extreme close-up | Slow dolly or tilt |
| 3 (Payoff) | 10-15s | Medium or wide | Pull back or hold static |

Always vary shot type per beat. Using the same framing for 15s = flat video.

---

## For the 5-episode series

Assign a different primary movement to each episode for visual variety:

| Episode | Suggested camera |
|---------|------------------|
| 1. Hook | Static medium shot + slow push-in (attention grab) |
| 2. Benefit | Slow pan across setting → land on product |
| 3. Demo | Extreme close-up + tilt down (texture reveal) |
| 4. Testimonial | Handheld medium shot (authentic feel) |
| 5. CTA | Pull-back wide shot (emotional finale) |

Adjust based on product category and series arc.

---

## Sources

- [Seedance 2.0 Camera Movement Cheat Sheet — PromeAI](https://www.promeai.pro/blog/2026/02/11/seedance-2-0-camera-movement-cheat-sheet/)
- [Seedance 2.0 Camera Guide — BigMotion](https://www.bigmotion.ai/user-guide/seedance-2-0-camera-settings-guide)
- [Mastering Cinematic Camera Movement — WenHaoFree](https://blog.wenhaofree.com/en/posts/articles/seedance-2-0-prompt-mastery-guide/)
