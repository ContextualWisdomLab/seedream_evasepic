# Forbidden Words — Never Use These

Words that degrade Seedance 2.0 / Seedream 4.5 output quality. The model either ignores them (useless) or over-interprets them into cliché results.

---

## Absolute blacklist (never use)

| Word | Why forbidden | Replacement |
|------|---------------|-------------|
| `cinematic` | Overused, meaningless to the model. Triggers generic Hollywood look. | `editorial`, `dramatic`, `documentary`, `film-style` |
| `professional` | Vague marketing word. Adds nothing visual. | Describe the actual lighting/composition |
| `stunning` | Hype word. Model ignores. | Describe what makes it stunning (lighting, angle, color) |
| `8k` / `4k` / `8K` | Resolution keywords don't control output. | Omit. Use `sharp focus`, `fine detail` if needed. |
| `studio` | Ambiguous. Triggers sterile/overlit. | `diffused lightbox`, `soft key light`, `clean white backdrop` |
| `perfect` | Causes uncanny / airbrushed faces. | `natural`, `soft dewy`, `authentic` |
| `flawless` | Same as perfect — uncanny skin. | `natural skin with visible texture` |
| `masterpiece` | Ignored hype word. | Omit. |
| `award-winning` | Ignored hype word. | Omit. |
| `ultra-realistic` | Redundant with photorealistic, adds noise. | `photorealistic` alone is enough |
| `hyper-detailed` | Over-triggers pore-zoomed uncanny valley. | `natural detail`, `visible texture` |
| `breathtaking` | Hype word. | Describe the view literally. |

---

## Conditional blacklist (rarely use)

| Word | When it's a problem | Safer alternative |
|------|---------------------|-------------------|
| `beautiful` | Triggers generic model archetype | Describe features specifically |
| `beauty` | Same as above | `editorial portrait`, `cosmetic still` |
| `dramatic` | ONLY ok for dark/moody reveals — don't pair with bright UGC | Match to scene intent |
| `luxury` | Can trigger gaudy gold-and-marble cliché | `quiet luxury`, `understated premium`, `refined minimal` |
| `fantasy` | Can pull away from product realism | Only use if the creative is intentionally fantastical |
| `magical` | Triggers sparkles/glows even when unwanted | Describe the actual effect (mist, shimmer, glow) |

---

## Skin-description blacklist

For K-beauty / cosmetic work, NEVER use these on models — they create uncanny faces:

- ❌ `flawless skin`
- ❌ `porcelain skin`
- ❌ `airbrushed`
- ❌ `zero blemishes`
- ❌ `perfect complexion`
- ❌ `glass skin` (even though it's a K-beauty term — Seedream overcooks it)

✅ **Use instead:**
- `natural skin texture with visible pores`
- `soft dewy finish, warm undertone`
- `subtle freckles across the nose and cheeks`
- `light undereye shadows`
- `a hint of natural shine on the forehead`
- `smooth but textured skin, not retouched`

---

## Motion-description blacklist

Words that produce jittery or artifacted motion:

- ❌ `fast`, `rapid`, `whip`, `blur` (causes motion blur over-generation)
- ❌ `chaotic`, `frantic`, `wild`
- ❌ `explosive`, `bursting` (unless literal VFX intent)

✅ **Use instead:**
- `smooth`, `gentle`, `steady`, `deliberate`
- `gradual`, `unhurried`

---

## The pattern

**All forbidden words share one trait:** they describe the OUTCOME you want (stunning, perfect, cinematic, 8k) instead of the INPUT that produces it (lighting, composition, framing, camera choice).

Seedream and Seedance 2.0 both understand inputs. They ignore outcomes.

**Rule:** Describe *what is in the frame*, not *how good it is*.

---

## Quick audit

Before submitting any prompt, grep (mentally) for these words. If any appear, rewrite that clause to describe the visual input instead.

```
grep -i -E "cinematic|professional|stunning|8k|studio|perfect|flawless|masterpiece|award-winning" prompt.txt
```

If any match → rewrite.
