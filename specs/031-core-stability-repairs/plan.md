# Production Flutter Implementation Plan: Core Stability Repairs

**Branch**: `031-core-stability-repairs` | **Date**: 2026-06-01 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/031-core-stability-repairs/spec.md`

## Mandatory First Read And Skill Gate

Completed before writing this plan:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/skill-matcher.json`.
- Searched `.agents/skills/` and `.agent/skills/` for relevant skills.
- Loaded matching `SKILL.md` files and followed them.

**Skills used**:

- `speckit-specify`: created the repair specification.
- `speckit-plan`: created this implementation plan and design artifacts.
- `speckit-tasks`: creates the executable task list.
- `production-flutter-app-guardrails`: applies production app scope and local-only/AI/privacy rules.
- `dart-add-unit-test`: shapes local repository, wallet, budget, and worker/service tests.
- `flutter-add-widget-test`: shapes Settings, Home, notifications, and AI expense UI tests.
- `dart-run-static-analysis`: defines touched-file analyzer checks.

## Summary

This plan stabilizes the production app before further feature work. It fixes local data reliability, correct monthly budget selection, wallet balance trust, AI privacy boundaries, worker input guardrails, notification cancellation, Settings flows, honest Home data, AI expense entry usability, and release-readiness tracking.

The implementation order intentionally puts financial-data correctness and AI privacy before UI polish. A polished screen over unreliable saves or unsafe AI paths would hide the real risk instead of fixing it.

## Why

The app has already moved toward local-only financial data and explicit AI actions, but the latest review found several trust blockers:

- local reads can happen before Drift data finishes loading;
- writes can be treated as success before durable SQLite persistence;
- monthly budgets can be selected incorrectly;
- wallet balances can become misleading;
- legacy AI services can bypass the newer compact on-demand advice flow if reconnected;
- Home can show static financial claims that look real;
- Settings and notifications can behave differently from user expectations.

These are core correctness and privacy issues. They must be fixed before the app is presented as stable or production-ready.

## Expected Result

When complete:

- Existing local financial data is loaded before screens treat it as empty/default.
- Expense/settings/category/budget/wallet writes surface real save failures.
- Monthly budgets are always resolved by requested month and year.
- Wallet-linked expense behavior is explicitly decided and implemented without partial balance drift.
- Production AI advice uses only the explicit on-demand compact-summary flow.
- Legacy prompt-based advice is unavailable from production routes/providers.
- AI worker checks reject unsafe advice payloads and constrain parse/receipt requests.
- Disabling notifications cancels app-managed scheduled reminders.
- Settings can change language/currency directly without reopening onboarding.
- Home no longer displays fake/static financial claims as real data.
- AI expense entry is easier to use on narrow Arabic and English screens.
- Release readiness items are tracked separately and cannot be called production-ready by accident.

## Source References

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.agents/MANDATORY_RULES.md`
- `.agents/workflows/development.md`
- `.agents/skill-matcher.json`
- `packages/expense_repository/lib/src/local/drift/drift_store.dart`
- `packages/expense_repository/lib/src/local/local_repositories.dart`
- `packages/expense_repository/lib/src/local/local_store_interface.dart`
- `packages/expense_repository/lib/src/wallet_account_repo.dart`
- `packages/expense_repository/lib/src/models/budget.dart`
- `packages/expense_repository/lib/src/models/expense.dart`
- `packages/expense_repository/lib/src/models/wallet_account.dart`
- `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
- `lib/features/dashboard/presentation/home_dashboard_screen.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/features/onboarding/presentation/base_currency_screen.dart`
- `lib/features/onboarding/presentation/language_screen.dart`
- `lib/features/onboarding/presentation/notifications_screen.dart`
- `lib/features/ai/presentation/ai_advice_screen.dart`
- `lib/features/ai/services/advisor_service.dart`
- `lib/features/ai/services/ai_api_service.dart`
- `workers/ai-gateway/src/handlers/financialAdvice.ts`
- `workers/ai-gateway/src/handlers/parseExpense.ts`
- `workers/ai-gateway/src/handlers/receiptExtraction.ts`
- `workers/ai-gateway/src/ai/promptBuilder.ts`
- `lib/services/notifications/notification_service.dart`
- `lib/monetization/`
- `android/app/build.gradle.kts`

