# Industry Pack — Mobile Android (Material 3 Expressive)

For Android apps built with Jetpack Compose or XML views, and Flutter apps using
Material widgets. Anchored to **Material 3 Expressive**, announced at the
**Android Show I/O Edition** on **May 13, 2025**, with general availability in
2025–2026 across Android 16, Wear OS 6, and Material Components.

Reference points: Google's flagship apps (Gmail, Calendar, Photos, Maps,
Messages, Drive, YouTube), **Material You** showcases, **Linear Android**,
**Notion Android**, **Spotify**, **Twitter/X**, **TickTick, Todoist**, **Pocket
Casts, Plex, Tasker, Microsoft Outlook for Android**.

---

## Pack Identity

Material 3 Expressive emphasizes:

- **Spring-based motion** as the default (replacing fixed easing curves)
- **Shape morphing** — components change shape on press (pill → rounded square)
- **Larger, bolder typography** with weight variation as the primary hierarchy
  driver (Bold over Big)
- **Color expressiveness** via dynamic Material You palette generation
- **Floating Toolbars / FAB Menus** replacing bottom app bars
- **Pill-shaped buttons** as the new default
- **5 button sizes** (XS / S / M / L / XL)
- **48dp minimum tap target** (always)
- **Navigation bar now 64dp** (down from 80dp in Material 3 stock)

---

## Token Overrides

```css
:root[data-pack="android"] {
  /* M3 dynamic color — use the user's wallpaper-based primary by default */
  --color-accent: oklch(60% 0.16 280);          /* default purple, will be overridden by Material You */
  --color-accent-fg: oklch(99% 0.01 280);
  --color-accent-soft: oklch(95% 0.04 280);
  --color-accent-strong: oklch(50% 0.18 280);

  /* M3 radii */
  --radius-button: 9999px;                      /* pill */
  --radius-input: 0.25rem;                      /* 4dp */
  --radius-card: 0.75rem;                       /* 12dp */
  --radius-modal: 1.75rem;                      /* 28dp - M3 modal corner */
  --radius-bottomsheet: 1.75rem;                /* 28dp top corner only */

  /* Roboto Flex variable */
  --font-sans: "Roboto Flex", "Roboto", system-ui, sans-serif;
  --font-display: "Roboto Flex", "Roboto", system-ui, sans-serif;

  /* M3 leading */
  --leading-display: 1.12;
  --leading-headline: 1.25;
  --leading-title: 1.4;
  --leading-body: 1.45;
  --leading-label: 1.3;
}
```

For pure Material You (wallpaper-driven):
```css
:root[data-pack="android-you"] {
  --color-accent: oklch(var(--m3-primary));     /* sourced from system at runtime */
}
```

---

## The Material 3 Color System

M3 introduces **roles** instead of named colors. Each role has an `on*` companion
(for text/icon on that surface) and `*-container` variants (for backgrounds that
sit on top of the base).

### Primary palette

```
primary               — primary brand surface color (e.g., FAB background)
onPrimary             — text/icon on primary
primaryContainer      — softer container holding primary content
onPrimaryContainer    — text on primary container
```

Same pattern for `secondary`, `tertiary`, `error`, `surface`, `inverseSurface`.

### Full M3 Color Roles

```
primary, onPrimary, primaryContainer, onPrimaryContainer
secondary, onSecondary, secondaryContainer, onSecondaryContainer
tertiary, onTertiary, tertiaryContainer, onTertiaryContainer
error, onError, errorContainer, onErrorContainer
background, onBackground
surface, onSurface
surfaceVariant, onSurfaceVariant
surfaceDim, surfaceBright
surfaceContainerLowest, surfaceContainerLow, surfaceContainer,
  surfaceContainerHigh, surfaceContainerHighest
inverseSurface, inverseOnSurface, inversePrimary
outline, outlineVariant
scrim, shadow
```

