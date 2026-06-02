# Tasks: Entry Quota And Rewarded Ads

**Input**: Design documents from `specs/032-entry-quota-rewarded-ads/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [quickstart.md](./quickstart.md), [contracts/](./contracts/)

**Project Type**: Production Flutter app with local-only financial data and explicit AI/server/ad actions when owned by the feature

## Mandatory First Read And Skill Gate

Before generating or executing tasks, the agent MUST read:

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.agents/MANDATORY_RULES.md`
- `.agents/workflows/development.md`
- `.agents/skill-matcher.json`
- This Spec Kit feature folder
- Relevant Spec Kit, production Flutter, Dart unit test, Flutter widget test, static-analysis, and second-agent review skills

**Skills used for this task list**:

- `second-agent-solution-review`
- `speckit-specify`
- `speckit-plan`
- `speckit-tasks`

## Non-Negotiable Rules

- Keep work scoped to exact task files.
- Do not perform broad repo analysis.
- Do not run full-project `flutter analyze` or full `flutter test` during normal execution.
- Run focused tests first.
- Stop after the first unrelated failure and report it.
- Do not retry a hanging Flutter command more than twice.
- No secrets in Flutter/mobile code.
- No fake rewarded-ad success.
- App-owned financial data must not be written to Firestore/PostgreSQL/VPS sync.
- Premium users must see no ads.
- Ads must not interrupt expense entry, saving, AI typing, or AI parsing.
- Arabic RTL and English LTR must remain usable.

## Phase 1: Setup And Guardrails

**Purpose**: Lock scope and prevent fake ad rewards or financial cloud writes before implementation starts.

- [X] T001 [Guardrail] Confirm active feature scope in `specs/032-entry-quota-rewarded-ads/tasks.md`
  - Why: Later workers need exact ownership and must not broaden into a full monetization rewrite.
  - Expected result: The task list owns quota, rewarded ads, safe banner/inline placements, premium bypass, and gateway quota alignment only when touched.
  - Inputs: `AGENTS.md`, `.specify/memory/constitution.md`, `specs/032-entry-quota-rewarded-ads/plan.md`.
  - Implementation notes: Do not add Firestore/PostgreSQL/VPS quota storage. Do not grant credits from placeholder ads.
  - Possible bugs: A worker starts broad repo analysis or runs full-project checks.
  - Fix strategy: Split work back into the focused tasks below and use focused tests first.
  - Verification: Manual review of this task list and exact owned paths.

- [X] T002 [P] [Guardrail] Add no-fake-reward tests in `test/monetization/rewarded_ad_quota_test.dart`
  - Why: The app must never add credits when the ad provider is unavailable, skipped, dismissed, or duplicated.
  - Expected result: Tests fail until `AdService` and quota grant handling support verified rewarded results.
  - Inputs: `contracts/rewarded-ads-contract.md`, `lib/monetization/services/ad_service.dart`, `test/monetization/monetization_honesty_test.dart`.
  - Implementation notes: Use fake ad services in tests only. Production `UnavailableAdService` must return no reward.
  - Possible bugs: Test grants credits without checking provider result.
  - Fix strategy: Assert exact result status and credit delta for every ad outcome.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\rewarded_ad_quota_test.dart`
  - Worker D note (2026-06-02): Added focused no-fake-reward tests for unavailable, dismissed, skipped, failed, verified, and duplicate reward outcomes. Verified in the focused monetization test command listed in the Worker D final report.

## Phase 2: Quota Foundation

**Purpose**: Build the local quota model and service before touching screens.

- [X] T003 [P] [Foundation] Add quota policy tests in `test/monetization/entry_quota_policy_test.dart`
  - Why: The product math must be locked before UI integration.
  - Expected result: Tests cover 5 normal entries, 3 AI entries, daily reset, premium bypass, no AI double-wall, failed save no consumption, and duplicate operation no double consumption.
  - Inputs: `contracts/quota-contract.md`, `data-model.md`.
  - Implementation notes: Keep tests independent from widgets and real ad SDK.
  - Possible bugs: AI tests accidentally consume normal quota.
  - Fix strategy: Assert normal and AI balances separately after AI saves.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\entry_quota_policy_test.dart`

