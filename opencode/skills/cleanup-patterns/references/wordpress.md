
# WordPress — Advanced Plugin/Theme Quality, Performance, Security, and Team Maintainability

Use this file when the user is working on WordPress themes, plugins, mu-plugins, custom post types, custom taxonomies, WP_Query, REST API endpoints, AJAX actions, Gutenberg blocks, WooCommerce integrations, admin screens, caching, logging, security, performance, or legacy cleanup.

This is not beginner WordPress advice. Prefer native WordPress APIs, explicit hooks, clear ownership, secure boundaries, measurable performance, centralized logging, cache discipline, and code that a team can safely update.

---

## 1. Rule zero: WordPress is a global hook-driven runtime

WordPress is not a normal framework app. It is:

- global state
- hooks
- filters
- database-backed configuration
- plugin/theme composition
- shared runtime with unknown third-party code
- request-specific globals
- admin/frontend/REST/AJAX/cron contexts

Production WordPress quality means isolating the chaos.

Rules:
- Do not scatter logic across random hooks.
- Do not put business logic directly in templates.
- Do not put plugin behavior in a theme.
- Do not make every class instantiate itself.
- Do not rely on global state deep inside domain logic.
- Keep WordPress-specific APIs near WordPress boundaries.
- Use WordPress APIs where they exist instead of bypassing core.

Good architecture:

```text
Plugin bootstrap
  -> Service container / registry
    -> Hook registration
      -> Controllers / Handlers
        -> Application services
          -> Domain logic
            -> Repository / Gateway
              -> WordPress APIs / database / remote APIs
````

Theme architecture:

```text
Theme bootstrap
  -> setup theme supports
  -> enqueue assets
  -> register menus/sidebars/patterns/templates
  -> render templates
```

Rule:

* Plugins own behavior. Themes own presentation.

---

## 2. Plugin vs theme responsibilities

Use a plugin for:

* custom post types
* taxonomies
* shortcodes
* REST endpoints
* business logic
* integrations
* payment/shipping logic
* data import/export
* admin tools
* cron jobs
* database tables
* permissions/capabilities
* content model changes

Use a theme for:

* templates
* styling
* layout
* block patterns
* theme.json
* menus
* sidebars
* image sizes
* presentation-only helpers

Bad:

```php
// functions.php
add_action('init', function () {
    register_post_type('course', [...]);
});
```

Better:

```text
plugins/course-manager/
  course-manager.php
  src/
    CoursePostType.php
    CourseRepository.php
    CourseRestController.php

themes/company-theme/
  templates/
  parts/
  theme.json
  functions.php
```

Rule:

* If switching themes would break site functionality, that functionality belongs in a plugin.

---

## 3. Folder structure for team-maintainable plugins

Recommended plugin layout:

```text
my-plugin/
  my-plugin.php
  composer.json
  readme.txt
  uninstall.php
  assets/
    css/
    js/
  languages/
  src/
    Plugin.php
    Infrastructure/
      WordPress/
        Hooks.php
        Assets.php
        Logger.php
      Database/
        Migrations.php
    Admin/
      SettingsPage.php
      ListTable.php
    Frontend/
      Shortcodes.php
      TemplateLoader.php
    Rest/
      OrdersController.php
    Domain/
      Order.php
      OrderStatus.php
      Money.php
    Application/
      PlaceOrderService.php
    Repository/
      OrderRepository.php
  tests/
```

Rules:

* Bootstrap file should load dependencies and start the plugin.
* Keep hook registration centralized.
* Keep admin, frontend, REST, cron, and domain separated.
* Use namespaces.
* Use Composer autoload if the plugin is large enough.
* Keep assets out of PHP folders.
* Keep generated/build assets separate from source assets.

Bootstrap:

```php
<?php

declare(strict_types=1);

/**
 * Plugin Name: My Plugin
 * Description: Production-grade custom plugin.
 * Version: 1.0.0
 */

defined('ABSPATH') || exit;

require_once __DIR__ . '/vendor/autoload.php';

