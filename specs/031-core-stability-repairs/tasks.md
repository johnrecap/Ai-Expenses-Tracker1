# Tasks: Core Stability Repairs

**Input**: Design documents from `specs/031-core-stability-repairs/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [quickstart.md](./quickstart.md), [contracts/](./contracts/)

**Project Type**: Production Flutter app with local-only financial data and explicit AI/server actions when owned by the feature

## Mandatory First Read And Skill Gate

Before generating or executing tasks, the agent MUST read:

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.agents/MANDATORY_RULES.md`
- `.agents/workflows/development.md`
- `.agents/skill-matcher.json`
- `docs/agent-playbooks/subagent-execution-rules.md`
- Relevant Spec Kit, production Flutter guardrail, Dart, Flutter widget test, and static-analysis skills

**Skills used for this task list**:

- `speckit-specify`
- `speckit-plan`
- `speckit-tasks`
- `production-flutter-app-guardrails`
- `dart-add-unit-test`
- `flutter-add-widget-test`
- `dart-run-static-analysis`

## Non-Negotiable Rules

- Keep work scoped to exact task files.
- Do not perform broad repo analysis.
- Do not run full-project `flutter analyze` or full `flutter test` during normal execution.
- Run focused tests first.
- Stop after the first unrelated failure and report it.
- Do not retry a hanging Flutter command more than twice.
- No secrets in Flutter/mobile code.
- AI provider keys stay server-side only.
- App-owned financial data must not be written to Firestore/PostgreSQL/VPS sync in local-only mode.
- Do not show mock/demo/sample financial data as real production data.
- Export/import remains out of scope.

## Phase 1: Setup And Guardrails

**Purpose**: Lock the full production-app scope and make the repair order explicit before implementation.

- [x] T001 [Guardrail] Confirm production app scope in `.specify/templates/spec-template.md`, `.specify/templates/plan-template.md`, `.specify/templates/tasks-template.md`, `.agents/skill-matcher.json`
  - Why: Old planning templates described a restricted app scope and could cause future agents to skip local data, AI gateway, notifications, monetization, or release work.
  - Expected result: New specs/plans/tasks describe the full production Flutter app and local-only financial-data rule.
  - Inputs: `AGENTS.md`, `.specify/memory/constitution.md`, `.agents/MANDATORY_RULES.md`, `specs/031-core-stability-repairs/plan.md`.
  - Implementation notes: Keep WebView/HTML and mobile secrets forbidden. Do not reintroduce fake financial data wording.
  - Possible bugs: A future plan still says app work is restricted to screens only.
  - Fix strategy: Search templates and matcher for old scope wording and replace with full production scope wording.
  - Verification: `rg -n "Production Flutter|local-only financial data|explicit AI|server-side AI gateway" .specify/templates .agents/skill-matcher.json .agents/skills .agent/skills`

- [x] T002 [P] [Guardrail] Keep `production-flutter-app-guardrails` readable in `.agents/skills/production-flutter-app-guardrails/SKILL.md` and `.agent/skills/production-flutter-app-guardrails/SKILL.md`
  - Why: Agents need a local skill that matches the current product scope.
  - Expected result: Both skill paths describe local-only financial data, explicit AI, native UI, RTL/LTR, and focused checks.
  - Inputs: `AGENTS.md`, `.agents/MANDATORY_RULES.md`.
  - Implementation notes: Keep both `.agents` and `.agent` paths because project workflows search both.
  - Possible bugs: One path is missing and some agents fail to find the skill.
  - Fix strategy: Copy the same skill content to both paths and validate they exist.
  - Verification: `Test-Path .agents\skills\production-flutter-app-guardrails\SKILL.md; Test-Path .agent\skills\production-flutter-app-guardrails\SKILL.md`

## Phase 2: Local Data Reliability (US1)

**Goal**: The app reads real local data after startup and never reports save success before durable local persistence succeeds.

**Independent Test**: Existing local records are available on immediate reads after store creation, and failed writes surface as failures.

