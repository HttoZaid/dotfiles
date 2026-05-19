# SEO, Semantic HTML & Clean Code

Marketing sites live or die by SEO and Core Web Vitals. Product apps live or die by
clean component architecture. This file covers both.

---

## Semantic HTML

The right element communicates meaning to browsers, screen readers, and search
engines. Using `<div>` for everything is the cheapest way to lose all three.

### The Essential Elements

```html
<!DOCTYPE html>
<html lang="en">
  <head>...</head>
  <body>
    <header>
      <nav aria-label="Primary">...</nav>
    </header>
    <main>
      <article>
        <header>
          <h1>...</h1>
          <p>...</p>
          <time datetime="2026-05-18">May 18, 2026</time>
        </header>

        <section aria-labelledby="section-1-heading">
          <h2 id="section-1-heading">...</h2>
          <p>...</p>
        </section>

        <aside aria-labelledby="related-heading">
          <h2 id="related-heading">Related</h2>
          ...
        </aside>
      </article>
    </main>
    <footer>
      <nav aria-label="Footer">...</nav>
      <address>...</address>
    </footer>
  </body>
</html>
```

### Element Cheat Sheet

| Use | When |
|---|---|
| `<main>` | Primary content of the page. Exactly one per page. |
| `<article>` | Self-contained, independently distributable content (blog post, product card). |
| `<section>` | Thematic grouping with a heading. Must have a heading. |
| `<nav>` | Group of navigation links. Use `aria-label` if more than one. |
| `<header>` | Introductory content (site header, article header). Can appear inside `<article>`. |
| `<footer>` | Closing content. Site footer, article footer. |
| `<aside>` | Tangentially related content (sidebars, callouts, related links). |
| `<figure>` + `<figcaption>` | Image / chart with caption. |
| `<time datetime="...">` | Machine-readable dates. |
| `<address>` | Contact info for the article or document author. |
| `<details>` + `<summary>` | Native collapsible. Use over JS accordions when possible. |
| `<dialog>` | Modals. With Radix or `useDialog()` for full a11y. |
| `<picture>` | Responsive images with multiple sources. |
| `<mark>` | Highlighted text. |
| `<kbd>` | Keyboard input ("Press Cmd+K"). |
| `<code>` | Inline code. |
| `<pre>` + `<code>` | Code block. |
| `<blockquote>` + `<cite>` | Quotations with source. |
| `<dl>`, `<dt>`, `<dd>` | Description lists (key-value pairs). |
| `<small>` | Side comments, fine print. |
| `<abbr title="...">` | Abbreviations with expansion. |

### Heading Hierarchy

- One `<h1>` per page.
- No skipped levels. `<h1>` → `<h2>` → `<h3>`, not `<h1>` → `<h3>`.
- Heading text describes the *section*, not the page title.
- Headings communicate document structure to assistive tech AND to search engines.

Pick a level for styling reasons → never. Pick a level for hierarchy reasons → always.

### Lists

```html
<!-- Ordered: when order matters -->
<ol>
  <li>Connect your repo</li>
  <li>Push your code</li>
  <li>See it deploy</li>
</ol>

<!-- Unordered: when order doesn't -->
<ul>
  <li>Custom domains</li>
  <li>Analytics</li>
  <li>Preview URLs</li>
</ul>

<!-- Description: definition pairs -->
<dl>
  <dt>Hobby</dt>
  <dd>Free tier with limits</dd>
  <dt>Pro</dt>
  <dd>For individuals with side projects</dd>
</dl>
```

Style with CSS. Never use `<div>` + Tailwind classes to fake a list.

### Tables

Use `<table>` for tabular data ALWAYS. Never fake tables with `<div>` grids:
screen readers can't navigate them, sortable headers don't work, copy-paste to
Excel breaks.

```html
<table>
  <caption>Revenue by region, Q4 2025</caption>
  <thead>
    <tr>
      <th scope="col">Region</th>
      <th scope="col">Revenue</th>
      <th scope="col">Growth</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">North America</th>
      <td>$2.4M</td>
      <td>+12%</td>
    </tr>
  </tbody>
</table>
```

- `<caption>` describes the table for SR users.
- `scope="col"` and `scope="row"` link cells to their headers.
- Don't use `<table>` for layout. Layout is `<div>` + grid/flex.

### Forms

```html
<form action="/api/signup" method="POST">
  <label for="email">Email</label>
  <input id="email" name="email" type="email" autocomplete="email" required />

  <fieldset>
    <legend>Plan</legend>
    <label><input type="radio" name="plan" value="hobby" /> Hobby</label>
    <label><input type="radio" name="plan" value="pro" /> Pro</label>
  </fieldset>

  <button type="submit">Sign up</button>
</form>
```

