# Tasks: Default Payment Method

**Input**: Design documents from `specs/028-default-payment-method/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md), [contracts/payment-method-contract.md](contracts/payment-method-contract.md)

**Project Type**: Production Flutter expense tracker

## Mandatory First Read And Skill Gate

Completed before generating these tasks:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Searched `.agents/skills/` and `.agent/skills/`.
- Loaded `speckit-tasks`.

**Skills used**:

- `speckit-tasks`: generated dependency-ordered implementation tasks from the Spec Kit artifacts.

## Non-Negotiable Rules

- Do not require a wallet account before saving an expense.
- Do not create fake wallets or fake financial data.
- Do not add mobile secrets or direct AI provider keys.
- Reuse existing `PaymentMethod`, `UserSettings`, `SettingsCubit`, repository contracts, and theme tokens.
- Use focused verification only; do not run full-project `flutter analyze` or full `flutter test` for this feature.
- Preserve Arabic RTL and English LTR behavior.

## Phase 1: Setup And Contract Guardrails

**Purpose**: Lock down the existing storage contract before UI behavior changes.

- [X] T001 [Setup] Verify payment method storage contract in `packages/expense_repository/lib/src/models/payment_method.dart`, `firestore.rules`, and `test/packages/expense_repository/settings_wallet_budget_contract_test.dart`
  - Why: The feature depends on valid payment method values and optional wallet fields already being accepted.
  - Expected result: The worker knows whether schema/rules changes are needed before editing UI flows.
  - Inputs: `specs/028-default-payment-method/contracts/payment-method-contract.md`, `docs/firebase/firestore-schema.md`, `firestore.rules`.
  - Implementation notes: Prefer adding focused assertions to the existing contract test instead of changing repository schema.
  - Possible bugs: Missing rule coverage for optional wallet fields; invalid payment method strings accepted in a test double but rejected by Firestore.
  - Fix strategy: Align tests with `PaymentMethod.storageValue` and Firestore `validPaymentMethod`.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\packages\expense_repository\settings_wallet_budget_contract_test.dart`

- [X] T002 [P] [Setup] Review current no-wallet expense tests in `test/features/expenses/add_expense_quick_screen_test.dart`, `test/features/expenses/add_expense_ai_text_screen_test.dart`, and `test/features/expenses/ai_expense_draft_mapper_test.dart`
  - Why: Existing tests already cover part of the requested behavior and should be extended instead of duplicated.
  - Expected result: A clear list of tests to update for no-wallet, default method, and wallet-link behavior.
  - Inputs: `specs/028-default-payment-method/spec.md`, `quickstart.md`.
  - Implementation notes: Keep tests focused and avoid broad folder runs.
  - Possible bugs: Tests assume Cash fallback only and miss Visa/Wallet/Bank Transfer defaults.
  - Fix strategy: Add small focused cases beside existing no-wallet tests.
  - Verification: No command required; this is a read/task-scoping step.

## Phase 2: Foundation

**Purpose**: Complete shared settings behavior before changing individual expense flows.

- [X] T003 [Foundation] Add default payment method save action in `lib/features/settings/settings_cubit/settings_cubit.dart`
  - Why: Settings UI and expense flows need one supported way to persist the user's default.
  - Expected result: `SettingsCubit` can save `PaymentMethod` and emit loading/success/failure states consistently with currency/language saves.
  - Inputs: `packages/expense_repository/lib/src/settings_repo.dart`, `packages/expense_repository/lib/src/models/user_settings.dart`.
  - Implementation notes: Follow existing `saveBaseCurrency` and `saveLanguagePreference` patterns. Do not add a new settings service.
  - Possible bugs: UI changes but repository is not updated; failure state loses previous settings.
  - Fix strategy: Save via existing repository and restore previous state on failure.
  - Verification: Focused settings cubit/widget tests that change default method.