- [x] T003 [P] [US1] Add local store startup tests in `packages/expense_repository/test/local_drift_reliability_test.dart`
  - Why: We need failing tests that prove startup reads wait for previously saved data instead of returning temporary empty/default values.
  - Expected result: Tests cover immediate settings/expense reads after creating a Drift-backed local store.
  - Inputs: `contracts/local-data-reliability-contract.md`, `packages/expense_repository/lib/src/local/drift/drift_store.dart`, `packages/expense_repository/lib/src/local/local_repositories.dart`.
  - Implementation notes: Use a test database/file setup that does not touch production user data. Keep test focused on local repository behavior.
  - Possible bugs: Test relies on timing sleeps and becomes flaky.
  - Fix strategy: Use explicit readiness hooks or deterministic fake/test database setup, not arbitrary delays.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub packages\expense_repository\test\local_drift_reliability_test.dart`

- [x] T004 [P] [US1] Add local write failure tests in `packages/expense_repository/test/local_drift_write_failure_test.dart`
  - Why: Current write failures can be swallowed, so UI may show success for data that is not persisted.
  - Expected result: Tests prove create/update/delete failure propagates as an error.
  - Inputs: `contracts/local-data-reliability-contract.md`, `packages/expense_repository/lib/src/local/drift/drift_store.dart`.
  - Implementation notes: Use a fake failing local store/database where practical. Do not require Firebase or network.
  - Possible bugs: Test only checks in-memory state and misses durable persistence.
  - Fix strategy: Verify the returned future/error from the repository, then reopen/read from persistence when relevant.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub packages\expense_repository\test\local_drift_write_failure_test.dart`

- [x] T005 [US1] Add readiness support in `packages/expense_repository/lib/src/local/drift/drift_store.dart`
  - Why: Reads need a deterministic way to know local data has loaded before returning empty/default state.
  - Expected result: The Drift store exposes or internally awaits a readiness future for reads and watches that depend on loaded data.
  - Inputs: T003, `contracts/local-data-reliability-contract.md`.
  - Implementation notes: Avoid broad rewrites. Make sure `_loadFromDatabase()` errors are surfaced and do not silently cause defaults to overwrite existing data.
  - Possible bugs: Watch streams never emit if readiness fails.
  - Fix strategy: Add failure handling and make repository/UI states able to show failure rather than hanging.
  - Verification: Run T003 focused test.

- [x] T006 [US1] Make local repository reads wait for readiness in `packages/expense_repository/lib/src/local/local_repositories.dart`
  - Why: Store readiness is not enough if repositories read from cache before readiness completes.
  - Expected result: `getSettings`, `getExpenses`, `getExpensesByFilter`, budget reads, and other initial reads do not return stale empty data before readiness.
  - Inputs: T005, `packages/expense_repository/lib/src/local/local_store_interface.dart`.
  - Implementation notes: Keep API changes minimal. If interface changes are required, update all local store implementations and focused tests.
  - Possible bugs: Existing tests using simple fake stores break because readiness is missing.
  - Fix strategy: Add default ready behavior to fakes/test stores or an adapter that resolves immediately.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub packages\expense_repository\test\local_drift_reliability_test.dart`

- [x] T007 [US1] Await durable writes in `packages/expense_repository/lib/src/local/drift/drift_store.dart` and `packages/expense_repository/lib/src/local/local_repositories.dart`
  - Why: Create/update/delete operations must not complete successfully until SQLite persistence completes.
  - Expected result: Write methods return failures when persistence fails and do not hide errors with `catchError((_) => 0)`.
  - Inputs: T004, `contracts/local-data-reliability-contract.md`.
  - Implementation notes: If changing `LocalStoreInterface` from sync to async, update implementations and call sites carefully. Preserve stream updates only after successful persistence or rollback failed optimistic updates.
  - Possible bugs: UI no longer updates immediately because stream emission moved too late.
  - Fix strategy: Prefer durable save first, then emit. If optimistic UI is kept, roll back and emit failure state on persistence error.
  - Verification: Run T004 focused test and a focused expense create/update test.

- [x] T008 [US1] Surface local save failures in expense/settings flows in `lib/features/expenses/` and `lib/features/settings/`
  - Why: Repository failures must become clear user-visible failures, not silent logs.
  - Expected result: Expense and settings save flows show failure states/messages when local persistence fails.
  - Inputs: T007, existing expense and settings blocs/cubits.
  - Implementation notes: Keep messages user-safe and localized where existing patterns allow. Do not expose stack traces.
  - Possible bugs: Tests without mounted blocs fail because exceptions now propagate.
  - Fix strategy: Update focused tests and fake repositories to model success/failure explicitly.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_quick_screen_test.dart test\features\settings\settings_screen_actions_test.dart`

