# Motion

Motion either elevates a UI or destroys it. The default position is **less, slower,
and only where meaning changes**. This file codifies Rauno Freiberg's interaction
principles and Emil Kowalski's animation rules into actionable defaults.

---

## The First Principle

**Animation signals change.** If nothing has changed (state, location, focus, value),
nothing should animate. Decorative motion is noise.

The corollary: **frequency kills delight.** Anything triggered hundreds of times a
day should be instant. Anything triggered once or twice a session can afford
personality.

---

## Emil Kowalski's Rules

Emil Kowalski (currently Linear web team; previously Vercel; built Sonner and Vaul;
runs animations.dev) wrote the most-cited essay on UI animation: emilkowal.ski/ui/great-animations.

### Rule 1 — Never animate keyboard-initiated actions

Raycast has **no open animation**. Why? Users open it hundreds of times per day.
Any animation, no matter how snappy, becomes friction at that frequency.

Apply this to:
- Command palette (Cmd+K)
- Esc to close anything
- Cmd+/ for shortcuts panel
- Cmd+Enter to submit
- Tab through fields
- Arrow key navigation

These should appear/dismiss/transition **instantly** (`--duration-instant: 0ms`).

### Rule 2 — Animate only `transform` and `opacity`

These are GPU-accelerated. The browser composites them on a separate layer without
triggering layout or paint.

Banned (cause layout/paint):
- `width`, `height`, `padding`, `margin`
- `top`, `left`, `right`, `bottom`
- `font-size`
- `border-width`

If you need to animate size, use `transform: scale()` and reset on completion. If
you need to animate position, use `transform: translate()`.

Exception: `background-color` is paint-only (no layout) and is fine to animate at
low frequency.

### Rule 3 — CSS for predetermined animations, JS for interruptible ones

```css
/* Predetermined: button hover. CSS. */
button {
  transition: background-color 100ms ease;
}

/* Predetermined: modal enter. CSS. */
.modal[data-state="open"] {
  animation: scale-in 200ms cubic-bezier(0.16, 1, 0.3, 1);
}
```

```tsx
// Interruptible: drag-to-dismiss sheet. JS (Framer Motion / Motion One).
<motion.div
  drag="y"
  dragConstraints={{ top: 0 }}
  animate={{ y: isOpen ? 0 : "100%" }}
/>
```

CSS animations run off the main thread → smoother under JS load. JS animations are
necessary only when the user can interrupt (gestures, scroll-driven, spring physics).

### Rule 4 — Modal + overlay share duration and easing

If the modal animates over 200ms with `ease-out`, the overlay (backdrop scrim) must
also animate 200ms with `ease-out`. Elements that move together must *feel* together.

```css
[data-radix-dialog-overlay],
[data-radix-dialog-content] {
  animation-duration: 200ms;
  animation-timing-function: cubic-bezier(0.16, 1, 0.3, 1);
}
```

### Rule 5 — Springs feel natural because they don't have fixed durations

A spring animation's duration depends on its physics (mass, stiffness, damping). The
animation ends when the simulation settles, not when a clock hits zero.

This makes spring motion feel "alive" in a way fixed-duration easing can't. Use
springs for:
- Drag interactions (release → settle back)
- Playful UI moments (sticker reactions, like buttons)
- Anywhere physics is the metaphor (a sheet falling away)

Don't use springs for:
- Anything that needs to complete in a known time (forms, error messages)
- Anything that interrupts every animation in flight
- Critical-path actions where unpredictable timing breaks flow

---

## Rauno Freiberg's Principles

Rauno Freiberg (Staff Design Engineer at Vercel; author of "Invisible Details of
Interaction Design"; built `cmdk`, the command palette library with 38M+ weekly
npm downloads).

### Robustness beats novelty

> "If your UI only works 80% of the time, the perception of quality breaks."

Test under stress:
- Fast scroll
- Low battery / reduced animation
- Slow network (transitions during data load)
- Rapid clicks / double-tap
- Tab away and back during an animation
- Reduced motion preference

If a transition glitches in any of these scenarios, it's worse than no transition.

### Disney's "Follow-Through and Overlapping Action"

Disney's classic principle of animation: secondary elements lag behind primary ones.
The hand lands; the arm continues for a moment.

In UI:
- A modal opens; its contents fade in 100ms after the modal frame.
- A list expands; items appear staggered, not simultaneously.
- A header slides in; the underline animates after.

```css
.modal-content { animation-delay: 100ms; }
.list-item { animation-delay: calc(var(--index) * 30ms); }
```

Use sparingly. Stagger >5 items becomes annoying.

### Build in code, not Figma

The material reveals truth. A spring animation in Figma is a smooth easing line.
A spring animation in React with Framer Motion has real physics and reacts to user
input.

Prototype in code from the start. The friction of switching modes (Figma → code)
is greater than the friction of working in code with a hot-reload dev server.

### Validate by exaggeration

Build the animation 10× too strong, then dial back. If the goal is a subtle 4px
translateY hover, first try translateY(-20px). Now you know what's too much.
The right amount is between the original guess and the exaggeration.