- [X] T004 [Foundation] Implement quota models in `lib/monetization/models/entry_quota.dart`
  - Why: Screens and services need one shared vocabulary for balances, consumption, reward grants, and premium bypass.
  - Expected result: Models represent local account scope, daily quota snapshot, consumption operation, reward grant, and result states.
  - Inputs: T003, `data-model.md`, `contracts/quota-contract.md`.
  - Implementation notes: Keep models pure Dart. Do not import Flutter widgets or ad SDK here.
  - Possible bugs: Date handling uses full timestamp and fails daily reset.
  - Fix strategy: Store and compare normalized local date values.
  - Verification: Run T003 focused test.

- [X] T005 [P] [Foundation] Add local quota store tests in `test/monetization/local_entry_quota_store_test.dart`
  - Why: Quota must survive app restart and must not use cloud storage.
  - Expected result: Tests cover load, save, daily reset, duplicate consumption ID, duplicate reward event ID, and restart persistence using a temp local store.
  - Inputs: `data-model.md`, `contracts/quota-contract.md`, current local storage dependencies in `pubspec.yaml`.
  - Implementation notes: Use temp directories in tests. Do not require real Firebase, network, or ad SDK.
  - Possible bugs: Test only checks in-memory state and misses persistence.
  - Fix strategy: Recreate the store from the same temp path and assert state reloads.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\local_entry_quota_store_test.dart`

- [X] T006 [Foundation] Implement local quota store in `lib/monetization/services/local_entry_quota_store.dart`
  - Why: Quota and reward grants need durable local persistence outside screen state.
  - Expected result: Store can load snapshots, consume operations idempotently, grant reward events idempotently, and reset by local day.
  - Inputs: T005, `data-model.md`, `lib/monetization/models/entry_quota.dart`.
  - Implementation notes: Store only quota metadata, not expense descriptions or raw AI text. Keep financial data local-only.
  - Possible bugs: Corrupted local file/table crashes Save flow.
  - Fix strategy: Surface a quota-unavailable state and keep a recoverable backup/default path.
  - Verification: Run T005 focused test.

- [X] T007 [Foundation] Implement quota service and cubit in `lib/monetization/services/entry_quota_service.dart` and `lib/monetization/cubit/entry_quota_cubit.dart`
  - Why: Screens should not contain quota math or persistence details.
  - Expected result: Cubit exposes remaining normal/AI entries, premium bypass, blocked reasons, consume-after-success methods, and reward-grant methods.
  - Inputs: T003-T006, `lib/monetization/cubit/monetization_cubit.dart`, `lib/monetization/models/entitlement_snapshot.dart`.
  - Implementation notes: Keep premium source as local entitlement state. Do not call ad SDK or gateway from quota service.
  - Possible bugs: Cubit emits stale count after save or reward.
  - Fix strategy: Reload snapshot after every consume/grant and test emitted states.
  - Verification: Run T003 and T005 plus focused cubit assertions in `entry_quota_policy_test.dart`.

- [X] T008 [P] [Foundation] Replace stub gate behavior in `lib/feature_flags/feature_gate_service.dart`
  - Why: `canUseAI()` currently always passes because `_dailyAiCount()` returns 0.
  - Expected result: Feature gate no longer pretends AI quota is real; AI quota decisions come from `EntryQuotaCubit` or an explicit unavailable state.
  - Inputs: `lib/feature_flags/feature_gate_service.dart`, T007.
  - Implementation notes: Keep advanced reports and remove-ads gates unchanged unless directly needed.
  - Possible bugs: Older screens still call `canUseAI()` and bypass quota.
  - Fix strategy: Search focused AI entry paths and route them to the new quota service.
  - Verification: `rg -n "canUseAI\\(|_dailyAiCount" lib test`

## Phase 3: Manual Entry Quota (US1)

**Goal**: Manual expense saves use the normal daily quota clearly and fairly.

**Independent Test**: Save 5 manual expenses, confirm the sixth opens the reward sheet, and failed saves consume no quota.

- [X] T009 [P] [US1] Add manual save quota tests in `test/features/expenses/add_expense_quick_quota_test.dart`
  - Why: The manual entry screen is the first core flow affected by quota.
  - Expected result: Tests cover visible remaining count, 5 successful saves, sixth blocked, failed save no consumption, premium bypass, and no ad during active save.
  - Inputs: `contracts/quota-contract.md`, `lib/features/expenses/presentation/add_expense_quick_screen.dart`, `lib/features/expenses/create_expense_bloc/create_expense_bloc.dart`.
  - Implementation notes: Use fake quota cubit/store and fake repositories. Do not show fake financial data.
  - Possible bugs: Test consumes quota before `CreateExpenseSuccess`.
  - Fix strategy: Assert count changes only after success state.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_quick_quota_test.dart`
  - Controller note (2026-06-02): Added focused widget tests for visible normal quota, consume-after-success, failed save no consumption, sixth save block, rewarded +5 grant, and premium bypass. Replaced temp-file quota store in this widget test with an in-memory fake store after the file-based setup caused Flutter test loading to hang. Verified with the focused test command.

