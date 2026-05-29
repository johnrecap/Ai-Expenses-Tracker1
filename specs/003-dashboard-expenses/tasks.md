# Tasks: Dashboard And Expenses

**Input**: Design documents from `/specs/003-dashboard-expenses/`

**Prerequisites**: `specs/001-foundation/` approved and implemented

## Mandatory First Read And Skill Gate

Skills used for task generation: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

## Non-Negotiable Rules

- UI only. No backend, API calls, database, persistence, WebView, or HTML rendering.
- Native Flutter widgets only.
- Mock data and local state only.
- Reuse shared components and tokens.
- Responsive for 360x800, 375x812, 390x844.
- Arabic RTL and English LTR ready.

## Phase 1: Shared Expense Components

- [ ] T201 [P] [US2] Create `CategoryIconBadge` in `lib/features/expenses/presentation/widgets/category_icon_badge.dart`
  - Why: Expense rows, filters, reports, and budgets need consistent category icon styling.
  - Expected result: Category icon badges render from mock category color/icon tokens.
  - Inputs: `expenses_list`, `home_dashboard`, `specs/component-map.md`.
  - Implementation notes: Use Material icons or approved local icon mapping; no SVG remote icons.
  - Possible bugs: Unknown icon names crash; badge size shifts rows.
  - Fix strategy: Provide fallback icon and fixed badge constraints.
  - Verification: Widget test renders known and unknown category IDs.

- [ ] T202 [US2] Create `TransactionTile` and `TransactionSection` in `lib/features/expenses/presentation/widgets/`
  - Why: Dashboard and expenses list share transaction rows and grouped sections.
  - Expected result: Transaction rows render merchant, category, wallet/status, and amount from `MockExpense`.
  - Inputs: `expenses_list/code.html`, `home_dashboard/code.html`, mock expenses.
  - Implementation notes: Use directional alignment; constrain amount column; keep row tap callback optional.
  - Possible bugs: Duplicate row code; amount clips; long merchant pushes amount offscreen.
  - Fix strategy: Use one component, `Expanded` for text, fixed min/max amount area, and ellipsis only for secondary text.
  - Verification: Test row with long merchant and large amount at 360px in LTR and RTL.

## Phase 2: Dashboard

- [ ] T203 [US1] Build `HomeDashboardScreen` in `lib/features/dashboard/presentation/home_dashboard_screen.dart`
  - Why: Dashboard is the primary home and combines most foundation components.
  - Expected result: `/home` shows greeting, summary metrics, AI insight, recent transactions, and bottom nav.
  - Inputs: `home_dashboard/screen.png`, `home_dashboard/code.html`, mock user/expenses/insights.
  - Implementation notes: Use `AppTopBar`, `MetricCard`, `AiInsightCard`, `TransactionTile`, and `AppBottomNav`.
  - Possible bugs: Bottom nav covers content; metric cards use raw colors; hero amount overflows.
  - Fix strategy: Add bottom content padding, move colors to tokens, constrain currency text.
  - Verification: Dashboard widget tests at 360, 375, 390 widths in LTR and RTL.

- [ ] T204 [US1] Wire `/home` in `lib/app/router.dart`
  - Why: Dashboard must be reachable through the central route registry.
  - Expected result: `/home` resolves to `HomeDashboardScreen`.
  - Inputs: Foundation router, `contracts/ui-contract.md`.
  - Implementation notes: Keep auth guards out of routing.
  - Possible bugs: Route points to placeholder; bottom nav active state wrong.
  - Fix strategy: Add route smoke test and central tab-to-route mapping.
  - Verification: Route test opens `/home`.

## Phase 3: Expenses List And Filters

- [ ] T205 [US2] Build `ExpensesListScreen` in `lib/features/expenses/presentation/expenses_list_screen.dart`
  - Why: Expenses list is the main high-density transaction browsing surface.
  - Expected result: `/expenses` shows search, filter chips, grouped transaction sections, and bottom nav.
  - Inputs: `expenses_list/screen.png`, `expenses_list/code.html`, transaction widgets.
  - Implementation notes: Search/chip filtering is local-only; chip row scrolls horizontally.
  - Possible bugs: Chip overflow; list hidden by nav; search implies backend query.
  - Fix strategy: Use horizontal `ListView`, bottom padding, and local mock filtering only.
  - Verification: Expenses list test scrolls and checks no overflow.

- [ ] T206 [US3] Build `ExpenseFiltersSheet` in `lib/features/expenses/presentation/expense_filters_sheet.dart`
  - Why: Filter export is a modal bottom sheet and validates native modal behavior.
  - Expected result: Filter button opens `GlassBottomSheet` with local filter controls, reset, and apply.
  - Inputs: `expense_filters_bottom_sheet/screen.png`, `code.html`.
  - Implementation notes: Cap sheet height; scroll body; pin footer with safe padding.
  - Possible bugs: Sheet exceeds viewport; footer overlaps safe area; state persists unexpectedly.
  - Fix strategy: Use `DraggableScrollableSheet` or constrained modal content, local state only.
  - Verification: Test opens sheet, taps reset/apply, and closes.

- [ ] T207 [US2] Wire `/expenses` and filter trigger in `lib/app/router.dart`
  - Why: Users need stable navigation between dashboard, expenses, and modal filter UI.
  - Expected result: `/expenses` opens list and filter action opens the native sheet.
  - Inputs: `contracts/ui-contract.md`, foundation routes.
  - Implementation notes: If `/expenses/filters` is represented as a route, it must still display as modal UI.
  - Possible bugs: Sheet opens as full page; back button does not close sheet.
  - Fix strategy: Use modal route or route-aware sheet pattern and add navigation test.
  - Verification: Route test opens `/expenses` and filter sheet.

## Phase 4: Verification

- [ ] T208 [Polish] Run compile, viewport, RTL, and forbidden dependency checks
  - Why: Main money flow must remain native and UI-only before add/edit flows.
  - Expected result: Commands pass or environment blockers are documented; no forbidden hits.
  - Inputs: Completed dashboard/expenses files.
  - Implementation notes: Inspect every dependency search hit.
  - Possible bugs: False positives; hidden repository/service import; narrow overflow.
  - Fix strategy: Remove implementation violations and fix shared components first.
  - Verification: `flutter pub get`, `flutter analyze`, `flutter test`, debug build, viewport checks, forbidden search.

## Dependencies And Execution Order

T201 and T202 block dashboard and expenses. T203/T204 can run before T205. T206 depends on foundation bottom sheet widget. T208 is final.

## Acceptance Criteria

- Dashboard, expenses list, and filters sheet render natively.
- Transactions come from static mock data.
- Search/filter controls are local-only.
- No backend/API/database/persistence/WebView/HTML rendering.
- Required viewport and RTL/LTR checks pass.
