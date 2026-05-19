# Industry Pack — Engineering / B2B / Data-Dense

For monitoring dashboards, observability tools, analytics platforms, B2B admin
panels, CRMs, internal tools, CAD/floor-plan apps, industrial/field tools, and
anywhere information density matters more than visual flourish.

Reference points: **Datadog, Grafana, Tailscale, Cloudflare Dashboard, Sentry,
PostHog, Plausible, Honeycomb, AWS Console (the good parts), Stripe Sigma,
Mixpanel, Segment, Statsig**.

This pack overrides the Grain foundation with engineering-specific defaults.

---

## Pack Identity

Engineering UIs serve power users who:
- Spend 4+ hours a day in the tool
- Care about information per pixel, not breathing room
- Need to compare numbers across rows / time / dimensions
- Will use keyboard shortcuts for everything they can
- Want consistent layouts so muscle memory works
- Will trade visual appeal for predictability and density

The aesthetic baseline is **flat, near-monochrome, structured, tabular**. Color is
semantic (status, severity) — never decorative.

---

## Token Overrides

```css
:root[data-pack="engineering"] {
  /* Accent: subdued, not a hero color */
  --color-accent: oklch(20% 0.04 265);          /* near-black accent (Datadog-style) */
  --color-accent-fg: oklch(99% 0.005 270);
  /* OR: a single saturated blue if data viz needs an action color */
  /* --color-accent: oklch(55% 0.18 245); */

  /* Radii: sharper, more "industrial" */
  --radius-button: 0.25rem;                     /* 4px */
  --radius-input: 0.25rem;                      /* 4px */
  --radius-card: 0.375rem;                      /* 6px */
  --radius-modal: 0.5rem;                       /* 8px */

  /* Typography: optimized for density */
  --font-sans: var(--font-geist-sans), "Inter", system-ui, sans-serif;
  --font-mono: var(--font-geist-mono), "JetBrains Mono", "Berkeley Mono", ui-monospace, monospace;
  --leading-body: 1.4;                          /* tighter than 1.5 */
  --leading-tight: 1.15;

  /* Density */
  --row-height-default: 32px;                   /* tight rows */
  --row-height-dense: 28px;                     /* high-density mode */
  --row-height-comfortable: 40px;

  /* Status / severity emphasis */
  --color-severity-critical: oklch(48% 0.22 25);   /* red */
  --color-severity-high: oklch(62% 0.22 25);
  --color-severity-medium: oklch(70% 0.16 75);     /* amber */
  --color-severity-low: oklch(60% 0.13 230);       /* blue */
  --color-severity-info: oklch(55% 0.02 270);      /* gray */
}
```

For pure-Datadog feel:
```css
:root[data-pack="engineering-datadog"] {
  --color-accent: oklch(55% 0.22 290);          /* Datadog purple, used sparingly */
  --font-mono: "Inconsolata", "Source Code Pro", ui-monospace, monospace;
}
```

For Grafana-style observability:
```css
:root[data-pack="engineering-grafana"] {
  --color-accent: oklch(65% 0.18 50);           /* Grafana orange */
}
```

---

## Reference Patterns by Product

### Datadog — Information density as identity

**Signatures**:
- Sidebar + secondary nav + page header + KPI strip + widget grid
- 32–36px row heights in tables
- Sparklines inline in cells
- Right-aligned numbers with tabular-nums
- Saturated severity colors (critical red, warning amber) against neutral chrome
- Time-range picker top-right is mandatory
- "Search across everything" keyboard shortcut (Cmd+K or /) opens global search

### Grafana — Panel-driven dashboards

**Signatures**:
- Every visualization is a "panel" with consistent header (title + actions + time)
- Drag-to-resize panels
- Variable interpolation in queries
- Dark mode default (engineering audience expectation)
- Color uses semantic queries (red = bad, green = good) tied to thresholds

### Cloudflare Dashboard — Multi-level resource navigation

