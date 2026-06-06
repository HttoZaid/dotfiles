---
name: grain-design-system
description: >
  Opinionated UI/UX design system for building taste-driven interfaces that don't
  look like AI slop. Use whenever the user wants to build a UI, component, screen,
  dashboard, app, website, marketing page, or design system. Also use for questions
  about color, type, spacing, motion, accessibility, SEO, or modern UI patterns.
  Covers anti-slop rules, OKLCH tokens, typography (Geist/Söhne/SF Pro/Roboto Flex),
  motion from Emil Kowalski & Rauno Freiberg, iOS 26 Liquid Glass, Material 3
  Expressive, WCAG 2.2 AA, Core Web Vitals, Tailwind v4 @theme, shadcn customization,
  and packs for SaaS, marketing, engineering/B2B, mobile iOS, and mobile Android.
  Triggers: "make a UI", "design a component", "build a landing page", "make a
  dashboard", "what colors", "pick a font", "build a screen", "design system",
  "make it look good", "make it modern", "stop the AI slop", "make it look like
  Linear/Vercel/Stripe/Apple", "build a mobile app UI".
---

# Grain Design System — beta

A taste engine, not a theme catalog. Built from Linear, Vercel, Stripe, Raycast, Apple
HIG iOS 26, Material 3 Expressive, Refactoring UI, Rauno Freiberg's interaction work,
Emil Kowalski's animation rules, and the named anti-AI-slop critiques of 2024–2026.

Strong defaults with documented escape hatches. The skill enforces opinions; the
industry packs override them.

---

## HOW TO USE THIS SKILL

When a user asks for any UI:

1. **Calibrate taste first.** Before writing code, infer or ask:
   - **Category** — SaaS app / corporate marketing / engineering or B2B / mobile native
   - **Tone** — serious-precise / playful / editorial / brutalist
   - **Density** — Linear-dense / Apple-quiet / data-tabular
   - **Industry pack** — defaults to SaaS if unspecified
2. **Load the industry pack.** Read the matching file from `references/`:
   - `industry-saas.md` for SaaS / app interfaces
   - `industry-corporate.md` for marketing sites
   - `industry-engineering.md` for B2B, data-dense, industrial
   - `industry-mobile-ios.md` for iOS native + Flutter Cupertino
   - `industry-mobile-android.md` for Android native + Flutter Material
3. **Run the 25 anti-slop rules** in `references/anti-slop-rules.md`. These are checked
   on output, not just on intent.
4. **Pull tokens from foundation.** `references/foundation.md` has the OKLCH palette,
   spacing scale, radius scale, motion curves, and the Tailwind v4 `@theme` block.
5. **Cross-check components.** `references/components.md` has spec for every primitive
   with hard limits and escape hatches.
6. **Self-review before shipping.** Walk the output against the anti-slop checklist
   and report any rule violations with the override reason.

If you skip step 1, the output regresses to median AI slop. The calibration is the
single biggest lever in the entire system.

---

## REFERENCE FILES

Read these on demand, not all at once. Each is the authoritative source for its domain.

| File | When to load |
|---|---|
| `references/anti-slop-rules.md` | **Always** load before generating any UI |
| `references/foundation.md` | **Always** load — color, type, spacing, radius, motion tokens |
| `references/components.md` | Whenever generating buttons, forms, cards, tables, modals, lists, badges |
| `references/typography.md` | Picking typefaces, optical sizing, font pairings |
| `references/motion.md` | Any animation, transition, or interactive feedback |
| `references/accessibility.md` | WCAG 2.2 AA — every component must pass |
| `references/seo-clean-code.md` | Marketing sites, semantic HTML, Core Web Vitals |
| `references/tailwind-v4.md` | Setting up `@theme`, OKLCH tokens, container queries |
| `references/shadcn.md` | Customizing shadcn/ui without producing default-neutral slop |
| `references/industry-saas.md` | SaaS pack — Linear/Vercel/Stripe/Raycast grammar |
| `references/industry-corporate.md` | Corporate / marketing pack — Apple/Stripe/Anthropic |
| `references/industry-engineering.md` | B2B / data-dense / industrial pack |
| `references/industry-mobile-ios.md` | iOS 26 Liquid Glass mobile pack |
| `references/industry-mobile-android.md` | Material 3 Expressive mobile pack |

