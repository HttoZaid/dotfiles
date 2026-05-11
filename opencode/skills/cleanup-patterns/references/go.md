
# Go — Advanced Production Quality, p99 Performance, and Cleanup

Use this file when the user is working on Go services, APIs, CLIs, workers, libraries, concurrency, memory, latency, database access, error design, package layout, testing, observability, or production cleanup.

This is not beginner Go advice. Prefer boring code, explicit ownership, small packages with real cohesion, measurable performance, p95/p99 thinking, clean cancellation, and clear error contracts.

---

## 5.1 Rule zero: do not optimize from vibes

**Rule:** Profile before optimizing.

Use:
- benchmarks for local hot functions
- `pprof` for CPU/heap/block/mutex profiles
- `go test -bench`
- `go test -run=^$ -bench=. -benchmem`
- execution traces for scheduler/goroutine issues
- production metrics for p50/p95/p99 latency
- logs/traces for slow request paths

Basic commands:

```bash
go test -run=^$ -bench=. -benchmem ./...
go test -run=^$ -bench=BenchmarkFoo -cpuprofile cpu.out -memprofile mem.out ./pkg/foo
go tool pprof cpu.out
go tool pprof mem.out
````

HTTP pprof for services:

```go
import _ "net/http/pprof"
```

Expose pprof only on an internal/admin listener, never on the public internet.

Rules:

* p50 tells normal experience.
* p95 tells common tail pain.
* p99 tells worst regular pain.
* Average latency hides user pain.
* Allocation count often matters more than raw CPU.
* One slow dependency dominates request latency.
* Measure before and after.

---

## 5.2 p50 / p95 / p99 thinking

Performance work must name the percentile.

Use:

* **p50** for normal path health
* **p95** for common tail health
* **p99** for worst regular user experience
* **max** only for debugging spikes, not product promises

Bad:

```text
API is fast.
```

Better:

```text
GET /orders p50=18ms p95=90ms p99=240ms over 30 minutes.
```

Rules:

* Every critical endpoint needs latency histograms.
* Track DB time separately from handler time.
* Track queue time separately from work time.
* Track external service time separately.
* Track error rate with latency.
* Optimize p99 by removing variance, not only by speeding the happy path.

Common p99 killers:

* unbounded goroutines
* unbounded DB queries
* missing timeouts
* cold caches
* lock contention
* GC pressure
* oversized JSON payloads
* N+1 queries
* connection pool starvation
* slow downstream services
* log sinks blocking request path

---

## 5.3 Package layout — simple until pressure exists

Do not cargo-cult huge layouts.

Simple single binary:

```text
myservice/
  go.mod
  main.go
  handler.go
  store.go
```

Multiple commands:

```text
myservice/
  go.mod
  cmd/
    api/main.go
    worker/main.go
  internal/
    auth/
    orders/
    billing/
    platform/
```

Library plus command:

```text
mylib/
  go.mod
  mylib.go
  internal/
    parser/
  cmd/
    mylib/main.go
```

Rules:

* Use `internal/` for private service code.
* Use `cmd/<name>/main.go` when there are multiple binaries.
* Avoid `pkg/` unless there is a real public package story.
* Avoid `common`, `util`, `helpers`, `shared`, and `models`.
* Name packages after what they provide.
* Keep package APIs small.
* Prefer fewer, cohesive packages over many fake-clean packages.

Bad:

```text
internal/
  models/
  services/
  helpers/
  utils/
```

Better:

```text
internal/
  orders/
  payments/
  auth/
  postgres/
```

---

## 5.4 Package design: cohesion over tiny files

Go does not reward Java-style file explosions.

Rules:

* Package names are short and meaningful.
* Files can be large if cohesive.
* Avoid one type per file as a hard rule.
* Put related tests near related code.
* Keep exported API tiny.
* Unexport everything until needed.
* Declare things close to use.
* Do not create packages just to reduce file length.

Good:

```text
internal/orders/
  handler.go
  service.go
  store.go
  errors.go
  service_test.go
```

Suspicious:

```text
internal/orders/
  interfaces/
  implementations/
  dto/
  constants/
  helpers/
```

If a package name needs `manager`, `helper`, `common`, or `util`, it probably lacks a real concept.

---

## 5.5 Interfaces — consumer owns the interface

**Rule:** Accept interfaces, return concrete types.

Bad producer-defined interface:

```go
package storage

