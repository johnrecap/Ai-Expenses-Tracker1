# Contract: Budget And Wallet Correctness

## Scope

Owned files:

- `packages/expense_repository/lib/src/local/local_repositories.dart`
- `packages/expense_repository/lib/src/local/drift/drift_store.dart`
- `packages/expense_repository/lib/src/models/budget.dart`
- `packages/expense_repository/lib/src/models/expense.dart`
- `packages/expense_repository/lib/src/models/wallet_account.dart`
- wallet and expense blocs/cubits directly touched by the implementation

## Budget Guarantees

1. A budget request with month/year returns only the budget for that month/year.
2. Budget watch streams emit the budget for the requested month/year.
3. If no budget exists for the requested month/year, the result is empty/null rather than another month.

## Wallet Balance Policy

The app uses automatic wallet balance updates for wallet-linked expenses:

1. Creating a wallet-linked expense reduces the wallet balance by the expense amount.
2. Editing a wallet-linked expense adjusts the previous wallet and the new wallet correctly.
3. Deleting a wallet-linked expense restores the wallet balance.
4. Currency mismatch is rejected or explicitly handled; it is never silently adjusted.
5. Expenses without a wallet do not change any wallet balance.

## Acceptance Tests

- Store two monthly budgets and verify each requested month returns the correct one.
- Create, edit, move, and delete wallet-linked expenses and verify no balance drift.
- If using manual fallback, verify no automatic balance adjustment occurs and UI copy is clear.
