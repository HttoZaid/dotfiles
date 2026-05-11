
# React / TypeScript UI — Advanced Performance, SSR, Accessibility, and Clean Code

Use this file when the user is working on React UI, Next.js, Remix, Vite React, SSR, SSG, hydration, accessibility, component APIs, Tailwind CSS, query/data folders, design systems, performance, or cleaning UI codebases.

This is not beginner React advice. Prefer fast pages, obvious state ownership, accessible components, small client bundles, typed boundaries, stable UI contracts, and deletion over clever abstractions.

---

## 4.1 Rule zero: users feel latency, instability, and confusion

Users usually love UI that is:

- fast on first load
- fast after interaction
- visually stable
- readable
- predictable
- forgiving
- keyboard-accessible
- mobile-safe
- clear about loading, errors, and success
- not over-animated
- not over-designed
- consistent across screens

A beautiful UI that shifts, blocks input, loses state, traps focus, or hides errors is bad UI.

Optimize for:
1. time to useful content
2. interaction responsiveness
3. layout stability
4. accessibility
5. clarity
6. consistency
7. maintainability

Do not optimize for:
- clever component APIs nobody understands
- animation everywhere
- maximal abstraction
- "clean" folders that hide ownership
- client-side everything
- memoization as decoration

---

## 4.2 Rendering strategy: SSR, SSG, ISR, CSR, RSC, and PPR

Choose rendering per page section, not by fashion.

### Use SSG / static rendering for:
- marketing pages
- docs
- landing pages
- pricing pages with rare changes
- public blog pages
- product/category pages with cacheable data
- pages where freshness is not per-request critical

### Use ISR / revalidation for:
- public content that changes occasionally
- product catalogs
- CMS pages
- docs with scheduled updates
- pages where stale-for-a-short-time is acceptable

### Use SSR for:
- request-specific data
- auth-specific pages
- dashboards
- geo/cookie/header-dependent rendering
- pages where SEO needs fresh dynamic content

### Use CSR for:
- highly interactive app islands
- dashboards after shell load
- admin tools
- authenticated widgets not needed for SEO
- browser-only APIs

### Use RSC / Server Components for:
- data fetching close to the server
- reducing client JavaScript
- keeping secrets/server-only code off the client
- static or mostly static UI that does not need hooks/events

### Use client components for:
- event handlers
- state
- effects
- browser APIs
- animations
- interactive controls

### Use PPR / streamed dynamic islands when:
- most of the page is static
- a few sections are personalized or slow
- you want a fast shell plus dynamic content
- dynamic data should not block the whole route

Rule:
- Static shell first.
- Dynamic islands second.
- Client JavaScript last.

Bad:
```tsx
'use client';

export default function ProductPage() {
  // Entire route is client-side because one button is interactive.
}
````

Better:

```tsx
export default async function ProductPage() {
  const product = await getProduct();

  return (
    <>
      <ProductHero product={product} />
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews productId={product.id} />
      </Suspense>
      <AddToCartClient productId={product.id} />
    </>
  );
}
```

---

## 4.3 Hydration discipline

Hydration bugs are UX bugs.

Common causes:

* reading `window` during render
* using `Date.now()` during server render
* using `Math.random()` during server render
* rendering different markup server vs client
* locale/timezone mismatch
* browser extension assumptions
* client-only state determining initial structure
* invalid HTML nesting
* unstable IDs

Rules:

* Server and first client render must match.
* Put browser-only logic in `useEffect`.
* Use `useId` for accessible IDs, not random IDs.
* Do not generate random IDs in render.
* Avoid server-rendering time-sensitive text unless controlled.
* Wrap truly client-only widgets intentionally.

Bad:

```tsx
const id = Math.random().toString(36);

return <label htmlFor={id}>Email</label>;
```

Better:

```tsx
const id = useId();

return (
  <>
    <label htmlFor={id}>Email</label>
    <input id={id} />
  </>
);
```

---

## 4.4 Component IDs and accessibility contracts

Use stable IDs for relationships, not styling.

Use `useId` for:

* `label` ↔ `input`
* `aria-describedby`
* `aria-labelledby`
* error message relationships
* hint text relationships
* tabs
* accordions
* combobox/listbox relationships

Example:

```tsx
type TextFieldProps = {
  label: string;
  error?: string;
  hint?: string;
} & Omit<React.InputHTMLAttributes<HTMLInputElement>, 'id'>;