- [X] T010 [US1] Wire normal quota into `lib/features/expenses/presentation/add_expense_quick_screen.dart`
  - Why: The screen must prevent saves only when the free normal quota is exhausted and show the correct next action.
  - Expected result: Remaining count appears, Save checks quota before dispatch, quota is consumed after success, and quota block opens the normal reward sheet.
  - Inputs: T009, T007, existing `showAppToast`, `GradientButton`, app theme.
  - Implementation notes: Keep wallet optional behavior. Do not add ad banner to this screen.
  - Possible bugs: Back navigation or toast fires before quota update completes.
  - Fix strategy: Keep save-state listener ordered: local save success, quota consume, refresh/list navigation.
  - Verification: Run T009 and touched-file analyzer for the screen, quota files, and test.
  - Controller note (2026-06-02): Wired normal quota status, pre-save quota decision, consume-after-success, normal rewarded sheet, verified reward grant, premium bypass behavior, and guarded async bottom-sheet context. Verified by T009 focused test.

## Phase 4: AI Entry Quota (US2)

**Goal**: AI expense saves use AI complete-entry quota without normal-entry double blocking.

**Independent Test**: Save 3 AI expenses, confirm the fourth opens the AI reward sheet, and gateway parse failures do not consume local AI save credit.

- [X] T011 [P] [US2] Add AI save quota tests in `test/features/expenses/add_expense_ai_text_quota_test.dart`
  - Why: AI is the main monetization feature and must not be double-blocked.
  - Expected result: Tests cover visible AI count, 3 successful AI saves, fourth blocked, failed save no consumption, parse failure no consumption, local parser save consumes AI credit, and premium bypass.
  - Inputs: `contracts/quota-contract.md`, `contracts/ai-gateway-quota-contract.md`, `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`, `lib/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart`.
  - Implementation notes: Mock gateway and repository; do not call real AI or network.
  - Possible bugs: AI save consumes normal quota or consumes at parse time.
  - Fix strategy: Assert normal balance is unchanged after AI saves and AI balance changes only after saved state.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_quota_test.dart`
  - Controller note (2026-06-02): Added focused widget/unit coverage for visible AI count, successful AI save consumption, failed save no consumption, local parser save, fourth-save block, rewarded +2 grant, premium bypass, and gateway 429 separation. Replaced temp-file quota store in this widget test with an in-memory fake store after the file-based setup caused Flutter test loading to hang. Verified with the focused test command.

- [X] T012 [US2] Wire AI quota into `lib/features/expenses/presentation/add_expense_ai_text_screen.dart` and `lib/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart`
  - Why: The AI screen needs a clear remaining count and a safe block before save when AI entries are exhausted.
  - Expected result: AI remaining count appears, AI Save checks local AI credit, successful AI save consumes exactly 1 AI credit, and exhausted AI quota opens AI reward sheet.
  - Inputs: T011, T007, `contracts/ai-gateway-quota-contract.md`.
  - Implementation notes: Keep gateway quota errors separate from local save quota. Do not call gateway just to check local quota.
  - Possible bugs: Gateway quota block is confused with local rewarded-ad flow.
  - Fix strategy: Separate messages: gateway parse limit means try later/sign in; local save limit means watch AI reward ad or premium.
  - Verification: Run T011 and touched-file analyzer for AI screen/cubit/quota files/test.
  - Controller note (2026-06-02): Wired AI quota status, pre-save local AI quota decision, consume-after-saved behavior, AI rewarded sheet, verified +2 grant, premium bypass, and distinct gateway quota behavior. No cubit production changes were required. Verified by T011 focused test.

## Phase 5: Rewarded Ad Flow (US2)

**Goal**: Rewarded ads grant exactly the promised entry credits after verified completion.

**Independent Test**: Complete, fail, dismiss, duplicate, and unavailable rewarded ad outcomes in focused tests.

- [X] T013 [US2] Extend ad service contract in `lib/monetization/services/ad_service.dart`
  - Why: Current `AdService` has no rewarded-ad result API, so it cannot safely grant credits.
  - Expected result: `AdService` supports rewarded placements and returns explicit reward result states without granting by itself.
  - Inputs: T002, `contracts/rewarded-ads-contract.md`, `test/monetization/local_entitlement_ads_test.dart`.
  - Implementation notes: Preserve existing blocked placements for core flows. `UnavailableAdService` must return unavailable/no reward.
  - Possible bugs: Existing tests break because fake ad services do not implement the new method.
  - Fix strategy: Update test fakes to implement the new method and assert unavailable behavior.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\local_entitlement_ads_test.dart test\monetization\rewarded_ad_quota_test.dart`
  - Worker D note (2026-06-02): Added rewarded normal/AI ad placements plus explicit rewarded result states. `UnavailableAdService` returns only unavailable/no verified reward. Verified with focused monetization tests and scoped analyzer.

