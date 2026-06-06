# Anti-AI-Slop Rules

The single most important file in Grain. These are the 25 rules that separate
taste-driven UI from the median LLM output. Every rule has a primary source, a
concrete tell, and a fix.

When generating any UI, run this file mentally before committing. When the user
critiques output as "looking like AI slop," diagnose which rule(s) were violated.

---

## The Origin of AI Slop

Adam Wathan, creator of Tailwind CSS, posted on X on **August 7, 2025 at 1:37 PM**
(1.3M views, x.com/adamwathan/status/1953510802159219096):

> "I'd like to formally apologize for making every button in Tailwind UI bg-indigo-500
> five years ago, leading to every AI generated UI on earth also being indigo."

That single default — `bg-indigo-500` — combined with shadcn/ui's neutral-zinc default
theme and Inter as the default font, propagated through GitHub at scale, then trained
into every LLM. The statistical center of "modern web UI" in training data became:

- Indigo or purple gradient hero (`from-indigo-500 to-purple-600`)
- Inter font, default weights
- `rounded-2xl` cards with `shadow-2xl`
- Three-column features grid with icon + heading + paragraph
- Center-stacked hero with H1 + subtitle + two CTAs ("Get Started" + "Watch Demo")
- "Trusted by" grayscale logo wall
- Footer with four columns of links

Recognizing this median is the prerequisite to escaping it.

---

## The 25 Rules

### Rule 1 — Ban Tailwind default purple/indigo

**Tell**: `bg-indigo-500`, `bg-indigo-600`, `text-indigo-600`, `from-indigo-500 to-purple-600`,
`from-purple-500 to-pink-500`, `bg-gradient-to-r from-violet-500 to-purple-600`.

**Why**: This is *the* signature. The single most reliable way to identify AI-generated
output without looking at the code.

**Fix**: Define `--color-accent` as an OKLCH value in your `@theme` block. Pick a hue
that isn't 270–290 (purple/violet range) unless the brand explicitly requires it.
Examples of strong non-purple accents:

- Linear Magic Blue: `oklch(60% 0.14 270)` — desaturated violet, NOT pure indigo
- Stripe Deep Violet: `oklch(48% 0.24 290)` — `#533afd`, used sparingly
- Vercel: pure black/white, NO accent — color comes from product screenshots only
- Anthropic warm terracotta: `oklch(65% 0.14 40)`
- Resend electric green: `oklch(85% 0.22 145)`
- Notion neutral: warm grayscale, single highlight via underline

**Escape hatch**: B2C consumer apps targeting Gen Z (TikTok, Discord-adjacent) can use
saturated purple as identity — but commit to it as a brand decision, not a default.

---

### Rule 2 — No center-stacked hero with two CTAs

**Tell**: `<h1 className="text-6xl text-center">` + subtitle + `<div className="flex gap-4 justify-center">` + "Get Started Free" + "Watch Demo".

**Why**: This composition is so common in the training data that every AI tool defaults
to it. Apple, Stripe, Linear, Vercel, Anthropic, Framer, Arc all break this pattern.

**Fix**: Pick one of:
- **Editorial asymmetric**: large display head left-aligned, caption-style support text
  in the right margin or above. Apple uses this on product pages.
- **Hero video / product reveal**: full-bleed product footage with sticky chrome.
- **Single-column with single CTA**: one primary action, no secondary. Linear's "Plan,
  build, and ship products" pattern.
- **Scroll-driven product introduction**: H1 fades, product UI assembles in stages
  as the user scrolls. Apple, Framer.
- **Quote-as-hero**: a real customer quote typeset as display, followed by attribution
  and one CTA.

**Escape hatch**: B2B SaaS sign-up pages where conversion is the only goal can use the
classic center-stack — but never on a homepage where the brand needs personality.

---

### Rule 3 — Inter as default = instant slop signal

**Tell**: `font-family: Inter` + no tracking adjustments + no Inter Display variant +
default Tailwind colors + default shadcn = the trifecta.

**Why**: Inter is excellent but ubiquitous. When combined with default tokens, it
becomes the visual equivalent of "I didn't choose."

**Fix** (pick one):
- **Geist** (Vercel, free OFL): default for product apps. Pair Geist + Geist Mono.
- **Stripe-style Inter**: weight 300 with `font-feature-settings: "ss01" "tnum"` and
  `letter-spacing: -0.04em` on display, `-0.01em` on subheads. This is the open-source
  Söhne fallback.
