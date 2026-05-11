
# Flutter / Dart — Advanced Cleanup, Performance, and Architecture

Use this file when the user is working on Flutter/Dart performance, app architecture, refactoring, maintainability, rebuild issues, jank, large widgets, state management, dependency cleanup, testing, or production-readiness.

This is not beginner Flutter advice. Prefer profiling, deletion, locality, and measurable fixes.

---

## 2.1 Performance rule zero: profile before changing code

**Rule:** Never optimize Flutter performance from vibes. Profile in `profile` or `release` mode on a real target device.

Debug mode lies. It adds checks, disables important optimizations, and exaggerates costs.

Use:

```bash
flutter run --profile
````

Then inspect:

* Flutter DevTools Performance view
* frame chart
* rebuild counts
* raster thread time
* UI thread time
* shader compilation stutter
* memory allocations
* image cache pressure
* network timeline
* app startup trace

Flutter targets 60fps, meaning roughly 16ms per frame, or 120fps on supported devices, meaning roughly 8ms per frame. A frame can miss budget because of UI-thread work, raster-thread work, image decoding, layout, shader work, or garbage collection. Do not assume the widget tree is the bottleneck until the profiler proves it. Official Flutter performance docs emphasize profiling and frame-budget analysis.

Sources: Flutter performance profiling, Flutter performance best practices.

---

## 2.2 The real performance hierarchy

Optimize in this order:

1. **Do less work**
2. **Do work less often**
3. **Do work later**
4. **Do work off the UI isolate**
5. **Make the work cheaper**
6. **Only then micro-optimize widgets**

Most Flutter performance bugs are not caused by missing `const`. They are caused by:

* rebuilding too much state scope
* doing I/O or parsing near UI code
* decoding oversized images
* using expensive visual effects casually
* creating too many objects during scrolling
* layout widgets that force extra passes
* treating clean architecture as permission to over-abstract

`const` matters, but it is not magic. It helps Flutter short-circuit rebuild work when identity is stable. It does not fix expensive layout, rasterization, image decoding, or bad state boundaries. Flutter’s own docs recommend `const` and `StatelessWidget` extraction, but those are baseline hygiene, not the whole performance story.

---

## 2.3 Lints — stricter than default

**Rule:** `flutter_lints` is a floor, not a serious production standard.

Use `very_good_analysis` or an equivalent strict lint profile.

```yaml
# analysis_options.yaml
include: package:very_good_analysis/analysis_options.10.0.0.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

  errors:
    invalid_annotation_target: ignore # usually needed with freezed/json_serializable
    missing_required_param: error
    missing_return: error

linter:
  rules:
    public_member_api_docs: false # true for packages
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_redundant_argument_values: true
    avoid_print: true
    cancel_subscriptions: true
    close_sinks: true
    depend_on_referenced_packages: true
    directives_ordering: true
    discarded_futures: true
    unawaited_futures: true
```

Rules:

* Pin the lint include version.
* Use one root include only.
* Every `// ignore:` needs a reason.
* No broad `// ignore_for_file:` unless generated or legacy-contained.
* `dart format` is not a debate.
* Treat analyzer warnings as CI failures.
* Do not loosen lints to make bad architecture compile.

---

## 2.4 Project structure — feature-first, not folder-theater

**Rule:** Use feature-first structure, but do not create fake layers just to look clean.

Good default:

```text
lib/
└── src/
    ├── app/
    │   ├── bootstrap.dart
    │   ├── app.dart
    │   ├── routing/
    │   └── theme/
    ├── features/
    │   ├── auth/
    │   │   ├── data/
    │   │   │   ├── auth_api.dart
    │   │   │   ├── auth_dto.dart
    │   │   │   └── auth_repository_impl.dart
    │   │   ├── domain/
    │   │   │   ├── auth_failure.dart
    │   │   │   ├── auth_repository.dart
    │   │   │   └── user.dart
    │   │   ├── application/
    │   │   │   └── login_cubit.dart
    │   │   └── presentation/
    │   │       ├── login_page.dart
    │   │       ├── login_view.dart
    │   │       └── widgets/
    │   └── orders/
    │       ├── data/
    │       ├── domain/
    │       ├── application/
    │       └── presentation/
    ├── shared/
    │   ├── widgets/
    │   ├── errors/
    │   ├── result/
    │   └── platform/
    └── main_development.dart
```