---

## THE FIVE LAWS

These override everything. If a request conflicts with a Law, push back before complying.

### Law 1 — Calibrate the personality before writing code.
SaaS app and marketing site live by different rules. Engineering tool and consumer
mobile app live by different rules. Without a personality decision, every interface
regresses to the same `bg-indigo-500` + Inter + `rounded-2xl` median. Make the
personality decision explicit at the top of every component or screen file (a comment
is fine).

### Law 2 — One accent color, semantic everything else.
The brand has exactly one accent. Status colors (success / warning / error / info) are
semantic, never branded. Neutral fills 90% of the surface. Three-or-more-color brand
palettes are banned in the default pack — only marketing hero gradients (Stripe-style
mesh) allow multi-hue, and only inside a clearly bounded section.

### Law 3 — Hierarchy comes from color and weight before size.
Body text is one size. Display heads are one size larger. Secondary text is the same
size as body but with reduced opacity or a muted token. Stop scaling text up and down
to communicate importance. Pull the reader's eye with weight (400 → 500 → 600) and
contrast (foreground → muted → subtle), not with 12px ↔ 18px noise.

### Law 4 — Motion only when it changes meaning.
Animate state changes, modal entries, list reorders, optimistic confirmations. Do not
animate keyboard-initiated actions, frequently-used dropdowns, or anything triggered
more than 50× per session. Frequency kills delight; reach for instant. Emil Kowalski's
rule: Raycast has no open animation because the user opens it hundreds of times a day.

### Law 5 — Density is a feature, not a bug.
2026's reference brands all moved toward higher density (Linear's calmer interface,
Stripe Sigma's tables, Datadog dashboards). Whitespace is a tool, not a default. For
app interfaces, prefer table rows 40–48px tall, list items at native platform minimums,
and information per screen over "breathing room." Marketing sites are the only place
generous whitespace is the default.

---

## THE 25 ANTI-SLOP RULES (SUMMARY)

The full rules with rationale and primary sources live in `references/anti-slop-rules.md`.
This is the shortlist for quick reference:

1. No `bg-indigo-500`, no `from-indigo-500 to-purple-600` gradients, no Tailwind default purple.
2. No center-stacked "H1 + subtitle + 2 CTAs" hero.
3. Inter is fine, but Inter + default Tailwind + default shadcn = instant slop. Differentiate.
4. No `rounded-2xl` or `rounded-3xl` on every surface. Pick a radius system per industry pack.
5. No three-column "icon + heading + paragraph" features grid as a default layout.
6. Card-everything syndrome is banned. Tables, lists, prose blocks exist.
7. The stock dashboard layout (sidebar + topbar + 4 stat cards + table) needs differentiation.
8. No ✨ sparkle emoji. No AI iconography. Don't telegraph the tool.
9. No glassmorphism on every surface. Glass is contextual (iOS Liquid Glass, specific overlays).
10. No 3D abstract humans, no floating geometric shapes, no unDraw / Storyset.
11. No generic CTA pair ("Get started for free" + "Watch demo"). Single CTA per section.
12. No "Trusted by" grayscale logo wall as a default.
13. The shadcn default neutral theme is banned. Override `--primary`, `--radius`, font.
14. No lorem-ipsum-feeling copy. Concrete copy referencing the real user and outcome.
15. No drop shadows on everything. Use background contrast for elevation.
16. No pure `#000` text on `#fff`. Use desaturated near-black (`oklch(20% 0.04 265)`).
17. No default Material/Bootstrap blue links. Match brand or use a neutral underline.
18. No full-viewport hero gradient backgrounds as default.
19. No identical card hover (`scale(1.05) + shadow-2xl`). Translate-Y + border shift.
20. No loading spinner that causes layout shift. Fixed-width buttons swap label for spinner.
21. No modal-centered-with-blur on mobile. Use bottom sheet (Vaul).
22. No flat-illustration empty states with "No data yet" headline. Explain what the screen becomes.
23. No auto-animate on enter for everything. Animate only what changes meaning.
24. Body text below 15px is banned. 16px desktop minimum, 17px mobile.
25. No body fonts at weight 300 — illegible at small sizes.

