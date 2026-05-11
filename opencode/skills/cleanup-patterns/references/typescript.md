
# TypeScript — Advanced Type Safety, Performance, and Cleanup

Use this file when the user is working on TypeScript architecture, type safety, strictness, runtime validation, monorepo performance, dead code, package hygiene, async correctness, or refactoring messy TS code.

This is not beginner TypeScript advice. Prefer strict compiler feedback, small explicit boundaries, runtime validation at trust edges, and deletion over clever type gymnastics.

---

## 3.1 Rule zero: TypeScript is not runtime safety

**Rule:** TypeScript proves facts about code before runtime. It does not validate JSON, database rows, forms, webhooks, environment variables, localStorage, URL params, or third-party API responses.

Every external value enters as `unknown`.

Trust boundary examples:
- `JSON.parse`
- `fetch().json()`
- request bodies
- form data
- environment variables
- database query results from weakly typed clients
- `localStorage`
- `postMessage`
- webhooks
- URL params
- feature flags
- config files
- CLI args

Bad:

```ts
const user = await response.json() as User;
````

Better:

```ts
const raw: unknown = await response.json();
const parsed = UserSchema.safeParse(raw);

if (!parsed.success) {
  return err({ type: 'parse', issues: parsed.error.issues });
}

return ok(parsed.data);
```

Use Zod, Valibot, ArkType, io-ts, or a local parser. The library matters less than the rule: **validate at boundaries, then keep the inside typed**.

---

## 3.2 Compiler config — strict is the floor

**Rule:** New TypeScript projects use `strict: true`. Mature projects move toward strictness one flag at a time.

Recommended baseline:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noPropertyAccessFromIndexSignature": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "allowUnreachableCode": false,
    "allowUnusedLabels": false,
    "isolatedModules": true,
    "verbatimModuleSyntax": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "skipLibCheck": true
  }
}
```

Important flags:

* `strict`: enables the important type-safety family.
* `noUncheckedIndexedAccess`: `arr[0]` and dictionary access become possibly `undefined`.
* `exactOptionalPropertyTypes`: `foo?: string` is not the same as `foo: string | undefined`.
* `verbatimModuleSyntax`: forces explicit type-only imports and reduces module side-effect surprises.
* `isolatedModules`: keeps code compatible with single-file transpilers.
* `noPropertyAccessFromIndexSignature`: makes dynamic access obvious.
* `noImplicitReturns`: catches missing branch returns.
* `noFallthroughCasesInSwitch`: blocks accidental switch fallthrough.

Official TypeScript docs describe compiler options and project references as the mechanism for stronger checking and scalable project structure. Project references can improve build/editor times by splitting programs into smaller pieces. ([TypeScript][1])

Migration rule:

1. Turn on one flag.
2. Fix real bugs first.
3. Add narrow helper functions.
4. Avoid `as` carpet-bombing.
5. Commit each flag separately.

---

## 3.3 `skipLibCheck` is acceptable, but know what it means

`skipLibCheck: true` skips checking declaration files. It often improves build speed and avoids third-party declaration noise.

Use it when:

* app code is still fully checked
* CI needs reasonable speed
* dependency type conflicts are not worth blocking product code

Do not use it as an excuse to:

* ignore errors in your own `.d.ts`
* ship broken internal packages
* avoid fixing bad public package types

Rule: `skipLibCheck` is a performance compromise, not a type-safety philosophy.

---

## 3.4 Type performance matters

TypeScript can become slow because of type-level complexity, not runtime code.

Common type-checker killers:

* giant recursive conditional types
* huge unions generated from data
* deeply nested mapped types
* template literal types over large unions
* excessive `as const` on massive objects
* giant inferred return types from factory functions
* barrel files that force loading too many modules
* project-wide imports from mega `index.ts`
* monorepos without project boundaries

Rules:

* Prefer named exported types at module boundaries.
* Avoid exposing monstrous inferred types.
* Break huge union types by domain.
* Avoid type-level programming unless the public API earns it.
* Do not make the compiler compute what a small explicit type can say.
* Use `tsc --extendedDiagnostics` when typecheck becomes slow.

