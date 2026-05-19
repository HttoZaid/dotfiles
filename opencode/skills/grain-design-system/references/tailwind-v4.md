# Tailwind v4

Grain assumes Tailwind v4 (CSS-first config via `@theme`, OKLCH color space, native
container queries, view transitions). v3 patterns still work but the v4 approach is
the default in this skill.

---

## Why CSS-First Config

In v4, Tailwind moved configuration from `tailwind.config.js` to a CSS-native
`@theme` directive. Three reasons:

1. **One source of truth**: design tokens live in CSS, where they're used.
2. **Native CSS variables**: every `@theme` token becomes a real `--variable`,
   usable outside Tailwind utilities (in raw CSS, in inline styles, in components).
3. **Smaller config surface**: no JS build step for design tokens, no separate
   token JSON.

---

## The `@theme` Block

```css
/* app/globals.css or styles/globals.css */
@import "tailwindcss";

@theme {
  /* Color tokens (OKLCH) */
  --color-bg: oklch(99% 0.004 270);
  --color-fg: oklch(20% 0.04 265);
  --color-accent: oklch(60% 0.18 250);

  /* Custom radii */
  --radius-pill: 9999px;
  --radius-card: 0.5rem;

  /* Custom fonts */
  --font-sans: "Geist", system-ui, sans-serif;
  --font-mono: "Geist Mono", ui-monospace, monospace;

  /* Custom durations */
  --duration-instant: 0ms;
  --duration-fast: 100ms;

  /* Custom easings */
  --ease-fluid: cubic-bezier(0.3, 0, 0, 1);
}
```

Every `--color-*` token auto-generates utility classes (`bg-*`, `text-*`, `border-*`,
`fill-*`, `stroke-*`, etc.). Same for `--font-*`, `--radius-*`, `--text-*`,
`--shadow-*`, and a few others.

### Naming conventions in `@theme`

| Prefix | Generates |
|---|---|
| `--color-*` | `bg-*`, `text-*`, `border-*`, `ring-*`, `fill-*`, `stroke-*`, `accent-*` |
| `--font-*` | `font-*` (family) |
| `--text-*` | `text-*` (size) |
| `--font-weight-*` | `font-*` (weight, e.g., `font-medium`) |
| `--leading-*` | `leading-*` |
| `--tracking-*` | `tracking-*` |
| `--radius-*` | `rounded-*` |
| `--shadow-*` | `shadow-*` |
| `--spacing` (single var) | scales `p-*`, `m-*`, `w-*`, `gap-*` |
| `--breakpoint-*` | `sm:`, `md:`, `lg:`, etc. |
| `--container-*` | `container-*` (sizes for container queries) |
| `--ease-*` | `ease-*` |
| `--duration-*` | `duration-*` |
| `--blur-*` | `blur-*` |

So defining:
```css
@theme {
  --color-accent: oklch(60% 0.18 250);
  --radius-pill: 9999px;
}
```

Automatically gives you:
```html
<button class="bg-accent text-accent-fg rounded-pill">
```

### Theme functions

Use `--color-*` etc. directly in custom CSS:
```css
.custom-shadow {
  box-shadow: 0 4px 12px var(--color-fg) / 0.1;
}
```

Or use the modern color-mix:
```css
.custom-bg {
  background: color-mix(in oklch, var(--color-accent) 20%, transparent);
}
```

---

## OKLCH — The New Color Space

Tailwind v4 uses OKLCH by default. Three components: **Lightness (0–100%),
Chroma (0–~0.4), Hue (0–360°)**.

```css
oklch(60% 0.18 250)
```

- `60%` lightness — perceptually 60% bright
- `0.18` chroma — saturation (max ≈ 0.4)
- `250` hue — blue range (0=red, 30=orange, 60=yellow, 120=green, 180=cyan,
  240=blue, 300=magenta)

### Why OKLCH > HSL