type Store interface {
	Get(ctx context.Context, id string) (*Job, error)
	Create(ctx context.Context, job *Job) error
	Update(ctx context.Context, job *Job) error
	Delete(ctx context.Context, id string) error
}

type PostgresStore struct{}

func NewPostgresStore() Store {
	return &PostgresStore{}
}
```

Better:

```go
package storage

type PostgresStore struct {
	db *sql.DB
}

func NewPostgresStore(db *sql.DB) *PostgresStore {
	return &PostgresStore{db: db}
}
```

Consumer defines the small interface it needs:

```go
package api

type JobStore interface {
	Get(ctx context.Context, id string) (*Job, error)
	Create(ctx context.Context, job *Job) error
}

type Server struct {
	store JobStore
}

func NewServer(store JobStore) *Server {
	return &Server{store: store}
}
```

Rules:

* Return structs from constructors.
* Define interfaces where they are consumed.
* Keep interfaces tiny.
* Do not create interfaces just for mocking.
* Use concrete types until a boundary appears.
* If an interface has 8 methods, it is probably too broad.

Exceptions:

* behavior-first stdlib-style interfaces like `io.Reader`
* packages that intentionally expose multiple implementations
* plugin/driver APIs

---

## 5.6 Error design

**Rule:** Errors are API contracts.

Use:

* plain errors for simple internal failures
* sentinel errors for stable matchable states
* custom error types when callers need fields
* wrapping with `%w` when callers may inspect the cause
* wrapping with `%v` when hiding the cause is intentional

Sentinel:

```go
var ErrNotFound = errors.New("orders: not found")
```

Wrapping:

```go
order, err := store.Get(ctx, id)
if err != nil {
	return fmt.Errorf("getting order %s: %w", id, err)
}
```

Caller:

```go
if errors.Is(err, orders.ErrNotFound) {
	http.Error(w, "not found", http.StatusNotFound)
	return
}
```

Custom error type:

```go
type ValidationError struct {
	Field string
	Err   error
}

func (e *ValidationError) Error() string {
	return fmt.Sprintf("invalid %s: %v", e.Field, e.Err)
}

func (e *ValidationError) Unwrap() error {
	return e.Err
}
```

Rules:

* Do not compare error strings.
* Do not prefix with `failed to`.
* Error strings should not start with capital letters unless proper nouns.
* Add context while returning upward.
* Handle errors once.
* Do not log and return the same error everywhere.
* Use `%w` only when exposing the wrapped error is part of the contract.
* Use `%v` when hiding implementation details.
* Library code should not call `log.Fatal`.

Bad:

```go
return fmt.Errorf("failed to failed to get user: %w", err)
```

Better:

```go
return fmt.Errorf("getting user %s: %w", id, err)
```

---

## 5.7 Panic policy

Panic only for:

* impossible programmer errors
* invariant violations
* startup failure in `main`
* test helpers that should stop the test immediately

Do not panic for:

* bad user input
* missing database rows
* network failures
* validation failures
* normal business conditions
* library-level errors

Bad:

```go
func GetUser(id string) User {
	user, err := db.Get(id)
	if err != nil {
		panic(err)
	}

	return user
}
```

Better:

```go
func GetUser(ctx context.Context, id string) (User, error) {
	user, err := db.Get(ctx, id)
	if err != nil {
		return User{}, fmt.Errorf("getting user %s: %w", id, err)
	}

	return user, nil
}
```

---

## 5.8 Context discipline

**Rule:** `context.Context` is the first parameter for work that can block, do I/O, call external systems, or be canceled.

Good:

```go
func (s *Service) GetOrder(ctx context.Context, id string) (Order, error) {
	return s.store.GetOrder(ctx, id)
}
```

Rules:

* First parameter: `ctx context.Context`.
* Never store context in a struct.
* Never pass `nil` context.
* Use `context.Background()` at process roots.
* Use request context in handlers.
* Use `context.WithTimeout` for external calls.
* Call the cancel function.
* Do not use context for optional parameters.
* Use context values only for request-scoped metadata.

Timeout:

```go
ctx, cancel := context.WithTimeout(ctx, 2*time.Second)
defer cancel()

