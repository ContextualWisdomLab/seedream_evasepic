# Seedream 4.5 — Image Prompt Reference

Seedream 4.5 is ByteDance's image generation model (sibling of Seedance 2.0 video). Use it to create the **hero still frame** that feeds into Seedance 2.0 as `referenceImages`.

Access via: Dreamina, fal.ai, WaveSpeed, Segmind, ModelArk (BytePlus).

---

## What makes Seedream different

Unlike keyword-stuffed Midjourney prompts, **Seedream 4.5 prefers grammatical English sentences** that read like a scene description to a human director.

- ✅ "A young woman holds a ceramide ampoule bottle up to warm afternoon window light, her fingers gently rotating it so the label catches the glow."
- ❌ "woman, ampoule, warm light, rotating, morning, cosmetic, cinematic, 8k, masterpiece"

Prompts are understood better in natural language than tag soup.

---

## The 6-part structure

```
[Subject] [Scene/Setting] [Lighting] [Mood/Style] [Composition/Camera angle] [Technical quality]
```

### 1. Subject (who/what)
The hero element. For product marketing, this is either:
- Model + product combo: "a 30s Korean woman cradling a frosted glass ampoule"
- Product-only hero: "a frosted glass ampoule bottle on a matte stone surface"

**K-beauty model guidance:**
- Age range (`20대 후반`, `late 20s`, `early 30s`)
- Skin notes (natural texture, soft dewy finish, subtle freckles — NOT "flawless")
- Hair (`glossy dark brown, loose ponytail`, `softly tied back`)
- Clothing (`beige minimalist top`, `ivory robe`, `soft-knit cardigan`)

### 2. Scene/Setting
The environment. Be specific about 2-3 objects that anchor the space:
- `minimalist bathroom vanity with marble counter and folded white towels`
- `airy bedroom with linen curtains, ceramic mug, morning sunlight through slatted blinds`
- `clinical lab corner with white ceramic dish and glass dropper set on a soft grey cloth`

### 3. Lighting (highest-impact element)
**Lighting is the single biggest quality lever.** Never skip.

| Mood | Lighting language |
|------|-------------------|
| Clinical / clean | `soft diffused lightbox, even overhead key, no harsh shadows` |
| Natural / UGC | `morning window light, soft side-fill, warm glow on skin` |
| Premium / hero | `dramatic side rim light against dark backdrop, glowing product edge` |
| Golden hour | `warm low-angle sunlight, amber tones on skin, long soft shadows` |
| Editorial | `single overhead beauty dish, cool white fill, catchlight in the eyes` |

### 4. Mood / Style
One or two adjectives + visual references:
- `editorial minimalism`, `quiet luxury`, `clean clinical`, `warm candid`, `soft dreamy`, `bold high-fashion`, `raw documentary`

For brand consistency, include hex palette: `warm neutral tones (#F8F4EF, #D4C5B2), muted rose accents (#E8C5B9)`.

### 5. Composition / Camera angle
How the frame is built. This directly maps to Seedance's starting frame.

| Intent | Composition |
|--------|-------------|
| Hero product | `product centered in frame, rule-of-thirds label alignment, shallow depth of field` |
| Hand-and-product | `hands entering from right edge holding product, leading lines toward label` |
| Model-with-product | `medium close-up, model's face and hands visible, product held at chest height` |
| Extreme macro | `extreme close-up of product texture, single droplet on skin, macro lens` |
| Wide lifestyle | `wide shot of model in setting, product visible on counter in foreground` |

### 6. Technical quality
End with 1-2 technical anchors:
- `photographed on a medium-format camera, 80mm lens, f/2.8, natural color grade`
- `shot on 35mm film, fine grain, slight warm cast, editorial retouch`
- `phone camera, natural auto white balance, unfiltered, authentic`

**DO NOT use:** `8k`, `4k`, `masterpiece`, `award-winning`, `cinematic`, `stunning` — Seedream ignores hype words.

---

## Prompt length

- **Sweet spot: 80–150 words**
- Under 60 → too vague
- Over 180 → model loses detail priority

---

## K-beauty / cosmetic-specific tips

### Texture rendering
For cream/serum/liquid products, describe the physical state:
- `light creamy texture pooling into a glass droplet`
- `translucent jelly-like serum catching window highlights`
- `fine mist settling in golden backlight`

### Label legibility
Seedream sometimes garbles text. Two approaches:
- **Hide it**: `label facing away from camera` or `backlit silhouette with label not visible`
- **Emphasize it**: `brand wordmark clearly centered, in quotes: "CERACLINIC"` — Seedream honors quoted text better

### Model skin realism
K-beauty images need **dewy but textured** skin. Prompt:
- `natural skin texture with visible pores and subtle highlights, not airbrushed`
- `soft dewy finish with natural freckles, warm undertone`

Never use: `flawless`, `porcelain-perfect`, `zero texture`. These make the model look uncanny.

---

## Negative prompting

Seedream 4.5 has **limited negative prompt support**. Instead of "no blur", describe the positive version:
- ❌ `no blur` → ✅ `tack sharp focus on label`
- ❌ `no extra hands` → ✅ `exactly two hands visible, five fingers each`

---

## Consistency for series work

When generating 5 images for the same product series, include an identity line in EVERY prompt:

```
Model consistency: same 30s Korean woman with glossy dark brown hair in soft low ponytail,
natural dewy skin with light freckles across the nose, warm undertone.

Product consistency: same frosted glass 30ml ampoule bottle with matte gold dropper cap,
minimalist white label with "CERACLINIC" wordmark.
```

Paste these two blocks into every Episode's image prompt. They drift without repetition.

---

## Example prompt (full 6-part)

```
A 30-something Korean woman with glossy dark brown hair pulled back in a soft low
ponytail holds a frosted glass 30ml ampoule bottle with a matte gold dropper cap
(minimalist white label, "CERACLINIC" wordmark centered). She stands in a minimalist
bathroom with a marble counter and folded white towels to her right, morning window
light pouring in from the left with soft side-fill on her cheek and warm glow along
the bottle's curve. The mood is clean clinical minimalism with quiet-luxury warmth —
tones of #F8F4EF ivory and #D4C5B2 soft sand dominate. Medium close-up composition,
rule-of-thirds with product label aligned on the right vertical, shallow depth of
field with blurred tile texture behind. Photographed on a medium-format camera with
an 80mm lens at f/2.8, natural color grade, no filter, subtle film grain. Model has
natural skin texture with visible pores, soft dewy finish, light freckles across the
nose — not airbrushed.
```

~150 words. Covers all 6 parts. Ready for Seedance 2.0 to animate.

---

## Official resources

- [ByteDance ModelArk — Seedream 4.5 official prompt guide](https://docs.byteplus.com/en/docs/ModelArk/1829186)
- [fal.ai Seedream 4.5 prompt guide](https://fal.ai/learn/devs/seedream-v4-5-prompt-guide)
- [Atlabs AI Seedream 4.0 ultimate prompting guide](https://www.atlabs.ai/blog/seedream4o-prompting-guide)
