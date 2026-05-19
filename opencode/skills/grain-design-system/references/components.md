# Component Specs

Detailed specifications for every primitive Grain ships. Each component has:
- **Default** — the always-correct version when no industry pack is specified.
- **States** — every state the component must implement.
- **Hard limits** — what's never acceptable.
- **Industry pack overrides** — when the default changes.

Read this file when generating any of: Button, ButtonLink, IconButton, Input,
Textarea, Select, Combobox, Checkbox, Radio, Switch, Card, Surface, Modal/Dialog,
Sheet, Popover, Tooltip, Toast, Table, DataGrid, List, ListItem, Badge, Avatar,
Tab, Breadcrumb, Pagination, EmptyState, Skeleton, Spinner.

---

## Button

### Default spec

```tsx
<Button size="md" variant="primary">
  Save changes
</Button>
```

| Property | Default |
|---|---|
| Heights | xs 28 / sm 32 / md 36 / lg 44 / xl 52 px |
| Horizontal padding | 1.5× vertical: xs 8 / sm 12 / md 16 / lg 20 / xl 24 px |
| Radius | `--radius-pill` (capsule) |
| Font weight | 500 (medium) |
| Font size | xs 13 / sm 13 / md 14 / lg 15 / xl 16 px |
| Letter spacing | 0 |
| Min width (with text) | 80px |
| Min width (icon-only) | matches height (square) |

### Variants

| Variant | Use | Style |
|---|---|---|
| `primary` | Single most important action per screen | bg-accent, fg-accent-fg |
| `secondary` | Co-equal action | bg-surface-2, fg, border |
| `tertiary` | Low-emphasis | text only, no background |
| `outline` | Alternative secondary | transparent bg, border-border, fg |
| `destructive` | Delete, irreversible | bg-error, fg-error-fg |
| `ghost` | Nav, toolbars | transparent bg, hover bg-surface-2 |
| `link` | Inline navigation | underlined text, no padding |

### States (every variant implements all)

```
default | hover | active | focus-visible | disabled | loading
```

**Hover**: lighten or darken background by 5–8%; add `--shadow-pop` if elevated.
**Active**: scale 0.98, deepen background.
**Focus-visible**: 2px ring at `--color-ring`, `outline-offset: 2px`.
**Disabled**: opacity 0.5, `cursor: not-allowed`, no pointer events.
**Loading**: replace label with spinner, fix `min-width` to prevent layout shift.

### Transitions

```css
button {
  transition:
    background-color var(--duration-fast) var(--ease-fluid),
    color var(--duration-fast) var(--ease-fluid),
    box-shadow var(--duration-fast) var(--ease-fluid),
    transform 80ms ease-out;
}
button:active { transform: scale(0.98); }
```

### Hard limits

- ❌ Never apply `rounded-2xl` unless industry pack requires.
- ❌ Never use brand color as background on a secondary button.
- ❌ Never combine `shadow-lg` + hover `shadow-2xl` + scale 1.05.
- ❌ Never use `cursor: pointer` on disabled buttons.
- ❌ Never auto-submit forms on Enter without a visible primary button.

### Pack overrides

| Pack | Button radius | Default size | Notes |
|---|---|---|---|
| SaaS | pill | md (36px) | Capsule default |
| Corporate | pill | lg (44px) | Larger for marketing CTAs |
| Engineering | sm (4px) | sm (32px) | Sharp, dense |
| iOS | concentric | lg (44pt) | Apple HIG 44pt minimum |
| Android M3 | pill | md (40dp) | M3 sizes XS 32/S 36/M 40/L 48/XL 56 |

### iOS Liquid Glass specifics (iOS 26+)

```swift
Button("Save") { /* ... */ }
  .buttonStyle(.glass)         // Liquid Glass material
  .buttonBorderShape(.capsule)
  .controlSize(.large)         // 44pt height
```

### Material 3 Expressive specifics

```kotlin
Button(
  onClick = { },
  shape = ButtonDefaults.shape,  // pill default; shape-morphs to rounded square on press
) { Text("Save") }
```

---

## ButtonLink

A button that performs navigation (changes URL). Visually identical to Button but
renders as `<a>` semantically. Vercel Geist makes this distinction explicit:
`Button` for state-mutating actions, `ButtonLink` for navigation.