order, err := store.GetOrder(ctx, id)
```

Bad:

```go
type Service struct {
	ctx context.Context
}
```

---

## 5.9 Database timeouts and pool health

Rules:

* Every DB call takes context.
* Every transaction takes context.
* Set query timeouts at the caller boundary.
* Configure connection pool limits intentionally.
* Track pool wait count/duration.
* Track query latency and rows scanned.
* Avoid N+1 queries.
* Avoid loading huge result sets into memory.
* Close rows.
* Check rows errors.

Good:

```go
rows, err := db.QueryContext(ctx, query, accountID)
if err != nil {
	return nil, fmt.Errorf("querying orders: %w", err)
}
defer rows.Close()

var orders []Order

for rows.Next() {
	var order Order
	if err := rows.Scan(&order.ID, &order.Total); err != nil {
		return nil, fmt.Errorf("scanning order: %w", err)
	}

	orders = append(orders, order)
}

if err := rows.Err(); err != nil {
	return nil, fmt.Errorf("iterating orders: %w", err)
}

return orders, nil
```

Transaction pattern:

```go
func WithTx(ctx context.Context, db *sql.DB, fn func(*sql.Tx) error) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}

	if err := fn(tx); err != nil {
		if rbErr := tx.Rollback(); rbErr != nil {
			return fmt.Errorf("rollback after %v: %w", err, rbErr)
		}

		return err
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("commit tx: %w", err)
	}

	return nil
}
```

Rules:

* Keep transactions short.
* Do not call slow external APIs inside DB transactions.
* Do not hold locks while doing network I/O.
* Prefer explicit transaction boundaries.

---

## 5.10 HTTP server quality

Server setup:

```go
srv := &http.Server{
	Addr:              ":8080",
	Handler:           routes,
	ReadHeaderTimeout: 5 * time.Second,
	ReadTimeout:       10 * time.Second,
	WriteTimeout:      30 * time.Second,
	IdleTimeout:       120 * time.Second,
	MaxHeaderBytes:    1 << 20,
}
```

Rules:

* Always configure server timeouts.
* Limit request body sizes.
* Decode JSON carefully.
* Return consistent error bodies.
* Do not leak internal errors to clients.
* Include request IDs in logs.
* Separate handler, service, and store logic.
* Handlers translate transport to domain.
* Services own business logic.
* Stores own persistence.

Handler shape:

```go
func (h *Handler) GetOrder(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	id, err := parseOrderID(r)
	if err != nil {
		writeError(w, http.StatusBadRequest, "invalid order id")
		return
	}

	order, err := h.service.GetOrder(ctx, id)
	if err != nil {
		h.writeOrderError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, order)
}
```

---

## 5.11 JSON performance and safety

Rules:

* Limit request body size.
* Reject unknown fields for strict APIs.
* Validate decoded payloads.
* Do not decode into `map[string]any` unless truly dynamic.
* Avoid double marshal/unmarshal.
* Avoid huge JSON payloads on p99-sensitive endpoints.
* Consider streaming for large payloads.
* Consider codegen/alternative encoders only after profiling.

Request decode:

```go
func decodeJSON[T any](w http.ResponseWriter, r *http.Request, dst *T) error {
	r.Body = http.MaxBytesReader(w, r.Body, 1<<20)

	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()

	if err := dec.Decode(dst); err != nil {
		return fmt.Errorf("decode json: %w", err)
	}

	if dec.More() {
		return errors.New("decode json: multiple json values")
	}

	return nil
}
```

Do not optimize away `encoding/json` until profiling proves it matters.

---

## 5.12 Concurrency: bounded, cancelable, observable

**Rule:** Every goroutine must have a lifetime story.

Bad:

```go
go func() {
	for {
		doWork()
	}
}()
```

Better:

```go
func runWorker(ctx context.Context, jobs <-chan Job) error {
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()

		case job, ok := <-jobs:
			if !ok {
				return nil
			}

			if err := handleJob(ctx, job); err != nil {
				return err
			}
		}
	}
}
```

Rules:

* Use `errgroup.WithContext` for fan-out.
* Bound concurrency.
* Respect cancellation.
* Avoid goroutine leaks.
* Do not spawn unbounded goroutines per request.
* Do not write to channels without a receiver plan.
* Prefer mutexes for protecting shared memory.
* Prefer channels for ownership transfer or coordination.
* Keep critical sections small.

Fan-out:

```go
g, ctx := errgroup.WithContext(ctx)
g.SetLimit(10)

