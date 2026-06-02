# Tasks: AI Expense Entry Polish

**Input**: Design documents from `specs/029-ai-expense-entry-polish/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md), [contracts/ai-expense-entry-contract.md](contracts/ai-expense-entry-contract.md)

**Project Type**: Production Flutter expense tracker

## Mandatory First Read And Skill Gate

Completed before generating these tasks:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Loaded `speckit-specify`, `speckit-plan`, `speckit-tasks`, and `flutter-fix-layout-issues`.

## Non-Negotiable Rules

- Do not run broad repo analysis.
- Do not run full-project `flutter analyze` or full `flutter test`.
- Do not create mock production financial data.
- Do not require a wallet before saving an expense.
- Do not add direct AI provider keys in Flutter.
- Reuse existing theme tokens and shared widgets.
- Keep Arabic RTL and English LTR ready.
- Stop after two repeated hangs/failures of the same Flutter command.

## Phase 1: Setup And Guardrails

**Purpose**: Confirm the exact current behavior and add guardrails before UI edits.

- [X] T001 [Setup] Re-read current AI input/theme files: `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`, `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`, `lib/core/theme/app_theme.dart`, `lib/core/theme/app_colors.dart`, `lib/core/theme/app_spacing.dart`, `lib/core/theme/app_radii.dart`, `lib/core/theme/app_text_styles.dart`
  - Why: The reported issue is visual; edits must match the existing design system.
  - Expected result: Worker knows the current TextField, padding, border, and save layout before editing.
  - Inputs: `plan.md`, `contracts/ai-expense-entry-contract.md`.
  - Implementation notes: No broad repo scan. Use focused reads only.
  - Possible bugs: Worker changes colors/radii without checking theme.
  - Fix strategy: Revert only the worker's new style choices and use existing tokens.
  - Verification: Notes in implementation summary cite the exact theme tokens reused.

- [X] T002 [P] [Tests] Add/extend AI input behavior tests in `test/features/expenses/ai_expense_parse_panel_user_states_test.dart`
  - Why: The input should not regress to zero padding or stuck keyboard behavior.
  - Expected result: Tests cover non-empty parse submission path and confirm parse action can be triggered from keyboard submit or equivalent callback.
  - Inputs: `contracts/ai-expense-entry-contract.md`, existing panel tests.
  - Implementation notes: Prefer widget-level checks that do not require real AI network calls. Use fake gateway/client patterns already present.
  - Possible bugs: Test becomes brittle by depending on exact decoration object internals.
  - Fix strategy: Assert user-visible behavior and key widget structure instead of exact pixel values unless necessary.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_parse_panel_user_states_test.dart`

- [X] T003 [P] [Tests] Add/extend AI screen save-placement and refresh tests in `test/features/expenses/add_expense_ai_text_screen_test.dart`
  - Why: The save button and refresh issue are screen-level behavior.
  - Expected result: Tests prove Save appears before manual details and that success triggers visible refresh hooks or events.
  - Inputs: `contracts/ai-expense-entry-contract.md`, current fake repositories/blocs in the test.
  - Implementation notes: Keep fake repositories local to tests. Do not add mock production data.
  - Possible bugs: Test cannot observe app-level refresh because required blocs are not mounted.
  - Fix strategy: Mount only the needed focused blocs/fakes for this screen test or assert the local refresh callback/event.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_screen_test.dart`

## Phase 2: Foundation

**Purpose**: Fix the AI input and focus handling before moving layout and refresh behavior.

- [X] T004 [US1] Refactor the AI text field surface in `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
  - Why: Current `contentPadding: EdgeInsets.zero` makes text feel outside or stuck to the field boundary.
  - Expected result: The TextField has a clear input surface, non-zero internal padding, and focused styling consistent with the app theme.
  - Inputs: `research.md` Decision 1, `contracts/ai-expense-entry-contract.md`, theme files from T001.
  - Implementation notes: Keep microphone/parse controls separate from the text entry area. Do not add new colors.
  - Possible bugs: Multiline text changes panel height too aggressively or creates overflow.
  - Fix strategy: Use stable min/max lines, constraints, and spacing from `AppSpacing`; check small widths.
  - Verification: Focused panel widget test from T002 plus manual visual check.

