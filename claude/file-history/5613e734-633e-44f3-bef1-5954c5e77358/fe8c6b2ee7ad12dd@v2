---
name: project-overview
description: "Flutter app for UK checkpoints navigation — stack, architecture, HERE SDK version, theme system, navigation feature status"
metadata: 
  node_type: memory
  type: project
  originSessionId: 06be46da-1045-4a93-ac26-083098ba1497
---

Flutter iOS/Android app. **NOT Expo/RN**.

**Why:** Building a UK checkpoints navigation app for a PeoplePerHour client.

**Stack:**
- Flutter (Dart SDK ^3.7.2) + Material 3 / useMaterial3: true
- `here_sdk` v4.25.5 Navigation tier — local docs at `here-sdk_doc_local/`
  - Always grep local docs before calling any HERE API
  - License covers Navigation tier (RoutingEngine, VisualNavigator, etc.)
- Riverpod v2.6 (riverpod_annotation + riverpod_generator)
- go_router v17
- Dio + ukcheckpoints_api (local package at `packages/ukcheckpoints_api`)
- Sentry (error tracking + performance)
- Fonts: Inter (UI body), Poppins (display/headlines) — both in pubspec

**Architecture:** Feature-first
- `lib/core/` — theme, router, providers, utils, widgets
- `lib/features/auth/` — login, signup, forgot password, splash
- `lib/features/checkpoints/` — checkpoint list, cards, filter, nearby popup
- `lib/features/map/` — HERE map screen, search bar, bottom sheet, overlays
- `lib/features/navigation/` — nav.md + todo.md (in-progress)
- `lib/features/profile/` — profile, settings, contribution graph
- `lib/features/billing/` — pricing screen
- `lib/features/home/` — MainWrapper (IndexedStack + NavigationBar)

**State management:** Riverpod with `@riverpod` codegen. Pattern:
`screen → controller → repository → data source`

**Theme system:** `lib/core/theme/theme.dart`
- `ThemeColors`, `ThemeRadius`, `ThemeShadows`, `ThemeMotion`, `ThemeText`, `ThemeFonts`, `ThemeSpacing`
- M3 Expressive shape + color scheme (fixed brand blue, no dynamic Material You)
- Motion: `ThemeMotion.medium` + `ThemeMotion.smooth` used for sheet animations

**HERE SDK rule:** Never guess API names. Grep `here-sdk_doc_local/` first.

---

## Navigation feature — DONE (todo.md checked)

All foundation, search/sheet, routing/trip overview, and checkpoint tasks are done:
- UK formatter, strings dict, route options, NavigationPhase sealed state, sheet state, persistent keepAlive providers
- Peek/full-search/trip-overview sheets with state retention; autosuggest 250ms debounce; map-tap peeks without discarding text; interaction lock
- Route calculation, map polyline + markers, trip overview sheet, maneuver preview
- 49 maneuver icons + mapping (`maneuvers/maneuver_icons.dart`), async route-checkpoint filter + section, tap→focus
- `startDrive()` in `nav_state_provider.dart`: startRendering, set route, DynamicCameraBehavior, clear preview, peek → ActiveDrive state
- Camera ownership enum (CameraOwnership.following/free) + onPan()/recenter() on notifier — logic complete

---

## Navigation feature — MISSING (todo.md unchecked)

### Active Drive UI (immediate priority)
1. **RouteProgress provider** — `onProgress` in nav_state_provider.dart is a no-op. Need a provider/state exposing `RouteProgress?` to HUD widgets (remaining distance, remaining duration, maneuvers).
2. **Pan gesture listener** — `map_screen.dart` must wire `mapView.gestures` pan listener (`GestureState.begin`) to call `navStateNotifier.onPan()`. Without this, camera-free loop never fires.
3. **Nav drive peek header** — `peek_content.dart` falls through to `_SearchPeek` during `ActiveDrive`. Need a dedicated widget: maneuver icon + instruction text + distance, large/high-contrast. Replaces the search pill while driving.
4. **Secondary turn** — shown only when next maneuver ≤ 500 yards, else hidden.
5. **Nav drive card** — Peek-mode bottom strip during drive: ETA, remaining distance, remaining duration (all from RouteProgress), End trip button, Recenter button.
6. **Progress bar** — `traveledDistance / totalRouteDistance` from RouteProgress (never time). Checkpoint dots colored by status (skip `unknown`). Animate to "done" as user passes.
7. **Recenter button** — appears when `CameraOwnership.free`; tapping calls `recenter()`. Auto-recenter after ~10s idle (debounced Timer in notifier).

### Edge cases
8. **Reroute** — `onDeviation` sets `isRerouting=true` but never calls routing engine. Must re-call `calculateRoute` (current GPS origin + original dest + same vehicle options), then `nav.route = newRoute`.
9. **Arrival UI** — `onArrival` goes straight to `Idle`; no "You've arrived" screen. Need `Arrived` navigation phase (or short state) + widget showing dest name/address, then settle to peek.
10. **GPS loss** — No location quality listener wired. Subscribe to HERE positioning quality; show "Searching for GPS…" banner, grey speed overlay, hold last position, silent recovery.

### Custom vehicles (SQLite) — not started
`models/vehicle.dart`, SQLite table + migration, `services/vehicle_repository.dart`, `routing/vehicle_mapper.dart` (Vehicle → HERE options + VehicleProfile), `providers/vehicle_provider.dart`, Add-vehicle form, trip-overview vehicle selector, start-drive sets trackingTransportProfile.

---

## Key files for active-drive work
- `lib/features/navigation/providers/nav_state_provider.dart` — NavStateNotifier, VisualNavigator lifecycle
- `lib/features/map/screens/map_screen.dart` — HereMap, needs pan gesture listener for nav
- `lib/features/map/controllers/map_controller.dart` — HereMapController wrapper
- `lib/features/map/widgets/map_bottom_sheet.dart` — DraggableScrollableSheet snap logic
- `lib/features/navigation/sheets/peek_content.dart` — needs ActiveDrive arm (nav header)
- `lib/features/navigation/sheets/guidance_full_content.dart` — full-sheet view during drive
- `lib/features/navigation/maneuvers/maneuver_icons.dart` — ManeuverAction → asset path

## Plan docs
- `lib/features/navigation/Navigation.md` — full design spec (§8 = active drive, §9 = edge cases)
- `lib/features/navigation/todo.md` — executable task list