- **Mona Sans + Hubot Sans** (GitHub, free): variable display + text pair.
- **ABC Diatype** (Dinamo, licensed): if budget allows.
- **System fonts** (Apple-style): `-apple-system, BlinkMacSystemFont, "Segoe UI"`.

If Inter is unavoidable, differentiate by: (a) using Inter Display for ≥24px, (b)
applying negative tracking on display sizes, (c) varying weight not size for hierarchy.

---

### Rule 4 — `rounded-2xl` on every surface

**Tell**: `<Card className="rounded-2xl">`, `<Button className="rounded-2xl">`,
`<Input className="rounded-2xl">`, `<Avatar className="rounded-2xl">` — all the same.

**Why**: A radius system signals craft. Same-radius-everywhere signals "I picked one
class and applied it."

**Fix**: Pick a radius system per industry pack and stick to it.

- **SaaS / product**: buttons capsule (`9999px`), cards `8px`, inputs `6px`, modals `12px`.
- **Corporate marketing**: buttons capsule, cards `12px`, hero elements `0–4px` (sharper).
- **Engineering / B2B**: buttons `6–8px`, cards `4–6px`, inputs `4px` — Linear-style.
- **Apple mobile**: concentric radii. Parent radius = R, child radius = R - padding.
- **Material 3 mobile**: pill buttons (full radius), cards 12dp, inputs 4dp.

**Escape hatch**: Brutalist or editorial sites may use `0` radius across all surfaces
intentionally. Document it explicitly.

---

### Rule 5 — Three-column features grid as default

**Tell**: `<div className="grid grid-cols-3 gap-8">` containing three identical
`<Card>`s, each with `<Icon />` + `<h3>` + `<p>`.

**Why**: It's the single most-reproduced layout pattern. Apple, Stripe, Linear use
sections that look completely different from one another, not three boxes in a row.

**Fix**: Each section gets its own visual identity:
- Section 1: product screenshot + caption alongside.
- Section 2: large pull-quote from a real customer.
- Section 3: feature comparison table or interactive demo embed.
- Section 4: editorial paragraph with inline product reference.

If you must use a feature grid, vary it: large featured item + smaller items, masonry
layout, or full-bleed alternating left/right.

---

### Rule 6 — Card-everything syndrome

**Tell**: Every section wrapped in `<Card>`. Every list item is a `<Card>`. Every
piece of content sits inside a bordered shadow-having container.

**Why**: Cards group related content. They're not decoration.

**Fix**: Use the right primitive:
- **Tables** for tabular data >20 rows.
- **Lists** for sequential items with dividers, not boxes.
- **Prose blocks** for editorial content with proper typography spacing.
- **Cards** only when content is genuinely grouped, parallel, and benefits from a
  bounded container (product cards, person profiles, project tiles).

---

### Rule 7 — Stock dashboard layout

**Tell**: Fixed sidebar (240–280px) + top bar with avatar + 4 stat cards in a row
above a paginated table. Every "dashboard" output from every AI tool.

**Why**: It's the most-reproduced product layout in training data. Recognizable in
two seconds.

**Fix**: Differentiate via:
- **Information architecture**: KPI strip with 4–6 metrics in *one* row, each with
  current value + sparkline + trend (Stripe pattern). Not 4 isolated stat cards.
- **Density**: tighter row heights (40–48px not 64+).
- **Color story**: branded accent only on actionable elements, semantic colors for
  status. Background is single-tone, not "card on gray background."
- **Layout**: collapsible sidebar with icons-only mode; combined breadcrumb+search
  in the top bar; sticky table headers; URL-synced filters.
- **Content**: real numbers, real names, real labels — never `$1,234.56` and `Acme Corp`.

---

### Rule 8 — No ✨ sparkle emoji, no AI iconography

**Tell**: ✨ in headlines, 🤖 in feature copy, "AI-powered" with magic-wand icon,
gradient sparkle decorations behind H1s.

**Why**: Telegraphs the production tool. Erodes trust by labeling the work as AI-made
even when the work itself is good.

