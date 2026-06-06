# Industry Pack — Mobile iOS (Liquid Glass)

For iOS / iPadOS apps built with SwiftUI or UIKit, and Flutter apps using Cupertino
widgets. Anchored to **iOS 26 Liquid Glass** (announced at WWDC25 on June 9, 2025;
shipping fall 2025) and Apple Human Interface Guidelines as of 2025–2026.

Reference points: Apple stock apps (Mail, Messages, Photos, Music, Settings,
Maps, Notes), **Things 3, Bear, Day One, Carrot Weather, Overcast, Apollo, Tweetbot
2** (RIP), **Reeder, Castro, Pixelmator, MoneyMoney, Dark Sky** (RIP), modern
**Linear Mobile, Cron** (now Notion Calendar), **Figma, Cash App, Robinhood**.

---

## Pack Identity

iOS lives by:

- **Liquid Glass material** — translucent layers that pick up content underneath,
  shipping system-wide in iOS 26 across iOS, iPadOS, macOS, watchOS, tvOS, visionOS
- **Concentric geometry** — child radii subtract from parent radii
- **Dynamic Type** — text scales to user preference, never hardcoded
- **Sheet detents** — modals are sheets with size detents (medium, large, custom)
- **Tab bars minimize on scroll** — content takes priority over chrome (iOS 26
  default)
- **44pt minimum tap targets** (Apple HIG)
- **SF Pro variable** — system font with optical sizing

---

## The Liquid Glass System (iOS 26)

Announced at WWDC25 session #356 ("Meet Liquid Glass"). The first major iOS visual
redesign since iOS 7 (2013).

Apple Newsroom (June 9, 2025): "Liquid Glass is a new translucent material that
reflects and refracts its surroundings, while dynamically transforming to help bring
greater focus to content."

### Where Liquid Glass appears

System-wide:
- Tab bars (translucent, minimize on scroll)
- Sidebars (translucent over content)
- Toolbars
- Buttons (`.buttonStyle(.glass)`)
- App icons (refractive translucent layers)
- Sliders, switches, alerts
- Search fields (now floating in many cases)

### SwiftUI API

```swift
// Apply Liquid Glass material to any view
SomeView()
  .glassEffect()                           // basic glass
  .glassEffect(.regular)                   // tinted variant
  .glassEffect(in: .capsule)               // glass with shape

// Button with glass style
Button("Save") { /* ... */ }
  .buttonStyle(.glass)
  .buttonBorderShape(.capsule)

// Tab bar that minimizes on scroll
TabView {
  HomeView().tabItem { Label("Home", systemImage: "house") }
  SearchView().tabItem { Label("Search", systemImage: "magnifyingglass") }
}
.tabBarMinimizeBehavior(.onScrollDown)     // iOS 26+ default behavior

// Bottom tab accessory (mini player above tab bar)
.tabViewBottomAccessory {
  MiniPlayer()
}
```

### Concentric Radii

The single most important geometric principle in iOS 26+:

> **Child radius = Parent radius − Padding**

A button (height 44pt, capsule radius 22pt) inside a card (radius 16pt, padding
8pt): the button's radius stays 22pt because it's already smaller than parent
minus padding (16 − 8 = 8). But if you have a child *container* with 8pt padding
inside that card, its radius should be 8pt.

```swift
ZStack {
  RoundedRectangle(cornerRadius: 16)       // parent
    .padding(8)

  RoundedRectangle(cornerRadius: 8)        // child: 16 - 8
}
```

This is the geometry that makes Apple's UI look "right" while custom UIs look "off."
The default UI of every iOS 17 → iOS 26 system control follows this rule.

---

## Token Overrides