## Phase 3: Budget And Wallet Correctness (US2)

**Goal**: Monthly budgets and wallet balances reflect the user's real financial state.

- [x] T009 [P] [US2] Add budget month filtering tests in `packages/expense_repository/test/local_budget_contract_test.dart`
  - Why: The repository must prove it returns the requested month, not any budget.
  - Expected result: Tests store at least two months and verify month/year-specific reads and watch behavior.
  - Inputs: `contracts/budget-wallet-contract.md`, `packages/expense_repository/lib/src/local/local_repositories.dart`.
  - Implementation notes: Include a no-budget-for-month case.
  - Possible bugs: Test relies on map insertion order and misses the real bug.
  - Fix strategy: Insert budgets in reverse order and assert exact month/year.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub packages\expense_repository\test\local_budget_contract_test.dart`

- [x] T010 [US2] Filter monthly budget reads and watches in `packages/expense_repository/lib/src/local/local_repositories.dart`
  - Why: Budget screens, Home, reports, and AI summaries need the correct month's budget.
  - Expected result: `getCurrentMonthBudget` and `watchCurrentMonthBudget` use month/year filtering.
  - Inputs: T009, `packages/expense_repository/lib/src/models/budget.dart`.
  - Implementation notes: Prefer existing `Budget.budgetIdFor(month, year)` or model fields. Do not change public behavior for unrelated budget operations.
  - Possible bugs: Watch stream emits all budgets or never updates.
  - Fix strategy: Map the store budget stream or add a budget collection watch that filters consistently.
  - Verification: Run T009 and `& 'C:\flutter\bin\flutter.bat' test --no-pub test\blocs\budget_bloc_test.dart`

- [x] T011 [US2] Document wallet balance policy in `specs/031-core-stability-repairs/contracts/budget-wallet-contract.md` and affected UI copy
  - Why: Wallet behavior must be explicit before code to avoid half-automatic balances.
  - Expected result: The chosen behavior is recorded. Preferred behavior is automatic balance adjustment for linked expenses.
  - Inputs: `contracts/budget-wallet-contract.md`, `lib/features/wallets/presentation/wallets_accounts_screen.dart`, `lib/features/expenses/presentation/`.
  - Implementation notes: If automatic behavior is too risky for the patch, implement manual-balance copy instead and defer automatic adjustment to a separate task.
  - Possible bugs: Code and copy disagree about whether balance changes automatically.
  - Fix strategy: Add tests that prove the chosen behavior and inspect labels for misleading text.
  - Verification: Read the contract and UI copy; run wallet behavior tests from T012 after implementation.

- [x] T012 [P] [US2] Add wallet behavior tests in `packages/expense_repository/test/local_wallet_expense_balance_test.dart`
  - Why: Create, edit, move, and delete are the cases where balance drift happens.
  - Expected result: Tests cover wallet-linked expense create, amount edit, wallet change, delete, and currency mismatch behavior.
  - Inputs: `contracts/budget-wallet-contract.md`, `packages/expense_repository/lib/src/models/expense.dart`, `packages/expense_repository/lib/src/models/wallet_account.dart`.
  - Implementation notes: Make the test match the selected policy from T011.
  - Possible bugs: Test only covers create and misses edit/delete drift.
  - Fix strategy: Require all mutation paths before marking wallet behavior complete.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub packages\expense_repository\test\local_wallet_expense_balance_test.dart`