**Fix**: If AI is the product, the iconography should reflect *the actual product
behavior*, not the trope. Linear's AI features don't have sparkles. Notion's don't.
GitHub Copilot uses a specific custom icon, not a generic sparkle. Anthropic uses a
single distinctive mark.

---

### Rule 9 — Glassmorphism on every surface

**Tell**: `bg-white/30 backdrop-blur-md border border-white/40` applied to every
card, nav, sidebar.

**Why**: Glass is a *material*, not a style. Apple's Liquid Glass (iOS 26) uses it
contextually — tab bars, controls, sidebars — not on every surface. Slapping
backdrop-blur on every card destroys depth hierarchy.

**Fix**: Use frosted/glass effects only where the content behind matters:
- Sticky nav that overlays scrolling content
- Modal scrim
- Floating tab bar that sits above content (iOS 26 pattern)
- Side panel that overlays the main view

Solid surfaces for: cards, content blocks, lists, body.

---

### Rule 10 — 3D abstract humans, unDraw, floating shapes

**Tell**: Generic illustrations of diverse abstract humans, flat-vector laptop scenes,
floating geometric blobs as hero backdrops.

**Why**: They're all from the same 3-4 free illustration libraries. They're stylistically
identical across thousands of sites. They communicate "we didn't budget for design."

**Fix**: In priority order:
1. **Product screenshots** — show what the product does.
2. **Real photography** — actual people, actual workspaces, custom-shot.
3. **Custom illustrations** — commissioned, hand-drawn, with consistent style.
4. **Geometric / typographic compositions** — Vercel-style, no illustrations at all.
5. **Atmospheric gradients** — Stripe-mesh-style, but only as backdrop, not content.

Banned libraries: unDraw, Storyset, ManyPixels, Open Doodles (for marketing). They're
fine for prototypes and internal tools.

---

### Rule 11 — Generic CTA pair: "Get started free" + "Watch demo"

**Tell**: Every hero, every section, two buttons side by side, equal weight, identical
phrasing.

**Why**: It's the conversion-funnel default. Every SaaS site does it. Differentiation
disappears.

**Fix**: One CTA per section. The CTA copy is product-specific:
- "Start tracking 4-hour deliveries" not "Get started"
- "See how Acme cut review cycles by 40%" not "Watch demo"
- "Read the launch announcement" instead of a secondary button

Secondary action becomes a text link with no button styling: "Or talk to sales →"

---

### Rule 12 — "Trusted by" grayscale logo wall

**Tell**: `<div className="flex gap-12 grayscale opacity-60">` with 6 customer logos.

**Why**: Generic, derivative, and at this point a parody of itself.

**Fix**:
- **Inline social proof**: weave customer names into the editorial copy.
- **Specific testimonials**: a single named quote with photo, role, and company —
  treated as display typography, not a card.
- **Numerical proof**: "Used by 200,000 developers" with a single supporting metric,
  no logos.
- **Case studies as content**: a section that links to specific customer stories with
  the screenshot and outcome.

If you must have logos, color them at full saturation, arrange asymmetrically, and
make them part of a section that tells *why* those customers chose the product.

---

### Rule 13 — Default shadcn neutral theme

**Tell**: `--primary: 240 5.9% 10%` (near-black), `--radius: 0.5rem`, no custom font,
Lucide everywhere. The shadcn `init` defaults.

**Why**: shadcn is the most-used React component library; AI tools default to it;
the default theme is therefore the visual median.

**Fix**: Before any component is added, override these:
1. `--primary` to a real brand color in OKLCH (not the default near-black).
2. `--radius` to something other than `0.5rem` — at minimum `0.375rem` or `0.75rem`,
   ideally a system per the radius rule.
3. Font family — replace Inter or system default with Geist / Söhne / Mona Sans.
4. At least one component variant — add a `brand-outline` button, customize Card's
   default padding.

Full guidance in `references/shadcn.md`.

---

### Rule 14 — Lorem-ipsum-feeling copy

**Tell**: "Streamline your workflow." "Built for modern teams." "Empower your business."
"Take control of your data." "Boost productivity 10x."

**Why**: These phrases say nothing. They're the verbal equivalent of stock photography.

**Fix**: Concrete copy with:
- **A specific user** — "for engineering managers running 5+ sprints"
- **A specific outcome** — "cut sprint planning from 2 hours to 20 minutes"
- **A specific mechanism** — "by auto-generating sprint goals from your last 4 weeks
  of GitHub activity"