```css
/* For React Native or Flutter using web-style tokens */
:root[data-pack="ios"] {
  /* iOS system blue is the default accent */
  --color-accent: oklch(60% 0.18 250);          /* SF Blue */

  /* iOS background palette */
  --color-bg: oklch(99% 0.005 270);             /* systemBackground */
  --color-surface: oklch(96% 0.005 270);        /* secondarySystemBackground */
  --color-surface-2: oklch(93% 0.005 270);      /* tertiarySystemBackground */
  --color-border: oklch(85% 0.005 270);         /* separator */

  /* iOS uses concentric radii — set base values */
  --radius-card: 0.875rem;                      /* 14pt typical */
  --radius-modal: 1rem;                         /* 16pt sheet corners */
  --radius-button: 9999px;                      /* capsule */

  /* iOS Dynamic Type baseline — actual sizes set per text style */
  --font-sans: "SF Pro Text", -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif;
  --font-display: "SF Pro Display", -apple-system, BlinkMacSystemFont, sans-serif;
  --font-mono: "SF Mono", "Menlo", ui-monospace, monospace;
}

.dark[data-pack="ios"] {
  --color-bg: oklch(10% 0.005 270);             /* iOS dark base */
  --color-surface: oklch(15% 0.005 270);
  --color-surface-2: oklch(20% 0.005 270);
  --color-border: oklch(25% 0.005 270);
}
```

### iOS semantic colors (full list)

Apple provides these as system colors; respect them on iOS native apps.

```
label                  — primary text
secondaryLabel         — secondary text
tertiaryLabel          — tertiary text
quaternaryLabel        — quaternary text (placeholder-tier)

systemBackground       — primary background
secondarySystemBackground
tertiarySystemBackground

systemFill, secondarySystemFill, tertiarySystemFill, quaternarySystemFill
  — for filling shapes (chips, indicators)

separator              — opaque separator
opaqueSeparator        — non-translucent separator

systemBlue             — blue accent
systemGreen, systemRed, systemOrange, systemYellow, systemPink, systemPurple,
systemTeal, systemIndigo, systemBrown, systemMint, systemCyan

systemGray, systemGray2, ..., systemGray6
  — neutral fills, 6-tier scale
```

In SwiftUI:
```swift
Text("Title").foregroundStyle(.primary)
Text("Subtitle").foregroundStyle(.secondary)
Color(.systemBackground)
Color(.systemBlue)
```

---

## Dynamic Type — The 11 Text Styles

Apple defines 11 text styles. Always use them; never hardcode point sizes.

| Style | Default size | Weight |
|---|---|---|
| `largeTitle` | 34pt | Regular |
| `title` | 28pt | Regular |
| `title2` | 22pt | Regular |
| `title3` | 20pt | Regular |
| `headline` | 17pt | Semibold |
| `body` | 17pt | Regular |
| `callout` | 16pt | Regular |
| `subheadline` | 15pt | Regular |
| `footnote` | 13pt | Regular |
| `caption` | 12pt | Regular |
| `caption2` | 11pt | Regular |

```swift
Text("Welcome").font(.largeTitle)
Text("Subtitle").font(.body)
```

Users can scale these globally via Settings → Display & Brightness → Text Size, OR
via Accessibility → Display & Text Size → Larger Text (which goes to AX5, much
larger). Apps must support both.

Test your layout at default + 3 sizes up + the largest accessibility size.

---

## Tab Bars (iOS 26+)

The tab bar now minimizes on downward scroll. This is the **default behavior** —
opt out only when there's a specific reason.

```swift
TabView {
  HomeView()
    .tabItem { Label("Home", systemImage: "house.fill") }
  SearchView()
    .tabItem { Label("Search", systemImage: "magnifyingglass") }
  ProfileView()
    .tabItem { Label("Profile", systemImage: "person.circle") }
}
.tabBarMinimizeBehavior(.onScrollDown)
```

**Behaviors**:
- `.onScrollDown` — minimize when user scrolls down (default in iOS 26)
- `.never` — always visible
- `.automatic` — system decides based on content

### Tab Bar Bottom Accessory

iOS 26 introduces a "bottom accessory" that floats above the tab bar — common
pattern is a mini media player.