13-tone palettes generate these from a single source color. With **Material You**,
that source color comes from the user's wallpaper at runtime.

### 3:1 contrast minimum for roles

All `on*` colors guarantee 3:1 contrast against their base. For body text use
`onSurface` on `surface` (always passes 4.5:1).

### In Compose

```kotlin
MaterialTheme(
  colorScheme = if (isSystemInDarkTheme()) darkColorScheme() else lightColorScheme(),
  typography = Typography(),
) {
  Surface(color = MaterialTheme.colorScheme.surface) {
    Text("Hello", color = MaterialTheme.colorScheme.onSurface)
  }
}
```

For dynamic Material You:
```kotlin
val colorScheme = when {
  Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
    if (isSystemInDarkTheme()) dynamicDarkColorScheme(context)
    else dynamicLightColorScheme(context)
  }
  isSystemInDarkTheme() -> darkColorScheme()
  else -> lightColorScheme()
}
```

---

## Typography — The 15-Token Scale

M3 has 15 typography tokens (5 roles × 3 sizes). Apply via `MaterialTheme.typography`.

| Token | Size | Weight | Line height | Letter spacing |
|---|---|---|---|---|
| **Display Large** | 57sp | Regular 400 | 64sp | -0.25 |
| **Display Medium** | 45sp | Regular 400 | 52sp | 0 |
| **Display Small** | 36sp | Regular 400 | 44sp | 0 |
| **Headline Large** | 32sp | Regular 400 | 40sp | 0 |
| **Headline Medium** | 28sp | Regular 400 | 36sp | 0 |
| **Headline Small** | 24sp | Regular 400 | 32sp | 0 |
| **Title Large** | 22sp | Regular 400 | 28sp | 0 |
| **Title Medium** | 16sp | Medium 500 | 24sp | 0.15 |
| **Title Small** | 14sp | Medium 500 | 20sp | 0.1 |
| **Body Large** | 16sp | Regular 400 | 24sp | 0.5 |
| **Body Medium** | 14sp | Regular 400 | 20sp | 0.25 |
| **Body Small** | 12sp | Regular 400 | 16sp | 0.4 |
| **Label Large** | 14sp | Medium 500 | 20sp | 0.1 |
| **Label Medium** | 12sp | Medium 500 | 16sp | 0.5 |
| **Label Small** | 11sp | Medium 500 | 16sp | 0.5 |

In Compose:
```kotlin
Text("Title", style = MaterialTheme.typography.titleLarge)
Text("Body copy", style = MaterialTheme.typography.bodyLarge)
Text("Button", style = MaterialTheme.typography.labelLarge)
```

### Roboto Flex variable

M3 Expressive (2025) ships **Roboto Flex** as the primary typeface — variable axes:
- Weight: 100–1000
- Width: 25–151%
- Optical size: 8–144
- Slant, grade, ascender height, descender depth, counter width, all variable

The "Bold over Big" principle: use weight (500 → 700) to convey hierarchy on the
same scale, instead of jumping size tokens.

### Display Flexible Variants (M3 Expressive only)

New in 2025: "Display Medium Flexible" and "Display Large Flexible" let apps use
larger, more expressive typography for product moments. Used in Google's flagship
apps for empty states, onboarding, hero moments.

---

## Buttons — 5 Sizes, 5 Styles

M3 Expressive ships **5 button sizes** and **5 button styles**.

### Sizes

| Size | Height | Use |
|---|---|---|
| **XS** | 32dp | Inline, dense lists, chips-adjacent |
| **S** | 36dp | Secondary actions in tight spaces |
| **M** | 40dp | Default |
| **L** | 48dp | Primary actions, mobile CTAs |
| **XL** | 56dp | Hero CTAs, "Continue" in onboarding |

```kotlin
Button(onClick = { }) { Text("Default M") }
Button(onClick = { }, modifier = Modifier.height(48.dp)) { Text("L") }
Button(
  onClick = { },
  modifier = Modifier.height(56.dp),
  contentPadding = PaddingValues(horizontal = 24.dp),
) { Text("XL") }
```