```tsx
<ButtonLink href="/dashboard" variant="primary">
  Open dashboard
</ButtonLink>
```

Rules:
- Use the correct semantic element. `<a>` for navigation, `<button>` for actions.
- ButtonLink supports `target="_blank"` + `rel="noopener noreferrer"` for external.
- ButtonLink with `prefetch={true}` on Next.js for hover-warmed routes.

---

## IconButton

Square button containing only an icon. ARIA label required.

```tsx
<IconButton aria-label="Close" size="md">
  <X />
</IconButton>
```

| Property | Default |
|---|---|
| Size | square: sm 32 / md 36 / lg 44 px |
| Icon size | sm 14 / md 16 / lg 20 px |
| Radius | pill OR matching context |
| Min tap target (mobile) | 44pt (iOS) / 48dp (Android) |

Rules:
- Always provide `aria-label`.
- Match icon weight to context (Phosphor `regular` for app chrome, `bold` for active).
- Don't put more than 5 icon buttons in a row without a divider.

---

## Input (text)

```tsx
<Input
  label="Email"
  type="email"
  placeholder="you@example.com"
  helperText="We'll never share this."
/>
```

| Property | Default |
|---|---|
| Height | sm 32 / md 36 / lg 44 px |
| Padding | h: 12 / 16 / 16 px |
| Radius | `--radius-md` (6px) |
| Border | 1px `--color-border` |
| Font size | 15px (avoid 14 — too small) |
| Label | Above input, 13px, weight 500 |
| Helper text | Below, 12–13px, `--color-muted` |
| Focus border | `--color-ring`, 2px |
| Focus ring | Either border thickening OR outline — not both |

### Label position

Always **above** the input. Never:
- Floating labels (accessibility issues, hard to read in dense forms)
- Labels inside the input (lost on focus)
- Right-aligned labels (mixed-language support breaks)

### Validation

- **Inline**: on blur, not on every keystroke. Live validation as the user types is
  hostile.
- **Success**: subtle border tint to `--color-success`, no icon (avoid clutter).
- **Error**: border `--color-error`, icon (`<Warning />`) + message below replacing
  helper text. Message uses `aria-describedby` on the input.

### States

```
default | hover (border-strong) | focus (ring) | filled | error | success | disabled
```

### Required

Marker is asterisk after label, color `--color-error`:
```tsx
<Label>Email <span className="text-error" aria-hidden>*</span></Label>
```
And `aria-required="true"` on the input.

### `autocomplete` is mandatory

Every field gets the correct `autocomplete` attribute (`email`, `current-password`,
`new-password`, `street-address`, `tel`, etc.) plus correct `inputmode` and `type`.
This is for autofill, password managers, and accessibility — not optional.

### Hard limits

- ❌ Never use `placeholder` as the label.
- ❌ Never disable autocomplete for legit form fields.
- ❌ Never use `<div contentEditable>` as a faux input.
- ❌ Never put password input in a non-`type="password"` element.

---

## Textarea

Same spec as Input except:
- `min-height: 80px`
- `resize: vertical` (or `none` if size matters for layout)
- Optional character counter in lower right, only if max length is enforced
- Helper text describes constraint: "Max 500 characters" or "Markdown supported"

---

## Select / Combobox

```tsx
<Select label="Country" placeholder="Choose…">
  <Select.Option value="us">United States</Select.Option>
  <Select.Option value="sg">Singapore</Select.Option>
</Select>
```

Native `<select>` on mobile (uses system picker). Custom popover-based combobox on
desktop only when search/filter is required.

| Property | Default |
|---|---|
| Trigger height | matches Input |
| Trigger style | identical to Input + chevron right icon |
| Menu max height | 320px with scroll |
| Menu item height | 36px |
| Search input | sticky top, focused on open if combobox |
| Empty state | "No matches" with secondary text "Try a different search" |

Rules:
- Use Radix Select for native-feeling combobox on desktop.
- For >10 options with search, use Combobox (cmdk).
- Keyboard: arrow keys navigate, Enter selects, Esc closes, type-to-search filters.
- Selected option marked with checkmark, not by color alone.

---

## Checkbox / Radio / Switch

### Checkbox

