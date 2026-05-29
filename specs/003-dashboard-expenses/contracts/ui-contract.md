# UI Contract: Dashboard And Expenses

## Routes

- `/home`: dashboard screen.
- `/expenses`: grouped expense list.
- `/expenses/filters`: bottom sheet path or modal trigger for filter UI.

## Component Contracts

### TransactionTile

- Input: `MockExpense`, resolved category, resolved wallet, tap callback.
- Must show merchant, category, date or status, amount, and icon.
- Must not overflow at 360px.
- Must use `TextAlign.start` and directional spacing.

### TransactionSection

- Input: date label and list of transactions.
- Renders repeated `TransactionTile` from data.

### ExpenseFiltersSheet

- Native bottom sheet using `GlassBottomSheet`.
- Contains local search, category chips, range/date controls, reset/apply buttons.
- Max height constrained with scrollable content.

## Interaction Contracts

- Search and filter controls may update local visible data only.
- Transaction tap may route to edit placeholder or future route.
- Filter apply/reset does not persist settings.
