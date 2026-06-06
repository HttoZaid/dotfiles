# Accessibility — WCAG 2.2 AA

Every Grain component must meet WCAG 2.2 AA. This file is the working reference,
not the spec — for spec, see w3.org/TR/WCAG22/. Treat AA as floor, not ceiling.

WCAG 2.2 was published as a **W3C Recommendation on October 5, 2023**. It adds 9 new
success criteria and removes 4.1.1 Parsing, for a total of 86 criteria. Six of the
new criteria affect AA.

---

## The Six WCAG 2.2 AA Criteria That Apply To Every Component

These were not in 2.1. They're required now.

### 2.4.11 Focus Not Obscured (Minimum) — Level AA

When a component receives focus, it must not be entirely hidden by author-created
content (sticky headers, cookie banners, fixed footers, chat widgets).

**Implementation**: Use `scroll-margin-top` on focusable elements to push them below
sticky headers:

```css
:focus-visible {
  scroll-margin-top: 80px;   /* match sticky header height */
}
```

When a sticky cookie banner exists, ensure focus rings remain visible above it
(higher z-index) or that focus auto-scrolls the page.

### 2.4.13 Focus Appearance — Level AAA (treat as required)

The focus indicator must:
- Be **at least 2 CSS pixels thick** around the component.
- Have **contrast ratio of at least 3:1** between focused and unfocused states.
- Have **contrast ratio of at least 3:1** against adjacent colors.

```css
:focus-visible {
  outline: 2px solid var(--color-ring);
  outline-offset: 2px;
}
```

Verify `--color-ring` against your background AND against the foreground of the
focused element. On a button with `bg-accent`, the ring shouldn't blend into the
accent — use offset and a different hue if needed.

### 2.5.7 Dragging Movements — Level AA

Every drag interaction must have a **single-pointer non-drag alternative**.

If your UI has drag-to-reorder, add up/down arrow buttons. If it has drag-to-resize,
add explicit size controls. If a kanban board drags cards between columns, also
provide a "Move to…" action via keyboard menu.

```tsx
<ListItem>
  <DragHandle aria-label="Drag to reorder" />
  <span>{item.name}</span>
  <MoveActions>
    <IconButton aria-label="Move up"><ArrowUp /></IconButton>
    <IconButton aria-label="Move down"><ArrowDown /></IconButton>
  </MoveActions>
</ListItem>
```

### 2.5.8 Target Size (Minimum) — Level AA

Interactive targets must be **at least 24 × 24 CSS pixels**, OR have adequate
spacing around them so the effective tap area is larger.

Grain's default exceeds this: 36px+ for web, 44pt iOS, 48dp Android. Apply 24×24
only when space is truly constrained (data tables with action icons).

Exceptions in WCAG 2.2:
- Inline text links.
- Browser/user-agent controls.
- Essential targets (e.g., interactive map markers when location-accurate).

### 3.2.6 Consistent Help — Level A

If a Help mechanism (contact info, chat, FAQ link) appears on multiple pages, it
must appear in the **same relative order** on each page.

Typical implementation: put the Help link in the footer or top-right of header,
and keep its position consistent.

### 3.3.7 Redundant Entry — Level A

Don't ask the user to re-enter information they've already provided in the same
process, unless:
- It's essential (re-confirming a password).
- The previous info is no longer valid.
- Auto-population would be a security risk.

Auto-populate or offer to select previously-entered values.

### 3.3.8 Accessible Authentication (Minimum) — Level AA

No cognitive function test (e.g., math problem, puzzle, transcription) is required
to authenticate, unless:
- An alternative exists.
- The test is to recognize the user's own content.

Use passkeys, OAuth, magic links, or password managers (allow paste; support
`autocomplete="current-password"`). CAPTCHAs are discouraged; if used, provide an
alternative (audio, accessibility token).

---

## Color Contrast

WCAG 2.2 AA requires:

| Content | Minimum contrast |
|---|---|
| Body text (<18px regular, <14px bold) | 4.5:1 |
| Large text (≥18px regular, ≥14px bold) | 3:1 |
| UI components, graphical objects (1.4.11) | 3:1 |
| Focus indicators (1.4.11 + 2.4.13) | 3:1 against adjacent |

### Testing tools

