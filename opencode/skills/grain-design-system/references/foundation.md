# Foundation — Color, Spacing, Radius, Motion, Elevation

The semantic system that every component reads from. All tokens are CSS variables
defined in `@theme` (Tailwind v4 CSS-first config). Industry packs override a small
set of these; everything else stays constant across packs.

---

## Color System

Grain uses **OKLCH** (Oklab Cylindrical) color space. Two reasons:
1. Perceptually uniform: equal lightness steps look equally bright across hues.
2. Wide gamut: covers P3 displays accurately, falls back to sRGB cleanly.
3. Tailwind v4's native color space — no conversion needed.

### The Token Hierarchy

```
Raw tokens (private) → Semantic tokens (public) → Component tokens (specialized)
```

Components never read raw tokens. Components read semantic. The system has 3 layers
so industry packs can override the middle layer without touching components.

### Semantic tokens (always present)

```css
/* Surface and content */
--color-bg            /* page background, the lowest layer */
--color-surface       /* card / panel background, slightly above bg */
--color-surface-2     /* elevated surface, hover backgrounds */
--color-fg            /* primary text, icons */
--color-muted         /* secondary text */
--color-subtle        /* tertiary text, placeholders, disabled */
--color-border        /* default border, divider */
--color-border-strong /* emphasized border */
--color-ring          /* focus ring color */

/* Accent (the ONE brand color) */
--color-accent        /* primary brand action */
--color-accent-fg     /* text/icon on top of accent */
--color-accent-soft   /* subtle backgrounds, like badges */
--color-accent-strong /* hover/active state of accent */

/* Status (semantic, never branded) */
--color-success       /* positive state */
--color-success-fg
--color-success-soft
--color-warning
--color-warning-fg
--color-warning-soft
--color-error
--color-error-fg
--color-error-soft
--color-info
--color-info-fg
--color-info-soft
```

### Light mode defaults

```css
@theme {
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
}
```

### Dark mode defaults

```css
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
  --color-accent-soft: oklch(25% 0.08 250);
  --color-accent-strong: oklch(75% 0.18 250);

  /* Status: lift lightness, reduce chroma slightly */
  --color-success: oklch(70% 0.14 145);
  --color-success-soft: oklch(25% 0.06 145);
  --color-warning: oklch(78% 0.14 75);
  --color-warning-soft: oklch(28% 0.06 75);
  --color-error: oklch(68% 0.18 25);
  --color-error-soft: oklch(25% 0.08 25);
  --color-info: oklch(70% 0.12 230);
  --color-info-soft: oklch(25% 0.06 230);
}
```

### Per-pack accent overrides

Each industry pack overrides only `--color-accent` and related tokens. Examples:

```css
/* SaaS (Linear-style) */
:root[data-pack="saas"] { --color-accent: oklch(60% 0.14 270); }

/* Engineering (Vercel-style — black/white, no accent) */
:root[data-pack="engineering"] {
  --color-accent: oklch(20% 0.04 265);     /* near-black as accent */
  --color-accent-fg: oklch(99% 0.005 270);
}

/* Corporate (Anthropic-style warm terracotta) */
:root[data-pack="corporate"] { --color-accent: oklch(65% 0.14 40); }

/* Mobile iOS (system blue) */
:root[data-pack="ios"] { --color-accent: oklch(60% 0.18 250); }

/* Mobile Android M3 — picks up from dynamic color */
:root[data-pack="android"] { --color-accent: oklch(60% 0.16 280); }
```

### Color rules (read alongside Refactoring UI)

1. **Limit hues**: 1 brand accent + 4 semantic statuses. Total: 5 distinct hues.
2. **Hierarchy by lightness, not hue**: `--color-fg → --color-muted → --color-subtle`
   walks down the lightness axis (20% → 55% → 75%) while keeping chroma low and hue
   stable. This is the secret to interfaces that read clearly.
