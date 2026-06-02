# Quickstart: AI Expense Entry Polish

## Implementation Order

1. Inspect current theme and shared widgets before UI edits.
2. Add focused tests for AI input padding/keyboard behavior where practical.
3. Refactor `AiExpenseParsePanel` so the text field has real internal padding and a clear input surface.
4. Make keyboard done, Parse, and Save clear focus.
5. Move the AI save button in `AddExpenseAiTextScreen` so it appears under the AI panel/review area.
6. Keep manual category/payment/details controls available below the AI area for corrections.
7. Add explicit refresh after successful AI save for expense list, reports, and current budget.
8. Run focused format, analyzer, and tests.
9. Check the screen on the connected phone or simulator at small-screen equivalents.

## Focused Verification

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' format lib\features\expenses\presentation\widgets\ai_expense_parse_panel.dart lib\features\expenses\presentation\add_expense_ai_text_screen.dart lib\features\expenses\presentation\cubit\ai_expense_entry_cubit.dart test\features\expenses\ai_expense_parse_panel_user_states_test.dart test\features\expenses\add_expense_ai_text_screen_test.dart test\features\expenses\ai_expense_entry_cubit_test.dart
& 'C:\flutter\bin\flutter.bat' analyze lib\features\expenses\presentation\widgets\ai_expense_parse_panel.dart lib\features\expenses\presentation\add_expense_ai_text_screen.dart lib\features\expenses\presentation\cubit\ai_expense_entry_cubit.dart test\features\expenses\ai_expense_parse_panel_user_states_test.dart test\features\expenses\add_expense_ai_text_screen_test.dart test\features\expenses\ai_expense_entry_cubit_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_parse_panel_user_states_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_screen_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_entry_cubit_test.dart
```

## Manual Checks

- Type: `صرفت 250 جنيه على غدا كاش`.
- Press keyboard done.
- Confirm keyboard closes.
- Press Parse.
- Confirm keyboard remains closed while parsing.
- Confirm the AI suggestion appears directly above Save.
- Confirm Save is visible without scrolling to the bottom of manual fields.
- Save the expense.
- Confirm the previous/home/list/report data updates without closing the app.
- Repeat with no wallet available.
- Check English LTR and Arabic RTL at 360x800, 375x812, and 390x844.

## Stop Condition

Stop when the AI input looks correct, keyboard behavior is fixed, save placement is corrected, immediate refresh works, and focused checks pass.