MyPlugin\Plugin::boot(__FILE__);
```

---

## 4. Folder structure for team-maintainable themes

Recommended block/classic hybrid theme layout:

```text
my-theme/
  functions.php
  theme.json
  style.css
  screenshot.png
  assets/
    src/
    build/
  inc/
    setup.php
    assets.php
    template-tags.php
    block-patterns.php
  templates/
  parts/
  patterns/
  languages/
```

Rules:

* Keep `functions.php` small.
* Split setup, assets, template tags, and block patterns into files.
* Do not put large business logic in theme files.
* Use `theme.json` for design tokens and editor settings where possible.
* Enqueue only needed assets.
* Prefer block patterns/templates for layout consistency.

Bad:

```php
// 2,000-line functions.php with CPTs, API calls, shortcodes, admin pages, and rendering.
```

Better:

```php
// functions.php
require_once __DIR__ . '/inc/setup.php';
require_once __DIR__ . '/inc/assets.php';
require_once __DIR__ . '/inc/template-tags.php';
```

---

## 5. Hook architecture

Hooks are WordPress’s power tool and its biggest maintainability trap.

Rules:

* Register hooks in one predictable place.
* Use named methods/functions, not anonymous closures for important behavior.
* Keep hook callbacks thin.
* Do not hide complex behavior inside hook registration.
* Use priorities intentionally.
* Document non-default priorities.
* Remove hooks only when callback identity is stable.
* Avoid running expensive logic on broad hooks.

Bad:

```php
add_action('init', function () {
    // 200 lines of setup, queries, API calls, conditionals.
});
```

Better:

```php
final class Hooks
{
    public function register(): void
    {
        add_action('init', [$this->postTypes, 'register']);
        add_action('wp_enqueue_scripts', [$this->assets, 'enqueueFrontend']);
        add_action('rest_api_init', [$this->rest, 'registerRoutes']);
    }
}
```

Rule:

* Hook callbacks should route to named services. They should not become the app.

---

## 6. Naming, prefixes, and namespaces

Rules:

* Use PHP namespaces for plugin classes.
* Prefix global functions, options, transients, actions, filters, cron hooks, and database tables.
* Never use generic option names.
* Never register generic AJAX action names.
* Never create global functions like `helper()` or `render_card()`.

Good:

```php
namespace Acme\CourseManager;

const OPTION_SETTINGS = 'acme_course_manager_settings';
const CRON_SYNC = 'acme_course_manager_sync';
```

Good hook names:

```php
do_action('acme_course_manager_order_paid', $orderId);
apply_filters('acme_course_manager_sync_batch_size', 100);
```

Bad:

```php
update_option('settings', $settings);
add_action('wp_ajax_save', 'save');
```

Rule:

* Everything global must be uniquely named.

---

## 7. Security model: capability, nonce, validation, sanitization, escaping

WordPress security work is not one function. It is a chain:

1. Authentication: who is the user?
2. Authorization: can they do this?
3. Nonce: did this request come from an intended UI flow?
4. Validation: does the data make domain sense?
5. Sanitization: make input safe to store/process.
6. Escaping: make output safe for its context.

Rules:

* Nonces are not permission checks.
* Capabilities are authorization.
* Validate before trusting.
* Sanitize before storing.
* Escape on output.
* Escape for the correct context.
* Never trust admin users blindly; compromised admin sessions exist.
* Never trust hidden fields.

Admin POST pattern:

```php
public function saveSettings(): void
{
    if (!current_user_can('manage_options')) {
        wp_die(esc_html__('You do not have permission.', 'my-plugin'));
    }

    check_admin_referer('my_plugin_save_settings');

    $raw = wp_unslash($_POST['my_plugin'] ?? []);

    if (!is_array($raw)) {
        wp_die(esc_html__('Invalid settings payload.', 'my-plugin'));
    }

    $settings = [
        'api_url' => esc_url_raw((string) ($raw['api_url'] ?? '')),
        'enabled' => !empty($raw['enabled']),
    ];

    update_option('my_plugin_settings', $settings);

    wp_safe_redirect(admin_url('options-general.php?page=my-plugin&updated=1'));
    exit;
}
```

---

## 8. Escaping output

Escape as late as possible, in the correct context.

Use:

* `esc_html()` for HTML text.
* `esc_attr()` for attributes.
* `esc_url()` for URLs.
* `esc_js()` for inline JavaScript contexts.
* `wp_kses_post()` for trusted limited HTML.
* `wp_json_encode()` for JSON output.

Bad:

```php
echo $_GET['name'];
```

Better:

```php
echo esc_html($name);
```

Attribute:

```php
printf(
    '<input type="text" name="title" value="%s">',
    esc_attr($title)
);
```

URL:

```php
printf(
    '<a href="%s">%s</a>',
    esc_url($url),
    esc_html($label)
);
```

Rules:

* Do not pre-escape values before storage.
* Store clean data, escape on output.
* Do not use `wp_kses_post()` as a lazy fix for everything.
* Never echo raw request/database data.

---

## 9. Sanitization and validation

Sanitization makes data safer. Validation decides whether it is acceptable.

Bad:

```php
$age = sanitize_text_field($_POST['age']);
```

Better:

```php
$age = absint($_POST['age'] ?? 0);

