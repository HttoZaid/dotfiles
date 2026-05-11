
# Svelte / SvelteKit — Advanced SSR, State, Performance, Accessibility, and Cleanup

Use this file when the user is working on Svelte components, SvelteKit routes, load functions, form actions, stores, runes, SSR, hydration, accessibility, Tailwind styling, adapters, server/client boundaries, or app performance.

This is not beginner Svelte advice. Prefer explicit server/client ownership, resilient forms, small components, typed route data, native SvelteKit patterns, progressive enhancement, measurable performance, and deletion over framework cosplay.

---

## 1. Rule zero: Svelte is fast when ownership stays obvious

Svelte removes a lot of runtime overhead by compiling components, but it does not save bad architecture.

Most Svelte/SvelteKit problems come from:

- unclear server/client boundaries
- loading data in the wrong place
- global state leaking between users
- using `$effect` for derived state
- too much client JavaScript
- huge route components
- broken progressive enhancement
- inaccessible custom controls
- form logic scattered across components
- secrets accidentally imported into client code
- stores used as a junk drawer
- invalidation/refetch chaos
- hydration mismatches

Rule:
- Put data on the server when it belongs on the server.
- Put interaction in the client only where interaction is needed.
- Keep state as local as possible.
- Let HTML forms work before enhancing them.
- Use native SvelteKit routing/loading/actions before inventing an app framework.

---

## 2. Version and rune caveats

Svelte 5 introduced runes. Svelte 3/4 and Svelte 5 can look similar but have different state patterns.

Svelte 5 rule:
- Use `$state` only for values that should cause UI/effects/derived state to update.
- Use `$derived` for derived values.
- Use `$effect` for synchronization with external systems, not normal computation.
- Keep side effects out of `$derived`.