Layer rules:

* Presentation depends on application.
* Application depends on domain.
* Data implements domain contracts.
* Domain must not import Flutter.
* Repositories should hide remote/local/cache details.
* UI should never import API clients, database clients, or storage clients.

Advanced rule:

* If a feature has only one screen and no domain logic, do not create four empty folders. Start flat, then split when pressure appears.

Bad:

```text
lib/
├── models/
├── screens/
├── widgets/
├── services/
├── helpers/
└── utils/
```

That structure groups by file type, not by change reason. A single feature change scatters across the repo.

---

## 2.5 Architecture without over-engineering

Flutter’s current architecture guidance commonly maps apps into UI, logic/view-model, repository, and service/data layers. Use that idea, but keep the implementation small.

Recommended dependency direction:

```text
Widget/View
  -> Cubit / Notifier / ViewModel
    -> Repository interface
      -> Repository implementation
        -> API / DB / cache / platform service
```

Rules:

* Keep business rules out of widgets.
* Keep Flutter imports out of domain and data logic when possible.
* Keep repositories boring.
* Keep view models/Cubits small enough to test without rendering widgets.
* Prefer one feature refactor at a time.

Do not blindly add:

* use-case classes for every one-line method
* abstract repositories with only one implementation unless testing or boundary clarity needs them
* service locators for everything
* mega `core` packages
* DTO/entity/mapper triplets for tiny apps

The best architecture is the least architecture that prevents the next real failure.

---

## 2.6 State scope — the hidden performance killer

**Rule:** Most rebuild problems are state-scope problems.

Bad:

* App-wide state object changes for local UI state.
* `BlocBuilder` wraps an entire page.
* Provider/Riverpod watch happens too high in the tree.
* `setState` sits above a large subtree.
* One Cubit owns unrelated pieces of state.

Better:

* Watch/select only the field needed.
* Put state ownership near the smallest subtree that needs it.
* Split ephemeral UI state from domain state.
* Use `BlocSelector`, `context.select`, Riverpod `select`, or equivalent.
* Move text-field, checkbox, tab, expansion, and hover state down.

Example:

```dart
BlocSelector<CartCubit, CartState, int>(
  selector: (state) => state.items.length,
  builder: (context, count) {
    return CartBadge(count: count);
  },
)
```

Bad:

```dart
BlocBuilder<CartCubit, CartState>(
  builder: (context, state) {
    return EntireHomePage(state: state);
  },
)
```

Rule of thumb:

* If one field changes and 200 widgets rebuild, the state boundary is wrong.
* If a Cubit emits huge state objects for tiny changes, split the state or selector usage.
* If `build()` has conditionals for unrelated concerns, split the widget.

---

## 2.7 Build method rules that actually matter

`build()` may run often. Treat it as a pure, cheap projection of state to UI.

Never do this in `build()`:

* network requests
* database reads
* JSON parsing
* sorting large lists
* filtering large lists
* date formatting in huge loops
* regex compilation
* expensive object graph creation
* controller creation
* focus node creation
* stream creation
* future creation for `FutureBuilder`
* provider creation with unstable parameters

Bad:

```dart
FutureBuilder(
  future: repository.loadUser(id),
  builder: ...
)
```

This can recreate the future on rebuild.

Better:

```dart
late final Future<User> _userFuture;

@override
void initState() {
  super.initState();
  _userFuture = widget.repository.loadUser(widget.id);
}

@override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: _userFuture,
    builder: ...
  );
}
```

Even better for app logic: move fetching into Cubit/Notifier and let the widget render state.

---

## 2.8 Widget extraction: not for prettiness, for containment

**Rule:** Extract widgets to create rebuild boundaries and ownership boundaries, not just to make files shorter.

Prefer:

```dart
class OrderTotalText extends StatelessWidget {
  const OrderTotalText({
    required this.total,
    super.key,
  });

  final Money total;

  @override
  Widget build(BuildContext context) {
    return Text(total.formatted);
  }
}
```

Avoid:

```dart
Widget _buildOrderTotal(Money total) {
  return Text(total.formatted);
}
```

A real widget:

* can be `const`
* has diagnostics
* gets a stable element
* can be tested
* can own keys
* can own small state
* gives the framework more structure to work with

But do not split into 80 one-line widgets just to satisfy a rule. Extract around:

