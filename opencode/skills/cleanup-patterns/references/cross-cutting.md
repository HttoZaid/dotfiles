
# Cross-Cutting Cleanup — CI, Dependencies, Docs, Monorepos, Migrations, and Repo Health

Use this file when the user is working on repo-wide maintainability, CI gates, dependency cleanup, dead code, monorepos, docs, migration plans, architecture thresholds, performance budgets, or anti-pattern cleanup across Flutter, TypeScript, React, and Go.

This file is for system-level engineering quality. Prefer measurable checks, small reversible changes, and automation that developers will actually tolerate.

---

## 6.1 Rule zero: repo health is a product feature

A codebase is healthy when changes are:

- easy to locate
- easy to test
- easy to review
- easy to revert
- easy to deploy
- easy to observe
- hard to break silently

Bad codebase health symptoms:
- nobody knows where a feature lives
- every PR touches random shared files
- CI is flaky
- tests are slow or meaningless
- dependency upgrades are scary
- local setup takes hours
- dead code survives forever
- docs disagree with code
- public APIs have no deprecation path
- performance regressions are discovered by users

Rule:
- If a cleanup does not reduce future change cost, risk, or latency, it is probably aesthetic.

---

## 6.2 The cleanup priority order

Apply cleanup in this order:

1. **Correctness bugs**
2. **Security risks**
3. **Production performance regressions**
4. **Observability gaps**
5. **Test coverage for risky paths**
6. **Dead code and unused dependencies**
7. **Module boundaries**
8. **Naming and docs**
9. **Style polish**

Do not spend a week renaming folders while p99 latency is broken.

---

## 6.3 Naming conventions that age well

Rules:
- Names describe purpose, not type.
- Functions are verbs.
- Types are nouns.
- Booleans start with `is`, `has`, `can`, `should`, or `was`.
- Avoid abbreviations unless the domain uses them.
- Avoid implementation names in domain APIs.
- Avoid generic names like `manager`, `helper`, `util`, `common`, `base`, `data`, `service`.

Good:
```text
parseInvoice
calculateTotal
hasPermission
OrderRepository
PaymentStatus
````

Bad:

```text
doStuff
handleData
processThing
UserManager
CommonHelper
BaseService
```

Rule:

* If a name needs a comment to explain what it is, rename it.

---

## 6.4 Comments and documentation that do not rot

Good comments explain:

* why something exists
* trade-offs
* surprising constraints
* external contracts
* migration deadlines
* security/performance reasoning

Bad comments explain:

* what obvious code does
* outdated implementation details
* TODOs with no owner
* fake certainty

Bad:

```ts
// increments i by one
i++;
```

Good:

```ts
// Keep this timeout below the load balancer's 30s idle timeout.
const timeoutMs = 25_000;
```

Rules:

* Put docs near the code they describe.
* Prefer doc comments for public APIs.
* Prefer ADRs for architecture decisions.
* Prefer `MIGRATING.md` for breaking changes.
* Prefer code examples over abstract prose.
* Delete stale docs aggressively.

Language notes:

* Go: exported identifiers need godoc-style comments when public.
* Dart: use `///`, cross-reference with `[Identifier]`.
* TypeScript: use TSDoc/JSDoc for public APIs, examples, and deprecations.
* React UI: document behavior, accessibility expectations, and composition examples.

---

## 6.5 ADRs: architecture decision records

Use ADRs for decisions that future maintainers will question.

Create an ADR when:

* choosing BLoC vs Riverpod
* choosing pnpm/Turborepo/Nx
* choosing monorepo vs polyrepo
* choosing Result types vs exceptions
* choosing database/ORM
* creating package boundaries
* adopting a design system
* changing CI/deployment model
* making a major performance trade-off

ADR template:

```md id="lxd52i"
# ADR-0001: Use Result types at API boundaries

## Status

Accepted

## Context

Expected failures such as validation, not found, and network errors are currently thrown and handled inconsistently.

## Decision

Return typed Result values at API and repository boundaries. Keep throwing for programmer errors.

## Consequences

- Callers must handle failures explicitly.
- Some code becomes more verbose.
- Error handling becomes easier to test.
- Third-party throwing libraries need adapters.
```

Rules:

* Keep ADRs short.
* Record rejected options.
* Update status when superseded.
* Do not use ADRs for tiny implementation details.

---

## 6.6 CI gates that matter

Minimum PR CI:

```text id="i8ywai"
format-check
lint
typecheck/analyze/vet
unit tests
dead-code check
dependency audit
build
```

Recommended by stack:

```text id="a8ls26"
Flutter:
  dart format --set-exit-if-changed .
  dart analyze
  flutter test
  flutter build <target>

TypeScript / React:
  pnpm lint
  pnpm typecheck
  pnpm test
  npx knip --no-progress
  pnpm build

Go:
  gofmt check
  go vet ./...
  staticcheck ./...
  go test ./...
  golangci-lint run
```

Rules:

* CI must be deterministic.
* CI must fail on real correctness issues.
* CI should run the smallest useful set per PR.
* Heavy checks can run nightly if they are too slow for every PR.
* Flaky tests are treated as bugs.
* Do not let developers normalize red CI.

---

## 6.7 Pre-commit hooks

Pre-commit hooks must be fast.

Good pre-commit:

* format changed files
* fast lint changed files
* secret scan
* maybe typecheck small staged package

Bad pre-commit:

* full test suite
* full monorepo typecheck
* slow integration tests
* network-dependent checks
* huge AI rewrite steps

Rule:

* If pre-commit takes more than a few seconds, developers will bypass it.

Recommended:

* TS: `lint-staged` + formatter + fast ESLint/Biome
* Go: `gofmt`/`goimports` on changed files
* Dart: `dart format` on changed files
* Cross-language: `lefthook` or similar

Heavy checks belong in CI.

---

## 6.8 Performance budgets

Every serious app should define performance budgets.

Examples:

```md id="wgylfc"
# Performance budgets

## Web
- LCP: under 2.5s on target device/network
- CLS: under 0.1
- INP: under 200ms
- JS initial bundle: under agreed route budget

## API
- GET /orders: p95 < 150ms, p99 < 400ms
- POST /checkout: p95 < 500ms, p99 < 1200ms
- Error rate: < 0.1%

## Flutter
- No repeated missed frames in critical flows
- List scroll stable on low-end target device
- Startup time tracked per release
- Memory does not grow unbounded after repeated navigation
```

Rules:

* Budget by route/flow, not only globally.
* Track p95/p99, not just averages.
* Set budgets based on product needs.
* Failing a budget requires an explicit decision.
* Add performance smoke tests for critical flows.

---

## 6.9 Observability baseline

Minimum:

* structured logs
* request IDs / trace IDs
* error reporting
* latency histograms
* build/deploy version
* dependency health signals
* user-impacting failure tracking

By stack:

* Go API: request duration, status, route, DB time, external call time
* React/Next: Web Vitals, route transition timing, hydration errors, client errors
* Flutter: crash reporting, app startup, slow frames, memory warnings, network failures
* TypeScript backend: endpoint latency, queue lag, DB query duration, unhandled rejection reporting

Rules:

* Logs are for debugging events.
* Metrics are for trends and alerts.
* Traces are for request path diagnosis.
* High-cardinality labels are dangerous.
* Do not log secrets, tokens, or sensitive payloads.

---

## 6.10 Dependency hygiene

Rules:

* Every dependency needs a reason.
* Remove unused dependencies.
* Prefer stable, maintained packages.
* Avoid packages that duplicate standard library/platform features.
* Avoid architecture-locking packages unless justified.
* Avoid packages with huge transitive trees for tiny features.
* Keep dependency upgrades routine.
* Treat abandoned platform packages as risk.
* Do not auto-merge major upgrades.

Questions before adding a dependency:

1. Can the language/platform do this already?
2. Is this used in more than one place?
3. Is the package maintained?
4. Is the API stable?
5. Does it affect bundle size, binary size, startup, or build time?
6. Does it introduce security or licensing risk?
7. Can we remove it easily later?

---

## 6.11 Renovate baseline

Recommended config:

```json id="hts84k"
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:recommended",
    ":semanticCommits",
    "schedule:weekly",
    "group:monorepos",
    "group:recommended"
  ],
  "automerge": true,
  "automergeType": "pr",
  "automergeStrategy": "squash",
  "rangeStrategy": "bump",
  "lockFileMaintenance": {
    "enabled": true,
    "schedule": ["before 4am on Monday"]
  },
  "packageRules": [
    {
      "matchUpdateTypes": ["patch", "minor"],
      "matchCurrentVersion": "!/^0/",
      "automerge": true
    },
    {
      "matchUpdateTypes": ["major"],
      "automerge": false,
      "addLabels": ["major-update"]
    },
    {
      "matchPackagePatterns": ["^@types/"],
      "automerge": true,
      "groupName": "type definitions"
    }
  ]
}
```