**Signatures**:
- Three-level breadcrumb (account → resource → setting)
- Status indicators inline with every resource (green/yellow/red dot)
- Quick-access "favorite" buttons on resources
- Inline editing for most settings (click to edit, blur to save with confirmation toast)
- Heavy use of badges for environments (Production, Staging, Preview)

### Sentry / PostHog — Event timeline with drilldown

**Signatures**:
- Stack of events on left, detail panel on right
- Filters as pill chips above the list
- "Breadcrumbs" of user actions leading to the event
- Code-style preformatted blocks for stack traces
- Severity color on the left edge of each event row

### Honeycomb / Tailscale — Engineering-craft minimalism

**Signatures**:
- Restrained color (often near-monochrome)
- Mono labels on every section
- Tables-first, no decorative cards
- Settings pages laid out as definition lists, not card grids
- "Show me the query" exposes the underlying query/JSON

---

## The 12 Engineering Pack Rules

### Layout

**1. Three-zone shell**: persistent sidebar (200–240px) + slim top bar (44–52px) +
content area. No top bar = no global navigation, no shortcuts surface, no env switcher.

**2. KPI strip above the main content**: 4–8 metrics, each `label / value / trend
arrow / sparkline`. Single row, scrolls horizontally on narrow screens. No
isolated "stat cards" with giant icons.

**3. Tables over cards** for any list >10 items. Density is the feature.

**4. High-density mode for wide monitors (≥1920px)**: split content left/right
symmetrically. Datadog and Grafana do this; lots of horizontal real estate is
engineering-pack territory.

### Tables & Data

**5. Sticky headers, solid background**: header `position: sticky; top: 0;
background: var(--color-bg);`. Never transparent (data scrolls behind it).

**6. Right-align numbers, use tabular-nums**: monetary values, counts, percentages,
durations. `font-variant-numeric: tabular-nums`.

**7. Semantic status colors only**: status uses the exact tokens
`--color-success/warning/error/info` or `--color-severity-*`. Never brand color
for status.

**8. URL-synced filter state**: every filter, sort, page, and search updates the
URL via `?filter=…&sort=…&page=…`. Power users share URLs to point teammates at
the exact view.

### Empty & Loading

**9. Skeletons match the loaded layout exactly**: if the loaded state is a 7-column
table, the skeleton is a 7-column table with shimmer bars sized per column. Generic
gray blocks are anti-slop rule violations.

**10. Empty data tells the user what would be here**: not "No data yet" but "No
events received in the last 15 minutes — agents send data via the API. Verify
your API key in Settings."

### Action & Confirmation

**11. Destructive operations get a confirmation modal + undo toast**: modal for
the action ("Delete cluster?"), toast on success with `Undo` (reversible up to 10s).

**12. Inline edit > modal forms** for single-field changes. Click the cell → input
appears → blur or Enter to save → toast confirms.

---

## Field / Ruggedized Tools (Industrial Sub-Pack)

For mobile / tablet apps used outdoors, in vehicles, in warehouses, in factories,
or anywhere physical conditions challenge the UI.

### Field-Specific Overrides

```css
:root[data-pack="engineering-field"] {
  /* Larger tap targets for gloved hands */
  --button-h-default: 56px;
  --input-h-default: 56px;

  /* High-contrast palette for sunlight */
  --color-fg: oklch(15% 0 0);                   /* pure dark */
  --color-bg: oklch(99% 0 0);                   /* pure light */
  --color-border: oklch(50% 0 0);               /* darker border */

  /* Boost text size */
  --text-base: 1.125rem;                        /* 18px */
  --text-lg: 1.25rem;
  --text-xl: 1.5rem;

  /* No light weights */
  --font-weight-regular: 500;
  --font-weight-medium: 600;
  --font-weight-bold: 700;
}
```

### Field Rules

