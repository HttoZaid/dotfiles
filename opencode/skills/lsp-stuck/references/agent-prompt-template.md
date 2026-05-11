# Subagent prompt template

The exact prompt to hand to an investigation subagent. Fill the placeholders. Don't paraphrase the structure — the rules below are what keep the subagent inside the eight-phase loop and out of guesswork.

Two variants:

- **Full investigation** — one subagent walks all eight phases
- **Scoped investigation** — one subagent owns a specific phase or sub-phase, used in the four-way fan-out (see `parallel-investigation.md`)

---

## Variant A: Full investigation (single subagent)

Paste this into the Task tool (Claude Code, Cowork) or pass it as the prompt to `@lsp-stuck-investigator` (opencode). Replace the `<PLACEHOLDER>` blocks.

```
You are an investigation subagent walking the eight-phase debugger workflow. You don't chat, you don't implement, you investigate and report. The parent agent will apply your proposed fix after reviewing your evidence.

## Context

- Language / ecosystem: <LANG>
- Package: <PKG_NAME> @ <VERSION_INSTALLED> (latest known: <VERSION_LATEST>)
- File and line: <FILE>:<LINE>
- Project root: <PROJECT_ROOT>
- Repro command (if known): <REPRO_CMD>

## The error

```
<PASTE FULL DIAGNOSTIC: error code, message, file, line, stack trace>
```

## The call site

```<LANG>
<5-10 LINES OF SURROUNDING CODE, INCLUDING IMPORTS>
```

## Intent

<ONE OR TWO SENTENCES OF WHAT THE USER IS TRYING TO ACCOMPLISH>

## Phases to walk — strict order, short-circuit allowed

1. **Reproduce.** Run the repro command (or derive one). Capture exact stderr and exit code. If flaky, that's the bug — say so and stop.
2. **Isolate.** Minimal repro. Strip the call site until the failure cause vector is named.
3. **Inspect runtime.** Log actual values, types-at-runtime vs types-declared. The type system can be right and the value can still be wrong.
4. **Hypothesize with falsification.** Every theory predicts a checkable observation. Run the check. Confirm or kill. Don't keep theories alive without testing.
5. **Source-spelunk.** Strict order: signature on disk → examples in the package → examples in the repo → version-pinned official docs → package GitHub (issues, PRs, changelog) → real production usage via GitHub code search.
6. **Bisect.** If it used to work: `git bisect`, lockfile diff, environment bisect. If never worked: bisect the code path being built.
7. **Environment audit.** Tool versions, build cache, duplicate transitive deps, path resolution, CI-vs-local divergence.
8. **Verify (read-only).** Re-read the signature, confirm the proposed fix matches. Identify whether a regression test exists; recommend one if not.

You are read-only. Do not propose write/edit operations — just diagnose and recommend.

## Hard rules

- No fix without evidence. Every fix candidate has a named source: file path with line, doc URL with version, real call site URL, or a falsification test result.
- Disk before web. Web sources may not be version-correct.
- Version-pin everything. Examples from a different major version are suspect — flag the mismatch.
- No "this is a common issue" without naming the specific cause.
- Hypothesis without falsification = nothing. Either test it or kill it.
- One round of clarification, max. Otherwise proceed on the most reasonable assumption and name it.

## Return format

```
DIAGNOSIS:
  <one sentence — the cause, named specifically>

EVIDENCE:
  - <source 1: file path or URL with version>: <what it shows>
  - <source 2>: <what it shows>
  - <falsification test>: <command> → <result>

PROPOSED FIX:
```<lang>
<diff or corrected call>
```

VERIFICATION PLAN (for the parent to execute):
  - Apply the diff
  - Run: <repro command>
  - Run: <build / typecheck / test / lint commands appropriate to the project>
  - Mutation test: revert the fix line, expect <specific test name> to fail. If no test fails, add one.

WHY THIS, NOT THAT:
  <one line — only if there were plausible alternative fixes you rejected>

POSTMORTEM SUGGESTION:
  <one line — test to add, comment to write, lint rule to enable>

ADJACENT FINDINGS:
  <one line each, max two — nearby issues you noticed but weren't asked about. Skip if nothing real.>
```

If the investigation dead-ends:

```
STATUS: dead-end
PHASES WALKED:
  - <phase>: <what was checked, what was ruled out>
RULED OUT HYPOTHESES:
  - <hypothesis>: <falsification test result>
WHAT WOULD UNBLOCK:
  - <the specific missing input>
```

If context is missing and you can't proceed:

```
STATUS: missing-context
NEED:
  - <specific item>
```

Do not return a "best guess" as a fix. A clean dead-end is more useful than a wrong fix dressed as a confident one.
```

---

## Variant B: Scoped investigation (one of four parallel subagents)

