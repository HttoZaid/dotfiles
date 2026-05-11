
# OpenCode Skill Authoring — Modular, Agent-Readable, and Easy to Extend

Use this file when creating, editing, splitting, testing, or extending this OpenCode skill.

This skill is designed as a **router skill**: the root `SKILL.md` stays small, and deeper reference files are loaded only when needed.

---

## 1. Skill folder structure

Recommended project-local layout:

```text
.opencode/
  skills/
    cleanup-patterns/
      SKILL.md
      references/
        00-operating-rules.md
        flutter-dart.md
        typescript.md
        react-ts-ui.md
        go.md
        php.md
        wordpress.md
        svelte-sveltekit.md
        cross-cutting.md
        sources-and-caveats.md
        skill-authoring.md
````

Rules:

* Use lowercase hyphenated folder names.
* Keep one main skill folder per skill.
* Keep `SKILL.md` at the skill root.
* Put large stack-specific material in `references/`.
* Use one Markdown file per stack or major topic.
* Avoid one giant `SKILL.md`.

---

## 2. Root `SKILL.md` purpose

The root `SKILL.md` should answer only:

1. What is this skill?
2. When should it activate?
3. Which reference file should the agent read?
4. What is the operating posture?

It should not contain every language rule.

Good root file:

```md
---
name: cleanup-patterns
description: Use when reviewing, refactoring, or restructuring Flutter/Dart, TypeScript, React/TS UI, Go, PHP, WordPress, or Svelte/SvelteKit codebases for maintainability, performance, architecture, accessibility, type safety, dependency hygiene, file layout, and cleanup.
---

# Code Cleanup & Maintainability Patterns

Read `references/00-operating-rules.md` first.

Then load only the relevant stack file:

- Flutter/Dart: `references/flutter-dart.md`
- TypeScript: `references/typescript.md`
- React/TS UI: `references/react-ts-ui.md`
- Go: `references/go.md`
- PHP: `references/php.md`
- WordPress: `references/wordpress.md`
- Svelte/SvelteKit: `references/svelte-sveltekit.md`
- Repo-wide quality: `references/cross-cutting.md`
```

Bad root file:

* 5,000+ lines
* every language in one context dump
* vague trigger description
* no routing map
* no anti-trigger guidance

Rule:

* Root `SKILL.md` is a router, not a textbook.

---

## 3. Frontmatter

Minimum frontmatter:

```md
---
name: cleanup-patterns
description: Use when reviewing, refactoring, or restructuring Flutter/Dart, TypeScript, React/TS UI, Go, PHP, WordPress, or Svelte/SvelteKit codebases for maintainability, performance, architecture, accessibility, type safety, dependency hygiene, file layout, and cleanup.
---
```

Recommended frontmatter:

```md
---
name: cleanup-patterns
description: Use when reviewing, refactoring, or restructuring Flutter/Dart, TypeScript, React/TS UI, Go, PHP, WordPress, or Svelte/SvelteKit codebases for maintainability, performance, architecture, accessibility, type safety, dependency hygiene, file layout, state management, rendering strategy, API boundaries, testing, CI, and cleanup. Do not use for beginner syntax questions, unrelated languages, or generic coding chat unless cross-stack cleanup is requested.
license: MIT
compatibility: opencode
metadata:
  audience: software-engineers
  workflow: code-review-refactor-maintainability