- **Real numbers** — not "10x faster," "from 3 days to 4 hours"

If you don't know the product well enough to write concrete copy, ask the user for
3–5 sentences of the actual product behavior before generating UI.

---

### Rule 15 — Drop shadows everywhere

**Tell**: `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl` on every card and section.

**Why**: Refactoring UI rule: shadows convey *elevation*. Putting them on everything
flattens the hierarchy.

**Fix**:
- **No shadow** on flat surfaces (cards on a colored background, list items, table rows).
- **Subtle shadow** (`--shadow-pop`) on lifted surfaces: dropdowns, hover-elevated cards.
- **Strong shadow** (`--shadow-modal`) only on modals, popovers, command palettes.
- Use **background contrast** for default separation: `bg-surface` on `bg-bg`,
  `border` only where needed.

---

### Rule 16 — Pure `#000` text on `#fff`

**Tell**: `text-black` on `bg-white`, or worse, `text-gray-900` on `bg-white` as a
default body.

**Why**: Pure black is unnaturally harsh and creates eye strain. Apple, Stripe, Linear,
Vercel all use desaturated near-blacks. Pure black appears only in display elements
where contrast is intentional.

**Fix**:
- Body foreground: `oklch(20% 0.04 265)` — near-black with slight cool cast.
- Muted: `oklch(55% 0.02 270)` — for secondary text.
- Subtle: `oklch(75% 0.015 270)` — for tertiary, placeholders.
- Pure `#000` only for: display headlines on light backgrounds, brand wordmarks,
  hard-stop emphasis.

---

### Rule 17 — Default Material/Bootstrap blue links

**Tell**: `text-blue-600 underline` for every link.

**Why**: Default link blue is a 2010s pattern. Modern interfaces match link color
to brand or use neutral underlines.

**Fix**:
- **Brand link**: `text-accent` with underline on hover only.
- **Neutral link**: `text-fg` with persistent underline + `text-decoration-thickness: 1px`.
- **Inline body links**: `text-accent` underlined, `text-decoration-thickness: 1px`,
  `text-underline-offset: 3px`.
- Visited state: don't differentiate unless content type requires it (search results,
  doc indexes). Most product UIs ignore `:visited`.

---

### Rule 18 — Full-viewport hero gradient background

**Tell**: `<section className="min-h-screen bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500">`.

**Why**: Loud, derivative, and increasingly cringe-coded.

**Fix**: Gradient atmosphere belongs in *specific brand moments*:
- **Stripe-style mesh**: bounded to the top third of the hero, soft blur, multi-stop
  pastels, ALWAYS over a neutral base.
- **Linear-style aura**: subtle glow behind the H1 only, low-saturation, blends to
  background.
- **No gradient at all**: Vercel, Apple, Anthropic. Black/white/neutral hero with
  product imagery doing the work.

Stripe gradient mesh recipe (use sparingly):
```css
background:
  radial-gradient(ellipse at 30% 20%, oklch(94% 0.08 30 / 0.4), transparent 60%),
  radial-gradient(ellipse at 70% 40%, oklch(92% 0.1 280 / 0.3), transparent 70%),
  radial-gradient(ellipse at 50% 10%, oklch(94% 0.06 350 / 0.4), transparent 60%),
  oklch(99% 0.004 270);
```

---

### Rule 19 — Identical card hover: scale + shadow-2xl

**Tell**: `hover:scale-105 hover:shadow-2xl transition-all duration-300`.

**Why**: It's the lazy default. It also breaks layout (the card grows into its neighbors).

**Fix**: Subtle hover patterns:
- `translateY(-2px)` + `--shadow-pop` (no scale).
- Border color shift: `border-border` → `border-fg/20`.
- Background brightness: `bg-surface` → `bg-surface-2`.
- Outline accent: `outline-2 outline-accent/30` appears.

Duration: 150ms max. Easing: `--ease-out`.

---

### Rule 20 — Loading spinner that causes layout shift

**Tell**: Button shrinks/expands when entering loading state because the label is
replaced with a spinner of different width.

**Why**: Layout shift damages Core Web Vitals (CLS) and looks unstable.