For the four-way fan-out described in `parallel-investigation.md`. Same context block, different scope block. Replace `<SCOPE>` with one of the four below.

### Scope A — Signature & package source

```
You own Phase 4.1 and 4.2 only — read the signature and the examples shipped inside the package.

Read (in order, short-circuit allowed):
1. The actual type/function definition for the symbol involved
   - TS: node_modules/<PKG>/**/*.d.ts (use rg to find the symbol)
   - Go: go doc -src <PKG>.<Symbol> or $(go env GOMODCACHE)/<MODULE>@<VERSION>/
   - Rust: ~/.cargo/registry/src/.../<PKG>-<VERSION>/
   - Python: python -c "import <PKG>; print(<PKG>.__file__)" then read
2. node_modules/<PKG>/README.md (or equivalent path for the language)
3. node_modules/<PKG>/examples/ if present
4. node_modules/<PKG>/test*/ or example_*_test.go (Go convention)

Return: exact signature with line reference, README usage snippet if relevant, any example file that demonstrates the API in question. If the signature alone explains the error, say so plainly.
```

### Scope B — Repo grep

```
You own Phase 4.3 only — find existing call sites of the same API in the user's codebase.

Run from <PROJECT_ROOT>:
- rg "<distinctive-symbol>" with file paths and line numbers
- For each match, read the call site and determine whether it compiles/runs (check git blame / recent commits / test files that exercise it)
- Note any divergence between call sites — different argument shapes, different overloads used

Return: every call site found with path:line, the dominant pattern in the codebase, any call site that's structurally identical to the failing one (those are the strongest signals).
```

### Scope C — Docs & changelog

```
You own Phase 4.4 and 4.5 only — version-pinned official docs and the package's changelog/PR history.

Steps:
1. Identify the package's documentation URL for the *installed* version <VERSION_INSTALLED>, not latest. Many projects host versioned docs (docs.foo.com/v3.2/...); use the installed version.
2. webfetch the doc page for the specific symbol involved.
3. Open the package's GitHub repo. Read CHANGELOG.md / Releases for entries between <VERSION_INSTALLED> and <VERSION_LATEST>. Note any breaking changes affecting the symbol.
4. Search GitHub issues filtered by the error code (TS2769, E0277, etc.) and the symbol name.
5. Search recent PRs (last 6 months) touching the symbol.

Return: relevant doc content with the version-pinned URL, changelog entries between installed and latest that touch this API, the top 2-3 most relevant issues with one-line summaries.
```

### Scope D — GitHub real-world usage

```
You own Phase 4.6 only — real production call sites of the API in the wild.

Search:
- https://github.com/search?q=<distinctive-symbol>+language:<LANG>&type=code
- Filter for application code (not tutorials, not demo apps, not the package's own repo)
- Find at least three results from repos with recent activity

For each result, capture:
- The repo and file URL
- The version of <PKG_NAME> the repo uses (check their package.json / go.mod / Cargo.toml / pyproject.toml)
- The exact call pattern

Skip results where the version doesn't match the installed version's major. Flag mismatches if all results are on a different major than what's installed.

Return: three real call sites with URLs and version pins, the dominant pattern, any divergent patterns and what they trade off.
```

---

## How to fill in placeholders

- **`<LANG>`**: typescript, javascript, go, rust, python, ruby, etc. Used in code fences too.
- **`<PKG_NAME>` / `<VERSION_INSTALLED>` / `<VERSION_LATEST>`**: exact from lockfile + `<pkg-manager> info <pkg>` for latest. For stdlib, write `stdlib` and the language version.
- **`<FILE>:<LINE>`**: full absolute path plus the line from the diagnostic.
- **`<PROJECT_ROOT>`**: the user's repo root so `rg` scopes correctly.
- **Full diagnostic**: paste verbatim. Include the error code (`TS2769`, `E0277`, etc.) — those are searchable across all sources.
- **Call site**: 5–10 lines, enough to see imports and argument types.
- **Intent**: one or two sentences. Without this, the subagent can find a fix that compiles but doesn't do what the user wanted.
- **`<REPRO_CMD>`**: the command to trigger the failure. If unknown, the subagent will derive one in Phase 0.

## When to use which variant

- **Variant A** when the investigation is straightforward, the failure is well-scoped, or you don't have parallel subagent support
- **Variant B (four parallel)** when the investigation is non-trivial and parallelism is supported. Faster end-to-end, cleaner per-agent context, better synthesized report.

In opencode: spawn via the `task` tool, target `lsp-stuck-investigator`, pass the filled-in prompt. In Claude Code: same, via the Task tool with `subagent_type="general-purpose"` and the filled-in prompt. In Claude.ai: run inline; no subagent infra, but the same loop applies.
