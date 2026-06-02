# Contract: Smart Add Entry

## Home Screen

- Shows exactly one primary add button.
- Does not show a separate small AI floating button.
- Top-bar AI icon remains for assistant/help only.
- Add button opens an add-choice sheet.

## Add Choice Sheet

Choices:

1. AI Text Expense
2. Quick Add
3. Full Add or Manual Add if available
4. Receipt only when real behavior exists, otherwise disabled/unavailable

Each choice must include:

- icon
- title
- short subtitle
- availability state
- route/action

## Navigation

- AI text routes to `AppRoutes.expensesNewText`.
- Quick add routes to `AppRoutes.expensesNewQuick`.
- Receipt routes to `AppRoutes.expensesNewReceipt` only if real receipt flow is enabled.
- New navigation must use `AppRoutes` constants or route helper methods.

## Empty/Unavailable State

- Disabled options explain why.
- Unavailable receipt must not pretend to parse real receipts.

## RTL/LTR

- Sheet layout respects current text direction.
- Icons and labels do not overlap.
- Arabic and English labels fit narrow screens.

## Test Contract

- `test/features/dashboard/smart_add_sheet_test.dart` covers sheet rendering, disabled receipt, dismissal, Arabic RTL, and English LTR.
- `test/features/dashboard/home_dashboard_test.dart` covers one primary add button and separate top-bar assistant behavior.