export const TextField = ({ label, error, hint, ...props }: TextFieldProps) => {
  const id = useId();
  const hintId = hint ? `${id}-hint` : undefined;
  const errorId = error ? `${id}-error` : undefined;
  const describedBy = [hintId, errorId].filter(Boolean).join(' ') || undefined;

  return (
    <div className="grid gap-1.5">
      <label htmlFor={id} className="text-sm font-medium">
        {label}
      </label>

      <input
        id={id}
        aria-invalid={error ? true : undefined}
        aria-describedby={describedBy}
        className="h-10 rounded-md border px-3 text-sm"
        {...props}
      />

      {hint ? (
        <p id={hintId} className="text-sm text-muted-foreground">
          {hint}
        </p>
      ) : null}

      {error ? (
        <p id={errorId} className="text-sm text-destructive">
          {error}
        </p>
      ) : null}
    </div>
  );
};
```

Rules:

* Do not use IDs for CSS targeting in component libraries.
* Do not make consumers manually wire IDs unless needed.
* Expose `id` override only when integration requires it.
* Every form field needs a programmatic label.
* Error text must be connected to the field.

---

## 4.5 Query/data folder structure

Use a feature-first structure. Keep data fetching near the feature, but keep raw API clients out of components.

Recommended:

```text
src/
  app/
    routes/
    providers/
    layout/
  features/
    users/
      api/
        get-user.ts
        update-user.ts
        user.schema.ts
      queries/
        user.query.ts
        user.mutations.ts
        user.keys.ts
      components/
        user-card.tsx
        user-form.tsx
      screens/
        user-details-screen.tsx
      model/
        user.types.ts
        user.mappers.ts
      index.ts
  shared/
    ui/
    lib/
    config/
    api/
```

Rules:

* `api/` owns HTTP/database boundary calls.
* `queries/` owns TanStack Query/SWR hooks and keys.
* `model/` owns feature types, schemas, and mappers.
* `components/` owns feature UI.
* `screens/` composes feature components.
* `shared/ui` must not import feature code.
* `shared/lib` must not become a trash pile.

Bad:

```text
src/
  components/
  hooks/
  utils/
  services/
  types/
```

That structure hides feature ownership.

---

## 4.6 TanStack Query / SWR discipline

Rules:

* Query keys must be centralized and stable.
* Query functions must not return unvalidated unknown payloads.
* Mutations must invalidate/update exact affected queries.
* Do not call query hooks deep in tiny leaf components unless the leaf owns the data.
* Do not duplicate server state into local state.
* Do not use global stores for server cache.
* Keep optimistic updates small and reversible.

Example query keys:

```ts
export const userKeys = {
  all: ['users'] as const,
  detail: (id: UserId) => [...userKeys.all, 'detail', id] as const,
  list: (filters: UserFilters) => [...userKeys.all, 'list', filters] as const,
};
```

Example query:

```ts
export const useUserQuery = (id: UserId) => {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => getUser(id),
    staleTime: 60_000,
  });
};
```

Rules:

* Avoid stringly query keys scattered across files.
* Avoid `refetch()` as a default mutation strategy.
* Prefer invalidation or cache updates.
* Set `staleTime` intentionally.
* Do not make every query instantly stale unless the data truly is.

---

## 4.7 Client state vs server state

Server state:

* fetched from API/database
* cached
* shared across screens
* can become stale
* belongs in TanStack Query/SWR/router loaders/server components

Client state:

* modal open
* tab selected
* input draft
* drag state
* hover state
* local filters before submit
* belongs near the component

Global client state:

* auth session view
* theme
* app layout preferences
* feature flags after bootstrap
* rarely needed

Rule:

* Do not put server data in Zustand/Redux just because multiple components need it.
* Do not put modal state in TanStack Query.
* Do not make everything global.

---

## 4.8 Component API design: composition over configuration

A 30-prop component is a bug farm.

Bad:

```tsx
<Card
  showHeader
  showFooter
  headerLeftIcon
  headerRightAction
  footerButtonText
  footerButtonVariant
  compact
  bordered
  elevated