---
```

Rules:

* `name` should match the folder name.
* Use lowercase hyphenated names.
* `description` is the trigger engine.
* Include both positive triggers and negative triggers.
* Keep description specific enough to avoid over-triggering.
* Do not make the description a full essay.

---

## 4. Description trigger quality

The description decides whether the skill activates.

Good trigger description includes:

* stacks covered
* task types
* symptoms
* exclusions

Good:

```text
Use when reviewing, refactoring, or restructuring Flutter/Dart, TypeScript, React/TS UI, Go, PHP, WordPress, or Svelte/SvelteKit codebases for maintainability, performance, architecture, accessibility, type safety, dependency hygiene, file layout, state management, rendering strategy, API boundaries, testing, CI, and cleanup. Do not use for beginner syntax questions, unrelated languages, or generic coding chat unless cross-stack cleanup is requested.
```

Too broad:

```text
Use for coding.
```

Too narrow:

```text
Use only for Flutter refactoring.
```

Too vague:

```text
Helps with best practices.
```

Rules:

* Mention real trigger phrases users say.
* Mention stacks explicitly.
* Mention non-goals explicitly.
* Do not claim the skill handles everything.

---

## 5. Reference file routing

Every stack file should have a clear activation domain.

Routing map:

| User asks about                                                        | Load                                |
| ---------------------------------------------------------------------- | ----------------------------------- |
| Skill behavior, trigger rules, quick triage                            | `references/00-operating-rules.md`  |
| Flutter performance, architecture, widgets, Riverpod, BLoC, Melos      | `references/flutter-dart.md`        |
| TypeScript strictness, runtime validation, type performance, monorepos | `references/typescript.md`          |
| React UI, SSR/SSG, Next.js, Tailwind, accessibility, query folders     | `references/react-ts-ui.md`         |
| Go APIs, p99 performance, concurrency, package design, profiling       | `references/go.md`                  |
| PHP backend quality, Composer, static analysis, runtime performance    | `references/php.md`                 |
| WordPress themes/plugins, hooks, WP_Query, security, performance       | `references/wordpress.md`           |
| Svelte/SvelteKit, SSR, load functions, stores, actions, routing        | `references/svelte-sveltekit.md`    |
| CI, docs, dependencies, monorepos, migrations, repo health             | `references/cross-cutting.md`       |
| Source validation and caveats                                          | `references/sources-and-caveats.md` |
| Editing this skill                                                     | `references/skill-authoring.md`     |

Rule:

* Load the smallest set of files that answers the user.

---

## 6. How to split content

Split into a new reference file when:

* one topic is more than 150–250 lines
* one stack has unique rules, tools, or anti-patterns
* loading the section every time would waste context
* users ask about it independently
* it has different source families or version caveats

Good split:

```text
flutter-dart.md
typescript.md
react-ts-ui.md
go.md
php.md
wordpress.md
svelte-sveltekit.md
cross-cutting.md
```

Bad split:

```text
best-practices.md
more-best-practices.md
other-stuff.md
notes.md
```

Rules:

* Split by user intent.
* Split by stack/runtime.
* Split by source family.
* Do not split purely by length if the file still represents one clear topic.

---

## 7. Writing style for skill files

Skill files should be written for agents, not just humans.

Use:

* direct rules
* concrete examples
* bad/better examples
* checklists
* thresholds
* cleanup playbooks
* anti-patterns to refuse
* source families
* version caveats

Avoid:

* vague advice
* motivational prose
* long essays
* huge copied official docs
* unsupported benchmark claims
* trendy tool worship
* "best practice" without context
* advice that applies only to one framework version without saying so

Good:

````md
Rule: Validate external data at trust boundaries.

Bad:
```ts
const user = await response.json() as User;
````

Better:

```ts
const raw: unknown = await response.json();
const parsed = UserSchema.safeParse(raw);
```

````

Bad:

```md
Always write clean code and follow best practices.
````

---

## 8. File template for new stack references

Use this template for future files such as:

```text
references/php.md
references/wordpress.md
references/svelte-sveltekit.md
```

Template:

```md
# <Stack> — Advanced Cleanup, Performance, and Architecture

Use this file when the user is working on <stack-specific domains>.

This is not beginner advice. Prefer measurable improvements, explicit boundaries, safe defaults, and deletion over unnecessary abstraction.

---

## 1. Rule zero

State the most important principle for the stack.

---

## 2. Runtime / version caveats

Name version-sensitive areas.

---

## 3. Architecture boundaries

Explain how code should be separated.

---

## 4. Performance model

Explain what actually causes slowness in this stack.

---

## 5. Safety / correctness model

Explain validation, error handling, security, type safety, or equivalent.

---

## 6. Testing strategy

Explain meaningful tests for the stack.

---

## 7. Cleanup playbooks

Give step-by-step refactor flows.

---

## 8. Performance checklist

Give merge-review questions.

---

## 9. Anti-patterns to refuse

List patterns the agent should push back on.

---

## 10. Escalation thresholds

Give concrete thresholds for when to change architecture/tooling.

---

## 11. Source families

List docs and references to verify against.
```

Rules:

* Keep headings predictable.
* Keep examples short.
* Prefer practical review rules over abstract theory.
* Include enough detail for code review decisions.

---

## 9. Anti-pattern sections

Every major reference file should include an anti-pattern section.

Anti-pattern entries should be direct:

```md
Refuse or strongly push back on:

- API calls in Flutter `build()`
- TypeScript `JSON.parse(...) as MyType`
- React route layouts marked `'use client'` without need
- Go goroutines without cancellation
- WordPress REST endpoints without capability checks
- SvelteKit server secrets imported into client code
```

Rules:

* Anti-patterns should be actionable.
* Avoid joke-only entries.
* Include the safer replacement elsewhere in the file.
* Use strong wording only for genuinely risky patterns.

---

## 10. Cleanup playbooks

Every major reference file should include cleanup playbooks.

Good playbook:

```md
### Slow page cleanup

