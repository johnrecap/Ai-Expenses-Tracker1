# Tasks: Local Only With AI On Demand

**Input**: Design documents from `specs/030-local-only-ai-on-demand/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [quickstart.md](./quickstart.md), [contracts/](./contracts/)

**Project Type**: Production Flutter app with local-only financial data and on-demand AI gateway.

## Mandatory First Read And Skill Gate

Before executing these tasks, the agent must read:

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.agents/workflows/development.md`
- `.agents/skill-matcher.json`
- `docs/agent-playbooks/subagent-execution-rules.md`
- Relevant Spec Kit and Flutter/Dart skills

**Skills used for this task list**:

- `speckit-specify`
- `speckit-plan`
- `speckit-tasks`

## Non-Negotiable Rules

- Keep work scoped to `lib`, `packages/expense_repository`, `workers/ai-gateway`, focused tests, and related docs.
- Do not perform broad repo analysis.
- Do not run full-project `flutter analyze` or full `flutter test` during normal execution.
- Run focused tests first.
- Stop after the first unrelated failure and report it.
- Do not retry a hanging Flutter command more than twice.
- No secrets in Flutter/mobile code.
- AI provider keys stay server-side only.
- App-owned financial data must not be written to Firestore/PostgreSQL in local-only mode.
- Export/import remains out of scope.

## Phase 1: Setup And Architecture Guardrails

**Purpose**: Make the local-only direction explicit and prevent accidental cloud financial-data writes.

- [x] T001 [Docs] Update long-lived architecture wording in `AGENTS.md` and `.specify/memory/constitution.md`
  - Why: The current project rules still describe Firestore/VPS as production app-data backends. That conflicts with Mohamed's new local-only decision.
  - Expected result: Project rules say production app-owned financial data is local-only, while AI gateway, ads, and purchase checks may still use network.
  - Inputs: `specs/030-local-only-ai-on-demand/spec.md`, `specs/030-local-only-ai-on-demand/plan.md`, `AGENTS.md`, `.specify/memory/constitution.md`.
  - Implementation notes: Keep the no-secrets rule. Do not remove Firebase/Auth wording entirely if it is still used for AI gateway identity/quota.
  - Possible bugs: Future agents follow old cloud-backed rules and reintroduce Firestore writes.
  - Fix strategy: Add a short "Local-only production data mode" section and link this spec.
  - Verification: Read both files and confirm local-only app data is named as the default.