* repeated UI
* expensive subtrees
* independently changing state
* separately testable behavior
* semantic component boundaries

---

## 2.9 Rendering traps most teams learn late

Avoid casual use of:

* `Opacity`
* `Clip.antiAliasWithSaveLayer`
* `ShaderMask`
* `BackdropFilter`
* large shadows
* blurs
* nested clips
* intrinsic layout widgets
* huge transparent PNGs
* oversized images
* animated gradients
* `saveLayer()`-triggering effects

Flutter docs specifically call out expensive `saveLayer()` usage and intrinsic layout passes as performance risks. The expensive part is often not Dart code. It is raster work.

### Opacity

Bad for static hiding:

```dart
Opacity(
  opacity: 0,
  child: ExpensiveWidget(),
)
```

Better:

* remove the widget
* use `Visibility`
* use `AnimatedOpacity` only when you truly animate opacity
* use color alpha directly when possible

### Clipping

Do not clip by default. Clipping can add raster cost.

Bad:

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: HugeImage(),
)
```

Sometimes fine, but verify if used in scrolling lists.

Better:

* pre-rounded image assets when possible
* clip only visible small surfaces
* avoid nested clips in lists

### Intrinsics

Avoid:

* `IntrinsicHeight`
* `IntrinsicWidth`
* layout patterns that require measuring children twice

Use fixed constraints, `Expanded`, `Flexible`, `AspectRatio`, or custom layout instead.

---

## 2.10 RepaintBoundary is a scalpel, not seasoning

`RepaintBoundary` can help when:

* a static expensive subtree sits next to frequently animated content
* a frequently repainting child should not dirty its parent
* DevTools/Repaint Rainbow proves repaint spread

It can hurt when:

* added everywhere
* used around tiny widgets
* it creates too many layers
* the child changes every frame anyway

Good candidate:

```dart
Stack(
  children: const [
    RepaintBoundary(child: StaticMapLayer()),
    MovingUserMarker(),
  ],
)
```

Bad:

```dart
RepaintBoundary(
  child: Text('Hello'),
)
```

Rule: Add it only after seeing repaint damage.

---

## 2.11 Lists and scrolling

Use lazy builders for unbounded or large lists:

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];

    return OrderTile(
      key: ValueKey(item.id),
      order: item,
    );
  },
)
```

Rules:

* Use stable keys when item identity matters.
* Keep item widgets small.
* Avoid per-row providers unless needed.
* Avoid per-row expensive formatting.
* Avoid per-row network image decoding without cache sizing.
* Avoid `shrinkWrap: true` in large scrollables.
* Avoid nested scrollables unless there is a strong reason.
* Use `itemExtent`, `prototypeItem`, or fixed extents when possible.
* Paginate before the UI is forced to render thousands of objects.
* Do not put an entire large list inside `SingleChildScrollView`.

Bad:

```dart
SingleChildScrollView(
  child: Column(
    children: items.map(OrderTile.new).toList(),
  ),
)
```

