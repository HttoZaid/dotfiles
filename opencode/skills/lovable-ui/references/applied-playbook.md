# Applied playbook: from principles to pixels (the anti-slop part)

Read this LAST and read it EVERY time you build. The other references explain *why*; this one stops you from reading the why and shipping slop anyway. Knowing a principle is not applying it.

## The slop defaults to consciously REJECT

AI reaches for these by default. Each one is a tell. Avoid them unless you have a specific reason:

- **Indigo/violet/blue-purple accent on white.** The single most overused "tech" default. Pick a committed accent with intent (warm terracotta, deep forest, ink, a specific brand hue) — and commit to ONE.
- **Pure `#000` / pure `#fff`.** Flat and lifeless. Use a warm or cool near-black (e.g. very dark desaturated blue/brown) and an off-white. The eye reads tinted neutrals as crafted.
- **Center-stacked hero with two equal CTAs** + a generic three-card "features" row below. The canonical slop skeleton. Break it: asymmetry, an editorial list, a single dominant CTA.
- **One sans-serif at three sizes.** No point of view. Pair a display face that has character with a clean body face, or use weight/size/tracking to create real contrast.
- **Uniform gray body text everywhere** with no clear focal point.
- **`rounded-2xl` on everything** at the same radius. Use a radius *system* (e.g. small for inputs, medium for cards, full for pills).
- **Gratuitous gradient mesh** slapped on because it "looks modern." If you use one, bound it and give it a reason.
- **Equal visual weight on everything** — no deference, no hierarchy.

## Concrete starting tokens (so "adopt a system" actually happens)

These are defaults to start from and adjust, not laws:

- **Spacing scale (4px base):** 4, 8, 12, 16, 24, 32, 48, 64, 96, 128. Use it for *everything* — padding, gaps, margins. Consistent spacing is a top fluency/craft signal.
- **Type scale (~1.25 ratio):** 12, 14, 16 (body), 20, 25, 31, 39, 49, 61. Tighten letter-spacing as size grows (display: -0.02 to -0.04em).
- **Line length:** 45–75 characters for body text. **Line height:** ~1.5–1.7 body, ~1.0–1.1 display.
- **Color:** 1 accent + a neutral ramp (off-white → tinted near-black, ~6–10 steps) + semantic (success/warn/error). Near-monochrome reads premium; saturated+many reads playful/cheap.
- **Motion tokens:** fast 150ms / base 250ms / slow 400ms. Ease-out for entrances, ease-in for exits, ease-in-out for moves. `cubic-bezier(0.16,1,0.3,1)` is a good expressive ease-out. Respect `prefers-reduced-motion`.
- **Elevation:** prefer subtle layered shadows (soft, low-opacity, multi-layer) over a single hard drop shadow.

## Worked example: diagnosing and fixing slop

**Slop version (what AI defaults to):**
> Centered hero, indigo→purple gradient headline, two buttons ("Get Started" / "Learn More") side by side, three white cards with generic icons below, Inter everywhere, pure-white background, `shadow-lg rounded-2xl` on the cards.

**Diagnosis (name the lever, don't vibe):**
- *Fluency*: no single focal point — two equal CTAs split attention (violates "one focal point"; Hick's Law).
- *Visceral*: indigo gradient + pure white = the most generic possible first impression; nothing for the 50ms judgment to latch onto.
- *Reflective*: zero point of view — it could be any SaaS; therefore forgettable.
- *Craft*: uniform radius, one font, hard shadow — none of the microdetail that signals care.

**Fix (apply principles):**
- Collapse to ONE primary CTA; demote the second to a quiet text link (restores focal point).
- Asymmetric hero: large display headline left, supporting line in the right margin (editorial, not centered-generic).
- Commit one accent (say, warm ink-blue or terracotta) on a tinted off-white; near-black is warm-desaturated, not `#000`.
- Pair a display face with a point of view + clean body face.
- Replace the three-card row with an editorial list or varied-size tiles (Gestalt grouping by spacing, not boxes).
- Radius system + soft layered shadow + 250ms ease-out hover that lifts 2px and shifts border, not a scale-bounce.
- Add ONE peak: a considered empty/success state or a single tasteful microinteraction.

The difference is never "more decoration." It's hierarchy, restraint, commitment, and a point of view.

## The pre-ship gate

Before returning ANY UI, force-answer these. If you can't answer the last one in a sentence, it's slop:

1. Where is the single focal point, and why does it win?
2. What is the ONE accent, and was it chosen with intent (not defaulted to indigo)?
3. Are neutrals tinted (not pure black/white)?
4. Does whitespace breathe, or is it cramped/edge-to-edge?
5. Does the type have a point of view, or is it one sans at three sizes?
6. Does motion ease (not linear, not gratuitous)?
7. Does every element earn its place? What did you delete?
8. **In one sentence: what does this design SAY / who is it for?** (If "nothing / anyone," start over.)

## When the user gives no constraint

Don't thrash through random variants. Ask for ONE concrete non-brand constraint: an unusual metaphor ("feels like a field notebook / a planetarium / a printed journal"), a hard restriction ("two colors total", "no rounded corners", "mono only"), or a deliberate break ("nav at the bottom", "vertical headlines"). Creativity comes from a sharper constraint, not from removing all of them. Then build from that + first principles.