- [x] T002 [P] [Tests] Create local-only factory guard test in `test/packages/expense_repository/local_only_repository_factory_test.dart`
  - Why: The safest first check is proving local-only mode builds only local repositories.
  - Expected result: Test fails before implementation if local-only mode is missing or creates Firebase/VPS product-data repos.
  - Inputs: `packages/expense_repository/lib/src/repository_runtime_mode.dart`, `packages/expense_repository/lib/src/repository_factory.dart`, `contracts/local-only-data-contract.md`.
  - Implementation notes: Test repository class/runtime behavior without connecting to Firebase or VPS.
  - Possible bugs: Test becomes too dependent on private class names.
  - Fix strategy: Assert through public factory behavior where possible; use type checks only for repository bundle classes.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\packages\expense_repository\local_only_repository_factory_test.dart`

- [x] T003 [P] [Tests] Create no-cloud-write guard search note in `test/packages/expense_repository/local_only_no_cloud_write_contract_test.dart`
  - Why: Local-only mode must not silently instantiate Firestore or sync clients for product data.
  - Expected result: Test or contract check documents forbidden repository types for local-only mode.
  - Inputs: `contracts/local-only-data-contract.md`, `packages/expense_repository/lib/src/firebase/`, `packages/expense_repository/lib/src/api/`.
  - Implementation notes: Keep it focused on local-only factory and app-data repositories, not AI gateway auth.
  - Possible bugs: False positives from legacy files that are allowed to remain.
  - Fix strategy: Only inspect local-only runtime path and factory output.
  - Verification: Same focused test command as T002 or a separate focused test file.

## Phase 2: Local-Only Runtime Foundation

**Purpose**: Make the app boot and persist financial data locally without requiring login or cloud database access.

- [x] T004 [Runtime] Add `localOnly` runtime mode in `packages/expense_repository/lib/src/repository_runtime_mode.dart`
  - Why: Local-only needs a named mode that cannot be confused with VPS local-first sync.
  - Expected result: `RepositoryRuntimeMode.localOnly` exists and is the default when no env value is passed.
  - Inputs: `plan.md`, `packages/expense_repository/lib/src/repository_runtime_mode.dart`.
  - Implementation notes: Keep legacy aliases for old modes, but default to local-only.
  - Possible bugs: Existing tests expecting `firebaseLegacy` default fail.
  - Fix strategy: Update tests to reflect the new product decision, not to preserve old behavior.
  - Verification: Focused runtime-mode tests and scoped analyzer on this file.

- [x] T005 [Runtime] Build local-only repository bundle in `packages/expense_repository/lib/src/repository_factory.dart`
  - Why: Local-only mode must use `DriftLocalRepositoryStore` for all app-owned financial repositories.
  - Expected result: Factory creates local expense, category, alias, budget, settings, recurring, goal, AI log, wallet, and transfer repositories.
  - Inputs: `packages/expense_repository/lib/src/local/local_repositories.dart`, `packages/expense_repository/lib/src/local/drift/drift_store.dart`.
  - Implementation notes: Reuse the existing local bundle logic if possible, but keep naming clear: local-only is not VPS sync.
  - Possible bugs: Store instance duplicated across repositories or disposed too early.
  - Fix strategy: Create one store per local bundle and pass it to all local repositories.
  - Verification: `test/packages/expense_repository/local_only_repository_factory_test.dart`

- [x] T006 [App] Make local-only app boot independent of visible login in `lib/app/app.dart`
  - Why: Core tracking must work without account or internet.
  - Expected result: App can create repository providers using a stable local scope before cloud auth is available.
  - Inputs: `lib/app/app.dart`, `packages/expense_repository/lib/src/auth/auth_repository.dart`, `contracts/local-only-data-contract.md`.
  - Implementation notes: Preserve auth bloc only if routes still need it. Do not block main app providers on Firebase user state in local-only mode.
  - Possible bugs: Router still redirects to login, providers are missing before auth, or local data scope changes between launches.
  - Fix strategy: Add a stable local user id/scope for local-only mode and update route guards separately.
  - Verification: Focused app/router tests plus manual offline startup.

- [x] T007 [Routes] Adjust login gating for local-only mode in `lib/app/router.dart`
  - Why: If router still requires login, local-only storage will not be usable.
  - Expected result: Core app routes open without login in local-only mode; auth screens become optional or hidden from the main path.
  - Inputs: `lib/app/router.dart`, `lib/app/routes.dart`, login/signup screens.
  - Implementation notes: Keep account screens available only if they still serve an explicit purpose.
  - Possible bugs: Splash/onboarding loop, back button exits unexpectedly, or protected settings route breaks.
  - Fix strategy: Add focused route tests for unauthenticated local-only startup.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test/app/routes_test.dart`

- [x] T008 [P] [Settings] Rewrite cloud/sync wording in `lib/features/settings/presentation/settings_screen.dart`
  - Why: Users must understand data is stored on this device and not backed up to cloud.
  - Expected result: Settings clearly states local-only storage and data-loss risk in user-friendly Arabic/English wording.
  - Inputs: `contracts/local-only-data-contract.md`, `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`.
  - Implementation notes: Use localization files, not hardcoded new text.
  - Possible bugs: English/Arabic mismatch or text overflow.
  - Fix strategy: Add widget test for text presence and RTL layout smoke check.
  - Verification: Focused settings screen test and `flutter gen-l10n` if localization changes.

- [x] T009 [P] [Analytics] Review analytics behavior in `lib/services/analytics/analytics_service.dart`
  - Why: Local-only financial data should not leak through analytics events.
  - Expected result: Analytics never sends amounts, descriptions, merchant names, or raw financial records.
  - Inputs: `lib/services/analytics/analytics_service.dart`, `contracts/local-only-data-contract.md`.
  - Implementation notes: Keep harmless screen/action events only if already approved.
  - Possible bugs: Existing event parameters include sensitive fields.
  - Fix strategy: Strip sensitive parameters and add a focused unit test if analytics is injectable.
  - Verification: `rg -n "amount|merchant|description|receipt|expense" lib/services/analytics lib/features`

