
# PHP — Advanced Backend Quality, Performance, and Cleanup

Use this file when the user is working on PHP services, Composer packages, legacy PHP, Laravel/Symfony-neutral backend code, APIs, workers, queues, database performance, static analysis, security, or production cleanup.

This is not beginner PHP advice. Prefer typed PHP, static analysis, measurable performance, explicit boundaries, safe input handling, and boring code that survives production.

---

## 1. Rule zero: modern PHP is typed, analyzed, and profiled

PHP lets weak code run. A serious PHP codebase must compensate with:

- supported PHP versions
- `strict_types`
- explicit parameter and return types
- static analysis
- runtime validation at boundaries
- Composer hygiene
- OPcache in production
- safe database access
- escaping and sanitization
- tests around business logic
- profiling before performance claims

PHPStan scans PHP code to find bugs without running it, and Psalm focuses on finding type-related bugs, including `mixed` issues that can hide real problems. Use one of them in CI. :contentReference[oaicite:0]{index=0}

---

## 2. PHP version baseline

**Rule:** Use a currently supported PHP release. Do not build new production code on end-of-life PHP.

PHP release branches are fully supported for two years from the first stable release, then receive security support for a further period before end-of-life. Check the official supported versions page before setting the baseline. :contentReference[oaicite:1]{index=1}

Rules:
- New apps should target a current supported PHP version.
- Legacy apps should have an upgrade plan.
- Do not ignore deprecations; they are future breakages.
- Pin platform PHP in Composer.
- Run CI on the deployed PHP version.

Composer platform pin:

```json id="u97alu"
{
  "config": {
    "platform": {
      "php": "8.4.0"
    },
    "sort-packages": true
  }
}
````

---

## 3. `strict_types` and type declarations

**Rule:** New PHP files should start with `declare(strict_types=1);`.

```php id="qtrvq8"
<?php

declare(strict_types=1);

namespace App\Orders;

final readonly class Money
{
    public function __construct(
        public int $amountInCents,
        public string $currency,
    ) {}
}
```

Rules:

* Use parameter types.
* Use return types.
* Use property types.
* Use `readonly` where mutation is not needed.
* Use enums for finite states.
* Use value objects for important domain primitives.
* Avoid `mixed` outside controlled boundaries.
* Avoid docblock-only types when native types work.

Bad:

```php id="d1y1iz"
function createOrder($userId, $total, $status) {
    // anything goes
}
```

Better:

```php id="r5c07h"
function createOrder(
    UserId $userId,
    Money $total,
    OrderStatus $status,
): Order {
    // typed domain boundary
}
```

---

## 4. Coding style and formatting

Use PSR-12 or a clearly documented project standard. PSR-12 exists to reduce cognitive friction when reading code from different authors by defining shared formatting expectations. ([php-fig.org][1])

Recommended tooling:

* PHP CS Fixer
* PHP_CodeSniffer
* Laravel Pint when in Laravel
* Rector for automated modernization

Composer scripts:

```json id="m2v67e"
{
  "scripts": {
    "format": "php-cs-fixer fix",
    "format:check": "php-cs-fixer fix --dry-run --diff",
    "analyse": "phpstan analyse",
    "test": "phpunit"
  }
}
```

Rules:

* Formatting is automated, not discussed in review.
* Do not mix unrelated formatting changes with feature work.
* CI should fail if formatting/linting fails.
* Use one formatter rule set.

---

## 5. Static analysis: PHPStan or Psalm

**Rule:** Every serious PHP codebase needs static analysis.

PHPStan config:

```neon id="ccqbo0"
# phpstan.neon
parameters:
  level: 8
  paths:
    - src
    - tests
  checkMissingIterableValueType: true
  checkGenericClassInNonGenericObjectType: true
