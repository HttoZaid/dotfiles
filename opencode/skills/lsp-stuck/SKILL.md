---
name: lsp-stuck
description: Real debugger workflow for when you hit an LSP error, type diagnostic, compiler error, or "this library isn't doing what I think" moment. Use whenever the user pastes an LSP/TS/Go/Rust/Python diagnostic, a "cannot find module / no overload matches / X not assignable to Y / trait bound not satisfied / works locally not in CI / worked yesterday" message, or is stuck on code that won't compile or behaves intermittently. Trigger on "I'm stuck", "this makes no sense", "this is flaky", "worked yesterday", or whenever red-squiggle or stack-trace output gets pasted. Fire proactively when Claude itself hits an error it can't resolve in one shot — run the workflow instead of guessing. Spawns parallel investigation subagents (opencode @lsp-stuck-investigator, Claude Code Task) or runs inline, walking eight debugger phases — reproduce, isolate, inspect, hypothesize-with-falsification, source-spelunk, bisect, environment-audit, verify-and-postmortem. Returns a fix backed by evidence and a verified regression test.
---

# lsp-stuck

A debugger workflow, not a vibes session. The LSP is telling you something. You don't know what. The cheap move is to pattern-match an API from memory and guess. The expensive-but-correct move is to run a real investigation. This skill is the second one, codified.

Operates under [sharp-dev](../sharp-dev/SKILL.md) voice rules. If sharp-dev isn't active, these rules still apply for the duration of this workflow: direct, imperative, no preamble, no template slop, no "let me investigate that for you", just the work.

## When this fires

Any of:
- LSP error, type-checker diagnostic, compiler error, or runtime stack trace pasted
- "I'm stuck", "makes no sense", "why won't this work", "the docs are useless", "this is flaky", "worked yesterday", "works locally not in CI"
- A call into a library where you don't have the signature memorized from this session
- Mid-task, code fails to compile/run and the cause isn't a typo

If you're about to type a function call you haven't read the signature of this session — fire this skill instead. Training data is stale. Stale APIs are the source.

## Eight phases of a real debugging session

Strict order. Each phase can short-circuit the rest if it produces a verified fix. Don't skip ahead — the cheap phases catch most bugs and skipping them is how you spend an hour on what should have been five minutes.

### Phase 0 — Reproduce

No theorizing until the failure runs on demand. Get a command — `bun test foo`, `cargo check`, `go test ./pkg/x -run TestY`, `npm run dev` plus the click path, the curl line that hits the failing endpoint — that produces the error every time. Record the exit code, the stderr, the relevant log lines.

If it's flaky: that's the bug worth fixing first. A hypothesis you can't test is worth nothing.

Outputs of this phase:
- Exact repro command, copy-pasteable
- Exact error text including code (`TS2769`, `E0277`, `panic:`, etc.)
- File and line, version of the language/runtime, version of the relevant package from the lockfile

### Phase 1 — Isolate

Minimal repro. Strip the call site to the smallest thing that still breaks. The point isn't to "clean it up" — it's to find the cause vector. Cut one variable at a time, run, observe.

- Does the error depend on a specific argument? Cut other args first.
- Does it depend on the surrounding control flow? Inline or remove conditionals.
- Does it depend on type inference? Add explicit annotations to pin types down.
- Does it depend on which file? Move the call to a scratch file with no other code.

The last cut that makes the error disappear *is* the cause vector. Don't theorize about what it is yet — write it down.

### Phase 2 — Inspect runtime, not just types

Types can be right and values can still be wrong. Stack traces lie about root cause but tell the truth about the death scene.

- TS/JS: `console.log` the actual values; `debugger;` in browser/Node; check `typeof`, `Array.isArray`, `instanceof`
- Go: `fmt.Printf("%#v\n", x)`; `dlv debug ./cmd/foo -- args`
- Rust: `dbg!(x);`; `cargo run` with `RUST_BACKTRACE=1`; `rust-lldb`
- Python: `breakpoint()`; `python -m pdb`; `repr(x)`, `type(x)`, `dir(x)`
- Anything: log the actual JSON/shape of the input that's failing, not what you assumed the input was

Often the bug is "the value at runtime isn't what the type says it is" — a missing field, a `null` where a `Date` should be, a `string` where a parsed object was expected. Types describe contracts; runtime tells you who broke them.

### Phase 3 — Hypothesize with falsification

Every theory has to predict something checkable. The format:

> *If the cause is X, then we should see Y. If we see Z instead, X is wrong.*

Examples:
- "If the cause is a stale build cache, then `rm -rf .next && bun run build` should fix it." Run it. If it's fixed, X is confirmed. If not, X is dead — don't keep believing it.
- "If the cause is the wrong major version, then the type signature in `node_modules/<pkg>/dist/index.d.ts` should have a different shape than what I'm calling." Open the file. Check.
- "If the cause is duplicate React in the resolution tree, then `bun pm ls react` should show two." Run it. Check.

A hypothesis without a falsification test is not a hypothesis, it's a hope. Hopes don't fix bugs.

