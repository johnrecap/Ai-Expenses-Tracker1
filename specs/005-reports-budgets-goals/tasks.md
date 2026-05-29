# Tasks: Reports, Budgets, And Goals

**Input**: Design documents from `/specs/005-reports-budgets-goals/`

**Prerequisites**: `specs/001-foundation/`, reusable expense/category components from `specs/003-dashboard-expenses/`

## Mandatory First Read And Skill Gate

Skills used for task generation: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

## Non-Negotiable Rules

- UI only. No backend, analytics API, database, persistence, WebView, HTML rendering, or screenshots-as-UI.
- Native Flutter widgets only.
- Static mock data and local state only.
- Reuse shared components and tokens.
- Responsive for 360x800, 375x812, 390x844.
- Arabic RTL and English LTR ready.

## Phase 1: Report Components

- [ ] T401 [P] [US1] Create `ReportSummaryCard` in `lib/features/reports/presentation/widgets/report_summary_card.dart`
  - Why: Reports and drilldown share summary totals and comparison text.
  - Expected result: Summary card renders total, comparison, and trend from mock report data.
  - Inputs: `reports_main`, `report_drilldown`, `specs/component-map.md`.
  - Implementation notes: Use `GlassCard`, `MetricCard` patterns, and constrained currency text.
  - Possible bugs: Large amount overflow; raw colors copied from HTML.
  - Fix strategy: Use shared text constraints and theme tokens.
  - Verification: Widget test renders large totals at 360px.

- [ ] T402 [P] [US1] Create `ChartCard` in `lib/features/reports/presentation/widgets/chart_card.dart`
  - Why: Report visuals must be native and reusable.
  - Expected result: Native chart placeholder/CustomPaint renders trend and category data.
  - Inputs: report exports and `research.md`.
  - Implementation notes: Do not use screenshot images for chart UI; chart dependency requires approval if added.
  - Possible bugs: Chart labels overflow; chart area blank; dependency bloat.
  - Fix strategy: Simplify labels, add test data, and prefer native drawing.
  - Verification: Chart widget test renders non-empty canvas/structure at 360px.

## Phase 2: Reports And Story Screens

- [ ] T403 [US1] Build `ReportsMainScreen` in `lib/features/reports/presentation/reports_main_screen.dart`
  - Why: Reports overview is a detected core analytics screen.
  - Expected result: `/reports` renders summary, chart, category breakdown, and bottom nav.
  - Inputs: `reports_main/screen.png`, `code.html`, mock reports/categories.
  - Implementation notes: Use shared `ChartCard`, `ReportSummaryCard`, and category badge components.
  - Possible bugs: Category rows duplicate expense rows; labels clip; bottom nav overlap.
  - Fix strategy: Reuse category components, constrain labels, add bottom padding.
  - Verification: Reports screen viewport tests pass.

- [ ] T404 [US1] Build `ReportDrilldownScreen` in `lib/features/reports/presentation/report_drilldown_screen.dart`
  - Why: Drilldown validates route parameters and category-specific report layout.
  - Expected result: `/reports/category/:categoryId` renders known category details or safe not-found.
  - Inputs: `report_drilldown/screen.png`, mock category IDs.
  - Implementation notes: Unknown IDs must not crash.
  - Possible bugs: Null category crash; route ID not decoded.
  - Fix strategy: Add lookup guard and route tests for known/unknown IDs.
  - Verification: Drilldown route tests pass.

- [ ] T405 [US2] Build `MonthlyFinancialStoryScreen` in `lib/features/reports/presentation/monthly_financial_story_screen.dart`
  - Why: Monthly story is a detected screen with long narrative content.
  - Expected result: `/story/monthly` renders native story panels and metrics.
  - Inputs: `monthly_financial_story/screen.png`, `code.html`.
  - Implementation notes: Use scrollable content and `StoryPagePanel`.
  - Possible bugs: Story text clips; panels are too tall; decorative screenshots used.
  - Fix strategy: Use flexible panels and native icons/metrics only.
  - Verification: Story scroll test at 360x800.