- Tap targets ≥ 48dp (60% larger than Material's 48dp default).
- Stepper inputs for numeric values (no mobile keyboard for short numbers).
- Confirmation required for state-changing actions (no auto-save mid-task — the
  user might be holding the device upside-down).
- High-contrast palette: WCAG AAA contrast (7:1) for body text, not just AA.
- No reliance on hover, tooltips, or fine motor input.
- Large, persistent "back" and "save" buttons in fixed positions.
- Avoid drag-and-drop (Rule 2.5.7 alternative is mandatory; consider banning drag
  entirely).

---

## Data Visualization for Engineering

The brand accent is NOT used in charts. Use the dedicated data viz palettes from
`foundation.md`.

### Common chart types and rules

**Time-series line chart**:
- 1–3 series: use distinct colors from categorical palette.
- 4+ series: use sequential palette + interactive legend (hover to highlight).
- X-axis: time. Y-axis: value. Zero baseline unless data warrants otherwise.
- Hover tooltip with all series values at that timestamp + the exact time.
- Right-edge label per series (Datadog pattern).

**Bar chart**:
- Vertical bars for time/category comparison.
- Horizontal bars when category labels are long.
- Stacked bars only when totals matter; otherwise grouped.
- Always show value on hover; only show on bar when there are few bars and space.

**Heatmap**:
- Sequential single-hue palette.
- Cell tooltips with exact value.
- Min/max scale labels visible.

**Sparkline**:
- 60–120px wide, 16–24px tall.
- Single color (`--color-fg` or muted version of brand).
- Hover reveals value at point + corresponding x.

### Tooling

- **Recharts** — general purpose; pairs well with shadcn.
- **Tremor** — KPI dashboards; built on Recharts.
- **visx** — primitive layer for custom viz.
- **echarts-for-react** — heavier but featureful (heatmaps, treemaps, advanced).
- **D3 directly** — for truly custom or unique visualizations.

For Grafana-style time series at scale: consider **uPlot** (much faster than Recharts
for high-cardinality time series).

---

## 10-Color Categorical Palette

When you need many distinct colors (multi-series charts, tags, environments):

```css
--cat-1: oklch(60% 0.15 250);   /* blue */
--cat-2: oklch(70% 0.18 50);    /* orange */
--cat-3: oklch(60% 0.18 145);   /* green */
--cat-4: oklch(60% 0.22 25);    /* red */
--cat-5: oklch(65% 0.16 290);   /* purple */
--cat-6: oklch(55% 0.1 65);     /* brown */
--cat-7: oklch(72% 0.18 350);   /* pink */
--cat-8: oklch(60% 0.02 270);   /* gray */
--cat-9: oklch(70% 0.18 100);   /* olive */
--cat-10: oklch(65% 0.15 195);  /* cyan */
```

Equal lightness (60–70%) means no color visually dominates. Tableau 10 in OKLCH.

---

## Layout Templates

### Dashboard shell with KPI strip + panel grid

```tsx
<div className="min-h-screen grid grid-cols-[220px_1fr] bg-bg">
  <aside className="border-r bg-surface">
    <SidebarNav />
  </aside>

  <div className="flex flex-col min-h-screen">
    <header className="h-12 border-b flex items-center px-4 gap-3">
      <Breadcrumbs />
      <div className="ml-auto flex items-center gap-2">
        <TimeRangePicker />
        <RefreshButton />
        <Button variant="ghost" size="sm">Share</Button>
      </div>
    </header>

    <main className="flex-1 p-4">
      {/* KPI strip */}
      <section className="grid grid-cols-2 md:grid-cols-4 xl:grid-cols-6 gap-3 mb-4">
        {kpis.map(kpi => (
          <article className="border rounded-md p-3 bg-surface">
            <p className="text-xs text-muted uppercase tracking-uppercase">
              {kpi.label}
            </p>
            <p className="mt-1 text-xl font-medium tabular-nums">{kpi.value}</p>
            <div className="mt-2 flex items-center justify-between">
              <TrendIndicator value={kpi.delta} />
              <Sparkline data={kpi.history} className="h-5 w-16" />
            </div>
          </article>
        ))}
      </section>

      {/* Panel grid */}
      <section className="grid grid-cols-12 gap-3">
        <Panel className="col-span-12 lg:col-span-8">
          <PanelHeader title="Requests/sec" actions={<PanelActions />} />
          <TimeSeriesChart data={data} />
        </Panel>
        <Panel className="col-span-12 lg:col-span-4">
          <PanelHeader title="By status" />
          <BarChart data={statusData} />
        </Panel>
        <Panel className="col-span-12">
          <PanelHeader title="Recent events" />
          <Table>...</Table>
        </Panel>
      </section>
    </main>
  </div>
</div>
```

### High-density tables (logs / events)

```tsx
<Table className="text-xs">
  <TableHeader className="sticky top-0 bg-bg z-10">
    <TableRow className="h-8">
      <TableHead className="w-32 font-mono">Time</TableHead>
      <TableHead className="w-20">Severity</TableHead>
      <TableHead className="w-24 font-mono">Service</TableHead>
      <TableHead>Message</TableHead>
      <TableHead className="w-20 text-right">Duration</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    {events.map(event => (
      <TableRow className="h-7 border-b border-border/50 hover:bg-surface-2">
        <TableCell className="font-mono text-muted tabular-nums">
          {formatTime(event.ts)}
        </TableCell>
        <TableCell>
          <SeverityIndicator level={event.severity} />
        </TableCell>
        <TableCell className="font-mono">{event.service}</TableCell>
        <TableCell className="truncate max-w-md">{event.message}</TableCell>
        <TableCell className="text-right tabular-nums">{event.duration}ms</TableCell>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

28–32px row heights, mono for IDs and timestamps, tabular numerals for durations,
severity as a colored bar/dot — not a Badge component.

### Detail / drill-down panel

```tsx
<div className="grid grid-cols-[1fr_400px] h-screen">
  <main className="overflow-y-auto p-4">
    <Table>...</Table>     {/* event list */}
  </main>
  <aside className="border-l bg-surface overflow-y-auto">
    {selectedEvent ? (
      <div className="p-4 space-y-4">
        <header className="border-b pb-3">
          <h2 className="font-mono text-sm">{selectedEvent.id}</h2>
          <p className="text-xs text-muted">{formatTimeFull(selectedEvent.ts)}</p>
        </header>

        <dl className="grid grid-cols-2 gap-x-4 gap-y-2 text-sm">
          <dt className="text-muted">Service</dt>
          <dd className="font-mono">{selectedEvent.service}</dd>
          <dt className="text-muted">Severity</dt>
          <dd><SeverityIndicator level={selectedEvent.severity} /></dd>
          <dt className="text-muted">Duration</dt>
          <dd className="tabular-nums">{selectedEvent.duration}ms</dd>
          <dt className="text-muted">User</dt>
          <dd className="font-mono">{selectedEvent.userId}</dd>
        </dl>

        <section>
          <h3 className="text-xs uppercase tracking-uppercase text-muted mb-2">
            Stack trace
          </h3>
          <pre className="text-xs bg-bg p-3 rounded border font-mono overflow-x-auto">
            {selectedEvent.stack}
          </pre>
        </section>

        <section>
          <h3 className="text-xs uppercase tracking-uppercase text-muted mb-2">
            Context
          </h3>
          <pre className="text-xs bg-bg p-3 rounded border font-mono overflow-x-auto">
            {JSON.stringify(selectedEvent.context, null, 2)}
          </pre>
        </section>
      </div>
    ) : (
      <EmptyState>Select an event to see details</EmptyState>
    )}
  </aside>
</div>
```

### Severity indicator (semantic color, not Badge)

```tsx
const severityClasses = {
  critical: "bg-severity-critical",
  high:     "bg-severity-high",
  medium:   "bg-severity-medium",
  low:      "bg-severity-low",
  info:     "bg-severity-info",
};

function SeverityIndicator({ level }: { level: keyof typeof severityClasses }) {
  return (
    <span className="inline-flex items-center gap-1.5">
      <span className={cn("size-2 rounded-full", severityClasses[level])} />
      <span className="text-xs uppercase tracking-uppercase">{level}</span>
    </span>
  );
}
```

A dot + label, not a pill. Reads faster in dense tables.

---

## Forms in Engineering UIs

Settings pages are forms-as-content, not modal forms.

```tsx
<section className="max-w-2xl">
  <header className="border-b pb-4 mb-6">
    <h2 className="text-lg font-medium">API access</h2>
    <p className="text-sm text-muted">
      Generate and manage API keys for programmatic access.
    </p>
  </header>

  <dl className="grid grid-cols-[200px_1fr] gap-x-6 gap-y-6">
    <dt className="text-sm pt-2">
      <span className="font-medium">Default key</span>
      <p className="text-muted text-xs mt-1">Used by SDK clients without an explicit key.</p>
    </dt>
    <dd>
      <div className="flex items-center gap-2 font-mono text-sm bg-bg border rounded px-3 py-2">
        sk_live_••••••••••••••••••dE2Q
        <Button variant="ghost" size="sm" className="ml-auto">Copy</Button>
        <Button variant="ghost" size="sm">Rotate</Button>
      </div>
    </dd>

    <dt className="text-sm pt-2">
      <span className="font-medium">Allowed origins</span>
      <p className="text-muted text-xs mt-1">CORS-allowed domains for browser SDK.</p>
    </dt>
    <dd>
      <Textarea
        rows={3}
        placeholder="https://example.com&#10;https://*.example.com"
      />
    </dd>
  </dl>

  <footer className="mt-8 flex justify-end gap-2 border-t pt-4">
    <Button variant="tertiary">Discard</Button>
    <Button variant="primary">Save changes</Button>
  </footer>
</section>
```

Notice: `<dl>` for key-value pairs, semantic, screen-reader-friendly.

---

## Motion for Engineering

Engineering UIs are the **most motion-restrictive** pack. Rules:

- Keyboard actions: instant.
- Inline edit transitions: instant or ≤80ms color shift only.
- Modal/dialog enter: 150ms (faster than default 200ms).
- Toast appear: 150ms.
- Skeleton → content: 100ms cross-fade.
- Chart zoom/pan: respect user input direction, no easing curve.
- Sidebar collapse: 150ms `--ease-fluid`.
- **No** scroll-driven animation anywhere.
- **No** stagger animations on table rows.
- **No** spring physics.
- **No** decorative motion.

Engineers actively dislike motion that wastes their time. Default to less.

---

## Imagery for Engineering

- **Charts and data viz** are the imagery.
- **Code blocks** with syntax highlighting (use `prism-react-renderer` or
  `shiki-react`).
- **Diagrams** for architecture pages (Mermaid, or hand-drawn SVG).
- **Screenshots** of integrations, not illustrations.
- **Logo grid** for integrations supported (this one's OK if logos are full-color
  and asymmetric).

No 3D illustrations. No abstract humans. No floating shapes.

---

## Mono Type Usage

Engineering pack uses mono prominently — but with discipline.

Use mono for:
- IDs, hashes, tokens, signatures.
- Timestamps in tables.
- Code, queries, JSON, YAML, raw API requests/responses.
- File paths.
- Numerical labels in charts (axis labels are often mono in Grafana-style charts).
- Environment names ("production", "staging") in chips.
- Service names in microservice dashboards.

Don't use mono for:
- Body paragraphs.
- Headings.
- Navigation labels.
- Form labels.
- User-facing copy outside of technical data.

Mono is technical. Overuse signals "I tried hard to look hacker-cool."

---

## Hard Bans for Engineering Pack

- ❌ Decorative gradients anywhere in the chrome.
- ❌ Brand color in status indicators.
- ❌ Card-everything (use tables, lists, definition lists).
- ❌ Loose row heights (>48px) in data tables.
- ❌ Centered single-column form layouts in admin panels.
- ❌ Modal forms longer than 6 fields (use a settings page or panel).
- ❌ Auto-animate on scroll.
- ❌ Glass / backdrop-blur on data panels (legibility-killer).
- ❌ Pure black/white text on saturated backgrounds without contrast verification.
- ❌ Marketing-style hero on dashboard pages.
- ❌ Generic "No data yet" empty states (explain what would be here).
- ❌ Drag-only interactions without keyboard/button alternative.