- [X] T014 [US2] Add rewarded grant orchestration in `lib/monetization/cubit/monetization_cubit.dart` and `lib/monetization/cubit/entry_quota_cubit.dart`
  - Why: Rewarded ad completion must translate into exactly one local quota grant.
  - Expected result: Manual reward grants +5 normal entries; AI reward grants +2 complete AI entries; failed outcomes grant 0; duplicates grant 0.
  - Inputs: T013, T007, `contracts/rewarded-ads-contract.md`.
  - Implementation notes: The ad service reports outcome; quota cubit persists grant idempotently. Do not put credits in UI-only state.
  - Possible bugs: Reward granted before ad starts or after a duplicated callback.
  - Fix strategy: Grant only from the verified result and store reward event ID.
  - Verification: Run T002 and reward-focused tests.
  - Worker D note (2026-06-02): `MonetizationCubit` now requests rewarded ads and `EntryQuotaCubit` grants only verified reward event IDs through the local quota service. Duplicate reward IDs return duplicate with no extra grant. Verified with `rewarded_ad_quota_test.dart`.

- [X] T015 [P] [US2] Add reward sheet widget tests in `test/monetization/rewarded_quota_sheet_test.dart`
  - Why: The user must clearly see what reward they get before watching the ad.
  - Expected result: Tests cover Arabic/English copy, manual +5 promise, AI +2 promise, unavailable provider state, loading state, and no overflow at 360px.
  - Inputs: `contracts/rewarded-ads-contract.md`, app theme files, T014.
  - Implementation notes: Use existing sheet/card/button styling. Do not create a new visual language.
  - Possible bugs: Long Arabic copy overflows the button or sheet.
  - Fix strategy: Use responsive text wrapping and existing spacing tokens.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\rewarded_quota_sheet_test.dart`
  - Worker D note (2026-06-02): Added widget tests for English manual +5, English AI +2, Arabic RTL copy at 360px, unavailable state, loading state, and CTA tap. Verified in focused monetization test command.

- [X] T016 [US2] Implement reward sheet widgets in `lib/monetization/widgets/rewarded_quota_sheet.dart` and quota count widgets in `lib/monetization/widgets/entry_quota_status.dart`
  - Why: Manual and AI screens need shared, consistent quota UI.
  - Expected result: Reusable widgets show remaining entries and reward actions with the correct copy and disabled/unavailable states.
  - Inputs: T015, app theme tokens, `lib/core/widgets/glass_bottom_sheet.dart`, `lib/core/widgets/gradient_button.dart`.
  - Implementation notes: Keep text localizable and RTL-ready. Do not place ads near input fields.
  - Possible bugs: Widgets assume a provider exists and show a broken CTA.
  - Fix strategy: Render "Ads unavailable" state when ad provider is unavailable.
  - Verification: Run T015 and affected screen tests T009/T011.
  - Worker D note (2026-06-02): Added shared `RewardedQuotaSheet` and `EntryQuotaStatus` using existing glass sheet/card, gradient button, theme colors, spacing, and RTL/LTR-safe copy. Screen wiring remains deferred to later screen workers by coordination rule.

## Phase 6: Real Ad Provider And Safe Ad Placements (US3)

**Goal**: Enable real ad integration only where safe, while preserving unavailable states if SDK setup is blocked.

**Independent Test**: Free users can see safe ad slots when provider is available; premium users see none; core flows remain ad-free.

- [X] T017 [P] [US3] Add ad placement tests in `test/features/dashboard/home_ads_test.dart` and `test/features/expenses/expenses_inline_ads_test.dart`
  - Why: Banner and inline ads must not overlap Home actions, nav, FAB, or expense rows.
  - Expected result: Tests cover free/premium visibility, provider unavailable state, inline interval after 6 expenses, short list hidden, and no replacement of expense rows.
  - Inputs: `contracts/ad-placement-contract.md`, `lib/features/dashboard/presentation/home_dashboard_screen.dart`, `lib/features/expenses/presentation/expenses_list_screen.dart`.
  - Implementation notes: Use fake monetization state. Do not require real ad SDK in widget tests.
  - Possible bugs: Inline ad changes list item count assertions incorrectly.
  - Fix strategy: Assert expense rows are still present and in order, then assert ad slot count separately.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\dashboard\home_ads_test.dart test\features\expenses\expenses_inline_ads_test.dart`