- [X] T004 [P] [Foundation] Add localized payment method labels in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`
  - Why: Settings and add-expense controls must support Arabic and English without hardcoded labels.
  - Expected result: Labels exist for "Default Payment Method", "Cash", "Visa/Card", "Wallet", "Bank Transfer", and "Wallet optional".
  - Inputs: `specs/028-default-payment-method/spec.md`, existing `lib/l10n/app_*.arb` style.
  - Implementation notes: Keep labels short to avoid overflow on 360px screens.
  - Possible bugs: Missing generated localization getters after ARB edits.
  - Fix strategy: Run `& 'C:\flutter\bin\flutter.bat' gen-l10n` if generated files are not auto-updated.
  - Verification: Analyzer on touched l10n-consuming files after generation.

- [X] T005 [Foundation] Update generated localization files in `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart`, and `lib/l10n/app_localizations_ar.dart`
  - Why: Flutter code cannot use new ARB keys until generated localization classes expose them.
  - Expected result: New payment method label getters are available to Settings and expense screens.
  - Inputs: `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`, `l10n.yaml`.
  - Implementation notes: Prefer `& 'C:\flutter\bin\flutter.bat' gen-l10n`; do not hand-edit generated files unless tooling is blocked and the change is mechanical.
  - Possible bugs: Flutter tool lockfile hang; generated files out of sync.
  - Fix strategy: Follow `docs/agent-playbooks/subagent-execution-rules.md` and report blocker after two hangs.
  - Verification: `& 'C:\flutter\bin\flutter.bat' gen-l10n`

## Phase 3: User Story 1 - Save Expense Without Wallet (P1)

**Goal**: Quick add and AI add save valid expenses even when the user has zero wallets.

**Independent Test**: Save quick and AI expenses with no wallets and verify payment method is present and wallet fields are empty.

- [X] T006 [P] [US1] Extend quick add no-wallet test in `test/features/expenses/add_expense_quick_screen_test.dart`
  - Why: This proves the most important unblocker before changing the screen.
  - Expected result: Test covers saving with zero wallets and asserts `walletAccountId`/`walletAccountName` are null.
  - Inputs: `spec.md` US1, `contracts/payment-method-contract.md`.
  - Implementation notes: Use existing fake repositories/blocs; do not introduce mock production data.
  - Possible bugs: Test accidentally mounts a wallet and misses the no-wallet path.
  - Fix strategy: Explicitly provide empty wallet state or omit `WalletBloc` only if the screen supports it.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_quick_screen_test.dart`