```

Psalm config should also be strict about `mixed` and type coverage. Psalm specifically warns about `mixed` because it can mask bugs. ([psalm.dev][2])

Rules:

* Start at a level the team can pass.
* Raise strictness over time.
* Do not baseline forever.
* Treat new static analysis errors as CI failures.
* Prefer fixing types over suppressing warnings.
* Every suppression needs a reason.

Bad:

```php id="oeeo1d"
/** @phpstan-ignore-next-line */
return $payload['user']['name'];
```

Better:

```php id="ho0lcv"
if (!is_array($payload) || !isset($payload['user']) || !is_array($payload['user'])) {
    throw InvalidPayload::missingUser();
}

$name = $payload['user']['name'] ?? null;

if (!is_string($name) || $name === '') {
    throw InvalidPayload::invalidName();
}

return $name;
```

---

## 6. Runtime validation at trust boundaries

**Rule:** External input is untrusted even if PHPStan is green.

Trust boundaries:

* HTTP request data
* JSON payloads
* uploaded files
* environment variables
* CLI args
* database rows from weak layers
* queue messages
* webhooks
* cache values
* session data
* third-party API responses

Bad:

```php id="7jmunv"
$userId = $_POST['user_id'];
$order = $repository->find($userId);
```

Better:

```php id="xwdabi"
$userId = UserId::fromString((string) ($_POST['user_id'] ?? ''));

$order = $repository->find($userId);
```

Rules:

* Validate shape.
* Validate type.
* Validate domain meaning.
* Convert into value objects early.
* Keep raw arrays near the boundary.
* Do not pass `$_POST`, `$_GET`, or raw decoded JSON deep into the app.

---

## 7. Arrays are not domain models

PHP arrays are fine for transport and simple lists. They are bad as long-lived domain models.

Bad:

```php id="cb96dg"
function charge(array $user, array $payment): array
{
    return [
        'status' => 'paid',
        'user_id' => $user['id'],
    ];
}
```

Better:

```php id="jkh1qw"
final readonly class ChargeRequest
{
    public function __construct(
        public UserId $userId,
        public Money $amount,
        public PaymentMethodId $paymentMethodId,
    ) {}
}

function charge(ChargeRequest $request): PaymentResult
{
    // explicit domain contract
}
```

Rules:

* Use DTOs for transport shape.
* Use value objects for domain meaning.
* Use entities for lifecycle/state.
* Use arrays for lists/maps, not business objects.
* Do not pass raw API arrays into templates or domain services.

---

## 8. Enums for finite state

Bad:

```php id="9q9aho"
if ($order['status'] === 'payed') {
    // typo survives
}
```

Better:

```php id="bk7rsx"
enum OrderStatus: string
{
    case Pending = 'pending';
    case Paid = 'paid';
    case Cancelled = 'cancelled';
    case Failed = 'failed';
}
```

Rules:

* Use enums for finite states.
* Avoid stringly typed workflows.
* Convert external strings to enums at boundaries.
* Handle unknown enum values explicitly.

```php id="sgm7y8"
$status = OrderStatus::tryFrom($rawStatus);

if ($status === null) {
    throw InvalidOrderStatus::fromValue($rawStatus);
}
```

---

## 9. Error and exception policy

**Rule:** Exceptions are for exceptional or boundary failures. Domain failures should be explicit when callers must branch on them.

Use exceptions for:

* infrastructure failure
* impossible state
* invalid trusted construction
* framework boundary errors

Use result-like objects/enums for:

* validation outcome
* payment declined
* authentication failed
* permission denied
* not found when normal
* business rule rejection

Example:

```php id="mb053a"
final readonly class PlaceOrderResult
{
    private function __construct(
        public bool $ok,
        public ?Order $order,
        public ?PlaceOrderFailure $failure,
    ) {}

    public static function success(Order $order): self
    {
        return new self(true, $order, null);
    }

    public static function failure(PlaceOrderFailure $failure): self
    {
        return new self(false, null, $failure);
    }
}
```

Rules:

* Do not catch `Throwable` unless at a true boundary.
* Do not swallow exceptions.
* Do not expose raw exception messages to users.
* Log once at the boundary.
* Use specific exception classes.
* Do not use exceptions for normal control flow in hot paths.

---

## 10. Composer hygiene

Rules:

* Commit `composer.lock` for applications.
* Libraries usually do not commit `composer.lock`.
* Use `composer audit`.
* Keep dependencies updated.
* Remove unused packages.
* Avoid packages for trivial helpers.
* Pin PHP platform.
* Sort packages.
* Prefer maintained packages with clear release history.
* Do not let dev dependencies leak into production autoload.

Useful commands:

```bash id="h8pzr2"
composer validate --strict
composer audit
composer outdated
composer dump-autoload --optimize
composer install --no-dev --prefer-dist --optimize-autoloader
```

Production install:

```bash id="jlt77f"
composer install \
  --no-dev \
  --prefer-dist \
  --optimize-autoloader \
  --classmap-authoritative