- [x] T013 [US2] Implement selected wallet behavior in `packages/expense_repository/lib/src/local/` and affected expense/wallet flows
  - Why: Wallet balances must be trustworthy or explicitly manual.
  - Expected result: Automatic balance changes are correct for create/edit/delete, or manual behavior is clearly enforced and labeled.
  - Inputs: T011, T012, `packages/expense_repository/lib/src/local/local_repositories.dart`, `packages/expense_repository/lib/src/local/drift/drift_store.dart`, `lib/features/expenses/presentation/`, `lib/features/wallets/`.
  - Implementation notes: Automatic behavior should be as transactional as the local store allows. Do not double-deduct on edit.
  - Possible bugs: Editing amount applies full amount again instead of difference; moving wallet leaves old wallet wrong.
  - Fix strategy: Store/read previous expense state before applying the new effect and test each mutation.
  - Verification: Run T012 and focused wallet/expense tests.

## Phase 4: AI Privacy Cleanup (US3)

**Goal**: Production AI advice is explicit, compact, and cannot accidentally use legacy prompt paths.

- [x] T014 [P] [US3] Add AI advice no-auto-call tests in `test/features/ai/ai_advice_screen_privacy_test.dart`
  - Why: Opening an advice screen must not contact remote AI before the user asks.
  - Expected result: Test proves no gateway call occurs before the explicit action and exactly one call occurs after action.
  - Inputs: `contracts/ai-privacy-contract.md`, `lib/features/ai/presentation/ai_advice_screen.dart`.
  - Implementation notes: Use fake requesters, not real network.
  - Possible bugs: Test passes because the fake is not injected into the real call path.
  - Fix strategy: Verify the screen uses the injected/default requester boundary consistently.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\ai_advice_screen_privacy_test.dart`

- [x] T015 [P] [US3] Add compact payload tests in `test/features/ai/ai_advice_payload_privacy_test.dart`
  - Why: Advice payload must not include raw histories, merchant names, descriptions, or receipt text.
  - Expected result: Test feeds sensitive-looking local data and asserts the gateway payload contains only compact summary fields.
  - Inputs: `lib/features/ai/domain/ai_advice_request_mapper.dart`, `contracts/ai-privacy-contract.md`.
  - Implementation notes: Include strings like merchant/description/receipt in source fixtures and assert they are absent from payload.
  - Possible bugs: Test checks only top-level keys and misses nested raw data.
  - Fix strategy: Serialize the full payload and search the resulting JSON string.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\ai_advice_payload_privacy_test.dart`

- [x] T016 [US3] Isolate legacy prompt advice in `lib/features/ai/services/advisor_service.dart` and `lib/features/ai/services/ai_api_service.dart`
  - Why: Legacy prompt-style advice can bypass the new compact on-demand flow if reconnected.
  - Expected result: Production routes/providers cannot call legacy remote advice; legacy service either becomes local-only or delegates to compact summary.
  - Inputs: T014, T015, `lib/features/ai/presentation/ai_advice_screen.dart`.
  - Implementation notes: Do not remove useful local fallback generation unless tests require it. The important part is blocking production remote prompt advice.
  - Possible bugs: Existing AI advisor screen breaks because it depended on legacy remote advice.
  - Fix strategy: Route it to the new advice flow or show an unavailable/local-only state.
  - Verification: Run T014/T015 and `rg -n "getAdvice\\(|summary: \\{'prompt'|AiApiService\\(\\)" lib\features\ai test\features\ai`