Diagnostic command:

```bash
tsc --noEmit --extendedDiagnostics
```

If one type alias needs a paragraph to explain it, it needs a name, tests, and probably simplification.

---

## 3.5 Type-level cleverness budget

**Rule:** Advanced types are production code. They need readability discipline.

Allowed:

* small generics that preserve input/output relationships
* discriminated unions
* branded types at boundaries
* utility types with clear names
* conditional types in reusable libraries

Suspicious:

* `infer` chains
* recursive conditional types
* template literal type parsers
* generic parameter lists over 4 items
* types that require `as any` at call sites
* types that make error messages unreadable

Bad:

```ts
type Magic<T> = T extends (...args: infer A) => infer R
  ? A extends [infer F, ...infer Rest]
    ? Rest extends unknown[]
      ? SomeOtherMagic<F, R, Rest>
      : never
    : never
  : never;
```

Better:

* name each step
* add comments
* add type tests
* use overloads if simpler
* accept a tiny runtime helper

Rule: If the clever type makes normal feature work slower, delete it.

---

## 3.6 Prefer `unknown` over `any`

`any` disables checking. `unknown` forces narrowing.

Bad:

```ts
const handle = (payload: any) => {
  return payload.user.profile.name.toLowerCase();
};
```

Better:

```ts
const handle = (payload: unknown) => {
  const parsed = PayloadSchema.safeParse(payload);

  if (!parsed.success) {
    return err({ type: 'invalid_payload' });
  }

  return ok(parsed.data.user.profile.name.toLowerCase());
};
```

Legitimate `any` cases:

* generic function constraints like `(...args: any[]) => any`
* test mocks in contained zones
* compatibility wrappers around badly typed third-party code

Rules:

* Never return `any` from domain code.
* Never accept `any` at a trust boundary.
* Quarantine unavoidable `any` in one file.
* Comment why it exists.

---

## 3.7 Use `satisfies`, not `as`, for config

Bad:

```ts
const routes = {
  home: '/',
  user: '/users/:id',
} as Record<string, string>;
```

This erases useful literal information.

Better:

```ts
const routes = {
  home: '/',
  user: '/users/:id',
} satisfies Record<string, string>;
```

Rules:

* `satisfies` checks compatibility without widening the value.
* `as` should be rare and local.
* `as unknown as X` is a smell.
* `as const` is useful for small literal maps, dangerous for huge data blobs.

Use `satisfies` for:

* route maps
* config objects
* design token maps
* permission tables
* reducer/action registries
* framework config

---

## 3.8 Discriminated unions — the highest-leverage pattern

Use discriminated unions for state, workflows, domain variants, and async status.

```ts
type LoadState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: AppError };
```

Render:

```ts
const renderUser = (state: LoadState<User>) => {
  switch (state.status) {
    case 'idle':
      return null;

    case 'loading':
      return <Spinner />;

    case 'success':
      return <UserCard user={state.data} />;

    case 'error':
      return <ErrorBox error={state.error} />;

    default: {
      const exhaustive: never = state;
      return exhaustive;
    }
  }
};
```

Rules:

* Discriminate before destructuring.
* Use one clear discriminant: `type`, `kind`, `status`, or `tag`.
* Keep variant payloads specific.
* Do not model state with many nullable fields.

Bad:

```ts
type State = {
  loading: boolean;
  data?: User;
  error?: Error;
};
```

This allows impossible states.

Better:

```ts
type State =
  | { status: 'loading' }
  | { status: 'success'; data: User }
  | { status: 'error'; error: Error };
```

`@typescript-eslint/switch-exhaustiveness-check` reports missing cases for unions/enums, which makes this pattern enforceable in lint. ([typescript-eslint.io][2])

---

## 3.9 Result types for expected failures

**Rule:** Throw for programmer errors. Return `Result` for expected failures.

Expected:

* validation failed
* not found
* unauthorized
* conflict
* network unavailable
* parse failed
* permission denied
* rate limited

Unexpected:

* invariant violation
* impossible branch
* programmer error

Example with `neverthrow`:

```ts
import { err, ok, ResultAsync } from 'neverthrow';

type UserError =
  | { type: 'not_found' }
  | { type: 'network'; cause: unknown }
  | { type: 'parse'; issues: unknown };

const getUser = (id: UserId): ResultAsync<User, UserError> =>
  ResultAsync.fromPromise(
    fetch(`/api/users/${id}`).then((response) => response.json() as Promise<unknown>),
    (cause): UserError => ({ type: 'network', cause }),
  ).andThen((raw) => {
    const parsed = UserSchema.safeParse(raw);

    return parsed.success
      ? ok(parsed.data)
      : err({ type: 'parse', issues: parsed.error.issues });
  });
```

Rules:

* Wrap throwing third-party libraries at boundaries.
* Do not throw for normal business outcomes.
* Do not return `null` for five different failure types.
* Keep error unions stable and explicit.
* Add linting if the repo standardizes on Result handling.

---

## 3.10 Async correctness

Async bugs in TS are often invisible until production.

Must-have lint rules:

* `@typescript-eslint/no-floating-promises`
* `@typescript-eslint/no-misused-promises`
* `@typescript-eslint/await-thenable`
* `@typescript-eslint/require-await`
* `@typescript-eslint/return-await` with team-chosen style

`no-floating-promises` reports promises that are not awaited, returned, caught, or explicitly ignored with `void`; the rule exists because unhandled promises can cause ignored rejections and improperly sequenced logic. ([typescript-eslint.io][3])

Bad:

```ts
saveUser(user);
navigate('/done');
```

Better:

```ts
await saveUser(user);
navigate('/done');
```

Allowed fire-and-forget:

```ts
void analytics.track('signup_completed').catch(reportAnalyticsError);
```

Rules:

* Fire-and-forget must be explicit with `void`.
* Async event handlers must handle failures.
* Never use `Array.prototype.forEach` with async callbacks when sequencing matters.
* Use `Promise.all` for parallel work.
* Use `Promise.allSettled` when partial failure is valid.
* Use cancellation/abort signals for requests that can outlive a screen/request.

Bad:

```ts
items.forEach(async (item) => {
  await saveItem(item);
});
```

Better:

```ts
await Promise.all(items.map(saveItem));
```

---

## 3.11 Runtime validation strategy

Validate once at the boundary, not everywhere.

Boundary parser:

```ts
const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;

const parseUser = (value: unknown): Result<User, ParseError> => {
  const parsed = UserSchema.safeParse(value);

  return parsed.success
    ? ok(parsed.data)
    : err({ type: 'parse_error', issues: parsed.error.issues });
};
```

Rules:

* `parseX` returns typed domain data or typed error.
* UI components should not parse raw API payloads.
* Repositories/adapters own conversion from unknown to domain.
* Never scatter `z.object(...)` definitions across random components.
* Keep schemas near boundary code or domain model code, not inside event handlers.

For high-throughput backend paths:

* avoid validating the same object repeatedly
* parse at ingress
* trust internal typed values afterward
* benchmark heavy schema libraries if parsing thousands of objects per request

---

## 3.12 Branded types for domain safety

Use brands when two values share the same primitive type but must not be mixed.

```ts
type Brand<T, Name extends string> = T & { readonly __brand: Name };

type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;

const UserIdSchema = z.string().uuid().transform((value) => value as UserId);
```

Rules:

* Brand IDs, currencies, sanitized HTML, slugs, and validated paths.
* Do not brand every string.
* Provide constructors/parsers.
* Never cast random strings at call sites.

Bad:

```ts
getOrders(orderId as unknown as UserId);
```

Better:

```ts
const parsed = UserIdSchema.safeParse(rawId);
```

---

## 3.13 Data modeling: make illegal states impossible

Bad:

```ts
type Payment = {
  status: 'pending' | 'paid' | 'failed';
  paidAt?: Date;
  failureReason?: string;
};
```

This allows:

```ts
{
  status: 'paid',
  failureReason: 'card declined'
}
```

Better:

```ts
type Payment =
  | { status: 'pending' }
  | { status: 'paid'; paidAt: Date }
  | { status: 'failed'; failureReason: string };
```

Rules:

* Avoid nullable fields when a union describes the state better.
* Prefer precise variants to comments.
* Use exhaustive switches for workflows.
* Do not encode business state as random booleans.

Bad:

```ts
type User = {
  isActive: boolean;
  isDeleted: boolean;
  isSuspended: boolean;
};
```

Better:

```ts
type UserStatus =
  | { type: 'active' }
  | { type: 'deleted'; deletedAt: Date }
  | { type: 'suspended'; reason: string };
```

---

## 3.14 Function design

Rules:

* Functions over 3 parameters should usually take an object.
* Boolean parameters are often unclear.
* Return domain types, not transport types.
* Avoid hidden I/O inside pure-looking functions.
* Separate calculation from effects.
* Keep async boundaries explicit.

Bad:

```ts
createUser('Zaid', true, false, 3);
```

Better:

```ts
createUser({
  name: 'Zaid',
  sendWelcomeEmail: true,
  requireMfa: false,
  retryCount: 3,
});
```

For pure logic:

```ts
const calculateTotal = (cart: Cart): Money => {
  return cart.items.reduce(addItemTotal, Money.zero(cart.currency));
};
```

For effects:

```ts
const saveCart = async (cart: Cart): Promise<Result<CartId, SaveCartError>> => {
  // I/O is obvious from name and return type.
};
```

---

## 3.15 Module boundaries

Rules:

* UI imports application/domain, not infrastructure directly.
* Domain must not import React, Express, Next, Prisma, Drizzle, or browser APIs.
* Infrastructure implements interfaces or adapters.
* Shared packages must not import apps.
* Avoid circular dependencies.
* Keep public exports intentional.

Good package shape:

```text
packages/
  domain/
    src/
      user.ts
      order.ts
      payment.ts
  api-client/
    src/
      user-client.ts
      schemas.ts
  app/
    src/
      features/
```

Bad:

* `domain` importing `@prisma/client`
* UI component importing database client
* `packages/shared` becoming a junk drawer
* `utils/index.ts` exporting everything

---

## 3.16 Kill internal barrel files

**Rule:** Internal barrel files make typecheck, test startup, bundling, and dependency tracing worse.

Bad:

```ts
import { Button, Dialog, Input, UserCard } from '@/components';
```

Better:

```ts
import { Button } from '@/components/button';
import { Dialog } from '@/components/dialog';
import { Input } from '@/components/input';
import { UserCard } from '@/components/user-card';
```

Acceptable:

* public package boundary exports
* explicit package subpath exports
* stable library API surfaces

```json
{
  "exports": {
    "./button": "./dist/button.js",
    "./dialog": "./dist/dialog.js"
  }
}
```

Cleanup playbook:

1. Find `index.ts` files.
2. Classify as public API or internal convenience.
3. Replace internal imports with direct imports.
4. Delete internal barrels.
5. Add lint/import rules to prevent reintroduction.
6. Measure typecheck/test startup if this was a performance fix.

Rule: A barrel that exists only to make imports pretty is not free.

---

## 3.17 Dead code and dependency cleanup

Use Knip for JS/TS dead-code cleanup. Knip’s docs describe it as finding unused dependencies, exports, and files, and its TypeScript pages specifically cover unused exports and dependencies. ([Knip][4])

Basic command:

```bash
npx knip --no-progress
```

Suggested config:

```json
{
  "$schema": "https://unpkg.com/knip@5/schema.json",
  "workspaces": {
    ".": {
      "entry": ["src/index.ts"],
      "project": ["src/**/*.{ts,tsx}"]
    },
    "apps/*": {
      "entry": ["src/main.tsx", "src/app/**/*.{ts,tsx}"],
      "project": ["src/**/*.{ts,tsx}"]
    },
    "packages/*": {
      "entry": ["src/index.ts"],
      "project": ["src/**/*.{ts,tsx}"]
    }
  }
}
```