**Fix**:
- Button locks `min-width` based on label width.
- Loading state replaces label with spinner (same color as label), positioned center.
- Button retains all padding, dimensions, and disabled state.
- For longer operations, button can show a progress bar inside (Linear pattern) or
  switch to "Loading…" with consistent letter count.

```tsx
<Button disabled={loading} className="min-w-[120px]">
  {loading ? <Spinner /> : "Save changes"}
</Button>
```

---

### Rule 21 — Modal centered with backdrop blur on mobile

**Tell**: `<Dialog className="rounded-2xl backdrop-blur-md">` shown on a 375px screen,
overflowing edges, awkward keyboard interaction.

**Why**: Mobile UX wants the modal anchored to the bottom (thumb reach), with a drag
handle, and detents. Centered dialogs are desktop UI.

**Fix**:
- **Mobile**: use Vaul (Emil Kowalski's library) for bottom sheets. Default detent
  half-screen, optional full. Drag handle visible.
- **Desktop**: centered dialog, max-width 480–640px, 24–32px padding, `--radius-modal`.
- **Responsive**: branch at the component level. `<ResponsiveSheet>` that picks
  Vaul on `<md` and Dialog on `≥md`.

---

### Rule 22 — Flat-illustration empty states with "No data yet"

**Tell**: Centered flat-vector illustration of a mailbox/folder/document with the
copy "No data yet" and a small "Create your first X" button.

**Why**: It says nothing. The user already knows they have no data; they need to
know what the screen will become.

**Fix**: Empty states *teach the screen*:
- Show a faint, monochrome preview of what filled state will look like (a sample row
  with reduced opacity, a "ghost" chart).
- Headline that names the screen's purpose: "Track customer issues here" not "No data yet."
- One sentence describing what the user does next: "Once you create your first issue,
  it'll show up in this list with status, assignee, and last update."
- Single primary CTA, concrete: "Create your first issue."
- Secondary text link to docs or templates if relevant.

---

### Rule 23 — Auto-animate on enter for everything

**Tell**: Every section fades + slides in as you scroll past it. Every card has a
stagger animation. Every modal has a bouncy spring entry.

**Why**: Frequency kills delight. Things that animate on every visit become noise.
Animation should signal *change*, not exist as decoration.

**Fix** (Emil Kowalski's rule):
- **Animate state changes**: idle → loading, closed → open, list reorder.
- **Animate modal/sheet enter and exit**: opacity + transform, ≤300ms.
- **Don't animate keyboard-initiated actions**: Cmd+K opens instantly. Esc closes
  instantly.
- **Don't animate frequently-used dropdowns**: nav menus, sort menus, filter menus
  open instantly on click.
- **Don't animate routine page entries**: scroll-triggered animations belong on
  marketing pages, not product apps.

---

### Rule 24 — Body text below 15px

**Tell**: `text-sm` (14px) as body on a marketing page. `text-xs` (12px) as
description text.

**Why**: Below 15px on desktop and 16px on mobile, body becomes uncomfortable to
read for any length of copy.

**Fix**:
- **Desktop body**: 16px minimum, 17–18px preferred for marketing.
- **Mobile body**: 17px minimum, matches iOS default. Never below 16px.
- **Caption**: 13–14px, with `+0.005em` to `+0.01em` positive tracking.
- **Micro-copy** (timestamps, badges): 11–12px, increase tracking to compensate.

---

### Rule 25 — Body fonts at weight 300

**Tell**: `font-weight: 300` body text. Looks thin and "elegant" in mockups; illegible
on actual screens, especially at small sizes.

**Why**: At ≤16px, weight 300 disappears against backgrounds and creates accessibility
contrast issues even when foreground/background pass WCAG.

**Fix**:
- **Body**: weight 400 default. Weight 500 if the typeface runs visually thin (Inter
  reads bolder than Geist at the same weight).
- **Captions / muted**: weight 400 with reduced opacity, not weight 300.
- **Display heads**: weight 300 is acceptable at ≥48px (Stripe's Söhne pattern). Below
  that, use weight 400/500/600 with negative tracking to convey "lightness."

---

## Named Designer Principles

The rules above are drawn from these designers' explicit work. When generating UI,
reach for their voices in this order:

### Rauno Freiberg — Staff Design Engineer at Vercel; built cmdk

- **Robustness beats novelty**: "If your UI only works 80% of the time, the perception
  of quality breaks." Test under stress: fast scroll, low battery, slow network.
- **Disney's Follow-Through**: Apply staggered motion between primary and secondary
  elements (100–200ms delays).
- **Build in code, not Figma**: Material reveals truth. Prototypes in real
  components catch what mockups can't.
- **Validate by exaggeration**: Build version 1 through 10 by pushing each iteration
  further, then pull back to the sweet spot.
- Source: rauno.me, Devouring Details course (devouringdetails.com).

### Emil Kowalski — Linear web team; built Sonner and Vaul; animations.dev

- Never animate keyboard-initiated actions.
- Animate only `transform` and `opacity` for GPU acceleration.
- CSS for predetermined animations; JS only for interruptible / gesture-driven.
- Modal + overlay share duration and easing — elements that move together must
  *feel* together.
- Springs feel natural because they don't have fixed durations.
- Frequency matters: 100×/day actions should be instant.
- Source: emilkowal.ski/ui/great-animations, animations.dev.

### Adam Wathan — Refactoring UI + Tailwind CSS

- Start with a feature, not a layout.
- Choose a personality before you start.
- Limit choices. Build a system.
- Hierarchy uses color and weight before size.
- Design in grayscale first; add color when hierarchy works.
- Leave more whitespace than feels natural, then tighten.
- Don't use borders for everything; use background contrast.
- Source: Refactoring UI book (Wathan + Schoger).

### Karri Saarinen — co-founder, Linear

- Calm interfaces win for products you live in.
- Density is craft; reduce borders rather than reduce information.
- 8px modular spacing scale, no traditional grid.
- The product is content-first; chrome serves content.
- Source: linear.app/now/behind-the-latest-design-refresh.

### Alan Dye — VP, Human Interface Design at Apple

- Concentric geometry: nested controls subtract padding from parent radius.
- Material (Liquid Glass) over decoration.
- Tab bars minimize on scroll to focus attention on content.
- Source: Apple Newsroom 2025-06-09, WWDC25 session 356.

### Soren Iverson — ex-Cash App; "Can You Imagine?" book

- Satirizes UX patterns by pushing them one step too far. Useful as a critique
  generator: if Soren would mock this UI on Twitter, change it.
- Source: soreniverson.com.

### Brian Lovin — designing AI products at Notion; ex-GitHub, ex-Campsite

- Detail-driven craft. Brian's site (brianlovin.com) is itself a design reference.
- Design Details podcast.

---

## Diagnostic Tells (Used by Designers in 2025–2026 to Call Out AI Output)

When critics on X / Twitter, designer Substacks, or HN diagnose AI-generated UI,
they consistently point to these:

1. The `bg-indigo-500` / purple-pink gradient — most-cited tell.
2. `rounded-2xl` on every surface, especially `rounded-2xl border bg-card shadow-md`.
3. The "Hero with two CTAs centered" composition.
4. The three-feature grid.
5. Inter at default weight + default colors.
6. Generic illustrations (unDraw, Storyset, ManyPixels).
7. Lorem-ipsum-tier copy ("Empower your workflow").
8. Shadcn default neutral theme with no customization.
9. Stock dashboard layout (sidebar + topbar + 4 stat cards + table).
10. ✨ in marketing copy + "AI-powered" framing.

Sources: Anna Arteeva on Design Systems Collective (designsystemscollective.com),
Mageswari on Medium ("Why Your AI-Generated UI Looks Like Everyone Else's"), DEV
Community threads ("Why Every AI-Built Website Looks the Same: Blame Tailwind's
Indigo-500"), the Shravonix "AI Purple Problem" essay.

---

## How to Use This File

1. Load this file at the start of every UI generation task.
2. Reference rules by number in comments: `// anti-slop rule #4 — using radius system per industry pack`.
3. When generating, ask yourself: "If Soren Iverson scrolled past this, would he
   screenshot and quote it?" If yes, change it.
4. When the user critiques output as "AI slop" or "looks generic," diagnose against
   the 25 rules and identify which were violated. Then regenerate, not patch.
5. Document intentional rule breaks with reason in inline comments. The framework
   allows escape hatches; it doesn't allow silent breaks.

If three or more rules are broken in a single output without documented reason,
the output should be regenerated from scratch with the calibration step done
properly first.
