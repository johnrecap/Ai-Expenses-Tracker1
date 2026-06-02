# Tasks: Real AI Expense Refactor

**Input**: Design documents from `specs/024-real-ai-expense-refactor/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md), [contracts/](contracts/)

**Project Type**: Production Flutter finance app with secure AI gateway and real user data

## Mandatory First Read And Skill Gate

Completed for task generation:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Searched `.agents/skills/` and `.agent/skills/` for relevant skills.
- Loaded matching `SKILL.md` files.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-apply-architecture-best-practices`, `flutter-setup-localization`, `flutter-use-http-package`, `flutter-fix-layout-issues`, `dart-run-static-analysis`.

## Task Format

Every real task uses a checkbox, sequential task id, area/story label, exact file path, and the detail fields: Why, Expected result, Inputs, Implementation notes, Possible bugs, Fix strategy, Verification, and Stop condition.

## Phase 1: Setup And Safety Guardrails

**Purpose**: Remove the most dangerous security exposure first and establish a baseline before broad refactoring.

- [X] T001 [Setup] Record current baseline in `specs/024-real-ai-expense-refactor/baseline.md`
  - Why: The project already has known analyzer/test failures; recording them prevents confusing old failures with refactor regressions.
  - Expected result: A short baseline file with current `flutter analyze`, `flutter test`, and security-search results.
  - Inputs: `quickstart.md`, current terminal output from previous review.
  - Implementation notes: Do not fix code in this task; only document the current state.
  - Possible bugs: Baseline becomes too verbose or includes secrets from logs.
  - Fix strategy: Summarize counts and failing test names only; never paste secret values or raw `.env`.
  - Verification: `baseline.md` exists and includes commands, outcome, and known failure categories.
  - Stop condition: Baseline file is complete and contains no secret values.

- [X] T002 [Security] Remove Flutter `.env` asset bundling in `pubspec.yaml`
  - Why: `.env` bundled as an app asset can expose secrets in APK/web builds.
  - Expected result: `.env` is no longer listed under Flutter assets.
  - Inputs: `pubspec.yaml`, `contracts/ai-gateway-contract.md`, AGENTS.md security rules.
  - Implementation notes: Keep non-secret assets such as `assets/images/`; do not delete the local `.env` file in this task.
  - Possible bugs: YAML indentation breaks or asset paths are accidentally removed.
  - Fix strategy: Validate `pubspec.yaml` indentation and run `flutter pub get`.
  - Verification: `rg -n "^\\s*- \\.env" pubspec.yaml` returns no production asset hit.
  - Stop condition: `.env` is not packaged by Flutter.

- [X] T003 [Security] Remove Flutter dotenv loading from `lib/main.dart` and `pubspec.yaml`
  - Why: Production Flutter must not read local secret files for AI credentials.
  - Expected result: `main.dart` no longer imports or loads `flutter_dotenv`; dependency is removed if unused.
  - Inputs: `lib/main.dart`, `pubspec.yaml`, `research.md`.
  - Implementation notes: Keep Firebase initialization and analytics behavior intact. Remove only mobile dotenv usage.
  - Possible bugs: Removing the dependency while another file still imports it causes compile errors.
  - Fix strategy: Search all Flutter code for `flutter_dotenv` before removing dependency.
  - Verification: `rg -n "flutter_dotenv|dotenv\\.load|dotenv\\.env" lib pubspec.yaml` has no production Flutter hits.
  - Stop condition: App no longer depends on Flutter dotenv.

- [X] T004 [Security] Replace public AI URL configuration in `lib/core/config/app_config.dart`
  - Why: The app still needs a non-secret gateway URL without shipping private keys.
  - Expected result: `AppConfig.aiGatewayUrl` is the single source for the public gateway base URL.
  - Inputs: `lib/core/config/app_config.dart`, `contracts/ai-gateway-contract.md`.
  - Implementation notes: Use a public compile-time value for URL only. Do not add API keys, tokens, or secrets.
  - Possible bugs: Missing trailing slash or double slash when building endpoint URLs.
  - Fix strategy: Normalize endpoint joining in the gateway client rather than string-concatenating in widgets.
  - Verification: Unit test or simple code review confirms no secret fields exist in `AppConfig`.
  - Stop condition: Public URL is available and private values are absent.