- Chrome DevTools → Inspect → Accessibility tab shows contrast ratio.
- WebAIM Contrast Checker (webaim.org/resources/contrastchecker/).
- Stark plugin (Figma, browser).
- Axe DevTools extension.

### Common failures

- `--color-muted` on `--color-bg`: at `oklch(55% 0.02 270)` on `oklch(99% 0.004 270)`,
  ratio ≈ 4.6:1 — passes for body, doesn't pass at smaller sizes.
- Branded button with light text on a mid-tone accent: verify before shipping.
- White text on glass/translucent backgrounds: blur changes apparent contrast.
- Status badges: `text-success` on `bg-success-soft` must clear 4.5:1 for the text.

---

## Keyboard Navigation

**Every interactive element** must be reachable and operable via keyboard.

### The keyboard contract

| Element | Keys |
|---|---|
| Button | Tab to focus, Space/Enter to activate |
| Link | Tab to focus, Enter to activate |
| Checkbox | Tab to focus, Space to toggle |
| Radio | Tab to group, Arrow keys within group, Space to select |
| Select | Tab to focus, Space/Enter to open, Arrow to navigate, Enter to choose, Esc to close |
| Combobox | Tab to focus, type to filter, Arrow to navigate, Enter to choose |
| Dialog | Tab traps inside, Esc closes, Tab/Shift+Tab cycles |
| Tabs | Tab to active tab, Arrow keys switch tabs |
| Menu | Arrow keys navigate, Enter activates, Esc closes |
| Slider | Tab to focus, Arrow keys adjust, Home/End jump to min/max |

### Tab order

The DOM order is the tab order. Don't use `tabindex` values >0 (creates fragile
ordering). Use `tabindex="0"` to add an element to the order, `tabindex="-1"` to
remove it (focusable programmatically only).

### Skip links

The first focusable element on every page should be a skip link:

```tsx
<a
  href="#main"
  className="absolute -top-10 left-2 focus:top-2 bg-bg text-fg px-3 py-2 rounded-md z-50"
>
  Skip to main content
</a>
```

It's visually hidden by default but appears on focus, allowing keyboard users to
bypass repeated navigation.

### Focus management in SPAs

When the route changes in a single-page app, focus must move to the new content.
Don't leave focus on the navigation link that was clicked.

```tsx
// app/[route]/page.tsx
useEffect(() => {
  document.getElementById("main")?.focus();
}, [pathname]);
```

Or send focus to the H1 of the new page.

---

## Screen Reader Support

Use **semantic HTML before ARIA**. The first rule of ARIA is "don't use ARIA."

### Semantic HTML cheat sheet

| Use | Don't use |
|---|---|
| `<button>` | `<div onClick>` |
| `<a href>` | `<div onClick>` for navigation |
| `<nav>` | `<div className="nav">` |
| `<main>` | `<div className="main">` (one per page) |
| `<header>`, `<footer>` | `<div role="banner">` |
| `<article>` | `<div className="article">` |
| `<section>` (with heading) | `<div className="section">` |
| `<ul>`, `<ol>` | styled `<div>`s |
| `<dl>` | `<div>` for key-value pairs |
| `<table>` | `<div className="table">` for tabular data |
| `<form>`, `<input>`, `<label>` | styled custom inputs without labels |
| `<details>`, `<summary>` | JS-only accordions |
| `<dialog>` (with Radix) | `<div role="dialog">` without focus trap |
| `<time datetime>` | `<span>` for dates |

### Headings

- Exactly one `<h1>` per page.
- Never skip heading levels (`<h1>` → `<h3>` skips `<h2>`).
- Use heading hierarchy to communicate document structure, not styling. If you need
  a smaller heading, style it differently, don't pick the wrong level.

### Landmarks

Every page should have:
- One `<header>` (site or page).
- One `<main>` (primary content, exactly one).
- One `<nav>` (or multiple with `aria-label` for primary, secondary, footer nav).
- One `<footer>`.
- `<aside>` for tangential content (sidebars, related links).

### ARIA — when you do need it

Only when semantic HTML can't express the role. Common legitimate uses:

```tsx
// Custom widget with no native equivalent
<div role="tablist">
  <button role="tab" aria-selected={isActive}>Overview</button>
</div>

// Live region for dynamic content
<div aria-live="polite" aria-atomic="true">
  {messageCount} new messages
</div>

// Labelling icon-only buttons
<button aria-label="Close dialog">
  <X />
</button>

// Linking helper text to input
<input id="email" aria-describedby="email-helper" />
<p id="email-helper">We'll never share this.</p>

// Indicating expanded/collapsed
<button aria-expanded={isOpen} aria-controls="menu-list">
  Menu
</button>
```

### Live regions

For dynamic content updates (toasts, error messages, search results count):

```tsx
<div aria-live="polite" aria-atomic="true" className="sr-only">
  {announcement}
</div>
```

- `aria-live="polite"`: announce when idle (don't interrupt current speech).
- `aria-live="assertive"`: announce immediately. Use for errors only.
- `aria-atomic="true"`: read the whole region, not just the changed part.

Sonner toasts handle this automatically.

### Visually hidden but screen-reader-accessible

```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

Use for:
- Skip links (until focused)
- Form field hints that should be announced but not visible
- Context for icon-only buttons (in addition to `aria-label`)

---

## Forms

### Every input has a label

```tsx
<label htmlFor="email">Email address</label>
<input id="email" type="email" autoComplete="email" required />
```

Never use placeholder as label. Placeholders disappear on focus and don't get
announced consistently by screen readers.

### Required fields

```tsx
<label htmlFor="email">
  Email <span aria-hidden="true">*</span>
  <span className="sr-only">(required)</span>
</label>
<input id="email" required aria-required="true" />
```

### Error handling

```tsx
<label htmlFor="email">Email</label>
<input
  id="email"
  type="email"
  aria-invalid={hasError}
  aria-describedby={hasError ? "email-error" : undefined}
/>
{hasError && (
  <p id="email-error" className="text-error" role="alert">
    Please enter a valid email address.
  </p>
)}
```

- `aria-invalid` on the input.
- Error message linked via `aria-describedby`.
- `role="alert"` ensures the error is announced when it appears.
- Place error directly below the field, never above.

### Fieldset for grouped inputs

```tsx
<fieldset>
  <legend>Notification preferences</legend>
  <label><input type="checkbox" /> Email</label>
  <label><input type="checkbox" /> SMS</label>
  <label><input type="checkbox" /> Push</label>
</fieldset>
```

Style `<legend>` like a section heading. Use `<fieldset>` for radio groups and
checkbox groups (5+ items).

### `autocomplete` attribute

Mandatory on every appropriate field. Helps autofill, password managers,
accessibility.

```tsx
<input autoComplete="email" />
<input autoComplete="given-name" />
<input autoComplete="family-name" />
<input autoComplete="street-address" />
<input autoComplete="postal-code" />
<input autoComplete="tel" />
<input autoComplete="current-password" />
<input autoComplete="new-password" />
<input autoComplete="one-time-code" />
```

Full list: developer.mozilla.org/en-US/docs/Web/HTML/Attributes/autocomplete.

### `inputmode` and `type`

```tsx
<input type="email" inputMode="email" />
<input type="tel" inputMode="tel" />
<input type="number" inputMode="numeric" />
<input type="text" inputMode="decimal" /> {/* for currency */}
<input type="search" inputMode="search" />
<input type="url" inputMode="url" />
```

Correct keyboards appear on mobile, improving entry speed and accuracy.

---

## Images & Media

### Alt text

```tsx
{/* Informational image */}
<img src="..." alt="Founder Jane Doe speaking at TechConf 2024" />

{/* Decorative image */}
<img src="..." alt="" />   {/* empty alt, skipped by SR */}

{/* Icon (decorative when text label exists) */}
<button>
  <Save aria-hidden="true" />
  Save
</button>

{/* Icon-only button */}
<button aria-label="Save">
  <Save aria-hidden="true" />
</button>
```

Alt text guidelines:
- Be specific. "Jane Doe speaking" beats "Person on stage."
- Don't repeat what's in surrounding text.
- Empty `alt=""` for purely decorative images.
- Don't say "Image of…" or "Photo of…" — screen readers already announce it as an image.

### Video and audio

- Captions for all spoken content (`<track kind="captions">`).
- Transcript for audio-only content.
- Visible play/pause controls (don't autoplay with sound).
- `prefers-reduced-motion` disables autoplay video backgrounds.

### Complex images (charts, diagrams)

Provide a long description:

```tsx
<figure>
  <img src="chart.png" alt="Revenue chart, see description below" />
  <figcaption>
    Q4 revenue grew from $1.2M in October to $2.8M in December, with the largest
    month-over-month increase (47%) occurring in November.
  </figcaption>
</figure>
```

---

## Mobile Accessibility

### Tap targets

- **iOS**: 44 × 44 pt (Apple HIG).
- **Android**: 48 × 48 dp (Material).
- **Web**: 24 × 24 CSS px (WCAG 2.5.8 minimum), but Grain default is 44.

If a target must be smaller, add spacing so the effective tap area is 44pt.

### Dynamic Type / Font Scaling

Both iOS Dynamic Type and Android font scaling let users increase text size. Don't
disable this.

iOS:
```swift
Text("Hello").font(.body)   // uses Dynamic Type
```

Android:
```kotlin
Text("Hello", style = MaterialTheme.typography.bodyLarge)
```

Web:
```css
html { font-size: 100%; }  /* respect user's browser zoom */
```

Never set `font-size` in `px` for body text — use `rem` so it scales with the user's
root font preference.

### VoiceOver / TalkBack labels

Mobile screen readers announce content. Every interactive element needs a meaningful
label.

iOS:
```swift
Button { } label: { Image(systemName: "trash") }
  .accessibilityLabel("Delete project")
```

Android:
```kotlin
IconButton(onClick = { }, modifier = Modifier.semantics {
  contentDescription = "Delete project"
}) { Icon(Icons.Default.Delete, contentDescription = null) }
```

---

## Testing

### Manual

- Tab through the entire page — can you reach every interactive element?
- Test in keyboard only (no mouse) for 10 minutes.
- Turn on VoiceOver (Cmd+F5 on Mac) or TalkBack (Android Settings → Accessibility)
  and try to complete a task.
- Toggle reduced motion in OS settings.
- Zoom to 200% in browser — does layout still work?

### Automated

- `axe-core` via @axe-core/react or Cypress plugin
- Lighthouse Accessibility audit (Chrome DevTools)
- WAVE browser extension
- Storybook a11y addon

Automated tools catch ~30% of issues. The rest require manual testing.

---

## Grain Components A11y Checklist

When generating any component, verify:

- [ ] **Focusable**: All interactive elements receive focus on Tab.
- [ ] **Focus visible**: 2px ring, 3:1 contrast, never `outline: none` alone.
- [ ] **Keyboard activatable**: Space/Enter for buttons, Enter for links.
- [ ] **Labeled**: Inputs have `<label>`, icon buttons have `aria-label`.
- [ ] **Hierarchy**: One H1, no skipped levels, semantic landmarks present.
- [ ] **Contrast**: All text passes 4.5:1 (body) or 3:1 (large).
- [ ] **Drag alternative**: If drag is supported, non-drag alternative exists.
- [ ] **Target size**: ≥24px (default 36–44).
- [ ] **Color not sole differentiator**: Status uses icon + color, not color alone.
- [ ] **Reduced motion**: Animations disabled or shortened.
- [ ] **Error messages**: Inline, linked via `aria-describedby`, `role="alert"` on appear.
- [ ] **Autocomplete**: Forms have proper `autocomplete` and `inputmode`.
- [ ] **Alt text**: Images have meaningful alt or `alt=""` if decorative.
- [ ] **Skip link**: Page has skip-to-main link as first focusable element.

If three or more fail, the component is not ready to ship.

---

## Resources

- WCAG 2.2 spec: w3.org/TR/WCAG22/
- "What Are All 87 WCAG 2.2 Success Criteria?" — testparty.ai/blog/wcag-22-success-criteria-list
- Deque University WCAG 2.2 Updates: dequeuniversity.com/resources/wcag-2.2/
- AllAccessible WCAG 2.2 Complete Guide 2025
- WebAIM Articles: webaim.org/articles/
- Inclusive Components by Heydon Pickering: inclusive-components.design
- A11y Project: a11yproject.com
- Radix UI Primitives — accessible by default, the right starting point.