---

## TAILWIND V4 @theme — DEFAULT TOKENS

Drop this into the project's CSS. Tokens are OKLCH for perceptually-uniform scales.
Industry packs override `--color-accent`, `--radius-button`, `--font-display`, and a
small set of duration tokens. Everything else stays.

```css
@import "tailwindcss";

@theme {
  /* === Color: semantic, OKLCH, one accent === */
  --color-bg: oklch(99% 0.004 270);
  --color-fg: oklch(20% 0.04 265);
  --color-muted: oklch(55% 0.02 270);
  --color-subtle: oklch(75% 0.015 270);
  --color-border: oklch(92% 0.005 270);
  --color-surface: oklch(98% 0.003 270);
  --color-surface-2: oklch(96% 0.004 270);

  --color-accent: oklch(60% 0.18 250);          /* override per pack */
  --color-accent-fg: oklch(99% 0.005 250);
  --color-accent-soft: oklch(96% 0.04 250);

  --color-success: oklch(65% 0.16 145);
  --color-warning: oklch(75% 0.14 75);
  --color-error: oklch(60% 0.22 25);
  --color-info: oklch(65% 0.13 230);

  /* === Dark mode === */
  /* override via .dark { --color-bg: oklch(15% 0.02 270); ... } */

  /* === Radius: system, not random === */
  --radius-input: 0.375rem;        /* 6px - inputs, small cards */
  --radius-card: 0.5rem;           /* 8px - cards, surfaces */
  --radius-button: 9999px;         /* capsule by default */
  --radius-modal: 0.75rem;         /* 12px - dialogs */

  /* === Spacing: 4px base === */
  /* Tailwind v4 provides this automatically; just use the scale */

  /* === Typography === */
  --font-sans: "Geist", "Inter", system-ui, sans-serif;
  --font-mono: "Geist Mono", "JetBrains Mono", ui-monospace, monospace;
  --font-display: "Geist", "Inter Display", "Inter", system-ui, sans-serif;

  --tracking-display: -0.04em;     /* large heads */
  --tracking-tight: -0.01em;       /* subheads */
  --tracking-body: 0em;
  --tracking-caption: 0.005em;

  --leading-display: 1.05;
  --leading-tight: 1.2;
  --leading-body: 1.6;

  /* === Motion === */
  --duration-fast: 100ms;          /* color, opacity changes */
  --duration-normal: 200ms;        /* enter/exit, transforms */
  --duration-slow: 300ms;          /* marketing micro-interactions */

  --ease-fluid: cubic-bezier(0.3, 0, 0, 1);
  --ease-snappy: cubic-bezier(0.2, 0, 0, 1);
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);

  /* === Elevation: rare; mostly use background contrast === */
  --shadow-pop: 0 1px 2px oklch(20% 0.04 265 / 0.06),
                0 4px 8px oklch(20% 0.04 265 / 0.04);
  --shadow-modal: 0 12px 32px oklch(20% 0.04 265 / 0.12),
                  0 4px 8px oklch(20% 0.04 265 / 0.08);
}

.dark {
  --color-bg: oklch(15% 0.02 270);
  --color-fg: oklch(95% 0.01 270);
  --color-muted: oklch(65% 0.02 270);
  --color-subtle: oklch(40% 0.02 270);
  --color-border: oklch(25% 0.01 270);
  --color-surface: oklch(18% 0.02 270);
  --color-surface-2: oklch(22% 0.02 270);
  --color-accent-soft: oklch(25% 0.06 250);
}
```

Industry packs only redefine: `--color-accent`, `--radius-button`, `--radius-card`,
`--font-display`, `--font-sans`. All other tokens stay. Read the pack file before
overriding.

---

## DEFAULT TAILWIND v4 + shadcn STACK

Recommended starting point for any web project:

- **Framework**: Next.js 15 App Router (or Vite + React 19 if no SSR needed)
- **Styling**: Tailwind v4 with `@theme` (CSS-first, no JS config)
- **Components**: shadcn/ui as primitives, customized per `references/shadcn.md`
- **Icons**: Phosphor Icons (consistent weight, broader than Lucide). Lucide acceptable
  for app chrome only.