- [X] T005 [Setup] Add shared widget test harness in `test/helpers/app_test_harness.dart`
  - Why: Current widget tests fail because screens are mounted without required providers.
  - Expected result: Tests can pump screens with required auth/bloc/repository scaffolding.
  - Inputs: failing tests under `test/features/auth/` and `test/features/onboarding/`, `app.dart`, `routes_test.dart`.
  - Implementation notes: Use lightweight fake repositories only inside tests. Do not add fake data to production app.
  - Possible bugs: Test harness grows into a second app or masks real provider errors.
  - Fix strategy: Keep harness limited to tests and document every fake dependency.
  - Verification: Update at least one failing auth/onboarding test to use the harness and pass.
  - Stop condition: Harness exists and is used by one previously failing screen test.

## Phase 2: Foundational Architecture

**Purpose**: Create clean boundaries before changing screens so UI does not keep creating services or parsing data directly.

- [X] T006 [Foundation] Create AI gateway result models in `lib/features/ai/data/ai_gateway_models.dart`
  - Why: AI responses need typed safe objects instead of loose maps inside widgets.
  - Expected result: Request, success, quota, error, and draft response models exist.
  - Inputs: `contracts/ai-gateway-contract.md`, `data-model.md`, Worker handler request/response shapes.
  - Implementation notes: Include only safe fields needed by the app. Do not store raw provider responses.
  - Possible bugs: Model names conflict with existing `AiParsedExpense`.
  - Fix strategy: Keep gateway DTOs separate and map to existing app models later.
  - Verification: `flutter analyze` reaches model files without type errors.
  - Stop condition: Typed gateway models compile.

- [X] T007 [Foundation] Create authenticated gateway client in `lib/features/ai/data/ai_gateway_client.dart`
  - Why: All AI calls must go through one safe client instead of widgets calling old proxy paths.
  - Expected result: Client methods exist for parse text, receipt extraction, and advice using `Authorization: Bearer`.
  - Inputs: `contracts/ai-gateway-contract.md`, `lib/core/config/app_config.dart`, `workers/ai-gateway/src/handlers/`.
  - Implementation notes: Get the current user's token from Firebase Auth, use `http`, throw typed safe errors, and never log request bodies.
  - Possible bugs: Token is null, endpoint path is wrong, errors return as raw body.
  - Fix strategy: Add explicit auth-required error, endpoint tests, and safe error mapping.
  - Verification: Unit tests can simulate success, quota failure, auth failure, and network failure.
  - Stop condition: No production code uses `X-API-Key` or old proxy paths.

- [X] T008 [Foundation] Add AI gateway tests in `test/features/ai/ai_gateway_client_test.dart`
  - Why: Security and failure behavior must be locked before UI depends on it.
  - Expected result: Tests cover success, quota, auth, invalid body, and no raw-body logging behavior.
  - Inputs: `ai_gateway_client.dart`, `ai_gateway_models.dart`, `contracts/ai-gateway-contract.md`.
  - Implementation notes: Use fake HTTP client/token provider; do not call the real network.
  - Possible bugs: Tests require real Firebase or real network.
  - Fix strategy: Inject token provider and HTTP sender abstractions for tests.
  - Verification: `flutter test test/features/ai/ai_gateway_client_test.dart`.
  - Stop condition: Gateway client tests pass locally.

- [X] T009 [Foundation] Create AI expense draft state in `lib/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart`
  - Why: AI expense UI needs predictable states: typing, parsing, draft, error, saving, saved.
  - Expected result: Cubit/state handles input text, parse request, draft edits, validation, and save command.
  - Inputs: `data-model.md`, `contracts/ui-state-contract.md`, existing `CreateExpenseBloc`.
  - Implementation notes: Keep UI widgets dumb. Cubit may call gateway client and expense repository/use case.
  - Possible bugs: Duplicate save occurs or edits are lost when parse returns.
  - Fix strategy: Disable save while saving and keep user edits as source of truth.
  - Verification: Unit tests for state transitions and validation.
  - Stop condition: Cubit covers all AI draft states without UI code.