- [X] T005 [US1] Add keyboard focus handling in `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
  - Why: Keyboard remains open after the user presses enter/done or Parse.
  - Expected result: Done/submit and Parse clear focus before processing.
  - Inputs: `research.md` Decision 2, `contracts/ai-expense-entry-contract.md`.
  - Implementation notes: Keep behavior safe for empty text. Do not trigger duplicate parse requests.
  - Possible bugs: Done action fires parse twice or blocks multiline typing unexpectedly.
  - Fix strategy: Route done and Parse through one guarded parse method.
  - Verification: Focused panel test from T002.

- [X] T006 [US1] Keep AI gateway user-state cards stable in `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
  - Why: Input layout changes must not break retry, quota, auth, or gateway error states.
  - Expected result: Error/retry cards still render below the input panel and do not overlap the field.
  - Inputs: Existing `ai_expense_parse_panel_user_states_test.dart`.
  - Implementation notes: Preserve `_AiGatewayStateCard` semantics and retry wiring.
  - Possible bugs: Retry button loses access to the parse method after refactor.
  - Fix strategy: Keep parse method on the panel state and pass it unchanged to retry.
  - Verification: Existing gateway-state tests still pass.

## Phase 3: User Story 2 - Save From The AI Area (P1)

**Goal**: Make the AI flow feel like type, review, save.

**Independent Test**: Parse or manually fill AI expense details and confirm Save is under the AI panel/review area.

- [X] T007 [US2] Move the AI save action in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: The current save button is below category/payment/manual fields, which makes AI entry feel too long.
  - Expected result: One primary Save button appears directly after `AiExpenseParsePanel`.
  - Inputs: `contracts/ai-expense-entry-contract.md`, `quickstart.md`.
  - Implementation notes: Keep optional manual correction fields below. Do not duplicate Save at the bottom.
  - Possible bugs: Save becomes visible before users understand missing fields.
  - Fix strategy: Keep validation feedback clear and leave manual fields accessible below.
  - Verification: Screen test from T003 and manual visual check.

- [X] T008 [US2] Clear keyboard focus before save in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: The keyboard should not cover the save result or snackbars.
  - Expected result: Pressing Save hides the keyboard before validation/save.
  - Inputs: `contracts/ai-expense-entry-contract.md`.
  - Implementation notes: Add focus clear at the start of the save path.
  - Possible bugs: Focus clear causes build timing issues if called after navigation.
  - Fix strategy: Clear focus before async save and before route changes.
  - Verification: Screen widget test where practical plus manual device check.

- [X] T009 [US2] Preserve no-wallet save behavior in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: This feature must not undo the default payment/no-wallet work.
  - Expected result: AI save still succeeds without wallet when amount/category are valid.
  - Inputs: `specs/028-default-payment-method/contracts/payment-method-contract.md`, existing no-wallet AI tests.
  - Implementation notes: Do not make wallet a required missing field.
  - Possible bugs: Moving the save button changes selected wallet/payment method state order.
  - Fix strategy: Keep `_effectivePaymentMethod` and optional wallet logic intact.
  - Verification: Existing no-wallet/default payment tests in `add_expense_ai_text_screen_test.dart`.

## Phase 4: User Story 3 - Immediate Refresh After AI Save (P1)

**Goal**: Newly saved AI expenses appear immediately in app data.

**Independent Test**: Save AI expense and confirm expense/list/report refresh hooks run in the same session.

- [X] T010 [US3] Identify the smallest refresh hook in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart` and `lib/app/app.dart`
  - Why: AI save currently writes directly through `AiExpenseEntryCubit`, while app-level refresh listens to `CreateExpenseBloc` success.
  - Expected result: Worker chooses the smallest scoped refresh path before editing.
  - Inputs: `research.md` Decision 4, `contracts/ai-expense-entry-contract.md`, `lib/app/app.dart`.
  - Implementation notes: Prefer local post-AI-save refresh over broad save-flow refactor for this feature.
  - Possible bugs: Duplicate refreshes if both stream and explicit refresh fire.
  - Fix strategy: Refresh commands should be idempotent and limited to existing blocs.
  - Verification: Implementation summary names the chosen refresh path.

- [X] T011 [US3] Trigger shared expense/report/budget refresh after AI save success in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: User currently needs to leave/reopen app to see updated data.
  - Expected result: On `AiExpenseEntryStatus.saved`, the screen refreshes expenses, reports, and current budget before or alongside navigation.
  - Inputs: `lib/features/expenses/get_expenses_bloc/get_expenses_bloc.dart`, `lib/features/reports/report_cubit/report_cubit.dart`, `lib/features/budgets/budget_bloc/budget_bloc.dart`.
  - Implementation notes: Resolve current date at save-success time. Guard optional bloc reads if a focused test route does not mount all app blocs.
  - Possible bugs: Test routes without `ReportCubit` or `BudgetBloc` throw provider errors.
  - Fix strategy: Use safe reads or mount focused fakes in tests.
  - Verification: Screen test from T003.

- [X] T012 [P] [US3] Add focused cubit/state coverage in `test/features/expenses/ai_expense_entry_cubit_test.dart`
  - Why: Save success and failure should remain clear after refresh integration.
  - Expected result: Cubit still emits saving then saved on successful repository write and draft-ready error on save failure.
  - Inputs: Existing cubit test patterns.
  - Implementation notes: Do not test UI refresh in cubit test unless the cubit is changed to emit saved expense details.
  - Possible bugs: Tests overreach into screen refresh behavior.
  - Fix strategy: Keep cubit tests about cubit state only.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_entry_cubit_test.dart`

