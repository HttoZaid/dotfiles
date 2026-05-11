---
name: grain-design-system
description: >
  A complete UI/UX design system for building human-quality interfaces.
  Use this skill whenever someone asks to build a UI, component, screen, dashboard,
  app, website, design system, or anything visual. Also use when the user asks about
  color palettes, font pairings, spacing, motion, or component design.
  Covers: color palettes (12 themes), font pairings (8 families), spacing system,
  typography scale, motion curves, component specs (buttons, forms, cards, lists,
  badges, modals), screen patterns, and Do/Don't rules.
  Trigger phrases: "make a UI", "design a component", "what colors should I use",
  "pick a font", "build a screen", "design system", "what palette", "make it look good".
---

# Grain Design System — v1.0

A practical design system built from Apple HIG analysis, award-winning app breakdowns,
and real UI/UX research. No sci-fi, no trends — just substance.

---

## HOW TO USE THIS SKILL

When a user asks for a UI, component, or design:

1. **Check if they specified a palette** — if yes, look it up in `palettes/`
2. **Check if they specified a font** — if yes, look it up in `fonts/`
3. **If neither specified** — ask them to pick OR choose the best match for their context
4. **Apply the 5 core principles** (below) to every output
5. **Reference component specs** in `components/` for exact pixel values
6. **Build the output** as HTML/CSS using the token system from this file

---

## 5 CORE PRINCIPLES

Apply these to every single output, no exceptions.

```
01. THE INTERFACE DISAPPEARS
    The best UI is invisible. The user thinks about their task, never the tool.
    Every decision: does this bring me closer to invisible?

02. WHITESPACE IS NOT EMPTINESS
    Negative space groups, separates, breathes. A "sparse" screen is working harder
    than a full one. Empty space signals confidence. Clutter signals nervousness.

03. DE-EMPHASISE TO EMPHASISE
    Don't make important things louder. Make unimportant things quieter.
    Hierarchy = contrast, not size. The eye goes to what's different.

04. SYSTEMS OVER DECISIONS
    Every pixel chosen from a system is a pixel not argued over.
    Use the tokens. Never hardcode values.

05. MOTION EARNS ITS PLACE
    Animation that doesn't communicate state, relationship, or direction = delete it.
    Motion is meaning. Not decoration.
```

---

## SPACING SYSTEM — 8PT GRID

All values are multiples of 4. This is non-negotiable.

```
Token     px    Usage
──────────────────────────────────────────────────────────
--sp-1     4px  Icon gaps, tightest text pairing
--sp-2     8px  Badge gap, tight rows, inline items
--sp-3    12px  List item inner padding, card gap
--sp-4    16px  ★ SCREEN EDGE MARGIN — SACRED. Never 12, never 20.
--sp-5    20px  Section header offset
--sp-6    24px  Between grouped sections
--sp-8    32px  Between major page sections
--sp-10   40px  Hero section top padding
--sp-12   48px  Large structural separation
--sp-16   64px  Page-level breathing room
```

**FIXED VALUES — memorise these:**
- Screen edge margin: **16px** always
- Min touch target: **44×44pt** (HIG minimum), **48×48pt** (comfortable)
- Nav bar height: **44pt** standard, **96pt** large title
- Bottom safe area (iOS): **34px**
- Tab bar total height: **83px** (49pt content + 34pt safe area)
- List row single-line: **44px** tall
- List row two-line: **56–60px** tall
- List icon: **32×32px**, border-radius 6px
- Toggle track: **44×26px**, thumb **22×22px**

---

## TYPOGRAPHY SCALE

```
Role           Font role    Size   Weight  Line-height  Usage
──────────────────────────────────────────────────────────────────
Display        Display      38px   400     1.1          Hero, page titles (serif)
Title 1        Sans         28px   500     1.2          Screen titles
Title 2        Sans         22px   500     1.25         Section titles
Title 3        Sans         18px   500     1.3          Subsection headers
Headline       Sans         16px   500     1.4          List section headers
Body ★         Sans         15px   400     1.65         All reading text — FLOOR
Callout        Sans         14px   400     1.5          List rows, form bodies
Subheadline    Sans         13px   400     1.5          Secondary text
Footnote       Sans         12px   400     1.5          Metadata, timestamps
Eyebrow/Label  Sans         11px   500     —            UPPERCASE, 0.07em tracking
Mono           Mono         12px   400     —            Code, tokens, data
Display Num    Sans         48px+  300     1.0          Hero stats, balances
```