for _, id := range ids {
	id := id

	g.Go(func() error {
		return process(ctx, id)
	})
}

if err := g.Wait(); err != nil {
	return fmt.Errorf("processing ids: %w", err)
}
```

---

## 5.13 Channels vs mutexes

Use a mutex when:

* multiple goroutines access shared memory
* state has clear ownership
* operation is simple and synchronous
* performance matters

Use a channel when:

* passing ownership of data
* coordinating stages
* worker pools
* fan-in/fan-out
* cancellation with select

Bad channel-as-mutex:

```go
lock := make(chan struct{}, 1)
lock <- struct{}{}
<-lock
```

Better:

```go
var mu sync.Mutex

mu.Lock()
defer mu.Unlock()
```

Rules:

* Do not use channels to look clever.
* Do not hold mutexes during network calls.
* Do not call unknown callbacks while holding a mutex.
* Use `sync.RWMutex` only when read-heavy and measured.
* Keep shared state small.

---

## 5.14 Memory and allocation discipline

Common allocation sources:

* string concatenation in loops
* converting `[]byte` to `string`
* large temporary slices
* repeated regexp compilation
* JSON marshal/unmarshal
* interface boxing
* `fmt.Sprintf` in hot paths
* capturing large values in closures
* maps without capacity hints
* appending without capacity hints

Rules:

* Use `-benchmem`.
* Reduce allocations in hot paths.
* Preallocate slices when size is known.
* Reuse buffers only when ownership is obvious.
* Use `sync.Pool` only for hot, proven allocation pressure.
* Do not use `sync.Pool` for correctness.
* Avoid premature micro-optimization outside hot paths.

Good:

```go
items := make([]Item, 0, len(rows))

for _, row := range rows {
	items = append(items, convert(row))
}
```

String builder:

```go
var b strings.Builder
b.Grow(estimatedSize)

for _, part := range parts {
	b.WriteString(part)
}

return b.String()
```

Regexp:

```go
var emailRE = regexp.MustCompile(`^[^@]+@[^@]+\.[^@]+$`)
```

Do not compile regex in a request loop.

---

## 5.15 GC and p99 latency

GC pressure often shows up as p99 latency.

Rules:

* Watch heap growth.
* Watch allocation rate.
* Watch object lifetime.
* Avoid retaining large slices accidentally.
* Avoid global caches without bounds.
* Avoid per-request giant allocations.
* Avoid logging huge objects.
* Avoid unbounded maps keyed by user/input.
* Prefer streaming for large data.

Slice retention trap:

```go
func firstKB(data []byte) []byte {
	return data[:1024]
}
```

This can retain the whole backing array.

Better when long-lived:

```go
func firstKB(data []byte) []byte {
	out := make([]byte, 1024)
	copy(out, data[:1024])
	return out
}
```

Rule:

* Copying can be cheaper than retaining huge memory.

---

## 5.16 Logging

Rules:

* Use structured logging.
* Log at boundaries.
* Do not log and return everywhere.
* Do not log secrets.
* Do not log huge payloads.
* Include request ID / trace ID.
* Include stable fields.
* Avoid formatting expensive log fields when disabled.
* Keep p99 paths free of blocking log sinks.

Good:

```go
logger.ErrorContext(ctx, "get order failed",
	"order_id", id,
	"error", err,
)
```

Bad:

```go
log.Printf("failed to failed to get order %+v with payload %+v", err, hugePayload)
```

---

## 5.17 Observability

Minimum production signals:

* request count
* error count
* duration histogram
* p50/p95/p99
* DB query duration
* external call duration
* queue depth
* worker lag
* goroutine count
* heap allocation
* GC pauses
* panic count
* dependency error rate

Rules:

* Instrument boundaries.
* Use histograms for latency.
* Add labels carefully.
* Avoid high-cardinality labels like raw user ID, email, path params.
* Trace slow critical flows.
* Correlate logs with traces.

Bad metric label:

```text
user_id="123456"
```

Better:

```text
route="/orders/{id}"
status="200"
```

---

## 5.18 Dependency injection

Default: manual constructor injection.

Good:

```go
type Service struct {
	store  Store
	clock  Clock
	logger *slog.Logger
}