3. **Saturation conveys interactivity**: high-chroma colors (`--color-accent`) belong
   on interactive elements. Neutrals (chroma <0.02) belong on content.
4. **Status colors are off-limits for branding**: green is success, red is error,
   yellow is warning, blue is info. Never use these for accent decoration.
5. **Pure black is banned**: `oklch(20% 0.04 265)` is the default near-black. Pure
   `#000` only on display headlines when intentional contrast is the goal.
6. **Accent on >25% of surface area is a violation**: the accent is the rarest color.
   If the page is half-purple, you've over-applied it.

### Contrast requirements

WCAG 2.2 AA enforced:
- Body text on background: ≥4.5:1
- Large text (≥18px or 14px bold): ≥3:1
- UI components and graphical objects: ≥3:1 (1.4.11)
- Focus indicators: ≥3:1 against adjacent colors (2.4.13)

Use `oklch()` lightness math to verify. Anything labeled `--color-fg` or `--color-muted`
must clear 4.5:1 against `--color-bg`. `--color-subtle` is for non-essential text only
and may sit at 3:1.

### Data visualization palettes

For charts and graphs, the brand accent is NOT used. Use one of:

**Sequential (single hue, light → dark)**:
```
oklch(95% 0.04 250), oklch(85% 0.08 250), oklch(72% 0.13 250),
oklch(58% 0.17 250), oklch(45% 0.18 250), oklch(32% 0.15 250)
```

**Categorical (Tableau 10 / d3 default, in OKLCH)**:
```
oklch(60% 0.15 250)   blue
oklch(70% 0.18 50)    orange
oklch(60% 0.18 145)   green
oklch(60% 0.22 25)    red
oklch(65% 0.16 290)   purple
oklch(55% 0.1 65)     brown
oklch(72% 0.18 350)   pink
oklch(60% 0.02 270)   gray
oklch(70% 0.18 100)   olive
oklch(65% 0.15 195)   cyan
```

**Diverging (red ↔ neutral ↔ blue, for delta values)**:
```
oklch(60% 0.22 25), oklch(75% 0.12 25), oklch(90% 0.04 30),
oklch(95% 0.005 270),
oklch(90% 0.04 240), oklch(75% 0.13 250), oklch(55% 0.18 250)
```

---

## Spacing System

Base unit: **4px**. Tailwind v4 generates the scale automatically. Use only:

| Token | px | When to use |
|---|---|---|
| `0` | 0 | Reset only |
| `0.5` | 2 | Hairline gaps, icon-text alignment |
| `1` | 4 | Tight padding inside small badges |
| `1.5` | 6 | Compact form padding |
| `2` | 8 | Default small padding |
| `3` | 12 | Default gap between adjacent items |
| `4` | 16 | Default card/component padding |
| `5` | 20 | Loose card padding |
| `6` | 24 | Section padding (small) |
| `8` | 32 | Section padding (medium) |
| `10` | 40 | Section padding (large) |
| `12` | 48 | Hero padding |
| `16` | 64 | Vertical section break |
| `20` | 80 | Major section break (marketing) |
| `24` | 96 | Marketing hero vertical padding |
| `32` | 128 | Reserved — only for spacious editorial layouts |

### Spacing rules

- **No magic numbers**: every dimension comes from the scale.
- **Adjacent elements use small gaps** (2–4 = 8–16px). Sectional separation uses
  large gaps (12–24 = 48–96px).
- **Internal padding > external margin**: prefer padding inside containers over
  margins between them for predictable layouts.
- **Container queries for responsive padding**: card padding shrinks at narrow widths
  via container queries, not media queries.

```css
@container (max-width: 480px) {
  .card { padding: var(--spacing-3); }
}
@container (min-width: 481px) {
  .card { padding: var(--spacing-5); }
}
```

---

## Radius System

