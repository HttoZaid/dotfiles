# Typography

The single most identity-defining decision in a UI. Picking the right typeface and
applying it correctly distinguishes taste-driven work from default AI output more
than any other choice.

---

## The Typeface Inventory (2024–2026)

### Free / Open-Source (use freely)

| Typeface | Designer / Source | Use |
|---|---|---|
| **Geist Sans + Geist Mono** | Vercel + Basement Studio (Andrés Briganti, Mateo Zaragoza; dev by Guido Ferreyra); OFL; launched Oct 27, 2023 | Default for product apps and modern SaaS. Influenced by Inter, Univers, SF Mono, SF Pro, Suisse International, ABC Diatype. |
| **Inter + Inter Display** | Rasmus Andersson | Workhorse. Use Inter Display for ≥24px. Differentiate from default by combining with negative tracking and weight contrast. |
| **Mona Sans + Hubot Sans** | GitHub | Variable display + text pair. GitHub-style modern feel. |
| **Pretendard** | Kil Hyung-jin | Korean-first variable, excellent fallback for multi-script. |
| **Manrope** | Mikhail Sharanda | Geometric sans, friendlier than Inter. |
| **IBM Plex Sans / Mono / Serif** | IBM | Corporate-leaning, very capable. |
| **JetBrains Mono** | JetBrains | Developer mono with strong ligatures. |
| **Public Sans** | USWDS | Government-tier neutral, good for civic / non-profit. |
| **Söhne fallback** | Inter weight 300 + `ss01` + `-0.04em` tracking | Open-source approximation of Stripe's Söhne. |
| **Editorial New** | Pangram Pangram | Free for personal use, paid for commercial. Premium serif display. |
| **DM Sans / DM Serif Display** | Google Fonts | Reliable web pair, slightly under-used so still feels distinct. |

### Licensed (commercial use requires purchase)

| Typeface | Foundry | Used by | Notes |
|---|---|---|---|
| **Söhne** | Klim Type Foundry | Stripe, Airbnb (display) | Weight 300 at large sizes, `ss01` for single-story `a`. |
| **ABC Diatype / Diatype Mono** | Dinamo | Linear marketing, Vercel-adjacent | Editorial premium. |
| **ABC Whyte** | Dinamo | Various | Editorial display variant. |
| **GT America / GT Walsheim / GT Eesti** | Grilli Type | Many premium brands | American grotesque tradition. |
| **NB International** | Neubau | Editorial / agency sites | Swiss precision. |
| **Söhne Mono** | Klim | Stripe code blocks | Pairs with Söhne. |
| **Roobert** | Displaay | OpenAI brand | Geometric with personality. |
| **Berkeley Mono** | Berkeley Graphics | Editorial / dev tools | Premium mono. |
| **Tobias** | Klim | Editorial serif | High contrast display serif. |
| **Migra** | Pangram Pangram | Editorial display | Modern serif with character. |
| **Times Now** | Pangram Pangram | Editorial sites | Reimagined Times for the web. |
| **PP Editorial New** | Pangram Pangram | Editorial display | Refined serif, free for personal use. |

### System (free, platform-bound)

| Typeface | Platform | When to use |
|---|---|---|
| **SF Pro / SF Pro Display / SF Mono** | iOS, macOS | Native iOS / macOS apps. Variable, 17–28pt optical interpolation. |
| **Roboto Flex** | Android (M3) | Native Android apps. Weight 100–1000, width 25–151%. |
| **Segoe UI Variable** | Windows | Windows apps. |
| **system-ui** | All | Marketing for performance-critical sites. Falls back to platform default. |

---

## Geist — The New Default

Vercel commissioned Geist Sans + Geist Mono from Basement Studio. **Designers: Andrés
Briganti, Mateo Zaragoza, with font development by Guido Ferreyra.** Publicly launched
**October 27, 2023**.

