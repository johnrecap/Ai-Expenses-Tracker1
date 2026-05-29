# Data Model: Add And Edit Expense

## ExpenseDraft

- `amountText`
- `merchant`
- `categoryId`
- `walletId`
- `dateLabel`
- `notes`
- `mode`

## AddExpenseMode

- `quick`
- `text`
- `receipt`

## MockParsedExpense

- `merchant`
- `amount`
- `categoryId`
- `dateLabel`
- `confidenceLabel`
- `source`: text or receipt

## Validation Rules

- Draft state is local and may reset when route is left.
- Edit screen copies from mock data and does not mutate global mock collections permanently.
- Parse/upload buttons only toggle local suggested state.
- Unknown expense IDs must show safe fallback or not-found.