## Phase 3: Budgets And Goals

- [ ] T406 [P] [US3] Create budget widgets in `lib/features/budgets/presentation/widgets/`
  - Why: Budget overview, category list, and edit screen share progress and budget rows.
  - Expected result: `BudgetOverviewCard` and `CategoryBudgetTile` render mock budget values.
  - Inputs: `budgets_overview`, `category_budgets_list`, design tokens.
  - Implementation notes: Clamp progress and use shared `ProgressBar`.
  - Possible bugs: Progress exceeds bounds; long category labels overflow.
  - Fix strategy: Clamp values and constrain/wrap labels.
  - Verification: Progress clamping unit/widget test.

- [ ] T407 [US3] Build budget screens in `lib/features/budgets/presentation/`
  - Why: Budget planning screens are part of the detected export set.
  - Expected result: `/budgets`, `/budgets/categories`, and `/budgets/monthly/edit` render native UI.
  - Inputs: budget exports, mock budgets/categories.
  - Implementation notes: Edit budget uses local draft state only.
  - Possible bugs: Edit persists globally; CTA hidden; slider overflow.
  - Fix strategy: Copy values to local state, safe footer padding, and constrained controls.
  - Verification: Budget edit test changes value locally only.

- [ ] T408 [P] [US3] Create `GoalCard` in `lib/features/goals/presentation/widgets/goal_card.dart`
  - Why: Saving goals repeat progress ring, amount, deadline, and status patterns.
  - Expected result: Goal card renders from mock goal data with clamped progress.
  - Inputs: `saving_goals_overview/screen.png`, mock goals.
  - Implementation notes: Use shared `ProgressRing` and constrained amount text.
  - Possible bugs: Ring clips; large target amount overflows.
  - Fix strategy: Fixed ring size and flexible text area.
  - Verification: Goal card test for low, high, and over-target progress.

- [ ] T409 [US3] Build `SavingGoalsScreen` in `lib/features/goals/presentation/saving_goals_screen.dart`
  - Why: Goals screen completes the planning surface and reuses AI insight.
  - Expected result: `/goals` renders goal cards, total saved, and AI insight.
  - Inputs: `saving_goals_overview/screen.png`, `code.html`, mock goals/insights.
  - Implementation notes: Add-goal action is inert or placeholder-only.
  - Possible bugs: Add action implies database; bottom nav overlap.
  - Fix strategy: Local snackbar/placeholder and bottom safe padding.
  - Verification: Goals screen viewport tests pass.

## Phase 4: Routes And Verification

- [ ] T410 [Routes] Wire report, budget, and goal routes in `lib/app/router.dart`
  - Why: All screens need central navigation and route ID handling.
  - Expected result: Seven routes resolve correctly.
  - Inputs: `contracts/ui-contract.md`.
  - Implementation notes: Unknown drilldown IDs route safely.
  - Possible bugs: Route mismatch; placeholder left in place.
  - Fix strategy: Add route smoke tests.
  - Verification: Route tests cover all paths.

- [ ] T411 [Polish] Run compile, viewport, RTL, and forbidden dependency checks
  - Why: Reports/planning screens are complete only when native and UI-only.
  - Expected result: Commands pass or blockers documented; forbidden search clean.
  - Inputs: Completed feature files.
  - Implementation notes: Inspect screenshot-as-UI patterns as well as service dependencies.
  - Possible bugs: False positives; chart screenshots; progress overflow.
  - Fix strategy: Remove violations and fix shared widgets.
  - Verification: `flutter pub get`, `flutter analyze`, `flutter test`, debug build, viewport checks, forbidden search.

## Dependencies And Execution Order

T401-T402 block report screens. T406 blocks budget screens. T408 blocks goals screen. T410 depends on screens. T411 is final.

## Acceptance Criteria

- Seven screens render natively.
- Charts/progress visuals are native Flutter.
- All data is static mock data.
- No backend/API/database/persistence/WebView/HTML rendering/screenshots-as-UI.
- Required viewport and RTL/LTR checks pass.
