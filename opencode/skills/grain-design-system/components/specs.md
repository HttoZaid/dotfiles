# Component Specifications

Exact pixel values, CSS classes, and behavioral rules for every Grain component.
Reference this file when building any UI component.

---

## BUTTONS

### Variant specs
```
Variant     bg              color    border              border-radius
──────────────────────────────────────────────────────────────────────
primary     var(--accent)   #fff     none                var(--r-md)
secondary   transparent     primary  1px var(--border-strong)  var(--r-md)
ghost       transparent     accent   none                var(--r-md)
danger      var(--danger)   #fff     none                var(--r-md)
```

### Size specs
```
Size    padding       font-size   height   border-radius
────────────────────────────────────────────────────────
sm      6px 14px      12px        30px     var(--r-sm)
base ★  9px 18px      14px        38px     var(--r-md)
lg      13px 26px     16px        50px     var(--r-lg)
pill    9px 20px      14px        38px     var(--r-full)
icon    0              —          36px     var(--r-md)  (width=36px too)
```

### States
```css
/* Hover */
.btn-primary:hover  { background: var(--accent-hover); }
.btn-secondary:hover { background: var(--bg-subtle); }
.btn-ghost:hover    { background: var(--accent-subtle); }

/* Active */
.btn:active         { transform: scale(.97); }

/* Disabled */
.btn:disabled       { opacity: .38; cursor: not-allowed; }
.btn:disabled:active { transform: none; }

/* Transition */
.btn                { transition: all 120ms cubic-bezier(.4,0,.2,1); }
```

### Rules
- ONE primary button per screen
- Labels are verbs: "Save changes" not "Confirm"
- Loading: replace label with spinner + "Saving…" + disabled
- Disabled = 38% opacity, never hidden from DOM

---

## FORM INPUTS

### Input base
```css
.input {
  width: 100%;
  padding: 9px 12px;
  font-size: 14px;
  background: var(--bg-raised);
  color: var(--text-primary);
  border: 1px solid var(--border-strong);
  border-radius: var(--r-md);
  outline: none;
  transition: border-color 120ms, box-shadow 120ms;
}
```

### States
```css
.input:hover     { border-color: <palette-300>; }
.input:focus     { border-color: var(--accent); box-shadow: 0 0 0 3px <accent@12%>; }
.input.error     { border-color: var(--danger); }
.input.error:focus { box-shadow: 0 0 0 3px rgba(190,48,48,.12); }
.input.success   { border-color: var(--success); }
```

### Field anatomy
```
field-label    12px · weight 500 · --text-secondary · margin-bottom 5px
input          height 38px · padding 9px 12px · 14px
field-hint     11px · --text-tertiary · margin-top 5px
field-error    11px · --danger · margin-top 5px
```

### Textarea
```css
textarea.input { resize: vertical; min-height: 88px; }
```

### Select
```css
select.input {
  appearance: none;
  background-image: url("data:image/svg+xml,...chevron...");
  background-repeat: no-repeat;
  background-position: right 12px center;
  padding-right: 32px;
}
```

### Segmented control
```css
.seg      { display: flex; background: var(--bg-subtle); border-radius: 9px; padding: 2px; gap: 2px; }
.seg-opt  { padding: 6px 16px; border-radius: 7px; font-size: 13px; transition: all 220ms; }
.seg-opt.active { background: var(--bg-raised); font-weight: 500; box-shadow: var(--shadow-sm); }
```

---

## CARDS

### Stat card (metrics)
```css
.stat {
  background: var(--bg-subtle);
  border-radius: var(--r-md);
  padding: 14px;
}
/* Label: 11px tertiary | Value: 22px 500 primary | Sub: 11px secondary */
```

### Content card
```css
.card {
  background: var(--bg-raised);
  border: 1px solid var(--border);
  border-radius: var(--r-lg);
  padding: 20px;
}
```

### Floating card (dropdown, modal)
```css
.floating {
  background: var(--bg-raised);
  border-radius: var(--r-xl);
  box-shadow: var(--shadow-lg);
  padding: 20px;
}
```

### Profile / data record card
```
Avatar:   44×44px · border-radius 50% · bg: accent-subtle · text: accent
Name:     15px · weight 500 · primary
Role:     12px · secondary
Divider:  1px var(--border) · padding-top 12px
Table:    13px · label secondary · value right-aligned
```

### Card rules
- 12px radius for cards, 8px or less for inner elements (never same as parent)
- 20px padding for content cards, 14px for compact stat cards
- One purpose per card — split when mixing concerns
- 1px border replaces shadows in most cases

---

## LIST ROWS

### Grouped list
```css
.list-card { background: var(--bg-raised); border: 1px solid var(--border); border-radius: var(--r-lg); overflow: hidden; }
.list-row  { display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-bottom: 1px solid var(--border); transition: background 120ms; cursor: pointer; min-height: 44px; }
.list-row:hover   { background: var(--bg-subtle); }
.list-row:last-child { border-bottom: none; }
```

### List icon
```css
.list-icon {
  width: 32px; height: 32px;
  border-radius: var(--r-sm);   /* 6px */
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
/* NEVER circle except for avatars */
```

### Title + subtitle
```
.list-title   14px · --text-primary · weight 400
.list-sub     11px · --text-secondary · margin-top 1px
.list-right   12px · --text-tertiary
.chevron      › character · 11px · right side
```