Rules:

* Auto-merge patch/minor only when CI is green.
* Do not auto-merge major upgrades.
* Group monorepo packages.
* Run lockfile maintenance.
* Keep a dependency dashboard.
* Use human review for risky packages.

Flutter/Dart note:

* Renovate supports `pub` workflows better than many simpler dependency bots.

---

## 6.12 Dead code detection

By stack:

| Stack              | Tooling                                                  |
| ------------------ | -------------------------------------------------------- |
| TypeScript / React | Knip, ESLint, TypeScript unused flags                    |
| Go                 | `staticcheck`, `unused`, `golangci-lint`                 |
| Flutter / Dart     | `dart analyze`, manual export/dependency audits          |
| Cross-repo         | deprecation annotations, search, coverage, usage metrics |

Rules:

* Run dead-code checks in CI.
* Public APIs need staged removal.
* Internal dead code can usually be deleted immediately.
* Do not keep dead code because "we might need it."
* Use git history as the archive.

Deprecation annotations:

```ts id="03eshn"
/**
 * @deprecated Use createOrderV2 instead. Remove after 2026-08.
 */
export const createOrder = () => {};
```

```go id="ay9h2h"
// Deprecated: Use CreateOrderV2 instead. Remove after 2026-08.
func CreateOrder() {}
```

```dart id="qjboiu"
@Deprecated('Use createOrderV2 instead. Remove after 2026-08.')
void createOrder() {}
```

---

## 6.13 Monorepo vs polyrepo

Use a monorepo when:

* teams share code often
* atomic cross-package changes matter
* shared CI can validate changes
* internal packages are versioned together
* design system and app evolve together
* tooling can keep feedback fast

Use polyrepo when:

* services release independently
* access control differs strongly
* build/test graph is too large
* teams rarely share code
* independent ownership matters more than atomic changes

Middle path:

* one monorepo per product
* polyrepo across products
* package boundaries inside the product repo

Rules:

* Monorepo without boundaries becomes a junk drawer.
* Polyrepo without automation becomes dependency drift.
* Choose based on change patterns, not vibes.

---

## 6.14 Monorepo quality gates

Required:

* package ownership
* dependency direction rules
* affected builds/tests
* remote/local caching if large
* no app-to-app imports
* no circular package references
* shared package review discipline
* explicit public exports
* dead-code checks per workspace

Tooling:

* TS/React: pnpm + Turborepo, Nx, Moonrepo, or Bazel
* Flutter/Dart: Melos
* Go: usually one module first; multi-module only when versioning needs it
* Polyglot: Nx, Bazel, Pants, or task-runner plus strict conventions

Rules:

* Do not create a package for every folder.
* Packages must represent ownership or deployment/reuse boundaries.
* Avoid `core` becoming the landfill.
* Keep public package APIs small.

---

## 6.15 Module boundary rules

Good dependency direction:

```text id="5s1bzt"
app / transport / presentation
  -> application / service
    -> domain
      -> nothing framework-specific

infrastructure / data
  -> domain contracts
```

Rules:

* Domain does not import UI frameworks.
* Domain does not import database clients.
* UI does not import raw database clients.
* Transport maps request/response.
* Application/service owns use cases.
* Data/infrastructure owns persistence and external APIs.
* Shared packages do not import app packages.

Bad:

```text
domain -> prisma
domain -> react
widget -> api client
handler -> SQL query everywhere
```

Better:

```text
handler/widget -> service/viewmodel -> repository contract -> repository implementation
```

---

## 6.16 Migration strategy

Use migrations when changing:

* state-management library
* routing system
* package layout
* error handling model
* ORM/database layer
* design system
* build tooling
* compiler/lint strictness
* major dependency versions

Migration rule:

* No big-bang rewrite unless the old system is too broken to run.

Safer migration:

1. Define target pattern.
2. Write one good example.
3. Add lint/code review rule.
4. Migrate one feature.
5. Measure.
6. Repeat.
7. Delete old path.
8. Document final rule.

---

## 6.17 Strangler fig pattern

Use when replacing large legacy systems.

Pattern:

* new code goes through the new path
* old code continues to work
* adapters bridge old/new boundaries
* traffic or features move gradually
* old code is deleted when usage reaches zero

Good for:

* API client migration
* UI design system migration
* state-management migration
* routing migration
* ORM migration
* monolith-to-service extraction