- [X] T018 [US3] Implement safe ad slot widgets in `lib/monetization/widgets/app_ad_slot.dart`
  - Why: Home and Expenses should reuse one safe wrapper instead of ad layout logic per screen.
  - Expected result: Widget renders no-op/unavailable state safely, renders provider-backed banner/native slot when available, and hides for premium.
  - Inputs: T017, `lib/monetization/cubit/monetization_cubit.dart`, `contracts/ad-placement-contract.md`.
  - Implementation notes: Do not add real ad SDK code here unless T020 owns it. Keep layout stable when hidden.
  - Possible bugs: Hidden ad slot leaves large empty gaps.
  - Fix strategy: Collapse unavailable/premium slot or use a small reserved height only when provider is loading.
  - Verification: Run T017.

- [X] T019 [US3] Wire safe ads into `lib/features/dashboard/presentation/home_dashboard_screen.dart` and `lib/features/expenses/presentation/expenses_list_screen.dart`
  - Why: Mohamed wants remaining ads as banners and between expenses.
  - Expected result: Home has a safe banner area; Expenses list can show inline ad after every 6 expenses; premium hides both; FAB/nav remain clear.
  - Inputs: T017, T018, existing dashboard/expenses tests.
  - Implementation notes: Do not add ads to add-expense screens. Keep `+` FAB lifted above nav.
  - Possible bugs: Inline ad breaks filtering or empty state.
  - Fix strategy: Build display items from filtered expenses plus optional ad separators, never mutate source data.
  - Verification: Run T017 and existing `test\features\expenses\expenses_list_test.dart`, `test\features\dashboard\home_dashboard_test.dart`.