`<form>` enables native Enter-to-submit, browser autofill, password manager
integration, and clean network requests. Don't replace with `<div>` + onClick.

---

## SEO Meta Tags

Every page (especially marketing) needs:

```html
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <title>Track customer issues — Acme</title>
  <meta name="description" content="One inbox for support emails, in-product feedback, and Slack mentions. Used by 200+ engineering teams." />

  <link rel="canonical" href="https://acme.com/features/issues" />

  <!-- Open Graph (Facebook, LinkedIn, iMessage, Slack) -->
  <meta property="og:type" content="website" />
  <meta property="og:url" content="https://acme.com/features/issues" />
  <meta property="og:title" content="Track customer issues — Acme" />
  <meta property="og:description" content="One inbox..." />
  <meta property="og:image" content="https://acme.com/og/issues.png" />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />

  <!-- Twitter Cards -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:site" content="@acme" />
  <meta name="twitter:title" content="Track customer issues — Acme" />
  <meta name="twitter:description" content="One inbox..." />
  <meta name="twitter:image" content="https://acme.com/og/issues.png" />

  <!-- Favicon set -->
  <link rel="icon" href="/favicon.ico" />
  <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
  <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
  <link rel="manifest" href="/manifest.webmanifest" />

  <!-- Theme color (mobile browser chrome) -->
  <meta name="theme-color" content="#ffffff" media="(prefers-color-scheme: light)" />
  <meta name="theme-color" content="#0a0a0a" media="(prefers-color-scheme: dark)" />
</head>
```

### Title rules

- 50–60 characters.
- Primary keyword first, brand at end.
- Each page has a unique title.
- Format: `Page-specific descriptor — Brand` OR `Brand — Page-specific descriptor`.

### Description rules

- 150–160 characters.
- Action-oriented or value-oriented.
- Each page has a unique description.
- Don't repeat the title verbatim.

### OG image

- 1200 × 630 pixels (exact).
- < 1 MB (preferably 200–400 KB).
- Include product UI screenshot or wordmark, not generic illustration.
- Page title visible on the image (not just a logo).
- Test in opengraph.xyz before deploying.

### Canonical URL

- One canonical per page, the single authoritative URL.
- Strip query parameters, tracking params, trailing slashes (be consistent).
- Cross-domain: if content is syndicated, canonical points to the original.

### Next.js metadata

```tsx
// app/features/issues/page.tsx
export const metadata = {
  title: "Track customer issues",
  description: "One inbox for support emails...",
  alternates: { canonical: "https://acme.com/features/issues" },
  openGraph: {
    title: "Track customer issues — Acme",
    description: "One inbox...",
    images: [{ url: "/og/issues.png", width: 1200, height: 630 }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Track customer issues — Acme",
    images: ["/og/issues.png"],
  },
};
```

`title.template` in root layout for "Page — Brand" pattern:

```tsx
// app/layout.tsx
export const metadata = {
  title: {
    default: "Acme — Customer issue tracking",
    template: "%s — Acme",
  },
};
```

---

## Structured Data (JSON-LD)

Helps search engines understand content semantically. Generates rich snippets,
knowledge panels, and breadcrumb displays.

### Organization (in root layout)

```tsx
<script type="application/ld+json">{JSON.stringify({
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Acme",
  "url": "https://acme.com",
  "logo": "https://acme.com/logo.png",
  "sameAs": [
    "https://twitter.com/acme",
    "https://github.com/acme",
    "https://linkedin.com/company/acme",
  ],
})}</script>
```

### Article (blog posts)

```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "How we redesigned the dashboard",
  "image": "https://acme.com/blog/redesign.png",
  "datePublished": "2026-05-15",
  "dateModified": "2026-05-18",
  "author": {
    "@type": "Person",
    "name": "Jane Doe",
    "url": "https://acme.com/team/jane"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Acme",
    "logo": { "@type": "ImageObject", "url": "https://acme.com/logo.png" }
  }
}
```

### Product

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Acme Pro",
  "description": "...",
  "image": "https://acme.com/pro.png",
  "offers": {
    "@type": "Offer",
    "price": "29.00",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "reviewCount": "1247"
  }
}
```

### BreadcrumbList

```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://acme.com/" },
    { "@type": "ListItem", "position": 2, "name": "Features", "item": "https://acme.com/features" },
    { "@type": "ListItem", "position": 3, "name": "Issues", "item": "https://acme.com/features/issues" }
  ]
}
```

### FAQPage (rich snippet eligibility)

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [{
    "@type": "Question",
    "name": "Do you support custom domains?",
    "acceptedAnswer": { "@type": "Answer", "text": "Yes, on all paid plans." }
  }]
}
```

Validate with Google's Rich Results Test (search.google.com/test/rich-results).

---

## Core Web Vitals (2025–2026)