Rules:

* Define completion criteria.
* Track remaining old usages.
* Do not let both systems live forever.
* Delete bridge code after migration.

---

## 6.18 Codemods

Write a codemod when a change touches many call sites.

Use:

* TypeScript: ts-morph, jscodeshift, Babel, ast-grep
* Go: gopls, gofmt/go/ast, `go fix`
* Dart: `dart fix`, analyzer plugins, custom scripts
* CSS/Tailwind: ast-grep, codemods, lint rules

Rule:

* If a breaking change touches more than roughly 10–20 call sites, consider a codemod.

Codemod safety:

* run on a small sample first
* format afterward
* run tests
* review generated diff
* keep manual cleanup separate

---

## 6.19 Branching and PR hygiene

Rules:

* Small PRs beat heroic PRs.
* Separate behavior changes from refactors.
* Separate generated code from hand-written code.
* Separate dependency upgrades from feature work.
* Keep PR description honest.
* Add screenshots for UI.
* Add benchmark/profile evidence for performance claims.
* Add migration notes for public API changes.



```text
1. Add tests around current behavior
2. Refactor without behavior change
3. Add new behavior
4. Delete old path
```

Bad PR:

```text
refactor + feature + dependency upgrade + formatting + generated files
```

---

## 6.20 Review checklist

Reviewers should ask:

* Is the change needed?
* Is it smaller than it could be?
* Is the boundary correct?
* Are failure states explicit?
* Is the code testable?
* Is the code observable?
* Is performance affected?
* Are dependencies justified?
* Is the public API stable?
* Can this be rolled back?
* Does the naming match the domain?
* Is the cleanup mixed with behavior?

Rule:

* A review comment should explain risk, not personal taste.

---

## 6.21 Testing pyramid by system

General:

* unit tests for pure logic
* integration tests for boundaries
* end-to-end tests for critical flows
* performance tests for critical paths
* smoke tests for deploy confidence

Flutter:

* unit: domain/repository/Cubit
* widget: states and composition
* golden: stable UI surfaces
* integration: auth/checkout/core flows

TypeScript:

* unit: pure logic
* integration: API/database/client boundaries
* type tests: public generic APIs
* E2E: core user flows

React:

* Testing Library for behavior
* Playwright for real flows
* visual regression for design system
* a11y scans for critical screens

Go:

* table unit tests
* integration tests with real DB/container
* race tests for concurrency
* benchmarks for hot paths
* fuzz tests for parsers

Rules:

* Do not snapshot giant trees.
* Do not mock everything.
* Test observable behavior.
* Keep tests fast by default.
* Move slow tests to separate CI stages.

---

## 6.22 Security cleanup

Baseline:

* dependency audit
* secret scanning
* input validation
* output escaping
* safe logging
* least privilege
* no secrets in client bundles
* no public debug endpoints
* no SQL string concatenation
* auth checks close to boundaries
* file path validation
* rate limiting where needed

Rules:

* Security fixes outrank style cleanup.
* Logs must not contain tokens, passwords, private keys, or sensitive payloads.
* Error responses must not leak internals.
* Debug tooling must be gated.
* CI should scan dependencies and secrets.

---

## 6.23 Performance cleanup across stacks

Universal performance killers:

* doing unnecessary work
* doing work too often
* doing work on the wrong thread/isolate
* large payloads
* unbounded concurrency
* excessive allocations
* stale caches with no invalidation
* missing indexes
* hidden waterfalls
* loading heavy code too early
* global state causing broad invalidation

Universal performance process:

1. Define target flow.
2. Capture baseline.
3. Identify bottleneck.
4. Make smallest change.
5. Measure again.
6. Keep or revert.
7. Add guardrail if important.

Rules:

* Do not accept "it should be faster" without measurement.
* Optimize user-critical paths first.
* Track p95/p99 for backend.
* Track Web Vitals for web.
* Track frame stability/startup/memory for Flutter.

---

## 6.24 AI-generated code cleanup

AI code often fails by being plausible, not correct.

Common AI code problems:

* invented APIs
* missing error states
* fake abstractions
* overbroad try/catch
* unvalidated external data
* hardcoded styling
* inaccessible UI
* no cancellation
* no tests
* huge components/functions
* unnecessary dependencies
* comments explaining obvious code
* mock data mixed with production
* no cleanup/dispose logic

AI cleanup pass:

1. Verify APIs compile.
2. Delete fake abstractions.
3. Add real error handling.
4. Add validation at boundaries.
5. Check accessibility.
6. Check cancellation/disposal.
7. Remove unused deps.
8. Split large files.
9. Add tests for behavior.
10. Run lint/typecheck/analyze/tests.

Rule:

* AI output is draft code, not production code.

---

## 6.25 Deprecation and removal

Use a deprecation cycle when:

* API is public
* multiple packages/apps consume it
* behavior change is risky
* third parties consume it
* migration needs time

Cycle:

1. Add replacement.
2. Mark old API deprecated.
3. Add automated warning/lint if possible.
4. Document migration.
5. Track remaining usage.
6. Remove in next major or agreed date.

Rules:

* Internal unused code can usually be deleted.
* Public API needs migration path.
* Deprecated code needs removal date.
* Do not keep deprecated code forever.

---

## 6.26 Feature flags

Use flags for:

* gradual rollout
* risky behavior changes
* A/B tests
* operational kill switches
* migration bridges

Rules:

* Every flag has an owner.
* Every flag has a removal date.
* Flags are not permanent architecture.
* Avoid deeply nested flag logic.
* Test both branches.
* Remove dead branches after rollout.

Bad:

```ts
if (flagA) {
  if (flagB) {
    if (flagC) {
      // nobody knows
    }
  }
}
```

Better:

* isolate flag decision once
* route to clear implementation
* delete old implementation later

---

## 6.27 File size and function size

Do not enforce arbitrary file length as religion, but use size as a smell.

Smells:

* file mixes unrelated concepts
* function has multiple reasons to change
* component handles fetch + form + render + validation
* package has no clear owner
* tests are impossible without large setup

Rules:

* Split by responsibility, not line count alone.
* Large cohesive Go files can be fine.
* Large React components are usually not fine.
* Large Flutter widgets are usually not fine.
* Large TypeScript utility files usually rot.

Thresholds:

* React component >150 lines: inspect
* Flutter widget >150 lines: inspect
* TS utility file >300 lines: inspect
* Go file >1000 lines: inspect for cohesion, not automatic failure
* Function >50 lines: inspect branching and responsibility

---

## 6.28 Cross-stack anti-pattern catalog

Refuse or strongly push back on:

* global `utils` dumping ground
* fake clean architecture with empty folders
* broad service locators
* untyped external data
* swallowing errors
* logging secrets
* internal barrel files
* no CI typecheck/analyze/vet
* flaky tests ignored
* giant PRs mixing refactor and behavior
* package added for trivial helper
* public API change without migration
* feature flag without owner/removal date
* "temporary" compatibility layer with no tracking
* performance claim without measurement
* p99 issue diagnosed from average latency
* frontend loading all heavy code upfront
* backend goroutines without cancellation
* Flutter doing I/O in widgets
* React client-side everything
* Go package named `common`
* TypeScript `as any`
* docs that are not tied to code

---

## 6.29 Escalation thresholds

| Symptom                                    | Action                                         |
| ------------------------------------------ | ---------------------------------------------- |
| CI >15 minutes                             | split stages, cache, affected checks           |
| PR review >2 days repeatedly               | reduce PR size and ownership ambiguity         |
| Same bug class repeats                     | add lint/test/tooling guardrail                |
| Dependency upgrades scary                  | introduce Renovate and smaller update cadence  |
| Many unused exports                        | add Knip/staticcheck/analyze gate              |
| Shared package changes break apps          | define public API and ownership                |
| Multiple features edit same files          | restructure by feature/ownership               |
| Performance regression discovered by users | add budget/measurement in CI or release checks |
| Docs repeatedly wrong                      | move docs closer to code or delete them        |
| Feature flags older than 2 quarters        | remove or re-approve explicitly                |
| Migration has no progress metric           | add usage tracking/checklist                   |
| Every new feature needs core changes       | boundaries are wrong                           |
| Tests require huge mocks                   | interfaces/components are too broad            |

---

## 6.30 Source families

Use these when validating or updating this file:

* Effective Dart and Flutter architecture/performance docs
* TypeScript Handbook and TSConfig docs
* React and Next.js docs
* Tailwind CSS docs
* Effective Go, Go diagnostics, Go Code Review Comments
* Uber Go Style Guide
* Knip documentation
* Renovate documentation
* Turborepo / Nx / Melos docs
* OpenTelemetry and Prometheus docs
* Web.dev performance guidance
* Testing Library, Playwright, Flutter test, Go test docs

