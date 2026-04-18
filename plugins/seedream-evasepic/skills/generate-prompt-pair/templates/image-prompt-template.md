# Image Prompt Template — Seedream 4.5

Fill in the `{{VARIABLES}}` to produce a Seedream 4.5 image prompt that will serve as the starting frame for a Seedance 2.0 video.

---

## The 6-part scaffold

```
{{SUBJECT_BLOCK}} {{SCENE_BLOCK}} {{LIGHTING_BLOCK}} {{MOOD_STYLE_BLOCK}} {{COMPOSITION_BLOCK}} {{TECHNICAL_BLOCK}}
```

Each block is 1-3 sentences. Total: 80-150 words.

---

## Block 1: Subject

**If model + product:**
```
A {{AGE_RANGE}} {{ETHNICITY}} {{GENDER}} with {{HAIR_DESCRIPTION}}, {{SKIN_TEXTURE}},
wearing {{WARDROBE}}, {{HOLDING_OR_INTERACTING_WITH}} a {{PRODUCT_DESCRIPTION}}.
```

**If product hero (no model):**
```
A {{PRODUCT_DESCRIPTION}} {{POSITIONING}}, {{PRODUCT_DETAIL_1}}, {{PRODUCT_DETAIL_2}}.
```

**Variables:**

| Variable | Options / Example |
|----------|-------------------|
| `AGE_RANGE` | `late 20s`, `30s`, `early 40s`, `mid-20s` |
| `ETHNICITY` | `Korean`, `Asian` (or omit if unspecified) |
| `GENDER` | `woman`, `man` |
| `HAIR_DESCRIPTION` | `glossy dark brown hair in a soft low ponytail`, `short bob with front bangs`, `loose waves tied half-up` |
| `SKIN_TEXTURE` | `natural skin texture with visible pores and a soft dewy finish`, `light freckles across the nose and cheeks`, `warm undertone with subtle undereye softness` |
| `WARDROBE` | `ivory silk shirt`, `oversized cream knit`, `beige linen robe` |
| `HOLDING_OR_INTERACTING_WITH` | `cradling`, `holding up to the light`, `about to press the dropper onto`, `admiring` |
| `PRODUCT_DESCRIPTION` | `frosted glass 30ml ampoule bottle with matte gold dropper cap, minimalist white label with "{{BRAND}}" wordmark` |

---

## Block 2: Scene / Setting

```
She stands in a {{SETTING_TYPE}} with {{DETAIL_1}}, {{DETAIL_2}}, {{DETAIL_3}}.
```

**Setting bank (match brand mood):**

| Mood | Setting + Details |
|------|-------------------|
| Clinical | `minimalist bathroom with marble counter, folded white towels, ceramic tray with dropper dishes` |
| Warm documentary | `cozy bedroom with linen curtains, a ceramic mug on the bedside, morning sunlight through slatted blinds` |
| Editorial premium | `dark-void studio backdrop with a marble plinth and a single pooled spotlight` |
| Bright clean | `bright bedroom vanity with pastel accents, fairy lights in the background, folded pink towel` |
| Ritual spa | `candlelit bathtub corner with amber glass bottles, a rolled linen towel, single pillar candle flickering` |

---

## Block 3: Lighting (HIGHEST-IMPACT — never skip)

```
{{LIGHTING_DESCRIPTION}}
```

**Lighting library:**
- Clinical: `soft diffused overhead lightbox, even fill with no harsh shadows, cool-neutral 5600K color temperature`
- Warm morning: `soft morning window light pouring in from the left, warm side-fill on her cheek, gentle amber glow on the product curve`
- Premium dramatic: `single dramatic side rim light against the dark backdrop, glowing edge on the bottle, low-key ambient fill`
- Golden hour: `warm late-afternoon backlight, amber tones on skin, long soft shadows stretching across the counter`
- Editorial beauty dish: `single overhead beauty dish, cool white fill, visible catchlights in the eyes`

---

## Block 4: Mood / Style

```
The mood is {{MOOD_ADJECTIVES}} — tones of {{HEX_1}} and {{HEX_2}} dominate, {{STYLE_REFERENCE}}.
```

**Mood adjective pairs:**
- `clean clinical minimalism with quiet-luxury warmth`
- `warm candid intimacy with lived-in texture`
- `editorial premium restraint with dramatic contrast`
- `bright playful freshness with youthful energy`
- `serene meditative stillness with amber glow`

Include 2 hex codes from the brand palette — Seedream honors specific color direction.

---

## Block 5: Composition / Camera angle

```
{{SHOT_TYPE}} composition, {{COMPOSITION_RULE}}, {{DEPTH_OF_FIELD}}.
```

**Shot type:** `close-up`, `medium close-up`, `medium shot`, `wide shot`, `extreme close-up`, `over-the-shoulder`, `top-down overhead`, `macro`.

**Composition rule:** `rule-of-thirds with product label on right vertical`, `centered symmetrical composition`, `leading lines from hand to product`, `negative space top-left, subject bottom-right`.

**Depth of field:** `shallow depth of field with blurred background`, `tack sharp throughout`, `medium depth with gentle background softness`.

---

## Block 6: Technical quality

```
Photographed on {{CAMERA}}, {{LENS}}, {{APERTURE}}, {{POST_PROCESSING}}.
```

**Camera:** `medium-format camera`, `35mm film camera`, `phone camera (natural auto white balance)`, `full-frame DSLR`.

**Lens:** `80mm prime`, `50mm prime`, `105mm macro`, `24mm wide`.

**Aperture:** `f/2.8`, `f/4`, `f/1.8` (shallow), `f/8` (deep).

**Post-processing:** `natural color grade, no filter, subtle film grain`, `editorial retouch with warm cast`, `clean commercial grade`.

---

## Assembly example (CERACLINIC Episode 1 — Hook)

```
A 30s Korean woman with glossy dark brown hair in a soft low ponytail, natural skin
texture with visible pores and light freckles across the nose, wearing an ivory silk
shirt, holding a frosted glass 30ml ampoule bottle with a matte gold dropper cap and
minimalist white label ("CERACLINIC" wordmark centered) up toward the camera. She
stands in a minimalist bathroom with marble counter, folded white towels to the right,
and a small ceramic tray of dropper dishes on the left. Soft diffused overhead
lightbox casts even fill with no harsh shadows, cool-neutral 5600K color temperature,
a gentle highlight along the bottle's glass curve. The mood is clean clinical
minimalism with quiet-luxury warmth — tones of #F8F4EF ivory and #D4C5B2 soft sand
dominate. Medium close-up composition, rule-of-thirds with the product label aligned
on the right vertical, shallow depth of field with blurred tile texture behind.
Photographed on a medium-format camera, 80mm prime at f/2.8, natural color grade,
subtle film grain, not retouched.
```

~150 words. All 6 blocks represented. Ready for Seedream 4.5.

---

## Quick checklist

- [ ] 80-150 words
- [ ] All 6 blocks present (Subject, Scene, Lighting, Mood, Composition, Technical)
- [ ] Natural sentences (not keyword soup)
- [ ] Brand palette hex codes included
- [ ] Shot type specified
- [ ] No forbidden words (cinematic, 8k, perfect, flawless, masterpiece)
- [ ] Skin texture described (not "flawless")
- [ ] Model/product identity lines match across series episodes