## Technical Context

**Language/Version**: Flutter / Dart app; TypeScript Cloudflare Worker for AI gateway.

**Primary Dependencies**: Flutter SDK, BLoC/Cubit, GoRouter, Drift/SQLite, local notifications, Firebase Auth only when needed for AI gateway identity/quota, Cloudflare Worker AI Gateway, purchase/ad SDKs only in release-readiness scope.

**Storage**: Drift/SQLite is the production financial-data store. Firestore, PostgreSQL, and VPS sync remain legacy/future infrastructure and are not default runtime storage for app-owned financial data.

**Testing**: focused Flutter/package tests, widget tests, worker tests, touched-file analyzer checks. Avoid full-project `flutter analyze` or full `flutter test` during normal feature execution.

**Target Platform**: Flutter mobile app with checks for 360x800, 375x812, 390x844, Arabic RTL, English LTR, and connected Android device checks when available.

**Project Type**: Production Flutter mobile app with local-only financial data and explicit server-side AI actions.

**Performance Goals**:

- startup reads do not show false empty state;
- save result reflects durable local persistence;
- Home/report/budget refreshes are immediate after save;
- AI advice request preparation uses compact summary and avoids unnecessary uploads;
- UI remains stable on narrow mobile viewports.

**Constraints**:

- No mobile secrets.
- No WebView/HTML rendering shortcuts.
- App-owned financial data remains local-only by default.
- AI calls must be explicit and gateway-backed.
- No fake financial data shown as real production data.
- Use existing theme, shared components, and local architecture patterns.

**Scale/Scope**: Owns targeted files in `lib/`, `packages/expense_repository/`, `workers/ai-gateway/`, `test/`, docs/specs, and release-readiness config notes. Does not add cloud financial-data sync.

## Required Plan Detail

Every implementation batch must include:

- why the batch exists;
- expected result;
- exact files owned;
- tests to write first where practical;
- likely bugs and fix strategy;
- focused verification commands;
- stop condition before the next batch.

## Constitution Check

*GATE: Pass before Phase 0 research and re-check after Phase 1 design.*

- [x] `AGENTS.md` and `.specify/memory/constitution.md` were read.
- [x] `.agents/MANDATORY_RULES.md` and `.agents/workflows/development.md` were read.
- [x] `.agents/skill-matcher.json` was checked.
- [x] Relevant installed skills were searched and loaded.
- [x] Matching skills are listed in the Mandatory First Read And Skill Gate.
- [x] Production Flutter app scope is preserved.
- [x] App-owned financial data remains local-only by default.
- [x] No Firestore/PostgreSQL/VPS financial-data write path is introduced.
- [x] AI calls remain explicit and gateway-backed.
- [x] No mobile secrets are planned.
- [x] No WebView or HTML rendering is planned.
- [x] Shared components and design tokens are planned for UI work.
- [x] No mock/demo/sample financial data is planned as real production data.
- [x] Responsive checks include 360x800, 375x812, and 390x844.
- [x] Arabic RTL and English LTR checks are planned.
- [x] Focused compile/test checks are listed for every implementation batch.

## Project Structure

### Documentation

```text
specs/031-core-stability-repairs/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
  tasks.md
```

### Source Ownership

```text
lib/
  app/
  core/
  features/
    ai/
    dashboard/
    expenses/
    onboarding/
    settings/
  services/notifications/
  monetization/
packages/expense_repository/
workers/ai-gateway/
test/
android/app/build.gradle.kts
```

**Structure Decision**: Use existing app, package, and worker folders. Do not introduce a new backend runtime or sync service. Repository changes stay inside `packages/expense_repository`; AI server changes stay inside `workers/ai-gateway`; UI changes reuse existing `lib/core/theme` and `lib/core/widgets`.