- [X] T007 [P] [US1] Extend AI text no-wallet test in `test/features/expenses/add_expense_ai_text_screen_test.dart`
  - Why: AI confirmation must not be blocked by missing wallets.
  - Expected result: AI add can save with no wallet and valid payment method.
  - Inputs: `spec.md` US1, `quickstart.md`.
  - Implementation notes: Reuse existing AI draft fixtures and empty wallet state.
  - Possible bugs: AI draft mapper throws missing wallet fields.
  - Fix strategy: Adjust mapper requirements so wallet is never required for save.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_screen_test.dart`

- [X] T008 [US1] Preserve optional wallet save behavior in `lib/features/expenses/presentation/add_expense_quick_screen.dart`
  - Why: Quick add is the fastest manual expense path.
  - Expected result: Valid expense saves without a wallet account and with a valid payment method.
  - Inputs: `contracts/payment-method-contract.md`, existing quick add tests.
  - Implementation notes: Keep wallet selector optional text visible. Do not route user to wallet creation.
  - Possible bugs: Currency comes from missing wallet instead of settings/base currency.
  - Fix strategy: If no wallet is selected, use settings base currency and the selected/default payment method.
  - Verification: Quick add focused test from T006.

- [X] T009 [US1] Preserve optional wallet confirmation in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: AI expense entry should not be weaker than quick add.
  - Expected result: AI draft confirmation saves without wallet account when amount/category/date are valid.
  - Inputs: `contracts/payment-method-contract.md`, AI text screen tests.
  - Implementation notes: Keep wallet unavailable/no-wallet messages honest but non-blocking.
  - Possible bugs: The screen auto-selects the only wallet even when user did not intend to link one.
  - Fix strategy: Only auto-link wallet if existing behavior is intentionally preserved and tests assert it; otherwise require deliberate selection.
  - Verification: AI text focused test from T007.

## Phase 4: User Story 2 - Use Default Payment Method When Missing (P1)

**Goal**: If the user does not choose or write a payment method, the app uses settings default, then Cash fallback.

**Independent Test**: Set default to Visa, save expense without explicit method, and assert saved method is Visa.

- [X] T010 [P] [US2] Add quick add default payment tests in `test/features/expenses/add_expense_quick_screen_test.dart`
  - Why: Prevents regression to hardcoded Cash.
  - Expected result: Tests cover Cash default, Visa default, Wallet default without wallet, and Bank Transfer default.
  - Inputs: `data-model.md`, `contracts/payment-method-contract.md`.
  - Implementation notes: Keep each case small; use existing fake settings repository.
  - Possible bugs: Test setup changes default in repository but not in mounted `SettingsCubit`.
  - Fix strategy: Seed `SettingsCubit` state before pumping screen.
  - Verification: Quick add focused test file.

- [X] T011 [P] [US2] Add AI text default payment tests in `test/features/expenses/add_expense_ai_text_screen_test.dart`
  - Why: AI add must share the same fallback behavior.
  - Expected result: AI draft with no payment words saves using settings default.
  - Inputs: `spec.md` US2, `quickstart.md`.
  - Implementation notes: Use an AI draft that has amount/category/date but no payment method.
  - Possible bugs: The mapper defaults to Cash before screen settings can apply.
  - Fix strategy: Pass default method into mapping/confirmation before creating the expense.
  - Verification: AI text focused test file.

- [X] T012 [US2] Add payment method selector state to `lib/features/expenses/presentation/add_expense_quick_screen.dart`
  - Why: The user must be able to override the default before saving.
  - Expected result: Quick add has a clear selected payment method, initialized from settings default when available.
  - Inputs: `contracts/payment-method-contract.md`, existing theme files.
  - Implementation notes: Use compact chips/segmented control consistent with current UI; do not add new colors.
  - Possible bugs: Selector text overflows in Arabic or pushes save button below usable area.
  - Fix strategy: Use wrapping layout and short localized labels.
  - Verification: Quick add widget tests plus 360x800 manual check.

- [X] T013 [US2] Apply default payment save logic in `lib/features/expenses/presentation/add_expense_quick_screen.dart`
  - Why: The selected/default method must drive the saved `Expense.paymentMethod`.
  - Expected result: No-wallet save uses selected method or settings default; Cash only when settings are unavailable.
  - Inputs: `contracts/payment-method-contract.md`, `UserSettings.defaultBaseCurrency`.
  - Implementation notes: Do not set wallet fields unless a wallet is selected.
  - Possible bugs: Selected wallet and selected payment method conflict.
  - Fix strategy: If a wallet account is selected, set payment method to Wallet unless implementation explicitly supports another combination with tests.
  - Verification: Tests from T010.

- [X] T014 [US2] Apply default payment save logic in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: The AI confirmation screen creates the final expense and must use the same fallback rules.
  - Expected result: Drafts without payment method save using settings default.
  - Inputs: `ai_expense_draft_mapper.dart`, `contracts/payment-method-contract.md`.
  - Implementation notes: Keep user override possible before save.
  - Possible bugs: Screen and mapper each apply different fallback values.
  - Fix strategy: Make one clear precedence path: explicit draft/user selection, settings default, Cash.
  - Verification: Tests from T011.

## Phase 5: User Story 3 - AI Detects Payment Method From Text (P1)

**Goal**: AI expense entry understands common Arabic and English payment wording.

**Independent Test**: Parse cash, visa/card, wallet, and transfer sentences and verify the draft method.

- [X] T015 [P] [US3] Add AI payment keyword tests in `test/features/expenses/ai_expense_draft_mapper_test.dart` or the nearest existing AI service test
  - Why: Detection rules must be explicit and stable before implementation.
  - Expected result: Tests cover Arabic and English cash, card, wallet, and transfer terms.
  - Inputs: `contracts/payment-method-contract.md`, `research.md`.
  - Implementation notes: If parsing lives in `ai_service.dart`, place tests in the matching AI service test file instead of the mapper test.
  - Possible bugs: Tests assert behavior at the wrong layer.
  - Fix strategy: Put tests where text becomes `paymentMethod`.
  - Verification: Focused AI mapper/service test.

- [X] T016 [US3] Implement deterministic payment method detection in `lib/features/ai/services/ai_service.dart`
  - Why: Provider output may omit payment method, so local fallback needs common terms.
  - Expected result: Text containing cash/card/wallet/transfer terms produces the expected `PaymentMethod`.
  - Inputs: `contracts/payment-method-contract.md`, existing `AiExpenseDraft` model.
  - Implementation notes: Keep keyword matching small and transparent; do not call external AI directly.
  - Possible bugs: "wallet" provider names are classified as transfer or card incorrectly.
  - Fix strategy: Order specific transfer terms before broad wallet terms only where needed and document precedence in tests.
  - Verification: Tests from T015.

- [X] T017 [US3] Update AI expense fallback in `lib/features/expenses/domain/ai_expense_draft_mapper.dart`
  - Why: The mapper must not convert missing method to hardcoded Cash before settings default can be applied.
  - Expected result: Mapping accepts a default payment method input or preserves draft method until the screen applies fallback.
  - Inputs: `data-model.md`, `contracts/payment-method-contract.md`.
  - Implementation notes: Keep `missingFields` free of wallet unless wallet is genuinely required by a future explicit flow.
  - Possible bugs: Existing tests expecting Cash fallback fail.
  - Fix strategy: Update tests to assert settings default fallback or Cash only when no default exists.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_draft_mapper_test.dart`