Better:

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: ...
)
```

---

## 2.12 Images: the silent memory killer

Image problems often show up as jank, crashes, or random memory spikes.

Rules:

* Do not decode a 4000px image to show a 64px avatar.
* Use `cacheWidth` / `cacheHeight` when appropriate.
* Use thumbnails for lists.
* Avoid giant PNGs when vector or compressed formats work.
* Use placeholders carefully; shimmer everywhere can be expensive.
* Precache only critical images, not the whole app.
* Watch memory in DevTools after scrolling image-heavy screens.
* Prefer server-side resizing for feeds and grids.

Example:

```dart
Image.network(
  user.avatarUrl,
  width: 48,
  height: 48,
  cacheWidth: 96,
  cacheHeight: 96,
  fit: BoxFit.cover,
)
```

Rule of thumb:

* Display size and decode size should be related.
* Image-heavy screens need explicit performance testing on low-end devices.

---

## 2.13 Async, isolates, and heavy work

Use isolates for CPU-heavy work:

* large JSON parsing
* image processing
* encryption/compression
* large sorting/filtering
* CSV import/export
* markdown parsing
* diffing large data sets

Do not use isolates for:

* simple mapping
* normal HTTP calls
* tiny JSON payloads
* work that needs lots of UI objects

Simple pattern:

```dart
final users = await compute(parseUsers, responseBody);
```

Better for advanced cases:

* long-lived isolate
* worker pool
* chunked processing
* cancellation-aware jobs

Rules:

* Keep isolate messages simple and transferable.
* Avoid sending huge object graphs repeatedly.
* Measure serialization overhead.
* Do not touch Flutter UI objects off the main isolate.

---

## 2.14 Memory cleanup

Every owner must dispose what it owns.

Dispose:

* `AnimationController`
* `TextEditingController`
* `ScrollController`
* `PageController`
* `TabController`
* `FocusNode`
* `StreamSubscription`
* `Timer`
* `ChangeNotifier`
* custom sinks/controllers

Example:

```dart
class SearchBoxState extends State<SearchBox> {
  late final TextEditingController controller;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }
}
```

Rules:

* If created in `initState`, usually disposed in `dispose`.
* If passed from parent, usually do not dispose it.
* If subscribed, cancel.
* If listening, remove listener.
* If timer started, cancel.
* If route/page owns a Cubit manually, close it.

Use lints:

* `cancel_subscriptions`
* `close_sinks`
* `discarded_futures`
* `unawaited_futures`

---

## 2.15 Dependency cleanup

Flutter apps rot through dependency creep.

Rules:

* Do not add a package for 20 lines of code.
* Do not add a package that owns app architecture unless it earns the lock-in.
* Prefer boring packages with strong maintenance.
* Avoid packages that wrap simple platform APIs badly.
* Avoid packages with broad transitive dependency trees for tiny features.
* Do not keep both old and new state libraries around forever.
* Remove unused packages during every feature cleanup.

Audit:

```bash
flutter pub deps
flutter pub outdated
dart analyze
```

Heuristics:

* If a package has not been touched in years and touches platform code, distrust it.
* If a package solves a UI problem by hiding many platform assumptions, test it on all platforms.
* If a package forces global state, lifecycle magic, or codegen everywhere, demand a strong reason.

---

## 2.16 State management — advanced selection

### Use Cubit/BLoC when:

* transitions matter
* states need auditability
* failures must be explicit
* flows are complex
* team wants predictable tests
* observability matters

### Use Riverpod when:

* async dependency graph matters
* providers compose naturally
* team accepts generator/lint ecosystem
* local override testing is valuable
* boilerplate pressure is real

### Use `setState` when:

* state is local and ephemeral
* no other widget cares
* no persistence/fetching/business rule is involved

### Avoid:

* global mutable singleton state
* service locator everywhere
* one Cubit per entire screen if the screen has unrelated state regions
* one provider per tiny value if it makes the graph unreadable
* mixing multiple state managers without a migration plan

Rule: State library is less important than state boundaries.

---

## 2.17 Error handling

**Rule:** Expected failures should be typed. Unexpected failures can throw.

Expected:

* validation failed
* network unavailable
* unauthorized
* not found
* cache miss
* parsing failed
* permission denied

Unexpected:

* impossible state
* programmer error
* invariant violation

Use sealed results:

```dart
sealed class FetchUserResult {
  const FetchUserResult();
}

final class FetchUserSuccess extends FetchUserResult {
  const FetchUserSuccess(this.user);
  final User user;
}

final class FetchUserNotFound extends FetchUserResult {
  const FetchUserNotFound();
}

