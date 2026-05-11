# Parallel investigation

The investigation phases in `SKILL.md` are mostly read-only. That means they parallelize cleanly across multiple subagents, each owning a slice of the problem, all running concurrently. The parent agent waits for all results and synthesizes.

Use this when the investigation is non-trivial (more than a 30-second signature lookup). For trivial cases, a single subagent or inline work is faster than the orchestration overhead.

## The four-way fan-out

Split Phase 4 (source-spelunk) and Phase 6 (environment audit) across four subagents:

| Investigator | Owns | Reads | Returns |
|---|---|---|---|
| **A — Signature & package source** | The actual type/function definition on disk; examples shipped with the package | `node_modules/<pkg>/`, `$GOMODCACHE/<pkg>@<v>/`, `~/.cargo/registry/src/.../<pkg>-<v>/`, `python -c "import <pkg>; print(<pkg>.__file__)"` | Exact signature, README usage block, examples directory contents, test file patterns |
| **B — Repo grep** | Existing call sites of the same API in the user's own codebase | `<PROJECT_ROOT>` | Every existing call site, with file paths and line numbers; whether they work or also fail |
| **C — Docs & changelog** | Version-pinned official docs, recent PRs touching the symbol, changelog between installed and latest | The package's documentation URL at the installed version, the GitHub repo's CHANGELOG.md / releases page, issues filtered by the error code | Doc page contents at the installed version, recent changes affecting the symbol, breaking-change notes |
| **D — GitHub real-world** | Production call sites in other repos on the same version | GitHub code search filtered by `language:<lang>`, sorted by recently indexed | Three real call sites with URLs, the dominant pattern, any divergent patterns worth noting |

These four don't overlap and don't depend on each other. Spawn them in the same turn.

## opencode invocation

The drop-in subagent ships at `agents/lsp-stuck-investigator.md`. Once installed at `.opencode/agent/lsp-stuck-investigator.md`, the primary agent invokes it via the `task` tool. To fan out, the primary agent makes four `task` calls in the same turn — opencode runs them as parallel child sessions and returns the results to the parent.

Example primary-agent reasoning trace:

```
The user hit TS2769 on `db.from('users').select(...)`. supabase-js v2.45.
I'll fan out:

task: lsp-stuck-investigator
  scope: Phase 4.1 only — signature & package source
  package: @supabase/supabase-js@2.45.0
  symbol: PostgrestQueryBuilder.select
  context: <full diagnostic + call site>

task: lsp-stuck-investigator
  scope: Phase 4.3 only — repo grep
  project_root: <ROOT>
  symbol: .from(...).select(
  context: <full diagnostic>

task: lsp-stuck-investigator
  scope: Phase 4.4 + 4.5 — docs & changelog
  package: @supabase/supabase-js@2.45.0
  installed_version: 2.45.0
  latest_version: <look up>
  context: <full diagnostic>

task: lsp-stuck-investigator
  scope: Phase 4.6 — GitHub real-world
  symbol: .from(...).select(
  language: typescript
  context: <full diagnostic>
```

After all four return, the parent synthesizes:

```
Cross-investigator findings:

A (signature): The .select() generic was changed in v2.40 to require an explicit Row type. Old shape: select<T = any>(). New shape: select<Row extends Record<string, unknown>>().

B (repo grep): Three existing call sites in this codebase, all on v2.30 patterns. None of them compile against the current v2.45 in node_modules — they're just not type-checked because they live in files with looser settings.

C (docs/changelog): v2.40 changelog explicitly notes the breaking change. Migration guide at <URL>.

D (GitHub real-world): Modern v2.45+ usage looks like: db.from('users').select<'users', UsersRow>('*'). Three examples confirm.

→ Diagnosis: post-v2.40 breaking change to .select() generic. The user's call signature is v2.30-shaped.
→ Fix: add the explicit Row type to the .select() call, regenerate types via `supabase gen types` if not done.
→ Adjacent: the three existing call sites also need migrating; flag them but don't fix silently.
```

### Permissions for the parent agent

For the primary agent to call `task` with the lsp-stuck-investigator subagent, the primary must allow it. Default `build` agent allows `task`; if using a custom primary, add to its frontmatter:

```yaml
permission:
  task:
    "lsp-stuck-investigator": allow
```

### Permissions for the subagent

The subagent file already declares read-only permissions (`edit: deny`, `write: deny`, destructive bash denied, `webfetch: allow`). Don't loosen these — the investigation phases don't need write access, and keeping the subagent read-only means parallel spawns can't race on file edits.

## Claude Code invocation

Same pattern via the Task tool. Spawn four Task calls in the same turn — Claude Code executes them concurrently.

```
Task(
  subagent_type="general-purpose",
  description="Signature & package source for @supabase/supabase-js@2.45.0 PostgrestQueryBuilder.select",
  prompt=<filled-in agent-prompt-template.md with Phase 4.1 scope>
)
Task(
  subagent_type="general-purpose",
  description="Repo grep for .from().select() patterns in <ROOT>",
  prompt=<filled-in template with Phase 4.3 scope>
)
Task(
  subagent_type="general-purpose",
  description="Docs & changelog for @supabase/supabase-js 2.30→2.45",
  prompt=<filled-in template with Phase 4.4+4.5 scope>
)
Task(
  subagent_type="general-purpose",
  description="GitHub real-world usage of supabase-js v2.45 .select()",
  prompt=<filled-in template with Phase 4.6 scope>
)
```

Four parallel reports arrive. Parent synthesizes the same way.

## When NOT to fan out

- The fix is likely a one-liner once any single signature is read → just spawn one investigator
- The error is "package not installed" or a typo → don't spawn at all
- You're working on a slow-loop CI where parallel calls cost meaningfully more than serial
- The four scopes would overlap heavily (e.g. all four would read the same file) — collapse to one

When in doubt, fan out. The orchestration overhead is small compared to the time saved by parallel I/O, and the cleaner context per subagent improves report quality.

## Synthesis rules

After all subagents return:

1. **Reconcile.** Do A's signature claim, C's changelog claim, and D's real-world examples all agree? If yes, you have a triangulated diagnosis. If they disagree, name the disagreement explicitly — one of them is wrong or out of date.
2. **Resolve conflicts in favor of disk.** A's findings from on-disk source beat D's findings from random GitHub repos when they conflict. Real production code (D) beats blog posts; on-disk package source (A) beats real production code.
3. **Prefer the smallest fix.** If A's signature alone reveals the fix, you don't need B/C/D to agree before applying it — but their reports still go in the EVIDENCE section.
4. **Surface adjacent findings.** B will often find existing broken call sites the user didn't ask about. Mention them in one line; don't silently fix them.
5. **Synthesize once, return once.** Don't drip results from each subagent to the user — wait for all four, then return the structured report.
