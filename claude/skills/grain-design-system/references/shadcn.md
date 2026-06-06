# shadcn/ui Customization

shadcn/ui is the most-used React component library and the most common source of
AI slop. This file is the difference between "I used shadcn" and "I customized
shadcn so it doesn't look like default shadcn."

---

## Why Default shadcn = Slop

The shadcn `init` command produces a project with:
- `--primary: 240 5.9% 10%` (near-black)
- `--radius: 0.5rem`
- Default Tailwind neutral / zinc / stone palette
- Inter as the implied font
- Lucide icons everywhere

Every AI tool trained on shadcn-using GitHub repositories defaults to these tokens.
The result: 90% of generated dashboards look interchangeable. This is anti-slop rule #13.

The fix is to **override the defaults before adding components**. After overrides, the
shadcn primitive layer becomes invisible — it's just well-built accessible components
wearing your design system's clothes.

---

## The Five Required Overrides

Do these before running `npx shadcn add` for the first time.

### 1. Replace `--primary` with a real brand color

```css
@theme {
  --color-primary: oklch(60% 0.18 250);
  --color-primary-foreground: oklch(99% 0.005 250);
}

/* shadcn maps */
@layer base {
  :root {
    --primary: var(--color-primary);
    --primary-foreground: var(--color-primary-foreground);
  }
}
```

shadcn's default `--primary` is near-black. Replace it with the brand accent.

### 2. Replace `--radius` with a system

shadcn assumes a single radius value applied everywhere. Grain uses a system:

```css
@theme {
  --radius-button: 9999px;     /* capsule */
  --radius-input: 0.375rem;    /* 6px */
  --radius-card: 0.5rem;       /* 8px */
  --radius-modal: 0.75rem;     /* 12px */
}

@layer base {
  :root {
    --radius: var(--radius-card);    /* shadcn's default reads from --radius */
  }
}
```

Then override component-specific radii inside each component (see "Per-component
overrides" below).

### 3. Replace the font

shadcn doesn't ship a font, but every default tutorial uses Inter. Replace it.

```tsx
// app/layout.tsx
import { GeistSans } from "geist/font/sans";
import { GeistMono } from "geist/font/mono";

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${GeistSans.variable} ${GeistMono.variable}`}>
      <body className="font-sans">{children}</body>
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

### 4. Pick a non-default base color

When running `npx shadcn init`, the CLI asks for a base color (slate, gray, zinc,
neutral, stone). All five are giveaways. Pick **slate or stone** if you want a
warmer/cooler default, but immediately override the resulting tokens in your `@theme`
with OKLCH values. The base color from the CLI is a starting point, not the answer.

### 5. Customize at least one component variant

The shadcn default Button has six variants (default, destructive, outline, secondary,
ghost, link). Out of the box, they're recognizable. Add a custom variant — even
something simple — to differentiate.

```tsx
// components/ui/button.tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center ...",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive ...",
        outline: "border bg-background ...",
        secondary: "bg-secondary ...",
        ghost: "hover:bg-accent ...",
        link: "text-primary underline-offset-4 hover:underline",
        // ADD: brand-outline variant
        "brand-outline": "border border-primary text-primary bg-transparent hover:bg-primary/5",
      },
      size: {
        default: "h-9 px-4 py-2",
        sm: "h-8 rounded-md px-3 text-xs",
        lg: "h-10 rounded-md px-8",
        icon: "h-9 w-9",
        // ADD: xs and xl sizes
        xs: "h-7 rounded-md px-2 text-xs",
        xl: "h-12 rounded-md px-10 text-base",
      },
    },
  }
);
```

---

## The `components.json` Configuration