Don't move on with a theory still alive but unverified. Either confirm it or kill it.

### Phase 4 — Source-spelunk

This is the v1 of this skill — still the most reliable source of API truth. Strict order, each step can short-circuit.

1. **Signature on disk.** Read the actual type/function definition. For TS: `node_modules/<pkg>/**/*.d.ts`. For Go: `go doc -src <pkg>.<Symbol>` or `$(go env GOMODCACHE)/<module>@<version>/`. For Rust: `~/.cargo/registry/src/.../<pkg>-<version>/`. For Python: `python -c "import <pkg>; print(<pkg>.__file__)"` then read the source. Stop here if the signature alone explains the error.
2. **Examples inside the package.** `<pkg>/README.md`, `<pkg>/examples/`, `<pkg>/test*/`, `<pkg>/example_*_test.go`. These are version-correct by definition.
3. **Examples in the current repo.** `rg "<distinctive-symbol>" <PROJECT_ROOT>` — has the API been used elsewhere in this codebase on this version? Replicate that pattern.
4. **Version-pinned official docs.** Not latest — the version installed. `web_fetch` the exact page.
5. **The package's GitHub.** Issues with the same error code/text, recent PRs touching the symbol, changelog entries between installed and latest.
6. **Real production call sites on GitHub.** `https://github.com/search?q=<distinctive-symbol>+language:<lang>&type=code`. Read at least three real call sites — application code, not tutorial repos — before generalizing.

See `references/ecosystem-notes.md` for exact paths, tools, and common error-code tables per language.

### Phase 5 — Bisect

If it used to work: bisect. This is the highest-signal phase when applicable.

- **Code bisect.** `git bisect start; git bisect bad; git bisect good <last-known-good-commit>` then run the repro command at each step. Identifies the commit that introduced the regression in O(log n) checks.
- **Lockfile bisect.** A passing run with the old lockfile and a failing run with the new one isolates a dependency change. `git diff HEAD~5 -- bun.lock` (or `package-lock.json`, `go.sum`, `Cargo.lock`, `uv.lock`) often points straight at the breaking transitive update.
- **Environment bisect.** Bad on Node 22, good on Node 20? Bad with `bun 1.2`, good with `1.1`? That's the cause.

If it never worked: bisect the code path you're *building*. Comment out half, run, observe. Find the line where the failing state is created.

### Phase 6 — Environment audit

The bug isn't always in the code.

- **Tool versions.** `node --version`, `bun --version`, `go version`, `rustc --version`, `python --version`. Match against `.tool-versions`, `.nvmrc`, `go.mod`, `pyproject.toml`. Mismatch is a frequent cause.
- **Build cache.** `.next/`, `dist/`, `target/`, `__pycache__/`, `tsconfig.tsbuildinfo`. Stale caches lie. Wipe and retry as a falsification test (cheap, fast).
- **Resolution tree.** Duplicate transitive dependencies are silent killers. `bun pm ls <pkg>`, `npm ls <pkg>`, `go mod why <pkg>`, `cargo tree -d`. Two copies of `react`, two `@types/node` versions, two glibc versions — all cause "this should work."
- **Path resolution.** TS `paths` in `tsconfig.json`, Go `replace` in `go.mod`, Rust `[patch]` in `Cargo.toml`, Python `sys.path` order. Check what's *actually* being resolved (`tsc --traceResolution`, `go env`, `python -c "import x; print(x.__file__)"`).
- **CI vs local divergence.** Different OS, different file-system case sensitivity (macOS vs Linux), different env vars, different secrets, different network. If "works locally, fails in CI" — diff the environments.

### Phase 7 — Verify and postmortem

A fix isn't done until it's verified for the right reason and the same class of bug can't ship again silently.

**Apply the fix.** One change, focused on the diagnosed cause.

**Run the repro command from Phase 0.** It must pass. If it passes for a reason other than the diagnosis, the diagnosis was wrong — go back to Phase 3.

**Run the broader checks.** Build, typecheck, test, lint. Whatever the project uses. "Done" means verified, not typed.

**Mutate the fix to confirm coverage.** Revert just the fix line. Does a test now fail? If no test fails, you have no regression net — write one before closing out. The same bug will come back otherwise.

**Postmortem in one line.** Write the lesson back into the code: a test case, a code comment at the call site explaining the gotcha, a lint rule, a changelog entry. One line, not a 10-page doc. The goal is "next time, this is caught automatically."

## Spawning the subagent

The investigation is read-heavy and parallelizable. Phases 4 and 6 in particular fan out cleanly across multiple subagents. Use them.

### opencode

This skill ships an opencode-native subagent at `agents/lsp-stuck-investigator.md`. Copy it into `.opencode/agent/lsp-stuck-investigator.md` (project) or `~/.config/opencode/agent/lsp-stuck-investigator.md` (global) and it's invokable two ways:

- **By the model**, via the `task` tool from a primary agent (`build`, etc.). The primary agent decides to delegate; the subagent runs in its own session with read-only permissions.
- **By the user directly**, via `@lsp-stuck-investigator` at the prompt.

