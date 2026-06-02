# Implementation Plan: Local Only With AI On Demand

**Branch**: `030-local-only-ai-on-demand` | **Date**: 2026-05-31 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/030-local-only-ai-on-demand/spec.md`

## Mandatory First Read And Skill Gate

Completed before writing this plan:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/skill-matcher.json`.
- Loaded matching Spec Kit skills.

**Skills used**:

- `speckit-specify`: turned Mohamed's local-only decision into a product spec.
- `speckit-plan`: produced implementation structure, contracts, data model, and verification plan.
- `speckit-tasks`: produced dependency-ordered tasks that another agent can execute.

## Summary

Move app-owned financial data to a local-only product mode. Expenses, categories, wallets, budgets, goals, subscriptions, settings, and AI history stay on the phone. Firestore and PostgreSQL/VPS are not used for production app data in this mode.

The server remains only for explicit AI actions, ads, purchase checks, and AI quota/abuse protection. AI advice must send a tiny precomputed summary instead of uploading raw transactions, so the user sees local advice immediately and the AI request starts quickly.

## Why

Mohamed wants a smaller app that does not need monthly backend maintenance. Local-only storage removes sync complexity, server uptime pressure, cloud database costs, and privacy risk. AI still remains useful because the app can calculate local tips instantly and send a compact summary only when the user asks for richer advice.

This also fixes the waiting problem: the app should not gather and upload a big expense history after the user taps the AI button.

## Expected Result

When implementation is complete:

- The production default data mode is local-only.
- Core tracking works offline without login.
- Firestore/PostgreSQL financial-data repositories are not instantiated in local-only mode.
- Advice screen shows local tips immediately.
- AI advice is requested only after the user taps an AI action.
- AI payload is a compact summary, not raw expenses.
- Normal AI payload stays below 10 KB; heavy local datasets stay below 25 KB.
- Summary preparation is precomputed/cached so request preparation normally completes under 150 ms.
- AI timeout/failure keeps local advice visible with retry.
- Premium/ads state works without storing financial app data on a backend.
- Settings/onboarding wording clearly says financial data is stored on this device.

## Source References

- `specs/030-local-only-ai-on-demand/spec.md`
- `specs/030-local-only-ai-on-demand/research.md`
- `specs/030-local-only-ai-on-demand/data-model.md`
- `specs/030-local-only-ai-on-demand/contracts/local-only-data-contract.md`
- `specs/030-local-only-ai-on-demand/contracts/ai-advice-speed-contract.md`
- `specs/030-local-only-ai-on-demand/contracts/monetization-contract.md`
- `packages/expense_repository/lib/src/repository_runtime_mode.dart`
- `packages/expense_repository/lib/src/repository_factory.dart`
- `packages/expense_repository/lib/src/local/drift/drift_store.dart`
- `lib/app/app.dart`
- `lib/features/ai/presentation/ai_advice_screen.dart`
- `lib/features/ai/services/advisor_service.dart`
- `lib/features/ai/data/ai_gateway_client.dart`
- `lib/features/ai/data/ai_gateway_models.dart`
- `workers/ai-gateway/src/handlers/financialAdvice.ts`
- `workers/ai-gateway/src/ai/providerTypes.ts`
- `workers/ai-gateway/src/ai/promptBuilder.ts`
- `lib/monetization/`
- `lib/features/settings/presentation/settings_screen.dart`

## Technical Context

**Language/Version**: Flutter / Dart app, TypeScript Cloudflare Worker for AI gateway.

**Primary Dependencies**: Flutter, BLoC/Cubit, GoRouter, Drift/SQLite local repository store, Cloudflare Worker AI gateway, Firebase Auth only if retained for AI gateway identity/quota protection.

**Storage**: Drift/SQLite local store is the production financial-data store. Firestore and VPS/PostgreSQL are disabled for product data in this mode.

**Testing**: Focused Flutter tests, focused analyzer on touched files, Worker unit tests for `/aiAdvice` payload validation.

**Target Platform**: Android-first mobile app with Arabic/English and RTL/LTR.