if ($age < 13 || $age > 120) {
    return new WP_Error('invalid_age', __('Invalid age.', 'my-plugin'));
}
```

Rules:

* Use `sanitize_text_field()` for simple text, not for every data type.
* Use `sanitize_email()` for email.
* Use `esc_url_raw()` / `sanitize_url()` for stored URLs.
* Use `absint()` for positive integers.
* Use enum/allow-list validation for finite values.
* Validate arrays recursively.
* Reject unknown fields for strict custom APIs where possible.

Allow-list:

```php
$status = sanitize_key((string) ($_POST['status'] ?? ''));

if (!in_array($status, ['draft', 'active', 'archived'], true)) {
    return new WP_Error('invalid_status', __('Invalid status.', 'my-plugin'));
}
```

---

## 10. REST API endpoints

Rules:

* Always define `permission_callback`.
* Validate parameters.
* Sanitize parameters.
* Return `WP_REST_Response` or arrays intentionally.
* Return `WP_Error` for errors.
* Do not expose private data by default.
* Do not use REST endpoints as permission bypasses.
* Keep callbacks thin.
* Use namespaced routes.

Route registration:

```php
public function registerRoutes(): void
{
    register_rest_route('acme/v1', '/orders/(?P<id>\d+)', [
        'methods' => WP_REST_Server::READABLE,
        'callback' => [$this, 'getOrder'],
        'permission_callback' => [$this, 'canReadOrder'],
        'args' => [
            'id' => [
                'required' => true,
                'validate_callback' => static fn ($value): bool => absint($value) > 0,
                'sanitize_callback' => 'absint',
            ],
        ],
    ]);
}

public function canReadOrder(WP_REST_Request $request): bool
{
    return current_user_can('read');
}

public function getOrder(WP_REST_Request $request): WP_REST_Response|WP_Error
{
    $orderId = absint($request['id']);

    $order = $this->orders->find($orderId);

    if ($order === null) {
        return new WP_Error(
            'acme_order_not_found',
            __('Order not found.', 'acme'),
            ['status' => 404]
        );
    }

    return rest_ensure_response($order->toArray());
}
```

Bad:

```php
'permission_callback' => '__return_true'
```

Only use public permission callbacks for truly public data.

---

## 11. AJAX actions

Rules:

* Separate logged-in and public AJAX intentionally.
* Use capabilities for privileged actions.
* Use nonces for state-changing UI requests.
* Validate/sanitize payloads.
* Return JSON with `wp_send_json_success()` / `wp_send_json_error()`.
* Exit through WordPress helpers.
* Do not echo random strings.

Example:

```php
add_action('wp_ajax_acme_save_settings', [$controller, 'saveSettings']);

