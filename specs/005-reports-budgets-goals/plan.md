# UI-Only Flutter Implementation Plan: Reports, Budgets, And Goals

**Branch**: `005-reports-budgets-goals` | **Date**: 2026-05-28 | **Spec**: `specs/005-reports-budgets-goals/spec.md`

**Input**: Feature specification from `/specs/005-reports-budgets-goals/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

## Summary

Implement native report, drilldown, monthly story, budget, category budget, edit budget, and saving goal screens from static mock data with reusable chart/progress/story components.

## Why

These screens turn expense data into planning and insight views. Building them together prevents conflicting chart/progress patterns and keeps budget edit behavior local-only.

## Expected Result

- `/reports`
- `/reports/category/:categoryId`
- `/story/monthly`
- `/budgets`
- `/budgets/categories`
- `/budgets/monthly/edit`
- `/goals`
- Native chart/progress/story/goal/budget components and tests

## Source References

- `stitch_ai_expenses_tracker_pro/reports_main/`
- `stitch_ai_expenses_tracker_pro/report_drilldown/`
- `stitch_ai_expenses_tracker_pro/monthly_financial_story/`
- `stitch_ai_expenses_tracker_pro/budgets_overview/`
- `stitch_ai_expenses_tracker_pro/category_budgets_list/`
- `stitch_ai_expenses_tracker_pro/edit_monthly_budget/`
- `stitch_ai_expenses_tracker_pro/saving_goals_overview/`
- `specs/component-map.md`
- `specs/design-system.md`

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**: Foundation widgets; optional approved lightweight chart dependency only if needed

**Storage**: N/A. Static mock data and local edit state only.

**Testing**: Widget tests for charts/progress, route IDs, viewports, and RTL

**Target Platform**: Flutter mobile prototype verified at 360x800, 375x812, and 390x844

**Constraints**: No analytics backend, database, persistence, API calls, WebView, HTML rendering, or screenshots-as-UI

## Constitution Check

- Project law read: PASS
- Skills used: PASS
- UI-only scope preserved: PASS
- No WebView or HTML rendering planned: PASS
- Native Flutter widgets planned: PASS
- Reuse planned: PASS
- Mock/local state only: PASS
- Required responsive and RTL checks planned: PASS
- Compile checks listed: PASS

## Project Structure

```text
lib/features/reports/presentation/
lib/features/reports/presentation/widgets/
lib/features/budgets/presentation/
lib/features/budgets/presentation/widgets/
lib/features/goals/presentation/
lib/features/goals/presentation/widgets/
test/features/reports/
test/features/budgets/
test/features/goals/
```

**Structure Decision**: Keep reports, budgets, and goals in feature folders while using shared foundation cards, progress widgets, and AI insight widgets.

## Reuse Strategy

Use `MetricCard`, `GlassCard`, `AiInsightCard`, `ProgressBar`, `ProgressRing`, `SectionHeader`, `AppTopBar`, and `AppBottomNav`. Create `ChartCard`, `ReportSummaryCard`, `StoryPagePanel`, `BudgetOverviewCard`, `CategoryBudgetTile`, and `GoalCard`.

## Mock Data Strategy

Use static report, category, budget, goal, and expense data. Budget edit screen copies values into local draft state and does not write persistent state.

## Possible Bugs And Fix Strategy

- Chart label overflow: reduce label density, wrap, or abbreviate.
- Screenshot-as-chart: replace with native chart widgets or approved chart package.
- Progress over 100%: clamp values between 0 and 1.
- Unknown category ID: route to not-found or safe fallback.
- Edit budget persistence creep: keep state local and avoid storage packages.

## Verification Plan

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Forbidden search:

```powershell
rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api|repository|database|Image.asset\\(.*screen" lib pubspec.yaml test
```

Viewport checks: 360x800, 375x812, 390x844 in LTR and RTL.

## Phase 0: Research

Completed in `research.md`.

## Phase 1: Design

Completed in `data-model.md`, `contracts/ui-contract.md`, `quickstart.md`, and `tasks.md`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
