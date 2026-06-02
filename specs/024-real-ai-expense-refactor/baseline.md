# Baseline: T001-T010 MVP Batch

Date: 2026-05-31

Scope: Baseline captured before implementing T001-T010 for the real AI expense refactor.

## Commands

```powershell
& 'C:\flutter\bin\flutter.bat' analyze
```

Outcome: Timed out after about 124 seconds before returning analyzer results. No secret values were printed.

```powershell
& 'C:\flutter\bin\flutter.bat' test
```

Outcome: Failed with existing test failures. The run reached `112` passing tests and `13` failing tests before completion.

Known failure categories:

- `test/blocs/recurring_bloc_test.dart`: casts expect loaded states while bloc emits initial/loading states.
- `test/features/auth/login_screen_test.dart`: missing `AuthBloc` provider in widget tests.
- `test/features/onboarding/splash_screen_test.dart`: missing `AuthBloc` provider and stale loading text expectation.
- Additional widget/provider failures were reported in the same run.

```powershell
rg -n "PROXY_API_KEY|X-API-Key|flutter_dotenv|dotenv\.env|dotenv\.load|/parseExpense|/getAdvice|AIza|GEMINI_API_KEY|GROQ_API_KEY" lib pubspec.yaml packages workers server --glob "!**/.env"
```

Outcome: Found production Flutter hits before this batch:

- `pubspec.yaml`: `flutter_dotenv`
- `lib/main.dart`: `flutter_dotenv`, `dotenv.load`
- `lib/features/ai/services/ai_api_service.dart`: `flutter_dotenv`, `PROXY_API_KEY`, `X-API-Key`, old `/parseExpense`, old `/getAdvice`
- `lib/features/expenses/presentation/add_expense_receipt_screen.dart`: old `/parseExpense` comment

Server and Worker hits reference server-side environment variables or tests and are not mobile secrets by themselves.

## Stop Condition

Baseline exists, summarizes current command outcomes, and does not include `.env` contents or secret values.