### Styles

| Style | Background | Use |
|---|---|---|
| **Filled** | `primary` | Primary action per screen |
| **Filled Tonal** | `secondaryContainer` | Co-equal action, softer than filled |
| **Elevated** | `surface` + shadow | Action that needs to lift off background |
| **Outlined** | transparent + outline | Secondary action |
| **Text** | transparent | Lowest-emphasis action, links |

```kotlin
Button(onClick = { }) { Text("Filled") }              // primary
FilledTonalButton(onClick = { }) { Text("Tonal") }    // secondary
ElevatedButton(onClick = { }) { Text("Elevated") }
OutlinedButton(onClick = { }) { Text("Outlined") }
TextButton(onClick = { }) { Text("Text") }
```

### Pill shape default, shape-morphs on press

M3 Expressive defaults all buttons to pill shape. On press, the shape morphs to
a slightly more rounded square via spring animation. The default is enabled when
using `ButtonDefaults.shape`.

```kotlin
Button(
  onClick = { },
  shape = ButtonDefaults.shape       // pill, morphs on press
) { Text("Action") }
```

### Icon buttons

```kotlin
IconButton(onClick = { }) {
  Icon(Icons.Default.Settings, contentDescription = "Settings")
}

// Toggleable
IconToggleButton(checked = isChecked, onCheckedChange = { isChecked = it }) {
  Icon(
    if (isChecked) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
    contentDescription = "Like"
  )
}
```

48dp tap target minimum. Always provide `contentDescription` for TalkBack.

---

## Navigation Bar (Bottom Nav)

Material 3 Expressive: **64dp height** (reduced from M3 standard 80dp). Active
indicator: 56dp pill behind the selected icon.

```kotlin
NavigationBar(modifier = Modifier.height(64.dp)) {
  navItems.forEach { item ->
    NavigationBarItem(
      icon = { Icon(item.icon, contentDescription = item.label) },
      label = { Text(item.label) },
      selected = currentRoute == item.route,
      onClick = { navigate(item.route) }
    )
  }
}
```

### Behaviors

- Active label not bold by default (M3 Expressive change — was bold in original M3).
- Labels always visible (selected and unselected).
- 3–5 items max. >5 items: use Navigation Drawer or Navigation Rail.

### Material You Color

Selected item indicator uses `secondaryContainer`. Icons use `onSurfaceVariant`
(unselected) → `onSecondaryContainer` (selected).

---

## Top App Bars

Four variants:

| Variant | Height | Use |
|---|---|---|
| **Small** | 64dp | Default for nested screens |
| **Center-aligned Small** | 64dp | Title centered (Material You style) |
| **Medium Flexible** | ~112dp | Important pages with extra space |
| **Large Flexible** | ~152dp | Hero pages, top-level destinations |

```kotlin
// Small top app bar
TopAppBar(
  title = { Text("Inbox") },
  navigationIcon = {
    IconButton(onClick = { /* back */ }) {
      Icon(Icons.Default.ArrowBack, contentDescription = "Back")
    }
  },
  actions = {
    IconButton(onClick = { /* search */ }) {
      Icon(Icons.Default.Search, contentDescription = "Search")
    }
  }
)

// Large top app bar that collapses on scroll
LargeTopAppBar(
  title = { Text("Inbox", style = MaterialTheme.typography.displaySmall) },
  scrollBehavior = scrollBehavior
)
```

### Scroll behaviors

- `pinnedScrollBehavior` — stays at top
- `enterAlwaysScrollBehavior` — collapses on scroll down, reappears on scroll up
- `exitUntilCollapsedScrollBehavior` — collapses to small variant, large only at top

Large Flexible is the equivalent of iOS's "large title" — big at top, collapses
to small on scroll.

---

## Bottom Sheets

Two variants:

### Standard Bottom Sheet

