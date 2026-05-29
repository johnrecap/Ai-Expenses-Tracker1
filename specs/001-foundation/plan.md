# UI-Only Flutter Implementation Plan: Foundation

**Branch**: `001-foundation` | **Date**: 2026-05-28 | **Spec**: `specs/001-foundation/spec.md`

**Input**: Feature specification from `/specs/001-foundation/spec.md`

## Mandatory First Read And Skill Gate

- `AGENTS.md` read.
- `.specify/memory/constitution.md` read.
- `.agents/workflows/development.md` read.
- `.agents/skill-matcher.json` read.
- Relevant skills searched and loaded.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`, `flutter-setup-localization`.

## Summary

Create the Flutter project baseline, shared theme, responsive layout helpers, reusable UI primitives, central routes, local asset registration, mock data, and tests. No exported Stitch screen is implemented in this batch.

## Why

The project has many repeated glass cards, metric cards, filters, forms, bottom sheets, lists, progress visuals, and RTL-sensitive layouts. A shared foundation prevents duplicated UI and makes later batches compile-checkable.

## Expected Result

- Placeholder Flutter app in the workspace root.
- `lib/app/` route registry and app shell placeholders.
- `lib/core/theme/`, `lib/core/layout/`, `lib/core/widgets/`, and `lib/core/mock/`.
- Local assets under `assets/images/`.
- Widget and route smoke tests.
- No backend, WebView, HTML renderer, persistence, or API dependency.

## Source References

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `specs/ui-only-flutter-prototype.md`
- `specs/screens-inventory.md`
- `specs/design-system.md`
- `specs/component-map.md`
- `stitch_ai_expenses_tracker_pro/lumina_finance/DESIGN.md`
- `stitch_ai_expenses_tracker_pro/ai_expenses_tracker_logo/screen.png`

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**: Flutter SDK, Material widgets, optional `go_router`, optional `intl`, optional FlutterGen-generated assets

**Storage**: N/A. Static in-memory mock data only.

**Testing**: `flutter test`, widget tests for LTR/RTL and required viewports

**Target Platform**: Flutter mobile prototype verified at 360x800, 375x812, and 390x844

**Project Type**: UI-only Flutter mobile app prototype

**Performance Goals**: Smooth scrolling, stable controls, restrained blur/glass effects

**Constraints**: Native Flutter widgets only, no WebView, no backend, no remote runtime assets, Arabic RTL and English LTR ready

**Scale/Scope**: Foundation for all detected Stitch export screens

## Constitution Check

- `AGENTS.md` and constitution read: PASS
- Skills searched and listed: PASS
- UI-only scope preserved: PASS
- No WebView or HTML rendering planned: PASS
- Native Flutter widgets planned: PASS
- Shared components and design tokens before screens: PASS
- Static in-memory mock data only: PASS
- Responsive checks include 360x800, 375x812, 390x844: PASS
- Arabic RTL and English LTR checks planned: PASS
- Compile checks listed: PASS

## Project Structure

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    routes.dart
  core/
    layout/
    theme/
    widgets/
    mock/
test/
assets/images/
pubspec.yaml
analysis_options.yaml
```

**Structure Decision**: Use feature-first Flutter architecture with no backend, API, repository, database, auth, or service folders.

## Reuse Strategy

Create shared tokens and widgets before any feature screen:

- Theme: `AppColors`, `AppGradients`, `AppRadii`, `AppSpacing`, `AppShadows`, `AppTextStyles`, `AppTheme`
- Layout: breakpoints, safe padding, content constraints, directionality helpers
- Widgets: `AppBackground`, `GlassCard`, `GlassBottomSheet`, `GradientButton`, `SecondaryPillButton`, `IconCircleButton`, `AppTopBar`, `AppBottomNav`, `SearchField`, `FilterChipRow`, `MetricCard`, `ProgressBar`, `ProgressRing`, `AiInsightCard`, `EmptyState`

## Mock Data Strategy

Create simple immutable model classes and static lists for user, expenses, categories, wallets, budgets, goals, subscriptions, reports, AI insights, and chat messages. Use IDs that match planned route parameters. Do not create repositories, services, async loaders, or persistence.

## Possible Bugs And Fix Strategy

- Flutter scaffold created in a nested folder: move project files to root and keep Stitch exports unchanged.
- Raw colors leak into feature screens: search `lib/` for hex values and move to theme tokens.
- RTL drift: replace `EdgeInsets`/`Alignment` with directional variants and add RTL widget tests.
- Asset failures: verify `pubspec.yaml`, run `flutter pub get`, and test image loading.
- Forbidden dependencies: remove packages/imports and replace behavior with static mock data.
- Bottom nav overlap in later screens: foundation shell must expose safe bottom content padding.

## Verification Plan

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

Viewport checks:

```text
360x800 LTR
360x800 RTL
375x812 LTR
375x812 RTL
390x844 LTR
390x844 RTL
```

## Phase 0: Research

Completed in `research.md`.

## Phase 1: Design

Completed in `data-model.md`, `contracts/ui-contract.md`, `quickstart.md`, and `tasks.md`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