---

## Easing Curves — When to Use Each

```css
--ease-linear: linear;
--ease-out: cubic-bezier(0.16, 1, 0.3, 1);
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-fluid: cubic-bezier(0.3, 0, 0, 1);
--ease-snappy: cubic-bezier(0.2, 0, 0, 1);
--ease-emphasized: cubic-bezier(0.2, 0, 0, 1);
--ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
--ease-anticipate: cubic-bezier(0.36, 0, 0.66, -0.56);
```

| Curve | Shape | Use |
|---|---|---|
| `linear` | constant | Loaders, progress bars, color shifts |
| `ease-out` | fast → slow | **Default for enter animations** (element arrives and settles) |
| `ease-in` | slow → fast | Exit animations (element accelerates away) |
| `ease-fluid` | symmetric | Bidirectional toggles (collapse/expand) |
| `ease-snappy` | fast deceleration | Quick UI feedback (button press release) |
| `ease-emphasized` | Material 3 default | Important state changes on Android |
| `ease-spring` | overshoots, settles | Playful interactions (like button, drag release) |
| `ease-anticipate` | pulls back, then forward | Rare; comedic timing |

### iOS system curves (SwiftUI)

```swift
.animation(.smooth, value: state)        // default smooth ease
.animation(.snappy, value: state)        // fast feedback
.animation(.bouncy, value: state)        // playful spring
.animation(.spring(response: 0.5, dampingFraction: 0.825), value: state)
```

### Material 3 motion tokens

```kotlin
MotionTokens.EasingStandardCubicBezier        // cubic-bezier(0.2, 0, 0, 1)
MotionTokens.EasingEmphasizedCubicBezier      // cubic-bezier(0.2, 0, 0, 1)
MotionTokens.EasingEmphasizedDecelerateCubicBezier  // for incoming elements
MotionTokens.EasingEmphasizedAccelerateCubicBezier  // for outgoing
```

M3 Expressive (2025) replaced fixed durations with **spring tokens** as the default
for important transitions. Stiffer springs for fast UI feedback, looser for celebratory
moments.

---

## Duration Bands

```css
--duration-instant: 0ms;
--duration-fast: 100ms;
--duration-normal: 200ms;
--duration-slow: 300ms;
--duration-marketing: 400ms;
```

### When to use each

**0ms (instant)** — Anything triggered >50× per session.
- Cmd+K opens
- Esc closes
- Frequently-used menus
- Keyboard arrow navigation

**100ms (fast)** — Hover and color changes.
- Button hover background
- Link underline
- Border color shift on focus
- Icon color change

**200ms (normal)** — Enter/exit and transforms.
- Modal/dialog enter
- Sheet/drawer slide in
- Dropdown open
- Tooltip appear (after 300ms delay)
- Toast appear

**300ms (slow)** — Marketing-adjacent and important state changes.
- Page transitions (when used)
- Hero element reveals on scroll
- Optimistic state confirmation

**400ms (marketing)** — Hero reveals, parallax, scroll-driven type animation.
- Reserved for marketing site moments. Never in product UI.

### What "feels right" is shorter than you think

Default human perception of UI motion:
- <100ms feels instantaneous
- 100–300ms feels responsive
- 300–500ms feels deliberate
- >500ms feels slow / cinematic

When in doubt, **shorten**.

---

## Specific Component Motion

### Button hover

```css
button {
  transition: background-color 100ms cubic-bezier(0.3, 0, 0, 1);
}
button:active {
  transform: scale(0.98);
  transition: transform 80ms ease-out;
}
```

### Modal / Dialog enter

```css
@keyframes scale-in {
  from { opacity: 0; transform: scale(0.95); }
  to   { opacity: 1; transform: scale(1); }
}
.modal {
  animation: scale-in 200ms cubic-bezier(0.16, 1, 0.3, 1);
}
```

### Bottom sheet slide

```css
@keyframes slide-up {
  from { transform: translateY(100%); }
  to   { transform: translateY(0); }
}
.sheet {
  animation: slide-up 250ms cubic-bezier(0.16, 1, 0.3, 1);
}
```

For draggable sheets (Vaul), use spring physics in JS, not CSS easing.

### Toast appear

```css
@keyframes toast-in {
  from { opacity: 0; transform: translateY(20px) scale(0.95); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}
.toast {
  animation: toast-in 200ms cubic-bezier(0.16, 1, 0.3, 1);
}
```

### Tooltip

Delay open: 300ms. Delay close: 0ms (closes instantly to feel responsive).

```tsx
<TooltipProvider delayDuration={300} skipDelayDuration={100}>
```

### Dropdown / Popover

200ms enter, `ease-out`. No exit animation if the user clicks outside (instant
dismiss). 100ms exit if Esc-triggered.

### List reorder (FLIP)

When a list reorders, animate items to their new positions using the FLIP technique:
**F**irst, **L**ast, **I**nvert, **P**lay.

