# Curated Prompts — UGC Selfie Style

Authentic, phone-filmed, friend-to-friend energy. The 9-layer UGC formula applied to K-beauty product content.

---

## The 9-layer UGC formula

Every UGC video prompt has 9 layers in order:

```
 1. FORMAT HEADER     — duration, style, device, lighting, angle
 2. PERSON            — appearance, skin texture, clothing
 3. SETTING           — lived-in environment with 3 specific clutter details
 4. PRODUCT INTRO     — how they hold/show the product
 5. SCRIPT BEATS      — jump-cut scenes with dialogue + action
 6. TONE DIRECTION    — personality, pacing, energy
 7. EDIT STYLE        — jump cuts, angle variation
 8. TECHNICAL FLAWS   — phone-quality imperfection
 9. VIBE STATEMENT    — one-sentence emotional anchor
```

Skip any layer and UGC output falls apart.

---

## Complete UGC template (K-beauty)

```
15 seconds UGC style {{CONTENT_TYPE}} video, filmed on smartphone,
{{LIGHTING_SOURCE}}, {{CAMERA_ANGLE}}. A {{AGE_RANGE}} Korean {{GENDER}} with
{{HAIR}}, {{SKIN_TEXTURE}}, wearing {{CLOTHING}}, in {{THEIR_SPACE}} —
{{CLUTTER_1}}, {{CLUTTER_2}}, {{CLUTTER_3}}, {{ATMOSPHERE}} and real. She holds
@(img1) ({{PRODUCT_DESCRIPTION}}) {{PRODUCT_INTRO_STYLE}}.

The video opens with her {{HOOK_ACTION}}: "{{HOOK_LINE}}"

Quick jump cut — {{BEAT_2_FRAMING}}, {{BEAT_2_ACTION}}: "{{BEAT_2_DIALOGUE}}"

Jump cut — {{BEAT_3_FRAMING}}, {{BEAT_3_ACTION}}.

Jump cut — {{BEAT_4_FRAMING}}, {{BEAT_4_ACTION}}: "{{BEAT_4_DIALOGUE}}"
{{CLOSING_ACTION}}.

Throughout the video, the tone is {{TONE_EMOTIONS}} — {{TONE_BEHAVIOR}}. The
pacing is unhurried — she pauses between lines, takes natural breaths. Each
jump cut is slightly closer or at a different angle, as if she filmed multiple
takes and edited the best bits together.

The lighting is {{LIGHT_TYPE}} — no ring light, no filters. The image is
slightly imperfect — natural phone quality, not color graded, auto white
balance shift between cuts. The sound is direct from the phone mic — room
ambience, her natural voice, no music underneath.

The overall feel is {{VIBE_ADJECTIVES}} — {{RELATABLE_METAPHOR}}.
```

---

## Variable banks for K-beauty

### Content type
- `skincare routine`, `honest review`, `morning routine`, `first impression`, `got-ready-with-me`, `haul unboxing`, `day in my life`

### Lighting source
- `natural bedroom window light`, `bathroom vanity mirror light`, `golden hour balcony light`, `overhead kitchen light`, `car dashboard light`
- Avoid `studio light` (forbidden word)

### Camera angle
- `casual handheld selfie angle`
- `phone propped on bathroom counter`
- `phone leaned against a stack of books`
- `mirror-selfie angle, phone in hand`

### Korean model descriptors
- `a late 20s Korean woman with glossy dark brown hair pulled into a messy low bun`
- `a 30-year-old Korean woman with long straight dark hair, soft front bangs`
- `a 22-year-old Korean woman with shoulder-length wavy hair, half-up with claw clip`

### Skin texture (always 2-3 cues)
- `natural skin texture with visible pores across nose and cheeks`
- `light freckles, warm undertone, slight undereye softness`
- `soft dewy finish with natural oil on the T-zone`
- ❌ NEVER: `flawless`, `porcelain`, `airbrushed`

### Setting with 3 clutter details
- **Bedroom:** `fairy lights on the headboard, books stacked on the bedside, a cardigan draped over the chair`
- **Bathroom:** `foggy mirror edge, toothbrush in ceramic holder, folded towel on counter`
- **Kitchen:** `coffee mug half-full, cutting board with a banana peel, morning light through blinds`
- **Vanity:** `makeup brushes in a cup, fairy lights strung around the mirror, a half-open palette`

### Dialogue patterns (Korean UGC)
- Hook: `"와... 이거 진짜 봐봐요."` / `"오늘은 제가 2주 동안 써본 거 얘기할 거예요."` / `"솔직히, 이게 제일 신기해요."`
- Beat 2: `"텍스처가 진짜... 완전 다르네요."` / `"흡수 속도 미쳤어요."` / `"향이 진짜 좋아요, 그냥 맡아봐요."`
- Beat 4 (verdict): `"아 근데, 저 이거 계속 쓸 거 같아요."` / `"링크 프로필에 있어요, 꼭 써봐."` / `"저는 진심이에요, 진짜 추천해요."`

### Tone emotions (pick 3)
- `excited fan`: `genuine, excited, breathless — she talks with energy but pauses between thoughts, uses natural breaths`
- `chill recommender`: `relaxed, honest, conversational — she speaks slowly, leaves beats of silence between lines`
- `skeptic converted`: `surprised, impressed, almost reluctant — she raises her eyebrows, pauses mid-sentence`
- `best friend sharing`: `warm, conspiratorial, intimate — she lowers her voice, leans in`
- `morning routine casual`: `sleepy, soft, unhurried — she moves slowly, long pauses`

### Vibe statement metaphors
- `trustworthy, relatable, real — a friend telling you about something she genuinely likes`
- `chaotic, genuine, fun — like a voice memo she sent to her group chat`
- `calm, honest, intimate — like overhearing someone's morning routine`
- `excited, breathless, contagious — like she just discovered something`

---

## Applied to 5-episode series

UGC works beautifully as a series. Each episode is one 15s clip with:
- Ep1 (Hook): `excited fan` tone, bold opener
- Ep2 (Benefit): `chill recommender` tone, ingredient talk
- Ep3 (Demo): mostly silent, ASMR application
- Ep4 (Testimonial): `skeptic converted` or `best friend sharing`, natural result talk
- Ep5 (CTA): clean close, `trustworthy, relatable` vibe

Keep same model, same setting, vary wardrobe slightly to signal days/routine progression.

---

## Source

Adapted from the 9-layer UGC formula in [krusemediallc/arcads-claude-code](https://github.com/krusemediallc/arcads-claude-code) — the arcads `seedance-2-ugc.md` template. Localized for K-beauty Korean-language dialogue and K-model descriptors.