- [X] T010 [Foundation] Create AI-to-expense mapper in `lib/features/expenses/domain/ai_expense_draft_mapper.dart`
  - Why: Mapping gateway output to a real saved expense should not live in widgets.
  - Expected result: A mapper resolves amount, date, category, currency, wallet, source, and description.
  - Inputs: `data-model.md`, `packages/expense_repository/lib/src/models/expense.dart`, category and wallet models.
  - Implementation notes: Missing fields stay missing; do not guess silently when user review is needed.
  - Possible bugs: Date parsing differs between Arabic and English, or category match chooses archived category.
  - Fix strategy: Test date defaults and category matching with explicit fixtures.
  - Verification: Unit tests for full, partial, and ambiguous draft mapping.
  - Stop condition: Mapper never saves or mutates data directly.

- [ ] T011 [Foundation] Extract app provider setup into `lib/app/app_providers.dart`
  - Why: `app.dart` currently mixes app shell, repositories, blocs, and route setup.
  - Expected result: Provider construction is in one dedicated file without changing runtime behavior.
  - Inputs: `lib/app/app.dart`, `plan.md`, existing repository bundle.
  - Implementation notes: Keep this as a mechanical extraction first. Do not change business behavior in the same task.
  - Possible bugs: Provider scope changes break routes or tests.
  - Fix strategy: Move code in small steps and run route/auth tests after extraction.
  - Verification: `flutter analyze` and relevant app route tests.
  - Stop condition: App still boots and providers are in the same effective scope.

- [ ] T012 [Foundation] Extract authenticated app scope into `lib/app/authenticated_scope.dart`
  - Why: Signed-in and signed-out app trees are duplicated and make localization/provider changes risky.
  - Expected result: Authenticated repository/bloc setup is isolated from the root `App`.
  - Inputs: `lib/app/app.dart`, `lib/app/app_providers.dart`.
  - Implementation notes: Preserve bundle creation behavior and user id ownership.
  - Possible bugs: User switch does not rebuild repositories correctly.
  - Fix strategy: Add tests around auth state changes and bundle reset.
  - Verification: Route/auth tests and smoke app build.
  - Stop condition: Signed-in and signed-out flows still route correctly.

## Phase 3: User Story 1 - Add Expense With AI Text (P1)

**Goal**: User can type Arabic/English expense text, review a draft, fix missing fields, and save a real expense.

- [X] T013 [P] [US1] Replace old proxy service usage in `lib/features/ai/services/ai_api_service.dart`
  - Why: Existing service reads mobile `.env` and sends `X-API-Key`.
  - Expected result: Old service is removed, deprecated, or turned into a safe wrapper around the new gateway client.
  - Inputs: `ai_gateway_client.dart`, `contracts/ai-gateway-contract.md`, current `ai_api_service.dart`.
  - Implementation notes: Prefer deleting unsafe behavior if no longer needed. Do not keep fallback to `PROXY_API_KEY`.
  - Possible bugs: Existing widgets still import the old service.
  - Fix strategy: Replace imports with the new cubit/client path and run `rg`.
  - Verification: `rg -n "PROXY_API_KEY|X-API-Key|/parseExpense|/getAdvice" lib`.
  - Stop condition: Old insecure AI path is gone from Flutter production code.

