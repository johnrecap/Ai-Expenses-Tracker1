# Reports, Budgets, And Goals Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild reporting, budget planning, and saving-goal screens as native Flutter UI.

**Architecture:** Reuse metric cards, AI insight cards, native chart/progress
widgets, and mock financial summaries. Charts are native Flutter widgets or an
approved lightweight chart dependency, never screenshots.

**Tech Stack:** Flutter, shared widgets, mock reports/budgets/goals, optional
chart package only if approved by Plan 00 dependency decisions.

---

## Depends On

- `specs/plans/00-foundation-plan.md`
- `specs/plans/02-dashboard-expenses-plan.md` for transaction/category components.

## Screens Covered

- `reports_main`
- `report_drilldown`
- `monthly_financial_story`
- `budgets_overview`
- `category_budgets_list`
- `edit_monthly_budget`
- `saving_goals_overview`

## Why

These screens turn expense data into planning views. They share summary cards,
charts, category rows, progress bars, progress rings, edit forms, and AI
insight cards. Implementing them together prevents conflicting chart/progress
patterns.

## Expected Result

Reports, report drilldown, monthly story, budgets, category budgets, edit budget,
and saving goals render from mock data with responsive native visuals.

## Source References

- `stitch_ai_expenses_tracker_pro/reports_main/*`
- `stitch_ai_expenses_tracker_pro/report_drilldown/*`
- `stitch_ai_expenses_tracker_pro/monthly_financial_story/*`
- `stitch_ai_expenses_tracker_pro/budgets_overview/*`
- `stitch_ai_expenses_tracker_pro/category_budgets_list/*`
- `stitch_ai_expenses_tracker_pro/edit_monthly_budget/*`
- `stitch_ai_expenses_tracker_pro/saving_goals_overview/*`
- `specs/component-map.md`
- `specs/design-system.md`

## Files And Ownership

- Create: `lib/features/reports/presentation/reports_main_screen.dart`
- Create: `lib/features/reports/presentation/report_drilldown_screen.dart`
- Create: `lib/features/reports/presentation/monthly_financial_story_screen.dart`
- Create: `lib/features/reports/presentation/widgets/report_summary_card.dart`
- Create: `lib/features/reports/presentation/widgets/chart_card.dart`
- Create: `lib/features/budgets/presentation/budgets_overview_screen.dart`
- Create: `lib/features/budgets/presentation/category_budgets_screen.dart`
- Create: `lib/features/budgets/presentation/edit_monthly_budget_screen.dart`
- Create: `lib/features/budgets/presentation/widgets/budget_overview_card.dart`
- Create: `lib/features/budgets/presentation/widgets/category_budget_tile.dart`
- Create: `lib/features/goals/presentation/saving_goals_screen.dart`
- Create: `lib/features/goals/presentation/widgets/goal_card.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/core/mock/mock_data.dart`
- Test: `test/features/reports/reports_test.dart`
- Test: `test/features/budgets/budgets_test.dart`
- Test: `test/features/goals/goals_test.dart`

## Tasks

- [ ] T401 [Charts] Build native report/chart primitives.
  - Why: Report screens need charts without using screenshots or HTML.
  - Expected result: `ChartCard` and `ReportSummaryCard` render mock spending trends and category summaries.
  - Inputs: `reports_main`, `report_drilldown`, `monthly_financial_story`.
  - Implementation notes: Use simple `CustomPaint` or approved chart dependency; keep labels responsive.
  - Possible bugs: chart labels overflow, chart package adds unwanted dependencies, screenshots used as UI.
  - Fix strategy: simplify chart geometry, constrain labels, remove screenshot-based UI.
  - Verification: chart widget test at 360px with long category labels.

- [ ] T402 [Reports] Build reports main, drilldown, and monthly story screens.
  - Why: These screens validate analytics-style surfaces and route parameters.
  - Expected result: `/reports`, `/reports/category/:categoryId`, and `/story/monthly` render native report UI.
  - Inputs: report exports and mock reports/categories/expenses.
  - Implementation notes: Drilldown uses mock category ID; monthly story is static/narrative.
  - Possible bugs: unknown category ID crashes, story content exceeds viewport, charts drift visually.
  - Fix strategy: route unknown IDs to not-found, make story scrollable, adjust shared chart tokens.
  - Verification: route tests cover known and unknown category IDs.

- [ ] T403 [Budgets] Build budget overview, category budgets, and edit budget.
  - Why: Budget screens share progress bars and editable mock fields.
  - Expected result: `/budgets`, `/budgets/categories`, and `/budgets/monthly/edit` render budget data and local edit UI.
  - Inputs: budget exports and mock budget/category data.
  - Implementation notes: Edit changes local state only; sliders/steppers do not persist.
  - Possible bugs: progress values exceed 100%, edit form mutates static mock data, bottom CTA hidden.
  - Fix strategy: clamp progress values, copy values into local controllers, add safe bottom padding.
  - Verification: tests assert progress clamping and local edit behavior.

- [ ] T404 [Goals] Build saving goals screen and goal components.
  - Why: Goals validate circular progress and AI insight reuse.
  - Expected result: `/goals` renders total saved, goal cards, progress rings, and AI insight card.
  - Inputs: `saving_goals_overview/screen.png`, `code.html`, mock goals.
  - Implementation notes: Add-goal action is inert or routes to a placeholder; no persistence.
  - Possible bugs: progress rings clip, total amount overflows, add action implies database.
  - Fix strategy: constrain ring sizes, use tabular/constrained amount text, show local snackbar for add.
  - Verification: goals widget test renders both low and high progress values.

## Possible Bugs And Fix Strategy

- Chart screenshots: replace with native chart widgets.
- Progress overflow: clamp `0.0..1.0`.
- Form persistence creep: keep edit budget local-only.
- Wide report labels: wrap, abbreviate, or hide secondary labels on 360px.

## Verification

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Seven covered screens render natively.
- Charts/progress visuals are native Flutter.
- All data comes from mock objects.
- No backend, API, database, persistence, WebView, or screenshot-as-UI.
- Required viewport and RTL checks pass.

## Stop Condition

Do not start wallets/subscriptions until shared metric, chart, and progress
components are stable.