```

Caveat:

* `--classmap-authoritative` can break dynamic class discovery if the app relies on it. Use it when the framework/package setup supports it.

---

## 11. Autoload and filesystem performance

Rules:

* Use Composer PSR-4 autoloading.
* Keep namespaces aligned with paths.
* Optimize autoload in production.
* Avoid scanning huge directories at runtime.
* Avoid dynamic class names unless necessary.
* Avoid runtime `require` forests.
* Do not put thousands of unrelated classes into one namespace root.

Good:

```json id="mbv891"
{
  "autoload": {
    "psr-4": {
      "App\\": "src/"
    }
  }
}
```

After changing autoload:

```bash id="9blxkv"
composer dump-autoload
```

Production:

```bash id="m8dq08"
composer dump-autoload --optimize --classmap-authoritative
```

---

## 12. OPcache and production runtime

**Rule:** OPcache should be enabled in production.

The PHP manual says OPcache improves performance by storing precompiled script bytecode in shared memory, removing the need to load and parse scripts on each request. ([PHP][3])

Production-ish settings to evaluate:

```ini id="s3izzl"
opcache.enable=1
opcache.enable_cli=0
opcache.memory_consumption=256
opcache.max_accelerated_files=60000
opcache.validate_timestamps=0
opcache.save_comments=1
```

Rules:

* Enable OPcache in production.
* Size `opcache.memory_consumption` for the app.
* Size `opcache.max_accelerated_files` for file count.
* Disable timestamp validation only if deployment resets/reloads OPcache correctly.
* Do not enable JIT expecting magic speedups for I/O-heavy web apps.
* Measure JIT for CPU-heavy workloads.

JIT caveat:

* JIT can help CPU-bound code.
* Most PHP web apps are I/O-bound: database, network, cache, templates.
* Profile before enabling JIT as a performance fix.

---

## 13. Request performance model

Most PHP web slowness comes from:

* database queries
* N+1 queries
* remote API calls
* slow filesystem/cache access
* cold autoload/opcache
* template rendering with too much work
* large JSON serialization
* inefficient loops over huge arrays
* session locks
* unbounded middleware
* logging inside hot paths

Optimize in this order:

1. reduce database work
2. remove N+1 queries
3. cache safe expensive reads
4. reduce payload size
5. optimize autoload/opcache
6. remove unnecessary middleware/work
7. profile CPU hot paths
8. only then micro-optimize PHP syntax

Rule:

* If the database is 90% of request time, rewriting loops will not save the endpoint.

---

## 14. Database access

Rules:

* Use prepared statements.
* Avoid string concatenated SQL.
* Add indexes for query patterns.
* Avoid N+1 queries.
* Limit selected columns.
* Paginate large result sets.
* Stream/chunk large exports.
* Keep transactions short.
* Do not call external APIs inside transactions.
* Log slow queries with context.

Bad:

```php id="qkskg0"
$sql = "SELECT * FROM users WHERE id = " . $_GET['id'];
```

Better with PDO:

```php id="y269x2"
$stmt = $pdo->prepare('SELECT id, email, name FROM users WHERE id = :id');
$stmt->execute(['id' => $userId->toString()]);