/>
```

Better:

```tsx
<Card>
  <Card.Header>
    <Card.Title>Billing</Card.Title>
    <Card.Action>Manage</Card.Action>
  </Card.Header>

  <Card.Content>
    ...
  </Card.Content>

  <Card.Footer>
    <Button>Save</Button>
  </Card.Footer>
</Card>
```

Use:

1. simple props for simple components
2. slots/children for layout components
3. compound components for shared internal state
4. render props only when necessary
5. headless hooks for reusable behavior

Rules:

* Props should describe decisions, not implementation details.
* Boolean prop explosion means the abstraction is wrong.
* Prefer explicit composition for UI users need to customize.
* Do not hide too much markup from product teams.

---

## 4.9 Compound components

Use compound components when children need shared state.

Good:

```tsx
<Tabs defaultValue="profile">
  <Tabs.List>
    <Tabs.Trigger value="profile">Profile</Tabs.Trigger>
    <Tabs.Trigger value="billing">Billing</Tabs.Trigger>
  </Tabs.List>

  <Tabs.Content value="profile">...</Tabs.Content>
  <Tabs.Content value="billing">...</Tabs.Content>
</Tabs>
```

Rules:

* Use compound components for real shared behavior.
* Do not namespace components only for aesthetics.
* Keep context value small and memoized only when necessary.
* Throw helpful errors when compound parts are used outside root.
* Prefer Radix/React Aria for complex accessible primitives.

---

## 4.10 Accessibility is not optional

Minimum:

* keyboard works
* focus is visible
* form fields have labels
* icon buttons have accessible names
* dialogs trap focus and restore focus
* menus support keyboard navigation
* dynamic status has live region when needed
* color contrast passes
* loading/error/success states are perceivable
* disabled state is not the only feedback
* semantic HTML before ARIA

Bad:

```tsx
<div onClick={onClose}>Close</div>
```

Better:

```tsx
<button type="button" onClick={onClose}>
  Close
</button>
```

Rules:

* Use `<button>` for actions.
* Use `<a>` for navigation.
* Do not put click handlers on random divs.
* Do not remove outlines without replacing them.
* Do not rely on color alone.
* Do not build custom dialog/menu/combobox from scratch unless the team has accessibility expertise.

For primitives:

* Radix UI
* React Aria
* Ariakit
* Base UI
* Headless UI

Prefer mature primitives over homemade accessibility.

---

## 4.11 Tailwind CSS v4 modern usage

Tailwind v4 is CSS-first. Prefer `@import "tailwindcss"` and `@theme` variables for design tokens.

Example:

```css
@import "tailwindcss";

@theme {
  --color-background: oklch(1 0 0);
  --color-foreground: oklch(0.145 0 0);

  --color-primary: oklch(0.55 0.18 260);
  --color-primary-foreground: oklch(0.98 0.01 260);

  --color-muted: oklch(0.96 0.01 260);
  --color-muted-foreground: oklch(0.45 0.02 260);

  --radius-sm: 0.375rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;

  --spacing-page: clamp(1rem, 2vw, 2rem);
}
```

Rules:

* Keep tokens in CSS variables.
* Use semantic tokens, not raw color names everywhere.
* Avoid giant custom Tailwind config unless needed.
* Prefer CSS variables for themes.
* Keep component class strings readable.
* Use `@utility` or component wrappers for repeated complex patterns.
* Use container queries when component layout depends on container width.
* Do not encode every one-off pixel as a token.

Bad:

```tsx
<div className="bg-blue-600 text-white border-blue-700">
```

Better:

```tsx
<div className="bg-primary text-primary-foreground">
```

---

## 4.12 Tailwind class hygiene

Rules:

* Sort classes consistently.
* Use `clsx`/`cn` helpers for conditional classes.
* Use `tailwind-merge` when consumer overrides should win.
* Use CVA or tailwind-variants for component variants.
* Do not concatenate arbitrary user input into class names.
* Avoid massive class strings in business components.
* Extract repeated UI patterns into components, not random CSS files.

Helper:

```ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export const cn = (...inputs: ClassValue[]) => {
  return twMerge(clsx(inputs));
};
```

CVA button:

```ts
import { cva, type VariantProps } from 'class-variance-authority';