## Phase 3: Local Advice And Summary Cache (P1)

**Goal**: Advice screen gives useful local guidance immediately, without waiting for network.

**Independent Test**: With local expenses and budgets, open advice screen offline and see local tips within the app without any AI request.

- [x] T010 [P] [US2] Create `AdviceSummary` model in `lib/features/ai/domain/advice_summary.dart`
  - Why: AI and local advice need one compact, privacy-safe summary shape.
  - Expected result: Model represents totals, budget status, top categories, trend flags, subscriptions total, savings progress, and summary hash.
  - Inputs: `data-model.md`, `contracts/ai-advice-speed-contract.md`.
  - Implementation notes: Do not include raw expense descriptions, merchant names, receipt OCR text, or full transaction lists.
  - Possible bugs: Model grows until payload is too large.
  - Fix strategy: Keep list fields capped and add serialization size tests.
  - Verification: `test/features/ai/advice_summary_builder_test.dart`

- [x] T011 [P] [US2] Create summary builder in `lib/features/ai/domain/advice_summary_builder.dart`
  - Why: Summary should be computed from local data in one predictable place.
  - Expected result: Builder creates a compact summary from local expenses, budgets, categories, wallets, goals, and subscriptions.
  - Inputs: `packages/expense_repository/lib/src/models/`, local repositories, `data-model.md`.
  - Implementation notes: Cap top categories at 5 and trend flags at 5. Keep calculations deterministic.
  - Possible bugs: Slow loops over very large datasets or wrong month boundaries.
  - Fix strategy: Use date filters, aggregate once, and add tests for empty/current/previous month data.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test/features/ai/advice_summary_builder_test.dart`

- [x] T012 [US2] Create summary cache service in `lib/features/ai/domain/advice_summary_cache.dart`
  - Why: The AI button must not wait to calculate everything after tap.
  - Expected result: Latest summary is cached and can be read quickly by advice UI and AI request.
  - Inputs: `advice_summary.dart`, `advice_summary_builder.dart`, repository streams/change events.
  - Implementation notes: Recompute after expense, budget, wallet, goal, or subscription changes. Keep stale state explicit.
  - Possible bugs: Cache does not refresh after save, causing old advice.
  - Fix strategy: Hook into existing blocs/repository streams and add tests for invalidation.
  - Verification: Focused cache test with data changes.

- [x] T013 [P] [US2] Create local advice generator in `lib/features/ai/domain/local_advice_generator.dart`
  - Why: User should see useful tips even offline or before AI returns.
  - Expected result: Generator produces short local tips from the cached summary in Arabic/English.
  - Inputs: `AdviceSummary`, `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`.
  - Implementation notes: Keep text practical and not fake AI. Use deterministic rules for budget near limit, top category, daily average, subscriptions.
  - Possible bugs: Advice feels generic or uses broken Arabic encoding from old service.
  - Fix strategy: Put clean localized strings in ARB and test both locales.
  - Verification: Focused unit tests for Arabic/English local advice.

- [x] T014 [US2] Replace unavailable advice state in `lib/features/ai/presentation/ai_advice_screen.dart`
  - Why: The current screen says AI advice is unavailable and shows no real local value.
  - Expected result: Screen renders local advice cards immediately, with a separate Ask AI action.
  - Inputs: `lib/core/theme/`, `lib/core/widgets/ai_insight_card.dart`, `AdviceSummary`, local advice generator.
  - Implementation notes: Match existing theme and shared components. Do not add a new design language.
  - Possible bugs: Layout overflow in Arabic, loading state hides local advice, or AI button blocks screen.
  - Fix strategy: Keep local advice and AI loading/error state as separate UI sections.
  - Verification: Focused widget test for local advice visible without network.

- [x] T015 [US2] Add immediate local advice widget tests in `test/features/ai/ai_advice_screen_test.dart`
  - Why: The no-wait behavior is the key user promise.
  - Expected result: Tests prove local advice appears without calling AI and remains visible during AI loading/failure.
  - Inputs: `contracts/ai-advice-speed-contract.md`, `ai_advice_screen.dart`.
  - Implementation notes: Use fake local summary/cache and fake AI client.
  - Possible bugs: Test accidentally waits for network or relies on timers.
  - Fix strategy: Inject fakes and assert synchronously after pump.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test/features/ai/ai_advice_screen_test.dart`