- [ ] T020 [US3] Connect real mobile ad SDK in `pubspec.yaml`, Android config, and `lib/monetization/services/admob_ad_service.dart`
  - Why: Rewarded ads and real banners cannot work with the current unavailable placeholder.
  - Expected result: Real provider can initialize, request test ads through safe configuration, return rewarded callbacks, and fail closed when config is missing.
  - Inputs: T013-T019, `pubspec.yaml`, Android Gradle files, official AdMob Flutter guide.
  - Implementation notes: Use test ad units or dart-define/env config for development. No ad IDs or secrets hardcoded as production credentials. If Android Gradle blocks SDK activation, report `BLOCKED` with exact error.
  - Possible bugs: Android build fails due Gradle/plugin mismatch; release uses test IDs; provider callbacks fire after widget dispose.
  - Fix strategy: Fix Android SDK alignment in this owned task only, add config validation, guard disposed callbacks.
  - Verification: `& 'C:\flutter\bin\flutter.bat' pub get`; focused tests; `& 'C:\flutter\bin\flutter.bat' build apk --debug`

## Phase 7: Premium And Settings Visibility (US4)

**Goal**: Premium is a clear ad-free, quota-free state, and free users understand their remaining entries.

- [X] T021 [P] [US4] Add premium bypass tests in `test/monetization/premium_quota_ads_test.dart`
  - Why: Premium must not accidentally show ads or block saves.
  - Expected result: Tests cover manual save bypass, AI save bypass, rewarded sheet hidden, banner hidden, inline ads hidden.
  - Inputs: `contracts/quota-contract.md`, `contracts/ad-placement-contract.md`, `lib/monetization/`.
  - Implementation notes: Use local entitlement test controls, not real purchases.
  - Possible bugs: Premium hides ads but quota still blocks Save.
  - Fix strategy: Assert both ad policy and quota decision results.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\premium_quota_ads_test.dart`
  - Worker D note (2026-06-02): Added premium bypass tests for manual quota, AI quota, rewarded ad request blocking, banner hiding, inline ad hiding, and avoiding rewarded sheet rendering. Verified in focused monetization test command.

- [X] T022 [US4] Wire premium bypass in `lib/monetization/cubit/entry_quota_cubit.dart`, `lib/monetization/cubit/monetization_cubit.dart`, and affected screens
  - Why: Premium value must be consistent across quota and ads.
  - Expected result: Premium users save without free quota blocks and all ad placements evaluate hidden.
  - Inputs: T021, current entitlement snapshot models.
  - Implementation notes: Do not change purchase verification rules in this task; use existing entitlement source.
  - Possible bugs: Entitlement state changes do not refresh quota/ad UI.
  - Fix strategy: Listen to monetization state changes and reload quota/ad decisions.
  - Verification: Run T021 plus affected screen quota tests.
  - Worker D note (2026-06-02): Wired premium bypass in the owned cubit/API layer: quota decisions and reward grants bypass for premium, and monetization policy blocks rewarded/banner/inline ads for premium. Direct add-expense screen wiring was intentionally not edited because later workers own those screens.

- [X] T023 [P] [US4] Add settings quota visibility tests in `test/features/settings/settings_quota_status_test.dart`
  - Why: Users need a place to understand limits and premium/ad-free value without entering a blocked flow.
  - Expected result: Settings shows free daily limits, remaining counts, premium status, and safe wording for local-only quotas.
  - Inputs: `lib/features/settings/presentation/settings_screen.dart`, T007, T021.
  - Implementation notes: Keep UI consistent with existing Settings sections.
  - Possible bugs: Settings copy implies cloud account tracking.
  - Fix strategy: Use "on this device/account" wording and local-only explanation.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\settings\settings_quota_status_test.dart`
  - Controller note (2026-06-02): Added focused settings tests for free daily local quota visibility and premium ad-free/quota-free wording without cloud-sync wording. Replaced temp-file quota store in this widget test with an in-memory fake store after similar screen tests showed file-backed widget setup could hang. Verified with focused test and scoped analyzer.