export const buttonVariants = cva(
  [
    'inline-flex items-center justify-center gap-2',
    'rounded-md text-sm font-medium',
    'transition-colors',
    'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
    'disabled:pointer-events-none disabled:opacity-50',
  ],
  {
    variants: {
      variant: {
        primary: 'bg-primary text-primary-foreground hover:bg-primary/90',
        secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
      },
      size: {
        sm: 'h-8 px-3',
        md: 'h-10 px-4',
        lg: 'h-11 px-6',
        icon: 'size-10',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  },
);

export type ButtonVariantProps = VariantProps<typeof buttonVariants>;
```

Rule:

* Tailwind is not an excuse to make unreadable JSX.
* If class logic is complex, move it into variants.

---

## 4.13 Type-safe polymorphism

Prefer `asChild` over complex `as` generics.

Good:

```tsx
<Button asChild>
  <a href="/billing">Billing</a>
</Button>
```

Implementation with Radix Slot:

```tsx
import { Slot } from '@radix-ui/react-slot';

type ButtonProps = React.ComponentPropsWithoutRef<'button'> &
  ButtonVariantProps & {
    asChild?: boolean;
  };

export const Button = ({
  asChild = false,
  className,
  variant,
  size,
  ...props
}: ButtonProps) => {
  const Comp = asChild ? Slot : 'button';

  return (
    <Comp
      className={cn(buttonVariants({ variant, size }), className)}
      {...props}
    />
  );
};
```

Rules:

* Avoid generic polymorphic components unless building a library.
* Complex `as` typing can hurt readability and typecheck performance.
* `asChild` composes better with links, routers, and primitives.
* Do not allow invalid HTML silently.

---

## 4.14 React performance: diagnose before memoizing

Do not sprinkle `memo`, `useMemo`, and `useCallback`.

Optimize in this order:

1. move state down
2. split components
3. avoid unnecessary effects
4. reduce prop churn
5. virtualize large lists
6. code-split heavy screens
7. memoize only measured hot paths

Bad:

```tsx
const value = useMemo(() => ({ theme, user }), [theme, user]);
```

Maybe better:

```tsx
const value = { theme, user };
```

Actually better if context causes too many renders:

* split the context
* move state lower
* use selector-based store
* avoid putting frequently changing values in broad providers

Use `useMemo` for:

* expensive calculations
* stable values passed to memoized children
* provider values after context split is considered

Use `useCallback` for:

* callbacks passed to memoized children
* stable dependencies for custom hooks
* event handlers where identity matters

Do not use memoization:

* to hide bad state placement
* around cheap calculations
* everywhere by default
* when dependencies change every render

---

## 4.15 Context performance

Context re-renders all consumers when the provided value changes.

Bad:

```tsx
<AppContext.Provider value={{ user, theme, cart, notifications, setTheme }}>
  {children}
</AppContext.Provider>
```

Better:

```tsx
<UserProvider>
  <ThemeProvider>
    <CartProvider>
      {children}
    </CartProvider>
  </ThemeProvider>
</UserProvider>
```

Rules:

* Split context by change frequency.
* Do not put rapidly changing values in app-wide context.
* Memoizing provider value is not enough if the value truly changes often.
* Prefer local state for local concerns.
* Use selector stores for high-frequency shared state.

---

## 4.16 Effects cleanup

Most bad React code has too many effects.

Effects are for synchronizing with external systems:

* DOM APIs
* subscriptions
* timers
* analytics
* network requests when framework data layer is not available
* imperative libraries

Effects are not for:

* deriving state from props
* formatting data
* calculating filtered lists
* responding to button clicks
* copying props into state

Bad:

```tsx
const [fullName, setFullName] = useState('');

useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);
```

Better:

```tsx
const fullName = `${firstName} ${lastName}`;
```

Effect rules:

* every subscription has cleanup
* every timer is cleared
* every request that can outlive the component has cancellation/ignore logic
* do not suppress dependency lint without explanation
* prefer event handlers for user-triggered actions

---

## 4.17 Lists and virtualization

Use virtualization for large lists.

Candidates:

* 500+ rows
* complex row UI
* tables
* logs
* search results
* infinite feeds
* admin grids

Use:

* TanStack Virtual
* React Aria collections where appropriate
* framework/table virtualization integrations

Rules:

* Use stable keys from data IDs.
* Never use array index as key for reorderable/mutable lists.
* Keep row components small.
* Avoid inline heavy formatting in every row render.
* Memoize row data only after measuring.
* Avoid nesting interactive controls badly in virtual rows.
* Preserve accessibility where virtualization hides offscreen DOM.

Bad:

```tsx
{items.map((item, index) => (
  <Row key={index} item={item} />
))}
```

Better:

```tsx
{items.map((item) => (
  <Row key={item.id} item={item} />
))}
```

---

## 4.18 Images, fonts, and media

Rules:

* Always specify image dimensions or use a framework image component.
* Avoid layout shift.
* Do not ship massive hero images to mobile.
* Use responsive sizes.
* Lazy-load below-the-fold images.
* Preload only critical above-the-fold assets.
* Use modern formats when supported.
* Keep font count low.
* Avoid layout shift from late font loading.
* Do not autoplay heavy media by default.

Bad:

```tsx
<img src="/hero.png" />
```

Better:

```tsx
<Image
  src="/hero.png"
  width={1200}
  height={630}
  alt="Product dashboard"
  priority
/>
```

Rule:

* Empty `alt=""` is correct for decorative images.
* Meaningful images need meaningful alt text.
* Do not stuff alt text with SEO keywords.

---

## 4.19 Bundle hygiene

Common bundle killers:

* client importing server code
* importing full icon libraries
* importing date/chart/editor libraries into the main route
* barrel files
* giant schema libraries in client components
* one shared client provider wrapping the whole app
* marking entire layout as `'use client'`
* rich text editors loaded on every page
* analytics SDKs loaded too early

Rules:

* Keep `'use client'` as low as possible.
* Dynamic import rare/heavy UI.
* Analyze bundles before and after large dependencies.
* Prefer per-icon imports.
* Keep chart/editor/map components route-split.
* Do not import Node-only packages into client code.
* Avoid package root imports that pull everything.

Bad:

```tsx
'use client';

export default function RootLayout({ children }) {
  return <html><body>{children}</body></html>;
}
```

Better:

```tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <ThemeClientBoundary />
      </body>
    </html>
  );
}
```

---

## 4.20 Server/client boundary rules

Rules:

* Server components may import server code.
* Client components must not import server-only modules.
* Pass serializable props from server to client.
* Do not pass functions/classes/DB clients to client components.
* Keep interactive leaf components small.
* Move data fetching up to server when it improves payload and SEO.
* Do not client-fetch data that was already available on the server unless freshness requires it.

Bad:

```tsx
'use client';