HSL is perceptually broken: `hsl(60, 100%, 50%)` (yellow) appears much lighter than
`hsl(240, 100%, 50%)` (blue), even though both claim 50% lightness. OKLCH fixes this.

### Practical recipes

```css
/* A monochrome scale by lightness */
oklch(98% 0.005 270)    /* surface */
oklch(92% 0.005 270)    /* border */
oklch(75% 0.015 270)    /* subtle */
oklch(55% 0.02 270)     /* muted */
oklch(20% 0.04 265)     /* fg */

/* Same hue, more chroma = brand accent */
oklch(60% 0.18 250)     /* primary blue */
oklch(65% 0.13 250)     /* primary blue lighter */
oklch(48% 0.2 250)      /* primary blue darker */

/* Status colors at consistent lightness for harmony */
oklch(55% 0.16 145)     /* green (success) */
oklch(70% 0.16 75)      /* yellow (warning) */
oklch(58% 0.22 25)      /* red (error) */
oklch(60% 0.13 230)     /* blue (info) */

/* Hue rotation for related-but-distinct */
oklch(60% 0.18 250)     /* primary */
oklch(60% 0.18 270)     /* primary, slight violet shift */
oklch(60% 0.18 290)     /* primary, more violet */
```

### Color with alpha

```css
oklch(60% 0.18 250 / 0.5)     /* 50% opacity */
oklch(20% 0.04 265 / 0.08)    /* near-black scrim, 8% */
```

### Convert sRGB hex to OKLCH

