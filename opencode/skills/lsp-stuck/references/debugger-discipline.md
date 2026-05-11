# Debugger discipline

The methodology behind the eight phases in `SKILL.md`. Read this when the failure is unusual or when the surface-level investigation isn't converging. Each section goes deeper than the SKILL.md summary.

## Phase 0 — Reproduce

A bug you can't reproduce is a bug you can't fix, only paper over. Time spent on Phase 0 is never wasted.

### When the failure is reliable

Capture three things in a snippet you can paste anywhere:
1. The exact command (with all flags, env vars, working dir)
2. The exact error output (stderr, exit code)
3. The minimal state needed (specific input file, specific URL, specific DB row)

### When the failure is flaky

Flaky failures hide root cause behind noise. Investigate the flakiness *first*:

- **Race conditions.** Run the test 100x in a loop (`for i in {1..100}; do <cmd>; done`). What percentage fails? Does it correlate with system load? With test order? With parallelism flags (`--parallel`, `-p`, `GOMAXPROCS`)?
- **Time/clock dependence.** Tests that use `Date.now()`, `time.Now()`, monotonic clocks, or sleep-based synchronization. Fix the clock, not the test.
- **Order dependence.** Tests that leak state into each other. Run in isolation: does it still fail? Run in reverse order: does it still fail?
- **Resource exhaustion.** Memory, file handles, ports, DB connections. Check `ulimit -a`, `lsof`, port-in-use errors.
- **Network/DNS.** Retry-with-backoff failures, hostname resolution. `dig`, `curl -v`, packet capture if desperate.

A reliably-failing test is a debuggable test. A flaky test needs to be made reliable first.

### When you can't reproduce locally

- Diff environments: Node/Go/Rust/Python versions, OS, env vars, secrets, working dir
- Check CI logs for the exact command run; replicate it locally with the same env
- File-system case sensitivity (macOS HFS+/APFS is case-insensitive by default; Linux ext4 is not — `import './FooBar'` resolving to `./foobar.ts` is a classic)
- Locale (`LC_ALL`, `LANG`) affects string sorting, number parsing, regex behavior
- Time zone (`TZ`) affects date parsing
- If the failure is CI-only and unreproducible locally, add diagnostic logging in the CI pipeline and re-run

## Phase 1 — Isolate

Minimization is the most underused technique. The goal: a 5-line repro that still fails. From there, the cause is geometrically narrowed.

### Reduction strategies

- **Delta debugging.** Cut the code in half. If it still fails, repeat on that half. If not, repeat on the other half. O(log n) to find a minimal repro.
- **Variable elimination.** Replace each argument with the simplest possible value of its type. Does it still fail? If so, that argument isn't the cause.
- **Inline everything.** Inline function calls, expand macros, unwrap abstractions. Sometimes the bug hides one layer above the line you're looking at.
- **Strip imports.** Remove unused imports/uses. A duplicate-import bug can silently change which symbol is in scope.

### What "isolated" looks like

A good isolated repro is:
- Single file
- No external state (no DB, no network, no file system reads beyond the source itself)
- Self-contained types — no `any`, no `interface{}`, no `Box<dyn Any>` hiding what's flowing through
- Runnable with one command

If the bug only reproduces with full project context, that's still progress — the next minimization step is figuring out which project file/config/dep is required.

## Phase 2 — Inspect runtime

The type system describes contracts. Runtime tells you who violated them.

### Common type-vs-runtime mismatches

- **Optional/nullable fields.** TS `Foo | undefined`, Go `*Foo`, Rust `Option<Foo>`, Python `Optional[Foo]`. The type says it might be null. Runtime is where you discover it actually is.
- **Discriminated unions narrowed wrong.** A switch on `kind` that doesn't handle a case, or handles it under the wrong branch.
- **Promises that resolve to errors.** TS `Promise<T>` returning a thrown error object as the resolved value — type says `T`, runtime says "this T has a `message` and a `stack`."
- **Parsed JSON treated as typed.** `JSON.parse()` returns `any`. The runtime shape might not match the declared type; you only learn this when the failing field is accessed.
- **Async ordering.** Code that runs before its dependencies are ready. Add a log line at every await boundary.

### Inspection recipes

**TS/JS:**
```js
console.log({ x, type: typeof x, isArr: Array.isArray(x), keys: x && Object.keys(x) });
// At the failing line:
debugger;
// In Node:
node --inspect-brk script.js   // then chrome://inspect
```

**Go:**
```go
fmt.Printf("x = %#v (type %T)\n", x, x)
// or use delve:
// dlv debug ./cmd/foo -- arg1 arg2
// (dlv) b path/to/file.go:42
// (dlv) c
// (dlv) p x
```

**Rust:**
```rust
dbg!(&x);
eprintln!("{x:#?}");
// Backtrace on panic:
// RUST_BACKTRACE=1 cargo run
// RUST_BACKTRACE=full cargo run
```

**Python:**
```python
breakpoint()   # drops into pdb
# Or:
import sys; sys.settrace(...)
# Quick inspection:
print(repr(x), type(x), dir(x))
```

## Phase 3 — Hypothesize with falsification

Karl Popper for debuggers. A hypothesis that can't be falsified is not a hypothesis.

### The format