- [x] T017 [US3] Add production route/provider guard tests in `test/features/ai/ai_legacy_route_guard_test.dart`
  - Why: Future edits must not reconnect old prompt advice accidentally.
  - Expected result: Test or contract check proves production AI advice route uses the new on-demand summary flow.
  - Inputs: `lib/app/router.dart`, `lib/features/ai/`.
  - Implementation notes: Keep this as a focused test or static contract check. Do not inspect the entire repo.
  - Possible bugs: False positives from tests or docs.
  - Fix strategy: Scope search/guards to production `lib/features/ai` paths and router/provider wiring.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\ai_legacy_route_guard_test.dart`

## Phase 5: AI Worker Guardrails (US3)

**Goal**: The server boundary rejects unsafe payloads and avoids raw user content logs.

- [x] T018 [P] [US3] Add worker financial advice privacy tests in `workers/ai-gateway/test/financialAdvice.privacy.test.ts`
  - Why: Server should reject raw advice payloads even if a future client sends them.
  - Expected result: Tests reject raw rows, merchant-like fields, receipt text, and oversized payloads.
  - Inputs: `workers/ai-gateway/src/handlers/financialAdvice.ts`, `contracts/ai-privacy-contract.md`.
  - Implementation notes: Use test provider fakes. Do not call real AI provider.
  - Possible bugs: Test only checks HTTP status and not provider invocation.
  - Fix strategy: Assert provider is not called for rejected payloads.
  - Verification: `cmd /c npm --prefix workers/ai-gateway test -- financialAdvice`

- [x] T019 [P] [US3] Add worker parse/receipt boundary tests in `workers/ai-gateway/test/parseReceiptBoundaries.test.ts`
  - Why: Text parse and receipt scan are explicit AI actions but still need size, MIME, and raw logging guardrails.
  - Expected result: Tests cover max text/body size, disallowed receipt MIME, oversized image, and no raw content in logged error metadata.
  - Inputs: `workers/ai-gateway/src/handlers/parseExpense.ts`, `workers/ai-gateway/src/handlers/receiptExtraction.ts`.
  - Implementation notes: Do not forbid current text/image entirely; those are the explicit user inputs.
  - Possible bugs: Tests become too strict and block legitimate receipt uploads.
  - Fix strategy: Match reasonable limits already used by worker config and document them in test names.
  - Verification: `cmd /c npm --prefix workers/ai-gateway test -- parseExpense receiptExtraction`

- [x] T020 [US3] Implement worker guardrails in `workers/ai-gateway/src/handlers/financialAdvice.ts`, `parseExpense.ts`, `receiptExtraction.ts`, and `promptBuilder.ts`
  - Why: Tests alone do not protect the gateway; handlers must enforce request boundaries.
  - Expected result: Unsafe advice payloads are rejected, parse/receipt inputs are bounded, allowed MIME types are explicit, and raw content is not logged.
  - Inputs: T018, T019, `contracts/ai-privacy-contract.md`.
  - Implementation notes: Keep error responses user-safe. Preserve existing successful explicit AI actions.
  - Possible bugs: Receipt scans fail for valid images; parse text rejects normal Arabic input.
  - Fix strategy: Add tests for allowed Arabic text and valid JPEG/PNG/WebP receipt inputs.
  - Verification: `cmd /c npm --prefix workers/ai-gateway test -- financialAdvice parseExpense receiptExtraction` and `cmd /c npm --prefix workers/ai-gateway run typecheck`

## Phase 6: Settings And Notifications (US4)

**Goal**: Settings changes happen in Settings and notification toggles control scheduled reminders.

- [x] T021 [P] [US4] Add Settings language/currency tests in `test/features/settings/settings_language_currency_test.dart`
  - Why: Changing one preference must not reset another or reopen onboarding.
  - Expected result: Tests prove Arabic/USD and English/EGP combinations remain stable when only one preference changes.
  - Inputs: `contracts/settings-notifications-contract.md`, `lib/features/settings/presentation/settings_screen.dart`.
  - Implementation notes: Use widget tests with fake settings cubit/repository where practical.
  - Possible bugs: Test only checks UI label and misses saved state.
  - Fix strategy: Assert cubit/repository receives the expected single-setting update.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\settings\settings_language_currency_test.dart`

- [x] T022 [US4] Replace Settings onboarding jumps in `lib/features/settings/presentation/settings_screen.dart`
  - Why: Onboarding carries first-run defaults and can reset unrelated settings.
  - Expected result: Settings opens direct language/currency picker UI and saves the selected value without navigating to onboarding.
  - Inputs: T021, existing theme/shared components.
  - Implementation notes: Match existing Settings design. Do not add new colors or a new visual language.
  - Possible bugs: Back button or sheet dismissal loses selected value unexpectedly.
  - Fix strategy: Keep selection explicit with Save/Cancel and test both paths.
  - Verification: Run T021 and a touched-file analyzer on Settings files/tests.