```swift
TabView { ... }
  .tabViewBottomAccessory {
    HStack {
      Image("album-art").frame(width: 32, height: 32)
      Text("Song title").font(.subheadline)
      Spacer()
      Button { /* play/pause */ } label: { Image(systemName: "play.fill") }
    }
    .padding(.horizontal)
    .glassEffect()
  }
```

Used by Apple Music, Podcasts, third-party media apps.

---

## Sheets and Detents

Modals are **sheets** on iOS. Centered dialog boxes don't exist on iOS — they're
desktop UI.

```swift
.sheet(isPresented: $showSheet) {
  EditView()
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
    .presentationCornerRadius(16)
    .presentationBackground(.thinMaterial)
}
```

### Detents

- `.medium` — half-screen sheet (~50% of viewport)
- `.large` — near-full-screen (~90%, leaves status bar visible)
- `.height(300)` — fixed-height custom
- `.fraction(0.4)` — fraction of viewport

The user can drag between detents. Sheets present from the bottom, dismiss by
swipe-down or programmatically.

### Drag indicator

`.presentationDragIndicator(.visible)` shows the small horizontal handle at the top
of the sheet, signaling it can be dragged. Always include for user-dismissible
sheets.

### Sheet corner radius

iOS 26 default is 16pt for sheets. Use `.presentationCornerRadius(16)` for
explicit control.

### Sheet background

```swift
.presentationBackground(.thinMaterial)      // Liquid Glass for the sheet itself
.presentationBackground(Color(.systemBackground))  // opaque
```

---

## Navigation

### NavigationStack (modern, iOS 16+)

```swift
NavigationStack(path: $navigationPath) {
  HomeView()
    .navigationTitle("Home")
    .navigationDestination(for: Project.self) { project in
      ProjectDetailView(project: project)
    }
}
```

Use `NavigationStack` over `NavigationView` (deprecated).

### Navigation Title Styles

```swift
.navigationTitle("Home")
.navigationBarTitleDisplayMode(.large)      // big title at top, collapses on scroll
.navigationBarTitleDisplayMode(.inline)     // compact, always visible
```

`.large` is the default for top-level views. `.inline` for detail/drill-down views.

### Toolbar Items

```swift
.toolbar {
  ToolbarItem(placement: .topBarLeading) {
    Button("Cancel") { dismiss() }
  }
  ToolbarItem(placement: .topBarTrailing) {
    Button("Save") { save() }.fontWeight(.semibold)
  }
}
```

Primary action: trailing, semibold. Cancel/back: leading. iOS 26 toolbar items
inherit Liquid Glass material.

---

## Lists

iOS list comes in three styles. Pick by content.

### `.plain` style

Edge-to-edge rows with separators inset from the leading edge.

```swift
List {
  ForEach(items) { item in
    HStack {
      Image(systemName: item.icon)
      Text(item.name)
      Spacer()
      Text(item.detail).foregroundStyle(.secondary)
    }
  }
}
.listStyle(.plain)
```

Use for: Mail inbox, Messages conversation list, Reminders.

### `.grouped` style (full-width groups)

```swift
List {
  Section("Account") {
    LabeledContent("Name", value: "Jane Doe")
    LabeledContent("Email", value: "jane@acme.com")
  }
  Section("Notifications") {
    Toggle("Push notifications", isOn: $pushOn)
    Toggle("Email", isOn: $emailOn)
  }
}
.listStyle(.grouped)
```

Use for: Settings pages, form-like configuration.

### `.insetGrouped` style (default in iOS 13+)

Same as grouped but with rounded corners inset from edges. Settings.app default.

```swift
.listStyle(.insetGrouped)
```

### Row heights

| Row content | Height |
|---|---|
| Single line, no leading element | 44pt |
| Single line + icon | 44pt |
| Two lines | 60pt |
| Three lines | 76pt |
| With avatar/thumbnail (60pt) | 84pt |

