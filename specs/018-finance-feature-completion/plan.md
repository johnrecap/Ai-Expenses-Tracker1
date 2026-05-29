# Implementation Plan: Finance Feature Completion

**Branch**: `018-finance-feature-completion` | **Date**: 2026-05-29 | **Spec**: `specs/018-finance-feature-completion/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

## Summary

Replace mock-only finance surfaces with real category, recurring, subscription, wallet, and transfer workflows while preserving the redesigned `new app` UI.

## Why

The comparison showed several screens exist visually but are not complete product features. Wallets and subscriptions read mock data; category management and recurring expenses are missing as screens; transfers are partial in the repository package.

## Expected Result

- Full categories management route.
- Recurring expenses route and bloc.
- Subscription center derived from recurring rules.
- Wallet CRUD and transfer flow.
- Add/edit expense uses real category and wallet data.
- Tests for each finance feature.

## Source References

- `Expense-Tracker-main/lib/screens/categories/`
- `Expense-Tracker-main/lib/screens/recurring_expenses/`
- `Expense-Tracker-main/lib/screens/subscriptions/`
- `Expense-Tracker-main/packages/expense_repository/lib/src/*wallet*`
- `new app/lib/features/wallets/presentation/wallets_accounts_screen.dart`
- `new app/lib/features/subscriptions/presentation/subscriptions_center_screen.dart`
- `new app/lib/features/expenses/presentation/widgets/expense_form_card.dart`

## Technical Context

**Primary Dependencies**: `flutter_bloc`, `go_router`, `flutter_colorpicker`, existing repository package.

**Storage**: Firebase and local-first repositories from specs 014 and 015.

**Testing**: Bloc tests, repository tests, widget tests for finance screens.

**Constraints**: No Export screen. No hardcoded mock data in production finance surfaces.

## Constitution Check

- Native Flutter widgets and shared components are required.
- Reuse existing theme/widgets.
- Responsive and RTL checks are required.
- Backend/repository integration is allowed by constitution.

## Project Structure

```text
lib/features/categories/
lib/features/recurring_expenses/
lib/features/subscriptions/
lib/features/wallets/
lib/features/expenses/
lib/app/routes.dart
lib/app/router.dart
test/features/categories/
test/features/recurring/
test/features/wallets/
test/features/subscriptions/
```

## Implementation Batches

### Batch 1 - Categories

**Expected result**: Category CRUD screen and category-aware add/filter/report surfaces.

### Batch 2 - Recurring And Subscriptions

**Expected result**: Recurring rules drive subscription summaries and due actions.

### Batch 3 - Wallets And Transfers

**Expected result**: Wallet balances and transfers are real and connected to expenses.

### Batch 4 - Finance QA

**Expected result**: No mock finance data on production paths; tests pass.

## Possible Bugs And Fix Strategy

- **Archived category still selectable by default**: filter archived categories except historical display.
- **Recurring item applies twice**: track last generated/applied date and disable duplicate action.
- **Transfer counted as expense**: model transfers separately and exclude from spending totals.
- **Wallet delete breaks old expenses**: archive wallet instead of destructive delete when referenced.
- **Mock data remains in screen**: source search for `MockData` in finance feature folders.

## Verification Plan

```powershell
flutter analyze --no-pub
flutter test --no-pub test/features/categories test/features/recurring test/features/wallets test/features/subscriptions test/features/expenses
rg -n "MockData" lib/features/categories lib/features/recurring_expenses lib/features/subscriptions lib/features/wallets lib/features/expenses
```

## Stop Condition

Finance features are repository-backed, independently testable, responsive, RTL-ready, and no Export screen work is introduced.