- [x] T023 [P] [US4] Add notification cancellation tests in `test/services/notifications/notification_service_test.dart` and `test/features/settings/settings_notifications_test.dart`
  - Why: Disabling notifications must cancel scheduled reminders, not just save a disabled flag.
  - Expected result: Tests prove disable calls cancel/cancelAll for app-managed reminders and permission denial leaves notifications disabled.
  - Inputs: `contracts/settings-notifications-contract.md`, `lib/services/notifications/notification_service.dart`, `lib/features/settings/settings_cubit/settings_cubit.dart`.
  - Implementation notes: Use fakes/mocks. Do not rely on real platform notifications in unit tests.
  - Possible bugs: Tests depend on plugin initialization and fail in CI.
  - Fix strategy: Add an injectable notification scheduler boundary or fake platform interface.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\services\notifications\notification_service_test.dart test\features\settings\settings_notifications_test.dart`

- [x] T024 [US4] Implement notification reconcile behavior in `lib/services/notifications/notification_service.dart`, `lib/features/settings/settings_cubit/settings_cubit.dart`, and `lib/features/settings/presentation/settings_screen.dart`
  - Why: UI preference must match real scheduled notification behavior.
  - Expected result: Disable cancels app-managed reminders; enable requests permission and schedules only after approval.
  - Inputs: T023, current notification settings model.
  - Implementation notes: Keep notification details privacy-safe. Do not expose raw subscription names on lock screen unless explicitly approved in a future privacy setting.
  - Possible bugs: Cancels unrelated system/plugin notifications.
  - Fix strategy: Track app-managed notification IDs/channels and cancel only managed reminders where possible.
  - Verification: Run T023 focused tests.

## Phase 7: Honest Home And AI Expense UX (US5)

**Goal**: Remove misleading financial UI and make AI expense saving clear.

- [x] T025 [P] [US5] Add Home honesty test in `test/features/dashboard/home_dashboard_honesty_test.dart`
  - Why: Home must not show static financial claims when no real data supports them.
  - Expected result: Test proves texts like "Spending is down 12%" and "2 due this week" do not appear in empty/unsupported state.
  - Inputs: `contracts/ui-honesty-contract.md`, `lib/features/dashboard/presentation/home_dashboard_screen.dart`.
  - Implementation notes: Test empty state and at least one real-data-backed state if available.
  - Possible bugs: Test becomes language-specific and misses Arabic static copy.
  - Fix strategy: Check known static English strings and add localized key expectations when UI is localized.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\dashboard\home_dashboard_honesty_test.dart`

- [x] T026 [US5] Remove or data-bind static Home financial cards in `lib/features/dashboard/presentation/home_dashboard_screen.dart`
  - Why: Fake insights are misleading in a money app.
  - Expected result: Home shows real calculated insight, loading, empty, or unavailable state instead of static financial claims.
  - Inputs: T025, existing dashboard cubits/blocs.
  - Implementation notes: Prefer hiding unsupported cards over inventing new metrics. Reuse existing cards/theme.
  - Possible bugs: Layout leaves awkward gaps after cards are removed.
  - Fix strategy: Replace with a compact empty/unavailable card using existing spacing.
  - Verification: Run T025 and existing `test\features\dashboard\home_dashboard_test.dart`.

