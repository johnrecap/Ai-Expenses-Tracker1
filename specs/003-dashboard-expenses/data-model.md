# Data Model: Dashboard And Expenses

## DashboardMetric

- `id`
- `label`
- `valueText`
- `trendText`
- `iconName`
- `accentToken`

## TransactionSection

- `id`
- `dateLabel`
- `expenseIds`

## ExpenseFilterState

- `query`
- `selectedCategoryIds`
- `selectedWalletIds`
- `dateRangeLabel`
- `minAmount`
- `maxAmount`

## Existing Foundation Entities Used

- `MockExpense`
- `MockCategory`
- `MockWallet`
- `MockAiInsight`

## Validation Rules

- Filters do not persist beyond local screen state.
- Unknown category or wallet IDs should fall back to neutral UI instead of crashing.
- Amount values must be formatted in the UI and constrained at 360px.