> "If the cause is X, then Y should be observable. Let me check Y."
> 
> Run check.
> 
> "Y was observed → X confirmed, move to fix" OR "Y was not observed → X is dead, generate next hypothesis"

### Anti-patterns

- **Hope-driven debugging.** "Maybe if I add a `?` here it'll fix it." Try, see, move on without learning. Doesn't build understanding; the next bug in the same area takes the same hour.
- **Shotgun debugging.** Change five things at once, then "see if it works." Now you don't know which change mattered.
- **Confirmation bias.** Looking only at evidence that supports your current theory. Actively look for evidence that *kills* it.

### Good hypotheses to keep on the shelf

When stuck, run through these:

1. **Wrong version installed.** `<pkg-manager> list <pkg>` vs what the code expects.
2. **Stale cache.** Wipe and rebuild.
3. **Duplicate dep.** Two copies of the same package in the resolution tree.
4. **Wrong import.** Importing from a sibling path that resolves to a different file (typo, case sensitivity).
5. **Compile-time vs run-time divergence.** TS compiles, runtime fails — type assertion was a lie.
6. **Async timing.** A value used before its source resolves.
7. **Mutation in shared state.** Object mutated after being passed to a consumer that didn't expect mutation.
8. **Encoding/charset.** UTF-8 vs UTF-16 vs latin-1; BOM in the file.
9. **CRLF vs LF.** Especially in tests comparing string outputs.
10. **Working directory.** Code that uses relative paths and runs from a different CWD than expected.

## Phase 4 — Source-spelunk

See SKILL.md and `ecosystem-notes.md`. The phase that wins most often when 0–3 didn't.

## Phase 5 — Bisect

### Code bisect (`git bisect`)

The most underused git command.

```bash
git bisect start
git bisect bad                    # current commit fails
git bisect good <last-known-good> # this commit passed

# Git checks out a midpoint. Run repro:
<repro-command>

# Tell git the result:
git bisect bad   # or: git bisect good

# Repeat until git names the culprit commit
git bisect reset                  # cleanup when done
```

Automate it with `git bisect run`:

```bash
git bisect start HEAD <good-sha>
git bisect run <repro-command>    # must exit non-zero on fail
```

### Lockfile bisect

When code is unchanged but behavior changed, dependency drift is the cause more often than people think.

```bash
git log -p -- bun.lock              # or package-lock.json / go.sum / Cargo.lock
# Find when the offending dep version changed.

# Or check what changed in a specific window:
git diff HEAD~5 HEAD -- bun.lock
```

### Environment bisect

Sometimes the cause is the Node/Go/Rust version. Especially with major version bumps (Node 18 → 20 → 22 each had behavioral changes worth knowing about).

```bash
# Switch versions and retry:
fnm use 18 && <repro>
fnm use 20 && <repro>
fnm use 22 && <repro>
```

## Phase 6 — Environment audit

A long checklist, run linearly. Time is well-spent here when the code looks correct but the build doesn't agree.

### The audit checklist

```bash
# Tool versions
node --version; bun --version
go version
rustc --version
python --version

# vs project-declared:
cat .tool-versions .nvmrc 2>/dev/null
rg "^go " go.mod
rg "^python_requires" pyproject.toml

# Build cache
ls -la .next dist target __pycache__ tsconfig.tsbuildinfo 2>/dev/null

# Resolution tree
bun pm ls <pkg>         # or npm ls <pkg>
go mod why <pkg>
cargo tree -d           # -d flag highlights duplicates
pip list | rg <pkg>

# Path resolution
cat tsconfig.json | jq '.compilerOptions.paths'
rg "^replace " go.mod
rg "^\[patch" Cargo.toml

# CI vs local
diff <(env | sort) <(ssh ci-host env | sort) 2>/dev/null
```

### Common environment-only bugs

- Test passes locally, fails in CI because CI runs with stricter file-watching limits (`ENOSPC`)
- Build works on Linux, fails on macOS because of case-sensitivity (`./Foo` vs `./foo`)
- Code runs with Node 20, fails on Node 22 because of a behavioral change (e.g. `node:test` runner defaults)
- Test passes with one ordering, fails with another because of shared state
- Build cache from a previous git branch poisoning the current branch's output

## Phase 7 — Verify and postmortem

The phase most often skipped, which is why the same bug ships twice.

### Mutation testing as a fix-verification

After applying the fix:

1. Run the repro command. Must pass.
2. Run full test suite. Must pass.
3. **Revert just the fix line.** Run tests. Something must fail.

If nothing fails when the fix is reverted, you have no regression test. The fix works *now*, but the next person who touches that line will reintroduce the bug silently. Add a test before closing out.

### Postmortem in one line

The point isn't a 10-page document. The point is one of:

- **A test case** named after the bug ("regression: parses ISO dates without TZ")
- **A code comment** at the call site explaining the gotcha ("don't pass `null` — `<lib>` doesn't narrow it to the `Optional` branch internally")
- **A lint rule** that catches the pattern automatically (custom ESLint rule, golangci-lint config, ruff rule, Clippy lint)
- **A changelog entry** if the fix changes public behavior

The bug doesn't return silently — that's the bar.

### When to escalate (write the longer postmortem)

For bugs that:
- Caused production incidents
- Touched security boundaries
- Revealed a class of bug, not a single instance
- Required changes to multiple components to fix

Then yes, write the longer postmortem. Otherwise, one line is enough.