Rules:

* Run Knip in CI.
* Triage findings, do not blindly delete public APIs.
* Mark planned removals with `@deprecated`.
* Remove unused dependencies aggressively.
* Fewer dependencies mean faster installs, smaller attack surface, and less maintenance.

---

## 3.18 Linting for serious TypeScript

Recommended stack:

* `typescript-eslint`
* `eslint-plugin-import-x` or equivalent import linting
* `eslint-plugin-unicorn` if the team accepts opinionated rules
* `eslint-plugin-jsx-a11y` for React
* `eslint-plugin-deprecation` for staged API removal
* Biome/Oxlint for speed where rule coverage fits
* Prettier or Biome formatter; do not hand-format

Must-have rules:

* `@typescript-eslint/no-floating-promises`
* `@typescript-eslint/no-misused-promises`
* `@typescript-eslint/switch-exhaustiveness-check`
* `@typescript-eslint/consistent-type-imports`
* `@typescript-eslint/no-unnecessary-type-assertion`
* `@typescript-eslint/no-explicit-any`
* `@typescript-eslint/no-unsafe-assignment`
* `@typescript-eslint/no-unsafe-member-access`
* `@typescript-eslint/no-unsafe-call`
* `@typescript-eslint/prefer-readonly`
* `import/no-cycle` or equivalent
* `no-restricted-imports` for boundary rules

Warning: the `no-unsafe-*` rules require type-aware linting, which is slower. Use them in CI or targeted packages if local lint gets too slow.

---

## 3.19 Type-aware lint performance

Type-aware ESLint is powerful but expensive.

Rules:

* Run fast lint locally.
* Run full type-aware lint in CI.
* Cache aggressively.
* Scope lint to changed packages when possible.
* Do not force 60-second pre-commit hooks.

Practical split:

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:types": "eslint . --config eslint.type-aware.config.js",
    "typecheck": "tsc --noEmit"
  }
}
```

Pre-commit:

* format
* fast lint on changed files

CI:

* full lint
* typecheck
* tests
* Knip
* build

Rule: If hooks are too slow, developers bypass them. Put heavy checks in CI.

---

## 3.20 Project references and monorepo scaling

Use project references when:

* typecheck is slow
* repo has many packages
* editor is sluggish
* boundaries need enforcement
* packages build independently

Official TypeScript docs say project references split programs into smaller projects and can improve build/editor interaction times. ([TypeScript][5])

Package `tsconfig.json`:

```json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "declarationMap": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"],
  "references": [
    { "path": "../domain" }
  ]
}
```

Root build config:

```json
{
  "files": [],
  "references": [
    { "path": "packages/domain" },
    { "path": "packages/api-client" },
    { "path": "apps/web" }
  ]
}
```

Build:

```bash
tsc -b
```

Rules:

* Use references for real package boundaries.
* Avoid references for tiny apps with no scale problem.
* Do not let every package reference every other package.
* Keep dependency direction acyclic.
* Use Turborepo/Nx/Moonrepo to orchestrate larger repos.

---

## 3.21 Build and bundle performance

Performance cleanup targets:

* barrel files
* giant dependency imports
* duplicate dependencies
* client/server boundary leaks
* importing Node-only modules into browser code
* importing full libraries for one function
* side-effectful modules
* circular imports
* excessive polyfills
* huge schema libraries in client bundles
* accidental test/dev code in production

Rules:

* Prefer subpath imports when the package supports them.
* Use bundle analyzer for front-end apps.
* Keep server-only code out of client bundles.
* Do not import from package roots if it pulls too much.
* Avoid side effects at module top level.
* Prefer dynamic import for rare heavy UI/code paths.

Bad:

```ts
import * as dateFns from 'date-fns';
```

Better:

```ts
import { format } from 'date-fns/format';
```

Exact import shape depends on the package. Verify with bundler output.

---

## 3.22 Avoid top-level side effects

Bad:

```ts
const connection = createDatabaseConnection();

