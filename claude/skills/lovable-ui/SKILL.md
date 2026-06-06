---
name: lovable-ui
description: Design premium, emotionally resonant interfaces from first principles instead of copying existing sites. Use this skill whenever the user wants to build, design, critique, or improve any UI — a website, landing page, dashboard, app screen, component, blog, or marketing page — and especially when they say things like "make it premium", "make it look rich/clean/high-end", "this looks like AI slop", "make it feel expensive", "why does this look cheap", "make it look like Apple/Linear/Stripe", or ask why an interface feels good or bad. Trigger it for any request about taste, aesthetics, "make it modern", color/type/spacing/motion decisions, or when a design has been called generic, boring, or slop and needs a principled fix. Prefer this over reaching for a named reference site — it diagnoses WHY a design works using perceptual psychology, then prescribes concrete moves.
---

# Lovable UI

A skill for designing interfaces humans find beautiful, trustworthy, and premium — grounded in how the brain actually perceives design, not in copying whatever site is currently fashionable.

The core insight that powers everything below: **beauty in an interface is cognition, not decoration.** The brain treats *easy to process* as *good, true, and trustworthy* (processing fluency). Almost every "premium" signal — clarity, hierarchy, whitespace, restraint, consistent type, unhurried motion — works because it makes the brain's job easier. Get fluency right and the design feels expensive. Get it wrong and no amount of gradient meshes or trendy fonts will save it.

## When NOT to copy a reference site

If the user says "make it like Stripe / Apple / Linear," do not reproduce that site's surface (its exact colors, its gradient, its hero layout). That path produces competent pastiche — the safe middle, i.e. slop. Instead, extract the *principle* the reference embodies (Stripe = obsessive microdetail; Apple = deference to content; Linear = craft-as-identity, dimmed chrome) and apply that principle to the user's actual content. Name the principle out loud, then design from it.

## The diagnostic loop

When building or fixing any UI, work in this order. Earlier stages dominate — a beautiful color palette cannot rescue broken hierarchy.

### 1. Fluency first (the foundation — never skip)

The brain judges visual appeal in ~50ms, before reading a word (Lindgaard 2006). That snap judgment then halos onto perceived usability and trust (the aesthetic-usability effect). So the first job is to make the screen effortless to parse:

- **One clear focal point per view.** The largest, highest-contrast, most isolated element wins the first fixation. If everything shouts, nothing is heard.
- **Ruthless visual hierarchy** via size, weight, contrast, and *spacing* — not borders and boxes. Let whitespace do the grouping (Gestalt proximity + common region).
- **Generous whitespace.** Negative space (Japanese *Ma*) is not empty — it is the single cheapest, most reliable premium signal, because emptiness *is* fluency. Cheap designs are cramped; expensive ones breathe.
- **Legible type, restrained palette.** High text contrast, comfortable measure (~45–75 characters), one or two typefaces, few colors. Saturated/many colors → playful, mass-market. Restrained/near-monochrome → professional, premium.
- **Cut extraneous cognitive load** (Sweller): remove every element that doesn't earn its place. Fewer choices per step (Hick's Law); chunk information (Miller ~4 chunks). Simplicity *literally* feels good because working memory is tiny.

Gut check: a 5-second look should answer "what is this / what do I do here." If it can't, fix hierarchy before touching polish.

See `references/perception.md` for the mechanisms (Gestalt, fluency, attention, the foundational studies).

### 2. Craft and emotion (what turns "fine" into "lovable")

Once fluent, layer the things that signal hundreds of careful decisions — because craft IS the felt sum of fluency-respecting microdetails.

- **Typography, spacing, color, motion as craft signals.** Adopt a spacing scale (4/8px), a tight type system, motion tokens. Precision here is what the brain reads as "expensive."
- **Design across Norman's three levels at once:** *visceral* (gut first impression — the 50ms), *behavioral* (effortless to use, responsive, in-control), *reflective* (what identity does using this confer? Linear = "I have taste"). Lovable products refuse to trade these off.
- **Engineer peaks and endings** (peak-end rule): memory is dominated by the emotional high point and the final moment, not the average. Build one genuine delight moment and a graceful completion/empty state.
- **Microinteractions** (Saffer): the toggle's ease, the hover, the confirmation. Small, single-purpose, alive. This is where delight concentrates.
- **Honest by default.** No deceptive patterns. Manipulation buys short-term conversion and corrodes the trust that fluency built. Durable love is built on transparency (Rams: "good design is honest").

