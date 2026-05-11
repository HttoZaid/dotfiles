# Ecosystem notes

Where packages actually live on disk, the tool to dump a signature without leaving the terminal, and the error patterns each ecosystem is famous for. Read the section for the language at hand. Skip the rest.

## TypeScript / JavaScript

### Where source lives

- `node_modules/<pkg>/` — installed source (or compiled output + `.d.ts`)
- `node_modules/<pkg>/package.json` — read `"types"`, `"main"`, `"exports"` for entry points
- `node_modules/.pnpm/<pkg>@<version>/node_modules/<pkg>/` — pnpm layout
- Bun uses the standard `node_modules/` layout

### Reading signatures

```bash
$EDITOR node_modules/<pkg>/dist/index.d.ts

npx tsc --noEmit --traceResolution 2>&1 | rg <pkg>

rg "export (type|interface|function|const) <Symbol>" node_modules/<pkg>/
```

### Common errors and what they actually mean

| Code | Meaning |
|---|---|
| `TS2345` "Argument of type X is not assignable to parameter of type Y" | Y is *narrower* than X. Narrow X with a type guard, or the API wants a different shape — check the signature. |
| `TS2322` "Type X is not assignable to type Y" | Same for assignments. Often a missing required property. |
| `TS2769` "No overload matches this call" | The function has multiple signatures; none of yours matches. Read all overloads in `.d.ts`, pick the right one, match exactly. |
| `TS2307` "Cannot find module X" | Not installed, no `@types/X`, or wrong `moduleResolution` in tsconfig. Check `node_modules/X` exists. |
| `TS2339` "Property X does not exist on type Y" | Either it really doesn't, or you've narrowed Y too far up the call stack. |
| `TS2742` "Inferred type of X cannot be named..." | Almost always a `paths`/exports issue with a transitive type. Fix with an explicit type annotation at the export site. |
| `TS2589` "Type instantiation is excessively deep" | Recursive generic ran out of budget. Pin the generic or add a base case. |

### Where examples live

- `node_modules/<pkg>/README.md`
- `node_modules/<pkg>/examples/`
- The source repo on GitHub (`package.json` → `"repository"`). The repo has more docs than the tarball.

### Version pin

```bash
node -e "console.log(require('<pkg>/package.json').version)"
bun pm ls | rg <pkg>
```

## Go

### Where source lives

- `$(go env GOMODCACHE)/<module>@<version>/`
- `vendor/<module>/` if vendored

### Reading signatures

```bash
go doc -all <pkg>
go doc <pkg>.<Symbol>
go doc -src <pkg>.<Symbol>

find "$(go env GOMODCACHE)/<module>@<version>" -name '*.go' | xargs rg "func <Symbol>"
```

### Common errors

| Error | Meaning |
|---|---|
| `cannot use X (type T1) as type T2 in argument to Y` | Type mismatch. Go is structural for interfaces, nominal for concrete types. If T2 is an interface, T1 needs the methods; if concrete, T1 must *be* T2. |
| `X undefined (type T has no field or method X)` | Method set issue. Pointer methods don't satisfy value receivers. Check whether you hold `T` or `*T`. |
| `cannot find package X` | Module not added (`go get`), wrong path, or `GOPATH` issue. `go mod tidy` first. |
| `ambiguous import` | Two paths to the same package. Usually vendored fighting module-cache. |
| `package X is not in std` | Stdlib path doesn't exist (typo) or Go version too old. |

### Where examples live

- `<pkg>/README.md`
- `<pkg>/example_test.go`, `<pkg>/example_*_test.go` — Go convention for runnable examples
- `<pkg>/cmd/<binary>/` — real CLI usage
- `go doc -all <pkg>` surfaces example output

### Version pin

```bash
go list -m -json <module>
rg "<module>" go.mod
```

## Rust

### Where source lives

- `~/.cargo/registry/src/index.crates.io-<hash>/<pkg>-<version>/`
- `~/.cargo/git/checkouts/<pkg>-<hash>/<rev>/` for git deps