**RULES:**
- Two weights only in product UI: 400 regular + 500 medium
- Weight 300 only for display numbers (health stats, balances)
- 11px is the absolute floor — never go below
- Large Title (28px+) scrolls with content and collapses to nav bar
- Display numbers BREAK the scale on purpose — they are hero content
- Hierarchy from weight+opacity, not size jumps alone

---

## BORDER RADIUS SCALE

```
Token      Value    Usage
─────────────────────────────────────────────────
--r-xs     4px      Code tags, tiny chips, inner elements
--r-sm     6px      Badges, small buttons, list icons
--r-md     8px      ★ Buttons (default), inputs, small cards
--r-lg     12px     ★ Cards (default), panels, list containers
--r-xl     16px     Bottom sheets, large drawers
--r-2xl    24px     Modals, full-screen sheets
--r-full   999px    Pills, full-round chips, avatar circles
```

**Rule:** Never use the same radius nested inside the same radius.
Card is 12px → inner badges must be 6px or smaller.

---

## ELEVATION SYSTEM

Depth comes from background color stacking, not shadow theatrics.

```
Layer      Token         Color         Usage
──────────────────────────────────────────────────────────
Base       --bg          stone-50      Page background
Raised     --bg-raised   #FFFFFF       Cards, panels, sheets
Subtle     --bg-subtle   stone-100     Hover fills, input backgrounds
Float      --shadow-lg   (shadow)      Dropdowns, modals, tooltips
```

```css
--shadow-sm: 0 1px 2px rgba(15,14,11,.06), 0 1px 3px rgba(15,14,11,.08);
--shadow-md: 0 2px 6px rgba(15,14,11,.08), 0 4px 12px rgba(15,14,11,.08);
--shadow-lg: 0 8px 24px rgba(15,14,11,.10), 0 2px 8px rgba(15,14,11,.06);
```

---

## MOTION SYSTEM

```
Curve          Value                              Duration   Usage
────────────────────────────────────────────────────────────────────────
spring ★       cubic-bezier(.34,1.56,.64,1)       220ms      All physical interactions, drawers, toggles
smooth         cubic-bezier(.4,0,.2,1)             220ms      Data transitions, number updates, color changes
ease-out       cubic-bezier(0,0,.2,1)              280ms      Elements ENTERING screen
ease-in        cubic-bezier(.4,0,1,1)              200ms      Elements LEAVING screen
instant        linear                              16ms       Tap highlight, button press flash
```

```
Duration tokens:
--dur-fast:    120ms  Hover states, micro-feedback
--dur-base:    220ms  ★ Most transitions
--dur-slow:    380ms  Page transitions, skeleton→content
--dur-slower:  500ms  Onboarding, celebrations
```

**6 motion principles:**
1. Motion communicates spatial relationship — where did this element come from?
2. Interruption is first-class — animations must follow the finger mid-flight
3. Feedback is instant (16ms), animation is async (220ms) — separate them
4. Never animate without purpose — does this teach the user something?
5. Spring physics, never linear — always `cubic-bezier(.34,1.56,.64,1)` for physical UI
6. Always wrap in `@media (prefers-reduced-motion: no-preference)`

---

## AVAILABLE PALETTES

12 palettes. Each has its own file in `palettes/`. Each file contains:
- Full color ramp (50–950)
- CSS custom properties
- Semantic token mapping
- Paired font recommendation
- When to use / when NOT to use