```css
@theme {
  --radius-none: 0;
  --radius-sm: 0.25rem;    /* 4px - inputs in engineering pack */
  --radius-md: 0.375rem;   /* 6px - inputs default */
  --radius-lg: 0.5rem;     /* 8px - cards default */
  --radius-xl: 0.75rem;    /* 12px - modals, large cards */
  --radius-2xl: 1rem;      /* 16px - reserved, marketing only */
  --radius-pill: 9999px;   /* capsule - buttons, badges */
}
```

### Radius rules per industry pack

| Element | SaaS | Corporate | Engineering | iOS | Android |
|---|---|---|---|---|---|
| Button | pill | pill | sm (4px) | concentric | pill |
| Input | md (6px) | md | sm (4px) | concentric | sm (4dp) |
| Card | lg (8px) | xl (12px) | sm (4px) | concentric | xl (12dp) |
| Modal | xl (12px) | xl | md (6px) | concentric | 28dp |
| Badge | pill | pill | sm | pill | pill |

**Concentric (iOS Liquid Glass)**:
- Parent radius = R, child radius = R - padding
- A button (pill, height 44pt, radius = 22pt) inside a card (radius 12pt, padding 8pt)
  is fine as is — but a *child container* of that card with 8pt padding should have
  radius = 12 - 8 = 4pt.
- Apple's WWDC25 #356 covers this; the API is `.glassEffect()` and `.buttonBorderShape(.capsule)`.

### Never

- Mix radii on touching surfaces. If a button sits inside a card, button's radius
  should respect the card's geometry.
