# Implementation Tasks

## How To Read This Plan

This task plan is intentionally explicit. Each batch explains why it exists, the
expected result, exact work areas, likely bugs, repair steps, and verification.
Workers should not infer backend behavior, persistence, auth, AI calls, OCR, or
HTML rendering from the Stitch exports.

## Required Task Card Format

Every future task added to this file must use this shape:

```text
- [ ] T000 [P?] [Area] Short action with exact file path
  - Why: Reason this action exists.
  - Expected result: Concrete outcome after completion.
  - Inputs: Source references needed before editing.
  - Implementation notes: Constraints and component reuse requirements.
  - Possible bugs: Likely failure modes.
  - Fix strategy: How to diagnose and fix those failures.
  - Verification: Command, widget test, or visual check that proves it works.
```

Rules:

- `[P]` means the task can run in parallel because it touches different files
  and has no dependency on incomplete work.
- Use native Flutter widgets only.
- Do not use WebView, HTML renderers, remote images, backend services, Firebase,
  auth SDKs, databases, HTTP clients, OCR SDKs, or AI APIs.
- Keep all mock data static and in-memory.
- Reuse components from `lib/core/widgets/` and theme tokens from
  `lib/core/theme/`.
- Validate 360x800, 375x812, and 390x844 in English LTR and Arabic RTL.

## Global Debug Playbook

Use this playbook before inventing fixes:

- Render overflow: inspect constraints, replace fixed widths with
  `Expanded`, `Flexible`, `ConstrainedBox`, `SingleChildScrollView`, or
  horizontal chip scrolling.
- Wrong RTL layout: replace `EdgeInsets`, `Alignment`, and `Positioned` with
  directional equivalents, then test with `Directionality(textDirection:
  TextDirection.rtl)`.
- Duplicated UI: move repeated cards, rows, buttons, chips, top bars, or bottom
  nav into `lib/core/widgets/`.
- Route mismatch: update `lib/app/routes.dart`, `lib/app/router.dart`, and route
  tests together.
- Missing assets: copy assets into `assets/images/`, update `pubspec.yaml`, run
  FlutterGen if configured, and replace remote URLs.
- Accidental backend dependency: remove the package/import, replace behavior
  with static mock data or local widget state.
- Visual drift from Stitch: compare against `screen.png`, then adjust tokens or
  shared component parameters instead of patching one screen locally.

## Batch 0: Project Scaffold And Guardrails

Goal: create the Flutter project shape without implementing exported screens.

Why: every later UI batch depends on a clean Flutter app, lints, guardrails, and
compile commands. This prevents implementation from starting with ad hoc files
or hidden backend dependencies.

Expected result: a compiling placeholder Flutter app with the planned folder
structure, documented UI-only rules, and no rendered Stitch screens yet.

Work areas:

- `pubspec.yaml`
- `analysis_options.yaml`
- `lib/main.dart`
- `lib/app/app.dart`
- `lib/app/routes.dart`
- `lib/app/router.dart`
- `test/`

Tasks:

- [ ] T001 [Scaffold] Create or confirm Flutter app structure in project root.
  - Why: implementation needs a real Flutter target for compile checks.
  - Expected result: `lib/`, `test/`, `pubspec.yaml`, and platform folders exist.
  - Inputs: `specs/ui-only-flutter-prototype.md`, `AGENTS.md`.
  - Implementation notes: use the current workspace root; do not overwrite
    Stitch exports.
  - Possible bugs: Flutter project created in a nested folder; generated files
    overwrite specs or exports.
  - Fix strategy: move only Flutter project files into the intended root, keep
    `stitch_ai_expenses_tracker_pro/` unchanged, and update paths in specs if
    needed.
  - Verification: `flutter pub get` runs from the workspace root.

- [ ] T002 [Guardrails] Add linting and UI-only documentation.
  - Why: the project must fail early on sloppy Dart and must document forbidden
    backend/WebView choices.
  - Expected result: lints are active and the UI-only contract is visible to
    every worker.
  - Inputs: `AGENTS.md`, this file.
  - Implementation notes: use `flutter_lints`; do not add backend-oriented
    rules or packages.
  - Possible bugs: lints too strict for generated files; missing include path.
  - Fix strategy: use Flutter's standard `include: package:flutter_lints/flutter.yaml`
    and keep custom rules minimal.
  - Verification: `flutter analyze` passes on the placeholder app.

