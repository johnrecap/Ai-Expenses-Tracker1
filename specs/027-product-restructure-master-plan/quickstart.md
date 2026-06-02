# Quickstart: Product Restructure Master Plan

## Purpose

Use this checklist before assigning or executing any restructuring phase.

## Read First

```text
AGENTS.md
.specify/memory/constitution.md
.agents/workflows/development.md
.agents/MANDATORY_RULES.md
.agents/skill-matcher.json
specs/027-product-restructure-master-plan/spec.md
specs/027-product-restructure-master-plan/plan.md
specs/027-product-restructure-master-plan/tasks.md
```

## Current Completed Inputs

- `specs/024-real-ai-expense-refactor/`: AI security foundation partially implemented through T010.
- `specs/025-smart-add-entry/`: Smart Add Entry completed.
- `specs/026-startup-onboarding-settings/`: Startup/onboarding/settings plan exists; implementation may be in progress.

## Global Rules

- Do not add mock data to production app screens.
- Do not put API keys in Flutter/mobile code.
- AI calls must go through Cloudflare AI Gateway.
- Keep Arabic/English and RTL/LTR in scope.
- Use scoped analyzer/tests for the phase.
- Do not run broad cleanup unless the task explicitly owns it.

## Suggested Phase Verification

### Startup/Localization

```powershell
& 'C:\flutter\bin\flutter.bat' gen-l10n
& 'C:\flutter\bin\flutter.bat' analyze lib/app lib/features/onboarding lib/features/settings packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart test/features/onboarding test/features/settings
& 'C:\flutter\bin\flutter.bat' test test/features/onboarding
```

### Expense Entry

```powershell
& 'C:\flutter\bin\flutter.bat' analyze lib/features/dashboard lib/features/expenses lib/features/ai test/features/dashboard test/features/expenses test/features/ai
& 'C:\flutter\bin\flutter.bat' test test/features/dashboard test/features/expenses test/features/ai
```

### Reports/Budgets

```powershell
& 'C:\flutter\bin\flutter.bat' analyze lib/features/reports lib/features/budgets lib/features/goals lib/features/recurring_expenses lib/features/subscriptions test/features/reports test/features/budgets test/blocs
& 'C:\flutter\bin\flutter.bat' test test/features/reports test/features/budgets test/blocs/report_cubit_test.dart
```

### Backend/Sync/Services

Use focused package/server/worker checks. Do not treat unrelated Flutter analyzer failures as blockers unless touched.

## Manual Review Flow

1. Install/open app.
2. Create account or sign in.
3. Complete language, currency, notification choices.
4. Add quick expense.
5. Add AI text expense.
6. Open expense list and filter.
7. Edit the expense and confirm wallet/currency/source remain.
8. Open dashboard and reports for current month.
9. Open budgets, goals, wallets, subscriptions.
10. Open settings, app lock, profile, premium.
11. Switch language and verify direction.
12. Confirm no fake advice/history/premium/receipt behavior is presented as real.