final class FetchUserNetworkFailure extends FetchUserResult {
  const FetchUserNetworkFailure(this.message);
  final String message;
}
```

Repository:

```dart
Future<FetchUserResult> fetchUser(String id) async {
  try {
    final response = await client.get('/users/$id');

    if (response.statusCode == 404) {
      return const FetchUserNotFound();
    }

    return FetchUserSuccess(User.fromJson(response.data));
  } on SocketException catch (error) {
    return FetchUserNetworkFailure(error.message);
  }
}
```

Rules:

* Do not show raw exception strings to users.
* Do not catch and silently return fake success.
* Do not log and rethrow everywhere.
* Convert infrastructure failures at boundaries.
* Keep domain failures stable.

---

## 2.18 DTOs, entities, and mapping

Do not let API shape infect the whole app.

Rules:

* DTOs belong in data.
* Entities/value objects belong in domain.
* UI models/view data can belong in presentation if they are display-specific.
* Mapping should happen at boundaries.
* Do not pass raw JSON past data layer.
* Do not expose backend naming quirks in UI code.

Bad:

```dart
Text(userJson['first_name'])
```

Better:

```dart
Text(user.displayName)
```

But do not over-map tiny apps to death. If the app is small and the API is stable, one model may be enough until pressure appears.

---

## 2.19 Navigation and routing cleanup

Rules:

* Keep route names/paths centralized.
* Do not push raw strings from random widgets.
* Do not pass huge mutable objects through routes.
* Pass IDs, then load state from repository/cache.
* Keep auth guards outside leaf widgets.
* Keep deep-link parsing testable.
* Avoid navigation inside repositories or data services.

Bad:

```dart
repository.saveOrder(order);
Navigator.of(context).pushNamed('/success');
```

Better:

* application layer emits success
* UI reacts and navigates
* route layer owns path details

---

## 2.20 Forms

Rules:

* Text controllers belong to the widget that owns the field lifecycle.
* Validation rules belong outside raw widget code when reused.
* Do not validate the entire form on every keystroke unless UX requires it.
* Debounce remote validation.
* Keep submit state explicit: idle, editing, submitting, success, failure.
* Disable submit while submitting.
* Do not use `BuildContext` after `await` unless `mounted` is checked.

Example:

```dart
Future<void> submit() async {
  final isValid = formKey.currentState?.validate() ?? false;

  if (!isValid) return;

  setState(() => isSubmitting = true);

  final result = await widget.onSubmit();

  if (!mounted) return;

  setState(() => isSubmitting = false);

  switch (result) {
    case SubmitSuccess():
      Navigator.of(context).pop();
    case SubmitFailure(:final message):
      showError(message);
  }
}
```

---

## 2.21 Animations

Rules:

* Prefer implicit animations for simple transitions.
* Use explicit controllers only when timing/control matters.
* Dispose controllers.
* Avoid animating layout-heavy properties if transform/opacity works.
* Avoid expensive blur/shader animations unless profiled.
* Keep animation subtrees small.
* Use `AnimatedBuilder.child` for static children.

Good:

```dart
AnimatedBuilder(
  animation: controller,
  child: const ExpensiveStaticChild(),
  builder: (context, child) {
    return Transform.scale(
      scale: controller.value,
      child: child,
    );
  },
)
```

The static child is not rebuilt every tick.

---

## 2.22 Platform channels and native boundaries

Rules:

* Keep platform channel code behind a small Dart interface.
* Do not call channels directly from widgets.
* Batch calls when possible.
* Avoid chatty method channels in scrolling or animation paths.
* Handle platform errors as typed failures.
* Test fallback behavior when a platform API is missing.
* Keep permission logic explicit and user-facing.

Bad:

```dart
final battery = await MethodChannel('battery').invokeMethod('getBattery');
```

inside a widget.

Better:

* `BatteryService`
* repository/use case calls service
* UI observes typed state

---

## 2.23 Build flavors and configuration

Rules:

* Separate dev/staging/prod entrypoints.
* Do not scatter environment checks across features.
* Keep config immutable at runtime unless it is remote config.
* Do not put secrets in Dart code.
* Validate config at startup.

Example layout:

```text
lib/
├── main_development.dart
├── main_staging.dart
├── main_production.dart
└── src/app/bootstrap.dart
```

Bootstrap:

```dart
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = reportFlutterError;

  runApp(App(config: config));
}
```

---

## 2.24 Testing that catches real regressions

Testing split:

* unit tests for domain, mappers, repositories, Cubits/Notifiers
* widget tests for views and UI states
* golden tests for design-system-level surfaces
* integration tests for critical flows only
* performance smoke tests for scroll-heavy or animation-heavy screens

Rules:

* Test states, not implementation details.
* Prefer finding by semantics/text/role-like behavior over random keys.
* Use keys for identity, not as a testing crutch.
* Golden tests must run on a pinned OS.
* Do not snapshot giant widget trees.
* Mock at boundaries, not everywhere.

Cubit test:

```dart
blocTest<LoginCubit, LoginState>(
  'emits submitting then success',
  build: () => LoginCubit(authRepository: authRepository),
  setUp: () {
    when(() => authRepository.login(any(), any()))
        .thenAnswer((_) async => const LoginResult.success());
  },
  act: (cubit) => cubit.submit('user@example.com', 'password'),
  expect: () => [
    const LoginState.submitting(),
    const LoginState.success(),
  ],
);
```

---

## 2.25 Performance review checklist

Before merging a UI-heavy PR, check:

* Does it add work in `build()`?
* Does it create futures/streams/controllers in `build()`?
* Does it rebuild a whole page for a tiny state change?
* Does it add `Opacity`, blur, clipping, shader, or shadow in a list?
* Does it use lazy lists for large data?
* Does it decode oversized images?
* Does it add a package for a trivial helper?
* Does it leak controllers/subscriptions?
* Does it use `shrinkWrap: true` in a large list?
* Does it pass raw JSON into UI?
* Does it add global state for local state?
* Does it have a profile trace for performance-sensitive changes?

---

## 2.26 Cleanup playbooks

### God widget cleanup

Symptoms:

* 300+ line widget
* many `setState` calls
* controllers mixed with API calls
* validation, navigation, fetching, and rendering all in one class

Steps:

1. Extract pure leaf widgets.
2. Move controllers/state to smallest owning widgets.
3. Move fetching/mutation into Cubit/Notifier.
4. Move parsing/mapping into repository/data layer.
5. Add widget tests for main states.
6. Delete dead helpers.
7. Profile before and after.

### Slow scrolling cleanup

Steps:

1. Run in profile mode.
2. Check raster vs UI thread.
3. Replace eager `Column` with lazy list.
4. Add stable keys.
5. Remove expensive visual effects from row widgets.
6. Resize images.
7. Precompute display strings outside item builder when needed.
8. Use selectors to avoid list-wide rebuilds.
9. Retest on low-end device.

### State explosion cleanup

Steps:

1. List every state field.
2. Mark each as local UI, feature UI, domain, cache, or app-global.
3. Move local UI state down.
4. Split unrelated Cubit/Notifier state.
5. Use selectors.
6. Delete state that can be derived cheaply.
7. Keep only canonical state.

### Dependency cleanup

Steps:

1. Run `flutter pub deps`.
2. Identify packages used once.
3. Replace trivial packages with local code.
4. Remove abandoned packages.
5. Collapse duplicate packages with overlapping jobs.
6. Run app on every target platform.
7. Commit dependency removal separately.

---

## 2.27 Anti-patterns to refuse

Refuse or strongly push back on:

* `_buildHeader()` helper forests instead of real widgets
* API calls in `build()`
* `FutureBuilder(future: repo.fetch())` with inline future creation
* top-level `models/screens/widgets/services/helpers`
* one global Cubit for the whole app
* `GetX` for long-lived production architecture without strong reason
* service locator as default dependency style
* `shrinkWrap: true` as a layout bandage
* giant `SingleChildScrollView` + `Column` lists
* `Opacity`/blur/shader effects in every list row
* passing raw JSON into widgets
* swallowing errors and showing empty UI
* catching `Exception` everywhere
* adding Melos before package boundaries exist
* adding codegen to tiny apps that do not need it
* keeping two state-management systems forever
* committing generated churn without a team policy
* ignoring analyzer warnings because "it works"

---

## 2.28 Escalation thresholds

| Symptom                                       | Action                                              |
| --------------------------------------------- | --------------------------------------------------- |
| Widget >150 lines                             | Extract leaf widgets and state owners               |
| Build method >50 lines                        | Split by semantic UI sections                       |
| More than 3 unrelated `setState` calls        | Introduce smaller state owners                      |
| Whole page rebuilds for one badge/text change | Use selector or split state                         |
| Scroll jank in profile mode                   | Audit item builder, images, effects, list structure |
| Large image memory spikes                     | Resize/decode/cache correctly                       |
| Feature has >5 Cubits/Notifiers               | Reconsider feature boundary                         |
| App >50K LOC or multi-app sharing             | Evaluate Melos/package split                        |
| CI >10 minutes                                | shard tests, cache, split integration tests         |
| Dependency added for tiny helper              | inline it or create local utility                   |
| Repeated platform conditionals                | create platform service boundary                    |

---

## 2.29 Source families

Use these when validating or updating this file:

* Flutter performance best practices
* Flutter performance profiling
* Flutter app architecture guide
* Effective Dart
* Dart analyzer/linter rules
* very_good_analysis
* VGV architecture and testing patterns
* BLoC documentation
* Riverpod documentation
* Code with Andrea architecture notes
* Flutter DevTools documentation
