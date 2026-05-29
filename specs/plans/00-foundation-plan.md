# Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the Flutter UI-only foundation that all Stitch screen rebuilds depend on.

**Architecture:** Build a feature-first Flutter app with shared theme tokens,
layout helpers, reusable widgets, central routes, local assets, and static mock
data. No exported screen is implemented in this plan.

**Tech Stack:** Flutter 3.44.0, Dart 3.12.0, Material widgets, optional
`go_router`, optional `intl`, FlutterGen for assets if configured.

---

## Why

This plan removes the highest execution risk: duplicated UI and inconsistent
layout decisions. The Stitch exports repeat glass cards, gradient buttons, top
bars, bottom nav, chips, metric cards, and RTL-sensitive layouts. Those must be
centralized before screen work starts.

## Expected Result

- A compiling Flutter placeholder app.
- Shared design tokens in `lib/core/theme/`.
- Responsive and RTL helpers in `lib/core/layout/`.
- Reusable visual primitives in `lib/core/widgets/`.
- Static mock models and lists in `lib/core/mock/`.
- Central route registry in `lib/app/`.
- Local asset setup in `assets/images/`.
- Smoke tests proving theme, routing, and directionality basics.

## Source References

- `AGENTS.md`
- `specs/ui-only-flutter-prototype.md`
- `specs/design-system.md`
- `specs/component-map.md`
- `specs/screens-inventory.md`
- `stitch_ai_expenses_tracker_pro/lumina_finance/DESIGN.md`
- `stitch_ai_expenses_tracker_pro/ai_expenses_tracker_logo/screen.png`

## Files And Ownership

- Create/modify: `pubspec.yaml`
- Create/modify: `analysis_options.yaml`
- Create: `lib/main.dart`
- Create: `lib/app/app.dart`
- Create: `lib/app/routes.dart`
- Create: `lib/app/router.dart`
- Create: `lib/core/theme/*.dart`
- Create: `lib/core/layout/*.dart`
- Create: `lib/core/widgets/*.dart`
- Create: `lib/core/mock/*.dart`
- Create: `assets/images/`
- Create: `test/core/*_test.dart`

## Tasks

- [ ] T001 [Scaffold] Create the Flutter project baseline in `lib/`, `test/`, `pubspec.yaml`, and `analysis_options.yaml`.
  - Why: All later plans need a compile target before UI code is added.
  - Expected result: The app launches to a plain placeholder route.
  - Inputs: `AGENTS.md`, `specs/ui-only-flutter-prototype.md`.
  - Implementation notes: Keep Stitch exports and specs untouched; do not create backend/API folders.
  - Possible bugs: Flutter project generated in a nested folder, or platform files overwrite planning docs.
  - Fix strategy: Move Flutter files back to the workspace root and re-run `flutter pub get`.
  - Verification: `flutter pub get`, `flutter analyze`, and `flutter test` pass.

- [ ] T002 [Theme] Create app tokens in `lib/core/theme/`.
  - Why: Screen rebuilds need one source for colors, gradients, radii, spacing, shadows, and typography.
  - Expected result: `AppColors`, `AppGradients`, `AppRadii`, `AppSpacing`, `AppShadows`, `AppTextStyles`, and `AppTheme` compile.
  - Inputs: `specs/design-system.md`, `stitch_ai_expenses_tracker_pro/lumina_finance/DESIGN.md`.
  - Implementation notes: Normalize letter spacing to `0`; support Inter and IBM Plex Sans Arabic fallbacks.
  - Possible bugs: raw hex values spread into feature screens, or Arabic line height looks compressed.
  - Fix strategy: Search `lib/` for raw hex values and move them into tokens; adjust shared text styles.
  - Verification: Theme widget test renders English and Arabic sample text.