## Phase 4: Fast On-Demand AI Request (P1)

**Goal**: AI advice sends only a tiny prepared summary after explicit user action.

**Independent Test**: Tap Ask AI and assert the request body is compact, contains no raw transactions, and local advice remains visible if the request fails.

- [x] T016 [P] [US3] Add compact advice request mapper in `lib/features/ai/domain/ai_advice_request_mapper.dart`
  - Why: The app needs one safe conversion from local summary to gateway payload.
  - Expected result: Mapper creates `AiGatewayAdviceRequest` with locale, currency, period, client request id, and compact summary only.
  - Inputs: `lib/features/ai/data/ai_gateway_models.dart`, `AdviceSummary`, `contracts/ai-advice-speed-contract.md`.
  - Implementation notes: Exclude descriptions, merchants, receipt text, full transaction lists, email, and phone.
  - Possible bugs: Future fields accidentally leak raw rows.
  - Fix strategy: Add deny-list tests for sensitive keys and payload size.
  - Verification: `test/features/ai/ai_advice_payload_test.dart`

- [x] T017 [P] [US3] Add payload-size tests in `test/features/ai/ai_advice_payload_test.dart`
  - Why: The "very fast sending" requirement needs a measurable cap.
  - Expected result: Typical payload under 10 KB and heavy dataset fallback under 25 KB.
  - Inputs: `contracts/ai-advice-speed-contract.md`, `ai_advice_request_mapper.dart`.
  - Implementation notes: Generate large local summary fixtures without raw rows.
  - Possible bugs: Test measures Dart object size instead of serialized JSON.
  - Fix strategy: Use `jsonEncode(request.toJson())` byte length.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test/features/ai/ai_advice_payload_test.dart`

- [x] T018 [US3] Add AI gateway timeout support in `lib/features/ai/data/ai_gateway_client.dart`
  - Why: Slow AI must not trap the user on a waiting state.
  - Expected result: AI calls use a short timeout and map timeout to a safe user message.
  - Inputs: `ai_gateway_client.dart`, `ai_gateway_models.dart`, `contracts/ai-advice-speed-contract.md`.
  - Implementation notes: Keep existing safe error mapping. Do not expose raw provider responses.
  - Possible bugs: Timeout wraps all errors as network, hiding quota or invalid request.
  - Fix strategy: Apply timeout only around the HTTP call and preserve response error handling.
  - Verification: Existing `test/features/ai/ai_gateway_client_test.dart` plus new timeout case.

- [x] T019 [US3] Connect Ask AI action in `lib/features/ai/presentation/ai_advice_screen.dart`
  - Why: AI must run only after explicit user tap.
  - Expected result: Button sends cached summary, shows loading near AI section, and never removes local advice.
  - Inputs: `ai_advice_screen.dart`, `AiGatewayClient`, `ai_advice_request_mapper.dart`, `advice_summary_cache.dart`.
  - Implementation notes: Disable duplicate taps while a request is in flight. Reuse cached advice when summary hash has not changed.
  - Possible bugs: Multiple requests fire, local advice disappears, or auth-required message blocks local tips.
  - Fix strategy: Add state machine test for idle/loading/success/error/cache-hit.
  - Verification: `test/features/ai/ai_advice_screen_test.dart`

- [x] T020 [US3] Add local AI advice cache in `lib/features/ai/domain/ai_advice_cache.dart`
  - Why: Repeating the same AI request wastes time and quota.
  - Expected result: Last AI advice is reused when summary hash, period, and locale match and cache is fresh.
  - Inputs: `data-model.md`, `AdviceSummary`, `AiGatewayAdviceResponse`.
  - Implementation notes: Store cache locally only. Do not store provider secrets or raw request bodies.
  - Possible bugs: Cache shows stale advice after big spending changes.
  - Fix strategy: Key cache by summary hash and invalidate on significant summary change.
  - Verification: Focused cache tests.

- [x] T021 [US3] Update Worker advice validation in `workers/ai-gateway/src/handlers/financialAdvice.ts`
  - Why: Gateway should enforce compact summary-only advice requests.
  - Expected result: `/aiAdvice` rejects missing summary and can reject oversized or raw-row-looking payloads.
  - Inputs: `contracts/ai-advice-speed-contract.md`, `workers/ai-gateway/src/ai/providerTypes.ts`.
  - Implementation notes: Keep Firebase bearer auth if current quota protection depends on it. Do not log full summaries.
  - Possible bugs: Worker rejects valid summary because of strict key names.
  - Fix strategy: Validate size and forbidden raw keys first, keep summary schema flexible.
  - Verification: `cmd /c npm --prefix workers/ai-gateway test -- financialAdvice`

- [x] T022 [P] [US3] Update advice prompt guardrails in `workers/ai-gateway/src/ai/promptBuilder.ts`
  - Why: AI must use only the compact summary and not invent transactions.
  - Expected result: Prompt emphasizes summary-only facts, short practical advice, no invented raw transactions.
  - Inputs: `workers/ai-gateway/src/ai/promptBuilder.ts`, `contracts/ai-advice-speed-contract.md`.
  - Implementation notes: Do not include raw user financial rows in prompt.
  - Possible bugs: Advice becomes too vague if summary fields are weak.
  - Fix strategy: Improve summary fields locally, not by sending raw rows.
  - Verification: Worker prompt/unit tests if present.

## Phase 5: Premium And Ads Without Financial Backend (P2)

**Goal**: Ads and premium behavior work without a custom financial-data backend.

**Independent Test**: Simulate free/premium states. Free can see allowed ads; premium sees no ads; expense save and AI typing are never blocked.

- [x] T023 [P] [US4] Update purchase service wording in `lib/monetization/services/purchase_service.dart`
  - Why: Current text says server entitlement verification is needed. New plan uses store purchase state plus local cache.
  - Expected result: Service wording and behavior match local entitlement snapshot approach.
  - Inputs: `contracts/monetization-contract.md`, `lib/monetization/models/entitlement_snapshot.dart`.
  - Implementation notes: Do not fake successful premium purchase. Keep unavailable states honest until store billing is integrated.
  - Possible bugs: UI implies premium works when billing is not wired.
  - Fix strategy: Separate "local entitlement cache design" from "billing provider not implemented yet".
  - Verification: `test/monetization/free_premium_screen_test.dart`

- [x] T024 [P] [US4] Centralize ad-blocking rules in `lib/monetization/services/ad_service.dart`
  - Why: Ads must not interrupt expense save, active typing, or AI parsing.
  - Expected result: Ad policy exposes allowed/blocked placements and respects premium state.
  - Inputs: `contracts/monetization-contract.md`, `lib/monetization/cubit/monetization_cubit.dart`.
  - Implementation notes: Keep ads disabled if provider is not wired, but make future rules explicit.
  - Possible bugs: Ad state says show ads while provider unavailable.
  - Fix strategy: Separate policy eligibility from provider availability.
  - Verification: `test/monetization/local_entitlement_ads_test.dart`

- [x] T025 [US4] Add monetization tests in `test/monetization/local_entitlement_ads_test.dart`
  - Why: Premium/ads must not create a hidden backend dependency.
  - Expected result: Tests cover free, premium, unknown entitlement, provider unavailable, blocked placements.
  - Inputs: `lib/monetization/`, `contracts/monetization-contract.md`.
  - Implementation notes: Use fake services, not store SDKs.
  - Possible bugs: Tests duplicate implementation details.
  - Fix strategy: Assert behavior: show/hide ads and premium flags.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\local_entitlement_ads_test.dart`