1. Run profiler/bundle analyzer.
2. Check whether the whole route is client-side.
3. Move static sections to server/static.
4. Split heavy client widgets.
5. Remove barrel imports.
6. Dynamic import charts/editors/maps.
7. Virtualize large lists.
8. Fix image sizes.
9. Reduce context churn.
10. Re-measure.
```

Bad playbook:

```md
Improve performance.
```

Rules:

* Steps should be ordered.
* Steps should be reversible.
* Steps should mention measurement when performance is involved.
* Steps should avoid big-bang rewrites.

---

## 11. Escalation thresholds

Thresholds tell the agent when advice should become stronger.

Good:

```md
| Symptom | Action |
|---|---|
| Component >150 lines | Split display, data, and interaction concerns |
| API p99 much higher than p50 | Investigate variance: DB, locks, GC, downstreams |
| Typecheck >5 minutes | Audit barrels, project boundaries, heavy types |
```

Rules:

* Use thresholds as heuristics, not absolute law.
* Prefer measurable symptoms.
* Include the recommended next action.
* Do not make thresholds impossible to satisfy.

---

## 12. Source families and caveats

Each stack file should end with source families.

Example:

```md
## Source families

Use these when validating or updating this file:

- official framework docs
- official language docs
- official style guides
- mature package docs
- large-org engineering guides
- production postmortems
- benchmark/profiling docs
```

Rules:

* Put detailed caveats in `sources-and-caveats.md`.
* Do not paste huge copied source text.
* Re-check version-sensitive advice before major edits.
* Treat community tips as signals, not final authority.

---

## 13. Skill update workflow

When updating this skill:

1. Identify the target stack or topic.
2. Read the current reference file.
3. Verify version-sensitive claims.
4. Add practical rules before theory.
5. Add examples if the rule affects code.
6. Add cleanup playbook if the issue repeats.
7. Add anti-pattern if the agent should push back.
8. Add threshold if escalation is measurable.
9. Update root `SKILL.md` routing if a new file was added.
10. Update `sources-and-caveats.md` if source families changed.

Rules:

* Do not add new tools just because they are popular.
* Do not remove caveats to make advice sound stronger.
* Do not mix stack-specific rules into `cross-cutting.md` unless they apply across stacks.
* Do not let `SKILL.md` grow into the whole skill.

---

## 14. Testing whether the skill triggers correctly

Test with positive, negative, and borderline prompts.

Positive prompts:

```text
Review this Flutter widget for performance and cleanup.
```

```text
This TypeScript codebase has slow typecheck and too many any casts.
```

```text
How should I clean up this React app with Tailwind and SSR?
```

```text
Go API p99 is bad and goroutines keep growing.
```

```text
Audit this WordPress plugin for security and query performance.
```

```text
Clean up this SvelteKit route and load function.
```

Negative prompts:

```text
What is a variable?
```

```text
Explain a for loop in Python.
```

```text
Write a tiny hello world in Go.
```

```text
What is HTML?
```

Borderline prompts:

```text
Is this code clean?
```

```text
How do I structure my app?
```

```text
Why is this slow?
```

For borderline prompts, the agent should inspect context:

* stack mentioned
* refactor/cleanup/performance intent
* codebase-level concern
* architecture concern
* file/folder concern

---

## 15. Avoiding context bloat

Rules:

* Load `00-operating-rules.md` first.
* Load only the relevant stack file.
* Load `cross-cutting.md` only for repo-wide concerns.
* Load `sources-and-caveats.md` only for validation/update tasks.
* Do not load all files by default.
* Do not paste entire reference files into normal answers.
* Summarize and apply the relevant rules.

Bad behavior:

* user asks about Go p99 latency
* agent loads Flutter, React, TypeScript, and WordPress files too

Good behavior:

* user asks about Go p99 latency
* agent loads `00-operating-rules.md` and `go.md`

---

## 16. Maintaining planned extension files

The root skill may mention these reference files even before they are fully written:

```text
references/php.md
references/wordpress.md
references/svelte-sveltekit.md
```

Rules:

* If a referenced file does not exist yet, say it is planned or missing.
* Do not pretend the missing file has rules.
* When adding it later, update both:

  * `SKILL.md`
  * `sources-and-caveats.md`
* Keep PHP, WordPress, and Svelte/SvelteKit separate because they have different runtimes and failure modes.

---

## 17. Final quality checklist

Before considering the skill complete, check:

* `SKILL.md` is short.
* `SKILL.md` has clear frontmatter.
* Description includes covered stacks.
* Description includes exclusions.
* Reference map is accurate.
* Each stack has its own file.
* Each stack file has anti-patterns.
* Each stack file has cleanup playbooks.
* Each stack file has performance/checklist sections.
* Cross-cutting rules are not duplicated everywhere.
* Sources and caveats are separated.
* Planned files are clearly listed.
* Advice is specific enough for code review.
* Claims are not stronger than evidence.

