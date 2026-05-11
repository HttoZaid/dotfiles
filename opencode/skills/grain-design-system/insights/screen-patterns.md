# Screen Patterns

The 5 screen archetypes that cover 90% of mobile and web UI.
Pick the right pattern BEFORE designing a single component.
The pattern determines the layout skeleton. Components fill it.

---

## Pattern 1 — List Screen

**Used by:** Settings, Messages, Contacts, Files, Mail inbox
**When to use:** Displaying a browsable collection of items of the same type

### Anatomy
```
Screen
├── Navigation bar (44pt)
│   ├── Large Title (28px, scrolls and collapses)
│   └── Optional action button (right, --accent, 44×44 target)
├── Optional search bar (36px, 16px margin)
├── Sections (repeating)
│   ├── Section label (10px / UPPERCASE / 0.07em tracking / tertiary)
│   │   └── margin: 16px left, 6px top, 10px bottom
│   └── List card (bg-raised, 1px border, r-lg)
│       └── Rows (44px min, 16px horizontal padding)
│           ├── Icon (32×32, r-sm, semantic bg tint)
│           ├── Title (14px primary) + optional subtitle (11px secondary)
│           └── Right: value + chevron › OR toggle
└── Bottom tab bar (83px total)
```

### Key measurements
- Section label to first row: 10px
- Between section groups: 24–32px
- Row height single-line: 44px
- Row height two-line: 56–60px
- Divider inset with icons: 58px (aligns to text, not edge)

### CSS skeleton
```css
.list-screen { padding: 0 0 83px; }
.section-label { font-size: 10px; font-weight: 500; text-transform: uppercase;
  letter-spacing: .07em; color: var(--text-tertiary);
  padding: 16px 16px 6px; }
.list-card { margin: 0 16px; border-radius: var(--r-lg);
  border: 1px solid var(--border); overflow: hidden; }
.list-row { padding: 12px 16px; min-height: 44px; border-bottom: 1px solid var(--border); }
.list-row:last-child { border-bottom: none; }
```

---

## Pattern 2 — Dashboard Screen

**Used by:** Health, Activity, Finance apps, Analytics dashboards
**When to use:** Surfacing data, metrics, and status at a glance

### Anatomy
```
Screen
├── Navigation bar (44pt) — title + edit/filter action
├── Date/period selector (segmented control or pills)
├── Hero metric section
│   └── Large number (26–48px, weight 300) + label (10px uppercase)
├── Metric card grid (2-col, equal width, gap 10–12px)
│   └── Each card: stat-lbl + stat-val + optional progress bar
├── Chart section
│   └── Bars only. No grid lines. No decorative borders.
│       6px bar radius. Semantic color fills.
├── Recent activity list (same as List pattern)
└── Bottom tab bar
```

### Key measurements
- Hero number: 26–48px, weight 300
- Metric card padding: 12–14px
- Chart height: 40–80px inline, 160–200px for featured chart
- Progress bar height: 6px
- Grid gap: 10–12px

### Rules
- Numbers own the screen — UI defers to them
- Color only on the metric that needs emphasis (danger if at risk, success if goal met)
- Charts strip all decoration — Tufte's data-to-ink ratio in practice
- Empty metric = show the goal, not "—"

---

## Pattern 3 — Detail / Article Screen

**Used by:** App Store feature, News article, Product page, Profile detail
**When to use:** Single item full presentation — one thing, explored deeply

### Anatomy
```
Screen
├── Navigation (inline, transparent over hero)
│   └── Back button + optional share/action
├── Hero area (full-bleed, no horizontal padding)
│   └── Image, illustration, or gradient — 200–320px tall
├── Content area (16px horizontal padding)
│   ├── Eyebrow (10px uppercase tertiary) — e.g. "CATEGORY · 4 MIN READ"
│   ├── Title (19–22px, weight 500, lh 1.25)
│   ├── Subtitle/author (13px secondary)
│   ├── Body text (15px, lh 1.65)
│   └── Action section
│       └── Primary CTA button (full-width or prominent)
└── Optional sticky bottom CTA (44pt + safe area)
```

### Key measurements
- Hero: full-bleed, zero horizontal margin
- Content top padding: 16px below hero
- Title line-height: 1.2–1.3
- Body max-width: 600px (desktop), full width (mobile)
- CTA margin-top: 20–24px from last content element

---

## Pattern 4 — Form Screen

**Used by:** Onboarding, Settings edit, Checkout, Sign up
**When to use:** Collecting structured input from the user

### Anatomy
```
Screen
├── Navigation (44pt, back button, optional step indicator)
├── Title (22px weight 500) + optional subtitle (15px secondary)
├── Form body (16px horizontal padding)
│   ├── Field group
│   │   ├── Label (12px weight 500 secondary, always above)
│   │   ├── Input (38px, 1px border, 8px radius)
│   │   └── Hint or error (11px, below input)
│   └── Fields spaced 18px apart, groups 28px apart
├── Submit / next button
│   └── Full-width primary OR sticky bottom-bar
└── Safe area clearance (34px)
```

### Rules
- Label ABOVE input, always visible (never placeholder-only)
- Validate on blur, show error immediately below that field
- Focus ring: box-shadow: 0 0 0 3px accent@12% — NEVER border-width change
- One column always on mobile
- Submit button: VERB label ("Save changes", "Continue", "Create account")
- Never more than 7 fields on one screen — split into steps if more

---

## Pattern 5 — Empty State Screen

**Used by:** First launch, empty search results, no data yet
**When to use:** No content to show — but there WILL be

### Anatomy
```
Screen
├── Navigation (optional, context-dependent)
├── Centered content (vertical + horizontal)
│   ├── Illustration or icon (64–80px, use accent or neutral tone)
│   ├── Title (20px weight 500, primary) — margin-top: 16px
│   ├── Body (15px regular, secondary, max-width 280px, centered)
│   │   └── "Explain WHY it's empty AND what happens next"
│   └── CTA button (primary) — margin-top: 20px
└── Optional secondary link (ghost button or text link below CTA)
```

### Rules
- "No results" alone is NOT an empty state — it's a failure state
- Every empty state answers: WHY is this empty? WHAT should I do?
- The CTA in an empty state is the most important onboarding action
- Background is --bg (page color), not a card — the screen IS the state
- Illustration should be simple (1–2 colors, outline style)

---

## Choosing the Right Pattern

```
Content type                     Pattern
─────────────────────────────────────────────────────────────
List of similar items            List screen
Metrics and data                 Dashboard screen
One thing in depth               Detail screen
Collecting user input            Form screen
Nothing to show yet              Empty state screen
```

## Combining Patterns

Some screens combine two patterns:
- Dashboard + List: metrics hero section, then activity list below (Health)
- Detail + Form: view mode and edit mode on same screen (Contacts)
- List + Empty state: list renders empty state when array is empty

When combining, the PRIMARY pattern determines the navigation and page title.
The secondary pattern slots in as a section within the primary layout.