Inline with content (e.g., Google Maps location details). Always visible at
collapsed state, expands on drag.

```kotlin
BottomSheetScaffold(
  sheetContent = { LocationDetails() },
  sheetPeekHeight = 128.dp,
) { padding ->
  MapView(padding)
}
```

### Modal Bottom Sheet

Overlay with scrim. Used for actions, filters, share sheets.

```kotlin
val sheetState = rememberModalBottomSheetState()
val coroutineScope = rememberCoroutineScope()

ModalBottomSheet(
  onDismissRequest = { coroutineScope.launch { sheetState.hide() } },
  sheetState = sheetState,
  dragHandle = { BottomSheetDefaults.DragHandle() }
) {
  FilterContent()
}
```

Rounded top corners (28dp). Drag handle visible by default. Swipe-down dismisses.

---

## FAB and FAB Menu (NEW in M3 Expressive)

### Floating Action Button

```kotlin
FloatingActionButton(onClick = { compose() }) {
  Icon(Icons.Default.Edit, contentDescription = "Compose")
}

// Extended (with text)
ExtendedFloatingActionButton(
  onClick = { compose() },
  icon = { Icon(Icons.Default.Edit, null) },
  text = { Text("Compose") }
)

// Small / Large variants
SmallFloatingActionButton(onClick = { }) { Icon(...) }
LargeFloatingActionButton(onClick = { }) { Icon(...) }
```

### FAB Menu (NEW)

When a single action isn't enough, FAB expands into a menu of secondary actions.
M3 Expressive introduces this as a stock component.

```kotlin
FloatingActionButtonMenu(
  expanded = expanded,
  button = {
    ToggleFloatingActionButton(
      checked = expanded,
      onCheckedChange = { expanded = it }
    ) {
      Icon(Icons.Default.Add, null)
    }
  }
) {
  FloatingActionButtonMenuItem(onClick = { }, icon = { Icon(Icons.Default.Email, null) }, text = { Text("Email") })
  FloatingActionButtonMenuItem(onClick = { }, icon = { Icon(Icons.Default.Call, null) }, text = { Text("Call") })
  FloatingActionButtonMenuItem(onClick = { }, icon = { Icon(Icons.Default.Message, null) }, text = { Text("Message") })
}
```

Replaces the older "speed dial" pattern.

---

## Toolbars — Docked and Floating (NEW)

M3 Expressive deprecates the Bottom App Bar in favor of:

### Docked Toolbar

```kotlin
DockedToolbar(
  modifier = Modifier.height(64.dp),
  navigationIcon = { IconButton(...) { Icon(...) } },
  actions = {
    IconButton(onClick = { }) { Icon(Icons.Default.Search, null) }
    IconButton(onClick = { }) { Icon(Icons.Default.MoreVert, null) }
  }
)
```

### Floating Toolbar

Translucent material, floats above content like iOS Liquid Glass equivalent.

```kotlin
FloatingToolbar(
  modifier = Modifier
    .align(Alignment.BottomCenter)
    .padding(16.dp)
) {
  IconButton(onClick = { }) { Icon(Icons.Default.FormatBold, null) }
  IconButton(onClick = { }) { Icon(Icons.Default.FormatItalic, null) }
  IconButton(onClick = { }) { Icon(Icons.Default.FormatUnderlined, null) }
}
```

Use for: text editor formatting bars, contextual action sets, media player controls.

---

## Lists

### List Item Spec (M3)

| Lines | Height (no avatar) | Height (with avatar) |
|---|---|---|
| 1 line | 48dp | 56dp |
| 2 lines | 64dp | 72dp |
| 3 lines | 88dp | 88dp |

Always 16dp horizontal padding.

```kotlin
ListItem(
  headlineContent = { Text("Project Apollo") },
  supportingContent = { Text("Last updated 3 hours ago") },
  leadingContent = { Icon(Icons.Default.Folder, null) },
  trailingContent = { Icon(Icons.Default.ChevronRight, null) },
  modifier = Modifier.clickable { open() }
)
```