import { db } from '@/server/db';
```

Better:

```tsx
// Server component
const user = await getUser();

return <UserMenuClient user={user} />;
```

---

## 4.21 Forms that users like

Good forms:

* preserve input
* show errors near fields
* explain what went wrong
* disable duplicate submit
* support keyboard submit
* show pending state
* do not wipe user input after server error
* validate important constraints before submit
* validate server constraints after submit
* focus first invalid field when appropriate

Rules:

* Use real `<form>`.
* Use `<button type="submit">`.
* Use labels.
* Connect errors with `aria-describedby`.
* Do not block paste.
* Do not over-format while typing.
* Do not validate on every keystroke if it creates noise.
* Use server validation as source of truth.

---

## 4.22 Loading, empty, and error states

Every data UI needs:

* loading state
* empty state
* error state
* success state
* refetch/pending state if applicable

Bad:

```tsx
if (!data) return null;
```

Better:

```tsx
if (query.isPending) return <UserSkeleton />;
if (query.isError) return <ErrorState retry={query.refetch} />;
if (query.data.length === 0) return <EmptyUsers />;

return <UserList users={query.data} />;
```

Rules:

* Skeletons should match final layout to avoid shift.
* Empty states should suggest next action.
* Error states should preserve context and allow retry.
* Do not use spinners for everything.
* Do not hide failure.

---

## 4.23 Design system rules

A good design system is boring, typed, accessible, and hard to misuse.

Rules:

* `shared/ui` components must be framework-compatible where possible.
* Components expose semantic variants, not raw style switches.
* Components forward refs when needed by primitives/forms.
* Components support `className` only where safe.
* Components have accessible defaults.
* Components document behavior, not just props.
* Do not add variants nobody uses.
* Delete dead variants.

Button example:

```tsx
type ButtonProps = React.ComponentPropsWithoutRef<'button'> &
  ButtonVariantProps & {
    asChild?: boolean;
    loading?: boolean;
  };