See `references/craft-and-emotion.md` for Norman's levels, the peak-end rule, motion timing, and microinteraction patterns.

### 3. Validate against the actual audience (don't average tastes into mush)

Taste is partly universal (symmetry, prototypicality, fluency) and partly learned (color meanings, conventions, register). So calibrate the *emotional register* to the segment:

- **Power users / developers** (Linear, Stripe, Vercel): density, speed, keyboard control, dark/monochrome restraint reads as premium.
- **Consumers / learners** (Duolingo): saturated color, playful anthropomorphism, gamified progress, gentle pacing.
- **Educators / professional**: clarity, trustworthiness, low cognitive load above all.
- **EdTech specifically** usually serves several segments at once — establish a calm, fluent, trustworthy base, then layer *intrinsic-motivation* delight (progress, competence, well-timed celebration) without sliding into compulsion/dark patterns.

If you can test: 5-second test (first impression), first-click test, desirability testing with Microsoft Reaction Cards (does the adjective set come back "premium/calm/trustworthy" or "cheap/busy"?). See `references/taste-and-validation.md`.

## Anti-slop checklist (run before shipping any UI)

Slop has tells. Catch them:

- [ ] **Not center-stacked everything** with two equal-weight CTAs and a generic three-card feature row.
- [ ] **One committed accent color**, not a rainbow; neutrals are warm/cool near-black, never pure `#000`/`#fff` flatness.
- [ ] **Real hierarchy** — one focal point, clear size/weight steps, not uniform gray text everywhere.
- [ ] **Whitespace that breathes** — not cramped, not edge-to-edge.
- [ ] **A type system with a display face that has a point of view**, not the same sans at three sizes.
- [ ] **Motion that eases** (decelerate-in, accelerate-out, 200–500ms), never linear, never gratuitous.
- [ ] **A reason for every element.** If it doesn't serve the content or the user, delete it (Rams: "as little design as possible").
- [ ] **A point of view.** Generic = forgettable. What does this design *say*? If "nothing," it's slop.
- [ ] **Honest** — no fake scarcity, no buried fees, no confirm-shaming.

## How to respond when a user says "this is slop"

1. Agree that copying a reference produces the safe middle — that critique is usually right.
2. Diagnose with a *principle*, not a vibe: which fluency or craft lever is missing (hierarchy? whitespace? a point of view? committed accent?).
3. Ask for ONE concrete constraint that isn't a brand name — an unusual metaphor ("feels like a field notebook"), a hard restriction ("two colors total", "no rounded corners"), or a deliberate break ("nav at the bottom"). Creativity comes from sharper constraints, not from removing them.
4. Build from that constraint + first principles. Don't thrash through random variants.

## References

- `references/applied-playbook.md` — **READ THIS EVERY TIME YOU BUILD.** The slop defaults to reject, concrete starting tokens (spacing/type/color/motion), a worked slop→fix example, and a pre-ship gate. This is the file that stops you from reading the theory and shipping slop anyway. Knowing a principle is not applying it.
- `references/perception.md` — Gestalt, processing fluency, the aesthetic-usability effect, the 50ms first impression, attention/hierarchy, and the foundational studies. Read when diagnosing *why* a layout reads as clear or cluttered.
- `references/craft-and-emotion.md` — Norman's three levels, Kahneman System 1/2, peak-end rule, cognitive-load laws, motion timing, microinteractions, Rams' principles, the Apple/Bauhaus/Japanese lineage. Read when adding polish and emotional resonance.
- `references/taste-and-validation.md` — what taste is (universal vs. learned), debunked myths (golden ratio, universal color meanings), per-segment registers with product teardowns (Apple, Duolingo, Linear, Stripe, Vercel, Notion, Things, Arc), and validation methods. Read when calibrating to an audience or justifying choices.