func NewService(store Store, clock Clock, logger *slog.Logger) *Service {
	return &Service{
		store:  store,
		clock:  clock,
		logger: logger,
	}
}
```

Rules:

* Wire dependencies in `main`.
* Constructors should be boring.
* Avoid global mutable dependencies.
* Avoid service locators.
* Use Wire only when manual wiring is genuinely painful.
* Use Fx only for large services needing lifecycle modules.
* Do not hide dependency graphs in magic.

---

## 5.19 Configuration

Rules:

* Parse config once at startup.
* Validate config once.
* Store typed config.
* Do not read env variables everywhere.
* Do not use package globals for mutable config.
* Do not put secrets in logs.
* Split config from runtime state.

Good:

```go
type Config struct {
	Addr        string
	DatabaseURL string
	ReadTimeout time.Duration
}

func LoadConfig() (Config, error) {
	cfg := Config{
		Addr:        getenv("ADDR", ":8080"),
		DatabaseURL: os.Getenv("DATABASE_URL"),
		ReadTimeout: 5 * time.Second,
	}

	if cfg.DatabaseURL == "" {
		return Config{}, errors.New("DATABASE_URL is required")
	}

	return cfg, nil
}
```

---

## 5.20 Testing strategy

Use:

* unit tests for pure logic
* table tests for branches
* integration tests for DB/external dependencies
* race tests for concurrency
* benchmarks for hot paths
* fuzz tests for parsers
* contract tests for public APIs

Table test:

```go
func TestParseStatus(t *testing.T) {
	t.Parallel()

	tests := map[string]struct {
		input string
		want  Status
		ok    bool
	}{
		"active":   {input: "active", want: StatusActive, ok: true},
		"unknown":  {input: "wat", ok: false},
		"empty":    {input: "", ok: false},
	}

	for name, tc := range tests {
		tc := tc

		t.Run(name, func(t *testing.T) {
			t.Parallel()

			got, ok := ParseStatus(tc.input)

			if ok != tc.ok {
				t.Fatalf("ok = %v, want %v", ok, tc.ok)
			}

			if got != tc.want {
				t.Fatalf("status = %v, want %v", got, tc.want)
			}
		})
	}
}
```

Rules:

* Use `t.Parallel()` intentionally.
* Use map test cases when order should not matter.
* Use slices when order matters.
* Do not overuse mocks.
* Prefer small consumer-defined interfaces.
* Do not assert error strings unless the string is the API.
* Use `errors.Is` / `errors.As`.

---

## 5.21 Race, leak, and concurrency testing

Commands:

```bash
go test -race ./...
```

Use leak checks for goroutine-heavy packages:

```go
func TestMain(m *testing.M) {
	goleak.VerifyTestMain(m)
}
```

Rules:

* Race tests should run in CI, at least on important packages.
* Every background goroutine in tests needs cancellation.
* Every test server should close.
* Every channel should have a shutdown story.
* Use timeouts to avoid hanging CI.
* Do not sleep blindly in tests.

Bad:

```go
time.Sleep(100 * time.Millisecond)
```

Better:

* wait on channel
* use context timeout
* use eventually/assert loop with deadline

---

## 5.22 Benchmarks

Benchmark hot code only.

```go
func BenchmarkEncodeOrder(b *testing.B) {
	order := testOrder()

	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		_, err := EncodeOrder(order)
		if err != nil {
			b.Fatal(err)
		}
	}
}
```

Rules:

* Use `b.ReportAllocs()`.
* Prevent compiler elimination.
* Benchmark realistic payloads.
* Keep setup outside timed loop.
* Compare with `benchstat`.
* Do not optimize code nobody calls.

Use:

```bash
go test -run=^$ -bench=. -benchmem ./...
benchstat old.txt new.txt
```

---

## 5.23 Linting and static analysis

Recommended `golangci-lint` baseline:

```yaml
version: "2"

linters:
  enable:
    - errcheck
    - govet
    - staticcheck
    - unused
    - ineffassign
    - bodyclose
    - contextcheck
    - errorlint
    - exhaustive
    - gocyclo
    - misspell
    - nilerr
    - prealloc
    - revive
    - tparallel
    - thelper
    - unconvert
    - unparam
    - wastedassign

linters-settings:
  gocyclo:
    min-complexity: 15