```
Palette file              Mood / Context
─────────────────────────────────────────────────────────────
palettes/clay.md          Warm · Earthy · Confident     ← DEFAULT
palettes/slate.md         Cool · Professional · Trustworthy
palettes/forest.md        Natural · Grounded · Organic
palettes/ocean.md         Deep · Focused · Technical
palettes/sand.md          Minimal · Luxury · Editorial
palettes/ember.md         Bold · Energetic · Consumer
palettes/dusk.md          Purple · Creative · Premium
palettes/chalk.md         Pure white · Ultra-minimal · Clinical
palettes/obsidian.md      Dark · Dramatic · Developer tool
palettes/rose.md          Soft · Approachable · Health/wellness
palettes/moss.md          Muted green · Sustainable · Finance
palettes/midnight.md      Navy · Serious · Enterprise
```

---

## AVAILABLE FONT PAIRINGS

8 pairings. Each has its own file in `fonts/`. Each file contains:
- Display font + body font + mono font
- Google Fonts import URL
- CSS variables
- When to use
- Sample heading + body text rendering

```
Font file             Character
────────────────────────────────────────────────────────
fonts/dm.md           DM Serif Display + DM Sans + DM Mono    ← DEFAULT
fonts/editorial.md    Playfair Display + Source Sans 3 + Fira Code
fonts/humanist.md     Fraunces + Nunito + Jetbrains Mono
fonts/geometric.md    Plus Jakarta Sans + Inter + IBM Plex Mono
fonts/slab.md         Zilla Slab + Lato + Source Code Pro
fonts/swiss.md        Bebas Neue + Helvetica Neue + Courier New
fonts/warm.md         Crimson Pro + Karla + Space Mono
fonts/neutral.md      Work Sans + Manrope + Roboto Mono
```

---

## SEMANTIC COLOR TOKENS (apply to any palette)

These token names stay the same across ALL palettes.
Only the hex values change per palette.

```css
/* Backgrounds */
--bg                 Page background (lightest surface)
--bg-raised          Cards, panels, sheets (white or near-white)
--bg-subtle          Input backgrounds, hover fills

/* Borders */
--border             Default borders, dividers (light)
--border-strong      Input borders, emphasized (medium)

/* Text */
--text-primary       Headings, body — full opacity
--text-secondary     Labels, subtitles — ~65% opacity
--text-tertiary      Hints, timestamps, placeholders — ~45% opacity

/* Accent (ONE per palette) */
--accent             Primary buttons, focus rings, links
--accent-hover       Hover state on accent elements
--accent-subtle      Selected state, active nav backgrounds

/* Semantic — same across all palettes */
--success            Sage green — active, complete, verified
--success-subtle     Sage green tint background
--warning            Amber — pending, caution, expiring
--warning-subtle     Amber tint background
--danger             Red — error, destructive, overdue
--danger-subtle      Red tint background
--info               Slate blue — informational, links
--info-subtle        Slate blue tint background
```

---

## COMPONENT QUICK-REFERENCE

Full specs in `components/`. Summary:

### Buttons
```
Variant    Background       Text     Border         Use when
──────────────────────────────────────────────────────────────────
primary    --accent         white    none           THE one CTA per screen
secondary  transparent      primary  --border-strong   Alternatives
ghost      transparent      --accent none           Navigational, low-stakes
danger     red              white    none           Irreversible destructive only
```
Rules: ONE primary per screen. Labels are VERBS not nouns. Disable never hide.

### Form inputs
```
State      Border              Shadow ring
─────────────────────────────────────────────────
Default    --border-strong     none
Hover      stone-400           none
Focus      --accent            0 0 0 3px accent@12%
Error      --danger            0 0 0 3px danger@12%
Success    --success           0 0 0 3px success@12%
```
Rules: Label above always visible. Validate on blur not submit. Ring is additive (box-shadow), never layout-shifting (border-width).

### Cards
```
Type        Padding    Radius    Shadow    Border
──────────────────────────────────────────────────────
Stat        14px       --r-md    none      none (bg-subtle fill)
Content     20px       --r-lg    none      1px --border
Profile     20px       --r-lg    none      1px --border
Floating    20px       --r-xl    --shadow-lg  none
```