| Property | Default |
|---|---|
| Size | sm 16 / md 20 / lg 24 px square |
| Border radius | 4px (rounded square, not pill) |
| Border | 1.5px `--color-border-strong` |
| Checked bg | `--color-accent` |
| Check icon | white, 1.5px stroke |
| Label gap | 8px |
| Hover | border `--color-fg`, subtle bg lift |
| Focus | 2px ring offset |

### Radio

Same as checkbox but:
- Always pill (full radius)
- Inner dot, not checkmark, when selected
- Radios in a group share `name` attribute

### Switch (toggle)

| Property | Default |
|---|---|
| Track height | 24px |
| Track width | 44px |
| Thumb diameter | 20px (1px inset from track) |
| Off bg | `--color-border` |
| On bg | `--color-accent` |
| Thumb transition | `transform var(--duration-fast) var(--ease-out)` |
| Label position | Right of switch (left in RTL) |

Rules:
- Switch = instant effect ("on/off"). Checkbox = pending choice that requires submit.
- Don't use switch for "I agree to terms" — that's a checkbox.
- Always show on/off labels in the description, not just visually.

---

## Card

```tsx
<Card>
  <CardHeader>
    <CardTitle>Project Apollo</CardTitle>
    <CardDescription>Last updated 3 hours ago</CardDescription>
  </CardHeader>
  <CardBody>…</CardBody>
  <CardFooter>
    <Button variant="primary">Open</Button>
  </CardFooter>
</Card>
```

| Property | Default |
|---|---|
| Padding | 24px (sm 16 / md 24 / lg 32) |
| Radius | `--radius-lg` (8px) |
| Background | `--color-surface` |
| Border | 1px `--color-border` OR no border + slight shadow — never both |
| Internal gap | 16px between header/body/footer |

### When to use Card

- Grouped, parallel content (e.g., a grid of products, projects, people).
- Self-contained information that benefits from a bounded container.
- Content that's interactive as a whole (clickable card → linked detail page).

### When NOT to use Card

- Single section of a page (use background contrast or section padding).
- Form fields (they live in form sections, not cards each).
- List rows (use a list with dividers).
- Marketing sections (use full-bleed sections with their own backgrounds).
- Tabular data (use a table).

### Hover (only if clickable)

Subtle: `translateY(-2px)` + `--shadow-pop` OR border color shift to `--color-border-strong`.
Duration 150ms. Never `scale(1.05)`.

### Hard limits

