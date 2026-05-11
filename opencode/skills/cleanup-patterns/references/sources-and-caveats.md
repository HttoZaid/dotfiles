
# Sources and Caveats

Use this file when validating claims, updating the skill, checking version-sensitive advice, or deciding whether a rule should be softened.

This skill intentionally combines official documentation, large-org style guides, mature community practice, and production heuristics. Treat all version-specific claims as temporary.

---

## 1. Source priority

Use sources in this order:

1. **Official language/framework docs**
2. **Official style guides**
3. **Maintainer-authored docs**
4. **Large-org engineering guides**
5. **Well-known expert/community writing**
6. **Case studies**
7. **Reddit / forum tips**
8. **Personal/team preference**

Rules:
- Official docs override blog posts.
- Maintainer docs override random tutorials.
- Large-org guides are useful, but not universal.
- Case studies are directional, not guaranteed.
- Reddit tips are signals, not authority.
- Benchmarks must match the project context.

---

## 2. Flutter / Dart source families

Use these when updating Flutter guidance:

- Flutter performance best practices
- Flutter DevTools docs
- Flutter app architecture docs
- Flutter testing docs
- Effective Dart
- Dart language docs
- Dart analyzer and linter docs
- very_good_analysis docs
- BLoC docs
- Riverpod docs
- Melos docs
- VGV engineering articles
- Code with Andrea architecture articles
- Dart package docs for `freezed`, `json_serializable`, `mocktail`, `bloc_test`

Version-sensitive areas:
- Flutter rendering engine behavior
- Impeller performance characteristics
- Riverpod generator/lint changes
- BLoC API changes
- very_good_analysis rule versions
- Melos workspace behavior
- Dart macros/codegen roadmap
- golden test tooling

Caveats:
- A state management choice is usually a team/process choice, not a universal benchmark decision.
- Codegen can be worth it in large apps and a tax in small apps.
- Feature-first architecture helps at scale but can become folder theater in tiny apps.
- Performance advice must be verified in profile/release mode on target devices.

---

## 3. TypeScript source families

Use these when updating TypeScript guidance:

- TypeScript Handbook
- TSConfig Reference
- TypeScript release notes
- typescript-eslint docs
- Effective TypeScript
- Total TypeScript
- Zod / Valibot / ArkType docs
- neverthrow docs
- Knip docs
- Turborepo docs
- Nx docs
- pnpm workspace docs
- Vite / Next.js / Rollup / Webpack / Rspack docs depending on project
- Google TypeScript Style Guide

Version-sensitive areas:
- TS compiler flag behavior
- NodeNext / bundler module resolution
- decorators
- type-checking performance
- JSX/runtime settings
- ESLint flat config
- Type-aware linting performance
- framework-specific bundler behavior
- Knip plugin support

Caveats:
- `strict: true` is strongly recommended for new code, but legacy migration should be incremental.
- `skipLibCheck: true` is a pragmatic performance compromise, not full type soundness.
- Type-level programming can be useful in libraries and toxic in product code.
- Runtime validation is mandatory at trust boundaries, but repeated validation inside trusted code can hurt throughput.
- `neverthrow` is a pattern choice; native exceptions are still valid for programmer errors.

---

## 4. React / UI source families

Use these when updating React/UI guidance:

- React docs
- React Compiler docs when applicable
- Next.js docs
- Remix docs when applicable
- TanStack Query docs
- SWR docs
- Tailwind CSS docs
- Radix UI docs
- React Aria docs
- Ariakit docs
- shadcn/ui patterns
- CVA docs
- tailwind-variants docs
- Testing Library docs
- Playwright docs
- axe / accessibility tooling docs
- Web.dev performance and Core Web Vitals docs
- React Doctor docs when using that tool

Version-sensitive areas:
- React Server Components
- React Compiler
- Next.js App Router caching/rendering behavior
- Partial prerendering
- Server actions
- Tailwind CSS v4 syntax and ecosystem migration
- shadcn/ui conventions
- TanStack Query major versions
- accessibility primitive APIs
- bundler tree-shaking behavior

Caveats:
- SSR/SSG/CSR strategy depends on product needs and hosting/runtime constraints.
- `useMemo` and `useCallback` are not default performance fixes.
- Tailwind class style is partly team preference, but token usage and accessibility are not.
- Design systems should optimize for product velocity and correctness, not theoretical purity.
- Static analysis tools like React Doctor are useful signals, not final reviewers.

---

## 5. Go source families

Use these when updating Go guidance:

- Effective Go
- Go Code Review Comments
- Go language spec
- Go blog
- Go diagnostics docs
- `context` package docs
- `net/http` docs
- `database/sql` docs
- `testing` package docs
- `pprof` docs
- `trace` docs
- Uber Go Style Guide
- Google Go Style Guide
- staticcheck docs
- golangci-lint docs
- errgroup docs
- OpenTelemetry Go docs
- Prometheus Go client docs
- benchstat docs

Version-sensitive areas:
- loop variable semantics
- slog behavior and ecosystem
- profile-guided optimization
- generics patterns
- HTTP server features
- `database/sql` driver behavior
- golangci-lint config schema
- staticcheck rules
- Go toolchain performance