- [ ] T003 [Routes] Add placeholder route registry and not-found route.
  - Why: screens need stable route names before implementation starts.
  - Expected result: central route constants exist and the app shows a
    placeholder page.
  - Inputs: route list in `specs/ui-only-flutter-prototype.md`.
  - Implementation notes: route definitions only; no screen UI beyond a
    placeholder.
  - Possible bugs: route strings diverge from the spec; not-found route loops.
  - Fix strategy: compare route constants with the spec route block and add a
    smoke test for unknown routes.
  - Verification: `flutter test` includes a route smoke test.

Acceptance criteria:

- `flutter pub get` passes.
- `flutter analyze` passes.
- `flutter test` passes.
- The app launches to a placeholder page only.
- No WebView dependency exists.
- No backend or network dependency exists.

Stop condition: do not start design-system widgets until Batch 0 compiles.

## Batch 1: Design System And App Shell

Goal: implement the reusable visual foundation.

Why: the Stitch exports repeat the same glass cards, gradient buttons, top bars,
bottom nav, chips, spacing, and typography. Building these first prevents every
screen from becoming a one-off copy.

Expected result: a reusable native Flutter design system that can render
glassmorphism, gradients, navigation shell, responsive padding, and LTR/RTL
behavior.

Work areas:

- `lib/core/theme/`
- `lib/core/layout/`
- `lib/core/widgets/`
- `test/core/`

Tasks:

- [ ] T004 [Theme] Create color, gradient, radius, shadow, spacing, and text
  token files under `lib/core/theme/`.
  - Why: design tokens keep screens consistent and make visual fixes global.
  - Expected result: `AppColors`, `AppGradients`, `AppRadii`, `AppSpacing`,
    `AppShadows`, `AppTextStyles`, and `AppTheme` exist.
  - Inputs: `specs/design-system.md`,
    `stitch_ai_expenses_tracker_pro/lumina_finance/DESIGN.md`.
  - Implementation notes: normalize letter spacing to `0`; keep Arabic font
    fallback ready.
  - Possible bugs: colors copied with wrong casing, text line heights too tight,
    or one-off color literals appear in screens.
  - Fix strategy: search for raw hex values in `lib/`, move them into tokens,
    and adjust shared styles.
  - Verification: widget test renders sample text and cards without theme
    exceptions.

- [ ] T005 [Layout] Add responsive constraints and directionality helpers under
  `lib/core/layout/`.
  - Why: required viewports are narrow and Arabic RTL must be supported from the
    first UI batch.
  - Expected result: helpers centralize max width, mobile padding, safe-area
    spacing, and direction-aware values.
  - Inputs: responsive rules in `specs/design-system.md`.
  - Implementation notes: prefer `EdgeInsetsDirectional`, `AlignmentDirectional`,
    and `TextAlign.start`.
  - Possible bugs: hardcoded left/right padding, directional icons not mirrored,
    or content hidden behind bottom nav.
  - Fix strategy: replace non-directional layout APIs and add LTR/RTL widget
    tests for each shared shell component.
  - Verification: tests cover 360, 375, and 390 widths in LTR and RTL.

- [ ] T006 [P] [Widgets] Build shared primitives in `lib/core/widgets/`.
  - Why: top bars, bottom nav, cards, buttons, chips, and section headers recur
    across almost every screen.
  - Expected result: `AppBackground`, `GlassCard`, `GlassBottomSheet`,
    `GradientButton`, `AppTopBar`, `AppBottomNav`, `SectionHeader`,
    `SearchField`, and reusable chip/button primitives compile.
  - Inputs: `specs/component-map.md` and repeated HTML classes such as
    `glass-card`, `glass-panel`, `btn-primary`, and bottom nav markup.
  - Implementation notes: components must accept child widgets/data; avoid
    screen-specific copy or hardcoded labels.
  - Possible bugs: nested cards, unbounded blur filters, oversized nav labels,
    or buttons resizing on state changes.
  - Fix strategy: add stable heights, constraints, and small API variants
    instead of duplicating components.
  - Verification: component gallery/smoke test renders all primitives.

Acceptance criteria:

- Shared components compile and render in tests.
- No screen implements duplicated card/button/top-bar primitives.
- LTR and RTL smoke tests pass.
- Required compile checks pass.

Stop condition: no feature screen should be created until core tokens and shell
components are in place.

## Batch 2: Mock Data, Routes, Assets

Goal: make the prototype data-driven before building screens.

Why: lists, cards, reports, budgets, wallets, subscriptions, and AI messages
must come from mock models so UI remains reusable and backend-free.

Expected result: static models, mock data, route constants, local assets, and a
safe asset-generation path are ready.

Work areas:

- `lib/core/mock/mock_models.dart`
- `lib/core/mock/mock_data.dart`
- `lib/app/routes.dart`
- `lib/app/router.dart`
- `assets/images/`
- `pubspec.yaml`

Tasks:

- [ ] T007 [Mock] Add static model classes and mock data under
  `lib/core/mock/`.
  - Why: repeated UI should be generated from data, not hardcoded per card.
  - Expected result: mock users, expenses, categories, wallets, budgets, goals,
    subscriptions, reports, AI insights, and chat messages exist.
  - Inputs: `specs/ui-only-flutter-prototype.md`, visible values in Stitch HTML.
  - Implementation notes: simple immutable Dart classes are enough; avoid
    repositories, services, async loaders, or persistence.
  - Possible bugs: models imply remote storage, dates/currencies inconsistent,
    or mock IDs do not match routes.
  - Fix strategy: keep names prefixed with `Mock`, store data in const/static
    lists, and add route IDs that map to mock items.
  - Verification: unit test confirms key mock collections are non-empty and
    route IDs resolve.

- [ ] T008 [Routes] Implement central router for all planned routes.
  - Why: route stability lets batches proceed independently.
  - Expected result: every route in the spec resolves to a placeholder or built
    screen without crashing.
  - Inputs: route list in `specs/ui-only-flutter-prototype.md`.
  - Implementation notes: modal routes can initially render placeholder widgets;
    bottom sheets are wired in later batches.
  - Possible bugs: deep-link parameters missing, modal routes open full-screen
    unexpectedly, or unknown route crashes.
  - Fix strategy: add route tests for static paths, dynamic expense/report IDs,
    and `/not-found`.
  - Verification: `flutter test` route registry tests pass.

- [ ] T009 [Assets] Move usable local image assets into `assets/images/` and
  configure asset access.
  - Why: runtime must not depend on remote image URLs embedded in HTML exports.
  - Expected result: local logo/avatar placeholders are available to Flutter.
  - Inputs: `stitch_ai_expenses_tracker_pro/ai_expenses_tracker_logo/screen.png`
    and any approved local placeholders.
  - Implementation notes: use FlutterGen once asset paths are registered; keep
    screenshots as references unless explicitly used as temporary assets.
  - Possible bugs: asset not listed in `pubspec.yaml`, path typo, or global
    FlutterGen command unavailable in the current shell.
  - Fix strategy: run `flutter pub get`, then run
    `dart pub global run flutter_gen:flutter_gen_command -v` or use generated
    runner if configured.
  - Verification: widget test loads logo placeholder without asset exception.

Acceptance criteria:

- All repeated data can be rendered from mock arrays.
- No remote image URLs are used.
- Route names/paths match `specs/ui-only-flutter-prototype.md`.
- Required compile checks pass.

Stop condition: feature batches should not hardcode repeated lists after this
batch.

## Batch 3: Launch, Onboarding, Auth

Goal: implement the app entry flow.

Why: launch, onboarding, and visual auth establish first-run navigation, locale
direction, and the no-real-auth rule before core app screens are built.

Expected result: splash, onboarding, login, and sign-up screens render natively
and navigate locally without authentication.

Screens:

- `splash_loading`
- `onboarding_language_selection`
- `onboarding_base_currency`
- `onboarding_notifications`
- `login_authentication`
- `sign_up`

Work areas:

- `lib/features/onboarding/presentation/`
- `lib/features/auth/presentation/`
- `lib/app/router.dart`
- `test/features/onboarding/`
- `test/features/auth/`

Tasks:

- [ ] T010 [Entry] Build splash and onboarding screens from native widgets.
  - Why: these screens prove route flow, locale selection, and responsive
    onboarding cards.
  - Expected result: splash, language, currency, and notifications screens
    match Stitch composition closely.
  - Inputs: corresponding `screen.png` and `code.html` exports.
  - Implementation notes: selections update local widget/app state only; no
    persistence or permission API.
  - Possible bugs: Arabic text uses corrupted mojibake from HTML, option cards
    overflow, or notification screen asks real permissions.
  - Fix strategy: rewrite Arabic strings manually, use scrollable content, and
    replace permission behavior with local mock toggles.
  - Verification: visual tests/smoke tests at 360x800, 375x812, 390x844 in LTR
    and RTL.

- [ ] T011 [Auth] Build login and sign-up visual forms.
  - Why: auth screens are part of the prototype but must not perform real auth.
  - Expected result: login/sign-up forms, logo block, glass panel, and local
    navigation render correctly.
  - Inputs: `login_authentication`, `sign_up`, logo asset.
  - Implementation notes: form buttons navigate or show local snackbars only.
  - Possible bugs: adding auth package, form validation blocking demo flow,
    keyboard causing overflow, or remote Google/avatar image usage.
  - Fix strategy: remove auth dependencies/imports, use `SingleChildScrollView`,
    local placeholders, and visual-only validation copy.
  - Verification: forbidden dependency search has no auth/Firebase/API hits in
    `lib`, `pubspec.yaml`, or `test`.

Acceptance criteria:

- Screens match Stitch composition closely at 360x800, 375x812, 390x844.
- Login/sign-up do not call auth services.
- Onboarding selections use ephemeral state only.
- LTR and RTL layouts do not overflow.
- Required compile checks pass.

Stop condition: entry flow must compile and stay UI-only before implementing
main tabs.

## Batch 4: Main Expenses Flow

Goal: implement the primary user loop.

Why: dashboard, transactions, filters, and add/edit expense are the core app
experience. This batch validates lists, bottom nav, bottom sheets, forms, and
mock-only interactions.

Expected result: the user can navigate through dashboard, expenses, filter
sheet, add modes, and edit expense with static data and local UI state only.

Screens:

- `home_dashboard`
- `expenses_list`
- `expense_filters_bottom_sheet`
- `add_expense_quick_mode`
- `add_expense_ai_text_mode`
- `add_expense_receipt_mode`
- `edit_expense`

Work areas:

- `lib/features/dashboard/presentation/`
- `lib/features/expenses/presentation/`
- `lib/core/widgets/transaction_tile.dart`
- `lib/core/widgets/filter_chip_row.dart`
- `test/features/expenses/`

Tasks:

- [ ] T012 [Dashboard] Build home dashboard with shared metrics,
  transactions, AI insight, and bottom nav.
  - Why: dashboard combines most shared components in one screen.
  - Expected result: greeting, balance/summary cards, insight card, transaction
    preview, and nav render from mock data.
  - Inputs: `home_dashboard/screen.png`, `home_dashboard/code.html`, mock data.
  - Implementation notes: use `MetricCard`, `AiInsightCard`,
    `TransactionTile`, and `AppBottomNav`.
  - Possible bugs: currency text overflows, bottom nav covers last card, or
    duplicated transaction UI appears.
  - Fix strategy: constrain currency text, add bottom padding equal to nav
    height, and move repeated rows to shared widgets.
  - Verification: dashboard widget tests pass for required viewport sizes.

- [ ] T013 [Expenses] Build expenses list and filters bottom sheet.
  - Why: transaction list is a repeated high-density layout and filters are the
    first modal surface.
  - Expected result: search bar, horizontal chips, grouped transactions, and
    filter sheet render without persistence.
  - Inputs: `expenses_list`, `expense_filters_bottom_sheet`.
  - Implementation notes: filter controls are local state only; sheet content
    must scroll.
  - Possible bugs: chip row clips, sheet exceeds height, range slider state
    persists globally, or search implies real querying.
  - Fix strategy: wrap chips in horizontal `ListView`, cap sheet height, keep
    filter values in the sheet widget, and filter only mock arrays if needed.
  - Verification: tests open and close the sheet and check no overflow.