- [x] T027 [P] [US5] Add AI expense narrow-layout tests in `test/features/expenses/add_expense_ai_text_layout_test.dart`
  - Why: The AI input and Save controls must stay usable in Arabic/English on narrow phones.
  - Expected result: Tests cover 360px width, long input text, Arabic/English directionality, and no overflow exceptions.
  - Inputs: `contracts/ui-honesty-contract.md`, `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`, `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`.
  - Implementation notes: Use `tester.takeException()` and scroll until visible when needed.
  - Possible bugs: Test fails because focused screen lacks app-level providers.
  - Fix strategy: Use existing test helpers or minimal fake providers already present in expense tests.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_layout_test.dart`

- [x] T028 [US5] Improve AI expense input and Save ordering in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart` and `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
  - Why: Beginners need to review parsed fields before saving, and long natural text must fit inside the input.
  - Expected result: Input has better space, hint/labels fit, Save is after required review fields or disabled until valid, and missing fields are clear.
  - Inputs: T027, existing theme/components.
  - Implementation notes: Match current colors, typography, spacing, and components. Do not create a new design language.
  - Possible bugs: Sticky Save overlaps keyboard or bottom nav.
  - Fix strategy: Use scroll padding/safe area and widget tests at narrow viewports.
  - Verification: Run T027 and `test\features\expenses\add_expense_ai_text_screen_test.dart`.

## Phase 8: Release Readiness Tracking (US6)

**Goal**: Track release blockers without distracting from core stability.

- [x] T029 [P] [US6] Add release readiness checklist in `specs/031-core-stability-repairs/release-readiness.md`
  - Why: Signing, purchases, ads, analytics consent, and privacy policy are production blockers but should not block the core repair sequence.
  - Expected result: A checklist clearly marks what is required before release.
  - Inputs: `contracts/release-readiness-contract.md`, `android/app/build.gradle.kts`, `lib/monetization/`, `lib/services/analytics/`.
  - Implementation notes: Do not implement billing/ads in this task; document blockers and verification commands.
  - Possible bugs: Checklist implies release is ready without verification.
  - Fix strategy: Use blocked/pending states and exact evidence fields.
  - Verification: Read checklist and confirm each item has owner, status, and required check.

- [x] T030 [P] [US6] Add monetization honesty tests in `test/monetization/free_premium_readiness_test.dart`
  - Why: Premium/ads screens must not imply production purchase success if services are placeholders.
  - Expected result: Tests prove unavailable purchase/restore states are honest.
  - Inputs: `lib/monetization/`, `contracts/release-readiness-contract.md`.
  - Implementation notes: Use fakes. Do not connect real billing/ads in this repair feature unless separately approved.
  - Possible bugs: Tests duplicate existing monetization tests.
  - Fix strategy: Reuse or extend existing tests rather than creating overlapping assertions.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\free_premium_readiness_test.dart`

- [x] T031 [US6] Document Android signing and privacy blockers in `specs/031-core-stability-repairs/release-readiness.md`
  - Why: Release should be blocked until signing and privacy/consent are ready.
  - Expected result: Release checklist names signing config, privacy policy, analytics consent, ads consent, and purchase restore checks.
  - Inputs: T029, `android/app/build.gradle.kts`, `lib/services/analytics/analytics_service.dart`.
  - Implementation notes: This is documentation unless the user explicitly approves release implementation.
  - Possible bugs: Documentation gets stale.
  - Fix strategy: Link the checklist from final release plan when release work starts.
  - Verification: Checklist review; no code command needed.

## Final Phase: Focused Verification And Handoff

- [x] T032 [Verify] Run local data focused tests and touched-file analyzer for `packages/expense_repository/`
  - Why: The highest-risk changes are local data reads/writes, budget, and wallet behavior.
  - Expected result: Focused package tests pass and touched files analyze cleanly.
  - Inputs: Completed T003-T013.
  - Implementation notes: Do not run full project tests unless this task is explicitly expanded.
  - Possible bugs: Flutter lockfile sandbox failure.
  - Fix strategy: Request approved Flutter command escalation instead of retrying inside sandbox.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub packages\expense_repository\test\local_drift_reliability_test.dart packages\expense_repository\test\local_drift_write_failure_test.dart packages\expense_repository\test\local_budget_contract_test.dart packages\expense_repository\test\local_wallet_expense_balance_test.dart`

- [x] T033 [Verify] Run AI privacy and worker focused checks
  - Why: AI privacy must be verified on both Flutter and worker boundaries.
  - Expected result: Flutter AI privacy tests and worker tests pass.
  - Inputs: Completed T014-T020.
  - Implementation notes: Worker commands may require dependencies already installed in `workers/ai-gateway`.
  - Possible bugs: npm dependency or network issue unrelated to code.
  - Fix strategy: Report dependency blocker and run available local tests first.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\ai_advice_screen_privacy_test.dart test\features\ai\ai_advice_payload_privacy_test.dart test\features\ai\ai_legacy_route_guard_test.dart`; `cmd /c npm --prefix workers/ai-gateway test -- financialAdvice parseExpense receiptExtraction`

