# Contract: Home Honesty And AI Expense UX

## Scope

Owned files:

- `lib/features/dashboard/presentation/home_dashboard_screen.dart`
- `lib/features/dashboard/presentation/widgets/`
- `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
- `lib/core/widgets/`
- `lib/core/theme/`
- focused widget tests

## Home Guarantees

1. Home does not show static financial claims as real user data.
2. Financial insight cards are real, loading, empty, or unavailable.
3. Empty states provide a clear next action when appropriate.

## AI Expense UX Guarantees

1. Text stays inside the AI input field on narrow Arabic and English screens.
2. Save appears after the user can review required fields, or stays disabled until required fields are valid.
3. Missing fields are clear near the review fields.
4. Keyboard and narrow viewport states do not hide critical actions permanently.

## Acceptance Tests

- Home without supporting data does not show static trend/bills copy.
- AI expense entry at 360px width has no overflow in Arabic or English.
- Save cannot complete until required fields are valid.