## Reuse Strategy

- Reuse existing `SettingsCubit`, expense blocs/cubits, budget bloc, wallet bloc, report cubit, and repository interfaces where possible.
- Reuse `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `GlassCard`, `GradientButton`, and existing shared form components.
- Do not add a new design language. Improve AI entry and Home honesty within current visual style.
- Prefer extending repository contracts only where needed for durable writes/readiness and wallet balance consistency.

## Data Strategy

- Production financial data stays local in Drift/SQLite.
- Existing Firebase/VPS code remains legacy/future code, not production local-only runtime.
- Tests may use fixtures and fake stores, but production UI must not display fake financial insight cards.
- AI advice sends compact summary only on explicit user action.
- AI parse text and receipt scan may send the user's current text/image because those are explicit AI actions, but they must not send stored history by default or log raw content.

## Possible Bugs And Fix Strategy

- **Startup empty state**: add readiness-aware local store behavior and tests that call reads immediately after store creation.
- **False save success**: make local writes await durable persistence and propagate errors to blocs/cubits.
- **Budget month drift**: filter by month/year and add multiple-month contract tests.
- **Wallet balance drift**: implement create/edit/delete balance adjustments or clearly mark wallet balances manual until full automatic behavior is done.
- **AI privacy regression**: isolate legacy prompt-based advice and add tests that only the on-demand compact flow reaches the gateway.
- **Worker oversized payloads**: add request validation tests and bounded parsing rules.
- **Notification mismatch**: add cancellation method and fake scheduler tests.
- **Settings reset**: replace onboarding route jumps with Settings-owned pickers and test language/currency independence.
- **Fake Home data**: remove static financial claims or bind to real data with empty states.
- **AI input overflow**: test narrow Arabic/English layouts and adjust input/saving layout without new visual language.

## Verification Plan

Use focused commands first. Flutter may require sandbox escalation because it writes to `C:\flutter\bin\cache\lockfile`.

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub <focused-test-file>
& 'C:\flutter\bin\flutter.bat' analyze <touched-files-and-tests>
```

Worker checks:

```powershell
cmd /c npm --prefix workers/ai-gateway test -- financialAdvice parseExpense receiptExtraction
cmd /c npm --prefix workers/ai-gateway run typecheck
```

Visual checks:

```text
360x800 English LTR
360x800 Arabic RTL
375x812 English LTR
375x812 Arabic RTL
390x844 English LTR
390x844 Arabic RTL
```

Privacy/local-only searches:

```powershell
rg -n "FirebaseFirestore|firebaseLegacy|migrationComparison|recentExpenses|merchant|receiptText|description" lib packages workers test
```

## Phase 0: Research

Research decisions are documented in [research.md](./research.md).

## Phase 1: Design

Design artifacts:

- [data-model.md](./data-model.md)
- [quickstart.md](./quickstart.md)
- [contracts/local-data-reliability-contract.md](./contracts/local-data-reliability-contract.md)
- [contracts/ai-privacy-contract.md](./contracts/ai-privacy-contract.md)
- [contracts/settings-notifications-contract.md](./contracts/settings-notifications-contract.md)
- [contracts/ui-honesty-contract.md](./contracts/ui-honesty-contract.md)
- [contracts/release-readiness-contract.md](./contracts/release-readiness-contract.md)
- [release-readiness.md](./release-readiness.md)

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |

## Phase Order

1. Local data reliability.
2. Budget and wallet correctness.
3. AI privacy cleanup.
4. Worker guardrails.
5. Settings and notifications.
6. Honest Home and AI expense UX.
7. Release readiness tracking.

## Stop Condition

Do not move to broad UI polish or release work until:

- local read/write reliability tests pass;
- budget month tests pass;
- wallet behavior decision is implemented or explicitly marked manual;
- AI advice cannot call legacy prompt paths from production screens;
- compact AI advice payload tests pass.
