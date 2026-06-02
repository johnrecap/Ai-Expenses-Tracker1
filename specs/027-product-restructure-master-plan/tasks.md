# Tasks: Product Restructure Master Plan

**Input**: Design documents from `specs/027-product-restructure-master-plan/`

**Prerequisites**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md), [contracts/](contracts/)

**Project Type**: Production Flutter finance app restructuring

## Mandatory First Read And Skill Gate

Before executing tasks, the agent MUST read:

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.agents/workflows/development.md`
- `.agents/MANDATORY_RULES.md`
- `.agents/skill-matcher.json`
- This plan and relevant phase specs

**Required skills**: `speckit-implement`, relevant Flutter/Dart/backend/security/localization skills for the owned phase.

**Analyzer rule**: Do not run full-project `flutter analyze` during feature phases. Run scoped analyzer/tests for touched app paths, package paths, worker/server paths, and focused tests. Full analyzer is a final release-readiness task only.

## Phase 0: Control Tower And Baseline

- [X] T001 [Setup] Create restructuring baseline in `specs/027-product-restructure-master-plan/baseline.md`
  - Why: Agents need one current source of truth for completed `024`, `025`, and current `026` status.
  - Expected result: Baseline lists completed tasks, known failures, active specs, and current no-mock/security concerns.
  - Inputs: `specs/024-real-ai-expense-refactor/tasks.md`, `specs/025-smart-add-entry/tasks.md`, `specs/026-startup-onboarding-settings/tasks.md`, agent reports.
  - Implementation notes: Do not edit app code. Do not paste secrets.
  - Possible bugs: Baseline mixes unrelated full-project analyzer failures with phase blockers.
  - Fix strategy: Split "phase blockers" from "known unrelated failures".
  - Verification: Baseline file exists and every active spec is classified.
  - Stop condition: New workers can start without redoing the full audit.

- [X] T002 [Setup] Create no-mock production audit in `specs/027-product-restructure-master-plan/no-mock-audit.md`
  - Why: Mohamed explicitly requires no mock data in the app.
  - Expected result: Audit lists mock/demo/sample/fake production hits and marks remove, keep-test-only, or honest-unavailable.
  - Inputs: `contracts/real-data-contract.md`, `lib/`, `packages/expense_repository/lib/`.
  - Implementation notes: Use `rg` searches but classify manually; do not delete in this task.
  - Possible bugs: False positives in tests/docs or missed fake states named differently.
  - Fix strategy: Search for `MockAiService`, `demo`, `sample`, `placeholder`, `not available yet`, `Future.delayed`.
  - Verification: Audit includes AI, premium, budgets, reports, settings, and services.
  - Stop condition: Every known fake production area has an owner phase.

## Phase 1: Startup, Onboarding, Settings, Language

- [X] T003 [US1] Finish startup routing tasks in `specs/026-startup-onboarding-settings/tasks.md`
  - Why: New users currently may skip setup and enter home too early.
  - Expected result: `T003-T005` in spec `026` are implemented or updated to current code state.
  - Inputs: `specs/026-startup-onboarding-settings/`, `lib/features/onboarding/presentation/splash_screen.dart`, `lib/app/app.dart`, `lib/app/router.dart`.
  - Implementation notes: Reuse `026`; do not create a second startup plan.
  - Possible bugs: Provider scope errors, route loops, splash timer flakiness.
  - Fix strategy: Add deterministic startup decision tests and keep navigation after settings load.
  - Verification: Focused onboarding/route tests from `026`.
  - Stop condition: Authenticated incomplete users reliably go to onboarding.

- [X] T004 [US1] Finish settings persistence and notification schema in `packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart`, `packages/expense_repository/lib/src/entities/user_settings_entity.dart`, and `firestore.rules`
  - Why: Existing settings can be overwritten or rejected by rules.
  - Expected result: Language, currency, and notification fields save without losing unrelated settings.
  - Inputs: `specs/026-startup-onboarding-settings/contracts/settings-persistence-contract.md`, `notification-contract.md`.
  - Implementation notes: Preserve existing docs; add defaults only for missing fields.
  - Possible bugs: Existing Firestore documents missing new fields fail parsing.
  - Fix strategy: Add backwards-compatible parsing and focused serialization/rules tests.
  - Verification: Scoped settings repository tests.
  - Stop condition: Onboarding save and settings update use the same accepted schema.

- [X] T005 [US1] Apply saved language and localization delegates in `lib/app/app.dart` and `lib/l10n/`
  - Why: Choosing language is not useful if the app is hardcoded to Arabic.
  - Expected result: Arabic/English preference changes app language and direction.
  - Inputs: `specs/026-startup-onboarding-settings/tasks.md`, existing `lib/l10n/` files.
  - Implementation notes: Remove fixed locale. Add generated delegates. Keep fallback safe for unauthenticated startup.
  - Possible bugs: Missing generated delegate, tests without localization, Arabic text overflow.
  - Fix strategy: Run `gen-l10n`, update test harness, and verify small screens.
  - Verification: `gen-l10n`, scoped analyzer for `lib/app lib/l10n lib/features/onboarding`.
  - Stop condition: Language selection controls visible app language and direction.

- [X] T006 [US1] Replace broken Arabic/English hardcoded onboarding/auth text in `lib/features/onboarding/` and `lib/features/auth/`
  - Why: First-run screens define user trust and currently mix languages or broken text.
  - Expected result: User-facing onboarding/auth labels are localized and not encoding-broken.
  - Inputs: UX agent report, `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`.
  - Implementation notes: Keep design style unchanged. Do not redesign screens.
  - Possible bugs: ARB key mismatch or long Arabic labels clipping.
  - Fix strategy: Use concise Arabic labels and widget tests for narrow widths.
  - Verification: Focused widget tests for language/auth screens.
  - Stop condition: Setup/auth has no critical broken visible text.

## Phase 2: Real Data And Backend Contract Foundation

- [X] T007 [US8] Align expense source values in `packages/expense_repository/lib/src/models/expense.dart` and `firestore.rules`
  - Why: AI-created expenses can be rejected if app sends `aiText` but rules accept `ai`.
  - Expected result: All valid source values used by Flutter are accepted by Firestore rules.
  - Inputs: Backend agent report, `firestore.rules`, expense model serialization.
  - Implementation notes: Prefer explicit allowed enum values. Do not loosen ownership rules.
  - Possible bugs: Existing data with old source values becomes invalid.
  - Fix strategy: Support legacy values if already stored, document migration if needed.
  - Verification: Firestore rules tests if available; serialization unit tests.
  - Stop condition: AI/manual/receipt expenses can be saved without rule mismatch.

- [X] T008 [US8] Add app serialization contract tests under `test/packages/expense_repository/` or existing package test folder
  - Why: Model/rules drift caused real backend risk.
  - Expected result: Tests cover expense source, notification settings, user settings defaults, wallet transfer, and category budget shape.
  - Inputs: `packages/expense_repository/lib/`, `firestore.rules`.
  - Implementation notes: Use package-focused tests without real Firebase network.
  - Possible bugs: Test location conflicts with package setup.
  - Fix strategy: Follow existing repository package test patterns.
  - Verification: Focused package tests.
  - Stop condition: Serialization changes are locked by tests.

- [X] T009 [US8] Remove or isolate production mock data listed in `specs/027-product-restructure-master-plan/no-mock-audit.md`
  - Why: Users must not see fake financial values as real.
  - Expected result: Each fake hit is removed, moved to test/dev preview, or converted to honest empty/unavailable state.
  - Inputs: `no-mock-audit.md`, `contracts/real-data-contract.md`.
  - Implementation notes: Do this in small batches by feature owner to avoid conflicts.
  - Possible bugs: Removing mock data leaves blank screens without empty state.
  - Fix strategy: Add empty/error/unavailable state before removing fake values.
  - Verification: No-mock search and focused widget tests.
  - Stop condition: No normal production route shows fake financial data.

## Phase 3: Unified Expense Entry

- [X] T010 [US2] Continue incomplete AI refactor tasks in `specs/024-real-ai-expense-refactor/tasks.md` from `T011` onward
  - Why: Foundation T001-T010 is done, but screens still use old services and duplicate flows.
  - Expected result: AI text screen uses the new typed gateway/cubit/mapper path.
  - Inputs: `specs/024-real-ai-expense-refactor/tasks.md`, AI agent report.
  - Implementation notes: Do not reintroduce Flutter dotenv, API keys, or old proxy paths.
  - Possible bugs: Old widgets still import `AiApiService` or swallow quota/auth errors.
  - Fix strategy: Replace imports gradually and add quota/auth state tests.
  - Verification: Focused AI/expense tests and security search.
  - Stop condition: AI Text is the canonical AI expense entry.

- [X] T011 [US2] Fix Quick Add currency/wallet save in `lib/features/expenses/presentation/add_expense_quick_screen.dart`
  - Why: Screen can display one currency but save default currency.
  - Expected result: Saved expense uses selected/displayed currency and selected wallet/category.
  - Inputs: Expense agent report, `packages/expense_repository/lib/src/models/expense.dart`, settings state.
  - Implementation notes: Show category/wallet empty states before save.
  - Possible bugs: Save button enabled without category/wallet, duplicate submit.
  - Fix strategy: Validate required fields and disable during save.
  - Verification: Quick add widget/unit tests.
  - Stop condition: Quick Add saves real complete expense data.

- [X] T012 [US2] Make Receipt Add real or unavailable in `lib/features/expenses/presentation/add_expense_receipt_screen.dart`
  - Why: Current receipt flow looks like OCR but does not call the receipt endpoint.
  - Expected result: It calls `extractReceipt` and shows review, or the route is hidden/disabled with a clear reason.
  - Inputs: `lib/features/ai/data/ai_gateway_client.dart`, `workers/ai-gateway/`, `specs/024-real-ai-expense-refactor/`.
  - Implementation notes: Do not send base64 fragments as text parse input.
  - Possible bugs: Large image payload, quota/auth failures, no camera permission.
  - Fix strategy: Add typed failure states and manual fallback.
  - Verification: Focused receipt tests with fake client.
  - Stop condition: Receipt is not fake-working.

- [X] T013 [US2] Remove or redirect old AI expense route in `lib/app/router.dart` and `lib/features/expenses/presentation/ai_expense_screen.dart`
  - Why: Duplicate AI entry screens create inconsistent behavior.
  - Expected result: Old route redirects to canonical AI text flow or uses the same component.
  - Inputs: `AppRoutes.expensesNewText`, `AppRoutes.expensesNewAi`, `specs/025-smart-add-entry/`.
  - Implementation notes: Preserve deep links if needed by redirecting.
  - Possible bugs: Route tests fail or old navigation targets break.
  - Fix strategy: Add route test for old path to canonical behavior.
  - Verification: Route/widget tests.
  - Stop condition: There is one AI text expense behavior.

## Phase 4: Expense Management, Categories, Wallets

- [X] T014 [US3] Wire expense filters to real data in `lib/features/expenses/presentation/expenses_list_screen.dart`, `expense_filters_sheet.dart`, and `expense_filter_cubit.dart`
  - Why: Filter UI currently changes visually but does not filter real results.
  - Expected result: Date, category, amount, wallet, and reset filters update the expense list.
  - Inputs: Expense agent report, existing filter cubit.
  - Implementation notes: Use real categories and wallets, not hardcoded filter values.
  - Possible bugs: Filters stack incorrectly or empty state missing.
  - Fix strategy: Add tests for each filter and clear behavior.
  - Verification: Focused expense list/filter tests.
  - Stop condition: Filter choices change visible real expenses.

- [X] T015 [US3] Preserve expense fields on edit in `lib/features/expenses/presentation/edit_expense_screen.dart`
  - Why: Editing can wipe owner, currency, wallet, payment method, or source.
  - Expected result: Edit updates only changed fields and preserves the rest.
  - Inputs: `Expense` model, edit screen, expense agent report.
  - Implementation notes: Use copy/update behavior rather than constructing a partial default object.
  - Possible bugs: Null old expense, stale category/wallet lists, save loading missing.
  - Fix strategy: Add regression test for hidden field preservation.
  - Verification: Edit expense focused tests.
  - Stop condition: Edit no longer loses metadata.

- [X] T016 [US3] Add category alias management in `lib/features/categories/presentation/categories_screen.dart`
  - Why: AI/category matching needs user-controlled aliases like merchant names.
  - Expected result: User can add/delete aliases per category and see validation errors.
  - Inputs: `packages/expense_repository/lib/src/category_alias_repo.dart`, current category UI.
  - Implementation notes: Keep aliases inside category details/form to avoid a separate confusing screen.
  - Possible bugs: Duplicate aliases, archived categories receiving aliases, long Arabic alias overflow.
  - Fix strategy: Validate uniqueness and show inline errors.
  - Verification: Category alias widget/unit tests.
  - Stop condition: Aliases are manageable and usable by matching.

- [X] T017 [US5] Link expenses to wallets in `lib/features/expenses/presentation/widgets/expense_form_card.dart` and add screens
  - Why: Wallets exist but expense entry does not clearly connect spending to accounts.
  - Expected result: Expense entry requires or defaults a wallet and saves it.
  - Inputs: Wallet bloc/repository, quick add, AI draft mapper.
  - Implementation notes: Use default wallet if configured; otherwise show selection/empty state.
  - Possible bugs: No wallet exists for new user.
  - Fix strategy: Provide "create wallet first" empty action or auto-create safe default only if approved by settings.
  - Verification: Expense form tests.
  - Stop condition: Saved expenses carry correct wallet.

- [X] T018 [US5] Implement real wallet transfers in `lib/features/wallets/presentation/wallets_accounts_screen.dart` and wallet repository
  - Why: Transfer repository exists but UI and balance effects are incomplete.
  - Expected result: User can create transfer and balances update according to defined policy.
  - Inputs: Wallet agent report, `packages/expense_repository/lib/src/firebase/firebase_wallet_repo.dart`.
  - Implementation notes: Balance changes should be atomic where backend supports it.
  - Possible bugs: Source/destination mismatch, partial write, negative balance.
  - Fix strategy: Add transaction or compensating validation, plus tests.
  - Verification: Wallet transfer tests.
  - Stop condition: Transfers are real and visible.

## Phase 5: Financial Insight

- [X] T019 [US4] Centralize selected financial period in reports/dashboard budget flow
  - Why: "This Month" currently can mean all-time data.
  - Expected result: Home, reports, budgets, and story use the same current/selected period.
  - Inputs: `lib/features/reports/report_cubit/report_cubit.dart`, dashboard, budgets, story screens.
  - Implementation notes: Add a small period helper/model if it removes duplication.
  - Possible bugs: Timezone boundaries, old expenses counted incorrectly.
  - Fix strategy: Add fixture tests with expenses across two months.
  - Verification: Report/dashboard/budget focused tests.
  - Stop condition: Monthly numbers match across screens.

- [X] T020 [US4] Fix report drilldown category matching in `lib/features/reports/presentation/report_drilldown_screen.dart`
  - Why: The screen can open empty because it receives category name but filters by category id.
  - Expected result: Drilldown uses consistent category id/name and can load direct routes safely.
  - Inputs: Reports agent report, report cubit, route parameters.
  - Implementation notes: Prefer category id as primary key and display name separately.
  - Possible bugs: Existing saved expenses without category id.
  - Fix strategy: Support fallback matching with clear migration note.
  - Verification: Drilldown tests.
  - Stop condition: Tapping a category shows its expenses.

- [X] T021 [US4] Replace static category budgets in `lib/features/budgets/presentation/category_budgets_list_screen.dart`
  - Why: Current category budget screen displays hardcoded rows.
  - Expected result: Category budgets come from repository and real category spending.
  - Inputs: `FirebaseCategoryBudgetRepo`, budgets agent report.
  - Implementation notes: Include loading, empty, error, create/edit states.
  - Possible bugs: Budget currency mismatch, category missing.
  - Fix strategy: Use base currency and category id consistently.
  - Verification: Category budget tests.
  - Stop condition: No static budget rows remain in production.

- [X] T022 [US4] Complete saving goal create/edit/delete/progress in `lib/features/goals/presentation/saving_goals_screen.dart`
  - Why: Goals can be viewed but not fully managed from UI.
  - Expected result: User can create, edit, update progress, and archive/delete goals.
  - Inputs: Saving goal bloc/repository.
  - Implementation notes: Show validation and success/failure states.
  - Possible bugs: Progress over target, currency mismatch, deadline parsing.
  - Fix strategy: Add validation and focused tests.
  - Verification: Goal screen tests.
  - Stop condition: Goal management is usable.

- [X] T023 [US4] Separate subscriptions from generic recurring expenses in `lib/features/subscriptions/presentation/subscriptions_center_screen.dart`
  - Why: Current screen treats any active recurring expense as a subscription.
  - Expected result: Subscriptions are typed or sourced separately and have correct renewal dates.
  - Inputs: Subscription model, recurring expense bloc, budgets agent report.
  - Implementation notes: If schema change is needed, plan backwards compatibility.
  - Possible bugs: Existing recurring items disappear unexpectedly.
  - Fix strategy: Add migration/display rules and tests.
  - Verification: Subscription tests.
  - Stop condition: Rent/installments are not mislabeled as subscriptions.

## Phase 6: AI Experiences Beyond Entry

- [X] T024 [US6] Replace `MockAiService` production usage in `lib/features/ai/presentation/ai_advice_screen.dart`, `ai_history_screen.dart`, and `ai_assistant_sheet.dart`
  - Why: These screens show fake AI results as if real.
  - Expected result: Screens use real service/cubit or show empty/unavailable state.
  - Inputs: AI agent report, AI gateway client, no-mock audit.
  - Implementation notes: Do not create local generated-looking fallback responses.
  - Possible bugs: Screens become empty without guidance.
  - Fix strategy: Add helpful empty states and retry buttons when a real service exists.
  - Verification: No-mock search and AI screen tests.
  - Stop condition: No production AI screen uses fake output.

- [X] T025 [US6] Add AI quota/auth/network user states across AI screens
  - Why: Gateway errors currently may be swallowed or shown generically.
  - Expected result: User sees daily limit, sign-in needed, retry, or unavailable messages.
  - Inputs: `ai_gateway_models.dart`, `ai_gateway_client.dart`, AI screens.
  - Implementation notes: Keep messages concise and localized.
  - Possible bugs: Technical error text leaks to user.
  - Fix strategy: Map typed errors to safe localized messages.
  - Verification: AI error state tests.
  - Stop condition: AI failures are understandable and safe.

- [X] T026 [US6] Define AI history privacy policy in `lib/features/ai/` and repository/service layer
  - Why: History should be real but must avoid unsafe raw financial text storage unless intentional.
  - Expected result: AI history stores safe metadata/result summaries or is disabled until privacy is approved.
  - Inputs: AI agent report, gateway usage log behavior.
  - Implementation notes: Do not store provider secrets or raw prompts by default.
  - Possible bugs: History screen expects fields not stored.
  - Fix strategy: Align screen with safe history model.
  - Verification: Unit tests for history model/service.
  - Stop condition: AI history is real and privacy-conscious.

## Phase 7: Settings, Account, Security, Premium

- [X] T027 [US7] Wire settings rows to real actions in `lib/features/settings/presentation/settings_screen.dart`
  - Why: Many settings rows currently do nothing.
  - Expected result: Profile, subscription, backup/export, delete account, notifications, language, currency either work or show unavailable state.
  - Inputs: Settings/security agent report.
  - Implementation notes: Avoid adding fake success. Disable unavailable rows clearly.
  - Possible bugs: Route extra data missing, provider not available.
  - Fix strategy: Add route tests and fallback loading states.
  - Verification: Settings screen tests.
  - Stop condition: No important settings row is silent no-op.

- [X] T028 [US7] Connect account profile and deletion to real auth flow in `lib/features/account/`
  - Why: Account deletion/reauth services are placeholders or not connected.
  - Expected result: Profile loads safely, update/delete actions use real auth/repository paths, and reauth is requested when needed.
  - Inputs: Firebase auth repository, account services, settings agent report.
  - Implementation notes: Do not delete auth before safe data cleanup policy is defined.
  - Possible bugs: Partial deletion, provider-specific reauth differences.
  - Fix strategy: Add clear flow states and tests with fake auth repo.
  - Verification: Account service/cubit tests.
  - Stop condition: Delete account is not fake and handles reauth.

- [X] T029 [US7] Enforce app lock at app level in `lib/app/app.dart`, `lib/features/security/`, and `lib/security/`
  - Why: PIN exists but does not protect app screens automatically.
  - Expected result: When lock condition is met, app shows unlock gate before financial screens.
  - Inputs: App lock service/cubit, settings/security agent report.
  - Implementation notes: Use app lifecycle/resume observer or route guard. Keep unlock route safe.
  - Possible bugs: Lock loop, unlock screen does not dismiss, tests hang.
  - Fix strategy: Add lifecycle tests or cubit tests around resume/lock/unlock.
  - Verification: Security focused tests.
  - Stop condition: Enabled lock actually blocks app use after resume.

- [X] T030 [US7] Harden PIN and biometric behavior in `lib/features/security/` and `lib/security/`
  - Why: PIN change can bypass old PIN and biometric enable does not prove identity.
  - Expected result: PIN change requires old PIN/biometric, biometric enable asks for auth, failed attempts handled.
  - Inputs: PIN service, biometric service.
  - Implementation notes: Keep secure storage hashing behavior; do not log PIN data.
  - Possible bugs: Biometric unavailable devices get stuck.
  - Fix strategy: Add fallback states and clear errors.
  - Verification: Security unit/widget tests.
  - Stop condition: PIN/biometric controls are safe and understandable.

- [X] T031 [US7] Make premium/ads honest in `lib/monetization/` and `lib/feature_flags/`
  - Why: Upgrade/restore and ads are currently fake/no-op.
  - Expected result: Purchases/ads are real verified flows or disabled/unavailable; feature gates do not crash.
  - Inputs: Monetization agent report, purchase service, ad service, feature gate service.
  - Implementation notes: Do not set premium locally as if verified by store/server.
  - Possible bugs: Feature gate depends on missing cubit.
  - Fix strategy: Provide app-wide entitlement state or disable gates until implemented.
  - Verification: Monetization tests.
  - Stop condition: No fake premium purchase success is reachable.

## Phase 8: Services And Sync

- [X] T032 [US8] Fix notification service initialization and settings respect in `lib/services/notifications/`
  - Why: Notifications can be unscheduled, repeated, or ignore user settings.
  - Expected result: Notifications initialize safely, request permission only when needed, and respect saved settings.
  - Inputs: Backend services agent report, onboarding notification settings.
  - Implementation notes: Avoid platform channel calls in widget tests; inject fakes where needed.
  - Possible bugs: Android permission/API differences, timezone scheduling failure.
  - Fix strategy: Add service result types and focused tests.
  - Verification: Notification service/onboarding tests.
  - Stop condition: Notification behavior is truthful and permission-aware.

- [X] T033 [US8] Remove export/import/backup flow from app UI and production services
  - Why: Mohamed decided export/import is not needed in this product scope.
  - Expected result: User does not see backup, restore, import, or export actions in the app.
  - Inputs: Settings UI, export/backup services, feature gates, localization keys.
  - Implementation notes: Remove unused export dependencies so no hidden export path remains.
  - Possible bugs: Stale localization/generated plugin references.
  - Fix strategy: Regenerate localization and run `flutter pub get`.
  - Verification: Settings and monetization focused tests, scoped analyze.
  - Stop condition: Export/import is absent from app code paths and UI.

- [X] T034 [US8] Make analytics privacy-safe in `lib/services/analytics/analytics_service.dart`
  - Why: Analytics can send sensitive amounts/names if used as-is.
  - Expected result: Events avoid raw amounts, notes, names, descriptions, and personal financial details.
  - Inputs: Backend services agent report.
  - Implementation notes: Prefer coarse event names and feature usage counts.
  - Possible bugs: Product metrics become too vague.
  - Fix strategy: Use safe buckets/counts only where needed.
  - Verification: Analytics unit tests or code review checklist.
  - Stop condition: Analytics cannot leak raw financial details.

- [X] T035 [US8] Fix exchange-rate failure behavior in `lib/services/exchange_rates/exchange_rate_service.dart`
  - Why: Returning `1.0` silently can corrupt financial totals.
  - Expected result: `1.0` fallback only when currencies are identical; otherwise show stale/failed state.
  - Inputs: Backend services agent report, settings exchange-rate fields.
  - Implementation notes: Save last successful rates and update timestamp where appropriate.
  - Possible bugs: Existing callers expect a number always.
  - Fix strategy: Introduce typed result or explicit stale state and update callers.
  - Verification: Exchange-rate tests.
  - Stop condition: Failed conversions are not silently wrong.

- [X] T036 [US8] Repair local/Drift/VPS sync contract in `packages/expense_repository/lib/src/sync/`, `drift_store.dart`, and `server/src/sync/`
  - Why: `vpsLocalFirst` is not real sync yet.
  - Expected result: Push payload matches server, pull applies remote data locally, pending queue persists.
  - Inputs: `specs/023-vps-architecture-fix/`, backend services agent report.
  - Implementation notes: Do not present VPS sync as production-ready until tests prove push/pull.
  - Possible bugs: Conflict resolution data loss, duplicate changes, operation name mismatch.
  - Fix strategy: Add contract tests and idempotency tests before enabling UI claims.
  - Verification: Package/server sync tests.
  - Stop condition: Sync mode is truthful and contract-aligned.

## Phase 9: Release Readiness

- [X] T037 [Polish] Run production truthfulness audit across `lib` and `packages/expense_repository/lib`
  - Why: Final product review must not find fake states presented as real.
  - Expected result: No unresolved production fake/mock/no-op blockers remain.
  - Inputs: `contracts/real-data-contract.md`, all completed phase notes.
  - Implementation notes: Classify remaining hits; do not blindly delete test mocks.
  - Possible bugs: False positives or hidden fake data under unusual names.
  - Fix strategy: Manually inspect each hit and add follow-up tasks if needed.
  - Verification: No-mock search output attached to final notes.
  - Stop condition: All normal user routes are honest.

- [X] T038 [Polish] Run scoped then broader verification from `quickstart.md`
  - Why: Broad checks are useful only after phase-level work is stable.
  - Expected result: Focused checks pass; broad checks either pass or list remaining unrelated issues with owners.
  - Inputs: `quickstart.md`, completed phase tests.
  - Implementation notes: Do not hide failures. Separate new regressions from old failures.
  - Possible bugs: Full analyzer still reports legacy issues.
  - Fix strategy: File remaining issues into follow-up specs or cleanup tasks.
  - Verification: Command log in final phase report.
  - Stop condition: Mohamed can review app with known issue list.

- [ ] T039 [Polish] Perform manual Arabic/English small-screen review for all listed screens
  - Why: Many failures are visual/UX and not caught by unit tests.
  - Expected result: Screens render without critical overflow, broken text, wrong direction, or dead primary controls.
  - Inputs: Full screen list from user, UX report.
  - Implementation notes: Use 360x800, 375x812, 390x844 in Arabic RTL and English LTR.
  - Possible bugs: Long Arabic labels, bottom sheet height, wrong icon direction.
  - Fix strategy: Fix shared components/tokens first, then screen-local overflow.
  - Verification: Manual checklist with screenshots if practical.
  - Stop condition: App is ready for screen-by-screen product review.
  - Current status: Automated small-screen/RTL coverage passed and manual checklist is documented in `specs/027-product-restructure-master-plan/ui-small-screen-review.md`; keep this task open until the full signed-in Android walkthrough is completed.

## Dependencies And Execution Order

```text
T001-T002 block all implementation agents.
T003-T006 should finish before broad UI work.
T007-T009 block reliable real-data claims.
T010-T013 depend on 024/025 and can run after Phase 1 basics.
T014-T018 can run after expense entry contracts are stable.
T019-T023 depend on real period and expense data.
T024-T026 can run after AI gateway foundation is stable.
T027-T031 can run in parallel with Phase 6 if file ownership is separated.
T032-T036 can run in parallel by service specialists after Phase 2 contracts.
T037-T039 run last.
```

## Suggested Agent Split

```text
Agent A: Phase 1 startup/onboarding/localization.
Agent B: Phase 3 expense entry and AI text/receipt.
Agent C: Phase 4 expenses/categories/wallets.
Agent D: Phase 5 reports/budgets/goals/subscriptions.
Agent E: Phase 6 AI advice/history/assistant.
Agent F: Phase 7 settings/security/account/premium.
Agent G: Phase 8 backend/services/sync.
Main thread: Phase 0 baseline, integration review, Phase 9 acceptance.
```

## MVP Scope

```text
T001-T013, T019-T021
```

This MVP gives Mohamed a truthful core app: startup setup, language/currency, one add entry, real quick/AI text expense save, honest receipt, real filters, safe edit, and correct dashboard/report/monthly budget numbers.