export const getUser = (id: UserId) => {
  return connection.user.find(id);
};
```

Better:

```ts
export const createUserRepository = (db: Database) => ({
  getUser: (id: UserId) => db.user.find(id),
});
```

Rules:

* Module import should not connect to databases.
* Module import should not start timers.
* Module import should not read mutable global config unless it is tiny and intentional.
* Prefer explicit factories for effectful dependencies.
* Top-level constants are fine when pure.

Benefits:

* faster tests
* easier mocking
* no hidden lifecycle
* clearer dependency graph
* safer serverless/runtime behavior

---

## 3.23 Environment variables

Environment variables are untyped external input.

Bad:

```ts
export const apiUrl = process.env.API_URL!;
```

Better:

```ts
const EnvSchema = z.object({
  API_URL: z.string().url(),
  NODE_ENV: z.enum(['development', 'test', 'production']),
});

export const env = EnvSchema.parse(process.env);
```

Rules:

* Validate env once at startup.
* Export typed config.
* Do not read `process.env` all over the app.
* Do not use non-null assertions for required env.
* Split server and client env.
* Never expose secrets to client bundles.

---

## 3.24 API client pattern

Bad:

* fetch scattered across components
* raw JSON returned everywhere
* each caller handles status codes differently

Better:

```ts
type ApiError =
  | { type: 'unauthorized' }
  | { type: 'not_found' }
  | { type: 'network'; cause: unknown }
  | { type: 'parse'; issues: unknown };

const getJson = async <T>(
  input: RequestInfo,
  schema: z.ZodSchema<T>,
): Promise<Result<T, ApiError>> => {
  try {
    const response = await fetch(input);

    if (response.status === 401) return err({ type: 'unauthorized' });
    if (response.status === 404) return err({ type: 'not_found' });

    const raw: unknown = await response.json();
    const parsed = schema.safeParse(raw);

    return parsed.success
      ? ok(parsed.data)
      : err({ type: 'parse', issues: parsed.error.issues });
  } catch (cause) {
    return err({ type: 'network', cause });
  }
};
```

Rules:

* Centralize HTTP status handling.
* Validate response bodies.
* Use typed errors.
* Do not make UI parse API failures.
* Support abort signals where appropriate.

---

## 3.25 Database and ORM boundaries

Rules:

* Do not leak ORM-specific types into domain unless the app is tiny.
* Keep queries in repository/data layer.
* Convert database nullability to domain variants.
* Do not trust raw SQL output without typed mapping.
* Avoid domain code importing Prisma/Drizzle/etc.
* Keep transactions explicit.

Bad:

```ts
const activateUser = async (user: Prisma.User) => {
  // domain logic now depends on Prisma shape
};
```

Better:

```ts
type User = {
  id: UserId;
  status: UserStatus;
};

const activateUser = (user: User): User => {
  return { ...user, status: { type: 'active' } };
};
```

---

## 3.26 Testing type safety

Runtime tests are not enough. Add type tests for public APIs and advanced types.

Options:

* `tsd`
* `expect-type`
* `vitest` type assertions
* `// @ts-expect-error` for negative tests

Example:

```ts
import { expectTypeOf } from 'expect-type';

expectTypeOf(parseUser).returns.toEqualTypeOf<Result<User, ParseError>>();
```

Negative test:

```ts
// @ts-expect-error OrderId must not be passed where UserId is required
getUser(orderId);
```

Rules:

* Use type tests for library utilities.
* Use `@ts-expect-error`, not `@ts-ignore`.
* Every expected error should prove a real contract.
* If `@ts-expect-error` stops erroring, TypeScript tells you.

---

## 3.27 Refactoring playbooks

### Strictness migration

1. Run `tsc --noEmit`.
2. Turn on one flag.
3. Fix boundary files first.
4. Replace `any` with `unknown`.
5. Add parsers for external data.
6. Replace nullable state blobs with unions.
7. Commit.
8. Repeat.