> "Geist is influenced and inspired by Inter, Univers, SF Mono, SF Pro, Suisse
> International, ABC Diatype Mono, and ABC Diatype."
> — github.com/vercel/geist-font

Why Geist as Grain's default:
- **Free (OFL)** — no licensing barrier.
- **Variable** — single file, all weights.
- **Designed for the web** — optimized at 14–18px sizes that dominate UI.
- **Pairs natively with Geist Mono** — same designer, same proportions.
- **Not Inter** — escape the median.

### Installation (Next.js / Tailwind v4)

```bash
npm install geist
```

```tsx
// app/layout.tsx
import { GeistSans } from "geist/font/sans";
import { GeistMono } from "geist/font/mono";

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${GeistSans.variable} ${GeistMono.variable}`}>
      <body>{children}</body>
    </html>
  );
}
```

```css
@theme {
  --font-sans: var(--font-geist-sans), system-ui, sans-serif;
  --font-mono: var(--font-geist-mono), ui-monospace, monospace;
}
```

---

## The Stripe Recipe — Söhne at Weight 300

Stripe uses Söhne at **weight 300** with the following settings:

```css
:root {
  --font-display: "Söhne", "Inter", system-ui, sans-serif;
  font-feature-settings: "ss01" "tnum";
}

h1 {
  font-family: var(--font-display);
  font-weight: 300;
  font-size: 56px;
  line-height: 1.05;
  letter-spacing: -1.4px;       /* roughly -0.025em */
}

h2 {
  font-weight: 300;
  font-size: 40px;
  line-height: 1.1;
  letter-spacing: -1px;
}

body {
  font-weight: 400;
  font-size: 17px;
  line-height: 1.5;
  letter-spacing: -0.2px;
}

.tabular {
  font-variant-numeric: tabular-nums;
}
```

### Key details

- `ss01` is Söhne's stylistic set — single-story `a`. Distinctive Stripe trait.
- `tnum` is tabular numerals — every digit is the same width. Used in monetary cells,
  prices, dashboard numbers.
- Weight 300 at large sizes only. Body stays at 400 (anti-slop rule #25).
- Letter-spacing scales: -1.4px at 56px → -1px at 40px → -0.2px at 17px. The smaller
  the size, the less negative tracking.
- **Open-source fallback**: Inter weight 300 with the same `ss01` (Inter has a single-
  story `a` stylistic set too) and the same tracking values.

---

## Vercel / Geist Recipe

Vercel marketing site uses:

```css
:root {
  --font-display: var(--font-geist-sans);
  --letter-spacing-display: -0.04em;
  --line-height-display: 1.15;
}

h1 {
  font-family: var(--font-display);
  font-weight: 600;
  font-size: clamp(3rem, 8vw, 5rem);
  line-height: var(--line-height-display);
  letter-spacing: var(--letter-spacing-display);
}

body {
  font-family: var(--font-display);
  font-weight: 400;
  font-size: 16px;
  line-height: 1.6;
  letter-spacing: 0;
}
```

Vercel uses Geist for both display AND body — single family, weight contrast does
the differentiation work.

---

## Apple SF Pro — The System Approach

SF Pro variable handles optical sizing automatically:

- **SF Text** (≤19pt classically; now interpolated)
- **SF Display** (≥20pt classically; now interpolated)

Since iOS 14 (WWDC20 #10175), the optical sizing interpolates **continuously**
between 17pt and 28pt. Above 28pt, you get full SF Display; below 17pt, full SF Text.
In between, the optical axis blends.

### iOS text styles (Dynamic Type)

| Style | Default size | Weight |
|---|---|---|
| Large Title | 34pt | Regular |
| Title 1 | 28pt | Regular |
| Title 2 | 22pt | Regular |
| Title 3 | 20pt | Regular |
| Headline | 17pt | Semibold |
| Body | 17pt | Regular |
| Callout | 16pt | Regular |
| Subheadline | 15pt | Regular |
| Footnote | 13pt | Regular |
| Caption 1 | 12pt | Regular |
| Caption 2 | 11pt | Regular |

Apple rule: **Use the text styles, don't hardcode point sizes.** Dynamic Type users
scale these globally; hardcoded `font: .system(size: 17)` doesn't scale.

```swift
Text("Hello")
  .font(.body)              // ← right