- [x] T026 [US4] Update premium screen copy in `lib/monetization/presentation/free_premium_screen.dart`
  - Why: User-facing copy should not promise server entitlement storage or unavailable features.
  - Expected result: Premium page says no ads and higher AI limits are planned/available according to actual services.
  - Inputs: `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`, `contracts/monetization-contract.md`.
  - Implementation notes: Keep beginner-friendly wording and no mock premium state.
  - Possible bugs: Text overflows on Arabic mobile widths.
  - Fix strategy: Add widget test at narrow width if copy changes significantly.
  - Verification: Focused premium screen test.

## Phase 6: User Trust And Local-Only UI (P2)

**Goal**: Users understand what is stored locally, what is sent to AI, and what is not backed up.

- [x] T027 [P] [US5] Add local-only strings to `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`
  - Why: The app needs clear Arabic/English wording about local storage and AI summary sending.
  - Expected result: Localized strings for local-only data, data-loss risk, and AI summary consent.
  - Inputs: `contracts/local-only-data-contract.md`, `contracts/ai-advice-speed-contract.md`.
  - Implementation notes: Avoid technical wording like Firestore/PostgreSQL in user-facing text.
  - Possible bugs: Generated localization files become stale.
  - Fix strategy: Run `flutter gen-l10n` after ARB edits.
  - Verification: `& 'C:\flutter\bin\flutter.bat' gen-l10n`

