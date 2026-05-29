# Tasks: Finance Feature Completion

**Input**: `specs/018-finance-feature-completion/spec.md`, `specs/018-finance-feature-completion/plan.md`

## Phase 1: Categories

- [ ] T018-001 [US1] Add categories management screen in `lib/features/categories/presentation/categories_screen.dart`
  - Why: Users need full category CRUD outside the add expense flow.
  - Expected result: Screen lists categories and supports create/edit/archive.
  - Inputs: Reference categories screen, current `CategoryBloc`, design tokens.
  - Implementation notes: Use shared list/card/button components; avoid duplicating category chip styles.
  - Possible bugs: archived categories disappear from historical expenses.
  - Fix strategy: hide archived only from selectors; keep historical display by stored category fields.
  - Verification: widget test for create/edit/archive states.

- [ ] T018-002 [P] [US1] Add category form dialog in `lib/features/categories/presentation/widgets/category_form_dialog.dart`
  - Why: Category creation and editing need consistent validation and icon/color selection.
  - Expected result: Reusable form handles name, icon, color, and validation.
  - Inputs: `flutter_colorpicker`, reference category dialog, category icon registry.
  - Implementation notes: Use accessible labels and RTL-friendly layout.
  - Possible bugs: long Arabic category names overflow.
  - Fix strategy: constrain fields and allow text wrapping where needed.
  - Verification: dialog widget tests at 360x800.

- [ ] T018-003 [US1] Wire categories route in `lib/app/routes.dart` and `lib/app/router.dart`
  - Why: Settings/add expense need a route to category management.
  - Expected result: `/categories` opens categories screen.
  - Inputs: router and settings files.
  - Implementation notes: Protected route; link from settings data section.
  - Possible bugs: route conflict with category reports.
  - Fix strategy: keep report route under `/reports/category/:categoryId`.
  - Verification: route tests.

- [ ] T018-004 [US1] Replace hardcoded category lists in expense and budget screens
  - Why: Real user categories must drive selectors, filters, and category budgets.
  - Expected result: Add/edit expense, filter sheet, reports, and category budget screens read `CategoryBloc`/repositories.
  - Inputs: `specs/012-data-quality/tasks.md`, current expense/budget screens.
  - Implementation notes: Remove `MockData.categories` from production paths.
  - Possible bugs: empty category state blocks expense entry.
  - Fix strategy: seed default categories and show retry/empty state.
  - Verification: source search plus widget tests.

## Phase 2: Recurring And Subscriptions

- [ ] T018-005 [US2] Create recurring expenses feature in `lib/features/recurring_expenses/`
  - Why: Recurring rules are missing as a navigable feature.
  - Expected result: Bloc, screen, form, and widgets support recurring expense CRUD.
  - Inputs: `Expense-Tracker-main/lib/screens/recurring_expenses/`.
  - Implementation notes: Reuse expense form primitives for category/payment/currency fields.
  - Possible bugs: recurrence frequency stored inconsistently across Firebase/local.
  - Fix strategy: use enum storage values and conversion tests.
  - Verification: bloc and widget tests.

- [ ] T018-006 [US2] Implement apply-once scheduler in `lib/services/recurring_expense_scheduler.dart`
  - Why: Due recurring expenses must not duplicate generated expenses.
  - Expected result: Scheduler identifies due rules, creates one expense per due period, updates next run/last generated state.
  - Inputs: reference scheduler, repository models.
  - Implementation notes: Treat dates as date-only for due checks.
  - Possible bugs: time zone causes duplicate generation around midnight.
  - Fix strategy: normalize to local date and test boundary dates.
  - Verification: `test/recurring/recurring_expense_scheduler_test.dart`.

- [ ] T018-007 [US2] Replace subscription mock data in `lib/features/subscriptions/presentation/subscriptions_center_screen.dart`
  - Why: Subscription center must reflect user recurring rules.
  - Expected result: Screen reads `SubscriptionSummaryService` and displays active/due/cancelled summaries.
  - Inputs: reference subscription summary service, recurring repository.
  - Implementation notes: AI insight cards can remain only if generated from real summaries.
  - Possible bugs: subscriptions disappear when recurring rule is archived but historical records remain.
  - Fix strategy: show active-only by default and add archived filter if needed.
  - Verification: subscription summary service and screen tests.

## Phase 3: Wallets And Transfers

- [ ] T018-008 [US3] Complete wallet bloc/cubit in `lib/features/wallets/`
  - Why: Wallet screen currently displays `MockData.wallets`.
  - Expected result: Wallets load from repository and support create/edit/archive.
  - Inputs: wallet repository interfaces, reference wallet models.
  - Implementation notes: Archive wallets with referenced expenses; do not destructive-delete by default.
  - Possible bugs: current `deleteWallet` local implementation is no-op.
  - Fix strategy: complete local/Firebase delete/archive behavior in repository package.
  - Verification: wallet bloc and repository tests.

- [ ] T018-009 [US3] Add transfer form and service in `lib/features/wallets/presentation/`
  - Why: Users need to move money between wallets without counting it as spending.
  - Expected result: Transfer form validates from/to wallet, amount, date, optional note, and updates balances.
  - Inputs: `TransferRepository`, wallet models.
  - Implementation notes: Prevent same-wallet transfer and negative amounts.
  - Possible bugs: transfer changes report totals.
  - Fix strategy: reports use expenses only; transfers affect wallet balance service.
  - Verification: transfer unit/widget tests.

- [ ] T018-010 [US3] Connect wallet selector in `lib/features/expenses/presentation/widgets/expense_form_card.dart`
  - Why: Expenses should be assigned to real wallets/payment sources.
  - Expected result: Add/edit expense can select wallet and persist wallet id/name.
  - Inputs: wallet bloc, expense model fields.
  - Implementation notes: Handle missing/archived wallet display on old expenses.
  - Possible bugs: deleting wallet breaks edit screen.
  - Fix strategy: keep stored wallet name fallback.
  - Verification: add/edit expense widget tests.

## Final Verification

- [ ] T018-011 [Polish] Run finance feature QA and mock-data audit
  - Why: Finance feature completion is not done while production paths still use mocks.
  - Expected result: Tests pass and source search shows no `MockData` in finance production screens.
  - Inputs: completed categories, recurring, subscriptions, wallets work.
  - Implementation notes: Export remains out of scope.
  - Possible bugs: tests pass but manual RTL overflows remain.
  - Fix strategy: run viewport checks and fix shared widgets first.
  - Verification: `flutter analyze --no-pub`; `flutter test --no-pub test/features/categories test/features/recurring test/features/wallets test/features/subscriptions`; required viewport checks.