public function saveSettings(): void
{
    if (!current_user_can('manage_options')) {
        wp_send_json_error(['message' => __('Forbidden.', 'acme')], 403);
    }

    check_ajax_referer('acme_save_settings', 'nonce');

    $value = sanitize_text_field(wp_unslash($_POST['value'] ?? ''));

    update_option('acme_value', $value);

    wp_send_json_success(['message' => __('Saved.', 'acme')]);
}
```

Rules:

* `wp_ajax_nopriv_*` means public. Treat it like public internet.
* Public AJAX endpoints need rate limiting or abuse controls when expensive.
* Never trust nonce alone.

---

## 12. WP_Query performance

`WP_Query` can be cheap or brutal.

Rules:

* Query only what you need.
* Use pagination.
* Avoid broad `meta_query`.
* Avoid `LIKE` queries on large postmeta.
* Avoid `posts_per_page => -1` in production paths.
* Use `'fields' => 'ids'` when only IDs are needed.
* Disable work you do not need.
* Avoid nested queries in templates.
* Reset post data after custom loops.
* Cache expensive query results carefully.

Good:

```php
$query = new WP_Query([
    'post_type' => 'product',
    'post_status' => 'publish',
    'posts_per_page' => 12,
    'paged' => max(1, get_query_var('paged')),
    'no_found_rows' => false,
]);
```

IDs only:

```php
$ids = get_posts([
    'post_type' => 'event',
    'post_status' => 'publish',
    'fields' => 'ids',
    'posts_per_page' => 50,
    'no_found_rows' => true,
]);
```

Rules:

* Use `no_found_rows => true` when pagination total is not needed.
* Use `update_post_meta_cache => false` if metadata is not needed.
* Use `update_post_term_cache => false` if terms are not needed.
* Do not call `setup_postdata()` unless needed.
* Avoid `query_posts()`.

Bad:

```php
query_posts(['posts_per_page' => -1]);
```

---

## 13. Post meta performance

`postmeta` is flexible but not free.

Bad for high-scale filtering:

* complex `meta_query`
* sorting by meta values
* filtering huge datasets by unindexed meta
* storing query-critical fields only in serialized arrays
* `LIKE` against serialized meta

Rules:

* Use post meta for content attributes, not everything.
* For high-volume relational/query-heavy data, consider a custom table.
* Store query-critical values in separate meta keys if using meta.
* Avoid serialized blobs for values you must query.
* Add indexes only with a real query plan and migration strategy.
* Cache derived read models if appropriate.

Escalate to custom table when:

* data volume is high
* queries are frequent
* filtering/sorting by multiple fields matters
* reporting/exporting matters
* postmeta queries dominate p95/p99

---

## 14. Custom database tables

Use custom tables when WordPress content tables are the wrong shape.

Good candidates:

* orders
* logs/events
* analytics
* high-volume form submissions
* sync state
* external IDs
* queue jobs
* many-to-many relationships at scale

Rules:

* Use `$wpdb->prepare()`.
* Use explicit schema/migrations.
* Use proper indexes.
* Prefix table names with `$wpdb->prefix`.
* Version your schema.
* Do not run heavy migrations on every request.
* Avoid `dbDelta()` surprises without testing.
* Keep repository methods typed and small.

Example:

```php
$table = $wpdb->prefix . 'acme_orders';

$sql = $wpdb->prepare(
    "SELECT id, status, total_cents FROM {$table} WHERE id = %d",
    $orderId
);

$row = $wpdb->get_row($sql, ARRAY_A);
```

Rules:

* Table names cannot be placeholders in `$wpdb->prepare()`. Build table names from trusted constants/prefix only.
* Values must be prepared.
* Do not concatenate user input into SQL.

---

## 15. Caching strategy

WordPress caching layers:

* page cache
* object cache
* transients
* fragment cache
* browser/CDN cache
* query cache through persistent object cache
* application-level read models

Rules:

* Cache expensive reads, not broken architecture.
* Use object cache for runtime/reusable objects when persistent cache exists.
* Use transients for temporary cached values with expiration.
* Include all inputs in cache keys.
* Version cache keys when shape changes.
* Set TTLs intentionally.
* Invalidate on writes.
* Avoid caching permission-specific data globally.
* Avoid transient bloat.
* Avoid autoloaded options for large data.

Transient example:

```php
$key = sprintf('acme_featured_posts:v1:%s', md5(wp_json_encode($args)));

