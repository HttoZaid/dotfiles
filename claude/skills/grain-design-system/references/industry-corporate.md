# Industry Pack — Corporate / Marketing

For homepages, marketing sites, product pages, landing pages, agency sites,
company.com. The reference points are **Apple, Stripe, Linear marketing site,
Vercel marketing site, Anthropic, OpenAI, Framer, Arc, rauno.me-tier personal sites,
Pitch, Ramp**.

This pack overrides Grain foundation with marketing-specific defaults.

---

## Pack Identity

Marketing UI lives by different rules than product UI. The goals are:

- **Personality** — telegraph the brand in the first second
- **Editorial composition** — asymmetry, deliberate layout breaks, scroll-driven
  storytelling
- **Generous whitespace** — content has room to breathe
- **Premium typography** — display type is the design
- **Real imagery** — product screenshots, custom illustration, video; never
  unDraw / stock 3D humans
- **One CTA per section** — no generic two-button hero stacks

---

## Token Overrides

```css
:root[data-pack="corporate"] {
  /* Accent: pick by brand. Default to warm terracotta for non-tech, near-black for tech */
  --color-accent: oklch(20% 0.04 265);
  --color-accent-fg: oklch(99% 0.005 270);

  /* Radii: corporate goes either capsule or near-zero */
  --radius-button: 9999px;                       /* capsule */
  --radius-card: 0.75rem;                        /* 12px - softer than SaaS */
  --radius-input: 0.5rem;
  --radius-modal: 1rem;

  /* Larger display sizes for marketing */
  --text-display: clamp(4rem, 12vw, 9rem);       /* 64–144px */
  --text-display-secondary: clamp(2.5rem, 6vw, 4.5rem);  /* 40–72px */

  /* Tighter display tracking */
  --tracking-display: -0.05em;                   /* more aggressive */
  --tracking-tight: -0.02em;

  /* Looser body for editorial reading */
  --leading-body: 1.7;                           /* roomier than SaaS 1.5 */
  --leading-display: 1.0;                        /* tight for huge heads */

  /* Font: editorial-ready */
  --font-display: var(--font-geist-sans), system-ui, sans-serif;
  --font-sans: var(--font-geist-sans), system-ui, sans-serif;
}
```

For editorial / agency feel (serif display):
```css
:root[data-pack="corporate-editorial"] {
  --font-display: "Migra", "Editorial New", Georgia, serif;
  --font-sans: var(--font-geist-sans), system-ui, sans-serif;
}
```

For Apple-tier tech:
```css
:root[data-pack="corporate-apple"] {
  --color-accent: oklch(20% 0.04 265);          /* near-black */
  --font-display: "SF Pro Display", -apple-system, BlinkMacSystemFont, sans-serif;
  --font-sans: "SF Pro Text", -apple-system, sans-serif;
}
```

---

## Reference Patterns by Brand

### Apple — Editorial precision

**Identity**: large product close-ups, vertical-stacked sections each with their own
theme, scroll-driven reveals, sticky frosted nav.

**Specific signatures**:
- Hero is a product (not text + button). Big image, small text below.
- Each section has its own background color and visual identity.
- Section headers anchor at the top as the user scrolls past.
- "Learn more" reveals deeper content inline, not via separate page.
- Pricing pages: clean rows, no "MOST POPULAR" sash, no purple gradient header.

**To imitate Apple**:
```tsx
<section className="min-h-screen flex flex-col items-center text-center bg-bg">
  <h1 className="pt-20 text-7xl md:text-8xl font-medium tracking-[-0.04em]">
    iPhone 17 Pro
  </h1>
  <p className="mt-4 text-xl text-muted">A magic-wand for the rest of us.</p>
  <div className="mt-8 flex gap-6 text-base">
    <a href="/buy" className="text-accent underline">Buy</a>
    <a href="/learn" className="text-muted underline">Learn more &gt;</a>
  </div>
  <div className="mt-12 flex-1 w-full">
    <Image src="/hero-iphone.png" alt="iPhone 17 Pro" priority />
  </div>
</section>
```

