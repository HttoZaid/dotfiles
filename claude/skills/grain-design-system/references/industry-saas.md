# Industry Pack — Modern SaaS

For SaaS apps, product interfaces, internal tools, developer platforms. The reference
points are **Linear, Vercel, Stripe Dashboard, Raycast, Notion, Cal.com, Resend,
Height, Mercury, Ramp, Pitch, Framer**.

This pack overrides the Grain foundation with SaaS-specific defaults.

---

## Pack Identity

The dominant aesthetic:

- **Near-monochrome surface** with one accent color
- **Tight density** — information per screen wins over breathing room
- **Sidebar nav** is canonical
- **Keyboard-first** — every primary action has a shortcut
- **Inline editing** > modal forms
- **Tables, not cards**, for power-user lists
- **Optimistic UI** for state mutations

---

## Token Overrides

```css
:root[data-pack="saas"] {
  /* Accent: Linear-style desaturated, NOT Tailwind indigo */
  --color-accent: oklch(60% 0.14 270);          /* slightly desaturated violet */
  --color-accent-fg: oklch(99% 0.005 270);
  --color-accent-soft: oklch(95% 0.04 270);
  --color-accent-strong: oklch(52% 0.16 270);

  /* Radii */
  --radius-button: 9999px;                       /* capsule buttons */
  --radius-card: 0.5rem;                         /* 8px cards */
  --radius-input: 0.375rem;                      /* 6px inputs */
  --radius-modal: 0.75rem;                       /* 12px modals */

  /* Typography */
  --font-sans: var(--font-geist-sans), "Inter", system-ui, sans-serif;
  --font-mono: var(--font-geist-mono), "JetBrains Mono", ui-monospace, monospace;

  /* Density */
  --row-height-default: 40px;                    /* tighter than 48px default */
  --row-height-dense: 32px;
  --leading-body: 1.5;                           /* tighter for data density */
}
```

For an Anthropic-style warm pack:
```css
:root[data-pack="saas-warm"] {
  --color-accent: oklch(65% 0.14 40);            /* terracotta */
  /* rest unchanged */
}
```

For a Resend-style green:
```css
:root[data-pack="saas-electric"] {
  --color-accent: oklch(78% 0.22 145);           /* electric green */
}
```

---

## Reference Patterns by Product

### Linear — Calm precision

**Identity**: dark-mode-first (designed in dark, light is the variant), tight
spacing, content density, no chrome decoration.

**Specific signatures**:
- Magic Blue accent `#5E6AD2` (`oklch(60% 0.14 270)` approximation) — desaturated
  violet, never pure indigo
- Inter at weights 400/500 only (no light, no bold body)
- 8px modular spacing scale
- Reduced borders, increased background-contrast separation
- Sidebar always visible, never collapsed by default
- Issue list: row height 36–40px, status pill + title + assignee avatar + project
  badge + date

**The November 2025 "calmer interface" refresh**:
> "By rounding out their edges and softening the contrast, the polished interface
> gives users structure on the page without cluttering their view."
> — linear.app/now/behind-the-latest-design-refresh

Borders were softened; sharp edges removed; contrast reduced where chrome competed
with content.

**To imitate Linear**:
```tsx
<aside className="w-64 border-r bg-surface min-h-screen">
  <nav className="px-3 py-4 space-y-1">
    {items.map(item => (
      <a className="
        flex items-center gap-2 px-3 py-1.5 rounded-md text-sm
        text-muted hover:text-fg hover:bg-surface-2
        data-[active=true]:bg-surface-2 data-[active=true]:text-fg
      ">
        <Icon size={16} />
        {item.label}
        {item.shortcut && (
          <kbd className="ml-auto text-xs text-subtle font-mono">{item.shortcut}</kbd>
        )}
      </a>
    ))}
  </nav>
</aside>
```

### Vercel — Grayscale + Geist

**Identity**: pure grayscale (`#000` / `#FFF`), Geist family, near-zero ornament.
Color appears only when it carries meaning (status, brand visualization).