### Reading signatures

```bash
cargo doc --open

rg "(pub )?(fn|struct|enum|trait) <Symbol>" ~/.cargo/registry/src/*/<pkg>-*/src/
```

### Common errors

| Error | Meaning |
|---|---|
| `E0277` "the trait bound X: Y is not satisfied" | A trait isn't implemented. Implement it, derive it, or change the generic constraint. Read what trait the function actually requires. |
| `E0382` "borrow of moved value" | Ownership moved earlier. Clone, borrow, or restructure. |
| `E0502` "cannot borrow X as mutable because it is also borrowed as immutable" | Narrow the scope of one borrow. |
| `E0599` "no method named X found for type T" | Method needs a trait imported (`use trait::T`), or T is the wrong type. |
| `E0308` "mismatched types" | Read *expected* vs *found* — Rust tells you both. |
| `E0106` "missing lifetime specifier" | The return type references borrowed data; tell the compiler whose lifetime to use. |

### Where examples live

- `<pkg>/README.md`
- `<pkg>/examples/` — `cargo run --example <name>`
- `<pkg>/tests/`
- `cargo doc` for `///` doc-comments with examples

## Python

### Where source lives

```bash
python -c "import <pkg>; print(<pkg>.__file__)"
python -c "import site; print(site.getsitepackages())"
```

- `<venv>/lib/python*/site-packages/<pkg>/`
- `~/.local/lib/python*/site-packages/<pkg>/`

### Reading signatures

```bash
python -c "import <pkg>; help(<pkg>.<symbol>)"

find $(python -c "import site; print(site.getsitepackages()[0])") -name '*.pyi' | rg <pkg>

python -c "import inspect, <pkg>; print(inspect.getsource(<pkg>.<symbol>))"
```

### Common errors (Pyright / mypy)

| Error | Meaning |
|---|---|
| `reportGeneralTypeIssues` "X is not assignable to Y" | Often `Optional[T]` vs `T` — forgot to check for `None`. |
| `reportAttributeAccessIssue` "Cannot access attribute X" | Either dynamic (use `cast` or fix the type), or doesn't exist on Y. |
| `reportArgumentType` | Argument mismatch. Read the `.pyi` stub. |
| `reportMissingImports` | Package not installed in Pyright's env. Check the venv. |
| `Cannot determine type of "X"` | Forward reference or untyped call. Add an annotation. |

### Where examples live

- `<pkg>/README.md` or `README.rst`
- `<pkg>/examples/` or `<pkg>/docs/examples/`
- `<pkg>/tests/`
- `pyproject.toml` → `[project.urls]` for the docs URL

## Ruby

- `$(bundle info <gem> --path)` → gem source on disk
- `<gem>/README.md`, `<gem>/lib/`, `<gem>/spec/` or `<gem>/test/`
- `ri <Class>#<method>` for signatures
- Sorbet errors: `T::Sig::ArgumentError` family — read the `sig` block above the method

## Cross-ecosystem: GitHub code search

When on-disk sources aren't enough, GitHub code search beats web search for real call sites.

```
https://github.com/search?q=<distinctive-import>+<function-name>&type=code
```

Add `language:<lang>`. Sort by recently indexed. Skip tutorial repos — look for application code. Distinctive imports help: `from fancy_lib import very_specific_thing` is a better search than `import fancy_lib`.

## Cross-ecosystem: changelog trick

When a function "doesn't work like it used to," check the package's `CHANGELOG.md` or GitHub releases for the version range between what the user has and `latest`. Breaking changes are usually labeled. Faster than diffing source.

## Cross-ecosystem: lockfile bisect

When code is unchanged but behavior changed, the lockfile is the suspect.

```bash
git log -p -- bun.lock      # or package-lock.json / go.sum / Cargo.lock / uv.lock
git diff HEAD~5 HEAD -- <lockfile>
```

Often the answer is right there.