- [ ] T003 [Layout] Add responsive and directionality helpers in `lib/core/layout/`.
  - Why: Required mobile sizes and RTL must be handled consistently.
  - Expected result: helpers for max width, safe padding, bottom nav padding, and directional values exist.
  - Inputs: responsive rules in `specs/design-system.md`.
  - Implementation notes: Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextAlign.start`, and safe-area aware spacing.
  - Possible bugs: left/right padding hardcoded, directional icons not mirrored, bottom nav covering content.
  - Fix strategy: Replace non-directional APIs and add LTR/RTL tests around shell widgets.
  - Verification: Widget tests run at 360, 375, and 390 widths in LTR and RTL.

- [ ] T004 [Widgets] Create shared primitives in `lib/core/widgets/`.
  - Why: Shared widgets prevent each screen from copying Tailwind structure manually.
  - Expected result: `AppBackground`, `GlassCard`, `GlassBottomSheet`, `GradientButton`, `SecondaryPillButton`, `IconCircleButton`, `AppTopBar`, `AppBottomNav`, `SectionHeader`, `SearchField`, `FilterChipRow`, `MetricCard`, `ProgressBar`, `ProgressRing`, `AiInsightCard`, and `EmptyState` exist.
  - Inputs: `specs/component-map.md`, repeated classes in `code.html` exports.
  - Implementation notes: Widgets should accept data/children/variants, not hardcoded screen labels.
  - Possible bugs: nested cards, unbounded `BackdropFilter`, resizing buttons, or screen-specific shared APIs.
  - Fix strategy: Add fixed constraints for controls, clip blur surfaces, and split variants by parameter.
  - Verification: Component smoke test renders all primitives without overflow.

- [ ] T005 [Mock] Create static mock models and data in `lib/core/mock/`.
  - Why: Lists and repeated cards must render from mock arrays without backend behavior.
  - Expected result: models for user, expense, category, wallet, budget, goal, subscription, report, AI insight, and chat message exist with static sample lists.
  - Inputs: `specs/ui-only-flutter-prototype.md`, visible copy/values from Stitch exports.
  - Implementation notes: Use immutable Dart classes or records; no repositories, async loaders, storage, or HTTP clients.
  - Possible bugs: model names imply persistence, mock IDs do not match routes, values are inconsistent across screens.
  - Fix strategy: Prefix source files with mock concepts and add tests for route ID lookups.
  - Verification: Unit test verifies required mock collections are non-empty and IDs resolve.

- [ ] T006 [Routes] Create central routes in `lib/app/routes.dart` and `lib/app/router.dart`.
  - Why: All feature plans need stable routes and modal paths.
  - Expected result: Every route from `specs/ui-only-flutter-prototype.md` resolves to a placeholder or shell destination.
  - Inputs: route list in `specs/ui-only-flutter-prototype.md`.
  - Implementation notes: Modal routes can initially render placeholders; later plans replace placeholders with screens.
  - Possible bugs: route strings drift, unknown route crashes, dynamic IDs fail.
  - Fix strategy: Add route tests for static and dynamic paths, including `/not-found`.
  - Verification: Route smoke tests pass.

- [ ] T007 [Assets] Configure local assets and optional FlutterGen.
  - Why: Runtime UI must not use remote images embedded in Stitch HTML.
  - Expected result: logo/avatar placeholders are local assets and load in tests.
  - Inputs: `stitch_ai_expenses_tracker_pro/ai_expenses_tracker_logo/screen.png`.
  - Implementation notes: Register assets in `pubspec.yaml`; use FlutterGen after the Flutter project exists.
  - Possible bugs: asset path typo, missing `pubspec.yaml` entry, FlutterGen command not on current shell PATH.
  - Fix strategy: run `flutter pub get`, verify asset path, run `dart pub global run flutter_gen:flutter_gen_command -v` if needed.
  - Verification: Widget test loads logo without asset exception.

## Possible Bugs And Fix Strategy

- Layout overflow: replace fixed widths with constraints, `Expanded`, or scroll views.
- RTL drift: replace left/right APIs with directional APIs and add RTL tests.
- Duplicate UI: move repeated patterns to `lib/core/widgets/`.
- Accidental backend package: remove the dependency and replace with static mock data.
- Asset failures: verify `pubspec.yaml`, run `flutter pub get`, and test asset loading.

## Verification

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

If Android tooling is unavailable:

```powershell
flutter build web
```

Forbidden dependency search:

```powershell
rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api" lib pubspec.yaml test
```

## Acceptance Criteria

- Placeholder app compiles.
- Shared components render in widget tests.
- No screen from Stitch is implemented yet.
- No backend/WebView/API/persistence dependency exists.
- Required viewport and directionality smoke tests pass.

## Stop Condition

Do not start Plan 01 until foundation compile, route, theme, asset, and mock
data tests pass.