Text("Hello")
  .font(.system(size: 17))  // ← wrong, ignores Dynamic Type
```

---

## Material 3 Expressive — 15-Token Scale

Material 3 has a 15-token scale (5 roles × 3 sizes). Roboto Flex is the default
typeface, variable across weight 100–1000 and width 25–151%.

| Role | Size | Use |
|---|---|---|
| Display Large | 57sp | Hero text |
| Display Medium | 45sp | Section headers |
| Display Small | 36sp | Page titles |
| Headline Large | 32sp | High-emphasis headers |
| Headline Medium | 28sp | |
| Headline Small | 24sp | |
| Title Large | 22sp | Card titles |
| Title Medium | 16sp (medium weight) | List item titles |
| Title Small | 14sp (medium) | |
| Body Large | 16sp | Body text |
| Body Medium | 14sp | Secondary body |
| Body Small | 12sp | Caption-adjacent |
| Label Large | 14sp (medium) | Button labels |
| Label Medium | 12sp (medium) | |
| Label Small | 11sp (medium) | |

Material 3 Expressive (May 13, 2025) supports more weight variation across the same
scale, encouraging "Bold over Big" — using weight to convey hierarchy rather than
size.

---

## Font Pairings That Work

### 1. Single-family contrast (Vercel, Linear)
- **Geist Sans** for everything, weight contrast (400 body / 600 display).
- **Inter** for everything (with tracking discipline).
- **Söhne** for everything (Stripe).

This is the safest, most modern approach. Two weights of one family beats two families.

### 2. Display + body sans
- **Inter Display** (headings) + **Inter** (body) + **JetBrains Mono** (code).
- **Mona Sans** (display) + **Mona Sans** (body, lighter weight).
- **GT America Display** + **GT America Text** + **GT America Mono**.

### 3. Editorial serif + sans
- **Editorial New** (display serif) + **Inter** (body sans).
- **Migra** (display serif) + **Geist** (body).
- **Tobias** (display serif) + **Söhne** (body).
- **Times Now** (editorial serif) + **system-ui** body.

Best for: blogs, editorial sites, agencies, premium brands.

### 4. Geometric + neutral
- **GT Walsheim** (geometric display) + **Inter** (body).
- **Manrope** (geometric) + **Inter** (body).

### 5. Mono-heavy (engineering, brutalist)
- **Berkeley Mono** for everything (premium).
- **JetBrains Mono** for everything.
- **Geist Mono** for everything.

Use sparingly — mono body fatigues at length. Best for short-form copy, terminals,
dev tools, technical aesthetic.

### 6. System fonts (performance)
- `system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`
- Free, instant, platform-native. Trade-off: every platform looks different. Use
  when performance is critical (marketing sites where LCP matters).

### Pairings to AVOID

- **Inter + Inter** at the same weight everywhere — slop median.
- **Default browser stack** ("Helvetica Neue, Arial").
- **Three+ families** in one project — pick max two, or one variable.
- **Roboto + anything** — Roboto is the Android default; on web, it screams "I used
  the wrong default." Use Roboto Flex on native Android, not web.
- **Comic Sans, Papyrus, Brush Script** — banned regardless of context.

---

## Optical Sizing Rules

Type behavior changes by size. Apply these per zone:

### Display (≥40px)
- **Tracking**: `-0.04em` to `-0.06em` (visually tight).
- **Line height**: 1.0 to 1.1 (display heads almost touch).
- **Weight**: Regular (400) or Medium (500) — large sizes carry weight naturally.
- **Optical**: use display-optimized variant (`Inter Display`, `SF Display`, `Geist Display`).
- **Cap height** does the heavy lifting; descenders and ascenders are pulled in.

### Subhead (24–32px)
- **Tracking**: `-0.02em` to `-0.03em`.
- **Line height**: 1.15 to 1.25.
- **Weight**: Medium (500) or Semibold (600).

### Section header (18–22px)
- **Tracking**: `-0.005em` to `-0.01em`.
- **Line height**: 1.3 to 1.4.
- **Weight**: Semibold (600) or Bold (700).

### Body (15–18px)
- **Tracking**: 0 (neutral).
- **Line height**: 1.5 to 1.7.
- **Weight**: Regular (400) — Medium (500) only if the typeface reads thin.
- **Max line length**: 60–75 characters (`max-width: 65ch`).

### Caption / Helper (12–14px)
- **Tracking**: `+0.005em` to `+0.01em` (positive to compensate for small size).
- **Line height**: 1.4.
- **Weight**: Regular (400) — reduced opacity, not lighter weight.

### Micro (10–11px)
- **Tracking**: `+0.02em` to `+0.05em`.
- **Weight**: Medium (500) for legibility.
- **Use**: timestamps, badges, micro-labels only. Don't use for paragraph text.

### Uppercase labels
- **Tracking**: `+0.05em` to `+0.08em`.
- **Use**: section dividers, table column headers, KPI labels.
- **Don't**: uppercase paragraph text — illegible at length.

---

## Specific Tracking by Size (Quick Reference)

```css
.text-display { font-size: 4rem;    letter-spacing: -0.04em; line-height: 1.05; }
.text-7xl     { font-size: 4.5rem;  letter-spacing: -0.04em; line-height: 1.05; }
.text-6xl     { font-size: 3.75rem; letter-spacing: -0.035em; line-height: 1.08; }
.text-5xl     { font-size: 3rem;    letter-spacing: -0.03em; line-height: 1.1; }
.text-4xl     { font-size: 2.25rem; letter-spacing: -0.025em; line-height: 1.15; }
.text-3xl     { font-size: 1.875rem; letter-spacing: -0.02em; line-height: 1.2; }
.text-2xl     { font-size: 1.5rem;  letter-spacing: -0.015em; line-height: 1.25; }
.text-xl      { font-size: 1.25rem; letter-spacing: -0.01em; line-height: 1.3; }
.text-lg      { font-size: 1.125rem; letter-spacing: -0.005em; line-height: 1.4; }
.text-base    { font-size: 1rem;    letter-spacing: 0;        line-height: 1.6; }
.text-sm      { font-size: 0.8125rem; letter-spacing: 0;      line-height: 1.5; }
.text-xs      { font-size: 0.75rem; letter-spacing: 0.005em;  line-height: 1.45; }
```

---

## Font Loading (Web Performance)

Type affects Core Web Vitals (LCP especially). Load fonts properly:

### Method 1 — `next/font` (Next.js, preferred)

```tsx
import { Geist, Geist_Mono } from "next/font/google";