Notice: text as inline links, not buttons. Product image fills the bottom 60% of the
viewport. No CTA button stack.

### Stripe — Atmospheric gradient + Söhne weight 300

**Identity**: atmospheric gradient mesh in the top third, Söhne at weight 300,
soft large shadows on cards, deep violet `#533afd` as accent.

**The Stripe gradient mesh recipe**:
```css
.stripe-mesh {
  background:
    radial-gradient(ellipse at 30% 20%, oklch(94% 0.08 30 / 0.4), transparent 60%),
    radial-gradient(ellipse at 70% 40%, oklch(92% 0.1 280 / 0.3), transparent 70%),
    radial-gradient(ellipse at 50% 10%, oklch(94% 0.06 350 / 0.4), transparent 60%),
    oklch(99% 0.004 270);
}
```

Use bounded — only the top third of the hero, never the entire viewport.

**To imitate Stripe**:
```tsx
<section className="stripe-mesh py-32">
  <div className="max-w-5xl mx-auto px-6">
    <h1 className="text-7xl font-light tracking-[-0.025em] leading-[1.05]">
      Financial<br />
      infrastructure for<br />
      the internet.
    </h1>
    <p className="mt-8 text-xl text-muted max-w-2xl">
      Millions of companies of all sizes use Stripe online and in person to accept
      payments, send payouts, automate financial processes, and ultimately grow
      revenue.
    </p>
    <div className="mt-12 flex gap-4">
      <Button variant="primary" size="lg">Start now</Button>
      <Button variant="ghost" size="lg">Contact sales →</Button>
    </div>
  </div>
</section>
```

### Vercel marketing — Geist + grayscale + asymmetry

**Identity**: pure grayscale, Geist, no decorative imagery — code blocks, screenshots,
and geometric typography compositions do all the work.

**Specific signatures**:
- Hero copy left-aligned, not centered
- One CTA primary, optional ghost secondary
- Display heads use weight 600 + `-0.04em` tracking + `1.15` line-height
- Section breaks use full-bleed dividers or geometric SVG compositions
- Footer is rich: sitemap, status, address, social

### Linear marketing — Cinematic dark + tight density

**Identity**: dark-mode-first marketing (rare and distinctive), Magic Blue accents,
ultra-clean composition, no decorative gradients, focus on product imagery.

**Specific signatures**:
- Background near-black (`oklch(15% 0.02 270)`)
- Magic Blue glow behind H1 (subtle, low-saturation)
- Product screenshots as primary imagery
- Whitespace pull-quote sections in serif (Tobias) optional

### Anthropic — Warm editorial

**Identity**: warm terracotta accent, generous spacing, editorial typography
(serif option), prose-heavy sections, scholarly tone.

**Specific signatures**:
- Background `oklch(98% 0.01 80)` (warm white)
- Accent `oklch(65% 0.14 40)` (terracotta)
- Display can use serif (Tiempos / Editorial New)
- Section transitions use color shifts (warm → neutral → warm)

### Framer / Arc — Bold, playful, contemporary

**Identity**: oversized display type, scroll-driven product reveals, custom video
embeds, optional bright accents, generous animation.

---

## The 14 Corporate Pack Rules

### Hero Composition