Don't undersize. 44pt is the floor — Apple's tap target minimum.

### Swipe Actions

```swift
.swipeActions(edge: .trailing) {
  Button(role: .destructive) { delete() } label: { Label("Delete", systemImage: "trash") }
  Button { archive() } label: { Label("Archive", systemImage: "archivebox") }
    .tint(.blue)
}
.swipeActions(edge: .leading) {
  Button { markRead() } label: { Label("Read", systemImage: "envelope.open") }
    .tint(.green)
}
```

Max 3 actions per edge. Destructive (red) goes furthest from initial position
(trailing edge default).

---

## Forms (Settings.app pattern)

```swift
Form {
  Section {
    LabeledContent("Display name") { TextField("", text: $name) }
    LabeledContent("Email") {
      TextField("", text: $email)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
    }
  } header: {
    Text("Profile")
  } footer: {
    Text("Your name and email are visible to your team.")
  }

  Section("Notifications") {
    Toggle("Push", isOn: $push)
    Toggle("Email", isOn: $email)
    NavigationLink("Notification details") {
      NotificationDetailView()
    }
  }
}
```

Settings.app-style forms use `Form` + `Section`. Footer text explains what the
section does. Toggles, navigation links, and labeled content are the primary
controls.

---

## Buttons

```swift
// Primary action
Button("Save") { save() }
  .buttonStyle(.borderedProminent)            // pre-iOS 26
  .buttonStyle(.glass)                        // iOS 26+

// Secondary
Button("Cancel") { cancel() }
  .buttonStyle(.bordered)

// Tertiary
Button("Skip") { skip() }
  .buttonStyle(.plain)

// Destructive
Button("Delete", role: .destructive) { delete() }
  .buttonStyle(.borderedProminent)
```

### Shape

```swift
.buttonBorderShape(.capsule)                  // pill (HIG default for large actions)
.buttonBorderShape(.roundedRectangle)         // rectangle with system radius
.buttonBorderShape(.automatic)                // system decides
```

### Size

```swift
.controlSize(.mini)        // small chips
.controlSize(.small)
.controlSize(.regular)     // default
.controlSize(.large)       // primary CTAs, 44pt+ height
.controlSize(.extraLarge)  // iOS 17+, even larger
```

### Tint

```swift
.tint(.blue)                                  // system blue accent
.tint(Color.brand)                            // brand accent
```

Apply `.tint` at the View or NavigationStack level to propagate.

---

## Search

iOS 26 introduces floating search bars (Liquid Glass material).

```swift
NavigationStack {
  ListView()
    .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
    .searchSuggestions {
      ForEach(suggestions) { suggestion in
        Text(suggestion.title).searchCompletion(suggestion.value)
      }
    }
}
```

Suggestions appear as the user types. Recent searches optional via
`searchSuggestions(.recent)`.

---

## Pull-to-Refresh

```swift
List { ... }
  .refreshable {
    await refresh()
  }
```

Default circular indicator. iOS 17+ supports a customizable inline indicator with
`.refreshIndicator()`.

---

## Haptics

Use haptics to confirm important actions. Don't overuse — every interaction having
haptic feedback becomes noise.

```swift
let haptic = UIImpactFeedbackGenerator(style: .light)
haptic.impactOccurred()
```

Styles:
- `.light` — subtle tap (toggle on)
- `.medium` — standard (button press)
- `.heavy` — significant action (delete confirmation)
- `.soft` / `.rigid` — newer subtle variants
- `.notification(.success / .warning / .error)` — semantic patterns

### When to use haptics

- Successful submit / save (success notification)
- Toggle on/off (light impact)
- Long-press menu open (medium impact)
- Drag start / drag end (selection feedback)
- Refresh complete (light impact)
- Error / validation fail (error notification)

### When NOT to use haptics

- Every button press (annoying)
- Page navigation (excessive)
- Routine UI state changes

