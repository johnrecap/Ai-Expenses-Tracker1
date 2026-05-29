# Dashboard And Expenses Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the dashboard, expenses list, and expense filters bottom sheet.

**Architecture:** Use the main shell, static mock expenses, shared transaction
rows, metric cards, AI insight cards, search field, filter chips, and native
bottom sheet components.

**Tech Stack:** Flutter, Plan 00 foundation, Plan 01 route flow, static mock data.

---

## Depends On

- `specs/plans/00-foundation-plan.md`
- Plan 01 routes may exist, but this plan can start after foundation if entry placeholders are available.

## Screens Covered

- `home_dashboard`
- `expenses_list`
- `expense_filters_bottom_sheet`

## Why

This is the primary money-tracking loop. It validates the bottom tab shell,
high-density transaction rows, grouped lists, search/filter controls, glass
cards, and modal bottom sheet behavior.

## Expected Result

The app shows a native dashboard, a native expenses list, and a native filter
bottom sheet using only static mock data and local UI state.

## Source References

- `stitch_ai_expenses_tracker_pro/home_dashboard/*`
- `stitch_ai_expenses_tracker_pro/expenses_list/*`
- `stitch_ai_expenses_tracker_pro/expense_filters_bottom_sheet/*`
- `specs/component-map.md`
- `specs/design-system.md`

## Files And Ownership

- Create: `lib/features/dashboard/presentation/home_dashboard_screen.dart`
- Create: `lib/features/expenses/presentation/expenses_list_screen.dart`
- Create: `lib/features/expenses/presentation/expense_filters_sheet.dart`
- Create: `lib/features/expenses/presentation/widgets/transaction_tile.dart`
- Create: `lib/features/expenses/presentation/widgets/transaction_section.dart`
- Create: `lib/features/expenses/presentation/widgets/category_icon_badge.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/core/mock/mock_data.dart`
- Test: `test/features/dashboard/home_dashboard_test.dart`
- Test: `test/features/expenses/expenses_list_test.dart`

## Tasks

- [ ] T201 [Expenses] Build transaction row and section components.
  - Why: Dashboard and expenses list both need the same merchant/category/amount/sync row.
  - Expected result: `TransactionTile`, `TransactionSection`, and `CategoryIconBadge` render from `MockExpense`.
  - Inputs: `expenses_list/code.html`, `home_dashboard/code.html`, mock expenses.
  - Implementation notes: Keep amount alignment direction-aware; large amounts must not overflow.
  - Possible bugs: duplicate transaction row code, amount text clips at 360px, sync icons spin forever in tests.
  - Fix strategy: move row UI to one component, constrain amount column, disable or tolerate animation in tests.
  - Verification: widget test renders long merchant names and large EGP amounts at 360px.

- [ ] T202 [Dashboard] Build `HomeDashboardScreen`.
  - Why: This screen combines top bar, metric cards, insight card, transaction preview, and bottom nav.
  - Expected result: `/home` shows the native dashboard from mock user, metrics, insights, and expenses.
  - Inputs: `home_dashboard/screen.png`, `home_dashboard/code.html`, shared widgets.
  - Implementation notes: Use `AppTopBar`, `MetricCard`, `AiInsightCard`, `TransactionTile`, and `AppBottomNav`.
  - Possible bugs: bottom nav covers last content, metric cards use raw colors, hero amount overflows.
  - Fix strategy: add bottom safe padding, move colors to tokens, wrap large amounts in constrained text.
  - Verification: dashboard smoke tests pass for 360x800, 375x812, 390x844 in LTR/RTL.

- [ ] T203 [Expenses] Build `ExpensesListScreen`.
  - Why: Expenses list is the main repeated list surface and validates search/chip components.
  - Expected result: `/expenses` shows search, filter chips, grouped transaction sections, and bottom nav.
  - Inputs: `expenses_list/screen.png`, `expenses_list/code.html`.
  - Implementation notes: Search filters mock data locally if implemented; no persistence or backend query.
  - Possible bugs: horizontal chips overflow, grouped cards nest incorrectly, list bottom hidden by nav.
  - Fix strategy: use horizontal `ListView`, avoid card-in-card styling, add bottom padding.
  - Verification: test scrolls expenses list and checks no overflow exceptions.

- [ ] T204 [Expenses] Build `ExpenseFiltersSheet`.
  - Why: The filters export is a bottom-sheet modal, not a full screen.
  - Expected result: `/expenses/filters` or a filter button opens a native `GlassBottomSheet` with search, dates, category chips, range, reset/apply buttons.
  - Inputs: `expense_filters_bottom_sheet/screen.png`, `expense_filters_bottom_sheet/code.html`.
  - Implementation notes: State stays inside the sheet; applying filters may update only visible local mock state.
  - Possible bugs: sheet height exceeds viewport, controls hidden behind safe area, reset/apply buttons overlap.
  - Fix strategy: cap sheet height, make content scrollable, pin footer with safe bottom padding.
  - Verification: test opens sheet, taps reset/apply, and closes without route crash.

## Possible Bugs And Fix Strategy

- Bottom nav overlap: add shell-provided content padding.
- Long transaction text: use `Expanded`, `Flexible`, and `TextOverflow.ellipsis`.
- Modal sheet overflow: cap height and scroll body content.
- Real filtering backend creep: filter only local mock arrays.

## Verification

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Forbidden dependency search remains required.

## Acceptance Criteria

- Three covered surfaces render natively.
- No WebView, HTML rendering, backend, or API calls.
- Transactions come from mock data.
- Filter sheet is native and local-only.
- Required viewport and RTL checks pass.

## Stop Condition

Do not start add/edit expense flow until transaction components, filter sheet,
and bottom nav layout are stable.