**1.** No center-stacked "H1 + subtitle + two equal CTAs" (anti-slop rule #2). Pick
one of: editorial asymmetric, hero video, single-CTA, scroll-driven product reveal,
or quote-as-hero.

**2.** Display headlines are 64–144px (`--text-display`). Below 56px, it's not a
display head — it's a subhead.

**3.** Display uses `--tracking-display` (-0.04em to -0.06em).

**4.** Display line-height ≤ 1.1.

**5.** One primary CTA per section. Secondary action is a text link, not a second
button.

### Sections

**6.** Each major section has its own visual identity — background color shift,
imagery, layout direction. Stacked sections shouldn't blur into each other.

**7.** Sections stack with vertical padding `py-20` to `py-32` (80–128px). Section
internal padding `py-12` to `py-16` (48–64px).

**8.** No three-column features grid as a default. Each section is its own
composition.

**9.** Editorial breaks: pull-quotes, full-bleed images, asymmetric grid for variety.

### Type & Imagery

**10.** Display can use serif (editorial pack) or sans (tech pack). Body always sans.

**11.** Body 17–18px on marketing (larger than SaaS pack's 14–16px).

**12.** No unDraw / Storyset / 3D abstract humans. Product screenshots, custom
illustration, real photography, or geometric/typographic compositions only.

**13.** Hero video, when used, is product behavior — never decorative loops or
ambient nature.

### Chrome

**14.** Sticky nav becomes frosted/glass pill on scroll. Logo + 3–5 nav links + 1
CTA. Mobile collapses to hamburger.

---

## Layout Templates

### Editorial asymmetric hero

```tsx
<section className="pt-32 pb-20">
  <div className="max-w-7xl mx-auto px-6 grid grid-cols-12 gap-8">
    <div className="col-span-12 lg:col-span-8">
      <h1 className="text-display font-medium tracking-display leading-display">
        Build software<br />
        without infrastructure.
      </h1>
    </div>
    <aside className="col-span-12 lg:col-span-4 lg:pt-12">
      <p className="text-lg text-muted leading-relaxed">
        Acme is the developer platform that takes care of everything that's not
        your application — so you can ship products, not infrastructure.
      </p>
      <Button variant="primary" size="lg" className="mt-8">
        Get started
      </Button>
    </aside>
  </div>
</section>
```

### Single-CTA hero with product imagery

```tsx
<section className="pt-24 pb-12">
  <div className="max-w-6xl mx-auto px-6 text-center">
    <h1 className="text-display font-semibold tracking-display leading-display">
      The new way to ship.
    </h1>
    <p className="mt-6 text-xl text-muted max-w-2xl mx-auto">
      One platform for your team to plan, build, and ship products that
      customers love.
    </p>
    <div className="mt-10">
      <Button variant="primary" size="lg">Start free trial</Button>
    </div>
  </div>
  <div className="mt-16 max-w-7xl mx-auto px-6">
    <div className="rounded-2xl overflow-hidden border shadow-modal">
      <Image src="/product-hero.png" alt="Acme dashboard" priority />
    </div>
  </div>
</section>
```

### Scroll-driven product section

```tsx
<section className="py-32 bg-surface-2">
  <div className="max-w-6xl mx-auto px-6 grid grid-cols-12 gap-8 items-center">
    <div className="col-span-12 lg:col-span-5 lg:sticky lg:top-24 lg:self-start">
      <span className="text-sm uppercase tracking-uppercase text-muted">
        For Engineering Teams
      </span>
      <h2 className="mt-3 text-5xl font-medium tracking-tight leading-tight">
        Sprint planning,<br />in 20 minutes.
      </h2>
      <p className="mt-6 text-lg text-muted">
        Auto-generated sprint goals from your last 4 weeks of GitHub activity.
        Drag-and-drop prioritization. Capacity-aware assignment.
      </p>
    </div>
    <div className="col-span-12 lg:col-span-7 space-y-6">
      <Image src="/feature-1.png" alt="Sprint board" />
      <Image src="/feature-2.png" alt="GitHub sync" />
      <Image src="/feature-3.png" alt="Capacity view" />
    </div>
  </div>
</section>
```

The left column sticks while the right column scrolls. Apple uses this pattern
extensively.

### Quote-as-hero

```tsx
<section className="py-32 max-w-5xl mx-auto px-6">
  <blockquote className="text-4xl md:text-6xl font-medium tracking-tight leading-tight">
    "We moved every customer touchpoint to Acme in two weeks. Our team finally
    has a single inbox."
  </blockquote>
  <footer className="mt-12 flex items-center gap-4">
    <Image src="/testimonials/jane.jpg" alt="" className="size-12 rounded-full" />
    <div>
      <p className="font-medium">Jane Doe</p>
      <p className="text-muted text-sm">VP Engineering, Megacorp</p>
    </div>
  </footer>
</section>
```

### Sticky frosted nav

```tsx
<header className="sticky top-0 z-50 bg-bg/70 backdrop-blur-md border-b">
  <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
    <a href="/" className="flex items-center gap-2 font-semibold">
      <Logo />
      Acme
    </a>
    <nav className="hidden md:flex items-center gap-8 text-sm">
      <a href="/product" className="text-muted hover:text-fg">Product</a>
      <a href="/customers" className="text-muted hover:text-fg">Customers</a>
      <a href="/pricing" className="text-muted hover:text-fg">Pricing</a>
      <a href="/docs" className="text-muted hover:text-fg">Docs</a>
    </nav>
    <div className="flex items-center gap-3">
      <a href="/login" className="text-sm text-muted hover:text-fg">Log in</a>
      <Button variant="primary" size="sm">Sign up</Button>
    </div>
  </div>
</header>
```

### Footer (rich)

```tsx
<footer className="border-t bg-surface">
  <div className="max-w-7xl mx-auto px-6 py-16 grid grid-cols-2 md:grid-cols-5 gap-8">
    <div className="col-span-2">
      <Logo className="size-10" />
      <p className="mt-4 text-sm text-muted max-w-xs">
        The developer platform for shipping products.
      </p>
      <p className="mt-6 text-sm text-muted">
        Acme Inc.<br />
        548 Market St #12345<br />
        San Francisco, CA 94104
      </p>
    </div>
    <nav>
      <h3 className="text-sm font-medium">Product</h3>
      <ul className="mt-3 space-y-2 text-sm text-muted">
        <li><a href="/product">Overview</a></li>
        <li><a href="/features">Features</a></li>
        <li><a href="/pricing">Pricing</a></li>
        <li><a href="/changelog">Changelog</a></li>
      </ul>
    </nav>
    <nav>
      <h3 className="text-sm font-medium">Resources</h3>
      <ul className="mt-3 space-y-2 text-sm text-muted">
        <li><a href="/docs">Docs</a></li>
        <li><a href="/blog">Blog</a></li>
        <li><a href="/customers">Customers</a></li>
        <li><a href="/status">Status</a></li>
      </ul>
    </nav>
    <nav>
      <h3 className="text-sm font-medium">Company</h3>
      <ul className="mt-3 space-y-2 text-sm text-muted">
        <li><a href="/about">About</a></li>
        <li><a href="/careers">Careers</a></li>
        <li><a href="/contact">Contact</a></li>
        <li><a href="/legal">Legal</a></li>
      </ul>
    </nav>
  </div>
  <div className="border-t">
    <div className="max-w-7xl mx-auto px-6 py-6 flex flex-col md:flex-row items-center justify-between gap-4 text-xs text-muted">
      <p>© 2026 Acme Inc. All rights reserved.</p>
      <div className="flex items-center gap-4">
        <a href="/privacy">Privacy</a>
        <a href="/terms">Terms</a>
        <a href="https://twitter.com/acme" aria-label="Twitter"><TwitterIcon /></a>
        <a href="https://github.com/acme" aria-label="GitHub"><GitHubIcon /></a>
      </div>
    </div>
  </div>
</footer>
```

Rich footer: sitemap by category, address, status link, social. Apple/Stripe-style,
not a single thin row.

---

## Pricing Pages

Clean rows, no "MOST POPULAR" sash, no gradient header. Stripe's pricing page is
the reference.

```tsx
<section className="py-24 max-w-6xl mx-auto px-6">
  <header className="text-center max-w-2xl mx-auto">
    <h1 className="text-5xl font-medium tracking-tight">Pricing</h1>
    <p className="mt-4 text-lg text-muted">
      Start free. Upgrade as you grow. No hidden fees.
    </p>
  </header>

  <div className="mt-16 grid grid-cols-1 md:grid-cols-3 gap-6">
    {plans.map(plan => (
      <article className="border rounded-xl p-8 bg-surface">
        <h2 className="text-lg font-medium">{plan.name}</h2>
        <p className="mt-1 text-sm text-muted">{plan.description}</p>
        <p className="mt-6 text-4xl font-medium tabular-nums">
          ${plan.price}<span className="text-base text-muted font-normal">/mo</span>
        </p>
        <Button variant={plan.featured ? "primary" : "outline"} className="mt-6 w-full">
          {plan.cta}
        </Button>
        <ul className="mt-8 space-y-3">
          {plan.features.map(f => (
            <li className="flex items-start gap-2 text-sm">
              <Check size={16} className="text-accent flex-none mt-0.5" />
              {f}
            </li>
          ))}
        </ul>
      </article>
    ))}
  </div>
</section>
```

Notice:
- No card highlighting via background gradient or scale-up. Variation comes from
  the CTA variant (`primary` for featured, `outline` for others).
- Features list uses Check icons, not bullets.
- Prices use `tabular-nums`.

---

## Imagery for Corporate

In priority order:
1. **Product screenshots** with realistic data (real names if approved, otherwise
   high-quality fakes — never `lorem ipsum`).
2. **Hero video** of product behavior, autoplay muted with reduced-motion fallback
   to still image.
3. **Custom illustration** with consistent style across the site.
4. **Real photography** — actual people, actual workspaces, custom-shot or
   high-quality licensed.
5. **Geometric / typographic compositions** — Vercel-style geometric SVG.
6. **Atmospheric gradients** — Stripe-mesh-only, bounded.

Banned:
- unDraw, Storyset, ManyPixels, Open Doodles, generic flat illustration libraries.
- 3D abstract humans.
- Floating geometric blobs.
- Stock photos of "diverse professionals smiling at laptops."

---

## Animation for Corporate

Scroll-driven animation is allowed (and encouraged) on marketing pages. Rules:

- Pick **one** hero moment per page that earns a reveal.
- Subsequent sections are static or have subtle (≤100ms opacity) reveals.
- Parallax: only on hero, only at low intensity (≤20% offset).
- View Transitions API for route changes (250ms max).
- All scroll-driven animation has reduced-motion fallback (just appear).

```css
.scroll-reveal {
  animation: fade-up linear;
  animation-timeline: view();
  animation-range: entry 10% cover 30%;
}

@keyframes fade-up {
  from { opacity: 0; transform: translateY(40px); }
  to   { opacity: 1; transform: translateY(0); }
}

@media (prefers-reduced-motion: reduce) {
  .scroll-reveal { animation: none; opacity: 1; transform: none; }
}
```

---

## SEO for Corporate

Marketing pages live or die by SEO. Every page must satisfy `seo-clean-code.md`:

- Unique `<title>` (50–60 chars) with primary keyword first
- Unique `<meta description>` (150–160 chars)
- Canonical URL
- OG + Twitter card with 1200×630 image
- One `<h1>` matching page topic
- Semantic landmarks (`<main>`, `<article>`, `<nav>`, `<footer>`)
- JSON-LD structured data (Organization, Article, Product, BreadcrumbList, FAQPage)
- Image alt text on every image
- LCP ≤ 2.5s, INP ≤ 200ms, CLS < 0.1

---

## Hard Bans for Corporate Pack

- ❌ Centered hero with two equal CTAs (anti-slop rule #2).
- ❌ Three-column features grid as the primary section pattern.
- ❌ "Trusted by" grayscale logo wall as a default.
- ❌ Generic CTAs ("Get started for free" + "Watch demo") — must be specific.
- ❌ unDraw / Storyset / stock illustration libraries.
- ❌ Lorem-ipsum-tier copy ("Empower your workflow," "Built for modern teams").
- ❌ Full-viewport gradient backgrounds (only bounded gradient mesh allowed).
- ❌ Auto-animate everything on scroll (pick one hero moment).
- ❌ Default browser/Bootstrap blue links.
- ❌ Sparkles ✨ and AI iconography in marketing copy.