export const Button = ({
  asChild,
  loading,
  disabled,
  children,
  ...props
}: ButtonProps) => {
  const Comp = asChild ? Slot : 'button';

  return (
    <Comp
      disabled={!asChild ? disabled || loading : undefined}
      aria-disabled={asChild ? disabled || loading : undefined}
      {...props}
    >
      {loading ? <Spinner aria-hidden="true" /> : null}
      {children}
    </Comp>
  );
};
```

---

## 4.24 No AI slop UI

Reject UI code that has:

* random gradients everywhere
* unreadable contrast
* fake glassmorphism by default
* meaningless animation
* icons without labels
* duplicate spacing systems
* hardcoded colors instead of tokens
* div buttons
* no loading/error states
* over-generic components
* huge components named `Dashboard`
* mock data mixed with production code
* generated comments explaining obvious JSX
* placeholder buttons that do nothing
* inconsistent radius/shadow/spacing
* client-side everything
* arbitrary Tailwind values everywhere

AI-generated UI cleanup pass:

1. Replace raw colors with tokens.
2. Replace clickable divs with buttons/links.
3. Add labels and aria relationships.
4. Delete decorative clutter.
5. Add loading/error/empty states.
6. Split giant components.
7. Move mock data out.
8. Move client boundary down.
9. Run accessibility checks.
10. Test keyboard navigation.

---

## 4.25 React Doctor / automated UI diagnosis

Use React Doctor or similar static analysis as an extra reviewer, not as a replacement for judgment.

Use it for:

* anti-pattern discovery
* broad repo scans
* agent-generated React review
* repeated health checks after cleanup
* catching common performance/correctness issues

Example API shape:

```ts
import {
  diagnose,
  summarizeDiagnostics,
  toJsonReport,
} from 'react-doctor/api';

const result = await diagnose('./path/to/react-project', {
  lint: true,
  deadCode: true,
});

