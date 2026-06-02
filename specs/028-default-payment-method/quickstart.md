# Quickstart: Default Payment Method

## Implementation Order

1. Inspect existing payment method and settings code.
2. Add or complete `SettingsCubit` action for default payment method.
3. Add the default payment method selector to Settings using current theme/components.
4. Add payment method selection to Quick Add.
5. Update Quick Add save logic to use selected method, settings default, then Cash fallback.
6. Update AI draft mapping to detect explicit method, then settings default, then Cash fallback.
7. Ensure wallet selection remains optional in quick and AI flows.
8. Verify Firestore/local repository contract tests for `defaultPaymentMethod`, `paymentMethod`, and optional wallet fields.

## Focused Verification

Use focused checks only:

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' format lib\features\settings\settings_cubit\settings_cubit.dart lib\features\settings\presentation\settings_screen.dart lib\features\expenses\presentation\add_expense_quick_screen.dart lib\features\expenses\presentation\add_expense_ai_text_screen.dart lib\features\expenses\domain\ai_expense_draft_mapper.dart
& 'C:\flutter\bin\flutter.bat' analyze lib\features\settings\settings_cubit\settings_cubit.dart lib\features\settings\presentation\settings_screen.dart lib\features\expenses\presentation\add_expense_quick_screen.dart lib\features\expenses\presentation\add_expense_ai_text_screen.dart lib\features\expenses\domain\ai_expense_draft_mapper.dart test\features\settings\settings_screen_actions_test.dart test\features\expenses\add_expense_quick_screen_test.dart test\features\expenses\add_expense_ai_text_screen_test.dart test\features\expenses\ai_expense_draft_mapper_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\settings\settings_screen_actions_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_quick_screen_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_screen_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_draft_mapper_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\packages\expense_repository\settings_wallet_budget_contract_test.dart
```

## Manual Checks

- Settings shows Default Payment Method.
- Changing default to Visa/Card persists after leaving and reopening Settings.
- Quick Add with no wallet and no explicit method saves using default.
- Quick Add with Wallet payment method and no wallet saves successfully.
- Quick Add with selected wallet preserves wallet id/name.
- AI text "دفعت 200 كاش أكل" maps to Cash.
- AI text "اشتريت بفيزا 500" maps to Visa/Card.
- AI text "حولت 300 انستاباي" maps to Bank Transfer.
- AI text without payment words maps to settings default.
- Arabic RTL and English LTR do not clip labels on 360x800, 375x812, and 390x844.

## Stop Condition

Stop when focused tests pass and manual review confirms that wallet creation is not required before saving quick or AI expenses.
