# Quickstart: Real AI Expense Refactor Verification

## Before Implementation

1. Read:

   ```text
   specs/024-real-ai-expense-refactor/spec.md
   specs/024-real-ai-expense-refactor/plan.md
   specs/024-real-ai-expense-refactor/research.md
   specs/024-real-ai-expense-refactor/data-model.md
   specs/024-real-ai-expense-refactor/contracts/
   ```

2. Confirm current baseline:

   ```powershell
   & 'C:\flutter\bin\flutter.bat' analyze
   & 'C:\flutter\bin\flutter.bat' test
   ```

   Existing known baseline from review:

   - `flutter analyze`: 137 issues before refactor.
   - `flutter test`: failing tests around `RecurringExpenseBloc`, missing `AuthBloc` providers in widget tests, and splash/login expectations.

## Manual Verification Scenarios

### Scenario 1: New Account Has No Fake Data

1. Sign in with a clean test user.
2. Open dashboard, expenses, reports, budgets, wallets, goals, subscriptions, AI history, and settings.
3. Confirm no fake transactions, fake wallets, fake goals, fake subscriptions, or fake AI messages appear.
4. Confirm each empty screen has a useful next action.

### Scenario 2: AI Text Expense In Arabic

1. Ensure the test user has at least one wallet and one category.
2. Open AI expense entry.
3. Type:

   ```text
   دفعت 250 جنيه أكل امبارح
   ```

4. Confirm a draft appears.
5. Review amount, currency, category, date, wallet, and note.
6. Edit at least one field.
7. Save.
8. Confirm the expense appears in the expenses list and dashboard totals.

### Scenario 3: AI Failure Keeps User Input

1. Simulate gateway failure, quota exceeded, or offline mode.
2. Type an expense sentence.
3. Trigger parse.
4. Confirm the app keeps the typed text.
5. Confirm the app offers retry or manual entry.

### Scenario 4: Localization And RTL

1. Switch to Arabic.
2. Check primary screens at 360x800, 375x812, and 390x844.
3. Switch to English.
4. Repeat the same checks.
5. Confirm no mixed labels, clipped text, hidden buttons, or wrong chevrons.

## Automated Verification

Run:

```powershell
& 'C:\flutter\bin\flutter.bat' pub get
& 'C:\flutter\bin\flutter.bat' gen-l10n
& 'C:\flutter\bin\flutter.bat' analyze
& 'C:\flutter\bin\flutter.bat' test
```

When AI gateway code changes:

```powershell
cmd /c npm --prefix workers/ai-gateway test
```

When server sync/account behavior changes:

```powershell
cmd /c npm --prefix server test
```

Security checks:

```powershell
rg -n "PROXY_API_KEY|X-API-Key|flutter_dotenv|dotenv\.env|/parseExpense|/getAdvice|AIza|GEMINI_API_KEY|GROQ_API_KEY" lib pubspec.yaml packages workers server --glob "!**/.env"
rg -n "MockData|MockAiService|placeholder|fake|stub" lib packages/expense_repository/lib
```

## Done

The feature is ready when:

- No production Flutter screen uses mock financial data.
- AI text expense flow uses authenticated gateway calls.
- AI drafts require user confirmation before save.
- Arabic/English locale behavior works.
- Narrow mobile viewports have no major layout break.
- Analyzer/tests are passing or remaining failures are documented and accepted.