- **Motion**: CSS animations + transitions for predetermined motion; Framer Motion
  ONLY for interruptible / gesture-driven motion.
- **Toasts**: Sonner (by Emil Kowalski).
- **Mobile sheets**: Vaul (by Emil Kowalski).
- **Command palette**: cmdk (by Paco Coursey / Rauno Freiberg).
- **Fonts**: Geist (free, OFL) as default. Override per industry pack.
- **Data viz**: Recharts for general charts, Tremor for KPI dashboards, visx for custom.

---

## ESCAPE HATCH SYNTAX

When generating code, document deviations from defaults using inline comments:

```tsx
// GRAIN OVERRIDE: industry=engineering — using 6px radius for B2B feel
<Card className="rounded-md">

// GRAIN OVERRIDE: marketing — Stripe-style gradient mesh hero
<section className="bg-gradient-to-br from-[oklch(95%_0.08_30)] via-[oklch(92%_0.1_280)] to-[oklch(94%_0.06_350)]">

// GRAIN OVERRIDE: anti-slop rule #2 — single CTA per hero (intentional break of "two CTAs")
```

Every deviation needs a reason. "It looks better" is not a reason; "industry pack
requires it" or "user explicitly asked" or "anti-slop rule conflicts with a stronger
rule" are reasons.

---

## SELF-REVIEW CHECKLIST

Before finishing a UI generation, walk this checklist out loud (or in a comment):

- [ ] **Personality**: declared category, tone, density, industry pack
- [ ] **Color**: one accent, semantic neutrals, no Tailwind default purple/indigo
- [ ] **Type**: not Inter-default; not weight 300 body; display has negative tracking
- [ ] **Radius**: systematic, not `rounded-2xl` on everything
- [ ] **Shadows**: only on elevated surfaces (modals, dropdowns), not on every card
- [ ] **Hierarchy**: weight + color drive importance, not just size
- [ ] **States**: every interactive has default / hover / focus-visible / active / disabled / loading
- [ ] **A11y**: focus rings 2px + 3:1 contrast; tap targets ≥44pt mobile / ≥24px web minimum
- [ ] **Motion**: only state-meaningful animations; reduced-motion fallback
- [ ] **SEO**: semantic HTML, one H1, meta tags, OG image (marketing only)
- [ ] **Anti-slop**: ran the 25 rules; flagged any intentional breaks with reason

If three or more items fail, regenerate the component, don't patch it.

---

## INDUSTRY PACK QUICK MATCH

| User signal | Pack |
|---|---|
| "Build a SaaS dashboard / admin panel / app screen" | `industry-saas.md` |
| "Linear / Vercel / Notion / Cal-style" | `industry-saas.md` |
| "Landing page / marketing site / homepage" | `industry-corporate.md` |
| "Apple-style / Stripe.com / agency-tier site" | `industry-corporate.md` |
| "Dashboard / monitoring / charts / tables / B2B" | `industry-engineering.md` |
| "CAD / floor plan / industrial / field tool / ruggedized" | `industry-engineering.md` |
| "iOS app / SwiftUI / iPhone UI" | `industry-mobile-ios.md` |
| "Android app / Material / Flutter" | `industry-mobile-android.md` |
| Unclear / mixed | Default to `industry-saas.md`, ask for clarification |

---

## VERSION NOTES

- **beta** (2026-05): Full rewrite. Anti-slop rules added (25). iOS 26 Liquid Glass +
  Material 3 Expressive specs integrated. Tailwind v4 `@theme` block. Industry packs
  split out. WCAG 2.2 AA enforced. Geist replaces Inter as default. Strong defaults
  with documented escape hatches.
- **v1.0** (deprecated): 12 color palettes + 8 font pairings + component specs +
  Apple HIG basics. Theme-focused. Replaced by beta.

When in doubt, the rule in `references/anti-slop-rules.md` wins. When two rules
conflict, the more specific industry pack wins. When the user explicitly overrides,
document the override and proceed.
