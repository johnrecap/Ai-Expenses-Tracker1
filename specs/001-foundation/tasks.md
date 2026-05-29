# Tasks: Foundation

**Input**: Design documents from `/specs/001-foundation/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/ui-contract.md`, `quickstart.md`

**Project Type**: UI-only Flutter prototype

## Mandatory First Read And Skill Gate

Skills used for task generation: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`, `flutter-setup-localization`.

## Non-Negotiable Rules

- UI only: no backend, Firebase, real auth, database, API calls, OCR, AI calls, payment SDKs, notification APIs, or persistence.
- No WebView and no HTML rendering.
- Use native Flutter widgets.
- Use static in-memory mock data.
- Reuse shared components and theme tokens.
- Responsive for 360x800, 375x812, and 390x844.
- Arabic RTL and English LTR ready.

## Phase 1: Setup And Guardrails

- [ ] T001 [Scaffold] Create or confirm Flutter project structure in `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, and `test/`
  - Why: Later UI work needs a real compile target.
  - Expected result: The app launches to a native placeholder screen.
  - Inputs: `specs/001-foundation/plan.md`, `AGENTS.md`.
  - Implementation notes: Keep `stitch_ai_expenses_tracker_pro/` unchanged and do not add backend folders.
  - Possible bugs: Project created in a nested folder; generated files overwrite specs or exports.
  - Fix strategy: Move Flutter files to the workspace root and restore untouched source reference folders.
  - Verification: `flutter pub get` succeeds from the workspace root.

- [ ] T002 [Guardrails] Add Flutter lints and source-level UI-only guardrails in `analysis_options.yaml` and `AGENTS.md` references
  - Why: Workers need fast feedback before adding code that violates scope.
  - Expected result: Standard Flutter lints run and project rules remain visible.
  - Inputs: `.specify/memory/constitution.md`, `AGENTS.md`.
  - Implementation notes: Use Flutter lint defaults; do not add backend-oriented dependency rules that require unavailable tooling.
  - Possible bugs: Analyzer include path wrong; generated files fail strict rules.
  - Fix strategy: Use `include: package:flutter_lints/flutter.yaml` and keep custom rules minimal.
  - Verification: `flutter analyze` passes on placeholder app.

## Phase 2: Foundation

- [ ] T003 [Theme] Create token files under `lib/core/theme/`
  - Why: Shared tokens prevent raw color and spacing drift across screens.
  - Expected result: `AppColors`, `AppGradients`, `AppRadii`, `AppSpacing`, `AppShadows`, `AppTextStyles`, and `AppTheme` compile.
  - Inputs: `specs/design-system.md`, `stitch_ai_expenses_tracker_pro/lumina_finance/DESIGN.md`.
  - Implementation notes: Normalize letter spacing to `0`; prepare Arabic font fallback.
  - Possible bugs: Raw hex values spread into feature files; Arabic line height is clipped.
  - Fix strategy: Search `lib/` for raw hex values and adjust shared text styles.
  - Verification: Theme widget test renders English and Arabic text.

- [ ] T004 [Layout] Create responsive and directionality helpers under `lib/core/layout/`
  - Why: Required mobile sizes and RTL must be handled consistently.
  - Expected result: Helpers define mobile constraints, safe padding, bottom nav padding, and direction-aware values.
  - Inputs: `specs/design-system.md`.
  - Implementation notes: Prefer `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextAlign.start`, and safe-area-aware layout.
  - Possible bugs: Hardcoded left/right values; bottom nav covers content; directional icons do not mirror.
  - Fix strategy: Replace non-directional APIs and add LTR/RTL tests around shell widgets.
  - Verification: Widget tests render at 360, 375, and 390 widths in LTR and RTL.

- [ ] T005 [Widgets] Create shared primitives in `lib/core/widgets/`
  - Why: Screens must compose shared components instead of duplicating Tailwind structures.
  - Expected result: Background, glass card, bottom sheet, buttons, icon button, top bar, bottom nav, search, chips, section header, metric, progress, AI insight, and empty state widgets exist.
  - Inputs: `specs/component-map.md`, repeated Stitch HTML classes.
  - Implementation notes: Components accept data/children/variants; avoid screen-specific labels.
  - Possible bugs: Nested cards, unbounded blur filters, resizing buttons, or hardcoded screen copy.
  - Fix strategy: Add stable constraints, clip blur surfaces, and split variants through parameters.
  - Verification: Component smoke test renders all primitives without overflow.