- [x] T028 [US5] Add AI summary consent/info row in `lib/features/ai/presentation/ai_advice_screen.dart`
  - Why: User should know AI receives a small summary only when they tap.
  - Expected result: Advice screen explains summary-only sending near Ask AI action.
  - Inputs: `contracts/ai-advice-speed-contract.md`, localized strings.
  - Implementation notes: Keep it short; do not create a scary legal panel.
  - Possible bugs: UI becomes cluttered or pushes button off-screen.
  - Fix strategy: Use compact text and existing spacing tokens.
  - Verification: Advice screen widget test for text and no overflow.

- [x] T029 [US5] Remove or hide cloud sync claims in `lib/features/settings/presentation/settings_screen.dart`
  - Why: The app must not imply cloud backup exists after choosing local-only.
  - Expected result: Any sync/backup/cloud wording is hidden, removed, or clearly marked unavailable.
  - Inputs: settings screen, localization strings, local-only contract.
  - Implementation notes: Export/import remains removed/out of scope.
  - Possible bugs: A route still points to removed backup/export action.
  - Fix strategy: Search settings routes/actions and remove dead entry points.
  - Verification: Focused settings action tests.

## Phase 7: Focused Verification And Guardrails

**Purpose**: Prove the implementation matches the plan without wasting time on broad unrelated failures.

- [x] T030 [Verification] Run local-only repository tests
  - Why: Confirms app-data storage defaults to local repositories.
  - Expected result: Local-only factory and no-cloud-write tests pass.
  - Inputs: T002-T005.
  - Implementation notes: If Flutter sandbox lockfile fails, rerun outside sandbox as allowed by project rules.
  - Possible bugs: Flutter command hangs.
  - Fix strategy: Follow `docs/agent-playbooks/subagent-execution-rules.md` and stop after repeated hang.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\packages\expense_repository\local_only_repository_factory_test.dart`

- [x] T031 [Verification] Run AI summary and payload tests
  - Why: Confirms the speed/privacy promise is measurable.
  - Expected result: Summary builder, payload size, cache, and advice screen tests pass.
  - Inputs: T010-T020.
  - Implementation notes: Tests should not call real network.
  - Possible bugs: Size test fails from extra fields.
  - Fix strategy: Remove raw/verbose fields or cap arrays.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\ai\advice_summary_builder_test.dart test\features\ai\ai_advice_payload_test.dart test\features\ai\ai_advice_screen_test.dart`