- [X] T024 [US4] Add quota status section to `lib/features/settings/presentation/settings_screen.dart`
  - Why: The user should not learn about quota only after Save is blocked.
  - Expected result: Settings displays today's normal and AI remaining entries, ad-free/premium state, and no misleading cloud-sync wording.
  - Inputs: T023, existing Settings design.
  - Implementation notes: Match existing Settings cards/list items. Do not add new colors.
  - Possible bugs: Settings rebuild causes quota store reload loops.
  - Fix strategy: Use cubit state and avoid starting load in build repeatedly.
  - Verification: Run T023 and touched-file analyzer.
  - Controller note (2026-06-02): Added a Settings quota section using existing card/list styling. It shows manual/AI remaining counts, local device/account wording, premium ad-free/quota-free copy, and avoids build-time reload loops. Verified by T023 focused test and scoped analyzer.

## Phase 8: AI Gateway Alignment

**Goal**: Keep AI provider cost protected without confusing local AI save quota.

- [X] T025 [P] [US2] Add gateway quota alignment tests in `workers/ai-gateway/test/quota.test.ts`
  - Why: Gateway request quota protects AI provider cost and must stay separate from local save quota.
  - Expected result: Tests document parse quota limits, safe quota error body, reset time, and no raw financial data required for quota decisions.
  - Inputs: `contracts/ai-gateway-quota-contract.md`, `workers/ai-gateway/src/quota/quotaService.ts`.
  - Implementation notes: Only touch worker if current gateway limits/messages must change to match product. Do not upload local quota state.
  - Possible bugs: Worker tests require unavailable dependencies.
  - Fix strategy: Use existing worker test setup and fake stores/providers.
  - Verification: `cmd /c npm --prefix workers/ai-gateway test -- quota`
  - Worker C note (2026-06-02): Added focused gateway quota tests for identity-only quota input, safe 429 quota body, reset time, and no local reward/quota fields in the gateway response. Verified with `cmd /c npm --prefix workers/ai-gateway test -- quota` (1 file, 10 tests passed).

- [X] T026 [US2] Align gateway quota messages in `workers/ai-gateway/src/quota/quotaService.ts`, `workers/ai-gateway/src/handlers/parseExpense.ts`, and Flutter gateway models if needed
  - Why: Users should understand whether they hit local save quota or gateway AI request quota.
  - Expected result: Gateway quota error remains user-safe and distinct from local rewarded-ad quota.
  - Inputs: T025, `lib/features/ai/data/ai_gateway_models.dart`.
  - Implementation notes: Do not send expense histories or local quota counters to the gateway.
  - Possible bugs: Local UI starts offering an ad for a gateway parse block even though an ad cannot fix gateway auth/rate limits.
  - Fix strategy: Keep local and gateway error states separate in UI tests.
  - Verification: Run T025 and T011.
  - Worker C note (2026-06-02): No production changes needed. Current worker returns `quota_exceeded` with "Daily AI limit reached for this request type.", and Flutter maps it to "AI requests" / "Try later" messaging, which stays distinct from local rewarded-ad quota. T011 remains owned by the AI UI worker.

## Final Phase: Focused Verification And Handoff

- [ ] T027 [Verify] Run focused quota, rewarded ad, and premium tests
  - Why: These are the highest-risk monetization behaviors.
  - Expected result: Quota math, local persistence, rewarded grants, no-fake rewards, and premium bypass pass.
  - Inputs: Completed T003-T024.
  - Implementation notes: Do not run full-project tests unless Mohamed explicitly expands this to release readiness.
  - Possible bugs: Flutter sandbox lockfile failure.
  - Fix strategy: Request approved Flutter command escalation instead of retrying inside sandbox.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\monetization\entry_quota_policy_test.dart test\monetization\local_entry_quota_store_test.dart test\monetization\rewarded_ad_quota_test.dart test\monetization\premium_quota_ads_test.dart`

- [ ] T028 [Verify] Run focused screen tests for manual, AI, Home, Expenses, and Settings
  - Why: User-visible flows must prove quota and ads do not break core tracking.
  - Expected result: Manual save, AI save, Home ads, inline ads, and Settings quota display pass.
  - Inputs: Completed T009-T024.
  - Implementation notes: Use widget tests first, then device/manual checks if needed.
  - Possible bugs: RTL overflow or ad slot overlap.
  - Fix strategy: Fix shared widgets and layout constraints before screen-specific hacks.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_quick_quota_test.dart test\features\expenses\add_expense_ai_text_quota_test.dart test\features\dashboard\home_ads_test.dart test\features\expenses\expenses_inline_ads_test.dart test\features\settings\settings_quota_status_test.dart`