console.log(result.score);
console.log(summarizeDiagnostics(result));
console.log(toJsonReport(result));
```

Rules:

* Treat the score as a signal, not truth.
* Fix high-confidence correctness and accessibility findings first.
* Re-run after changes.
* Do not blindly apply generated patches.
* Keep human review for product behavior and UX.

---

## 4.26 Testing strategy

Use:

* Testing Library for behavior
* Playwright for real flows
* Axe or equivalent for accessibility checks
* Storybook for component states
* Chromatic/visual regression for design systems
* Vitest/Jest for logic and hooks
* Type tests for generic component APIs

Rules:

* Query by role/name first.
* Do not test implementation details.
* Do not snapshot huge component trees.
* Test loading/error/empty/success states.
* Test keyboard behavior for custom controls.
* Test focus behavior for dialogs/menus.
* Test forms with real user events.

Good:

```tsx
expect(
  screen.getByRole('button', { name: /save/i }),
).toBeEnabled();
```

Bad:

```tsx
expect(container.firstChild).toMatchSnapshot();
```

---

## 4.27 Cleanup playbooks

### Giant component cleanup

Symptoms:

* 300+ line component
* many `useState`
* many `useEffect`
* mixed fetching, formatting, validation, and rendering
* large JSX with repeated sections

Steps:

1. Extract pure display components.
2. Move data fetching to route/query layer.
3. Move form logic to form component/hook.
4. Replace derived state effects with direct derivation.
5. Split loading/error/empty states.
6. Add tests for visible behavior.
7. Delete dead props and branches.

### Slow page cleanup

Steps:

1. Run profiler/bundle analyzer.
2. Check if the whole route is client-side.
3. Move static sections to server/static.
4. Split heavy client widgets.
5. Remove barrel imports.
6. Dynamic import charts/editors/maps.
7. Virtualize large lists.
8. Fix image sizes.
9. Reduce context churn.
10. Re-measure.

### Accessibility cleanup

Steps:

1. Keyboard through the screen.
2. Check visible focus.
3. Check labels and names.
4. Check dialogs/menus/popovers.
5. Connect descriptions/errors.
6. Check contrast.
7. Run automated a11y scan.
8. Test with screen reader for critical flows.

### Tailwind cleanup

Steps:

1. Replace raw colors with tokens.
2. Move repeated variants to CVA/tailwind-variants.
3. Delete one-off arbitrary values.
4. Sort classes.
5. Replace style props with tokens/utilities.
6. Create semantic UI components for repeated patterns.
7. Keep layout classes near JSX.

### Query cleanup

Steps:

1. Centralize keys.
2. Validate API responses.
3. Remove duplicated local server state.
4. Set stale times intentionally.
5. Fix mutation invalidation.
6. Add error and empty states.
7. Delete fetch calls from components.

---

## 4.28 Performance review checklist

Before merging UI code, check:

* Is the route unnecessarily marked `'use client'`?
* Is data fetched on the client when server/static would work?
* Does the page have loading, error, empty, and success states?
* Does it use stable IDs for labels/errors/hints?
* Does it preserve keyboard navigation?
* Does it import heavy libraries into the main bundle?
* Does it use internal barrel imports?
* Does it render large lists without virtualization?
* Does it create derived state with effects?
* Does it put fast-changing values in broad context?
* Does it use random IDs or time-dependent server markup?
* Does it ship oversized images?
* Does it use raw Tailwind colors instead of tokens?
* Does it add arbitrary values everywhere?
* Does it add a dependency for a simple component?
* Does it hide errors with `return null`?
* Does it expose a 25-prop component API?
* Does it pass unvalidated API data into UI?

---

## 4.29 Anti-patterns to refuse

Refuse or strongly push back on:

* entire app/layout marked `'use client'`
* homemade accessible dialog/menu/combobox without expertise
* clickable `div`
* icon-only button without label
* random ID generation during render
* `useEffect` for derived state
* `useMemo`/`useCallback` everywhere by default
* index keys for mutable lists
* giant `components/`, `hooks/`, `utils/` folders
* fetch calls scattered inside components
* raw API JSON passed into UI
* global store for server state
* one mega context provider
* internal barrel files
* massive className strings with repeated variants
* hardcoded design values in product screens
* hidden empty/error states
* snapshot tests for full pages
* importing chart/editor/map libraries into the initial bundle
* treating React Doctor score as absolute truth
* shipping AI-generated UI without accessibility and performance cleanup

---

## 4.30 Escalation thresholds

| Symptom                              | Action                                              |
| ------------------------------------ | --------------------------------------------------- |
| Component >150 lines                 | Split display, data, and interaction concerns       |
| Component has >5 hooks               | Extract behavior or split ownership                 |
| Component has >20 props              | Move to composition/slots/compound API              |
| Entire route is client-side          | Push client boundary down                           |
| List >500 complex rows               | Virtualize                                          |
| Context value changes often          | Split context or move state down                    |
| Page lacks error/empty states        | Block merge until handled                           |
| Repeated query keys                  | Create query key factory                            |
| API data typed with `as`             | Add runtime schema/parser                           |
| Tailwind class string unreadable     | Extract variant/component                           |
| Bundle grows unexpectedly            | Run analyzer and inspect imports                    |
| Hydration mismatch appears           | audit IDs, time, random, browser-only logic         |
| Custom interactive primitive appears | replace with accessible primitive or prove behavior |

---

## 4.31 Source families

Use these when validating or updating this file:

* React docs
* Next.js rendering, caching, streaming, and PPR docs
* Remix docs when using Remix
* TanStack Query docs
* SWR docs
* Tailwind CSS v4 docs
* Radix UI docs
* React Aria docs
* shadcn/ui patterns
* CVA / tailwind-variants docs
* Testing Library docs
* Playwright docs
* axe accessibility tooling
* React Doctor docs
* Web.dev performance and Core Web Vitals guidance