$ids = get_transient($key);

if ($ids === false) {
    $ids = get_posts([
        'post_type' => 'post',
        'fields' => 'ids',
        'posts_per_page' => 6,
        'no_found_rows' => true,
    ]);

    set_transient($key, $ids, 10 * MINUTE_IN_SECONDS);
}
```

Object cache example:

```php
$key = 'order:' . $orderId;
$group = 'acme_orders';

$order = wp_cache_get($key, $group);

if ($order === false) {
    $order = $this->repository->find($orderId);
    wp_cache_set($key, $order, $group, 300);
}
```

Rules:

* Use object cache groups.
* Invalidate related keys after writes.
* Do not assume persistent object cache exists on every site.
* Design correctness without cache, then add cache.

---

## 16. Options API performance

Rules:

* Do not store huge blobs in autoloaded options.
* Use `autoload = no` for large rarely used options.
* Keep option names prefixed.
* Group small settings in one option only when they share lifecycle.
* Do not update options on every request.
* Avoid using options as logs/queues.
* Clean up options on uninstall if plugin-owned.

Bad:

```php
update_option('acme_logs', $hugeGrowingArray);
```

Better:

* custom table for logs
* external logger
* bounded transient/cache for temporary state

When adding large option:

```php
add_option('acme_large_settings', $value, '', 'no');
```

---

## 17. Asset loading performance

Rules:

* Register assets once.
* Enqueue only where needed.
* Use dependencies correctly.
* Use versioning for cache busting.
* Do not load admin assets on every admin page.
* Do not load frontend assets globally if only one shortcode/block needs them.
* Prefer block asset metadata when building blocks.
* Defer/async scripts only when safe.
* Avoid duplicate libraries already provided by WordPress.
* Use `wp_enqueue_script()` and `wp_enqueue_style()`.

Admin conditional enqueue:

```php
public function enqueueAdmin(string $hook): void
{
    if ($hook !== 'settings_page_acme') {
        return;
    }

    wp_enqueue_script(
        'acme-admin',
        plugins_url('assets/build/admin.js', ACME_PLUGIN_FILE),
        ['wp-api-fetch'],
        ACME_VERSION,
        true
    );
}
```

Frontend shortcode asset pattern:

* register globally
* enqueue only when shortcode/block renders

Rule:

* Asset performance is mostly about not loading things.

---

## 18. Block editor / Gutenberg

Rules:

* Prefer block.json metadata for blocks.
* Separate editor script, frontend script, and style.
* Load block assets only when block is used when possible.
* Keep server render callbacks fast.
* Validate attributes.
* Escape render output.
* Avoid heavy REST calls on every editor keystroke.
* Use core components where possible.
* Keep block behavior in plugins, not themes, when it represents functionality.

Dynamic block render:

```php
public function render(array $attributes): string
{
    $title = sanitize_text_field($attributes['title'] ?? '');

    ob_start();
    ?>
    <section class="acme-card">
        <h2><?php echo esc_html($title); ?></h2>
    </section>
    <?php
    return (string) ob_get_clean();
}
```

Rules:

* Escape inside render callbacks.
* Do not trust block attributes.
* Avoid querying large datasets during block render without caching.

---

## 19. Centralized logging

WordPress has `WP_DEBUG_LOG` for debug logging, but production teams need a central logging pattern.

Rules:

* Do not scatter `error_log()` everywhere.
* Wrap logging behind a plugin logger.
* Include context.
* Never log secrets.
* Use request IDs when possible.
* Log at boundaries.
* Log errors once.
* Support fallback to `error_log()` when no PSR logger exists.
* Integrate with host/log platform when available.
* Keep logs structured enough to search.

Logger interface:

```php
interface Logger
{
    /**
     * @param array<string, mixed> $context
     */
    public function error(string $message, array $context = []): void;