- [ ] T029 [Verify] Run worker quota checks only if worker files changed
  - Why: Gateway quota protects AI cost and should not regress when aligned.
  - Expected result: Worker quota tests pass or are skipped with a clear "worker untouched" note.
  - Inputs: Completed T025-T026 if touched.
  - Implementation notes: Do not install dependencies or run broad npm tasks unless needed.
  - Possible bugs: npm dependency issue unrelated to Flutter.
  - Fix strategy: Report the exact dependency blocker and continue Flutter verification.
  - Verification: `cmd /c npm --prefix workers/ai-gateway test -- quota`

- [ ] T030 [Verify] Run guardrail searches and touched-file analyzer
  - Why: Final check must catch fake rewards, ad interruption regressions, and forbidden cloud storage.
  - Expected result: No owned production code grants credits from unavailable ads, shows ads in blocked placements, or writes app-owned financial data to cloud.
  - Inputs: Completed implementation.
  - Implementation notes: Search hits in docs/tests can be expected; inspect production `lib`/`workers` hits carefully.
  - Possible bugs: False positives from specs or test names.
  - Fix strategy: Classify hits in final handoff instead of deleting unrelated legacy code.
  - Verification: `rg -n "FirebaseFirestore|PostgreSQL|vpsLocalFirst|grant.*unavailable|reward.*fake|expenseSave|expenseEntry|aiTyping|aiParsing|WebView|webview" lib test workers`

- [ ] T031 [Docs] Update task checkboxes and final handoff notes in `specs/032-entry-quota-rewarded-ads/tasks.md`
  - Why: Future agents need exact status and verification evidence.
  - Expected result: Completed tasks are checked only after verification; blockers include command, failure, files changed, and smallest next action.
  - Inputs: All prior tasks and command outcomes.
  - Implementation notes: Do not bulk-mark tasks complete without evidence.
  - Possible bugs: Handoff says done while AdMob remains unavailable.
  - Fix strategy: Separate local quota completion from real ad provider readiness in the final notes.
  - Verification: Manual review of task statuses and final report.

## Dependencies And Execution Order

1. T001-T002 block all implementation.
2. T003-T008 build the quota foundation and block screen work.
3. T009-T010 wire manual quota after foundation.
4. T011-T012 wire AI quota after foundation.
5. T013-T016 wire rewarded ads after quota foundation.
6. T017-T020 wire banner/inline ads and real provider work.
7. T021-T024 complete premium/settings behavior.
8. T025-T026 run only if gateway quota alignment is needed.
9. T027-T031 are final verification and handoff.

## Parallel Opportunities

- T002 and T003 can be prepared in parallel.
- T005 can be prepared while T004 is implemented if model shape is agreed.
- T009 and T011 can be prepared in parallel after T007.
- T015 and T017 can be prepared in parallel because they own different widget tests.
- T021 and T023 can be prepared in parallel.
- T025 can run in parallel with Flutter UI work if worker files are owned by a separate agent.

## MVP Scope

The minimum safe MVP is:

1. T003-T008 quota foundation.
2. T009-T012 manual and AI save quota.
3. T013-T016 rewarded grant flow without fake rewards.
4. T021-T022 premium bypass.
5. T027-T028 focused verification.

Banner/inline ads and real AdMob provider work can be implemented immediately after MVP, but must not block quota correctness.