- [ ] T006 [Mock] Create static mock models and data in `lib/core/mock/mock_models.dart` and `lib/core/mock/mock_data.dart`
  - Why: Lists and cards must be data-driven while staying backend-free.
  - Expected result: Static mock user, expenses, categories, wallets, budgets, goals, subscriptions, reports, AI insights, and chat messages exist.
  - Inputs: `specs/001-foundation/data-model.md`, visible values from Stitch exports.
  - Implementation notes: Use immutable classes or records; no repositories, async loaders, storage, or HTTP clients.
  - Possible bugs: Mock IDs do not match routes; models imply persistence; values inconsistent across screens.
  - Fix strategy: Prefix concepts with `Mock`, centralize IDs, and add lookup tests.
  - Verification: Unit test confirms required mock collections are non-empty and IDs resolve.

- [ ] T007 [Routes] Create central routes in `lib/app/routes.dart` and `lib/app/router.dart`
  - Why: Later features need stable route names and modal paths.
  - Expected result: Every route in `specs/ui-only-flutter-prototype.md` resolves to a placeholder.
  - Inputs: Route list in `specs/ui-only-flutter-prototype.md`, `contracts/ui-contract.md`.
  - Implementation notes: Modal paths may render placeholder widgets until their feature batch.
  - Possible bugs: Route strings drift; unknown route crashes; dynamic IDs fail.
  - Fix strategy: Add route tests for static paths, dynamic IDs, and `/not-found`.
  - Verification: `flutter test` route smoke tests pass.

- [ ] T008 [Assets] Register local assets under `assets/images/` and `pubspec.yaml`
  - Why: Runtime UI must not use remote images from exported HTML.
  - Expected result: Logo/avatar placeholders are local and load in tests.
  - Inputs: `stitch_ai_expenses_tracker_pro/ai_expenses_tracker_logo/screen.png`.
  - Implementation notes: Configure FlutterGen only after the Flutter project exists.
  - Possible bugs: Asset path typo; `pubspec.yaml` indentation error; FlutterGen not in PATH.
  - Fix strategy: Run `flutter pub get`, verify asset paths, and use `dart pub global run flutter_gen:flutter_gen_command -v` if needed.
  - Verification: Widget test loads logo without asset exception.

## Final Phase: Foundation Verification

- [ ] T009 [Tests] Add foundation tests under `test/core/` and `test/app/`
  - Why: Foundation regressions block all future screen batches.
  - Expected result: Tests cover theme rendering, widget smoke, directionality, mock data, and routes.
  - Inputs: `contracts/ui-contract.md`, `quickstart.md`.
  - Implementation notes: Exercise LTR and RTL and the required widths.
  - Possible bugs: Tests depend on animation timing; viewport sizes not applied correctly.
  - Fix strategy: Disable unnecessary animations in tests and set explicit test surface sizes.
  - Verification: `flutter test` passes.

- [ ] T010 [Polish] Run foundation compile and forbidden dependency gates
  - Why: Ensures no forbidden architecture entered before feature screens.
  - Expected result: Compile commands pass or exact environment blockers are documented; forbidden search has no implementation hits.
  - Inputs: Completed foundation files.
  - Implementation notes: Inspect every forbidden search hit and distinguish docs from implementation.
  - Possible bugs: Android tooling missing; false positives in comments; package names in specs.
  - Fix strategy: Run `flutter build web` if Android build is unavailable and remove implementation violations.
  - Verification: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, and forbidden dependency search.

## Dependencies And Execution Order

T001 blocks all tasks. T002-T004 can proceed after T001. T005-T008 depend on T003/T004. T009 depends on T005-T008. T010 is final.

## Acceptance Criteria

- Placeholder Flutter app compiles.
- Shared components render in widget tests.
- No Stitch screen is implemented yet.
- No backend, WebView, API, auth, database, or persistence dependency exists.
- Required viewport and directionality smoke tests pass.