### `any` cleanup

1. Search for `: any`, `as any`, and implicit unsafe zones.
2. Classify each as boundary, generic utility, test, or laziness.
3. Boundary: replace with `unknown` and parser.
4. Utility: constrain generic.
5. Test: localize and comment if needed.
6. Laziness: type properly or delete.

### Barrel removal

1. List all `index.ts` files.
2. Keep package public API barrels.
3. Delete internal convenience barrels.
4. Rewrite imports.
5. Run typecheck/tests.
6. Add import restriction.

### Result migration

1. Start at API/database boundary.
2. Convert throwing function to `Result`.
3. Update one caller path.
4. Add exhaustive error handling.
5. Repeat outward.
6. Do not convert the entire app in one PR.

### Slow typecheck cleanup

1. Run `tsc --extendedDiagnostics`.
2. Remove internal barrels.
3. Split giant packages.
4. Name exported return types.
5. Simplify recursive/conditional types.
6. Add project references if scale warrants.
7. Move heavy type-aware lint to CI.

---

## 3.28 Performance review checklist

Before merging a TS-heavy PR, check:

* Does it add `any`?
* Does it add `as unknown as X`?
* Does it parse external data?
* Does it model impossible states?
* Does it introduce barrel imports?
* Does it add circular dependencies?
* Does it add type-level recursion?
* Does it expose giant inferred types?
* Does it import server-only code into client code?
* Does it add top-level side effects?
* Does it leave promises floating?
* Does it add a dependency for trivial logic?
* Does it increase bundle size?
* Does it slow typecheck or lint?
* Does it weaken `tsconfig`?

---

## 3.29 Anti-patterns to refuse

Refuse or strongly push back on:

* `strict: false` in new projects
* `JSON.parse(...) as MyType`
* `fetch().then(r => r.json() as User)`
* `as any` to silence real errors
* `as unknown as X` without a boundary wrapper
* nullable state bags instead of discriminated unions
* throwing for expected validation/network outcomes
* unhandled promises
* async `forEach`
* internal barrel files
* `utils/index.ts` dumping ground
* domain importing framework/ORM types
* reading `process.env` everywhere
* public APIs with giant inferred return types
* type-level puzzles that nobody can maintain
* pre-commit hooks that run full type-aware lint for a huge repo
* adding dependencies that duplicate platform/language features
* loosening compiler flags to merge faster

---

## 3.30 Escalation thresholds

| Symptom                                          | Action                                            |
| ------------------------------------------------ | ------------------------------------------------- |
| Any external data typed with `as X`              | Add runtime parser                                |
| Repeated `data?: T; error?: E; loading: boolean` | Replace with discriminated union                  |
| Build/typecheck >5 minutes                       | Audit barrels, project size, project references   |
| ESLint local run >30 seconds                     | Split fast lint and type-aware CI lint            |
| Package exports everything from `index.ts`       | Replace internal barrels with direct imports      |
| More than 3 modules import each other cyclically | Redraw module boundaries                          |
| `any` appears in domain code                     | Replace with proper type or `unknown` + narrowing |
| Function has 4+ params                           | Use parameter object                              |
| Type alias spans >20 lines                       | Name subtypes or simplify                         |
| Public inferred return type is unreadable        | Add explicit exported return type                 |
| Client bundle grows unexpectedly                 | Run bundle analyzer and inspect imports           |
| Dependency used once for trivial helper          | Delete dependency                                 |

---

## 3.31 Source families

Use these when validating or updating this file:

* TypeScript Handbook and TSConfig Reference
* TypeScript project references docs
* typescript-eslint rules
* Effective TypeScript
* Total TypeScript
* Knip documentation
* Zod / Valibot / ArkType documentation
* neverthrow documentation
* Turborepo / Nx / Moonrepo docs
* Bundler docs for the project: Vite, Next.js, esbuild, Rollup, Webpack, or Rspack