When you `init` shadcn, configure `components.json` like this:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "app/globals.css",
    "baseColor": "slate",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  },
  "iconLibrary": "lucide"
}
```

Choose `"new-york"` style over default — fewer pill curves, sharper feel.
Set `"cssVariables": true` (mandatory; this is Tailwind v4's mode).

For icons, swap to Phosphor if available:
```bash
npm install @phosphor-icons/react
```

Then in component code:
```tsx
import { Trash, PencilSimple } from "@phosphor-icons/react";
```

Phosphor has more icons, more weights (thin / light / regular / bold / fill / duotone),
and feels less default than Lucide for product UI.

---

## Token Mapping: shadcn ↔ Grain

shadcn uses its own token names. Map them to Grain tokens in `globals.css`:

```css
@layer base {
  :root {
    --background: var(--color-bg);
    --foreground: var(--color-fg);
    --card: var(--color-surface);
    --card-foreground: var(--color-fg);
    --popover: var(--color-bg);
    --popover-foreground: var(--color-fg);
    --primary: var(--color-accent);
    --primary-foreground: var(--color-accent-fg);
    --secondary: var(--color-surface-2);
    --secondary-foreground: var(--color-fg);
    --muted: var(--color-surface-2);
    --muted-foreground: var(--color-muted);
    --accent: var(--color-accent-soft);
    --accent-foreground: var(--color-accent-strong);
    --destructive: var(--color-error);
    --destructive-foreground: var(--color-error-fg);
    --border: var(--color-border);
    --input: var(--color-border);
    --ring: var(--color-ring);
    --radius: 0.5rem;
  }

  .dark {
    --background: var(--color-bg);
    --foreground: var(--color-fg);
    --card: var(--color-surface);
    --card-foreground: var(--color-fg);
    --popover: var(--color-surface);
    --popover-foreground: var(--color-fg);
    --primary: var(--color-accent);
    --primary-foreground: var(--color-accent-fg);
    --secondary: var(--color-surface-2);
    --secondary-foreground: var(--color-fg);
    --muted: var(--color-surface-2);
    --muted-foreground: var(--color-muted);
    --accent: var(--color-accent-soft);
    --accent-foreground: var(--color-accent-strong);
    --destructive: var(--color-error);
    --destructive-foreground: var(--color-error-fg);
    --border: var(--color-border);
    --input: var(--color-border);
    --ring: var(--color-ring);
  }
}
```

Now every shadcn component automatically picks up Grain colors without modification.
This is the entire point: write tokens once, every component obeys.

---

## Per-Component Customizations

shadcn components are copy-pasted into your project. Edit them directly.

### Button

```tsx
// components/ui/button.tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-pill text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-9 px-4 py-2",
        sm: "h-8 px-3 text-xs",
        lg: "h-11 px-6 text-base",      // 44px = mobile-friendly
        icon: "h-9 w-9",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  }
);
```

Key changes from shadcn default:
- `rounded-pill` (capsule), not `rounded-md`.
- `lg` size is 44px (h-11) for mobile-friendly tap targets.
- `font-medium` (500), not Tailwind's default font-weight.

### Card

```tsx
// components/ui/card.tsx
const Card = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        "rounded-lg border bg-card text-card-foreground",
        // NO default shadow. Background contrast does the work.
        className
      )}
      {...props}
    />
  )
);

const CardHeader = React.forwardRef<...>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex flex-col space-y-1.5 p-6", className)} {...props} />
  )
);

const CardTitle = React.forwardRef<...>(
  ({ className, ...props }, ref) => (
    <h3 ref={ref} className={cn("text-lg font-medium tracking-tight", className)} {...props} />
  )
);
```

Changes:
- No shadow by default (anti-slop rule #15).
- CardTitle uses `font-medium` not `font-semibold` (Refactoring UI: weight is enough).
- Title size `text-lg` not `text-2xl` (don't oversize card titles).

### Input

```tsx
// components/ui/input.tsx
const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type, ...props }, ref) => (
    <input
      type={type}
      ref={ref}
      className={cn(
        "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2",
        "text-base ring-offset-background",
        "file:border-0 file:bg-transparent file:text-sm file:font-medium",
        "placeholder:text-muted-foreground",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "disabled:cursor-not-allowed disabled:opacity-50",
        className
      )}
      {...props}
    />
  )
);
```

Changes:
- `h-10` (40px) — higher than shadcn default `h-9` (36px) for comfortable mobile.
- `text-base` (16px) — important: input text smaller than 16px causes iOS Safari to
  zoom on focus.

### Dialog

```tsx
// components/ui/dialog.tsx (DialogContent override)
const DialogContent = React.forwardRef<...>(
  ({ className, children, ...props }, ref) => (
    <DialogPortal>
      <DialogOverlay />
      <DialogPrimitive.Content
        ref={ref}
        className={cn(
          "fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4",
          "border bg-background p-6 shadow-modal",
          "rounded-xl",                                    // 12px modal radius
          "duration-200",
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
          "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
          "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
          "data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%]",
          "data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%]",
          className
        )}
        {...props}
      >
        {children}
      </DialogPrimitive.Content>
    </DialogPortal>
  )
);
```

Changes:
- `rounded-xl` (12px) — modal-specific radius from Grain's radius system.
- `shadow-modal` — Grain's strong shadow token.
- `bg-background` (full opacity) — no glass-on-everything (anti-slop rule #9).

### Toaster (use Sonner)

shadcn ships its own Toast (deprecated by maintainer). Use Sonner instead:

```bash
npx shadcn add sonner
```

```tsx
// app/layout.tsx
import { Toaster } from "@/components/ui/sonner";