## Phase 6: User Story 4 - Manage Default In Settings (P2)

**Goal**: User can select and persist default payment method in Settings.

**Independent Test**: Change default in Settings, leave/reopen, and verify selection persists.

- [X] T018 [P] [US4] Add settings UI tests in `test/features/settings/settings_screen_actions_test.dart`
  - Why: Settings must prove the selector is visible and saves through the repository.
  - Expected result: Test taps default payment method and verifies repository/default state changes.
  - Inputs: `spec.md` US4, existing settings tests.
  - Implementation notes: Use existing fake settings repository; avoid full app setup.
  - Possible bugs: Test cannot find controls because settings content is scrollable.
  - Fix strategy: Use `tester.ensureVisible` before tapping below-fold controls.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\settings\settings_screen_actions_test.dart`

- [X] T019 [US4] Add default payment method UI to `lib/features/settings/presentation/settings_screen.dart`
  - Why: Users need a visible place to change the default.
  - Expected result: Settings shows current default and lets the user choose Cash, Visa/Card, Wallet, or Bank Transfer.
  - Inputs: `AppColors`, `AppSpacing`, `AppTextStyles`, existing `_AppearanceSection` pattern.
  - Implementation notes: Prefer adding this to the existing Appearance/preferences section unless a better existing settings section fits.
  - Possible bugs: New row is hidden below bottom nav or clipped in Arabic.
  - Fix strategy: Keep row compact and use existing `SingleChildScrollView` spacing.
  - Verification: Settings test from T018 and manual 360x800 RTL/LTR check.

- [X] T020 [US4] Wire settings UI to `SettingsCubit.saveDefaultPaymentMethod` in `lib/features/settings/presentation/settings_screen.dart`
  - Why: The selected default must persist, not just change visually.
  - Expected result: Selecting a method updates settings state and repository.
  - Inputs: `SettingsCubit`, `SettingsRepository.updateDefaultPaymentMethod`.
  - Implementation notes: Show honest error state/snackbar if save fails.
  - Possible bugs: Multiple rapid taps emit stale settings.
  - Fix strategy: Disable or ignore repeated save while `SettingsSaving`.
  - Verification: Settings test from T018.

## Phase 7: User Story 5 - Link Wallet Only When Chosen (P2)

**Goal**: Wallet account fields are written only when the user intentionally chooses an existing wallet.

**Independent Test**: Save one expense with Visa/no wallet and one with selected wallet; only the second has wallet fields.

- [X] T021 [P] [US5] Add wallet-link precedence tests in `test/features/expenses/add_expense_quick_screen_test.dart`
  - Why: Prevents accidental wallet linking or losing selected wallet data.
  - Expected result: Tests cover no-wallet Visa and selected-wallet Wallet behavior.
  - Inputs: `contracts/payment-method-contract.md`.
  - Implementation notes: Use existing wallet fake state.
  - Possible bugs: Test fails because UI auto-selects the only wallet.
  - Fix strategy: Make auto-selection explicit in either product behavior or remove it and update tests.
  - Verification: Quick add focused test.

- [X] T022 [P] [US5] Add wallet-link precedence tests in `test/features/expenses/add_expense_ai_text_screen_test.dart`
  - Why: AI save path must not link unknown wallet names.
  - Expected result: Unknown wallet suggestions do not block save and do not populate wallet fields.
  - Inputs: `spec.md` edge cases, `contracts/payment-method-contract.md`.
  - Implementation notes: Include a draft with wallet name that does not exist.
  - Possible bugs: Mapper marks wallet missing or throws.
  - Fix strategy: Treat unmatched wallet as optional metadata and continue with payment method.
  - Verification: AI text focused test.

- [X] T023 [US5] Enforce wallet-field write rules in `lib/features/expenses/presentation/add_expense_quick_screen.dart` and `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: UI selection should be the only reason wallet account fields are written.
  - Expected result: No-wallet expenses keep wallet fields empty; selected-wallet expenses preserve id/name.
  - Inputs: Tests from T021 and T022.
  - Implementation notes: Do not infer wallet from payment method alone.
  - Possible bugs: Wallet payment method without wallet still writes placeholder wallet id.
  - Fix strategy: Assert null wallet fields unless selected wallet object exists.
  - Verification: Tests from T021 and T022.