## Phase 5: User Story 4 - Responsive And RTL/LTR Polish (P2)

**Goal**: Confirm the screen is usable on small phones in Arabic and English.

- [ ] T013 [US4] Check small-screen layout manually on device or simulator for `AddExpenseAiTextScreen`
  - Why: The reported issue is visual and keyboard-related; tests cannot fully prove it.
  - Expected result: No clipped input text, no overlapped buttons, and Save is reachable under the AI area.
  - Inputs: `quickstart.md` manual checks.
  - Implementation notes: Check keyboard open and closed. Check Arabic and English if locale switching is available.
  - Possible bugs: Save button is technically moved but still hidden by keyboard.
  - Fix strategy: Adjust scroll padding, focus clear, and button placement.
  - Verification: Manual check notes for 360x800, 375x812, and 390x844 equivalents.
  - Status: Pending because `flutter devices` currently shows Windows, Chrome, and Edge only; no Android phone or emulator is visible.

- [X] T014 [Polish] Format touched Dart files
  - Why: Keep code style consistent before analyzer/tests.
  - Expected result: Touched implementation and test files are formatted.
  - Inputs: Changed files from T004-T012.
  - Implementation notes: Use Dart formatter only on touched files.
  - Possible bugs: Formatter touches generated/unrelated files if command is too broad.
  - Fix strategy: Pass exact file paths.
  - Verification: `& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' format lib\features\expenses\presentation\widgets\ai_expense_parse_panel.dart lib\features\expenses\presentation\add_expense_ai_text_screen.dart lib\features\expenses\presentation\cubit\ai_expense_entry_cubit.dart test\features\expenses\ai_expense_parse_panel_user_states_test.dart test\features\expenses\add_expense_ai_text_screen_test.dart test\features\expenses\ai_expense_entry_cubit_test.dart`

- [X] T015 [Polish] Run focused analyzer on touched files
  - Why: Catch compile/static issues without broad analysis.
  - Expected result: Analyzer passes for touched implementation and tests.
  - Inputs: Changed files from implementation.
  - Implementation notes: Flutter may need outside-sandbox execution because of lockfile; do not retry more than twice.
  - Possible bugs: Existing unrelated analyzer failures appear if command scope expands.
  - Fix strategy: Keep analyzer scoped to exact touched files and report unrelated failures separately.
  - Verification: `& 'C:\flutter\bin\flutter.bat' analyze lib\features\expenses\presentation\widgets\ai_expense_parse_panel.dart lib\features\expenses\presentation\add_expense_ai_text_screen.dart lib\features\expenses\presentation\cubit\ai_expense_entry_cubit.dart test\features\expenses\ai_expense_parse_panel_user_states_test.dart test\features\expenses\add_expense_ai_text_screen_test.dart test\features\expenses\ai_expense_entry_cubit_test.dart`

- [X] T016 [Polish] Run focused tests
  - Why: Prove the changed AI input/save/refresh behavior works.
  - Expected result: Focused tests pass or exact environment blocker is reported.
  - Inputs: T002, T003, T012.
  - Implementation notes: Run one focused test file first, then the remaining focused test files.
  - Possible bugs: Flutter lockfile hang or stale process.
  - Fix strategy: Follow `docs/agent-playbooks/subagent-execution-rules.md`; stop after repeated hang.
  - Verification:
    `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_parse_panel_user_states_test.dart`
    `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_screen_test.dart`
    `& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_entry_cubit_test.dart`

## Dependencies And Execution Order

- T001 blocks all UI edits.
- T002 and T003 can run in parallel after T001.
- T004-T006 must complete before save-placement work is finalized.
- T007-T009 depend on T004-T006.
- T010-T012 depend on understanding the save status from T007-T009.
- T013-T016 run after implementation.

## Parallel Opportunities

- T002 and T003 can run in parallel.
- T012 can run in parallel with T011 if the cubit API is unchanged.
- T014 formatting can happen after all code changes are complete.

## Suggested MVP

Complete T001-T011 first. That fixes the visible field problem, keyboard issue, save placement, and stale data issue. T012-T016 harden and verify.

## Stop Condition

Stop when all touched-file checks pass, the device/manual review confirms the visual fixes, and no wallet is required for AI expense save.