$row = $stmt->fetch(PDO::FETCH_ASSOC);
```

Rules:

* Never trust request values in SQL.
* Do not select `*` by default.
* Convert database rows to typed objects at the boundary.
* Treat `false` from fetch as a real case.

---

## 15. N+1 query cleanup

Bad:

```php id="4x5oph"
$orders = $orderRepository->all();

foreach ($orders as $order) {
    $customer = $customerRepository->find($order->customerId);
    echo $customer->name;
}
```

Better:

```php id="0u4j6x"
$orders = $orderRepository->all();
$customerIds = array_map(
    static fn (Order $order): CustomerId => $order->customerId,
    $orders,
);

$customersById = $customerRepository->findManyIndexed($customerIds);

foreach ($orders as $order) {
    echo $customersById[$order->customerId->toString()]->name;
}
```

Rules:

* Batch lookups.
* Eager-load intentionally.
* Add query count assertions for critical endpoints.
* Review loops that call repositories.
* Cache stable lookups per request.

---

## 16. Memory safety

PHP request-per-process hides some leaks, but workers do not.

Watch memory in:

* queue workers
* daemons
* WebSocket servers
* RoadRunner/Swoole/FrankenPHP/Laravel Octane
* large imports/exports
* image processing
* CSV processing
* report generation

Rules:

* Avoid loading huge files into memory.
* Stream large files.
* Chunk database reads.
* Free large references in long-running workers.
* Reset per-request state in persistent workers.
* Avoid static caches without bounds.
* Monitor memory growth over time.

Bad:

```php id="3yyr1d"
$rows = $repository->fetchAllRowsForExport();
```

Better:

```php id="2m3n2h"
foreach ($repository->streamRowsForExport() as $row) {
    $writer->write($row);
}
```

---

## 17. Long-running worker rules

Traditional PHP resets state every request. Long-running workers do not.

Rules:

* No request-specific static/global state.
* Reset services that hold per-request data.
* Close/recycle stale DB connections.
* Clear entity managers/unit-of-work between jobs.
* Bound memory per job.
* Restart workers after max jobs/time/memory if needed.
* Make jobs idempotent.
* Use backoff and dead-letter queues.
* Do not retry forever.

Bad:

```php id="sp5524"
final class CurrentUser
{
    public static ?User $user = null;
}
```

That can leak user state between requests/jobs in persistent runtimes.

Better:

* request-scoped context object
* explicit dependency passing
* framework-supported request scope

---

## 18. Caching

Use caching for expensive, stable, safe-to-reuse data.

Rules:

* Cache by explicit key.
* Include all inputs in the key.
* Set TTLs.
* Invalidate on writes when needed.
* Avoid caching permission-specific data under global keys.
* Avoid unbounded local static caches.
* Cache final read models when possible.
* Do not cache broken behavior to hide slow code.

Bad:

```php id="19ihfr"
Cache::set('user', $user);
```

Better:

```php id="48urro"
Cache::set(
    sprintf('user:%s:v1', $userId->toString()),
    $user,
    ttl: 300,
);
```

Rules:

* Version cache keys when shape changes.
* Never cache secrets accidentally.
* Avoid stampedes with locks or stale-while-revalidate where supported.

---

## 19. Security basics

Rules:

* Validate input.
* Escape output.
* Use prepared statements.
* Hash passwords with `password_hash`.
* Verify passwords with `password_verify`.
* Use CSRF protection for state-changing browser requests.
* Check authorization at the boundary.
* Do not trust hidden fields.
* Do not unserialize untrusted data.
* Do not log secrets.
* Do not expose stack traces in production.
* Set secure cookie flags.
* Limit file upload types and sizes.
* Store uploaded files safely outside executable paths when possible.

Bad:

```php id="wn9j9x"
echo $_GET['name'];
```

Better:

```php id="jgil7h"
echo htmlspecialchars($name, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
```

Bad:

```php id="040bz5"
$user = unserialize($_POST['payload']);
```

Better:

* use JSON
* validate decoded structure
* map to DTO/value object

---

## 20. File uploads

Rules:

* Limit size.
* Validate MIME/type server-side.
* Do not trust original filename.
* Generate safe filenames.
* Store outside public executable paths when possible.
* Scan or inspect risky uploads when required by product.
* Never execute uploaded files.
* Normalize image processing.
* Strip metadata if privacy matters.

Bad:

```php id="4gtjod"
move_uploaded_file($_FILES['avatar']['tmp_name'], 'uploads/' . $_FILES['avatar']['name']);
```

Better:

* validate upload error code
* validate size
* generate random name
* store safely
* persist metadata separately

---

## 21. API response design

Rules:

* Use consistent response envelopes or consistent problem details.
* Do not leak internal exception messages.
* Return stable error codes.
* Validate request bodies.
* Reject unknown fields for strict APIs when possible.
* Use pagination for lists.
* Include request IDs in error responses when useful.
* Keep API DTOs separate from database entities.

Bad:

```php id="12zqqz"
return ['error' => $e->getMessage()];
```

Better:

```php id="2xf4ab"
return [
    'error' => [
        'code' => 'ORDER_NOT_FOUND',
        'message' => 'Order not found.',
        'request_id' => $requestId,
    ],
];
```

---

## 22. Framework boundary rule

This file is framework-neutral. For Laravel/Symfony/etc., the same boundary rule applies:

```text id="pm347p"
Controller / Handler
  -> Application Service
    -> Domain
      -> nothing framework-specific

Infrastructure
  -> implements domain/application ports
```

Rules:

* Controllers should be thin.
* Domain should not depend on framework request objects.
* Do not pass framework containers into domain services.
* Keep validation near request boundaries.
* Keep persistence behind repositories/query services when complexity warrants.
* Do not create fake layers for tiny CRUD apps.

Bad:

```php id="mxkib6"
final class Invoice
{
    public function saveWithLaravelRequest(Request $request): void
    {
        // domain now depends on HTTP + framework
    }
}
```

Better:

* request DTO
* application service
* domain object
* repository

---

## 23. Testing strategy

Use:

* PHPUnit or Pest for unit/integration tests
* static analysis for type safety
* mutation testing for critical pure logic
* integration tests for database/repository paths
* contract tests for public APIs
* smoke tests for boot/container/config

Rules:

* Test business rules without booting full framework when possible.
* Test database queries that matter.
* Test error mapping.
* Test validation boundaries.
* Do not mock everything.
* Prefer fakes for simple ports.
* Keep slow tests separate.

Example:

```php id="z3w3n5"
final class MoneyTest extends TestCase
{
    public function test_it_adds_money_with_same_currency(): void
    {
        $a = new Money(1000, 'USD');
        $b = new Money(250, 'USD');

        self::assertEquals(
            new Money(1250, 'USD'),
            $a->plus($b),
        );
    }
}
```

---

## 24. Mutation testing

Use mutation testing for critical business logic when normal coverage becomes misleading.

Good candidates:

* pricing
* tax
* permissions
* billing
* state machines
* eligibility rules
* security-sensitive branching

Tool:

* Infection PHP

Rules:

* Do not start with mutation testing for the whole app.
* Use it on critical pure logic first.
* Mutation score is a signal, not a religion.
* Slow mutation tests can run nightly or before release.

---

## 25. Refactoring legacy PHP

Legacy cleanup order:

1. Add tests around current behavior.
2. Add Composer autoload if missing.
3. Add formatting.
4. Add static analysis at low level.
5. Add `strict_types` only to new/changed files first.
6. Convert raw arrays at boundaries.
7. Introduce value objects for critical concepts.
8. Extract giant scripts into functions/classes.
9. Replace globals with explicit dependencies.
10. Raise static analysis level.

Do not:

* big-bang rewrite
* add strict types everywhere in one PR
* replace the framework first
* rename everything without tests
* introduce architecture astronaut layers

---

## 26. Performance playbooks

### Slow request cleanup

1. Measure total request time.
2. Split DB, external API, template, and app time.
3. Count queries.
4. Find N+1 loops.
5. Check slow query logs.
6. Add indexes if query plan proves need.
7. Cache stable expensive reads.
8. Reduce payload size.
9. Enable/tune OPcache.
10. Re-measure.

### High memory cleanup

1. Check peak memory per request/job.
2. Find `fetchAll` / huge arrays.
3. Stream/chunk large work.
4. Remove accidental retained references.
5. Bound caches.
6. Restart workers after safe thresholds.
7. Re-measure under realistic load.

### Static analysis cleanup

1. Run PHPStan/Psalm.
2. Fix real type bugs first.
3. Add array shapes or DTOs at boundaries.
4. Replace `mixed` with concrete types.
5. Add generics annotations for collections.
6. Remove suppressions.
7. Raise level.

### Composer cleanup

1. Run `composer validate --strict`.
2. Run `composer audit`.
3. Run `composer outdated`.
4. Remove unused packages.
5. Replace trivial packages with local code.
6. Optimize autoload for production.
7. Commit dependency changes separately.

---

## 27. Performance review checklist

Before merging PHP performance-sensitive code, check:

* Is the PHP version supported?
* Is OPcache enabled in production?
* Does this add N+1 queries?
* Does this select more columns than needed?
* Does this load huge arrays into memory?
* Does this validate external input?
* Does this escape output?
* Does this add dynamic class loading?
* Does this add a dependency for trivial logic?
* Does this rely on global/static state?
* Does this work in long-running workers?
* Does this catch and swallow exceptions?
* Does this leak raw exception messages?
* Does this add cache without invalidation/TTL?
* Does this run static analysis cleanly?
* Does this have tests for critical business rules?

---

## 28. Anti-patterns to refuse

Refuse or strongly push back on:

* new production code on unsupported PHP
* no `strict_types` in new files
* raw `$_GET` / `$_POST` deep in app code
* SQL string concatenation
* raw arrays as domain models everywhere
* `mixed` spreading across services
* `@` error suppression
* `unserialize` on untrusted data
* stack traces shown in production
* logging passwords/tokens/secrets
* `catch (Throwable $e) {}` with no handling
* global mutable state
* static per-request state in long-running workers
* controllers with business logic
* framework request objects inside domain models
* Composer packages for tiny helpers
* OPcache disabled in production
* JIT claimed as a web-app fix without profiling
* caching without TTL/invalidation
* `SELECT *` by default
* N+1 repository calls inside loops
* baselined PHPStan/Psalm errors that never get paid down

---

## 29. Escalation thresholds

| Symptom                            | Action                                          |
| ---------------------------------- | ----------------------------------------------- |
| PHP version unsupported            | Upgrade plan before feature work                |
| Static analysis absent             | Add PHPStan/Psalm at low level, raise over time |
| `mixed` appears in core services   | Add DTO/value object boundary                   |
| Controller >150 lines              | Move business logic to application service      |
| Query count grows with list size   | Fix N+1 with batching/eager loading             |
| Endpoint memory spikes             | Stream/chunk data, inspect large arrays         |
| Worker memory grows over jobs      | Reset state, bound caches, restart policy       |
| Composer dependency used once      | Inline or local helper                          |
| OPcache disabled in prod           | Enable and size it                              |
| Cache has no TTL/invalidation      | Add policy or remove cache                      |
| Raw SQL uses interpolation         | Convert to prepared statements                  |
| Exception message returned to user | Map to stable public error                      |

---

## 30. Source families

Use these when validating or updating this file:

* PHP supported versions
* PHP manual
* OPcache manual
* Composer docs
* PHP-FIG PSRs, especially PSR-12
* PHPStan docs
* Psalm docs
* PHPUnit docs
* Pest docs
* Infection PHP docs
* OWASP guidance
* framework docs when project-specific: Laravel, Symfony, Slim, Laminas, Spiral
* database docs for the project’s DB engine