    /**
     * @param array<string, mixed> $context
     */
    public function info(string $message, array $context = []): void;
}
```

WordPress fallback logger:

```php
final class ErrorLogLogger implements Logger
{
    public function error(string $message, array $context = []): void
    {
        error_log($this->format('error', $message, $context));
    }

    public function info(string $message, array $context = []): void
    {
        if (defined('WP_DEBUG') && WP_DEBUG) {
            error_log($this->format('info', $message, $context));
        }
    }

    /**
     * @param array<string, mixed> $context
     */
    private function format(string $level, string $message, array $context): string
    {
        return wp_json_encode([
            'plugin' => 'acme',
            'level' => $level,
            'message' => $message,
            'context' => $this->redact($context),
        ]) ?: $message;
    }

    /**
     * @param array<string, mixed> $context
     * @return array<string, mixed>
     */
    private function redact(array $context): array
    {
        foreach (['password', 'token', 'secret', 'authorization', 'cookie'] as $key) {
            if (array_key_exists($key, $context)) {
                $context[$key] = '[redacted]';
            }
        }

        return $context;
    }
}
```

Rules:

* Use logging for diagnosis, not user messaging.
* Do not log full request bodies by default.
* Do not log PII unless explicitly allowed.
* Do not use logs as a database.

---

## 20. Cron and background tasks

Rules:

* WP-Cron depends on traffic unless real cron triggers it.
* Keep cron jobs idempotent.
* Use locks to prevent overlap.
* Keep batches small.
* Store progress.
* Retry with backoff.
* Log failures centrally.
* Avoid running huge jobs in a single request.
* Clear scheduled hooks on deactivation if plugin-owned.

Schedule:

```php
register_activation_hook(ACME_PLUGIN_FILE, static function (): void {
    if (!wp_next_scheduled('acme_sync_cron')) {
        wp_schedule_event(time() + HOUR_IN_SECONDS, 'hourly', 'acme_sync_cron');
    }
});

register_deactivation_hook(ACME_PLUGIN_FILE, static function (): void {
    wp_clear_scheduled_hook('acme_sync_cron');
});
```

Lock:

```php
if (get_transient('acme_sync_lock') !== false) {
    return;
}

set_transient('acme_sync_lock', 1, 10 * MINUTE_IN_SECONDS);

try {
    $this->sync->runBatch();
} finally {
    delete_transient('acme_sync_lock');
}
```

---

## 21. Admin performance

Rules:

* Do not run expensive queries on every admin page.
* Check `$hook` before enqueuing admin assets.
* Use pagination for list tables.
* Cache expensive dashboard widgets.
* Avoid remote API calls during admin page render.
* Use background jobs for sync/import.
* Do not add global admin notices on every screen.
* Load plugin admin code only in admin context when possible.

Bad:

```php
add_action('admin_init', function () {
    remote_sync_everything();
});
```

Better:

* explicit sync button
* cron/background queue
* cached status
* admin notice only on plugin pages

---

## 22. Multisite caveats

Rules:

* Know whether settings are site-level or network-level.
* Use `get_site_option()` for network options.
* Be careful switching blogs.
* Restore current blog after `switch_to_blog()`.
* Avoid network-wide loops in normal requests.
* Batch network operations.
* Consider per-site table prefixes.
* Test activation/deactivation on multisite.

Pattern:

```php
switch_to_blog($blogId);