- ❌ No `rounded-2xl shadow-2xl` combo.
- ❌ No card-everything (anti-slop rule #6).
- ❌ No nested cards (card inside card). Use background contrast or dividers instead.

---

## Modal / Dialog

### Desktop

```tsx
<Dialog>
  <DialogTrigger asChild><Button>Open</Button></DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Delete project</DialogTitle>
      <DialogDescription>This action cannot be undone.</DialogDescription>
    </DialogHeader>
    <DialogBody>…</DialogBody>
    <DialogFooter>
      <Button variant="tertiary">Cancel</Button>
      <Button variant="destructive">Delete project</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

| Property | Default |
|---|---|
| Max width | 480px (sm) / 640px (md) / 800px (lg) |
| Padding | 24px or 32px |
| Radius | `--radius-xl` (12px) |
| Background | `--color-bg` (full opacity, not blurred glass) |
| Shadow | `--shadow-modal` |
| Backdrop | `oklch(20% 0.04 265 / 0.5)` (50% near-black) |
| Backdrop blur | Optional 4–8px on supported browsers |
| Z-index | `--z-modal` |
| Enter animation | opacity 0→1 + scale 0.95→1, 200ms `--ease-out` |
| Exit animation | reverse, 150ms `--ease-in` |

### Mobile

Use a **bottom sheet** (Vaul library), not a centered dialog. Centered dialogs on
mobile are anti-slop rule #21.

### Focus management

- Focus traps inside the modal.
- Esc closes (with optional confirmation if destructive).
- Body scroll locks while open.
- Initial focus on the first interactive element OR the title heading (for screen
  readers).
- On close, focus returns to the trigger.

### Action ordering

- Primary action **right**, cancel **left** on Mac/iOS/web standard.
- Destructive action gets the destructive variant.
- Cancel uses tertiary/ghost variant — never matching primary visual weight.
- Three actions max in footer. More = it's a form, not a modal.

### Hard limits

- ❌ Never auto-close on outside click for destructive operations.
- ❌ Never make Cancel button equal-weight to primary.
- ❌ Never put forms longer than 6 fields in a modal — use a full page or panel.
- ❌ Never nest modals (modal that opens another modal). Use steps or a wizard instead.

---

## Sheet (Drawer)

Slides in from edge. Common for mobile bottom sheets, desktop side panels.

### Side sheet (desktop)

```tsx
<Sheet side="right">
  <SheetContent className="w-[480px]">
    <SheetHeader>
      <SheetTitle>Project settings</SheetTitle>
    </SheetHeader>
    …
  </SheetContent>
</Sheet>
```

| Side | Width / Height | Use |
|---|---|---|
| right | 400–600px | Detail panels, settings, filters |
| left | 280–320px | Navigation drawer (mobile fallback) |
| top | auto | Notifications, search |
| bottom | auto / detents | Mobile sheets (use Vaul) |

### Bottom sheet (mobile, Vaul)

```tsx
<Drawer>
  <DrawerTrigger>Open</DrawerTrigger>
  <DrawerContent>
    <DrawerHeader>
      <DrawerHandle />
      <DrawerTitle>Filters</DrawerTitle>
    </DrawerHeader>
    …
  </DrawerContent>
</Drawer>
```

Detents: `medium` (50%) and `large` (90%) by default. `dismissible` if user can
swipe down to close. Drag handle visible at top by default.

---

## Popover

Smaller than a modal, attached to a trigger. No backdrop.

```tsx
<Popover>
  <PopoverTrigger asChild><Button>Filter</Button></PopoverTrigger>
  <PopoverContent>
    <Filters />
  </PopoverContent>
</Popover>
```

| Property | Default |
|---|---|
| Max width | 320–400px |
| Padding | 16px |
| Radius | `--radius-lg` (8px) |
| Shadow | `--shadow-overlay` |
| Offset from trigger | 8px |
| Arrow | optional, off by default |

Rules:
- Click outside closes.
- Esc closes and returns focus to trigger.
- Don't trigger on hover (use Tooltip instead).
- Don't nest popovers.

---

## Tooltip

```tsx
<Tooltip content="Save changes (⌘S)">
  <IconButton aria-label="Save"><Floppy /></IconButton>
</Tooltip>
```

| Property | Default |
|---|---|
| Background | `--color-fg` (dark on light theme, inverted) |
| Foreground | `--color-bg` |
| Padding | 6px 10px |
| Font size | 12px |
| Radius | 6px |
| Delay open | 300ms |
| Delay close | 0ms |
| Arrow | 4px, optional |

Rules:
- Only on hover-capable devices (`@media (hover: hover)`). On touch, replace with
  long-press or move info to label.
- Never the only way to access information.
- Keyboard focus also triggers tooltip (a11y).
- Include keyboard shortcut in the tooltip when applicable: "Save (⌘S)".

---

## Toast (Sonner)

Use Sonner by Emil Kowalski. Default stack location: bottom-right on desktop,
bottom-center on mobile. Auto-dismiss 4 seconds. Swipe to dismiss.

```tsx
toast.success("Project saved");
toast.error("Failed to save", { description: "Check your connection" });
toast.promise(savePromise, {
  loading: "Saving…",
  success: "Saved",
  error: "Failed to save",
});
```

| Property | Default |
|---|---|
| Width | 360px |
| Padding | 16px |
| Radius | `--radius-lg` |
| Background | `--color-bg` + `--shadow-overlay` |
| Border | 1px `--color-border` |
| Icon | size 16px, semantic color |
| Stacking | max 3 visible, rest queue |
| Auto-dismiss | 4000ms (5000ms for action toasts) |

### Variants

- `success` — green checkmark icon, soft green left border.
- `error` — red icon, soft red left border, no auto-dismiss for critical.
- `warning` — yellow icon.
- `info` — blue icon.
- `loading` — spinner icon, no auto-dismiss until resolved.

### Action toast

Include "Undo" button for reversible operations.
```tsx
toast.success("Project deleted", {
  action: { label: "Undo", onClick: () => undelete() }
});
```

Rules:
- Never use toast for critical errors that require user attention — use inline error
  in the form or modal.
- Never stack >3 toasts. Coalesce repeated toasts with a count: "3 items saved".
- Don't auto-show toasts on page load.

---

## Table

```tsx
<Table>
  <TableHeader>
    <TableRow>
      <TableHead>Name</TableHead>
      <TableHead>Status</TableHead>
      <TableHead className="text-right">Revenue</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    {rows.map(row => (
      <TableRow key={row.id}>
        <TableCell>{row.name}</TableCell>
        <TableCell><Badge>{row.status}</Badge></TableCell>
        <TableCell className="text-right tabular-nums">${row.revenue}</TableCell>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

| Property | Default |
|---|---|
| Row height (comfortable) | 48px |
| Row height (dense) | 36px |
| Header row | 40–44px, font weight 500, color `--color-muted` |
| Column padding | 12–16px horizontal |
| Border | 1px `--color-border` bottom of each row, no vertical borders |
| Header sticky | `position: sticky; top: 0; z-index: --z-sticky` |
| Header background | `--color-bg` (solid, never transparent) |
| Hover row | `bg-surface` lift |
| Selection | checkbox column on left, header has master checkbox |

### Column alignment

- **Text**: left-align.
- **Numbers**: right-align with `tabular-nums` (`font-variant-numeric: tabular-nums`).
- **Status**: center-align in column, badge centered.
- **Dates**: left-align (or right-align if rightmost column).
- **Actions** (icon buttons): right-align in last column.

### Sort indicators

Only the active sort column shows a strong arrow. Other sortable columns show a
subtle dual chevron on hover. Click cycles asc → desc → unset.

### Pagination

Reference data (logs, transactions, issues) uses page numbers: "Showing 21–40 of 1,247".
Feeds use infinite scroll. Never mix.

### Expandable rows

Chevron in first column, click row to expand. Expanded content slides down with
`grid-template-rows: 0fr → 1fr` (the modern Tailwind v4 way, no JS).

### Hard limits

- ❌ No alternating row backgrounds (out of fashion in 2026).
- ❌ No vertical borders between columns.
- ❌ No `<div>`-based fake tables. Use `<table>` for tabular data — a11y, screen
  reader navigation, sortable.
- ❌ No charts inside table cells unless the column is dedicated to a sparkline (then
  spec it tightly: 60×24px, single color).

---

## List

```tsx
<List>
  <ListItem>
    <Avatar src={user.avatar} />
    <ListItemContent>
      <ListItemTitle>{user.name}</ListItemTitle>
      <ListItemDescription>{user.role}</ListItemDescription>
    </ListItemContent>
    <ListItemActions>
      <Button variant="ghost">Edit</Button>
    </ListItemActions>
  </ListItem>
</List>
```

| Property | Default (web) |
|---|---|
| Row height (1 line) | 48px |
| Row height (2 lines) | 64px |
| Row height (3 lines) | 88px |
| Padding | 16px horizontal |
| Divider | 1px bottom border, `--color-border` |
| Hover | `bg-surface` |
| Click target | entire row |

### Material 3 list item sizes (mobile pack)

Per M3 spec: 1-line 48dp (no avatar) / 56dp (with avatar), 2-line 64dp / 72dp,
3-line 88dp. Always 16dp horizontal padding.

### iOS list (Settings-style)

Inset grouped: cards with 16pt padding around groups, 12pt radius. Plain: full-width
rows with separators inset 16pt from left.

### Rules

- Use list, not card grid, for sequential/sortable data.
- Don't combine list with cards (each row in a card = anti-slop rule #6 violation).
- Action menu on right uses IconButton with kebab/dots icon.
- Empty state inside the list container, not above.

---

## Badge

```tsx
<Badge variant="success">Active</Badge>
<Badge variant="muted">Draft</Badge>
```

| Property | Default |
|---|---|
| Height | 20–24px |
| Padding | 8–12px horizontal |
| Radius | `--radius-pill` |
| Font size | 11–13px |
| Font weight | 500 |
| Letter spacing | `--tracking-caption` (slight positive) |
| Background | semantic-soft (e.g., `--color-success-soft`) |
| Foreground | semantic strong (e.g., `--color-success`) |

### Variants

- `default` — neutral, `bg-surface-2 text-fg`
- `muted` — `bg-surface-2 text-muted`
- `outline` — transparent bg, border-strong
- `success` — `bg-success-soft text-success`
- `warning` — `bg-warning-soft text-warning`
- `error` — `bg-error-soft text-error`
- `info` — `bg-info-soft text-info`
- `accent` — `bg-accent-soft text-accent` (sparingly)

### Hard limits

- ❌ No solid `bg-green-500` badges. Use the soft+strong pattern.
- ❌ No badges with shadow.
- ❌ No badges that contain interactive elements (use Chip if you need close/dismiss).

---

## Avatar

```tsx
<Avatar src={user.avatar} alt={user.name} size="md" />
```

| Size | Diameter |
|---|---|
| xs | 20px |
| sm | 28px |
| md | 36px |
| lg | 44px |
| xl | 64px |
| 2xl | 96px |

| Property | Default |
|---|---|
| Shape | circle |
| Border | 1px white/bg on stacked avatars only |
| Fallback | initials over `--color-accent-soft` |
| Image loading | lazy, blur-up if next/image |

Stacked avatars (overlapping for groups): each subsequent avatar shifts left by 30%
of its diameter, white border 2px to separate. Max 4 visible + "+N" badge.

---

## Tabs

```tsx
<Tabs defaultValue="overview">
  <TabsList>
    <TabsTrigger value="overview">Overview</TabsTrigger>
    <TabsTrigger value="usage">Usage</TabsTrigger>
    <TabsTrigger value="settings">Settings</TabsTrigger>
  </TabsList>
  <TabsContent value="overview">…</TabsContent>
</Tabs>
```

### Variants

- **Underlined** (default for app): trigger has bottom border on active, no
  background change.
- **Pill** (filter UI): pill-shaped triggers, active = `bg-surface-2 text-fg`,
  inactive = `text-muted`.
- **Boxed** (rare, for settings groups): card-like containers.

### Spec

| Property | Default |
|---|---|
| Trigger height | 40px |
| Trigger padding | 12px horizontal |
| Underline thickness | 2px |
| Underline color | `--color-accent` |
| Active text | `--color-fg`, weight 500 |
| Inactive text | `--color-muted`, weight 400 |

Rules:
- Max 7 tabs visible. If more, use sidebar nav or a dropdown.
- Tabs stay in URL via search params (`?tab=usage`) for shareable links.
- Keyboard: arrow keys navigate, Enter/Space activates.

---

## Breadcrumb

```tsx
<Breadcrumb>
  <BreadcrumbItem href="/">Home</BreadcrumbItem>
  <BreadcrumbSeparator />
  <BreadcrumbItem href="/projects">Projects</BreadcrumbItem>
  <BreadcrumbSeparator />
  <BreadcrumbItem current>Apollo</BreadcrumbItem>
</Breadcrumb>
```

| Property | Default |
|---|---|
| Font size | 13–14px |
| Color | `--color-muted` (links), `--color-fg` (current) |
| Separator | `/` or `<ChevronRight />`, color `--color-subtle` |
| Hover on links | underline |

Rules:
- Use only when nav depth ≥3 levels.
- Truncate middle items with ellipsis when too long; first and last always visible.
- Current page is not a link (no `href`).

---

## Pagination

```tsx
<Pagination>
  <PaginationButton variant="ghost"><ChevronLeft /></PaginationButton>
  <PaginationItem>1</PaginationItem>
  <PaginationItem active>2</PaginationItem>
  <PaginationItem>3</PaginationItem>
  <PaginationEllipsis />
  <PaginationItem>27</PaginationItem>
  <PaginationButton variant="ghost"><ChevronRight /></PaginationButton>
</Pagination>
```

| Property | Default |
|---|---|
| Item size | 36px square |
| Active background | `--color-fg`, text `--color-bg` |
| Hover | `bg-surface-2` |
| Ellipsis | three dots, no background |
| Page info text | "Showing 21–40 of 1,247" — `--color-muted`, 13px |

Rules:
- Show first, current ±2, and last page numbers.
- Disable prev/next at boundaries (don't hide them).
- Pagination is for referenceable data; feeds use infinite scroll.
- Update URL `?page=2` for shareable state.

---

## Empty State

```tsx
<EmptyState>
  <EmptyStateIcon><FolderOpen /></EmptyStateIcon>
  <EmptyStateTitle>Track customer issues here</EmptyStateTitle>
  <EmptyStateDescription>
    Once you create your first issue, it'll show up in this list with status,
    assignee, and last update.
  </EmptyStateDescription>
  <EmptyStateActions>
    <Button variant="primary">Create your first issue</Button>
  </EmptyStateActions>
</EmptyState>
```

| Property | Default |
|---|---|
| Vertical padding | 48–80px |
| Icon size | 48–64px, `--color-subtle` |
| Title size | 20px, weight 500 |
| Description | 15px, `--color-muted`, max-width 480px, centered |
| Action | single primary button |

Rules per anti-slop rule #22:
- Title names the **screen's purpose**, not the absence ("Track customer issues here"
  not "No data yet").
- Description explains **what the screen will become** when populated.
- One concrete primary action ("Create your first issue", not "Get started").
- Optional ghost preview of populated state below the empty state (1–2 fake rows at
  20% opacity).
- No 3D illustrations, no mascot characters.

---

## Skeleton

Loading placeholder that matches the final layout's shape.

```tsx
<Skeleton className="h-4 w-32" />
<Skeleton className="h-10 w-full" />
```

| Property | Default |
|---|---|
| Background | `--color-surface-2` |
| Radius | matches the element it replaces |
| Animation | subtle pulse, `opacity: 0.5 ↔ 1` over 1.5s |
| Reduced motion | static at 0.7 opacity |

Rules:
- Skeleton matches the layout of the loaded state. Don't use a generic gray block
  if the loaded state is a list — show list-shaped skeletons.
- Replace skeleton with content using a 100–150ms cross-fade.
- Skeleton for predictable load (≥300ms wait, known shape). Spinner only for
  unpredictable load.
- Never show skeleton + spinner simultaneously.

---

## Spinner

```tsx
<Spinner size="md" />
```

| Size | Diameter | Stroke |
|---|---|---|
| xs | 12px | 1.5px |
| sm | 16px | 1.5px |
| md | 20px | 2px |
| lg | 32px | 2.5px |
| xl | 48px | 3px |

Animation: rotate 360° over 800ms linear. Use SVG with `stroke-dasharray` for the
arc shape (not a full circle — modern spinners are a 270° arc).

Rules:
- Use for unknown-duration tasks <2s.
- For >2s, switch to progress bar with explanation ("Uploading 3 of 12 files…").
- Color: `currentColor` so it inherits text color of the parent.
- Center the spinner in its container; don't add layout shift.

---

## Component Composition Patterns

### Form section

```tsx
<form className="grid gap-6">
  <Input label="Name" required />
  <Input label="Email" type="email" required />
  <Textarea label="Bio" helperText="Markdown supported" />
  <div className="flex justify-end gap-3">
    <Button variant="tertiary">Cancel</Button>
    <Button type="submit" variant="primary">Save</Button>
  </div>
</form>
```

- Gap 24px between fields (16px in dense forms).
- Action buttons right-aligned, gap 12px between.
- Primary action submits the form (handles Enter).

### Hero (corporate, non-slop)

```tsx
<section className="container py-24">
  <div className="max-w-3xl">
    <h1 className="text-display font-medium tracking-display leading-display">
      Track customer issues
      <br />
      <span className="text-muted">without the spreadsheet.</span>
    </h1>
    <p className="mt-6 text-lg text-muted max-w-prose">
      One inbox for support emails, in-product feedback, and Slack mentions.
      Triage, assign, and ship fixes from the same place your engineers live.
    </p>
    <div className="mt-10">
      <Button size="lg" variant="primary">Start a free trial</Button>
    </div>
  </div>
</section>
```

Note: single CTA, asymmetric layout, concrete copy. No generic gradient bg, no
center-stacking.

### Dashboard KPI strip

```tsx
<section className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
  {kpis.map(kpi => (
    <Card key={kpi.id} className="p-5">
      <p className="text-sm text-muted">{kpi.label}</p>
      <p className="mt-2 text-2xl font-medium tabular-nums">{kpi.value}</p>
      <div className="mt-3 flex items-center gap-2">
        <TrendIndicator value={kpi.delta} />
        <Sparkline data={kpi.history} className="ml-auto" />
      </div>
    </Card>
  ))}
</section>
```

Each KPI: label, value (tabular-nums), trend + sparkline. No isolated stat cards
with giant icons.