**Specific signatures**:
- No accent color in the chrome — black/white only
- Geist Sans + Geist Mono everywhere
- Buttons: 44pt default with `shape="rounded"` (capsule)
- `ButtonLink` vs `Button` distinction (semantic: nav vs action)
- Dashboard uses subtle close-range shadows for elevation, otherwise flat
- Triangle logo and Geist Mono labels do the "designed" work

**To imitate Vercel**:
```css
:root[data-pack="saas-vercel"] {
  --color-accent: oklch(20% 0.04 265);          /* near-black as accent */
  --color-accent-fg: oklch(99% 0.005 270);
  --color-bg: oklch(99% 0.004 270);
  --color-fg: oklch(20% 0.04 265);
}
```

Color appears only on:
- Status badges (semantic green/yellow/red/blue)
- Code syntax highlighting
- Charts
- Deployment status indicators

### Stripe Dashboard — Söhne weight 300 + tabular numbers

**Identity**: Söhne at weight 300 for display, tabular numerals everywhere with
money, soft shadows, atmospheric gradient mesh in marketing chrome only.

**Specific signatures**:
- Display heads use weight 300, letter-spacing -1.4px at 56px
- `font-feature-settings: "ss01" "tnum"` (single-story `a`, tabular numerals)
- Deep Violet `#533afd` (`oklch(48% 0.24 290)`) for primary actions
- Cards have soft, large-blur shadows: `0 0 32px 8px rgba(0,0,0,0.2)` equivalent
- Interactive radius 4px, card radius 6–8px

**Hard rule**: every monetary value uses `tabular-nums`:
```tsx
<span className="font-medium tabular-nums">${revenue.toFixed(2)}</span>
```

### Raycast — Keyboard-first, animation-minimal

**Identity**: keyboard-driven, opens hundreds of times per day, zero open animation,
every list item shows shortcut on right edge.

**Specific signatures**:
- No enter/exit animation on the main panel
- Cmd+K opens instantly
- Every list item: icon + label + (optional metadata) + shortcut right-aligned
- Subtle accent on selection (background lift), no scale animation
- Dark mode default

**To imitate Raycast (command palette)**:
```tsx
<Command>
  <CommandInput placeholder="Search projects, files, commands..." />
  <CommandList>
    {commands.map(cmd => (
      <CommandItem onSelect={cmd.action}>
        <Icon size={16} />
        <span>{cmd.label}</span>
        {cmd.shortcut && (
          <kbd className="ml-auto text-xs text-subtle">{cmd.shortcut}</kbd>
        )}
      </CommandItem>
    ))}
  </CommandList>
</Command>
```

### Notion — Warm minimalism

**Identity**: warm grays (slightly yellow tint), serif headings option, conversational
copy, generous spacing for editorial features, tight for tables.

**Specific signatures**:
- Background `oklch(99% 0.005 70)` (warm white)
- Page titles can use serif (Lora) optionally
- Toggle blocks, callouts, dividers as content primitives
- Drag handle on hover left of each block

### Resend — Premium developer dark

**Identity**: dark by default, electric green accent, monospace labels, minimal
chrome, ultra-tight spacing.

**Specific signatures**:
- Electric green `oklch(78% 0.22 145)` as the sole accent
- Geist or Inter at 13px body (denser than typical)
- Code blocks are the hero element
- Documentation has heavy monospace presence

### Cal.com — Friendly blue + booking-first

**Identity**: friendly blue `oklch(62% 0.16 240)`, calendar UI as the centerpiece,
booking forms as core flows.

### Mercury / Ramp — Fintech-tier polish

**Identity**: Söhne family, soft shadows, monetary tables with tabular numerals,
subtle gradient meshes on marketing only, premium feel.

---

## The 18 SaaS Pack Rules

### Layout & Navigation

**1.** Sidebar nav for any product with >7 destinations. Width 240–280px.
Collapsible to icon-only on user toggle.

**2.** Top bar is thin (48–56px), contains: page title or breadcrumbs left, search
center (or in sidebar), user avatar + quick actions right.

**3.** App content area uses `--container-content` (1080px) max width. Wide-monitor
dashboards may use `--container-extra` (1440px).

