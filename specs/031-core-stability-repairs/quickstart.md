# Quickstart: Core Stability Repairs

## Purpose

Use this quickstart to execute the repair plan without broad repo analysis or unnecessary full-project commands.

## Required First Read

1. `AGENTS.md`
2. `.specify/memory/constitution.md`
3. `.agents/MANDATORY_RULES.md`
4. `.agents/workflows/development.md`
5. `.agents/skill-matcher.json`
6. `specs/031-core-stability-repairs/spec.md`
7. `specs/031-core-stability-repairs/plan.md`
8. `specs/031-core-stability-repairs/tasks.md`

## Execution Order

1. Local data reliability.
2. Budget month correctness.
3. Wallet behavior.
4. AI privacy cleanup in Flutter.
5. AI worker guardrails/tests.
6. Notifications cancellation.
7. Settings language/currency.
8. Home honest data.
9. AI expense UX.
10. Release readiness tracking.

Do not start UI polish before local data reliability, budget correctness, wallet decision, and AI privacy cleanup pass their focused tests.

## Focused Verification Ladder

Use this ladder for each task:

1. Run the single focused test that proves the behavior.
2. Run analyzer only on touched files and directly touched tests.
3. Run a wider folder test only if the task owns that folder.
4. Stop at unrelated failures and report them separately.

Flutter commands may need approval/escalation because Flutter writes to `C:\flutter\bin\cache\lockfile`.

## Example Commands

Local repository checks:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub packages\expense_repository\test\local_drift_reliability_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\packages\expense_repository\local_budget_wallet_contract_test.dart
```

AI privacy checks:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\ai_advice_payload_test.dart test\features\ai\ai_advice_screen_test.dart
cmd /c npm --prefix workers/ai-gateway test -- financialAdvice parseExpense receiptExtraction
```

Settings and notifications checks:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\settings\settings_screen_actions_test.dart test\services\notifications\notification_service_test.dart
```

Home and AI expense UI checks:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\dashboard\home_dashboard_test.dart test\features\expenses\add_expense_ai_text_screen_test.dart
```

Analyzer on touched files:

```powershell
& 'C:\flutter\bin\flutter.bat' analyze <touched-files-and-direct-tests>
```

## Manual Checks

- Open Home with no expenses/subscriptions and confirm no fake financial trend or fake upcoming bill count appears.
- Add an expense with AI text on a narrow viewport and confirm Save is clear and reachable.
- Change language and currency independently from Settings.
- Disable notifications and confirm scheduled reminders are cancelled.
- Confirm no release is marked ready before signing, privacy policy, ads/purchases, and consent are complete.

## Stop Conditions

Stop and report `BLOCKED` if:

- local write failure cannot be surfaced without changing repository contracts broadly;
- wallet automatic balance cannot be made safe for edit/delete;
- legacy AI services cannot be isolated without breaking active routes;
- a focused Flutter command hangs twice;
- a needed device/emulator is unavailable for final mobile verification.