For maximum power, fan out: the primary agent spawns four parallel `task` calls — one for signature/source, one for repo grep, one for docs+changelog, one for GitHub real-world — and synthesizes the four reports. See `references/parallel-investigation.md` for the fan-out pattern with exact `task` tool invocations.

### Claude Code

Use the Task tool. Fill in `references/agent-prompt-template.md` with the diagnostic, package, version, and call site. For parallel fan-out, spawn four Task calls in the same turn — they execute concurrently.

### Cowork

Same as Claude Code — Task tool, parallel fan-out supported.

### Claude.ai (no subagents)

Run the loop inline. The order doesn't change. The discipline doesn't change. You lose the parallelism, that's all.

## After the investigation: continue

When the subagent returns or the inline pass completes, apply the fix, run the repro command, run the broader checks, do the postmortem. Then return to whatever the larger task was. Don't hand the task back at "diagnosis complete" — the user said *continue* for a reason. "Done" means the build is green and the regression is locked in.

## Return format

Whether you ran inline or via subagent, the final synthesis to the user looks like this:

```
DIAGNOSIS:
  <one sentence — the actual cause, named specifically>

EVIDENCE:
  - <source 1: file path or URL with version>: <what it shows>
  - <source 2>: <what it shows>
  - <falsification test that confirmed it>: <result>

FIX:
```<lang>
<the diff or corrected call>
```

VERIFICATION:
  - Repro command: <command> → <PASS/FAIL>
  - Build/typecheck/test/lint: <PASS/FAIL>
  - Mutation test (revert fix, run tests): <FAILED as expected / NO TEST COVERS THIS — added one>

WHY THIS, NOT THAT:
  <one line — only if there were other plausible fixes you rejected>

POSTMORTEM:
  <one line lesson, plus the regression net you added — test name, comment location, lint rule>

ADJACENT NOTES:
  <one line each, max two — issues noticed while debugging that the user didn't ask about. Skip if nothing real.>
```

If the investigation dead-ends:

```
STATUS: dead-end
PHASES WALKED:
  - <phase>: <what was checked, what was ruled out>
WHAT I'D NEED:
  - <specific missing input — a runnable repro, a version pin, access to the failing env, etc.>
```

A clean dead-end is more useful than a confident wrong fix. Don't dress one as the other.

## Hard rules

- **No guessing API signatures from memory.** If you're about to type a call you haven't read the signature for this session, stop and read it first.
- **No fix without a verified falsification test.** "Try this, it might work" is not done. The repro must pass, the mutation test must fail. No exceptions.
- **No skipping Phase 0.** If you can't reproduce, you can't debug. Make it reproduce first or admit you can't.
- **No skipping to web search.** Disk first, web second. Disk is version-correct; web might not be.
- **Version pin everything.** Examples and docs from a different major version are suspect — flag the mismatch.
- **No "this is a common issue" without naming the specific cause.** Common is not a diagnosis.
- **Hypothesis without falsification = nothing.** Either test it or kill it.
- **No silent papering-over.** If the fix removes a symptom without the diagnosis matching, the bug will return. Go back to Phase 3.
- **One round of clarification, max.** If the diagnostic is genuinely incomplete, ask once with a batched list. Otherwise proceed on the most reasonable assumption and name it.

## Forbidden patterns

- "Let me investigate this for you" — just do it
- "This is a common issue" without the specific cause named
- "Try this" with no evidence trail
- A fix that contradicts a type signature you didn't bother to read
- "Best practices" without a real call site backing it
- Recommending a package upgrade without checking the changelog for the breaking change that would actually fix it
- Stopping at "I think this might be the issue" instead of running the falsification test
- Returning a fix when the build hasn't been run
- Closing out without a regression net

## When to bail (no investigation needed)

- Typo the user can see — point at it, done
- Missing import the LSP has a code action for — say "your LSP has a quick-fix, hit it"
- Package not installed — `<pkg-manager> add <pkg>`, done
- Obvious version mismatch the lockfile shows — fix the lockfile, done

If the answer is a one-liner, return the one-liner. The eight-phase workflow is for when the obvious fix isn't obvious.

## Reference files

- `agents/lsp-stuck-investigator.md` — drop-in opencode subagent. Copy to `.opencode/agent/` or `~/.config/opencode/agent/`. Read-only permissions, callable via `@lsp-stuck-investigator` or the `task` tool.
- `references/debugger-discipline.md` — full methodology for the eight phases: reproducing flaky failures, isolation techniques per language, falsification framework, bisection recipes, mutation testing
- `references/parallel-investigation.md` — fan-out pattern for spawning four parallel investigators with exact `task` tool invocations for opencode and Claude Code
- `references/ecosystem-notes.md` — per-language: where packages live on disk, signature-dumping commands, common error-code tables with real meanings
- `references/agent-prompt-template.md` — exact subagent prompt with placeholders for diagnostic, package, version, call site, and intent. Works for both Claude Code Task and opencode `task` tools.
