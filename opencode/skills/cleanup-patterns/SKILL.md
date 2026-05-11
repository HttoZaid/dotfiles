---
name: cleanup-patterns
description: Use when reviewing, refactoring, or restructuring Flutter/Dart, TypeScript, React/TS UI, Go, PHP, WordPress, or Svelte/SvelteKit codebases for maintainability, performance, architecture, accessibility, type safety, linting, error handling, dependency hygiene, dead code, file layout, state management, rendering strategy, API boundaries, testing, CI, and cleanup. Do not use for beginner syntax questions, unrelated languages, or generic coding chat unless cross-mapping is requested.
license: MIT
compatibility: opencode
metadata:
  audience: software-engineers
  workflow: code-review-refactor-maintainability
---

# Code Cleanup & Maintainability Patterns

Use this skill to give research-grounded, stack-specific cleanup, performance, architecture, and maintainability advice without dumping every language rule into context at once.

## How to use this skill

1. Read `references/00-operating-rules.md` first.
2. Identify the user's stack and load only the matching reference file.
3. Load `references/cross-cutting.md` only for repo-wide concerns: CI, docs, dependency hygiene, dead code, monorepos, migrations, performance budgets, or anti-pattern catalogs.
4. Load `references/sources-and-caveats.md` when citing source families, checking caveats, validating claims, or updating the skill.
5. Load `references/skill-authoring.md` only when editing this skill or creating another OpenCode skill.
6. If a mapped reference file is missing, say it is planned/missing instead of pretending the rules exist.

## Reference map

| User topic | Read this file |
|---|---|
| Activation rules, severity, quick triggers | `references/00-operating-rules.md` |
| Flutter, Dart, Riverpod, BLoC, Melos, very_good_analysis, widget performance | `references/flutter-dart.md` |
| TypeScript, tsconfig, strictness, type safety, barrels, Result types, Zod, knip, monorepos | `references/typescript.md` |
| React/TS UI, SSR, SSG, Next.js, Radix, shadcn/ui, CVA, Tailwind CSS, a11y, query folders | `references/react-ts-ui.md` |
| Go layout, interfaces, errors, context, concurrency, testing, p95/p99 performance, golangci-lint | `references/go.md` |
| PHP, Composer, static analysis, backend cleanup, runtime performance, typed PHP | `references/php.md` |
| WordPress themes/plugins, hooks, WP_Query, REST API, security, caching, performance | `references/wordpress.md` |
| Svelte/SvelteKit, SSR, load functions, form actions, stores, routing, hydration | `references/svelte-sveltekit.md` |
| CI, Renovate, docs, migrations, anti-patterns, thresholds, repo health | `references/cross-cutting.md` |
| Source list and version caveats | `references/sources-and-caveats.md` |
| How to maintain OpenCode skills | `references/skill-authoring.md` |

## Operating posture

- Be specific: name the pattern, the trade-off, and the file/section to apply.
- Prefer deletion over addition.
- Refactor in small reversible steps.
- Push back on premature architecture.
- Measure performance before claiming improvement.
- Treat p95/p99, frame stability, bundle size, typecheck time, memory, and accessibility as first-class cleanup concerns.
- Do not invent version-specific claims; verify when tool versions matter.
- When touching multiple stacks, compare only the relevant files instead of loading the whole skill.
- Validate external input at trust boundaries.
- Keep framework-specific code out of domain logic unless the app is intentionally small.
- Prefer accessible, typed, observable, testable code over clever abstractions.