try {
    // site-specific work
} finally {
    restore_current_blog();
}
```

---

## 23. WooCommerce caveats

Rules:

* Use WooCommerce APIs for orders/products when possible.
* Do not directly mutate order postmeta casually.
* Avoid slow order queries.
* Respect HPOS/custom order tables when applicable.
* Hook into WooCommerce lifecycle events intentionally.
* Keep checkout path lean.
* Never add remote blocking calls to checkout without timeout/fallback.
* Log payment/order failures centrally.
* Do not expose sensitive payment data.

Checkout rule:

* Anything in checkout affects revenue. Profile and test it.

---

## 24. Internationalization

Rules:

* Use text domain consistently.
* Escape translated output.
* Do not concatenate translated sentence fragments.
* Use placeholders.
* Load plugin/theme text domain.
* Keep user-facing strings translatable.

Good:

```php
printf(
    esc_html__('Order %s was created.', 'acme'),
    esc_html($orderNumber)
);
```

Bad:

```php
echo esc_html__('Order ', 'acme') . esc_html($orderNumber) . esc_html__(' was created.', 'acme');
```

---

## 25. Coding standards and static analysis

Use:

* WordPress Coding Standards
* PHP_CodeSniffer
* PHPStan or Psalm
* WordPress-specific stubs/rules where useful
* Composer scripts
* CI checks

Composer scripts:

```json
{
  "scripts": {
    "lint": "phpcs",
    "lint:fix": "phpcbf",
    "analyse": "phpstan analyse",
    "test": "phpunit"
  }
}
```

Rules:

* Do not let standards be manual review work.
* Automate formatting/linting.
* Use baselines only as temporary migration tools.
* Fail CI on new issues.

---

## 26. Testing strategy

Use:

* PHPUnit for PHP logic.
* WordPress test suite for WP integration.
* Brain Monkey or similar for isolated hook/function tests when useful.
* Playwright/Cypress for critical admin/frontend flows if needed.
* Snapshot tests only for stable rendered fragments, not entire pages.
* Static analysis for type/contract checks.

Rules:

* Test domain/application services without booting WordPress when possible.
* Test hook registration separately from business logic.
* Test REST permission callbacks.
* Test sanitization/validation.
* Test cache invalidation.
* Test custom table migrations.
* Test multisite if supported.
* Test WooCommerce paths if integrated.

---

## 27. Team maintainability rules

Rules:

* One obvious owner per feature area.
* Hook registration is centralized.
* Naming is prefixed/namespaced.
* No 2,000-line `functions.php`.
* No random snippets pasted from blogs.
* No business logic inside templates.
* No direct SQL outside repositories/gateways.
* No untracked options/transients.
* No magic strings scattered across files.
* Document public hooks/filters.
* Document database schema.
* Document cron jobs.
* Document uninstall behavior.

Public extension point example:

```php
/**
 * Filters the sync batch size.
 *
 * @param int $batchSize Number of records to sync.
 */
$batchSize = (int) apply_filters('acme_sync_batch_size', 100);
```

Rule:

* If other developers are expected to use a hook/filter, document it like an API.

---

## 28. Uninstall and cleanup

Rules:

* Deactivation stops runtime behavior.
* Uninstall removes plugin-owned data if the user chose full removal.
* Do not delete user data unexpectedly.
* Clean scheduled events.
* Clean options/transients.
* Drop custom tables only with explicit uninstall behavior.
* Document what is removed.

`uninstall.php`:

```php
<?php

defined('WP_UNINSTALL_PLUGIN') || exit;

delete_option('acme_settings');
delete_transient('acme_featured_posts');