**4.** No giant hero headlines inside app screens. Apps start with content.

**5.** Breadcrumbs only when nav depth ≥3 levels.

### Content & Density

**6.** Tables over cards for any list >20 rows. Row height 36–48px.

**7.** Dense info: KPI strip at top (4–6 metrics, value + sparkline + trend), then
the working table or grid.

**8.** Empty states teach: explain what the screen becomes (anti-slop rule #22).

**9.** Inline edit, not modal, for single-field changes.

**10.** Optimistic UI for state mutations <500ms expected. Roll back with toast on error.

### Interaction

**11.** Command palette (Cmd+K) is mandatory. Use cmdk by Paco Coursey / Rauno
Freiberg.

**12.** Every primary action has a keyboard shortcut, visible on hover next to the
label.

**13.** Toasts: Sonner, bottom-right desktop / bottom mobile, auto-dismiss 4s, swipe
to dismiss, max 3 visible.

**14.** Filters live in URL params (`?status=open&assignee=jane`) so state is
shareable.

**15.** Skeletons for predictable loading (matching layout shape); spinners only
for unknown <1s waits.

### Numbers & Status

**16.** Numeric data right-aligned with `tabular-nums`. Status pills center-aligned.

**17.** Status colors are semantic tokens — never brand color for status. Use
`--color-success/warning/error/info`.

**18.** Sticky table headers, solid background (never transparent), `z-index: --z-sticky`.

---

## Default Layout Templates

### Two-column app shell

```tsx
<div className="min-h-screen grid grid-cols-[260px_1fr] bg-bg">
  <aside className="border-r bg-surface">
    <SidebarNav />
  </aside>
  <div className="flex flex-col min-h-screen">
    <header className="h-14 border-b flex items-center px-6 gap-4">
      <Breadcrumbs />
      <div className="ml-auto flex items-center gap-2">
        <SearchTrigger />
        <UserMenu />
      </div>
    </header>
    <main className="flex-1 p-6 max-w-[1080px] mx-auto w-full">
      {children}
    </main>
  </div>
</div>
```

### Dashboard (KPI strip + main table)

```tsx
<main className="space-y-6">
  <header>
    <h1 className="text-2xl font-medium tracking-tight">Revenue</h1>
    <p className="text-muted">Last 30 days</p>
  </header>

  <section className="grid grid-cols-2 lg:grid-cols-4 gap-4">
    {kpis.map(kpi => (
      <article className="border rounded-lg p-5 bg-surface">
        <p className="text-sm text-muted">{kpi.label}</p>
        <p className="mt-2 text-2xl font-medium tabular-nums">{kpi.value}</p>
        <div className="mt-3 flex items-center gap-2">
          <TrendIndicator value={kpi.delta} />
          <Sparkline data={kpi.history} className="ml-auto h-6 w-20" />
        </div>
      </article>
    ))}
  </section>

  <section>
    <div className="flex items-center justify-between mb-3">
      <h2 className="text-lg font-medium">Transactions</h2>
      <div className="flex items-center gap-2">
        <FilterMenu />
        <Button variant="primary" size="sm">Export</Button>
      </div>
    </div>
    <Table>
      ...
    </Table>
  </section>
</main>
```

### Issue list (Linear-style)

```tsx
<div className="divide-y divide-border">
  {issues.map(issue => (
    <a
      href={`/issues/${issue.id}`}
      className="
        flex items-center gap-3 px-6 h-10
        hover:bg-surface-2 cursor-pointer
      "
    >
      <StatusIcon status={issue.status} className="size-4" />
      <span className="font-mono text-xs text-muted w-12">{issue.id}</span>
      <span className="flex-1 truncate text-sm">{issue.title}</span>
      <PriorityIcon priority={issue.priority} className="size-3 text-subtle" />
      <Badge variant="muted" size="sm">{issue.project}</Badge>
      <Avatar src={issue.assignee.avatar} size="xs" />
      <span className="text-xs text-muted w-16 text-right tabular-nums">
        {formatDate(issue.updatedAt)}
      </span>
    </a>
  ))}
</div>
```

Notice: 40px row height, dense info, no card wrapper around each issue, status as
icon not badge, monospace ID, tabular-nums on date.

### Settings page (sectioned form)

```tsx
<div className="grid grid-cols-[200px_1fr] gap-8 max-w-4xl mx-auto py-8">
  <nav className="space-y-1">
    {sections.map(s => (
      <a className="block px-3 py-1.5 rounded-md text-sm hover:bg-surface-2">
        {s.label}
      </a>
    ))}
  </nav>

  <main className="space-y-12">
    <section id="profile">
      <h2 className="text-lg font-medium mb-1">Profile</h2>
      <p className="text-sm text-muted mb-6">
        Update your personal information.
      </p>
      <form className="grid gap-4">
        <Input label="Display name" />
        <Input label="Email" type="email" />
        <Textarea label="Bio" />
        <div className="flex justify-end">
          <Button variant="primary">Save changes</Button>
        </div>
      </form>
    </section>

    {/* more sections... */}
  </main>
</div>
```

---

## Color Themes for SaaS

Pick one accent. Stick to it.

### Linear Blue (default)
```css
--color-accent: oklch(60% 0.14 270);  /* desaturated violet */
```

### Stripe Violet (premium)
```css
--color-accent: oklch(48% 0.24 290);  /* deep violet */
```

### Anthropic Terracotta (warm)
```css
--color-accent: oklch(65% 0.14 40);
```

### Resend Green (developer)
```css
--color-accent: oklch(78% 0.22 145);
```

### Cal Blue (friendly)
```css
--color-accent: oklch(62% 0.16 240);
```

### Vercel Mono (no accent)
```css
--color-accent: oklch(20% 0.04 265);  /* near-black */
```

### Notion Warm Gray
```css
--color-accent: oklch(45% 0.04 60);   /* warm dark */
```

---

## Type Scale for SaaS

Tighter than marketing. Bias toward readability at small sizes.

```css
@theme {
  --text-display-sm: 1.875rem;   /* 30px — page heroes inside app */
  --text-h1: 1.5rem;             /* 24px — page title */
  --text-h2: 1.125rem;           /* 18px — section header */
  --text-h3: 1rem;               /* 16px — subsection */
  --text-body: 0.875rem;         /* 14px — list rows, tables */
  --text-body-comfortable: 1rem; /* 16px — settings, prose */
  --text-caption: 0.8125rem;     /* 13px */
  --text-micro: 0.75rem;         /* 12px — timestamps, labels */
}
```

App pages default to 14px body for density. Settings / docs / marketing-adjacent
pages bump to 16px.

---

## Motion for SaaS

- Modal/dialog enter: 200ms `--ease-out`
- Sheet slide: 250ms `--ease-out`
- Toast appear: 200ms `--ease-out`
- List reorder: 200ms (FLIP)
- Button hover/active: 100ms color, 80ms transform
- Optimistic state change: instant (0ms)
- Keyboard actions: instant (0ms) — Cmd+K, Esc, etc.

Scroll-driven animation is **banned in app screens**. Use only on marketing sites.

---

## Imagery for SaaS

- **Avatars**: real user photos OR initials over `--color-accent-soft`.
- **Empty states**: no illustration; faint preview of populated state.
- **Charts**: data viz palettes from foundation.md, not brand color.
- **Marketing imagery in product onboarding**: keep it; everywhere else, screenshots
  of the actual product.

---

## Hard Bans for SaaS Pack

- ❌ Centered hero on any app page (only marketing landings allow it).
- ❌ Marketing-style 3-column features grid inside the app.
- ❌ Glass blur on every surface (anti-slop rule #9).
- ❌ Decorative gradients in the chrome (sidebar, header, table).
- ❌ Card-everything (lists are lists, not stacks of cards).
- ❌ Loading skeletons that don't match the loaded layout.
- ❌ Toast notifications for routine confirmations (only for state-significant changes).
- ❌ Modal forms longer than 6 fields (use a sheet or dedicated page).