- [x] T034 [Verify] Run Settings, notifications, Home, and AI expense UI focused checks
  - Why: User-facing changes must be verified in the affected screens only.
  - Expected result: Focused widget/service tests pass without broad unrelated failures.
  - Inputs: Completed T021-T028.
  - Implementation notes: If a widget test needs scrolling, use `scrollUntilVisible` instead of arbitrary delays.
  - Possible bugs: RTL test failures from hardcoded English labels.
  - Fix strategy: Add localization usage or stable test keys instead of forcing English strings.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\settings\settings_language_currency_test.dart test\features\settings\settings_notifications_test.dart test\services\notifications\notification_service_test.dart test\features\dashboard\home_dashboard_honesty_test.dart test\features\expenses\add_expense_ai_text_layout_test.dart`

- [x] T035 [Verify] Run privacy/local-only search in `lib`, `packages`, `workers`, and `test`
  - Why: Search catches accidental cloud financial-data paths or raw AI payload regressions in owned areas.
  - Expected result: Each hit is expected legacy/future code, tests, or a reviewed production path.
  - Inputs: Completed implementation.
  - Implementation notes: Do not delete legacy Firestore/VPS files just because they appear. The goal is ensuring local-only production runtime does not instantiate them.
  - Possible bugs: False positives from docs/tests.
  - Fix strategy: Inspect each hit and classify it in the final report.
  - Verification: `rg -n "FirebaseFirestore|firebaseLegacy|migrationComparison|recentExpenses|merchant|receiptText|description|WebView|webview" lib packages workers test`

- [x] T036 [Docs] Update this task list checkboxes and final handoff notes in `specs/031-core-stability-repairs/tasks.md`
  - Why: Future agents need to know which repair batches are complete and which checks passed.
  - Expected result: Completed tasks are checked immediately after verified, and any blockers are documented with exact command/failure.
  - Inputs: All prior tasks.
  - Implementation notes: Do not mark a task complete without its verification or a documented blocker accepted by Mohamed.
  - Possible bugs: Checkboxes are bulk-marked without verification.
  - Fix strategy: Update one task at a time after its focused check.
  - Verification: Manual review of task status and final report.

## Dependencies And Execution Order

1. T001-T002 must complete before feature implementation.
2. T003-T008 block all later financial correctness tasks.
3. T009-T013 depend on local write/read reliability.
4. T014-T020 can run after local data summary behavior is stable; do not wait for UI polish.
5. T021-T024 can run after data reliability, in parallel with UI honesty if file ownership is separate.
6. T025-T028 must wait until data trust and AI privacy are stable.
7. T029-T031 can run in parallel as docs/tests, but release implementation is deferred.
8. T032-T036 are final verification/handoff.

## Parallel Opportunities

- T003 and T004 can be written in parallel.
- T009 and T012 can be written in parallel after local test setup is known.
- T014 and T015 can be written in parallel.
- T018 and T019 can be written in parallel.
- T021 and T023 can be written in parallel.
- T025 and T027 can be written in parallel.
- T029 and T030 can be written in parallel.

## MVP Scope

The minimum safe MVP is:

1. T003-T008 local data reliability.
2. T009-T010 budget month correctness.
3. T011-T013 wallet decision and behavior.
4. T014-T017 AI privacy cleanup.

Do not treat the app as stable until this MVP passes focused checks.

## Final Handoff Notes

- Completed all tasks T001-T036 for this repair feature.
- Local financial data remains local-only by default. `RepositoryRuntimeMode` defaults to `localOnly`, and `App` creates the local-only bundle without Firebase financial repositories in that mode.
- Firestore hits from the final search are legacy/future explicit modes or account-profile capability code, not the production local-only financial data path.
- AI advice uses compact summaries. Raw `merchant`, `description`, receipt text, and row-like expense payload hits are either local UI/model fields, tests, explicit AI parse/receipt actions, or server-side rejection tests.
- Home no longer shows unsupported static claims like "Spending is down 12%" or "2 due this week".
- AI expense text entry now fits narrow 360px screens better, hides the keyboard on submit, and keeps Save disabled until required fields are ready.
- Settings language/currency changes no longer route through onboarding. Notification disable cancels app-managed reminders; enabling does not persist a misleading enabled state if permission is denied.
- Release readiness remains **BLOCKED** until Android release signing, privacy policy, terms, analytics/ad consent, purchases, and restore verification are completed. See `release-readiness.md`.
- Focused tests and touched-file analyzer checks passed. One earlier `dart format` attempt timed out; per project hang rules, it was not retried repeatedly. Analyzer checks on touched files passed after edits.