Caveats:
- Go rewards simple code, but "simple" does not mean under-instrumented or under-tested.
- Large files can be fine when cohesive.
- Interfaces should usually be consumer-defined, but public behavior interfaces can belong in producer packages.
- p99 performance depends on production workload, not only microbenchmarks.
- Alternative JSON libraries or hand optimization need proof from profiles.

---

## 6. Cross-cutting source families

Use these when updating system-level guidance:

- Renovate docs
- Dependabot docs
- OpenTelemetry docs
- Prometheus docs
- Web.dev performance docs
- OWASP guidance
- Conventional Commits
- Turborepo / Nx / Melos docs
- Knip docs
- GitHub Actions docs or the project’s CI platform docs
- Playwright / Flutter test / Go test / Vitest docs
- Project-specific ADRs and postmortems

Version-sensitive areas:
- CI platform behavior
- dependency bot config
- package manager lockfile behavior
- monorepo tooling
- security scanners
- performance budgets
- test runner APIs
- browser performance metrics

Caveats:
- Tooling should match repo size.
- Heavy local hooks are usually bypassed.
- Automated dependency upgrades are only safe with trustworthy CI.
- Monorepos need boundaries; polyrepos need upgrade automation.
- Performance budgets need real target devices/users.

---

## 7. Community and Reddit tips

Community tips are useful for discovering pain points, but they need validation.

Use Reddit/forum tips for:
- discovering repeated developer pain
- finding "nobody says this" gotchas
- checking if a tool has rough edges
- identifying migration traps
- finding real-world failure modes

Do not use Reddit/forum tips for:
- final authority on architecture
- security claims
- benchmark claims without reproduction
- version-specific claims without docs
- broad "best practice" rules

Validation rule:
1. Capture the tip.
2. Check official docs or maintainer docs.
3. Check issue tracker/release notes if version-sensitive.
4. Test in a small repro if behavior matters.
5. Only then add it to the skill.

---

## 8. Benchmark caveats

Benchmarks lie when:
- workload is unrealistic
- input size is too small
- warmup behavior is ignored
- debug mode is used
- target hardware differs
- network/database latency is absent
- cache behavior is different
- GC/allocation behavior is ignored
- benchmark measures the wrong thing

Rules:
- For Go, include `-benchmem` and use `benchstat`.
- For Flutter, profile on target devices in profile/release mode.
- For React/web, use bundle analysis, Web Vitals, and real device/network conditions.
- For TypeScript, distinguish runtime performance from typecheck/lint/build performance.
- For backend systems, track p50/p95/p99 and error rate together.

Never write:
```text
This is faster.
````

Write:

```text
In this workload, this reduced p95 from X to Y and allocations from A to B.
```

---

## 9. Version caveats

Always re-check versions for:

* Flutter SDK
* Dart SDK
* Riverpod
* BLoC
* very_good_analysis
* Melos
* TypeScript
* typescript-eslint
* ESLint
* Tailwind CSS
* Next.js
* React
* TanStack Query
* Knip
* Go
* golangci-lint
* staticcheck
* Renovate

Rule:

* If the advice names a specific version, release, API, or config schema, verify before applying.

---

## 10. Tool deprecation caveats

Tools change or die.

Known categories that require periodic checking:

* dead-code tools
* lint config schemas
* dependency bots
* monorepo task runners
* Flutter codegen tools
* React framework rendering behavior
* TypeScript compiler flags
* Go lint aggregators

Rules:

* Revalidate this file every 6–12 months.
* Prefer tools with active maintainers.
* Keep migration cost in mind before adopting tools.
* Avoid betting core architecture on fragile tools.

---

## 11. Case study caveats

Case studies are useful but not universal.

A build speed improvement from one company may depend on:

* repo size
* bundler
* import graph
* hardware
* cache setup
* test runner
* team workflow
* package layout

Use case studies to justify investigation, not guaranteed outcomes.

Good:

```text
Barrel files have caused major build slowdowns in large TS repos. Audit this repo and measure.
```

Bad:

```text
Removing barrels will make every repo 75% faster.
```

---

## 12. Skill maintenance checklist

When updating this skill:

* Verify official docs first.
* Check release notes for major tool versions.
* Remove stale version-specific claims.
* Prefer patterns over tool worship.
* Keep root `SKILL.md` short.
* Keep each reference file focused.
* Add examples that an agent can apply.
* Add refusal/anti-pattern rules.
* Add cleanup playbooks.
* Add measurable thresholds.
* Avoid vague "best practices" filler.
* Do not include huge copied docs.
* Link or name source families instead of pasting long source text.
* Keep the skill easy to skim.

---

## 13. Claims that need especially strong proof

Require strong evidence for:

* performance numbers
* security guarantees
* "X is deprecated"
* "Y is the official standard"
* "Z is faster"
* "everyone uses this"
* "this tool replaces that tool"
* "this pattern is required"
* "this framework recommends this"

Use softer wording when proof is weaker:

* "prefer"
* "usually"
* "commonly"
* "measure"
* "consider"
* "for larger teams"
* "when this pressure appears"

Use hard wording only when the rule is truly strong:

* "Do not log secrets."
* "Validate external input."
* "Do not expose debug endpoints publicly."
* "Do not ignore unhandled async failures."
* "Do not compare error strings."