**Project Type**: Production Flutter app with local-only data and on-demand AI gateway.

**Performance Goals**:

- Core local screens respond without network.
- Local advice appears in under 300 ms for typical local data.
- Advice summary read/build before request is under 150 ms for typical data.
- AI request body stays below 10 KB for normal users and below 25 KB for heavy users.
- AI gateway request has a user-facing timeout around 8 seconds and never clears local advice while waiting.

**Constraints**:

- No AI provider key in Flutter/mobile code.
- No background financial-data upload.
- No Firestore/PostgreSQL writes for app-owned financial data in local-only mode.
- No mock data shown as real production data.
- Ads cannot block expense save or active AI typing.
- Premium cannot require storing financial data on a custom backend.

**Scale/Scope**:

- Scope includes financial-data ownership, app boot, advice summary, AI advice request path, premium/ads gating, user wording, and verification.
- Scope excludes export/import/cloud backup because Mohamed explicitly removed export/import for now.
- Scope excludes deleting legacy Firestore/VPS code in the first pass unless a task owns that removal safely.

## Constitution Check

**Gate status**: Needs documented architecture amendment before implementation.

The current constitution says the app is production-grade with Firebase/Firestore and VPS backend support. Mohamed has now explicitly changed the direction for app-owned financial data to local-only. This plan treats that as a deliberate architecture change.

Implementation must:

- Update project docs/rules to say local-only is the production app-data default.
- Keep AI gateway server-side for keys and quotas.
- Keep Firebase/Auth only if used as silent AI identity/quota protection, not as app-data storage.
- Preserve no-secrets-in-mobile rule.
- Use focused verification and stop at unrelated failures.

## Project Structure

### Documentation

```text
specs/030-local-only-ai-on-demand/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
    local-only-data-contract.md
    ai-advice-speed-contract.md
    monetization-contract.md
  tasks.md
```

### Source Code Areas

```text
packages/expense_repository/lib/src/
  repository_runtime_mode.dart
  repository_factory.dart
  local/
  local/drift/
  firebase/
  api/

lib/
  app/app.dart
  features/ai/
  features/settings/
  monetization/
  services/analytics/

workers/ai-gateway/src/
  handlers/financialAdvice.ts
  ai/providerTypes.ts
  ai/promptBuilder.ts
  quota/

test/
workers/ai-gateway/test/
```

**Structure Decision**: Do not create a new backend for app data. Reuse the existing local repository store and add a clear local-only runtime/default. Add AI advice summary services under the existing AI feature area.

## Data Ownership Plan

1. Add a clear `localOnly` runtime mode.
2. Make `localOnly` the production default.
3. Create local repository bundle from `DriftLocalRepositoryStore`.
4. Use a stable local device/user scope for local data when no signed-in account exists.
5. Keep Firebase repositories available only behind explicit legacy/comparison modes.
6. Add tests that fail if local-only mode builds Firebase/VPS financial repositories.
7. Hide or rewrite UI that implies cloud sync/backup.

## AI Speed Plan

The AI flow must not wait to scan all expenses after the user taps the button.

1. Build `AdviceSummary` from local expenses, budgets, wallets, goals, and subscriptions.
2. Cache the latest summary and update it after relevant local data changes.
3. Generate deterministic local tips from the cached summary.
4. Render local tips as soon as the advice screen opens.
5. On Ask AI, send only the cached summary with locale/currency/period.
6. Cap arrays: top categories max 5, trend flags max 5, no full row lists by default.
7. Hash the summary and reuse recent AI advice when the summary has not changed.
8. Add payload-size tests and request-preparation timing tests.
9. Add short timeout and keep local advice visible during loading/failure.

## Premium And Ads Plan

1. Store premium entitlement snapshot locally.
2. Use store purchase/restore checks as the entitlement source.
3. Hide ads for premium users.
4. Keep local advice unlimited.
5. Gate premium AI features and higher AI quota locally for UX.
6. Let AI gateway enforce operational quota/abuse limits without storing full financial data.
7. Never show ads while user is saving an expense, typing in AI entry, or confirming a draft.