Use oklch.com (Erik Kennedy's interactive converter) or the `@csstools/postcss-oklab-function`
plugin's tooling. Many designers eyeball it: `#7C3AED` ≈ `oklch(54% 0.25 290)`.

---

## Container Queries (Native in v4)

Style components based on their container's width, not the viewport.

```css
@theme {
  --container-narrow: 480px;
  --container-wide: 800px;
}
```

```html
<div class="@container">
  <article class="grid grid-cols-1 @md:grid-cols-2 @xl:grid-cols-3">
    ...
  </article>
</div>
```

The `@container` class enables container queries on the element. Inside, `@md:`,
`@xl:` prefixes target the container's width breakpoints.

### When to use container queries over media queries

- **Component-level responsiveness**: a card looks one way in a sidebar (narrow), another way in main content (wide).
- **Reusable layouts**: same component in multiple contexts.
- **Sidebar collapse**: when sidebar shrinks, its contents respond.

Use media queries for page-level layout (header, footer, main grid).

### Example: responsive card

```tsx
<div className="@container">
  <Card className="grid grid-cols-1 @sm:grid-cols-[120px_1fr] gap-4">
    <img className="w-full @sm:w-30 aspect-square rounded-md" />
    <div>
      <h3 className="text-base @sm:text-lg">Title</h3>
      <p className="text-sm text-muted">Description</p>
    </div>
  </Card>
</div>
```

When the container is narrow, the image stacks above. When wide, image goes left, content right.

---

## `@starting-style` for Enter Animations

Native CSS for enter animations without JS. Defines the "from" state for transitions.

```css
.modal {
  opacity: 1;
  transform: scale(1);
  transition: opacity 200ms, transform 200ms;
}

.modal[data-state="open"] {
  @starting-style {
    opacity: 0;
    transform: scale(0.95);
  }
}
```

When the modal is added to the DOM with `data-state="open"`, it animates from
`opacity: 0, scale: 0.95` to `opacity: 1, scale: 1`.

---

## View Transitions API

Native page transitions between routes.

```css
::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 250ms;
}

::view-transition-old(root) {
  animation: fade-out 250ms ease-in;
}
::view-transition-new(root) {
  animation: fade-in 250ms ease-out;
}
```

In Next.js App Router:
```tsx
"use client";
import { unstable_ViewTransition as ViewTransition } from "next/navigation";

<ViewTransition>
  {children}
</ViewTransition>
```

Used sparingly. Page transitions in product apps are usually instant.

---

## CSS Layers (Layer-Aware Tailwind)

Tailwind v4 uses CSS `@layer` for cascade control:

```css
@layer base, components, utilities;

@layer base {
  body { font-family: var(--font-sans); }
}

@layer components {
  .btn {
    padding: 0.5rem 1rem;
    border-radius: var(--radius-pill);
  }
}

@layer utilities {
  /* Tailwind utilities live here, can be overridden by inline styles */
}
```

Custom CSS goes in `@layer components` or `@layer utilities` depending on whether
it's a reusable class or a one-off utility.

---

## Dark Mode in v4

Two approaches:

### 1. Media query (system-driven only)
```css
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: oklch(15% 0.02 270);
    --color-fg: oklch(95% 0.01 270);
  }
}
```

### 2. Class-based (user toggleable, recommended)
```css
@theme {
  /* Light mode defaults */
  --color-bg: oklch(99% 0.004 270);
}

.dark {
  --color-bg: oklch(15% 0.02 270);
}
```

Toggle by adding/removing `.dark` on `<html>`:
```tsx
function ThemeToggle() {
  return (
    <button onClick={() => document.documentElement.classList.toggle("dark")}>
      Toggle theme
    </button>
  );
}
```

For Next.js + system preference + persistent user choice, use `next-themes`:
```tsx
import { ThemeProvider } from "next-themes";

<ThemeProvider attribute="class" defaultTheme="system" enableSystem>
  {children}
</ThemeProvider>
```

---

## Arbitrary Values vs Tokens

Tailwind allows `bg-[#ff0000]` and `text-[14.5px]` — **avoid them**.

```tsx
{/* Bad */}
<div className="bg-[#7c3aed] text-[15px] rounded-[10px]">

{/* Good */}
<div className="bg-accent text-base rounded-lg">
```

Arbitrary values defeat the design system. Use them only for genuine one-offs
(e.g., a hero image height that has no semantic meaning).

Exception: short-term scaffolding while iterating. Replace with tokens before
shipping.

---

## Common v4 Utilities You'll Reach For

### Sizing
- `size-12` (1 prop for width + height)
- `w-fit`, `w-min`, `w-max`
- `min-w-0` (essential for flex children that need to truncate)

### Spacing
- `space-x-3`, `space-y-3` (gap between children)
- `gap-3` (preferred over `space-*` in modern flex/grid)

### Layout
- `flex`, `grid`, `inline-flex`
- `flex-col`, `flex-row`
- `items-center`, `justify-between`, `place-items-center`
- `grid-cols-1`, `grid-cols-12`, `auto-cols-fr`

### Position
- `absolute`, `relative`, `fixed`, `sticky`
- `inset-0`, `inset-x-0` (top+right+bottom+left at once)
- `top-0`, `left-1/2 -translate-x-1/2` (center horizontally)

### Container queries
- `@container` (enable on element)
- `@sm:`, `@md:`, `@xl:` (target container width)

### Modern selectors
- `[&_a]:underline` (target nested elements)
- `has-[input:checked]:bg-accent` (parent-based styles via `:has`)
- `not-[:first-child]:border-t` (negation)

### Logical properties (RTL-friendly)
- `ms-3` (margin-inline-start, becomes `mr-3` in RTL)
- `pe-2` (padding-inline-end)
- `border-s`, `border-e`

---

## Grain's Recommended `globals.css`

```css
@import "tailwindcss";

@theme {
  /* ===== COLOR ===== */
  --color-bg: oklch(99% 0.004 270);
  --color-surface: oklch(98% 0.004 270);
  --color-surface-2: oklch(96% 0.005 270);
  --color-fg: oklch(20% 0.04 265);
  --color-muted: oklch(55% 0.02 270);
  --color-subtle: oklch(75% 0.015 270);
  --color-border: oklch(92% 0.005 270);
  --color-border-strong: oklch(85% 0.008 270);
  --color-ring: oklch(60% 0.18 250);

  --color-accent: oklch(60% 0.18 250);
  --color-accent-fg: oklch(99% 0.005 250);
  --color-accent-soft: oklch(96% 0.04 250);
  --color-accent-strong: oklch(52% 0.2 250);

  --color-success: oklch(55% 0.16 145);
  --color-success-fg: oklch(99% 0.01 145);
  --color-success-soft: oklch(95% 0.05 145);
  --color-warning: oklch(70% 0.16 75);
  --color-warning-fg: oklch(20% 0.05 75);
  --color-warning-soft: oklch(95% 0.06 75);
  --color-error: oklch(58% 0.22 25);
  --color-error-fg: oklch(99% 0.01 25);
  --color-error-soft: oklch(95% 0.05 25);
  --color-info: oklch(60% 0.13 230);
  --color-info-fg: oklch(99% 0.005 230);
  --color-info-soft: oklch(95% 0.04 230);

  /* ===== RADIUS ===== */
  --radius-none: 0;
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-xl: 0.75rem;
  --radius-2xl: 1rem;
  --radius-pill: 9999px;

  /* ===== TYPOGRAPHY ===== */
  --font-sans: "Geist", system-ui, sans-serif;
  --font-mono: "Geist Mono", ui-monospace, monospace;
  --font-display: "Geist", system-ui, sans-serif;

  --text-xs: 0.75rem;
  --text-sm: 0.8125rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 1.875rem;
  --text-4xl: 2.25rem;
  --text-5xl: 3rem;
  --text-6xl: 3.75rem;
  --text-7xl: 4.5rem;
  --text-display: clamp(3.5rem, 10vw, 7.5rem);

  --tracking-display: -0.04em;
  --tracking-tight: -0.01em;
  --tracking-body: 0em;
  --tracking-caption: 0.01em;
  --tracking-uppercase: 0.05em;

  --leading-display: 1.05;
  --leading-tight: 1.2;
  --leading-snug: 1.4;
  --leading-body: 1.6;
  --leading-loose: 1.75;

  /* ===== MOTION ===== */
  --duration-instant: 0ms;
  --duration-fast: 100ms;
  --duration-normal: 200ms;
  --duration-slow: 300ms;
  --duration-marketing: 400ms;

  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  --ease-in: cubic-bezier(0.4, 0, 1, 1);
  --ease-fluid: cubic-bezier(0.3, 0, 0, 1);
  --ease-snappy: cubic-bezier(0.2, 0, 0, 1);
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);

  /* ===== ELEVATION ===== */
  --shadow-pop:     0 1px 2px oklch(20% 0.04 265 / 0.06),
                    0 4px 8px oklch(20% 0.04 265 / 0.04);
  --shadow-overlay: 0 4px 12px oklch(20% 0.04 265 / 0.08),
                    0 12px 24px oklch(20% 0.04 265 / 0.06);
  --shadow-modal:   0 12px 32px oklch(20% 0.04 265 / 0.12),
                    0 4px 8px oklch(20% 0.04 265 / 0.08);

  /* ===== BREAKPOINTS ===== */
  --breakpoint-sm: 640px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;
  --breakpoint-xl: 1280px;
  --breakpoint-2xl: 1536px;
  --breakpoint-3xl: 1920px;

  /* ===== CONTAINERS ===== */
  --container-narrow: 640px;
  --container-content: 1080px;
  --container-wide: 1280px;
  --container-extra: 1440px;
}

.dark {
  --color-bg: oklch(15% 0.02 270);
  --color-surface: oklch(18% 0.02 270);
  --color-surface-2: oklch(22% 0.02 270);
  --color-fg: oklch(95% 0.01 270);
  --color-muted: oklch(65% 0.02 270);
  --color-subtle: oklch(45% 0.02 270);
  --color-border: oklch(25% 0.01 270);
  --color-border-strong: oklch(35% 0.01 270);

  --color-accent: oklch(68% 0.16 250);
  --color-accent-fg: oklch(15% 0.04 250);
  --color-accent-soft: oklch(25% 0.08 250);
  --color-accent-strong: oklch(75% 0.18 250);

  --color-success: oklch(70% 0.14 145);
  --color-success-soft: oklch(25% 0.06 145);
  --color-warning: oklch(78% 0.14 75);
  --color-warning-soft: oklch(28% 0.06 75);
  --color-error: oklch(68% 0.18 25);
  --color-error-soft: oklch(25% 0.08 25);
  --color-info: oklch(70% 0.12 230);
  --color-info-soft: oklch(25% 0.06 230);
}

@layer base {
  *, *::before, *::after {
    box-sizing: border-box;
  }

  html {
    -webkit-text-size-adjust: 100%;
    text-rendering: optimizeLegibility;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }

  body {
    background: var(--color-bg);
    color: var(--color-fg);
    font-family: var(--font-sans);
    font-size: var(--text-base);
    line-height: var(--leading-body);
  }

  h1, h2, h3, h4, h5, h6 {
    font-family: var(--font-display);
    letter-spacing: var(--tracking-tight);
    line-height: var(--leading-tight);
  }

  :focus-visible {
    outline: 2px solid var(--color-ring);
    outline-offset: 2px;
    border-radius: 4px;
  }

  ::selection {
    background: var(--color-accent-soft);
    color: var(--color-fg);
  }

  /* Tabular figures for monetary cells */
  .tabular {
    font-variant-numeric: tabular-nums;
  }

  /* Reduced motion */
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
      scroll-behavior: auto !important;
    }
  }
}
```

---

## Migration from v3

| v3 | v4 |
|---|---|
| `tailwind.config.js` | `@theme` block in CSS |
| `colors.indigo` | `--color-accent` (semantic) |
| `screens.md` | `--breakpoint-md` |
| `borderRadius.lg` | `--radius-lg` |
| `tailwind.config.ts` for plugins | `@plugin "..."` in CSS |
| `@apply` heavy use | Component composition with utilities |

Most apps migrate by:
1. Install v4: `npm install tailwindcss@latest`
2. Replace `tailwind.config.js` with `@theme` in CSS.
3. Convert color palette to OKLCH (or paste hex and let Tailwind convert).
4. Replace JS plugins with CSS `@plugin` declarations.

The official `npx @tailwindcss/upgrade` helps automate.

---

## Common v4 Patterns Grain Uses

### Stat / KPI value with tabular numerals

```tsx
<div className="text-3xl font-medium tracking-tight tabular-nums">
  $1,247.89
</div>
```

### Responsive card grid with container queries

```tsx
<section className="@container">
  <div className="grid grid-cols-1 gap-4 @md:grid-cols-2 @xl:grid-cols-3">
    {items.map(...)}
  </div>
</section>
```

### Compound state styles

```tsx
<button
  className="
    bg-accent text-accent-fg
    hover:bg-accent-strong
    active:scale-98
    focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-2
    disabled:opacity-50 disabled:pointer-events-none
    data-[loading=true]:cursor-wait
    transition-colors duration-100
  "
>
```

### Logical properties for RTL

```tsx
<div className="ps-4 pe-2 border-s border-border">
```

Becomes `pl-4 pr-2 border-l` in LTR, `pr-4 pl-2 border-r` in RTL automatically.

### `:has()` parent styling

```tsx
<label className="
  flex items-center gap-2 p-3 rounded-lg
  has-[input:checked]:bg-accent-soft
  has-[input:checked]:border-accent
  border border-border
">
  <input type="checkbox" /> Enable
</label>
```

When the checkbox is checked, the parent label gets the accent background — no JS.

---

## When NOT to Use Tailwind

- **Print stylesheets**: use plain CSS, Tailwind doesn't help.
- **Email templates**: inline styles only.
- **Generated content** (Markdown, MDX): use prose plugin or raw CSS for typography.
- **One-off custom illustrations** in SVG: inline `<style>` is fine.

Everything else: Tailwind v4 + `@theme` + OKLCH is the default.
