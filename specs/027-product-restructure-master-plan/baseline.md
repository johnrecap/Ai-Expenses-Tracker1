# Baseline: Product Restructure Master Plan

Date: 2026-05-31

## Scope

This baseline is the controller source of truth for executing plan `027-product-restructure-master-plan`.
It is intentionally limited to the Flutter app and app-owned implementation paths:

- `lib/`
- `packages/expense_repository/lib/`
- `firestore.rules`
- `server/` and `workers/ai-gateway/` only when a later task explicitly owns them
- focused tests under `test/`

Do not run broad repository analysis for normal feature work. Use scoped reads, focused tests, and touched-file analyzer commands.

## Spec Kit State

- `specs/024-real-ai-expense-refactor/`
  - Completed: `T001-T010`.
  - Still open: `T011-T041`.
  - Current known result: AI gateway models/client/cubit/mapper foundation exists, but production AI screens still have old or mock paths.

- `specs/025-smart-add-entry/`
  - Completed: `T001-T014`.
  - Current known result: Home now has one Smart Add entry, AI text and Quick Add choices, receipt disabled/unavailable from the home sheet, and focused dashboard tests were reported passing by the worker.

- `specs/026-startup-onboarding-settings/`
  - Completed: `T001-T017`.
  - Still open: `T018`.
  - Current known result: startup/onboarding/settings/notification implementation is mostly done. The controller fixed the offscreen currency test by using `ensureVisible` and verified language + currency focused tests.

- `specs/027-product-restructure-master-plan/`
  - Active controller spec.
  - Phase 0 owns this baseline and the no-mock audit.

## Verification State

Known passing focused check from the controller:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\onboarding\language_screen_test.dart test\features\onboarding\base_currency_screen_test.dart
```

Result: 8 tests passed.

Known worker-reported passing checks:

- `test/features/ai/ai_gateway_client_test.dart`
- `test/features/expenses/ai_expense_draft_mapper_test.dart`
- `test/features/expenses/ai_expense_entry_cubit_test.dart`
- `test/features/dashboard/smart_add_sheet_test.dart`
- `test/features/dashboard/home_dashboard_test.dart`
- focused analyzer on files touched by `024` and `025`

Known broad-check status:

- Full-project analyzer/test checks are not release-ready yet and have unrelated existing failures.
- Do not make feature workers rediscover these failures.
- Full-project checks are reserved for `T038` in this plan.

Environment note:

- Flutter commands may require running outside the sandbox because Flutter writes to `C:\flutter\bin\cache\lockfile`.
- A sandbox lockfile failure is an environment issue, not a code failure.
- Do not retry the same hanging/failing Flutter command more than twice.

Spec Kit prerequisite note:

- `.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` failed because the current branch is `main`, while the Spec Kit script expects a feature branch name.
- The plan files already exist and the checklist passes, so implementation can continue from `tasks.md`.
- Checklists: `requirements.md` has 16 total, 16 complete, 0 incomplete.
- `.specify/extensions.yml` is not present, so there are no before/after implement hooks to run.

## Current Dirty Tree

The workspace is intentionally dirty because previous agents and the controller have already changed files. Do not revert unrelated files.

High-level changed areas include:

- Agent rules and workflows.
- Specs `024`, `025`, `026`, `027`.
- AI gateway/data/cubit/mapper files.
- Smart Add dashboard files and tests.
- Startup/onboarding/settings/notifications files and tests.
- Generated localization and plugin registrant files.

Any worker must inspect the exact files it owns before editing and preserve existing user/agent changes.

## Active Phase Blockers

- `026` still needs `T018` focused verification before Phase 1 can be fully closed.
- AI entry still needs `024` tasks from `T011` onward.
- Production mock/fake output remains in AI advice/history/assistant, receipt upload panel, premium purchase, some hardcoded KWD screens, and local stub repositories. See `no-mock-audit.md`.
- Broad app verification is intentionally deferred until plan `027` Phase 9.

## Controller Rules For New Agents

Every agent prompt must include:

- Exact task ids.
- Exact owned files/folders.
- Exact files/folders not to touch.
- No broad repo analysis.
- No full-project `flutter analyze` or full `flutter test` during feature tasks.
- Focused verification ladder.
- Two-retry limit for failing/hanging commands.
- Required final status format from `PORTABLE_AGENT_RULES.md`.