## Final Phase: Verification And Polish

- [X] T024 [Polish] Format touched files using Dart formatter in `lib/features/settings/`, `lib/features/expenses/`, `lib/features/ai/`, `lib/l10n/`, and focused tests
  - Why: Keeps diffs readable and avoids analyzer style noise.
  - Expected result: Touched Dart files are formatted.
  - Inputs: All implementation tasks above.
  - Implementation notes: Use direct Dart executable if `flutter.bat` wrapper hangs.
  - Possible bugs: Formatter hangs through Flutter wrapper.
  - Fix strategy: Use `& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' format <files>`.
  - Verification: Formatter exits 0.

- [X] T025 [Polish] Run focused analyzer on touched files listed in `specs/028-default-payment-method/quickstart.md`
  - Why: Confirms the implementation compiles without broad unrelated failures.
  - Expected result: No analyzer issues in touched files and touched tests.
  - Inputs: `quickstart.md`, touched file list.
  - Implementation notes: Do not run full-project analyze for this feature.
  - Possible bugs: Analyzer surfaces unrelated generated localization drift.
  - Fix strategy: Include generated l10n files if they were changed; otherwise stop at unrelated failures and report.
  - Verification: `& 'C:\flutter\bin\flutter.bat' analyze <touched-files> <touched-tests>`

- [X] T026 [Polish] Run focused tests listed in `specs/028-default-payment-method/quickstart.md`
  - Why: Proves the feature behavior across settings, quick add, AI add, mapper, and repository contracts.
  - Expected result: All focused tests pass.
  - Inputs: Updated focused test files.
  - Implementation notes: Stop after first unrelated failure and report it.
  - Possible bugs: Widget test tap misses below-fold settings row.
  - Fix strategy: Use `tester.ensureVisible` and fixed pump durations as described in `docs/agent-playbooks/subagent-execution-rules.md`.
  - Verification: Focused `flutter test --no-pub` commands in `quickstart.md`.

- [ ] T027 [Polish] Perform manual viewport checks for payment controls in `lib/features/settings/presentation/settings_screen.dart`, `lib/features/expenses/presentation/add_expense_quick_screen.dart`, and `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: Payment method labels and optional wallet text can overflow on narrow Arabic screens.
  - Expected result: No clipped labels, hidden controls, or bottom nav overlap at required sizes/directions.
  - Inputs: `quickstart.md` manual checks.
  - Implementation notes: Check 360x800, 375x812, 390x844 in Arabic RTL and English LTR when device/browser tooling is available.
  - Possible bugs: Long Arabic labels break segmented controls.
  - Fix strategy: Use Wrap/chips or shorter localized labels instead of fixed-width rows.
  - Verification: Manual check notes in implementation final report.

## Dependencies And Execution Order

1. Phase 1 contract guardrails should run first.
2. Phase 2 foundation blocks settings UI and default fallback behavior.
3. US1 can be implemented as MVP after foundation.
4. US2 and US3 can proceed after US1, but both touch AI/expense mapping and should be coordinated.
5. US4 can proceed in parallel after T003/T004/T005 because it mostly touches Settings.
6. US5 should run after US1 and US2 to avoid conflicting wallet save logic.
7. Polish depends on all selected story phases.

## Parallel Execution Examples

```text
After T003-T005:
- Agent A: T006, T008 for quick add no-wallet behavior.
- Agent B: T007, T009 for AI add no-wallet behavior.
- Agent C: T018-T020 for settings default selector.

After US1:
- Agent A: T010, T012, T013 for quick add default method.
- Agent B: T015-T017 for AI text detection and mapper fallback.
```

Parallel rule: Do not run two agents that both edit the same file unless one is strictly reviewing and not writing.

## Implementation Strategy

### MVP First

Complete US1 and US2 first:

- Save without wallet.
- Use settings default when method is missing.
- Keep Cash fallback.

This makes the app immediately usable without wallet setup.

### Incremental Delivery

1. Contract tests and shared settings action.
2. Quick add no-wallet/default payment.
3. AI add no-wallet/default payment.
4. AI text keyword detection.
5. Settings selector UI.
6. Wallet-link precedence polish.

### Stop Condition

Stop when `tasks.md` is generated, each task has exact file paths and verification, and the MVP scope is clear enough for an implementation agent to start without more product questions.