Google's measurable performance signals. Treat the thresholds as required, not
aspirational.

| Metric | Good (P75) | Needs Improvement | Poor |
|---|---|---|---|
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | 2.5s–4.0s | > 4.0s |
| **INP** (Interaction to Next Paint) | ≤ 200ms | 200–500ms | > 500ms |
| **CLS** (Cumulative Layout Shift) | < 0.1 | 0.1–0.25 | > 0.25 |

INP replaced FID in March 2024. INP measures the **worst eligible interaction**
across the whole session, not just the first.

### LCP — Largest Contentful Paint

Time until the largest visible content element renders. Usually the hero image,
H1, or video poster.

**Optimization**:
- **Hero image**: use `<Image priority fetchPriority="high">` (Next.js) or
  `<link rel="preload" as="image">`.
- **Format**: AVIF first, WebP fallback, no JPEG/PNG above the fold.
- **Self-host fonts**: `next/font` or `@font-face` with `font-display: swap`.
- **Inline critical CSS**: Next.js does this; for plain HTML, inline above-the-fold
  styles in `<style>` and load the rest async.
- **Reduce render-blocking JS**: defer or async, use `<Script strategy="afterInteractive" />`.
- **Server-render the LCP element**: never lazy-mount or wait for JS hydration.

### INP — Interaction to Next Paint

Time from interaction start to next visible paint. Measures responsiveness.

**Optimization**:
- **Break long tasks**: any JS task >50ms should be broken with `scheduler.yield()`
  or `setTimeout(0)`.
- **Defer third-party scripts**: analytics, chat widgets, ad scripts via
  `<Script strategy="lazyOnload" />`.
- **Memoize expensive React renders**: `useMemo`, `useCallback`, `React.memo`.
- **Use CSS transforms not layout-shifting properties**: animating `width` blocks
  the main thread; `transform` doesn't.
- **Move heavy work off-main-thread**: Web Workers for parsing, image processing.

INP is where modern AI-generated UIs often regress: too much Framer Motion animating
non-transform properties under load.

### CLS — Cumulative Layout Shift

Sum of unexpected layout shifts. Catches: late-loading images that push content,
fonts swapping in with different metrics, ads injecting late.

**Optimization**:
- **Explicit `width` and `height`** on every `<img>` and `<video>`.
- **Reserve space for ads/embeds** with `aspect-ratio` CSS.
- **`font-size-adjust`** on body to match fallback font metrics:
  ```css
  body { font-family: "Geist", system-ui, sans-serif; font-size-adjust: 0.5; }
  ```
- **Use skeletons** that match final layout, not generic blocks.
- **Avoid injecting content above existing content** post-load. New toasts/banners
  appear at top of viewport with absolute positioning, not pushing content.

### Measurement

- Lighthouse (Chrome DevTools).
- PageSpeed Insights (pagespeed.web.dev) — uses real-world Chrome User Experience data.
- Vercel Analytics, Cloudflare Speed Insights.
- web.dev/vitals for definitions.

---

## Image Optimization

```tsx
// Hero (LCP element)
<Image
  src="/hero.png"
  alt="Acme product dashboard"
  width={1200}
  height={800}
  priority
  fetchPriority="high"
/>

// Below the fold
<Image
  src="/feature.png"
  alt="Feature illustration"
  width={800}
  height={600}
  loading="lazy"
  decoding="async"
/>
```

### Responsive images with `<picture>`

```html
<picture>
  <source type="image/avif" srcset="hero.avif" />
  <source type="image/webp" srcset="hero.webp" />
  <img src="hero.jpg" alt="..." width="1200" height="800" />
</picture>
```

### Rules

- AVIF preferred, WebP fallback. JPEG/PNG only as last resort.
- Always set `width` and `height` to prevent CLS.
- `loading="lazy"` for below-the-fold images.
- `loading="eager"` + `fetchpriority="high"` for LCP.
- `decoding="async"` everywhere except LCP.
- Compress aggressively: 80% quality is invisible vs 100% at half the bytes.
- `sizes` attribute for responsive: `sizes="(max-width: 768px) 100vw, 50vw"`.

---

## Font Loading (Recap from typography.md)

```css
@font-face {
  font-family: "Geist";
  src: url("/fonts/geist-variable.woff2") format("woff2-variations");
  font-weight: 100 900;
  font-display: swap;
}
```

```html
<link rel="preload" href="/fonts/geist-variable.woff2" as="font" type="font/woff2" crossorigin />
```

- WOFF2 only.
- Variable fonts (one file, all weights).
- `font-display: swap` to prevent FOIT (Flash of Invisible Text).
- Preload max 2 fonts (each competes with LCP).
- Self-host > Google Fonts (CSS request adds 100–200ms).

---

## Clean Code Rules

For any component or page Grain generates.

### 1. No inline styles