```

Rules:

* Start with bug-catching linters.
* Add style linters after team buy-in.
* CI should fail on real correctness issues.
* Do not add noisy linters nobody respects.
* Never ignore lint without a reason.

High-value:

* `errcheck`
* `staticcheck`
* `govet`
* `bodyclose`
* `contextcheck`
* `errorlint`
* `nilerr`
* `unused`

---

## 5.24 API design

Rules:

* Keep exported API small.
* Prefer options structs over long parameter lists.
* Avoid boolean parameters.
* Return concrete types unless interface is intentional.
* Accept context for blocking operations.
* Document concurrency safety.
* Document ownership of slices/maps.
* Do not expose internal implementation types.

Bad:

```go
func NewClient(url string, timeout time.Duration, retries int, debug bool, secure bool) *Client
```

Better:

```go
type ClientConfig struct {
	URL     string
	Timeout time.Duration
	Retries int
	Debug   bool
	Secure  bool
}

func NewClient(cfg ClientConfig) (*Client, error)
```

For optional configuration:

```go
type Option func(*Client)

func WithTimeout(timeout time.Duration) Option {
	return func(c *Client) {
		c.timeout = timeout
	}
}
```

Use functional options for libraries with many optional settings. For app code, a config struct is often clearer.

---

## 5.25 Generics

Use generics for:

* containers
* reusable algorithms
* typed helpers
* reducing duplicated type-safe code

Do not use generics for:

* hiding unclear design
* replacing simple interfaces
* building framework magic
* avoiding explicit domain types

Good:

```go
func Ptr[T any](v T) *T {
	return &v
}
```

Suspicious:

```go
type Manager[TRepository, TEntity, TEvent, TConfig any] struct {
	// nobody wants this
}
```

Rules:

* Keep constraints small.
* Prefer concrete code when only used once.
* Avoid generic abstractions around business workflows.
* Do not copy Java/C# repository generic patterns.

---

## 5.26 Worker systems and queues

Rules:

* Bound concurrency.
* Track queue depth.
* Track job duration.
* Track retry count.
* Use context cancellation.
* Use idempotency keys for retryable jobs.
* Do not retry forever without backoff and dead-letter handling.
* Keep job payloads small.
* Store large payloads externally and pass references.
* Make shutdown graceful.

Worker pool:

```go
func RunWorkers(ctx context.Context, n int, jobs <-chan Job, handle func(context.Context, Job) error) error {
	g, ctx := errgroup.WithContext(ctx)

	for i := 0; i < n; i++ {
		g.Go(func() error {
			for {
				select {
				case <-ctx.Done():
					return ctx.Err()

				case job, ok := <-jobs:
					if !ok {
						return nil
					}

					if err := handle(ctx, job); err != nil {
						return err
					}
				}
			}
		})
	}

	return g.Wait()
}
```

---

## 5.27 Graceful shutdown

Rules:

* Stop accepting new work.
* Cancel background contexts.
* Let in-flight requests finish within deadline.
* Close queues/workers.
* Close DB connections.
* Flush logs/traces.
* Exit non-zero on failed startup.

HTTP shutdown:

```go
ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
defer stop()

go func() {
	if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		logger.Error("server failed", "error", err)
	}
}()

<-ctx.Done()

shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()

