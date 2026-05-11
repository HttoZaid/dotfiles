## 0. Activation & operating rules

### When to fire
- User asks for refactor / cleanup / review on Flutter, TypeScript, React/TS, or Go code
- User asks "how should I structure" / "what's the right pattern" in those stacks
- User describes symptoms: slow builds, fat components, god widgets, util-package sprawl, throwing functions, prop drilling, "this is getting messy"
- User mentions specific tooling: BLoC, Riverpod, freezed, Melos, Turborepo, Nx, knip, Renovate, golangci-lint, `errors.Is`, `errors.As`, `%w`, neverthrow, Radix, CVA, shadcn

### How to behave when fired
1. **Be specific.** Quote the rule, name the pattern, cite the source. No "consider following best practices."
2. **Push back on weak premises.** If a user wants Melos for a 3-screen app, say no and explain. If they want to introduce barrel files, refuse and explain.
3. **Prefer deletion over addition.** The cheapest line of code is the one you didn't write. Most cleanup wins are subtractive.
4. **Refactor in the smallest reversible step.** Extracting a widget = one commit. Migrating state management = feature-by-feature, not big-bang.
5. **Cite numbers when you have them.** "Atlassian saw 75% faster Jira builds after removing barrel files" beats "barrels can hurt builds."
6. **Don't pretend to know what you don't.** If the user's stack is at a version boundary you're not sure about (e.g., Riverpod 3.x changes, TS 5.x compiler-flag drift), say so and ask them to confirm.

### How to scale advice
- **Small project** (<5 features, <10K LOC, 1 dev): minimum viable rigour. Lints + format + tests. Skip monorepos, codegen, Wire, etc.
- **Medium** (5–20 features, 10–50K LOC, 2–5 devs): full lint stack, repository pattern, knip in CI, table tests, Renovate.
- **Large** (>20 features, >50K LOC, >5 devs OR multi-app): Melos / Turborepo, enforced module boundaries, codegen-aware CI, golden tests, deprecation cycles documented.

The temptation is to apply "large project" rigour to small projects. Resist. Premature modularization costs more than it saves.

---

## 1. Quick decision triggers

| Symptom | Pattern to apply | Section |
|---|---|---|
| Flutter widget >150 lines, multiple `setState` | Extract widgets bottom-up; move logic to Cubit/Notifier | §2.5, §2.10 |
| Flutter `lib/` is `models/screens/widgets/` folders | Convert to feature-first | §2.2 |
| TS build >5 min, slow Jest | Audit and remove barrel files | §3.3 |
| TS function throws on expected error case | Refactor to `Result<T,E>` (neverthrow) | §3.4 |
| Function returns `any` from external data | Validate with Zod/Valibot, return `Result` | §3.7 |
| React component >80 lines | Extract custom hooks for behavior; compound components for markup | §4.10 |
| React component has 25+ props | Compound components with implicit context | §4.2 |
| Go interface in producer package | Move to consumer; producer returns concrete struct | §5.3 |
| Go function uses `errors.New` everywhere with no wrap | Wrap with `fmt.Errorf("doing X: %w", err)` | §5.4 |
| Go has `util/` or `common/` package | Rename to what it provides; or split into cohesive packages | §5.2 |
| No dead-code detection in CI | Add knip (TS) / `staticcheck unused` (Go) / `dart analyze` | §6.5 |
| Manual dep upgrades, falling behind | Renovate with auto-merge for patch/minor | §6.4 |