const sans = Geist({ subsets: ["latin"], variable: "--font-sans" });
const mono = Geist_Mono({ subsets: ["latin"], variable: "--font-mono" });
```

Automatic: subsetting, self-hosting, preload, `font-display: swap`, no layout shift.

### Method 2 — Self-hosted `@font-face`

```css
@font-face {
  font-family: "Geist";
  src: url("/fonts/Geist-Variable.woff2") format("woff2-variations");
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
}
```

Add `<link rel="preload" as="font" type="font/woff2" crossorigin>` in `<head>` for
above-the-fold fonts.

### Rules

- Variable fonts (one file, all weights) beat multiple weight files.
- `font-display: swap` is the default; `optional` for performance-critical pages
  (drops the font entirely if it doesn't load fast enough).
- Subset to needed glyphs only (Latin Extended typically enough).
- WOFF2 only — don't ship WOFF, TTF, or older formats.
- Preload no more than 2 fonts. Each preload competes with LCP image.

### Reducing CLS from font swap

```css
:root {
  --font-fallback: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

body {
  font-family: "Geist", var(--font-fallback);
  font-synthesis: none;
  font-size-adjust: 0.5;        /* normalize x-height to fallback */
}
```

`font-size-adjust` (broadly supported since 2024) reduces the visual jump when the
custom font swaps in.

---

## Pairing Decision Tree

```
Building a SaaS app?
  └→ Geist Sans + Geist Mono (default)

Building a marketing site?
  ├→ Premium / agency feel?
  │   └→ Editorial New / Migra (display) + Inter / Geist (body)
  ├→ Tech-forward / startup?
  │   └→ Geist (single family) OR Söhne (licensed)
  └→ Corporate / enterprise?
      └→ Inter (display) + Inter (body) + JetBrains Mono

Building an editorial / blog?
  └→ Editorial New (display) + Public Sans / Inter (body)

Building a developer tool / terminal?
  └→ Berkeley Mono OR JetBrains Mono OR Geist Mono (single family)

Building iOS native?
  └→ SF Pro (system) — never override

Building Android native?
  └→ Roboto Flex (system) — never override

Building cross-platform Flutter?
  └→ Inter (works everywhere) OR system font per platform
```

---

## Hard Rules

1. **Two families max** per project (or one variable).
2. **Body never below 16px desktop / 17px mobile.**
3. **Body never weight 300** — illegible at small sizes.
4. **Display ≥32px always uses negative tracking.**
5. **Display uses display-optimized variant** when available (Inter Display, SF Display).
6. **Line length ≤75 characters** (`max-width: 65ch`).
7. **Tabular numerals** (`font-variant-numeric: tabular-nums`) on every monetary /
   metric value.
8. **System fonts** for performance-critical marketing (LCP <2.5s).
9. **`next/font`** or `@font-face` with `font-display: swap` — never `<link>` to
   Google Fonts CSS (blocks render).
10. **No fake bold / fake italic** — turn off `font-synthesis` if the typeface ships
    only one weight.

---

## Examples — Copy-Paste Setups

### Vercel-style (Geist single family)

```css
@theme {
  --font-sans: "Geist", system-ui, sans-serif;
  --font-mono: "Geist Mono", ui-monospace, monospace;
}
h1 { font-weight: 600; font-size: 4rem; line-height: 1.1; letter-spacing: -0.04em; }
h2 { font-weight: 600; font-size: 2.5rem; line-height: 1.15; letter-spacing: -0.03em; }
body { font-weight: 400; font-size: 1rem; line-height: 1.6; }
```

### Stripe-style (Söhne / Inter weight 300)

```css
@theme {
  --font-sans: "Söhne", "Inter", system-ui, sans-serif;
  font-feature-settings: "ss01" "tnum";
}
h1 { font-weight: 300; font-size: 3.5rem; line-height: 1.05; letter-spacing: -1.4px; }
h2 { font-weight: 300; font-size: 2.5rem; line-height: 1.1; letter-spacing: -1px; }
body { font-weight: 400; font-size: 17px; line-height: 1.5; letter-spacing: -0.2px; }
.tabular { font-variant-numeric: tabular-nums; }
```

### Linear-style (Inter with discipline)

```css
@theme {
  --font-sans: "Inter Display", "Inter", system-ui, sans-serif;
}
h1 { font-weight: 600; font-size: 3rem; line-height: 1.1; letter-spacing: -0.03em; }
body { font-weight: 400; font-size: 14px; line-height: 1.5; }  /* tight for density */
```

### Editorial-style (Migra + Geist)

```css
@theme {
  --font-display: "Migra", Georgia, serif;
  --font-sans: "Geist", system-ui, sans-serif;
}
h1 { font-family: var(--font-display); font-weight: 400; font-size: 5rem; line-height: 1; letter-spacing: -0.02em; }
body { font-family: var(--font-sans); font-weight: 400; font-size: 18px; line-height: 1.7; }
```
