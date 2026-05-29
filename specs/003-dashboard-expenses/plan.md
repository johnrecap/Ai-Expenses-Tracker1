# UI-Only Flutter Implementation Plan: Dashboard And Expenses

**Branch**: `003-dashboard-expenses` | **Date**: 2026-05-28 | **Spec**: `specs/003-dashboard-expenses/spec.md`

**Input**: Feature specification from `/specs/003-dashboard-expenses/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

## Summary

Implement the main dashboard, expenses list, and expense filters bottom sheet using shared shell widgets, mock expenses, reusable transaction rows, local filter state, and native bottom sheet UI.

## Why

This is the primary money-tracking loop. It validates the app shell, high-density transaction rows, search/filter chips, bottom navigation, scroll behavior, and first modal bottom sheet.

## Expected Result

- `/home`
- `/expenses`
- `/expenses/filters` or a filter-triggered modal sheet
- `TransactionTile`, `TransactionSection`, `CategoryIconBadge`
- Dashboard and expenses tests

## Source References

- `stitch_ai_expenses_tracker_pro/home_dashboard/`
- `stitch_ai_expenses_tracker_pro/expenses_list/`
- `stitch_ai_expenses_tracker_pro/expense_filters_bottom_sheet/`
- `specs/design-system.md`
- `specs/component-map.md`
- `specs/001-foundation/`

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**: Foundation widgets and mock data

**Storage**: N/A. Static in-memory mock data and local filter state only.

**Testing**: Widget tests for screen rendering, transaction rows, modal sheet behavior, LTR/RTL viewports

**Target Platform**: Flutter mobile prototype verified at 360x800, 375x812, and 390x844

**Constraints**: No backend queries, persistence, database, API calls, WebView, or HTML rendering

## Constitution Check

- Project law read: PASS
- Skills used: PASS
- UI-only scope preserved: PASS
- No WebView or HTML rendering planned: PASS
- Native Flutter widgets planned: PASS
- Component reuse planned: PASS
- Mock/local state only: PASS
- Required responsive and RTL checks planned: PASS
- Compile checks listed: PASS

## Project Structure

```text
lib/features/dashboard/presentation/
lib/features/expenses/presentation/
lib/features/expenses/presentation/widgets/
test/features/dashboard/
test/features/expenses/
```

**Structure Decision**: Dashboard owns dashboard composition. Expenses owns transaction-specific widgets that are reused by dashboard when appropriate.

## Reuse Strategy

Use `AppBackground`, `AppTopBar`, `AppBottomNav`, `GlassCard`, `MetricCard`, `AiInsightCard`, `SearchField`, `FilterChipRow`, `GlassBottomSheet`, and theme/layout tokens. Create transaction components once.

## Mock Data Strategy

Use `MockExpense`, `MockCategory`, `MockWallet`, `MockAiInsight`, and dashboard metrics derived from static values. Filter state remains local to the expenses screen or sheet.

## Possible Bugs And Fix Strategy

- Transaction amount overflow: use constrained amount column and `Flexible` for merchant text.
- Chip overflow: horizontal scroll for chips.
- Bottom nav overlap: add shell-provided bottom padding.
- Sheet overflow: max-height and scrollable content.
- Duplicate transaction UI: move rows into shared expenses widgets.
- Backend creep: search imports and remove service/API packages.

## Verification Plan

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Forbidden search:

```powershell
rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api|repository|database" lib pubspec.yaml test
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