The official Svelte best-practices docs say to only use `$state` for variables that should be reactive — variables that cause `$effect`, `$derived`, or template expressions to update. ([svelte.dev](https://svelte.dev/docs/svelte/best-practices?utm_source=chatgpt.com))

Bad:

```svelte
<script lang="ts">
  let count = $state(0);
  let doubled = $state(0);

  $effect(() => {
    doubled = count * 2;
  });
</script>
````

Better:

```svelte
<script lang="ts">
  let count = $state(0);
  let doubled = $derived(count * 2);
</script>
```

Rule:

* `$effect` is not the new reactive statement for everything.
* `$derived` should be side-effect free. Svelte’s docs explicitly state that `$derived(...)` expressions should be free of side effects. ([svelte.dev](https://svelte.dev/docs/svelte/%24derived?utm_source=chatgpt.com))

---

## 3. Recommended project structure

Good SvelteKit structure:

```text
src/
  app.html
  hooks.server.ts
  lib/
    server/
      db/
      auth/
      email/
      repositories/
    components/
      ui/
      layout/
    features/
      users/
        user-card.svelte
        user-form.svelte
        user.schema.ts
        user.types.ts
        user.service.ts
      billing/
      dashboard/
    utils/
      format.ts
      guards.ts
    styles/
      app.css
  routes/
    +layout.server.ts
    +layout.svelte
    dashboard/
      +page.server.ts
      +page.svelte
    users/
      [id]/
        +page.server.ts
        +page.svelte
        edit/
          +page.server.ts
          +page.svelte
```

Rules:

* `src/lib/server/**` is for server-only code.
* `src/lib/components/ui/**` is for reusable design-system components.
* `src/lib/features/**` is for feature-owned UI, schemas, and client-safe helpers.
* `src/routes/**` composes route-level data and pages.
* Keep secrets, DB clients, filesystem access, and private SDKs in server-only files.
* Do not turn `src/lib` into a dumping ground.
* Do not put everything in `routes` if it is reusable feature logic.

Bad:

```text
src/
  components/
  stores/
  utils/
  services/
  types/
```

That structure hides ownership and becomes junk-drawer architecture.

---

## 4. Server/client boundary

**Rule:** Secrets, database clients, filesystem access, admin SDKs, and private environment variables stay server-side.

Use server-only modules for:

* database queries
* private API keys
* sessions/auth verification
* filesystem access
* payment provider secret calls
* email sending
* privileged operations
* admin SDKs

Use client/browser code for:

* user interaction
* animations
* browser APIs
* local component state
* optimistic UI
* client-only widgets

Bad:

```ts
// src/lib/api.ts
import { PRIVATE_API_KEY } from '$env/static/private';

export const callPrivateApi = async () => {
  // Later imported by +page.svelte accidentally.
};
```

Better:

```text
src/lib/server/private-api.ts
```

Rule:

* Anything under `src/lib/server` is protected from client imports by SvelteKit conventions.
* If a file can be imported by a `.svelte` component, assume it may enter the client bundle.
* Keep server-only names obvious.

---

## 5. Load function strategy

SvelteKit load functions are route data boundaries.

Use `+page.server.ts` / `+layout.server.ts` when:

* querying a database directly
* reading private environment variables
* using private SDKs
* reading cookies/session
* doing auth checks
* using filesystem
* calling internal services
* returning data that should be prepared server-side

SvelteKit docs say server `load` functions are convenient when accessing data directly from a database/filesystem or using private environment variables. ([svelte.dev](https://svelte.dev/docs/kit/load?utm_source=chatgpt.com))

Use universal `+page.ts` / `+layout.ts` when:

* data is safe to fetch in browser and server
* using public APIs
* logic truly works in both environments
* the code is client-safe

Use component-level fetch only when:

* data is needed after user interaction
* the data is not needed for initial render
* SEO does not matter
* route-level data would be wasteful

Bad:

```svelte
<script lang="ts">
  import { onMount } from 'svelte';

  let user = $state(null);

  onMount(async () => {
    user = await fetch('/api/user').then((r) => r.json());
  });
</script>
```

Better:

```ts
// +page.server.ts
export const load = async ({ locals }) => {
  const user = await locals.repositories.users.current();

  return { user };
};
```

```svelte
<script lang="ts">
  let { data } = $props();
</script>

<UserCard user={data.user} />
```

Rule:

* Load as early as possible at the route boundary when the data is needed for initial UI.

---

## 6. Layout load discipline

Layout load functions are powerful and dangerous.

Use layout load for:

* session/current user
* navigation data
* feature flags needed globally
* route group shared data
* app shell data

Do not use layout load for:

* page-specific heavy queries
* dashboard data for every route
* large lists
* data only one child page needs
* remote calls that slow all navigation

Bad:

```ts
// +layout.server.ts
export const load = async () => {
  return {
    users: await db.user.findMany(),
    orders: await db.order.findMany(),
    reports: await expensiveReports()
  };
};
```

Better:

* layout loads current user and nav
* page loads page-specific dashboard/report data

Rule:

* If a layout load slows unrelated pages, it is in the wrong place.

---

## 7. Streaming, waterfalls, and parallelism

Avoid sequential awaits when independent data can load in parallel.

Bad:

```ts
export const load = async () => {
  const user = await getUser();
  const orders = await getOrders();
  const notifications = await getNotifications();

  return { user, orders, notifications };
};
```

Better:

```ts
export const load = async () => {
  const [user, orders, notifications] = await Promise.all([
    getUser(),
    getOrders(),
    getNotifications()
  ]);

  return { user, orders, notifications };
};
```

Rules:

* Parallelize independent server calls.
* Keep dependent calls sequential only when required.
* Avoid client waterfalls caused by onMount fetch chains.
* Use parent layout data intentionally, not accidentally.
* Do not block the whole route on low-priority data if streaming/deferred patterns fit the app.

---

## 8. Forms and progressive enhancement

**Rule:** A SvelteKit form should work before JavaScript enhancement.

Use form actions for:

* login
* signup
* settings update
* create/edit/delete
* contact forms
* checkout steps
* admin actions
* mutations tied to route UI

SvelteKit docs state `use:enhance` works with `method="POST"` forms that point to actions defined in `+page.server.js`/`.ts`. ([svelte.dev](https://svelte.dev/docs/kit/form-actions?utm_source=chatgpt.com))

Server action:

```ts
// +page.server.ts
import { fail } from '@sveltejs/kit';

export const actions = {
  updateProfile: async ({ request, locals }) => {
    const formData = await request.formData();

    const name = String(formData.get('name') ?? '').trim();

    if (name.length < 2) {
      return fail(400, {
        values: { name },
        errors: { name: 'Name is too short' }
      });
    }

    await locals.repositories.users.updateProfile({ name });

    return { success: true };
  }
};
```

Page:

```svelte
<script lang="ts">
  import { enhance } from '$app/forms';

  let { form } = $props();
</script>

<form method="POST" action="?/updateProfile" use:enhance>
  <label for="name">Name</label>
  <input
    id="name"
    name="name"
    value={form?.values?.name ?? ''}
    aria-invalid={form?.errors?.name ? 'true' : undefined}
    aria-describedby={form?.errors?.name ? 'name-error' : undefined}
  />

  {#if form?.errors?.name}
    <p id="name-error">{form.errors.name}</p>
  {/if}

  <button type="submit">Save</button>
</form>
```

Rules:

* Use real `<form method="POST">`.
* Keep server validation as source of truth.
* Return values/errors so users do not lose input.
* Use `use:enhance` after non-JS behavior works.
* Do not submit important mutations only through client fetch.
* Disable duplicate submit when needed.
* Show pending state.
* Focus or announce errors for accessible UX.

The Svelte tutorial emphasizes that ordinary forms work even when users do not have JavaScript, then `use:enhance` can improve the experience. ([svelte.dev](https://svelte.dev/tutorial/kit/progressive-enhancement?utm_source=chatgpt.com))

---

## 9. Validation and type safety

TypeScript types do not validate request data.

Validate:

* form data
* URL params
* search params
* cookies
* session data
* external API responses
* database results if weakly typed
* webhook bodies
* JSON request bodies

Use:

* Zod
* Valibot
* ArkType
* Superforms
* custom parsers

Bad:

```ts
const age = Number(formData.get('age'));
await saveAge(age);
```

Better:

```ts
const raw = {
  age: formData.get('age')
};

const parsed = AgeSchema.safeParse(raw);

if (!parsed.success) {
  return fail(400, {
    errors: parsed.error.flatten().fieldErrors
  });
}

await saveAge(parsed.data.age);
```

Rules:

* Validate at the server boundary.
* Convert to domain types early.
* Do not trust client-side validation.
* Keep schemas near feature/model boundary.
* Return typed, user-safe error messages.

---

## 10. Route params and search params

Rules:

* Validate route params in load/actions.
* Do not assume `[id]` is valid.
* Use param matchers for reusable constraints.
* Validate search params before using them in queries.
* Normalize pagination/filter params.
* Avoid passing raw search params into repositories.

Bad:

```ts
export const load = async ({ params }) => {
  return {
    user: await getUser(params.id)
  };
};
```

Better:

```ts
export const load = async ({ params, error }) => {
  const userId = UserIdSchema.safeParse(params.id);

  if (!userId.success) {
    error(404, 'User not found');
  }

  const user = await getUser(userId.data);

  if (!user) {
    error(404, 'User not found');
  }

  return { user };
};
```

---

## 11. State ownership

State should live at the smallest scope that needs it.

Local component state:

* input draft
* modal open
* tabs
* hover/focus details
* local filters before submit
* animation flags

Route data:

* server-loaded page data
* auth/session data
* initial page state
* SEO-critical data

Global state:

* theme
* client-only app preferences
* small shared UI state
* data that truly crosses unrelated routes

Rules:

* Do not put route data into a global store just because many components read it.
* Pass route data down through props when ownership is clear.
* Use context for tree-scoped dependencies.
* Use stores/runes modules for genuine shared client state.
* Avoid server-user data in module-level mutable state.

---

## 12. Global state and SSR safety

SvelteKit is isomorphic: code can run on server and client. Module-level state can leak between users on the server.

Bad:

```ts
// src/lib/current-user.ts
export let currentUser = $state<User | null>(null);
```

This can become dangerous if imported server-side.

Better:

* keep request user in `event.locals`
* pass user through load data
* use client state only for client-only preferences
* create per-request objects inside load/actions/hooks

Rules:

* Never store request-specific data in module-level variables.
* Never store auth/session data in global client-ish modules server-side.
* Treat shared modules as potentially long-lived.
* Keep server state per request.

Community Svelte 5 guidance also warns that global state is especially risky in isomorphic apps that run on both server and client. ([mainmatter.com](https://mainmatter.com/blog/2025/03/11/global-state-in-svelte-5/?utm_source=chatgpt.com))

---

## 13. Stores vs runes

Use local runes for:

* component-local state
* local derived state
* feature-local state in `.svelte.ts` modules when appropriate

Use stores when:

* interoperating with older Svelte code
* using store ecosystem APIs
* representing streams/subscriptions
* sharing reactive values across non-rune-compatible boundaries

Rules:

* Do not use stores for everything by habit.
* Do not create global stores for route data.
* Keep writable stores private; expose read/update methods.
* Avoid exporting a raw writable store from a feature module unless the app is tiny.

Bad:

```ts
export const user = writable<User | null>(null);
```

Better:

```ts
const user = writable<User | null>(null);

export const userStore = {
  subscribe: user.subscribe,
  setFromSession: (value: User | null) => user.set(value),
  clear: () => user.set(null)
};
```

---

## 14. `$effect` discipline

Use `$effect` for:

* DOM/browser API synchronization
* subscriptions
* timers
* analytics
* imperative third-party libraries
* localStorage synchronization
* cleanup-required side effects

Do not use `$effect` for:

* derived values
* formatting data
* copying props to state
* normal calculations
* replacing load functions
* firing server mutations by accident

Bad:

```svelte
<script lang="ts">
  let { items } = $props();

  let total = $state(0);

  $effect(() => {
    total = items.reduce((sum, item) => sum + item.price, 0);
  });
</script>
```

Better:

```svelte
<script lang="ts">
  let { items } = $props();

  let total = $derived(
    items.reduce((sum, item) => sum + item.price, 0)
  );
</script>
```

Effect cleanup:

```svelte
<script lang="ts">
  $effect(() => {
    const id = setInterval(tick, 1000);

    return () => {
      clearInterval(id);
    };
  });
</script>
```

Rules:

* Every subscription/timer/listener needs cleanup.
* Do not suppress effect warnings without reason.
* If `$effect` mutates state, ask whether `$derived` is correct instead.

---

## 15. Component API design

Good Svelte components have small, obvious props and predictable slots/snippets.

Rules:

* Prefer explicit props for simple components.
* Use snippets/slots for composition.
* Avoid 30-prop components.
* Avoid boolean prop explosions.
* Keep styling variants typed.
* Expose events/callbacks intentionally.
* Do not hide too much markup in generic components.
* Keep accessibility wired inside reusable components.

Bad:

```svelte
<Card
  showHeader={true}
  showFooter={true}
  headerIcon="user"
  footerButtonText="Save"
  compact={true}
  bordered={true}
/>
```

Better:

```svelte
<Card>
  {#snippet header()}
    <CardTitle>Profile</CardTitle>
  {/snippet}

  <ProfileForm />

  {#snippet footer()}
    <Button type="submit">Save</Button>
  {/snippet}
</Card>
```

Rule:

* If a component has many props controlling markup, it probably wants composition.

---

## 16. Accessibility

Svelte warns about many accessibility mistakes at compile time. Svelte’s compiler warnings docs say it warns about potential mistakes such as inaccessible markup, while noting some warnings can be false positives. ([svelte.dev](https://svelte.dev/docs/svelte/compiler-warnings?utm_source=chatgpt.com))

Minimum:

* use semantic HTML
* real buttons for actions
* real links for navigation
* labels for inputs
* visible focus
* keyboard support
* correct heading order
* alt text for meaningful images
* empty alt for decorative images
* error messages connected to fields
* dialogs trap/restore focus
* no color-only meaning

Bad:

```svelte
<div onclick={save}>Save</div>
```

Better:

```svelte
<button type="button" onclick={save}>Save</button>
```

Form field:

```svelte
<script lang="ts">
  const id = $props.id ?? 'email';
</script>

<label for={id}>Email</label>
<input
  {id}
  name="email"
  aria-describedby={`${id}-hint`}
/>
<p id={`${id}-hint`}>Use your work email.</p>
```

Rules:

* Do not silence a11y warnings casually.
* If using `svelte-ignore`, explain why.
* Test keyboard navigation manually.
* Use axe/Playwright accessibility checks for critical flows.
* Compiler warnings are not full accessibility testing.

---

## 17. Styling and Tailwind

Rules:

* Use component-scoped CSS for local component styling.
* Use Tailwind for utility-first product UI if the project standardizes on it.
* Use design tokens for colors/spacing/radius.
* Do not scatter raw colors everywhere.
* Avoid giant unreadable class strings.
* Extract reusable UI components when patterns repeat.
* Keep global CSS small.
* Prefer semantic classes/tokens for design-system primitives.

Tailwind component helper:

```ts
// src/lib/utils/cn.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export const cn = (...inputs: ClassValue[]) => twMerge(clsx(inputs));
```

Variant helper:

```ts
import { tv, type VariantProps } from 'tailwind-variants';

export const button = tv({
  base: 'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50',
  variants: {
    variant: {
      primary: 'bg-primary text-primary-foreground hover:bg-primary/90',
      ghost: 'hover:bg-accent hover:text-accent-foreground',
      destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90'
    },
    size: {
      sm: 'h-8 px-3',
      md: 'h-10 px-4',
      icon: 'size-10'
    }
  },
  defaultVariants: {
    variant: 'primary',
    size: 'md'
  }
});

export type ButtonVariants = VariantProps<typeof button>;
```

Rules:

* Tailwind should not make components unreadable.
* Use tokens, not random values everywhere.
* Keep variants centralized for shared UI.

---

## 18. Performance model

Svelte is usually fast, but apps get slow from:

* too much client JavaScript
* loading data too late
* request waterfalls
* huge route components
* large lists without virtualization
* expensive derived calculations
* unnecessary global invalidation
* oversized images
* heavy third-party libraries
* repeated remote calls
* unbounded form/action work
* blocking server load functions
* slow database queries
* too much data returned from load

Optimize in this order:

1. move work to server/static where appropriate
2. reduce payload/data size
3. remove request waterfalls
4. split heavy client components
5. lazy-load rare/heavy widgets
6. virtualize large lists
7. cache safe expensive reads
8. reduce derived recomputation
9. profile before micro-optimizing

Rule:

* A Svelte app can still be slow if the data strategy is bad.

---

## 19. Client bundle hygiene

Rules:

* Keep browser-only dependencies out of server code.
* Keep server-only dependencies out of client code.
* Avoid importing heavy libraries in top-level layouts.
* Dynamically import charts/editors/maps.
* Avoid giant icon packs.
* Avoid shipping schema libraries to the client unless needed.
* Keep route-level JS small.
* Analyze bundles when adding large packages.

Bad:

```svelte
<script lang="ts">
  import HeavyChart from '$lib/components/heavy-chart.svelte';
</script>

<HeavyChart />
```

Better for rare widgets:

```svelte
<script lang="ts">
  let Chart = $state<typeof import('$lib/components/heavy-chart.svelte').default | null>(null);

  async function showChart() {
    Chart = (await import('$lib/components/heavy-chart.svelte')).default;
  }
</script>

<button onclick={showChart}>Show chart</button>

{#if Chart}
  <Chart />
{/if}
```

Rule:

* Do not load a chart/editor/map on routes that do not need it.

---

## 20. Lists and large data

Rules:

* Do not render thousands of complex rows directly.
* Paginate server data.
* Use infinite scroll carefully.
* Use virtualization for large client-side lists.
* Keep row components small.
* Use stable IDs as keys.
* Avoid expensive formatting in each row render.
* Precompute display data on server when appropriate.
* Do not return giant lists from load by default.

Bad:

```svelte
{#each users as user}
  <UserRow {user} />
{/each}
```

Better:

```svelte
{#each users as user (user.id)}
  <UserRow {user} />
{/each}
```

For huge lists:

* paginate
* virtualize
* chunk
* search/filter server-side

---

## 21. Images and assets

Rules:

* Specify dimensions.
* Use responsive images.
* Do not ship giant desktop images to mobile.
* Lazy-load below-the-fold images.
* Preload only critical assets.
* Use optimized image pipelines when available.
* Keep fonts limited.
* Avoid layout shift from late-loading media.
* Use meaningful alt text.

Bad:

```svelte
<img src="/hero.png">
```

Better:

```svelte
<img
  src="/hero.webp"
  width="1200"
  height="630"
  alt="Product dashboard"
/>
```

Rules:

* Decorative images use `alt=""`.
* Meaningful images need useful alt text.
* Do not keyword-stuff alt text.

---

## 22. Invalidation and refresh

Rules:

* Invalidate the smallest data dependency.
* Do not call `invalidateAll()` by default.
* After form actions, rely on SvelteKit behavior where suitable.
* Use targeted invalidation for client-side mutations.
* Avoid refetch storms.
* Keep cache keys/data dependencies clear.
* Do not duplicate server data into stores and then fight invalidation.

Bad:

```ts
await invalidateAll();
```

Better:

```ts
await invalidate('/api/orders');
```

or update data through route/action patterns.

Rule:

* If every mutation refetches the entire app, data ownership is unclear.

---

## 23. Auth and sessions

Rules:

* Auth/session verification belongs server-side.
* Store request-specific user/session in `locals`.
* Do not expose secrets in load data.
* Return only the safe user fields needed by UI.
* Protect server routes/actions.
* Redirect unauthenticated users in server load/actions.
* Do not rely on client-side route guards for security.

Hook pattern:

```ts
// hooks.server.ts
export const handle = async ({ event, resolve }) => {
  const session = await getSessionFromCookies(event.cookies);

  event.locals.user = session ? await getUser(session.userId) : null;

  return resolve(event);
};
```

Protected route:

```ts
// +page.server.ts
import { redirect } from '@sveltejs/kit';

export const load = async ({ locals }) => {
  if (!locals.user) {
    redirect(303, '/login');
  }

  return {
    user: {
      id: locals.user.id,
      name: locals.user.name
    }
  };
};
```

Rules:

* Client-side checks are UX, not security.
* Server load/actions enforce access.

---

## 24. Hooks

Use `hooks.server.ts` for:

* session setup
* request IDs
* logging context
* security headers
* route-level instrumentation
* global request handling

Do not use hooks for:

* page-specific data
* expensive queries for every route
* random business logic
* work only one route needs

Rules:

* Keep hooks fast.
* Avoid remote calls on every request unless essential.
* Add timing/logging carefully.
* Do not mutate global state.

---

## 25. Error handling

Rules:

* Use SvelteKit `error()` for route errors.
* Use `fail()` for form validation failures.
* Use redirects intentionally.
* Do not expose raw exception messages.
* Log server errors centrally.
* Return user-safe messages.
* Keep expected failures typed/structured.
* Add `+error.svelte` for good UX.

Bad:

```ts
catch (e) {
  return { error: String(e) };
}
```

Better:

```ts
catch (error) {
  logger.error('profile update failed', { error });

  return fail(500, {
    message: 'Could not update your profile. Try again.'
  });
}
```

Rule:

* User messages and log messages are different things.

---

## 26. Logging and observability

Rules:

* Add request IDs.
* Log server-side errors centrally.
* Do not log secrets/cookies/tokens.
* Log route/action failures with context.
* Track latency for server loads/actions/API routes.
* Track form failure rates for important flows.
* Track client errors separately.
* Track performance regressions by route.

Good server logging context:

* route ID
* request ID
* user ID if safe/internal
* action name
* duration
* error type
* status

Bad:

* full cookies
* raw form data with passwords
* entire request bodies
* stack traces shown to users

---

## 27. Testing strategy

Use:

* Vitest for unit tests
* Playwright for end-to-end flows
* Testing Library for component behavior where useful
* axe/accessibility checks for critical screens
* typechecking with `svelte-check`
* adapter/build tests for deployment confidence

Rules:

* Test form actions.
* Test validation failures.
* Test redirects/auth guards.
* Test load functions with mocked locals.
* Test keyboard behavior for custom controls.
* Test no-JS form fallback for critical forms.
* Do not snapshot huge pages.
* Do not test generated DOM implementation details unless necessary.

Commands:

```bash
npm run check
npm run test
npm run test:e2e
```

CI should include:

```bash
svelte-check
vitest run
playwright test
npm run build
```

---

## 28. `svelte-check` and linting

Rules:

* Run `svelte-check` in CI.
* Treat Svelte compiler warnings seriously.
* Use ESLint/Prettier with Svelte plugins.
* Do not ignore a11y warnings without reason.
* Keep TypeScript strict.
* Use generated `$types` from SvelteKit.
* Do not manually duplicate route data types.

Typical scripts:

```json
{
  "scripts": {
    "check": "svelte-kit sync && svelte-check --tsconfig ./tsconfig.json",
    "lint": "prettier --check . && eslint .",
    "format": "prettier --write .",
    "test": "vitest run",
    "test:e2e": "playwright test"
  }
}
```

---

## 29. Deployment and adapters

Rules:

* Choose adapter based on hosting/runtime, not trend.
* Know whether the route runs serverless, edge, Node, or static.
* Do not use Node-only APIs on edge/static targets.
* Do not assume filesystem writes work in serverless.
* Keep environment variable handling deployment-aware.
* Test production build locally where possible.
* Watch cold starts if serverless.
* Watch cache behavior if CDN/static.

Static adapter:

* good for static sites
* not for runtime auth-heavy dashboards unless designed around APIs

Node adapter:

* good for long-running Node server
* easier server-side integrations

Edge/serverless:

* fast global latency potential
* stricter runtime limitations
* cold start/runtime caveats

---

## 30. Cleanup playbooks

### Giant route cleanup

Symptoms:

* 300+ line `+page.svelte`
* load/fetch/form/render all mixed
* many local states
* repeated UI sections
* difficult to test

Steps:

1. Move data fetching to `+page.server.ts` or `+page.ts`.
2. Move mutations to form actions.
3. Extract display components.
4. Extract form component.
5. Move feature helpers to `src/lib/features/<feature>`.
6. Replace derived `$effect` with `$derived`.
7. Add loading/error/empty states.
8. Add tests for route behavior.
9. Delete dead state and props.

### Bad data loading cleanup

Steps:

1. List all data sources.
2. Mark server-only vs public.
3. Move private data to server load.
4. Parallelize independent calls.
5. Remove client waterfalls.
6. Add validation for params/search/form.
7. Return only needed fields.
8. Add caching if safe.
9. Re-measure.

### Global state cleanup

Steps:

1. List every store/global module.
2. Mark request-specific, route-specific, local, or truly global.
3. Move request-specific state to `locals/load`.
4. Move route-specific data to route data.
5. Move local state into components.
6. Expose read-only store APIs.
7. Delete stores that only mirror route data.

### Form cleanup

Steps:

1. Make the form work without JavaScript.
2. Add server action.
3. Validate server-side.
4. Return values/errors.
5. Connect errors to fields.
6. Add `use:enhance`.
7. Add pending/success state.
8. Test no-JS and enhanced paths.

### Accessibility cleanup

Steps:

1. Run `svelte-check`.
2. Fix semantic HTML.
3. Replace clickable divs.
4. Add labels.
5. Connect errors/hints.
6. Test keyboard navigation.
7. Add Playwright/axe checks for critical flows.
8. Only then add custom ARIA if needed.

---

## 31. Performance review checklist

Before merging Svelte/SvelteKit code, check:

* Does this load private data only on the server?
* Does this import server-only code into client code?
* Does this create global request-specific state?
* Does this fetch initial route data in `onMount` unnecessarily?
* Does this create sequential waterfalls?
* Does this return too much data from load?
* Does this use form actions for mutations?
* Does this work without JavaScript where appropriate?
* Does this validate route params/search params/form data?
* Does this use `$derived` instead of `$effect` for computed state?
* Does every `$effect` have a real side-effect reason?
* Does this render a huge list without pagination/virtualization?
* Does this load heavy libraries into initial bundle?
* Does this preserve accessibility?
* Does this pass `svelte-check`?
* Does this leak secrets into client bundle?
* Does this use `invalidateAll()` unnecessarily?
* Does this have loading/error/empty states?

---

## 32. Anti-patterns to refuse

Refuse or strongly push back on:

* secrets/private env imported into client-safe files
* database calls from `.svelte` components
* auth enforced only client-side
* `onMount` fetch for SEO/initial route data
* module-level mutable request/user state
* global stores for route data
* `$effect` used for derived values
* no-JS form behavior broken for important forms
* form mutations handled only by client fetch
* `invalidateAll()` after every mutation
* raw `params.id` passed to DB
* unvalidated `formData`
* clickable `div`
* silenced a11y warnings with no explanation
* giant `+page.svelte` files
* all feature code dumped into `src/lib/utils`
* heavy chart/editor/map imports in top-level routes
* returning full database rows to the client
* logging raw cookies/tokens/form payloads
* assuming adapter/runtime supports Node APIs
* ignoring `svelte-check`

---

## 33. Escalation thresholds

| Symptom                                   | Action                                          |
| ----------------------------------------- | ----------------------------------------------- |
| `+page.svelte` >150 lines                 | Split display, form, and route concerns         |
| `+layout.server.ts` slows unrelated pages | Move data to page load                          |
| Initial data fetched in `onMount`         | Move to load unless interaction-only            |
| Global store contains user/session        | Move to `locals` and load data                  |
| `$effect` writes derived state            | Replace with `$derived`                         |
| Route returns huge list                   | Paginate, filter server-side, or virtualize     |
| Form requires JS for core submit          | Add server action/progressive enhancement       |
| Repeated `invalidateAll()`                | Use targeted invalidation or action result flow |
| Heavy dependency added to common layout   | Dynamic import or route-split                   |
| Accessibility warning ignored             | Require explanation and manual test             |
| Server-only dependency in client bundle   | Move to `src/lib/server`                        |
| Auth guard only in component              | Enforce in server load/action                   |

---

## 34. Source families

Use these when validating or updating this file:

* Svelte docs
* Svelte best practices docs
* SvelteKit load docs
* SvelteKit form actions docs
* SvelteKit routing docs
* SvelteKit hooks docs
* SvelteKit adapter docs
* Svelte compiler warnings and accessibility docs
* SvelteKit tutorial on progressive enhancement
* TypeScript docs
* Playwright docs
* Vitest docs
* Testing Library docs
* Tailwind CSS docs when styling uses Tailwind
* Hosting adapter docs for the project runtime