- [ ] T014 [AddExpense] Build quick, AI text, receipt, and edit expense flows.
  - Why: these screens prove segmented controls, forms, mocked AI parsing, and
    receipt upload placeholders.
  - Expected result: all add/edit expense modes render and save/parse/upload
    actions are visual only.
  - Inputs: `add_expense_quick_mode`, `add_expense_ai_text_mode`,
    `add_expense_receipt_mode`, `edit_expense`.
  - Implementation notes: no camera, OCR, speech, AI API, or file picker. Use
    local state and placeholder panels.
  - Possible bugs: accidental camera/OCR package, segmented tabs lose state,
    keyboard overflow, or edit form mutates shared mock data.
  - Fix strategy: remove prohibited packages, keep mode state local, wrap forms
    in scroll views, and copy mock values into local controllers.
  - Verification: forbidden dependency search plus form smoke tests.

Acceptance criteria:

- No camera, OCR, AI, or network integration exists.
- Filter controls do not persist beyond local state.
- Bottom nav does not cover content.
- Amount text and transaction rows do not overflow at 360px width.
- Required compile checks pass.

Stop condition: main expense flow must be stable before report/budget screens
reuse its transaction and chart components.

## Batch 5: Reports, Budgets, Goals, Wallets, Subscriptions

Goal: implement the planning and account-management surfaces.

Why: these screens share metrics, charts, progress indicators, account cards,
and AI cards. Building them after the expense flow allows reuse instead of
parallel duplication.

Expected result: reports, budget planning, goals, wallets, and subscriptions
render from static mock data with native charts/progress widgets.

Screens:

- `reports_main`
- `report_drilldown`
- `monthly_financial_story`
- `budgets_overview`
- `category_budgets_list`
- `edit_monthly_budget`
- `saving_goals_overview`
- `wallets_accounts`
- `subscriptions_center`

Work areas:

- `lib/features/reports/presentation/`
- `lib/features/budgets/presentation/`
- `lib/features/goals/presentation/`
- `lib/features/wallets/presentation/`
- `lib/features/subscriptions/presentation/`
- `lib/core/widgets/progress_bar.dart`
- `lib/core/widgets/progress_ring.dart`
- `lib/core/widgets/chart_card.dart`

Tasks:

- [ ] T015 [Reports] Build reports, drilldown, and monthly story screens.
  - Why: reports validate native chart cards and narrative panels.
  - Expected result: summary cards, category breakdown, drilldown details, and
    monthly story render without screenshots-as-UI.
  - Inputs: `reports_main`, `report_drilldown`, `monthly_financial_story`.
  - Implementation notes: charts must be native Flutter widgets or a minimal
    chart package if approved by the dependency plan.
  - Possible bugs: using screenshot images for charts, chart labels overflow,
    or route parameter does not find category mock data.
  - Fix strategy: replace chart screenshots with simple CustomPaint/fl_chart
    widgets, hide or wrap labels, and add category ID lookup tests.
  - Verification: report route and chart widget smoke tests pass.

- [ ] T016 [BudgetsGoals] Build budgets, edit budget, category budgets, and
  saving goals.
  - Why: these screens validate progress components and editable mock forms.
  - Expected result: budget overview, category budget list, edit form, goal
    cards, progress rings, and AI savings insight render.
  - Inputs: `budgets_overview`, `category_budgets_list`,
    `edit_monthly_budget`, `saving_goals_overview`.
  - Implementation notes: edit budget changes local state only; no persistence.
  - Possible bugs: progress values exceed 100%, edit form writes to global mock
    data, or rings clip in narrow cards.
  - Fix strategy: clamp progress between 0 and 1, copy data into local form
    state, and constrain ring dimensions.
  - Verification: widget tests assert progress clamping and no narrow overflow.

- [ ] T017 [Accounts] Build wallets and subscriptions screens.
  - Why: these surfaces validate bento cards, recurring cost cards, and
    account-style navigation without financial integrations.
  - Expected result: wallet cards, transfer preview, subscription cards, and AI
    renewal insight render from mock data.
  - Inputs: `wallets_accounts`, `subscriptions_center`.
  - Implementation notes: add wallet/subscription buttons are inert or route to
    planned placeholders only.
  - Possible bugs: worker adds bank/subscription APIs, brand logos use remote
    URLs, or card grid breaks at 360px.
  - Fix strategy: remove API packages, replace logos with local initials/icons,
    and use one-column mobile grids with responsive constraints.
  - Verification: forbidden dependency search and viewport smoke tests pass.

Acceptance criteria:

- All values come from mock data.
- Chart visuals are native Flutter widgets, not screenshots.
- Add/edit secondary actions are inert or route to planned placeholders.
- Required responsive and RTL checks pass.
- Required compile checks pass.

Stop condition: all planning/account screens must reuse existing shell, metric,
card, progress, and insight components.

## Batch 6: AI Surfaces, Settings, Polish

Goal: complete the exported screen set and harden quality.

Why: AI advice, assistant, Arabic chat history, and settings carry the highest
risk of accidentally implying real AI/auth/settings persistence. Final polish
also catches overflow, RTL, and duplicated component drift.

Expected result: all remaining screens render natively; AI and settings are
static/local-only; final verification proves UI-only compliance.

Screens:

- `ai_advice_insights`
- `ai_history_assistant`
- `ai_assistant_bottom_sheet`
- `settings_main`

Work areas:

- `lib/features/ai/presentation/`
- `lib/features/settings/presentation/`
- `lib/core/widgets/chat_bubble.dart`
- `lib/core/widgets/settings_row.dart`
- `test/features/ai/`
- `test/features/settings/`

Tasks:

- [ ] T018 [AI] Build AI advice, history, and assistant bottom sheet from mock
  messages and insights.
  - Why: AI surfaces must look complete while staying offline and static.
  - Expected result: AI insight cards, chat bubbles, prompt chips, and assistant
    sheet render with local-only input behavior.
  - Inputs: `ai_advice_insights`, `ai_history_assistant`,
    `ai_assistant_bottom_sheet`.
  - Implementation notes: Arabic chat should use RTL and Arabic font; sending a
    message can append a local mock response or show a visual-only state.
  - Possible bugs: adding an AI SDK/API client, Arabic bubbles align wrong,
    bottom sheet keyboard overflow, or prompt chips clip.
  - Fix strategy: remove AI/network dependencies, test RTL directionality, make
    sheet scrollable, and use horizontal chip scrolling.
  - Verification: AI screens pass LTR/RTL and forbidden dependency checks.

- [ ] T019 [Settings] Build settings screen with static rows and local toggles.
  - Why: settings must complete the app shell without adding persistence or
    account services.
  - Expected result: profile header, settings rows, toggles, and navigation
    affordances render from mock data.
  - Inputs: `settings_main`.
  - Implementation notes: toggles mutate local widget state only; subpages can
    route to placeholders if not implemented.
  - Possible bugs: toggles persist through packages, profile actions imply real
    account management, or rows duplicate style code.
  - Fix strategy: keep state in widget, use `SettingsRow`, and route secondary
    actions to placeholders/snackbars.
  - Verification: settings widget test toggles local controls without external
    calls.

- [ ] T020 [Polish] Run final visual, RTL, dependency, and compile verification.
  - Why: final pass catches cross-screen regressions before approval.
  - Expected result: every exported screen has a native Flutter counterpart and
    the app passes all compile and UI-only checks.
  - Inputs: all specs and all `screen.png` references.
  - Implementation notes: fix root causes in shared components/tokens whenever
    multiple screens share the same issue.
  - Possible bugs: one screen uses raw colors, screenshots rendered as UI,
    hidden WebView dependency, or narrow viewport overflow.
  - Fix strategy: search for forbidden patterns, centralize raw styles, inspect
    failing viewport, and add a regression widget test.
  - Verification: run the final verification gate below.

Acceptance criteria:

- No AI/API calls exist.
- Chat input does not call a backend.
- Settings toggles are local-only.
- Every exported screen has a native Flutter counterpart.
- Required compile checks pass.

Stop condition: implementation is not complete until the final gate passes or
any unavailable tool is documented with an exact failure reason.

## Final Verification Gate

Before claiming implementation complete:

- Search for forbidden dependencies and APIs:

```powershell
rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api" lib pubspec.yaml test
```

- Run:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

- If Android tooling is unavailable, record the exact failure and run:

```powershell
flutter build web
```

- Verify visual behavior at:

```text
360x800 LTR
360x800 RTL
375x812 LTR
375x812 RTL
390x844 LTR
390x844 RTL
```

- Confirm no screen embeds HTML, screenshots as UI, or WebView.

## Approval Checkpoint

Stop after these spec files are created or edited. Do not implement Flutter
screens until the user approves the plan.