```tsx
import { motion } from "framer-motion";

<motion.div layout transition={{ duration: 0.2 }}>
  {items.map(item => (
    <motion.div key={item.id} layout>{item.text}</motion.div>
  ))}
</motion.div>
```

### State change (idle → loading → success)

Smooth crossfade:
```css
.state-transition {
  transition: opacity 150ms cubic-bezier(0.3, 0, 0, 1);
}
```

When the spinner replaces the label in a button, the button width doesn't change
(fixed min-width). The label opacity fades to 0 as spinner opacity fades to 1.

---

## Page Transitions

**App pages: instant.** Don't animate route changes in a product. Users want to be
*at* the new page, not watch it arrive. The exception is a defined wizard flow with
explicit "next step" semantics.

**Marketing pages: optional, subtle.** Fade-in over 200–300ms is the maximum. Slide-
in transitions are heavy and dated.

### Next.js App Router with View Transitions API

```tsx
// app/layout.tsx
<html style={{ viewTransitionName: "root" }}>
```

```css
::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 250ms;
}
```

Use sparingly. The default no-animation is correct for 90% of routes.

---

## Scroll-Driven Animation

Modern browsers support `animation-timeline: scroll()` and `animation-timeline: view()`.
Use these for marketing reveals.

```css
@keyframes fade-up {
  from { opacity: 0; transform: translateY(40px); }
  to   { opacity: 1; transform: translateY(0); }
}

.scroll-reveal {
  animation: fade-up linear;
  animation-timeline: view();
  animation-range: entry 10% cover 30%;
}
```

Rules:
- Trigger only once per scroll into view (don't replay on scroll up).
- Reveals only on marketing pages, never in product UI.
- Provide reduced-motion fallback (just appear, no animation).
- Don't reveal the entire page chunk-by-chunk — pick 2–3 hero moments.

---

## Reduced Motion

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

Don't disable everything. Keep:
- Opacity transitions (≤100ms) — needed for state change clarity.
- Background color transitions — needed for hover feedback.

Disable:
- All `transform` animations.
- Scroll-driven reveals.
- Parallax.
- Auto-playing video / GIF backgrounds.
- Spring physics.

### Test it

Toggle macOS System Settings → Accessibility → Display → Reduce Motion. The UI
should still be perfectly usable, just stiller. If it feels broken without motion,
the motion was hiding bad design.

---

## Anti-Patterns

### Don't animate frequently-triggered actions
- Dropdown menu open on a primary nav button (clicked 30× a session) → instant.
- Filter pill toggle (clicked 50× a session) → instant.
- "Mark as read" toast (appears 100× a session) → instant or very short (≤100ms).

### Don't stagger >5 items
Stagger is delightful at 2–4 items. At 6+, it feels like waiting. List items should
animate together (or use FLIP for individual position changes).

### Don't use spring physics for forms
Form submission feedback should complete in known time. A bouncy success message
that overshoots makes users second-guess whether the action worked. Use ease-out.

### Don't auto-animate on enter
The single most-overused effect in 2020s web design: every section fades + slides in
as the user scrolls past. By 2025, this signals "template" or "AI-generated."

Pick **one** hero moment per marketing page that earns a reveal. Everything else is static.

### Don't animate scroll-jacking
Forced scroll snapping, scroll-hijacked horizontal sections, "story mode" navigation
that traps the user — all hostile. Let scroll be scroll.

### Don't combine multiple motion types

```css
/* Wrong: opacity + scale + translate + rotate */
.bad {
  animation: opacity-in 200ms, scale-in 200ms, slide-up 200ms, rotate-in 200ms;
}
```

Two properties max in any single animation. Three when one is opacity for
crossfading.

---

## Library Recommendations

| Library | When to use |
|---|---|
| **CSS** (built-in) | 80% of animations. Default. |
| **Framer Motion** (now "Motion") | Drag, gesture, layout animations, complex orchestration |
| **Motion One** | Lightweight web alternative to Framer Motion |
| **Vaul** (Emil Kowalski) | Mobile bottom sheets with drag-to-dismiss |
| **Sonner** (Emil Kowalski) | Toasts |
| **cmdk** (Paco Coursey / Rauno Freiberg) | Command palette |
| **AutoAnimate** (FormKit) | Drop-in list animations (FLIP) without setup |
| **GSAP** | Complex marketing storytelling, scroll-driven cinema |
| **View Transitions API** | Native page transitions, modern browsers |

For Grain's default stack: CSS + Framer Motion + Vaul + Sonner + cmdk.

---

## The Self-Check Before Adding Any Animation

Ask:
1. **Does something change?** If no, no animation.
2. **How often is this triggered?** >50/session = instant.
3. **Is the user waiting for an outcome?** Then shorten or remove.
4. **Does it work under reduced-motion?** Test it.
5. **Does it work at 60fps on a 4-year-old phone?** If you can't verify, simplify.
6. **Is it `transform` and/or `opacity` only?** If not, refactor.
7. **Would Rauno or Emil ship this?** If you can't argue yes with a straight face,
   simplify.

If three or more of these fail, remove the animation entirely. No motion beats bad motion.