- [x] T032 [Verification] Run monetization focused tests
  - Why: Confirms premium/ads do not depend on a financial-data backend.
  - Expected result: Free/premium/ad placement tests pass.
  - Inputs: T023-T026.
  - Implementation notes: No real billing or ad network calls in tests.
  - Possible bugs: Existing tests expect old unavailable wording.
  - Fix strategy: Update tests to the new product wording while keeping honesty.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\local_entitlement_ads_test.dart test\monetization\free_premium_screen_test.dart`

- [x] T033 [Verification] Run worker advice tests
  - Why: Confirms gateway accepts compact summaries and rejects invalid advice bodies.
  - Expected result: `/aiAdvice` tests pass without exposing secrets.
  - Inputs: T021-T022.
  - Implementation notes: Use existing npm worker tests only.
  - Possible bugs: Network/dependency install needed.
  - Fix strategy: If npm dependency issue is unrelated, report exact command and stop.
  - Verification: `cmd /c npm --prefix workers/ai-gateway test -- financialAdvice`

- [x] T034 [Verification] Run scoped analyzer on touched files only
  - Why: Confirms changed Dart files are clean without triggering unrelated project-wide failures.
  - Expected result: Analyzer passes for touched production and test files.
  - Inputs: All changed Dart files.
  - Implementation notes: Do not run full-project analyzer unless Mohamed asks for final release readiness.
  - Possible bugs: Analyzer reports unrelated files if glob is too broad.
  - Fix strategy: Pass exact touched file paths.
  - Verification: `& 'C:\flutter\bin\flutter.bat' analyze <touched files>`

- [x] T035 [Verification] Run guardrail searches
  - Why: Catches accidental cloud data writes and raw AI payload leaks.
  - Expected result: Any Firebase/VPS hits are legacy-only or outside local-only runtime path; AI advice path contains no raw transaction list sending.
  - Inputs: `lib`, `packages/expense_repository`, `workers/ai-gateway`.
  - Implementation notes: Inspect hits manually; do not delete unrelated legacy files unless a task owns it.
  - Possible bugs: False positives from documentation/comments.
  - Fix strategy: Classify each hit as allowed legacy/gateway/auth or forbidden local-only app-data path.
  - Verification:
    `rg -n "FirebaseExpenseRepo|FirebaseCategoryRepository|FirebaseBudgetRepository|FirebaseSettingsRepository|FirebaseWalletAccountRepository|Vps|vpsLocalFirst|Firestore|FirebaseFirestore" lib packages/expense_repository`

- [ ] T036 [Verification] Manual offline and speed smoke check on device
  - Why: The user cares about perceived speed and no waiting.
  - Expected result: Offline core app works; local advice appears immediately; Ask AI sends quickly and handles timeout/failure.
  - Inputs: Implemented app, connected Android device.
  - Implementation notes: Use `flutter devices` first. If no phone appears, report it instead of wasting time.
  - Possible bugs: Device not detected, adb unauthorized, or Flutter lockfile issue.
  - Fix strategy: Follow device troubleshooting only once, then report exact blocker.
  - Verification: Device run plus manual checklist from `quickstart.md`.
  - Status note 2026-05-31: `flutter devices` showed only Windows, Chrome, and
    Edge. No Android phone/emulator was detected, so device smoke check remains
    pending.

## Dependencies And Execution Order

- T001-T003 establish guardrails.
- T004-T007 are blocking for true local-only app startup.
- T010-T015 can start after local repositories are available.
- T016-T022 depend on `AdviceSummary`.
- T023-T026 can run in parallel with AI work if files do not overlap.
- T027-T029 depend on product wording decisions and should land before final UI checks.
- T030-T036 are final focused verification tasks.

## Parallel Execution Examples

- Agent A: T004-T007 local-only runtime and app boot.
- Agent B: T010-T015 summary/local advice UI.
- Agent C: T016-T022 AI payload/gateway speed contract.
- Agent D: T023-T026 premium/ads.

Each agent must own exact files and stop at unrelated failures.

## MVP Scope

MVP is T002-T007 plus T010-T019:

- App boots into local-only financial data mode.
- Core app is not blocked by login.
- Advice screen shows local tips immediately.
- Ask AI sends compact summary only after tap.

Premium/ads and trust wording are next, but should not block the local-only data cutover if Mohamed wants fastest delivery.