wp_clear_scheduled_hook('acme_sync_cron');
```

Rule:

* Be careful with destructive cleanup. Users hate plugins that delete data unexpectedly.

---

## 29. Performance playbooks

### Slow frontend page cleanup

1. Check page cache status.
2. Check query count.
3. Find slow WP_Query/meta_query calls.
4. Remove `posts_per_page => -1`.
5. Convert ID-only queries to `'fields' => 'ids'`.
6. Disable unnecessary found rows/meta/term cache work.
7. Move repeated remote calls to cached/background jobs.
8. Enqueue fewer assets.
9. Resize/compress images.
10. Re-measure.

### Slow admin page cleanup

1. Check if code runs on every admin screen.
2. Restrict by `$hook`.
3. Paginate list tables.
4. Cache dashboard/status widgets.
5. Move sync/import to cron/background.
6. Remove global admin notices.
7. Profile queries.
8. Re-measure.

### Slow REST endpoint cleanup

1. Verify permission callback is not doing heavy work.
2. Validate params early.
3. Query only needed fields.
4. Batch related data.
5. Cache safe read responses.
6. Avoid exposing huge payloads.
7. Add pagination.
8. Return stable errors.
9. Re-measure.

### Plugin cleanup

1. Move behavior out of theme.
2. Centralize hook registration.
3. Prefix/namespace globals.
4. Split admin/frontend/REST/cron.
5. Add capability checks.
6. Add nonce checks for UI actions.
7. Add validation/sanitization/escaping.
8. Add logging wrapper.
9. Add coding standards/static analysis.
10. Delete dead snippets.

---

## 30. Performance review checklist

Before merging WordPress code, check:

* Does this run on every request?
* Does this run on every admin page?
* Does this add a broad hook callback?
* Does this add N+1 queries?
* Does this use `posts_per_page => -1`?
* Does this use expensive `meta_query`?
* Does this query only needed fields?
* Does this cache expensive stable reads?
* Does this invalidate cache on writes?
* Does this enqueue assets only where needed?
* Does this add remote API calls in render/checkout/admin load?
* Does this check capabilities?
* Does this verify nonce where appropriate?
* Does this validate and sanitize input?
* Does this escape output?
* Does this expose REST/AJAX publicly?
* Does this log centrally without secrets?
* Does this clean up cron/options/transients on uninstall/deactivation?
* Does this follow coding standards?
* Can another team member find where this feature lives?

---

## 31. Anti-patterns to refuse

Refuse or strongly push back on:

* editing WordPress core
* plugin behavior hidden in a theme
* 2,000-line `functions.php`
* anonymous hook callbacks with complex logic
* `query_posts()`
* `posts_per_page => -1` in production paths
* unbounded `meta_query` on large datasets
* `LIKE` queries on serialized postmeta
* direct SQL with user input
* REST route without `permission_callback`
* AJAX action without capability checks
* nonce used as authorization
* raw `$_POST` / `$_GET` deep in services
* unescaped output
* globally enqueued assets for one page/block
* remote API calls during page render without caching/timeout
* WP-Cron job with no lock/batching
* plugin logs stored in one huge option
* `error_log()` scattered everywhere
* secrets/tokens in logs
* custom tables without schema versioning
* deleting user data on deactivation
* public debug output in production
* random snippets pasted with no ownership

---

## 32. Escalation thresholds

| Symptom                                            | Action                                                    |
| -------------------------------------------------- | --------------------------------------------------------- |
| Theme contains CPT/business logic                  | Move to plugin                                            |
| `functions.php` >300 lines                         | Split setup/assets/template tags; move behavior to plugin |
| Hook callback >50 lines                            | Move to named service/controller                          |
| REST endpoint lacks permission callback            | Block merge                                               |
| AJAX action changes state without capability check | Block merge                                               |
| Query count grows with posts shown                 | Fix N+1/batching                                          |
| `meta_query` dominates slow pages                  | Cache, remodel data, or custom table                      |
| `posts_per_page => -1` appears                     | Replace with pagination/chunking                          |
| Admin page slow globally                           | Restrict hooks/assets by screen                           |
| Remote API call happens during render              | Cache/background it                                       |
| Large option autoloaded                            | Move to non-autoload/custom table/cache                   |
| Logs stored in options                             | Use central logger/custom table/external logs             |
| Cron overlaps                                      | Add lock and batches                                      |
| WooCommerce checkout path slowed                   | Treat as revenue-impacting incident                       |

---

## 33. Source families

Use these when validating or updating this file:

* WordPress Plugin Handbook
* WordPress Theme Handbook
* WordPress Coding Standards
* WordPress Security docs
* WordPress REST API Handbook
* WordPress Common APIs Handbook
* WordPress Transients API docs
* WordPress Cache docs
* WordPress Debugging docs
* WordPress Block Editor Handbook
* WP-CLI docs
* WooCommerce developer docs when relevant
* PHP manual
* Composer docs
* PHPStan/Psalm docs
* OWASP guidance