- [X] T014 [US1] Rebuild AI parse panel around cubit in `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
  - Why: The widget currently owns service calls and failure handling.
  - Expected result: Widget displays input, parsing state, draft summary, editable fields, and safe errors from the cubit.
  - Inputs: `ai_expense_entry_cubit.dart`, `ai_expense_draft_mapper.dart`, existing shared widgets.
  - Implementation notes: Reuse `GlassCard`, `GradientButton`, `SearchField` or existing form styles. Keep typed input after failure.
  - Possible bugs: Text field loses focus/state, draft UI overflows, save button is enabled too early.
  - Fix strategy: Keep controllers scoped carefully, use state-driven validation, check narrow viewport.
  - Verification: Widget test for successful parse and failed parse.
  - Stop condition: Panel does not instantiate gateway/service directly.

- [X] T015 [US1] Update AI text screen in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: AI text entry must become a complete user flow, not just a partial form.
  - Expected result: Screen uses the shared AI parse panel and saves confirmed drafts.
  - Inputs: `ai_expense_parse_panel.dart`, `CreateExpenseBloc`, route constants.
  - Implementation notes: On save success, refresh expenses/reports/budgets and navigate consistently.
  - Possible bugs: Save succeeds but list does not update, or duplicate snackbars appear.
  - Fix strategy: Centralize success listener and avoid multiple listeners for same state.
  - Verification: Widget/integration-style test verifies typed text -> draft -> save event.
  - Stop condition: A confirmed AI draft can create a real expense.

- [X] T016 [US1] Update full AI expense screen in `lib/features/expenses/presentation/ai_expense_screen.dart`
  - Why: Duplicate AI entry screens create inconsistent behavior.
  - Expected result: This screen either reuses the new AI entry flow or redirects to the canonical AI text flow.
  - Inputs: `AppRoutes.expensesNewText`, `AppRoutes.expensesNewAi`, existing router.
  - Implementation notes: Avoid maintaining two separate AI parsing UIs.
  - Possible bugs: Routes break or old tests expect old labels.
  - Fix strategy: Update route tests and widget expectations to the canonical UI.
  - Verification: Route tests plus manual navigation from dashboard/expenses.
  - Stop condition: Only one behavior exists for AI text expense entry.

- [X] T017 [US1] Add unit tests in `test/features/expenses/ai_expense_entry_cubit_test.dart`
  - Why: AI expense state is the highest-risk flow and should not regress.
  - Expected result: Tests cover parse success, missing fields, edit draft, save success, quota failure, network failure.
  - Inputs: `ai_expense_entry_cubit.dart`, fake gateway client, fake expense repository.
  - Implementation notes: Tests must not use real network, Firebase, or real secrets.
  - Possible bugs: Test fakes become too different from production models.
  - Fix strategy: Use the same public model classes and only fake transport/repository.
  - Verification: `flutter test test/features/expenses/ai_expense_entry_cubit_test.dart`.
  - Stop condition: State tests pass.

- [X] T018 [US1] Add widget tests in `test/features/expenses/ai_expense_parse_panel_test.dart`
  - Why: Users must see review, missing-field, and failure states clearly.
  - Expected result: Tests verify draft rendering, disabled save, edited save, and error fallback.
  - Inputs: `ai_expense_parse_panel.dart`, shared test harness.
  - Implementation notes: Include Arabic input and a narrow width test.
  - Possible bugs: Text finders break after localization migration.
  - Fix strategy: Prefer keys/semantics for critical controls when labels are localized.
  - Verification: `flutter test test/features/expenses/ai_expense_parse_panel_test.dart`.
  - Stop condition: AI panel widget tests pass.

## Phase 4: User Story 2 - No Mock Data Anywhere (P1)

**Goal**: Production screens show real user data, empty states, or intentional unavailable states.

- [ ] T019 [US2] Audit mock usage and record decisions in `specs/024-real-ai-expense-refactor/mock-removal-audit.md`
  - Why: Mock references are spread across core, AI, dashboard, reports, and tests.
  - Expected result: Each `MockData`, `MockAiService`, placeholder, fake, and stub production hit is classified as remove, replace, quarantine, or test-only.
  - Inputs: `rg -n "MockData|MockAiService|placeholder|fake|stub" lib packages/expense_repository/lib`.
  - Implementation notes: Do not delete files before identifying test dependencies.
  - Possible bugs: Comments/tests produce false positives.
  - Fix strategy: Classify production code separately from test fixtures.
  - Verification: Audit file includes every production hit.
  - Stop condition: No unknown production mock usage remains.

- [ ] T020 [US2] Remove mock dashboard dependencies in `lib/features/dashboard/presentation/home_dashboard_screen.dart`
  - Why: Dashboard is the first screen and must never show fake financial totals.
  - Expected result: Dashboard reads real bloc/repository state and shows empty cards/actions when data is absent.
  - Inputs: `home_dashboard_screen.dart`, expense/budget/wallet blocs, `EmptyState`, `MetricCard`.
  - Implementation notes: Preserve current visual layout and tokens. Do not invent new colors.
  - Possible bugs: Null data causes crashes or layout holes.
  - Fix strategy: Add safe zero/empty calculations and loading/error branches.
  - Verification: Widget tests for empty account and populated account.
  - Stop condition: Dashboard has no production mock imports.

- [ ] T021 [US2] Remove mock AI chat/history dependencies in `lib/features/ai/presentation/`
  - Why: Fake AI messages make the assistant look functional when it is not using real history.
  - Expected result: AI advice/history/assistant screens use real gateway/history data or show empty/unavailable states.
  - Inputs: `ai_advice_screen.dart`, `ai_history_screen.dart`, `ai_assistant_sheet.dart`, `ai_chat_screen.dart`.
  - Implementation notes: If real chat history is not supported yet, show intentional unavailable/empty state instead of fake chat.
  - Possible bugs: Removing fake list leaves blank screens.
  - Fix strategy: Use `EmptyState` with action to try AI expense/advice if available.
  - Verification: `rg -n "MockAiService|MockData" lib/features/ai`.
  - Stop condition: AI screens do not display fake conversation data.

- [ ] T022 [US2] Remove mock subscriptions/goals/report fallbacks in `lib/features/`
  - Why: Financial planning screens must reflect actual user records.
  - Expected result: Goals, subscriptions, reports, budgets, and wallets use repositories/blocs or empty states.
  - Inputs: `lib/features/goals/`, `subscriptions/`, `reports/`, `budgets/`, `wallets/`.
  - Implementation notes: If a feature lacks full create/edit support, keep read/empty state honest and disable unsupported actions clearly.
  - Possible bugs: Screens assume non-empty lists and crash.
  - Fix strategy: Add empty branch before list/chart rendering.
  - Verification: Widget smoke tests for empty lists on each screen.
  - Stop condition: No production fake financial records appear.

- [ ] T023 [US2] Quarantine `lib/core/mock/` for test-only usage
  - Why: Mock files may remain useful for tests but should not leak into production flows.
  - Expected result: Production code does not import `lib/core/mock/`; tests can still use controlled fixtures.
  - Inputs: `lib/core/mock/`, `test/core/mock_test.dart`, mock-removal audit.
  - Implementation notes: Consider moving fixtures to `test/fixtures/` only if it does not create churn.
  - Possible bugs: Moving files breaks many imports.
  - Fix strategy: First remove production imports; move fixtures later if needed.
  - Verification: `rg -n "core/mock|MockData" lib --glob "!lib/core/mock/**"` has no production hits.
  - Stop condition: Mock data is isolated from production app screens.

## Phase 5: User Story 3 - Consistent Expense Entry UI (P2)

**Goal**: All expense entry modes behave as one coherent product flow.

- [ ] T024 [US3] Create shared expense review widget in `lib/features/expenses/presentation/widgets/expense_review_panel.dart`
  - Why: Manual, quick, AI, receipt, and edit screens repeat validation and display patterns.
  - Expected result: A reusable panel displays amount, currency, category, wallet, date, note, errors, and save action.
  - Inputs: Existing `expense_form_card.dart`, `ai_expense_parse_panel.dart`, design tokens.
  - Implementation notes: Keep widget presentation-only; pass values/callbacks from state.
  - Possible bugs: Shared widget becomes too generic or breaks existing forms.
  - Fix strategy: Start with fields needed by AI text and edit flow, then expand.
  - Verification: Widget test for required fields and narrow layout.
  - Stop condition: Review panel compiles and is used by at least AI text entry.

- [ ] T025 [US3] Align quick add in `lib/features/expenses/presentation/add_expense_quick_screen.dart`
  - Why: Quick add should use the same validation and save result behavior as AI/manual.
  - Expected result: Quick add saves real expense and shows consistent errors/success.
  - Inputs: `expense_review_panel.dart`, `CreateExpenseBloc`, categories/wallet state.
  - Implementation notes: Keep quick path fast; do not add unnecessary screens if inline review is enough.
  - Possible bugs: Quick add becomes slower or requires too many taps.
  - Fix strategy: Preserve defaults while using shared validation.
  - Verification: Widget test for invalid amount and successful save.
  - Stop condition: Quick add matches shared validation behavior.

- [ ] T026 [US3] Align receipt add in `lib/features/expenses/presentation/add_expense_receipt_screen.dart`
  - Why: Receipt flow currently has placeholder behavior risk.
  - Expected result: Receipt uses real gateway extraction or clear unavailable/manual fallback.
  - Inputs: `contracts/ai-gateway-contract.md`, `receipt_upload_panel.dart`, gateway client.
  - Implementation notes: Do not return placeholder parsed expenses.
  - Possible bugs: Image picker works but gateway fails silently.
  - Fix strategy: Surface safe error and keep manual entry path visible.
  - Verification: Test simulated unavailable/failed receipt flow.
  - Stop condition: No fake receipt parse result remains.

- [ ] T027 [US3] Align edit expense in `lib/features/expenses/presentation/edit_expense_screen.dart`
  - Why: Editing must share validation expectations with creating.
  - Expected result: Edit screen uses consistent fields, error messages, and save behavior.
  - Inputs: `expense_review_panel.dart`, existing `CreateExpenseBloc` update/delete behavior.
  - Implementation notes: Preserve ability to go back and handle missing expense.
  - Possible bugs: Existing expense values do not populate correctly.
  - Fix strategy: Add test with an existing expense fixture from repository fake.
  - Verification: Widget test for existing value render and successful update.
  - Stop condition: Edit flow remains functional and consistent.

## Phase 6: User Story 4 - Arabic, English, RTL, And LTR (P2)

**Goal**: The app respects selected language and direction across primary screens.

- [ ] T028 [US4] Wire app localization in `lib/app/app.dart`
  - Why: ARB files exist but app locale/delegates are not fully connected.
  - Expected result: `AppLocalizations.delegate` is included and app locale comes from language/settings state.
  - Inputs: `lib/l10n/`, `l10n.yaml`, `AppLanguageCubit`, `SettingsCubit`.
  - Implementation notes: Do not hardcode `Locale('ar')`; use Arabic/English/system preference behavior.
  - Possible bugs: Generated localization import path mismatch.
  - Fix strategy: Run `flutter gen-l10n` and adjust imports to existing generated file path.
  - Verification: Widget test for Arabic and English app shell.
  - Stop condition: App can render both locales.

- [ ] T029 [US4] Migrate bottom navigation strings in `lib/core/widgets/app_bottom_nav.dart`
  - Why: Navigation is visible everywhere and currently uses hardcoded English.
  - Expected result: Nav labels use localized strings.
  - Inputs: `app_en.arb`, `app_ar.arb`, `app_bottom_nav.dart`.
  - Implementation notes: Keep current icon/style and only change text source.
  - Possible bugs: Tests expecting English labels fail in Arabic.
  - Fix strategy: Update tests to run per locale or use localization-aware expectations.
  - Verification: Widget test for nav labels in Arabic and English.
  - Stop condition: Bottom nav localizes correctly.

- [ ] T030 [US4] Migrate auth and settings strings in `lib/features/auth/` and `lib/features/settings/`
  - Why: Auth and settings are high-visibility and currently contain mixed/hardcoded text.
  - Expected result: Login, sign-up, and settings user-facing strings come from ARB.
  - Inputs: `login_screen.dart`, `sign_up_screen.dart`, `auth_panel.dart`, `settings_screen.dart`, ARB files.
  - Implementation notes: Avoid mixed bilingual labels; each locale shows one language.
  - Possible bugs: Missing ARB keys break generation.
  - Fix strategy: Add keys to both ARB files and run `flutter gen-l10n`.
  - Verification: Auth/settings widget tests in both locales.
  - Stop condition: Auth/settings no longer show mixed labels.

- [ ] T031 [US4] Add directional icon helper in `lib/core/layout/directional_icon.dart`
  - Why: Fixed chevrons and arrows point the wrong way in RTL.
  - Expected result: Shared helper returns correct directional icons for back/forward/chevron.
  - Inputs: `directionality_utils.dart`, settings/category/AI widgets with chevrons.
  - Implementation notes: Use helper only for directional icons; non-directional icons stay unchanged.
  - Possible bugs: Icons flip twice when Flutter auto-mirrors.
  - Fix strategy: Test both `TextDirection.ltr` and `TextDirection.rtl`.
  - Verification: Unit/widget test for helper outputs.
  - Stop condition: Helper is used by at least settings chevrons and any repeated directional row.

- [ ] T032 [US4] Add RTL/narrow viewport tests in `test/core/rtl_real_data_flow_test.dart`
  - Why: Narrow Arabic UI is a high-risk product area.
  - Expected result: Smoke tests cover Arabic/English at 360x800 for dashboard, expenses, AI entry, and settings.
  - Inputs: shared test harness, localized app shell, primary screens.
  - Implementation notes: Tests should catch overflow exceptions and missing required controls.
  - Possible bugs: Tests become flaky due async streams.
  - Fix strategy: Use deterministic fake repositories in tests only.
  - Verification: `flutter test test/core/rtl_real_data_flow_test.dart`.
  - Stop condition: Primary screens render at narrow width in both directions.

## Phase 7: User Story 5 - Every Visible Action Works Or Is Clearly Disabled (P3)

**Goal**: No dead buttons or fake features remain visible.

- [ ] T033 [US5] Create action audit in `specs/024-real-ai-expense-refactor/action-audit.md`
  - Why: The app has many screens and actions; untracked dead actions are easy to miss.
  - Expected result: Audit lists primary actions per screen and marks working, needs setup, unavailable, or remove.
  - Inputs: `contracts/ui-state-contract.md`, routes, primary screens.
  - Implementation notes: This is a planning/audit artifact, not code change.
  - Possible bugs: Audit misses nested bottom-sheet actions.
  - Fix strategy: Include main screen buttons and bottom sheet/menu actions.
  - Verification: Audit covers all primary screens listed in contract.
  - Stop condition: Every primary action has a decision.

- [ ] T034 [US5] Fix route constant usage in `lib/app/routes.dart` and `lib/app/router.dart`
  - Why: Hardcoded route strings make navigation fixes inconsistent.
  - Expected result: Dynamic and static routes use `AppRoutes` helpers/constants consistently.
  - Inputs: `router.dart`, `routes.dart`, route tests.
  - Implementation notes: Add helper methods for dynamic route locations if needed.
  - Possible bugs: Dynamic routes use pattern string instead of concrete location.
  - Fix strategy: Keep route patterns separate from location builders.
  - Verification: `flutter test test/app/routes_test.dart test/app/final_ui_contract_test.dart`.
  - Stop condition: Route tests pass.

- [ ] T035 [US5] Replace dead placeholder actions in `lib/features/settings/presentation/settings_screen.dart`
  - Why: Settings includes coming-soon and unimplemented actions that should be clear.
  - Expected result: Each settings action works, navigates, or shows an intentional unavailable/setup message.
  - Inputs: `action-audit.md`, `settings_screen.dart`, account/security/subscription routes.
  - Implementation notes: Preserve existing settings visual style.
  - Possible bugs: Removing items confuses users or breaks tests.
  - Fix strategy: Prefer disabled/unavailable state with explanation when feature is not ready.
  - Verification: Settings widget test taps primary rows.
  - Stop condition: No settings row silently does nothing.

- [ ] T036 [US5] Replace dead placeholder actions in `lib/features/dashboard/presentation/home_dashboard_screen.dart`
  - Why: Dashboard quick actions are highly visible.
  - Expected result: Add, AI, transfer, scan, and report actions route correctly or explain setup/unavailability.
  - Inputs: `action-audit.md`, dashboard screen, routes.
  - Implementation notes: If transfer/scan are incomplete, show clear unavailable state instead of fake flow.
  - Possible bugs: Quick action route creates missing-provider errors.
  - Fix strategy: Add route/provider smoke tests for each action.
  - Verification: Dashboard quick action widget test.
  - Stop condition: All dashboard quick actions have real behavior.

## Final Phase: Verification And Polish

- [ ] T037 [Polish] Run security and mock-data searches from `specs/024-real-ai-expense-refactor/quickstart.md`
  - Why: Confirms the refactor removed the highest-risk code paths.
  - Expected result: No production mobile secret usage and no production mock financial data usage.
  - Inputs: `quickstart.md`, source tree.
  - Implementation notes: Inspect false positives manually; test fixtures can remain if isolated.
  - Possible bugs: Search hits comments or server secrets examples.
  - Fix strategy: Classify hits by production mobile code vs docs/tests/server examples.
  - Verification: Both `rg` commands are run and results documented.
  - Stop condition: Production Flutter code has no mobile secrets or mock financial entries.

- [ ] T038 [Polish] Fix analyzer warnings introduced or touched by this work across `lib/`, `packages/expense_repository/lib/`, and `test/`
  - Why: Refactor should improve the codebase, not add lint debt.
  - Expected result: No new analyzer warnings from changed files; important existing warnings are fixed where practical.
  - Inputs: `flutter analyze` output.
  - Implementation notes: Avoid broad unrelated cleanup unless it blocks this feature.
  - Possible bugs: Mechanical fixes change behavior.
  - Fix strategy: Review each analyzer fix and run focused tests after changes.
  - Verification: `flutter analyze`.
  - Stop condition: Analyzer is clean for changed scope or remaining issues are documented.

- [ ] T039 [Polish] Fix failing Flutter tests related to this feature in `test/`
  - Why: Existing failures hide future regressions.
  - Expected result: Auth/onboarding provider failures, recurring bloc expectation failures, and AI/expense tests are corrected.
  - Inputs: previous `flutter test` output, shared test harness, changed feature tests.
  - Implementation notes: Fix tests to match real app behavior; do not weaken tests to pass.
  - Possible bugs: Tests rely on production Firebase.
  - Fix strategy: Use deterministic test-only fakes via the harness.
  - Verification: `flutter test`.
  - Stop condition: Test suite passes or remaining failures are unrelated and documented.

- [ ] T040 [Polish] Perform manual visual checks for `lib/features/expenses/`, `dashboard/`, `settings/`, and `ai/`
  - Why: Analyzer/tests do not catch all Arabic layout and bottom-sheet issues.
  - Expected result: No visible overflow, clipped required buttons, wrong RTL chevrons, or bottom nav overlap at required sizes.
  - Inputs: quickstart viewport matrix.
  - Implementation notes: Preserve current design tokens and avoid screen-local hacks where shared fixes are better.
  - Possible bugs: One fix improves Arabic but breaks English.
  - Fix strategy: Check both directions after every layout fix.
  - Verification: 360x800, 375x812, 390x844 in Arabic and English.
  - Stop condition: Primary flows are visually usable in both languages.

- [ ] T041 [Polish] Update developer documentation in `APP_DOCUMENTATION.md` or project docs if behavior changes
  - Why: Current documentation says some features are working but code review found mock/placeholder risks.
  - Expected result: Documentation reflects real AI flow, no mock-data policy, and secure gateway path.
  - Inputs: final implementation behavior, `APP_DOCUMENTATION.md`, `docs/`.
  - Implementation notes: Do not include secrets or private endpoint keys.
  - Possible bugs: Documentation promises unsupported features.
  - Fix strategy: Document unavailable features honestly.
  - Verification: Read docs and compare with implemented behavior.
  - Stop condition: Docs do not claim fake or incomplete behavior is production-ready.

## Dependencies And Execution Order

```text
Phase 1 blocks all implementation.
Phase 2 blocks AI UI and broad screen changes.
US1 and US2 are MVP and should complete before UI polish.
US3 depends on US1 foundation and improves entry consistency.
US4 can run after localization wiring starts but should avoid conflicting with active UI edits.
US5 depends on route and screen audit.
Final polish depends on all selected user-story phases.
```

## Parallel Opportunities

- T006 and T005 can run in parallel after T002-T004.
- T019 can run while T006-T010 are being implemented.
- T028-T031 can be split by file area after `AppLocalizations` wiring is agreed.
- T035 and T036 can run in parallel after T033 and T034.
- T037-T041 must wait until implementation tasks are complete.

## MVP Scope

MVP for first implementation pass:

1. T001-T010
2. T013-T018
3. T019-T021
4. T028-T029
5. T037-T039

This delivers the most important outcome: secure AI text expense entry, no mobile AI secrets, no fake data in the main AI/dashboard paths, and a testable baseline.