---

## Color and Status

Don't hardcode colors. Use system semantic colors:

```swift
// Backgrounds
Color(.systemBackground)
Color(.secondarySystemBackground)

// Text
.foregroundStyle(.primary)
.foregroundStyle(.secondary)
.foregroundStyle(.tertiary)

// Status
.foregroundStyle(.green)     // success → systemGreen
.foregroundStyle(.red)       // error → systemRed
.foregroundStyle(.orange)    // warning → systemOrange
.foregroundStyle(.blue)      // info → systemBlue
```

These adapt to light/dark mode automatically. Hardcoded hex won't.

---

## The 12 iOS Mobile Rules

**1. Use Dynamic Type, never hardcode font sizes.** `Text("...").font(.body)` not
`.font(.system(size: 17))`.

**2. 44pt minimum tap targets.** Apple HIG. Period.

**3. Concentric radii.** Child radius = parent radius - padding.

**4. Use system colors, not custom hex.** They adapt to dark mode, accessibility
settings, and tinting.

**5. Sheets, not centered dialogs.** Modals on iOS are bottom sheets with detents.

**6. Tab bar minimize on scroll** is the iOS 26 default. Opt out only with reason.

**7. Liquid Glass for chrome that overlays content** (tab bars, sidebars, search,
mini player). Solid surfaces for content cards.

**8. Standard system controls** wherever possible. Don't reinvent toggles, sliders,
pickers — Apple's are polished, accessible, and familiar.

**9. NavigationStack** over NavigationView. Use type-safe routing with
`navigationDestination(for:)`.

**10. Form for settings-style screens.** Sections, footers explain context.

**11. Haptics intentionally**, not on every interaction.

**12. Test on real device + dark mode + Dynamic Type largest + Reduce Motion.**
This catches everything that breaks the layout.

---

## Flutter Cupertino (when targeting iOS via Flutter)

If building cross-platform with Flutter and targeting iOS users:

```dart
CupertinoApp(
  theme: CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
    brightness: Brightness.light,
  ),
  home: CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      middle: Text('Home'),
    ),
    child: CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          title: Text('Item'),
          trailing: CupertinoListTileChevron(),
        ),
      ],
    ),
  ),
)
```

Use Cupertino widgets:
- `CupertinoPageScaffold`
- `CupertinoNavigationBar`
- `CupertinoTabScaffold` / `CupertinoTabBar`
- `CupertinoListSection` / `CupertinoListTile`
- `CupertinoButton`
- `CupertinoTextField`
- `CupertinoSwitch`, `CupertinoSlider`, `CupertinoPicker`
- `CupertinoSheetRoute` for modals
- `CupertinoActionSheet` for action sheets
- `CupertinoAlertDialog` for system-style alerts

Liquid Glass material in Flutter as of 2026 is approximated via
`BackdropFilter(filter: ImageFilter.blur(...))` — not pixel-identical to native.
For pixel-identical Liquid Glass, native SwiftUI is still the only option.

---

## Hard Bans for iOS Pack

- ❌ Hardcoded font sizes (breaks Dynamic Type).
- ❌ Hardcoded hex colors (breaks dark mode and accessibility tinting).
- ❌ Custom toggles / sliders / pickers when system ones suffice.
- ❌ Centered dialog modals (use sheets).
- ❌ Tap targets below 44pt.
- ❌ Glass on every surface (iOS 26 contextual; not decorative everywhere).
- ❌ Ignoring concentric radii (children with same radius as parent).
- ❌ Material 3 patterns on iOS apps (pills + shape-morphing on iOS feels wrong).
- ❌ Web-style toast notifications floating over content (use iOS-style banner
  notifications or status bar updates).
- ❌ Hamburger menus on iOS (use tab bar or sidebar split-view).
- ❌ Skipping VoiceOver labels on Image-only buttons.
- ❌ Animations that don't respect Reduce Motion accessibility setting.