- Apply `rounded-2xl` to every surface (anti-slop rule #4).
- Use `rounded-full` on rectangles wider than 2.5× their height (it looks like a
  pill-shaped lozenge, which is correct for narrow elements like badges but ugly
  on wider rectangles).

---

## Motion System

```css
@theme {
  /* Durations */
  --duration-instant: 0ms;       /* keyboard actions, frequently-used */
  --duration-fast: 100ms;        /* hover, color, opacity */
  --duration-normal: 200ms;      /* enter/exit, transforms */
  --duration-slow: 300ms;        /* modal, sheet, marketing */
  --duration-marketing: 400ms;   /* hero reveals, scroll-driven */

  /* Easing curves */
  --ease-linear: linear;
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);       /* default for enter */
  --ease-in: cubic-bezier(0.4, 0, 1, 1);           /* exit only */
  --ease-fluid: cubic-bezier(0.3, 0, 0, 1);        /* Tailwind v4 default */
  --ease-snappy: cubic-bezier(0.2, 0, 0, 1);       /* fast UI feedback */
  --ease-emphasized: cubic-bezier(0.2, 0, 0, 1);   /* Material 3 emphasized */
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1); /* playful bounce */
}
```

### When to use each duration

- **instant (0)**: keyboard shortcuts, command palette open, Cmd+K, Esc, frequently-
  triggered menus. Anything the user hits >50× per session.
- **fast (100ms)**: hover color/opacity changes, focus ring, button press.
- **normal (200ms)**: modal/sheet enter, dropdown open, optimistic state confirmation,
  list reorder.
- **slow (300ms)**: marketing micro-interactions, scroll-triggered fade-in.
- **marketing (400ms)**: hero product reveals, parallax, scroll-driven type animation.

### Easing rules

- Enter animations use `--ease-out` (decelerate into final state).
- Exit animations use `--ease-in` (accelerate away).
- Bidirectional transitions (collapse/expand toggle) use `--ease-fluid`.
- Bouncy interactions use `--ease-spring` — sparingly, never on critical-path actions.

### Properties to animate

**Cheap (GPU-accelerated)**:
- `transform` (translate, scale, rotate)
- `opacity`
- `filter` (brief use only)

**Expensive (avoid)**:
- `width`, `height`, `top`, `left`, `padding`, `margin` — these force layout
  recalculation and trigger CLS.
- `background-color` is fine (paint-only, no layout).

### Reduced motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

Keep opacity transitions (≤100ms) for state clarity — disabling them entirely makes
state changes invisible. Disable transforms, scroll animations, and parallax.

### What to animate vs not (Emil Kowalski's rules, explicit)

| Animate | Don't animate |
|---|---|
| Modal/sheet enter/exit | Cmd+K open |
| Dropdown open (on click) | Frequently-used nav menus |
| Toast appear/dismiss | Page scroll position |
| List reorder (FLIP) | Initial page render content |
| State change (idle → loading) | Section fade-ins on scroll (product apps) |
| Optimistic confirmation | Routine layout changes |
| Tooltip appear (with delay) | Anything triggered >50×/session |
| Marketing hero reveals | Form field value changes |

---

## Elevation System

Shadows convey **depth**. Use them to communicate that something is *lifted above
the page*, not as decoration.

```css
@theme {
  /* Subtle elevation: hover cards, dropdowns */
  --shadow-pop: 0 1px 2px oklch(20% 0.04 265 / 0.06),
                0 4px 8px oklch(20% 0.04 265 / 0.04);

  /* Mid elevation: popovers, command palette */
  --shadow-overlay: 0 4px 12px oklch(20% 0.04 265 / 0.08),
                    0 12px 24px oklch(20% 0.04 265 / 0.06);

  /* High elevation: modals, dialogs */
  --shadow-modal: 0 12px 32px oklch(20% 0.04 265 / 0.12),
                  0 4px 8px oklch(20% 0.04 265 / 0.08);

  /* Brand glow (use sparingly): focused primary button */
  --shadow-glow: 0 0 0 4px oklch(60% 0.18 250 / 0.15);
}
```

### Elevation rules

- **0**: default surfaces (cards on bg, list items, table rows). Use border or
  background contrast.
- **1 (pop)**: hover state of cards, dropdown menus, tooltips.
- **2 (overlay)**: popovers, command palette, autocomplete dropdown.
- **3 (modal)**: modals, dialogs, full-screen sheets.
- **Glow**: focused state on the primary brand action only. Optional.

Never:
- Combine shadow with thick border. Pick one.
- Apply elevation to every card (anti-slop rule #15).
- Use colored shadows except for the brand glow (which is a focus indicator).
- Use shadows on dark backgrounds without first checking they're visible — at high
  saturation, shadows disappear on dark surfaces; use inset borders instead.

---

## Z-index Scale

Avoid arbitrary z-index numbers. Use semantic tokens:

```css
@theme {
  --z-base: 0;
  --z-dropdown: 100;
  --z-sticky: 200;
  --z-overlay: 300;
  --z-modal: 400;
  --z-popover: 500;
  --z-toast: 600;
  --z-tooltip: 700;
}
```

Rules:
- Sticky headers: `--z-sticky`.
- Overlay scrim (modal backdrop): `--z-overlay`.
- Modal content: `--z-modal`.
- Popovers/dropdowns inside modals: `--z-popover` (must be > modal).
- Toasts always on top of overlays but under tooltips.
- Tooltips highest — they should be visible over every other element.

---

## Typography Scale

```css
@theme {
  /* Sizes (clamp-based for fluid type) */
  --text-xs: 0.75rem;        /* 12px */
  --text-sm: 0.8125rem;      /* 13px */
  --text-base: 1rem;         /* 16px */
  --text-lg: 1.125rem;       /* 18px */
  --text-xl: 1.25rem;        /* 20px */
  --text-2xl: 1.5rem;        /* 24px */
  --text-3xl: 1.875rem;      /* 30px */
  --text-4xl: 2.25rem;       /* 36px */
  --text-5xl: 3rem;          /* 48px */
  --text-6xl: 3.75rem;       /* 60px */
  --text-7xl: 4.5rem;        /* 72px */
  --text-display: clamp(3.5rem, 10vw, 7.5rem);  /* 56 → 120px fluid */

  /* Weights */
  --font-weight-regular: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;

  /* Line heights */
  --leading-display: 1.05;   /* tight for large heads */
  --leading-tight: 1.2;      /* subheads */
  --leading-snug: 1.4;       /* small headings */
  --leading-body: 1.6;       /* body text */
  --leading-loose: 1.75;     /* relaxed body */

  /* Letter spacing (tracking) */
  --tracking-display: -0.04em;  /* large heads */
  --tracking-tight: -0.01em;    /* subheads */
  --tracking-body: 0em;
  --tracking-wide: 0.005em;
  --tracking-caption: 0.01em;
  --tracking-uppercase: 0.05em; /* SMALL CAPS labels */
}
```

### Type scale rules

- **Use the scale**: never set `font-size: 17px`. Use `text-lg` (18px) or `text-base`
  (16px). The scale ensures consistency.
- **Negative tracking on display**: anything ≥32px gets `--tracking-display` or `--tracking-tight`.
  Positive only for `<small>` and `text-uppercase` labels.
- **Hierarchy uses weight + color, not just size** (Refactoring UI rule). Body and
  caption can share size if weight/color differentiate them.
- **Maximum line length**: 60–75 characters for body. Use `max-width: 65ch`.
- **Minimum body**: 16px desktop, 17px mobile.

Full typography guidance in `typography.md`.

---

## Container System

```css
@theme {
  --container-prose: 65ch;        /* readable column */
  --container-narrow: 640px;      /* form / focused content */
  --container-content: 1080px;    /* app content area */
  --container-wide: 1280px;       /* marketing default */
  --container-extra: 1440px;      /* dashboard wide mode */
  --container-full: 100%;
}
```

Rules:
- Marketing default: `--container-wide` (1280px).
- App content: `--container-content` (1080px) for primary, `--container-extra` for
  data-dense dashboards on wide monitors.
- Prose / blog / docs: `--container-prose` (65ch ≈ 720px).
- Forms: `--container-narrow` (640px) — never wider, eye travel breaks down.

---

## Breakpoint System (Tailwind v4 defaults, with semantic intent)

```css
@theme {
  --breakpoint-sm: 640px;     /* tablet portrait */
  --breakpoint-md: 768px;     /* tablet landscape */
  --breakpoint-lg: 1024px;    /* small desktop */
  --breakpoint-xl: 1280px;    /* desktop */
  --breakpoint-2xl: 1536px;   /* wide desktop */
  --breakpoint-3xl: 1920px;   /* large monitor, density mode */
}
```

Rules:
- Mobile-first: default styles target ≤640px.
- Use container queries for component-level responsiveness, media queries for layout.
- 3xl (1920px+) triggers high-density dashboard mode (Datadog pattern: split left/right
  halves symmetrically).
- Don't write classes for every breakpoint. Most components only need `sm:` and `lg:`.

---

## How Industry Packs Override These Tokens

Each pack file (`industry-saas.md` etc.) specifies exactly which tokens to override.
Typical pack overrides:

```css
/* SaaS pack */
:root[data-pack="saas"] {
  --color-accent: oklch(60% 0.14 270);
  --radius-button: 9999px;
  --radius-card: 0.5rem;
  --font-display: "Inter Display", "Inter", system-ui, sans-serif;
}

/* Engineering pack */
:root[data-pack="engineering"] {
  --color-accent: oklch(20% 0.04 265);
  --radius-button: 0.25rem;
  --radius-card: 0.25rem;
  --font-sans: "Geist Mono", "JetBrains Mono", ui-monospace, monospace;
  --leading-body: 1.5;          /* tighter for data density */
}

/* Corporate pack */
:root[data-pack="corporate"] {
  --color-accent: oklch(65% 0.14 40);     /* warm terracotta */
  --radius-button: 9999px;
  --radius-card: 0.75rem;
  --font-display: "Editorial New", "Söhne", "Inter Display", serif;
  --text-display: clamp(4rem, 12vw, 9rem);  /* larger marketing heads */
}
```

Components read semantic tokens (`var(--color-accent)`), so they automatically pick
up the override without modification. This is the entire point of the token system.