## Possible Bugs And Fix Strategy

- **App stuck on login**: Make local-only app boot create local repositories before cloud auth. Verify startup with no Firebase user.
- **Accidental Firestore writes**: Add factory tests and source search. Local-only mode must not instantiate Firebase financial repositories.
- **Local data scoped to changing user id**: Use one stable local scope for offline/local-only data and test app restart persistence.
- **Slow AI request preparation**: Precompute summary after changes. Add timing test and payload-size test.
- **Huge AI payload**: Cap categories/trends/subscription details and reject raw transaction lists by default.
- **AI failure clears advice**: Keep local tips and last cached AI advice separate from loading/error state.
- **Premium state unavailable**: Fall back to safe local entitlement state and show restore path.
- **Ads block core tracking**: Centralize ad policy and add tests for no ad during save/typing.
- **Arabic text issues**: Use app localization and RTL checks for local-only wording and advice UI.
- **Constitution/doc drift**: Update long-lived project rules once implementation is approved.

## Verification Plan

Use focused commands. Do not run full-project checks for every small task.

Flutter focused tests:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\packages\expense_repository\local_only_repository_factory_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\advice_summary_builder_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\ai_advice_payload_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\ai_advice_screen_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\local_entitlement_ads_test.dart
```

Scoped analyzer:

```powershell
& 'C:\flutter\bin\flutter.bat' analyze <touched lib files> <touched test files>
```

Worker focused tests:

```powershell
cmd /c npm --prefix workers/ai-gateway test -- financialAdvice
```

Guardrail searches:

```powershell
rg -n "FirebaseExpenseRepo|FirebaseCategoryRepository|FirebaseBudgetRepository|FirebaseSettingsRepository|FirebaseWalletAccountRepository|Vps|vpsLocalFirst|Firestore|FirebaseFirestore" lib packages/expense_repository
rg -n "recentExpenses|description|merchant|rawText|receipt|transactions|expenses" lib/features/ai workers/ai-gateway/src/handlers/financialAdvice.ts workers/ai-gateway/src/ai/promptBuilder.ts
```

Manual checks:

- Airplane mode: add/edit/delete/list expense.
- Airplane mode: reports, budgets, wallets, goals, subscriptions load from local data.
- Advice screen: local tips appear immediately.
- Ask AI online: only compact summary is sent.
- AI timeout/failure: local advice stays visible.
- Premium state: ads hidden when premium, ads non-blocking when free.
- Settings: local-only wording is clear in Arabic and English.

## Phase 0: Research

Completed in [research.md](./research.md).

Key decisions:

- Local-only is the primary production data mode.
- AI is on-demand only.
- AI receives compact summary only.
- Summary is precomputed/cached for speed.
- Local advice appears before AI.
- Premium/ads do not require a financial-data backend.
- Firestore/PostgreSQL remain disabled for product data in local-only mode.

## Phase 1: Design

Completed in:

- [data-model.md](./data-model.md)
- [contracts/local-only-data-contract.md](./contracts/local-only-data-contract.md)
- [contracts/ai-advice-speed-contract.md](./contracts/ai-advice-speed-contract.md)
- [contracts/monetization-contract.md](./contracts/monetization-contract.md)
- [quickstart.md](./quickstart.md)

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Architecture changes from cloud-backed to local-only product data | Mohamed explicitly requested local-only to avoid backend maintenance | Keeping Firestore/PostgreSQL would keep the maintenance and privacy burden he wants to remove |
| Firebase/Auth may remain only for AI gateway identity | Current gateway quota uses Firebase bearer identity | Removing all identity immediately would require a separate gateway auth redesign before AI can stay protected |

## Stop Condition

This plan is ready for implementation when Mohamed approves the architecture direction. Implementation should stop when:

- Local-only is default.
- No financial app data writes to Firestore/PostgreSQL in local-only mode.
- Local advice renders instantly.
- AI sends only compact summary after explicit user action.
- Premium/ads work without a financial-data backend.
- Focused tests and scoped analyzer pass, or unrelated environment failures are documented.