### Dividers

Use `HorizontalDivider()` between sections, not between every item. Material 3
deprecated the always-divided list in favor of section-only dividers.

---

## Motion — Springs Replace Easing

M3 Expressive replaces fixed-duration easing with **spring physics tokens** as the
default for important transitions.

### Spring tokens

```kotlin
// In Compose, the default for state animations
spring<Float>(
  dampingRatio = Spring.DampingRatioNoBouncy,
  stiffness = Spring.StiffnessMedium
)

// Categories
Spring.DampingRatioHighBouncy
Spring.DampingRatioMediumBouncy
Spring.DampingRatioLowBouncy
Spring.DampingRatioNoBouncy

Spring.StiffnessHigh
Spring.StiffnessMedium
Spring.StiffnessMediumLow
Spring.StiffnessLow
Spring.StiffnessVeryLow
```

### Easing curves (still available for non-spring)

```kotlin
MotionTokens.EasingStandardCubicBezier              // cubic-bezier(0.2, 0, 0, 1)
MotionTokens.EasingEmphasizedCubicBezier            // important transitions
MotionTokens.EasingEmphasizedDecelerateCubicBezier  // incoming elements
MotionTokens.EasingEmphasizedAccelerateCubicBezier  // outgoing
```

### Duration tokens

```
short1 = 50ms
short2 = 100ms
short3 = 150ms
short4 = 200ms
medium1 = 250ms
medium2 = 300ms
medium3 = 350ms
medium4 = 400ms
long1 = 450ms
long2 = 500ms
long3 = 550ms
long4 = 600ms
extraLong1 = 700ms
extraLong2 = 800ms
extraLong3 = 900ms
extraLong4 = 1000ms
```

Default for UI feedback: `short3` (150ms) to `medium1` (250ms).

### When to use spring vs easing

- **Spring**: drag, gesture release, shape morphing, important state changes.
- **Easing**: enter/exit, predictable transitions, simple property changes.

---

## Shape System

M3 has a shape system with five named tokens:

```
extraSmall = 4dp
small = 8dp
medium = 12dp
large = 16dp
extraLarge = 28dp
full = 9999dp (pill)
```

Applied per-component default:
- Buttons → full (pill)
- Cards → medium (12dp)
- Modals / sheets → extraLarge (28dp)
- Inputs → extraSmall (4dp)
- Snackbars → extraSmall

In Compose:
```kotlin
Card(shape = MaterialTheme.shapes.medium) { ... }
```

---

## Snackbars (the Toast equivalent)

```kotlin
val snackbarHostState = remember { SnackbarHostState() }
val scope = rememberCoroutineScope()

Scaffold(
  snackbarHost = { SnackbarHost(snackbarHostState) }
) { padding ->
  Button(onClick = {
    scope.launch {
      snackbarHostState.showSnackbar(
        message = "Project saved",
        actionLabel = "Undo",
        duration = SnackbarDuration.Short
      )
    }
  }) { Text("Save") }
}
```

- Position: bottom of screen.
- Duration: Short (~4s) / Long (~7s) / Indefinite.
- One snackbar at a time.
- Includes action when reversible.

---

## Material You Dynamic Color

Android 12+ supports user-wallpaper-derived themes. Opt in:

```kotlin
val colorScheme = when {
  Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
    val context = LocalContext.current
    if (darkTheme) dynamicDarkColorScheme(context)
    else dynamicLightColorScheme(context)
  }
  darkTheme -> darkColorScheme()
  else -> lightColorScheme()
}
```

For apps where brand identity is critical, **don't** use dynamic color — provide a
fixed `ColorScheme`. For consumer apps where personalization is welcome (Calendar,
Notes, Messages), opt in.

---

## The 15 Android Mobile Rules

**1.** **48dp minimum tap targets.** Material guideline, hard floor.