if err := srv.Shutdown(shutdownCtx); err != nil {
	logger.Error("shutdown failed", "error", err)
}
```

---

## 5.28 Security basics that affect code quality

Rules:

* Set HTTP timeouts.
* Limit request body size.
* Validate input.
* Avoid SQL string concatenation.
* Escape output in templates.
* Do not log secrets.
* Do not expose pprof publicly.
* Use constant-time compare for secrets.
* Keep dependencies updated.
* Run vulnerability scans.
* Avoid path traversal by cleaning/validating file paths.

SQL bad:

```go
query := "SELECT * FROM users WHERE id = " + id
```

Better:

```go
row := db.QueryRowContext(ctx, "SELECT * FROM users WHERE id = $1", id)
```

---

## 5.29 Cleanup playbooks

### Slow API endpoint cleanup

1. Check p50/p95/p99.
2. Split handler latency into app, DB, external calls, queue.
3. Check context timeouts.
4. Check DB query plans.
5. Check N+1 calls.
6. Check connection pool wait.
7. Add pprof sample under load.
8. Reduce allocations if GC appears in tail.
9. Bound concurrency.
10. Re-measure.

### Memory spike cleanup

1. Capture heap profile.
2. Check top allocators.
3. Check retained objects.
4. Look for large slices/maps.
5. Look for unbounded caches.
6. Look for goroutine leaks.
7. Check JSON payload sizes.
8. Stream or chunk large data.
9. Add bounds.
10. Re-measure.

### Goroutine leak cleanup

1. Count goroutines over time.
2. Capture goroutine profile.
3. Find blocked channel sends/receives.
4. Add context cancellation.
5. Close channels from sender side.
6. Use errgroup.
7. Add leak test.
8. Re-run under cancellation.

### Error cleanup

1. List exported errors.
2. Replace string comparisons with `errors.Is` / `errors.As`.
3. Add sentinel or custom types where callers need matching.
4. Wrap with context.
5. Remove duplicate logging.
6. Keep transport error mapping in handler layer.
7. Add tests for error classification.

### Package cleanup

1. Find `util`, `common`, `helper`, `models`.
2. Group functions by actual domain.
3. Move code to owning package.
4. Unexport symbols.
5. Delete dead abstractions.
6. Break import cycles.
7. Add package docs only for public packages.

---

## 5.30 Performance review checklist

Before merging performance-sensitive Go code, check:

* Does every I/O path accept context?
* Are timeouts set?
* Is concurrency bounded?
* Are errors wrapped with useful context?
* Is p99 affected by DB/external calls?
* Are request bodies limited?
* Are rows closed?
* Are response bodies closed?
* Are goroutines cancelable?
* Are channels closed by the sender?
* Are allocations measured in hot paths?
* Are maps/slices preallocated when size is known?
* Are logs safe and bounded?
* Are metrics low-cardinality?
* Is pprof available safely?
* Is the change benchmarked if performance is claimed?
* Does this add a dependency for trivial code?
* Does it create an interface before a consumer needs it?
* Does it use global mutable state?

---

## 5.31 Anti-patterns to refuse

Refuse or strongly push back on:

* public pprof endpoints
* no HTTP server timeouts
* DB calls without context
* goroutines without cancellation
* unbounded goroutines per request
* channels used as clever mutexes
* global mutable service state
* service locator patterns
* `panic` for normal errors
* comparing error strings
* logging and returning the same error everywhere
* swallowing errors with `_`
* `interface{}` instead of `any` in modern Go
* producer-defined interfaces with many methods
* `util`, `common`, `helper`, `shared` packages
* package layouts copied from web templates without pressure
* huge request/response payloads in p99-sensitive APIs
* `time.Sleep` in tests
* benchmarks without `-benchmem`
* optimizing without profile/benchmark evidence
* caches without size/TTL/eviction
* maps keyed by unbounded user input with no cleanup
* holding locks during network calls
* transactions around external API calls
* dependency injection frameworks for small apps

---

## 5.32 Escalation thresholds

| Symptom                           | Action                                           |
| --------------------------------- | ------------------------------------------------ |
| p99 much higher than p50          | Investigate variance: DB, locks, GC, downstreams |
| Endpoint p95 > budget             | Add tracing and split latency by dependency      |
| Goroutine count grows forever     | Capture goroutine profile and add cancellation   |
| Heap grows after steady traffic   | Capture heap profile and inspect retention       |
| DB pool wait increases            | Tune pool, reduce query time, fix leaks          |
| Handler has business logic        | Move to service layer                            |
| Service imports HTTP package      | Split transport from application logic           |
| Store imports handler/API package | Fix dependency direction                         |
| Interface has >5 methods          | Split by consumer need                           |
| Package named util/common         | Rename or split by concept                       |
| Test needs huge mock              | Consumer interface is too broad                  |
| Benchmark claims improvement      | Require benchstat                                |
| New goroutine introduced          | Require shutdown/cancellation story              |
| New cache introduced              | Require bounds and invalidation story            |
| Function has >4 parameters        | Use config/params struct                         |

---

## 5.33 Source families

Use these when validating or updating this file:

* Effective Go
* Go Code Review Comments
* Go diagnostics and pprof docs
* Go execution tracer docs
* Go context docs
* database/sql docs
* net/http docs
* Uber Go Style Guide
* Google Go Style Guide
* staticcheck docs
* golangci-lint docs
* errgroup docs
* OpenTelemetry Go docs
* Prometheus Go client docs
* benchstat docs

