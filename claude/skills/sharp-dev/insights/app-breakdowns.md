# App Breakdowns — What Billion-Dollar Apps Teach

5 Apple apps dissected for extractable design principles.
Use these when the user asks "how should I design X?" — find the closest match.

---

## Health — Data as Emotion

**Category:** Dashboard · Health · Wellness
**Core insight:** Three activity rings are the entire visual language. Apple solved the
"health dashboard" problem by making data feel alive — the rings animate, close, and
have urgency. One visual metaphor, owned completely.

**Spacing lesson:**
The summary screen has more whitespace than content. Hero numbers are 48–72px.
Everything else defers. This is confidence, not emptiness.

**Color lesson:**
Move ring = red. Exercise ring = green. Stand ring = blue.
Three semantically meaningful colors, never decorative. Each ring has one job.
This is Grain's semantic color rule in production.

**Typography lesson:**
The big number (e.g. 412 cal) is 48px weight 300. The label is 10px uppercase tertiary.
The gap between them IS the hierarchy. No intermediate sizes needed.

**Steal this:**
Find your one visual metaphor and own it completely. What is your "activity ring"?
Build the entire product around that metaphor — not around feature parity with competitors.

---

## Wallet — Trust Through Restraint

**Category:** Finance · Payments · High-stakes transactions
**Core insight:** Almost no color. Pure black background. White typography only.
No illustrations, gradients, or shadows. The most visually stripped app Apple ships.

**Why it works:**
When stakes are high (money, health, legal, security), visual restraint signals
seriousness. Complexity creates doubt. Minimalism creates confidence.
The Wallet app says: we don't need to impress you, we need you to trust us.

**Typography lesson:**
The balance ($2,847.50) is 32–40px weight 300. The card name is 13px secondary.
The gap in scale is enormous. That gap IS the hierarchy.
Two sizes, one hundred points apart. That's it.

**Component lesson:**
Card stacking uses subtle parallax — the cards behind the front card peek at 8–10px.
This communicates that there are more cards without showing them.
The interface reveals content at the pace of intent.

**Steal this:**
For ANY high-stakes action — payment, deletion, medical result, legal document —
strip everything decorative. The UI itself becomes the trust signal.
If you're adding decoration to a high-stakes screen, you're papering over anxiety.

---

## Maps — Progressive Disclosure

**Category:** Navigation · Maps · Search
**Core insight:** Maps starts with almost nothing — a map and a search bar.
Each user action earns the next layer of information.
The UI never shows more than the current intent requires.

**Interaction flow — 5 layers:**
```
Layer 1: Idle          → Map + search bar only
Layer 2: Tap search    → Category pills appear
Layer 3: Tap a place   → Minimal card slides up (name, rating, distance)
Layer 4: Tap card      → Full detail (hours, photos, reviews, directions)
Layer 5: Tap directions → Full navigation UI takes over
```
Each layer is earned by an action. No layer is skipped.

**Component lesson:**
The bottom sheet is the best component in iOS. It appears at the right height,
contains exactly the right info for that intent, and dismisses by swipe-down.
No "close" button needed. The gesture IS the affordance.

**Spacing lesson:**
The search bar has 16px margins (the sacred rule). Category pills have 8px between them.
Filter chips have 6px 16px padding. Every spacing decision is from the 8pt grid.

**Steal this:**
Audit every screen for information that doesn't belong at that moment.
Move it to the next tap. Reveal at the pace of user intent —
not at the pace of your feature checklist.

---

## App Store — Editorial Trust

**Category:** Marketplace · Discovery · Commerce
**Core insight:** The App Store looks like a magazine, not a store.
The Today tab is pure editorial — stories, interviews, curated collections.
Trust converts better than sales pressure. Curation converts better than catalog.

**Card lesson:**
Featured hero cards are full-bleed image with dark overlay text.
"App of the Day" in 10px uppercase, tertiary color.
Title in 22px white weight 600.
Zero other UI. The content IS the UI.
No borders, no shadows, no badges on the hero card.

**Typography lesson:**
Category labels are ALWAYS 10px / UPPERCASE / 0.07em letter-spacing / tertiary color.
This convention repeats across Music, Podcasts, Books, App Store.
It's a system-level pattern. Use it for every section label in your UI.

**Color lesson:**
No brand color on the featured section. The app's art is the color.
The store steps back. This is the opposite of most marketplaces that
plaster their brand on every surface.

**Steal this:**
If you have a marketplace, your best feature is curation.
Less catalog, more editorial voice.
Curating 10 things beautifully beats listing 10,000 things badly.
The editorial voice builds trust. Trust drives conversion.

---

## Music — Content Drives Layout

**Category:** Media · Entertainment · Audio
**Core insight:** The album art in Now Playing is enormous — 60–70% of the screen.
The UI wraps around the content, not the other way around.
The content IS the design.

**Color lesson:**
Music uses dynamic color extraction from album art.
The background, scrubber, and controls adapt to the artwork's dominant color.
This is the most sophisticated color system in iOS — and it makes zero manual
color decisions. The algorithm picks, the system applies.

**Spacing lesson:**
The scrubber has 32px padding on each side (double the standard 16px).
The play button is 56px — well above the 44px HIG minimum.
Primary controls get EXTRA space because hesitation costs music playback.
Touch target generosity = UX quality signal.

**Layout lesson:**
The art is centered, takes 65% of the vertical space.
The controls hang below at a fixed distance.
There's no sidebar, no split view, no navigation chrome.
The screen has one job. It does that one job completely.

**Steal this:**
Ask: what is the primary content in my product?
Photo? Map? Chart? Document? Give it 60–70% of the screen.
Let the UI controls wrap around it, below it, or slide in over it.
The UI should step back and let the content breathe.

---

## Quick Reference — Which App to Learn From

```
You're building...              Study...
────────────────────────────────────────────────────────
A data dashboard                Health — one metaphor, hero numbers
A payment / financial flow      Wallet — restraint = trust
A search / discovery product    Maps — progressive disclosure layers
A marketplace                   App Store — editorial curation
A media player / viewer         Music — content drives layout
A settings screen               Settings — grouped lists, 44px rows, semantic icons
A notification system           Messages — density math, 52px rows, timestamp alignment
A navigation app                Maps — bottom sheet, spatial memory
An onboarding flow              App Store — editorial, not instructional
A profile / account screen      Contacts — data record layout, avatar sizing
```
