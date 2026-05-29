# Firestore Ownership Matrix

This document maps the legacy Firestore collections used by
`packages/expense_repository/lib/src/firebase/` to their ownership boundary and
security-rule intent.

All app-owned documents live under `users/{userId}`. Reads and writes are
allowed only when `request.auth.uid == userId`. Root-level fallback matches deny
all reads and writes.

| Collection path | Repository file | Owner rule | Write validation |
| --- | --- | --- | --- |
| `users/{userId}/expenses/{expenseId}` | `firebase_expense_repo.dart` | Authenticated owner only | `expenseId`, `userId`, money fields, timestamps, source, payment method, currency, optional AI/wallet/recurring references |
| `users/{userId}/categories/{categoryId}` | `firebase_category_repo.dart` | Authenticated owner only | Category ID, owner ID, name, icon, color, archive flag, timestamps |
| `users/{userId}/budgets/{budgetId}` | `firebase_budget_repo.dart` | Authenticated owner only | Monthly budget ID, owner ID, month, year, amount, currency, warning threshold, timestamps |
| `users/{userId}/categoryBudgets/{budgetId}` | `firebase_category_budget_repo.dart` | Authenticated owner only | Category budget ID, owner ID, category ID, amount, month, year, timestamps |
| `users/{userId}/recurringExpenses/{recurringExpenseId}` | `firebase_recurring_expense_repo.dart` | Authenticated owner only | Recurring expense ID, owner ID, name, amount, category ID, currency, frequency, start/end dates, timestamps |
| `users/{userId}/saving_goals/{goalId}` | `firebase_saving_goal_repo.dart` | Authenticated owner only | Goal ID, owner ID, name, target/current amount, currency, color, archive flag, optional deadline, timestamps |
| `users/{userId}/wallets/{walletId}` | `firebase_wallet_repo.dart` | Authenticated owner only | Wallet ID, owner ID, name, type, balance, currency, icon, color, timestamps |
| `users/{userId}/transfers/{transferId}` | `firebase_wallet_repo.dart` | Authenticated owner only | Transfer ID, owner ID, source/destination wallet IDs, amount, optional note, date, creation timestamp |
| `users/{userId}/settings/profile` | `firebase_settings_repo.dart` | Authenticated owner only | Profile document only; language, base currency, supported currencies, conversion rates, payment method, notifications, onboarding/tour fields |
| `users/{userId}/aiActions/{actionId}` | `firebase_ai_action_log_repo.dart` | Authenticated owner only | AI action ID, owner ID, type, input/output fields, success flag, quota, creation timestamp |
| `users/{userId}/categoryAliases/{aliasId}` | `firebase_category_alias_repo.dart` | Authenticated owner only | Alias ID, owner ID, display name, category ID, creation timestamp |

## Query Support

`firestore.indexes.json` currently supports:

- `expenses` ordered by `date` descending then `expenseId` descending.
- `recurringExpenses` ordered by active/archive state and next run date for
  migration compatibility.

When repository query patterns change, update this matrix, `firestore.rules`,
and `firestore.indexes.json` in the same change.

## Out Of Scope

Firebase Functions are intentionally not part of this plan. AI provider secrets
must remain in the Cloudflare Worker boundary, not in Flutter or Firestore.