### Badges
```
Variant    Background      Text color
────────────────────────────────────────
neutral    bg-subtle       text-secondary
accent     accent-100      accent-700
success    success-subtle  success-700
warning    warning-subtle  warning-600
danger     danger-subtle   danger-600
info       info-subtle     info-700
```
Size: 11px, font-weight 500, padding 3px 8px, border-radius --r-sm.

---

## DO / DON'T — THE FAST RULES

```
COLOR
✓ One accent per product. Semantic colors are not accents.
✓ Use tokens always. var(--accent) not #D97530.
✓ Text on tint: use darker stop from same ramp. Never generic black.
✗ Color for decoration. Every color must have a semantic job.
✗ Hardcode hex values in components.

TYPOGRAPHY
✓ Two weights: 400 + 500. That's it for product UI.
✓ 15px body minimum. 11px absolute floor.
✓ Weight+opacity for hierarchy, not size jumps.
✗ Six different font sizes on one screen.
✗ 12px body text to "fit more content".

SPACING
✓ 16px screen edge. Every screen. Every device. Always.
✓ Space to group. 8px between related, 24px between sections.
✗ Different margins on different screens.
✗ Dividers for everything — use space instead.

COMPONENTS
✓ One primary button per screen.
✓ Button labels are verbs: "Save changes" not "Confirm".
✓ Loading state on every async button.
✗ Three primary buttons on one screen.
✗ Hiding buttons based on state — disable instead.

MOTION
✓ Spring curves for physical interactions.
✓ 220ms base duration.
✓ Feedback at 16ms, animation at 220ms — separate them.
✗ Animate for decoration.
✗ Linear easing for anything visible.
```

---

## ASKING THE USER FOR PALETTE + FONT

When building a UI and no palette/font is specified, ask:

> "Which vibe fits your project? I can apply any of these palette + font combos:
>
> **Warm & Earthy** — Clay palette + DM Serif (confident, product, SaaS)
> **Clean & Professional** — Slate palette + Plus Jakarta Sans (B2B, dashboards)
> **Natural & Grounded** — Forest palette + Fraunces (wellness, editorial, eco)
> **Deep & Focused** — Ocean palette + Zilla Slab (developer tools, docs)
> **Ultra Minimal** — Sand palette + Work Sans (luxury, portfolio, fashion)
> **Bold & Consumer** — Ember palette + Bebas Neue (apps, landing pages)
> **Creative & Premium** — Dusk palette + Playfair Display (creative tools, media)
> **Dark Mode** — Obsidian palette + DM Sans (dev tools, code, terminal)
>
> Or describe your product and I'll pick the best match."

---

## WORKFLOW FOR BUILDING A UI WITH THIS SKILL

```
1. Read SKILL.md (this file)
2. Determine palette — read palettes/{name}.md
3. Determine font — read fonts/{name}.md
4. Apply 5 core principles
5. Use spacing system (8pt grid, 16px edges)
6. Use type scale (two weights, 15px body floor)
7. Use semantic tokens (var(--accent), var(--bg), etc.)
8. Reference component specs for exact values
9. Output clean HTML/CSS with CSS custom properties
10. Test: does it look good in dark mode? Are touch targets ≥44px?
```

---

## AVAILABLE INSIGHTS

Deep-dive reference files for strategic design decisions.

```
File                              Content
──────────────────────────────────────────────────────────────────────
insights/app-breakdowns.md        Health · Wallet · Maps · App Store · Music
                                  Each broken down: core insight, spacing,
                                  color, typography, steal-this principle.
                                  Also includes: "which app to learn from" table.

insights/screen-patterns.md       5 screen archetypes with full anatomy,
                                  key measurements, CSS skeletons, and rules.
                                  List · Dashboard · Detail · Form · Empty state
```

**When to read app-breakdowns.md:**
- User asks "how should I design a dashboard / marketplace / settings screen"
- User wants to know what makes a great UI feel premium
- Building anything in the categories: finance, health, navigation, media, marketplace

**When to read screen-patterns.md:**
- Starting a new screen from scratch
- User asks "how do I structure this screen"
- Building list, dashboard, form, detail, or empty-state screens