```tsx
{/* Bad */}
<div style={{ padding: 24, borderRadius: 8 }}>...</div>

{/* Good */}
<div className="p-6 rounded-lg">...</div>
```

Inline styles defeat the design system. Use Tailwind utilities or CSS variables.

### 2. No magic numbers

```tsx
{/* Bad */}
<div className="p-[27px] mt-[33px]">...</div>

{/* Good */}
<div className="p-6 mt-8">...</div>     {/* 24px, 32px from spacing scale */}
```

Every dimension comes from the spacing/sizing scale.

### 3. No hardcoded colors

```tsx
{/* Bad */}
<button className="bg-[#7C3AED] text-white">

{/* Good */}
<button className="bg-accent text-accent-fg">
```

Colors come from CSS variables, period.

### 4. Semantic component names

```tsx
{/* Bad */}
<Button2 variant="newNew">

{/* Good */}
<Button variant="destructive">
```

Names describe the component's role, not its history.

### 5. Consistent prop patterns

Across all components, use the same vocabulary:

| Prop | Values |
|---|---|
| `size` | `xs`, `sm`, `md`, `lg`, `xl` |
| `variant` | `primary`, `secondary`, `tertiary`, `ghost`, `outline`, `destructive` |
| `tone` | semantic — `success`, `warning`, `error`, `info`, `neutral`, `accent` |
| `disabled` | boolean |
| `loading` | boolean |
| `fullWidth` | boolean |

### 6. Co-locate styles with components

```
components/
  button/
    button.tsx
    button.module.css   (or styles inline via Tailwind)
    button.stories.tsx
    button.test.tsx
```

No global CSS except design tokens.

### 7. Compose, don't extend

Build complex components from primitives:

```tsx
// Card is a composition, not a megacomponent
<Card>
  <CardHeader>
    <CardTitle>...</CardTitle>
  </CardHeader>
  <CardBody>...</CardBody>
</Card>
```

Each subcomponent has its own role. The user composes; the system doesn't have a
god-component with 30 props.

### 8. No `div` soup

```tsx
{/* Bad */}
<div>
  <div>
    <div className="title">Profile</div>
    <div className="text">Manage your account</div>
  </div>
</div>

{/* Good */}
<header>
  <h2>Profile</h2>
  <p>Manage your account</p>
</header>
```

### 9. Prop drilling has a limit

Three levels of prop passing is OK. Beyond that, use composition, context, or a
state library.

### 10. Comments explain *why*, not *what*

```tsx
// Bad: explains what
// Set padding to 24px
<div className="p-6">

// Good: explains why
// Extra padding to align with sticky header height
<div className="p-6 pt-16">
```

Reserve comments for non-obvious reasoning, escape-hatch overrides, and TODOs.

### 11. File structure

```
app/                        # Next.js app router
components/                 # shared components
  ui/                       # shadcn primitives
  features/                 # feature-specific composed components
lib/                        # utilities, hooks
styles/
  globals.css               # @theme, base styles
public/                     # static assets
```

Match this structure or document why you deviate.

### 12. Naming conventions

- **Files**: `kebab-case.tsx` for components, `camelCase.ts` for utilities.
- **Components**: `PascalCase`.
- **Hooks**: `useCamelCase`.
- **CSS variables**: `--kebab-case`.
- **Types**: `PascalCase`, prefix `T` only if collision exists.
- **Constants**: `SCREAMING_SNAKE_CASE` for module-level constants only.

### 13. Don't reinvent primitives

Don't write a custom modal when Radix Dialog exists. Don't write a custom popover
when Radix Popover exists. The primitives are accessibility-tested; rebuilding them
guarantees bugs.

The Grain stack already includes Radix UI primitives via shadcn. Use them.

---

## SEO Checklist for Marketing Pages

- [ ] Unique `<title>` (50–60 chars)
- [ ] Unique `<meta description>` (150–160 chars)
- [ ] Canonical URL
- [ ] OG + Twitter image (1200×630)
- [ ] One `<h1>` matching the page topic
- [ ] Heading hierarchy without skips
- [ ] Semantic HTML5 elements (`<main>`, `<article>`, `<nav>`)
- [ ] Internal links to related pages with descriptive anchor text
- [ ] All images have meaningful alt text
- [ ] JSON-LD structured data (Organization, Article, Product, etc.)
- [ ] `sitemap.xml` and `robots.txt`
- [ ] Mobile-responsive (test at 375px, 768px, 1280px)
- [ ] HTTPS only
- [ ] LCP ≤ 2.5s on 4G
- [ ] CLS < 0.1 throughout interaction
- [ ] INP ≤ 200ms on common actions
- [ ] No console errors in production build
- [ ] Lighthouse score: 90+ across all four categories

If three or more fail on a marketing page, fix before launch.