### Toggle
```css
.tog-track {
  width: 44px; height: 26px;
  border-radius: 13px;
  background: var(--border-strong);
  cursor: pointer;
  transition: background 220ms cubic-bezier(.4,0,.2,1);
}
.tog-track.on { background: var(--success); }
.tog-thumb {
  position: absolute;
  width: 22px; height: 22px;
  border-radius: 11px;
  background: white;
  top: 2px; left: 2px;
  box-shadow: 0 1px 3px rgba(0,0,0,.2);
  transition: left 220ms cubic-bezier(.4,0,.2,1);
}
.tog-track.on .tog-thumb { left: 20px; }
```

### Row heights
```
Single-line row:   44px min-height
Two-line row:      56–60px
Horizontal padding: 16px (screen edge rule)
Divider inset:     58px when icons present (aligns to text, not edge)
```

---

## BADGES

### Sizes and specs
```css
.badge {
  display: inline-flex;
  align-items: center;
  font-size: 11px;
  font-weight: 500;
  padding: 3px 8px;
  border-radius: var(--r-sm);   /* 6px */
  white-space: nowrap;
}
```

### Variants
```
.badge-neutral   bg: --bg-subtle        text: --text-secondary
.badge-accent    bg: accent-100         text: accent-700
.badge-success   bg: --success-subtle   text: success-700
.badge-warning   bg: --warning-subtle   text: warning-600
.badge-danger    bg: --danger-subtle    text: danger-600
.badge-info      bg: --info-subtle      text: info-700
```

### Notification indicators
```
Dot:    10×10px · bg: --danger · border-radius 50% · border: 1.5px solid --bg
Badge:  min-width 18px · height 18px · bg: --danger · border-radius 9px · border: 2px solid --bg
        font-size 10px · weight 500 · color white · padding 0 4px
Position: absolute · top: -6px right: -6px
```

---

## FILTER PILLS

```css
.pill {
  padding: 6px 16px;
  border-radius: var(--r-full);
  font-size: 13px;
  color: var(--text-secondary);
  border: 1px solid var(--border-strong);
  background: transparent;
  cursor: pointer;
  transition: all 120ms;
}
.pill:hover  { border-color: var(--border-primary); color: var(--text-primary); }
.pill.active { background: var(--text-primary); color: var(--bg); border-color: transparent; }
```

---

## PROGRESS BAR

```css
.prog-wrap {
  background: var(--bg-subtle);
  border-radius: var(--r-full);
  height: 6px;
  overflow: hidden;
}
.prog-fill {
  height: 100%;
  border-radius: var(--r-full);
  background: var(--accent);
  transition: width 380ms cubic-bezier(.4,0,.2,1);
}
```

---

## MODAL / SHEET

### Bottom sheet
```css
.sheet {
  position: fixed;
  bottom: 0; left: 0; right: 0;
  background: var(--bg-raised);
  border-radius: var(--r-2xl) var(--r-2xl) 0 0;
  padding: 20px 20px calc(20px + env(safe-area-inset-bottom));
  box-shadow: var(--shadow-lg);
}
/* Handle bar: 32×4px · bg: --border-strong · border-radius 2px · margin: 0 auto 16px */
```

### Modal overlay
```css
.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,.45);
  display: flex; align-items: center; justify-content: center;
}
.modal {
  background: var(--bg-raised);
  border-radius: var(--r-2xl);
  padding: 28px;
  max-width: 480px; width: calc(100% - 32px);
  box-shadow: var(--shadow-lg);
}
```

---

## NAVIGATION BAR

```
Height:        44pt standard, 96pt large-title
Large title:   28px weight 500 · scrolls with content · collapses to 44pt
Nav title:     17px weight 500 · always visible in nav bar
Back button:   ‹ chevron + label · 44×44pt touch target · --accent color
Action items:  text actions: 17px --accent · icon actions: 44×44pt target
Separator:     1px --border · only on scroll (not always visible)
```

---

## TAB BAR (iOS)

```
Total height:  83px (49pt content + 34pt safe area)
Icon size:     25×25pt
Label size:    10pt
Active color:  --accent
Inactive:      --text-tertiary
Background:    --bg-raised with blur material if possible
```

---

## EMPTY STATES

```
Icon/illustration: centered · 64–80px
Title:    20px weight 500 · primary · margin-top 16px
Body:     15px regular · secondary · max-width 280px · centered · margin-top 8px
CTA:      primary button · margin-top 20px
```

Rule: Empty states are onboarding moments. "No results" is not a design.
Every empty state explains WHY it's empty AND what to do next.

---

## SCREEN PATTERNS

### List screen (Settings, Messages, Contacts)
- Section labels: 10px / UPPERCASE / 0.07em letter-spacing / tertiary / 16px margin bottom
- Rows: 44px min, 56px with subtitle, 16px horizontal padding
- List icons: 32×32, --r-sm, semantic background tint
- Grouped in cards with 1px border, 12px radius
- Page title Large (28px+), collapses on scroll

### Dashboard screen (Health, Activity, Finance)
- Hero numbers: 26–48px, weight 300
- Metric cards: equal-width 2-col grid
- Progress bars: 6px, semantic color
- Charts: bars only, no grid lines, no borders

### Detail screen (Product, Article, Profile)
- Hero: full-bleed, no horizontal padding
- Content starts at 16px margin below hero
- Category: 11px / UPPERCASE / tertiary
- Title: 18–20px / weight 500
- CTA: full-width at bottom of content block

### Form screen
- One column, full width
- Labels above inputs, always visible
- 18px gap between fields
- Submit button: full-width primary at bottom
- Error messages: inline, on blur, specific

### Empty state screen
- Centered vertically and horizontally
- Icon → Title → Body → CTA
- Background: --bg (not a card)