**2.** **Use Material Components**, don't reinvent buttons, sliders, switches.

**3.** **Roboto Flex** as the default typeface; weight contrast > size contrast.

**4.** **Pill-shaped buttons** as default (M3 Expressive).

**5.** **Bottom navigation 64dp**, max 5 items, labels always visible.

**6.** **Large flexible top app bars** for top-level destinations; small for drill-down.

**7.** **Modal bottom sheets** for actions/filters, not centered dialogs.

**8.** **Spring physics** for state-meaningful motion, not fixed easing.

**9.** **Shape morphing on button press** (M3 Expressive default).

**10.** **Dynamic color** for consumer apps; fixed scheme for brand-critical apps.

**11.** **FAB Menu** for multi-action primary; FAB for single primary.

**12.** **Floating Toolbars** for contextual action sets (deprecated Bottom App Bar).

**13.** **Material 3 list item heights** strict: 48 / 56 / 64 / 72 / 88dp.

**14.** **TalkBack labels** on every Icon-only button (`contentDescription`).

**15.** **Test with TalkBack on**, large font size (200%), and dark theme.

---

## Flutter Material (cross-platform Android target)

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Color(0xFF5E6AD2),
    typography: Typography.material2021(),
  ),
  home: Scaffold(
    appBar: AppBar(title: Text('Home')),
    body: ListView(
      children: [
        ListTile(
          title: Text('Item'),
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () { },
      child: Icon(Icons.add),
    ),
    bottomNavigationBar: NavigationBar(
      destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
      ],
      selectedIndex: 0,
      onDestinationSelected: (i) { },
    ),
  ),
)
```

Flutter's M3 support as of 2026 includes most M3 Expressive components, with FAB
Menu and Floating Toolbar landing in 2025–2026 updates.

---

## Apple vs Material — The Contradictions Table

Cross-platform apps must respect platform conventions. Here's where the systems
diverge:

| Concern | iOS | Material 3 |
|---|---|---|
| Primary action position | Trailing (right) in nav | Bottom right (FAB) or right in app bar |
| Modal style | Bottom sheet with detents | Modal bottom sheet OR dialog |
| Back navigation | Top-left chevron + label | Top-left arrow icon |
| Top nav title | Large title that collapses | Small or Large Flexible app bar |
| Tap target | 44pt | 48dp |
| Font | SF Pro variable | Roboto Flex variable |
| Hierarchy driver | Size + weight (Dynamic Type) | Weight > size (Bold over Big) |
| Button shape default | Capsule (`.buttonBorderShape(.capsule)`) | Pill |
| Motion default | Smooth ease | Spring physics |
| Tab bar height | ~49pt (now glass, minimize on scroll) | 64dp (down from 80dp) |
| Empty space treatment | Generous | Slightly tighter |
| Color generation | Custom or system blue | Material You from wallpaper |

For cross-platform: provide a platform-aware shim layer. Don't ship Material UI to
iOS or Cupertino UI to Android.

---

## Hard Bans for Android Pack

- ❌ iOS-style centered dialogs on Android (use bottom sheets).
- ❌ Tap targets below 48dp.
- ❌ Hardcoded colors that ignore Material You / dynamic theming.
- ❌ Bottom app bars (deprecated in M3 Expressive; use Docked/Floating Toolbar).
- ❌ Old M3 navigation bar heights (80dp) — use 64dp.
- ❌ Bold selected labels in nav bar (M3 Expressive changed this default).
- ❌ Fixed-duration easing for state-meaningful transitions (use springs).
- ❌ Pre-Roboto-Flex fonts (Roboto, Noto Sans) when Roboto Flex is available.
- ❌ Ignoring Dynamic Type / font scale settings.
- ❌ Snackbars stacking (one at a time, latest wins).
- ❌ FABs that don't expand to FAB Menu when multiple actions exist.
- ❌ Custom toggles / sliders when Material variants suffice.