<body>
  {children}
  <Toaster
    position="bottom-right"
    expand
    richColors
    closeButton
  />
</body>
```

Then anywhere:
```tsx
import { toast } from "sonner";
toast.success("Saved");
toast.error("Failed", { description: "Check your connection" });
```

---

## When NOT to Use shadcn

Even with all the customization, sometimes shadcn fights you.

### Marketing sites

shadcn's primitives are built for product UIs. On a marketing site, you want:
- Custom hero compositions
- Editorial layouts
- Scroll-driven storytelling
- No accessibility tree of nested Radix primitives

For marketing, use Radix primitives directly when needed (Dialog for sign-up modal,
Tooltip for tooltips) and write the rest as custom JSX.

### Data viz and dashboards

shadcn has Chart components (charts via Recharts), but for serious data viz reach
for the underlying library:
- **Recharts** — general purpose, React-friendly.
- **Tremor** — pre-built KPI cards, area charts, sparklines, ideal for dashboards.
- **visx** — Airbnb's primitive layer for custom charts.
- **echarts-for-react** — heavy but featureful.
- **D3** directly for unique visualizations.

### Mobile-first PWAs

shadcn is desktop-first. On mobile, you want:
- Vaul for bottom sheets (already in the stack).
- Native-feeling lists with platform-correct row heights.
- Larger tap targets than shadcn defaults.

For mobile-dominant projects, use shadcn as a layer (Dialog for the rare desktop
case) but build mobile UI from native components or platform-specific libraries.

### Strong brand identity required

shadcn is intentionally neutral. If the brand requires a strong visual identity
(luxury, fashion, gaming, agency), the customization overhead becomes high enough
that rolling custom is faster.

---

## Tools That Help

### tweakcn.com

Visual editor for shadcn themes. Generates the `globals.css` with custom colors,
radius, and typography. Use it for the initial customization, then refine by hand.

### shadcn/Create

A guided creation tool launching in late 2025. Starts from a design preset (Calm,
Bold, Editorial, Brutalist, etc.) instead of defaults. Worth using if available.

### v0 by Vercel

v0 generates shadcn-based UIs. After generation, immediately apply the five required
overrides — v0 outputs default-neutral theme even when the prompt asks for branding.

### Storybook

For a Grain-themed project, set up Storybook with the same `globals.css`. Every
component renders in Grain's tokens. Catches inconsistencies fast.

---

## The shadcn Anti-Slop Audit

When generating a UI using shadcn, run this audit:

- [ ] `--primary` is NOT near-black or near-white. It's an actual brand color in OKLCH.
- [ ] `--radius` is part of a system, not a single value applied everywhere.
- [ ] Font is NOT Inter (or if Inter, has discipline: weight contrast, tracking).
- [ ] At least 1 custom Button variant or size beyond defaults.
- [ ] No `Card` has `shadow-md` or stronger by default.
- [ ] Mobile dialogs use `Vaul` (bottom sheet), not centered `Dialog`.
- [ ] Toast uses `Sonner`, not deprecated shadcn `Toast`.
- [ ] Icon library is consistent (all Phosphor OR all Lucide, not mixed).
- [ ] Empty states are custom (not the shadcn `Card` + centered text default).

If three or more fail, the UI still looks default-shadcn regardless of how much
custom code wraps it. Redo the foundation.

---

## Summary

shadcn is the right primitive layer for React product UIs in 2026 — accessibility-
tested, copy-paste flexible, and tightly integrated with Tailwind. The trap is
shipping with defaults. Apply the five required overrides before adding components,
map tokens to Grain semantics, and customize one variant per primitive.

After that, shadcn becomes invisible — it's just well-built components wearing your
design system's clothes.
