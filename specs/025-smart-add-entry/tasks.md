# Tasks: Smart Add Entry

**Input**: Design documents from `specs/025-smart-add-entry/`

**Prerequisites**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md), [contracts/](contracts/)

**Project Type**: Production Flutter app UI improvement

## Mandatory First Read And Skill Gate

Completed for task generation:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Searched installed skills for relevant workflows.
- Loaded relevant skills.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`.

## Phase 1: Setup And Current-State Audit

- [X] T001 [Setup] Audit current home add entry points in `lib/features/dashboard/presentation/home_dashboard_screen.dart` and record notes in `specs/025-smart-add-entry/home-add-audit.md`
  - Why: We need an exact list of current add/AI buttons before removing duplication.
  - Expected result: The audit names the stacked add FAB, stacked AI FAB, top-bar AI action, their current labels, and their current destinations.
  - Inputs: `home_dashboard_screen.dart`, `lib/app/routes.dart`, `lib/app/router.dart`, `specs/025-smart-add-entry/spec.md`.
  - Implementation notes: Do not edit app code in this task. Note whether any button is dead, duplicated, or points to an older flow.
  - Possible bugs: Missing a nested action inside a bottom sheet or confusing assistant AI with expense AI.
  - Fix strategy: Search for `expensesNewQuick`, `expensesNewText`, `expensesNewAi`, `AiAssistantSheet`, and `FloatingActionButton`.
  - Verification: Audit file includes every home add/AI entry and the route/action it triggers.
  - Stop condition: No home add/AI entry remains unclassified.

- [X] T002 [Routes] Confirm canonical add routes in `lib/app/routes.dart` and `lib/app/router.dart`
  - Why: The smart add sheet must route to the correct existing screens without hardcoded paths.
  - Expected result: AI text routes to `AppRoutes.expensesNewText`; quick add routes to `AppRoutes.expensesNewQuick`; receipt route state is documented.
  - Inputs: `lib/app/routes.dart`, `lib/app/router.dart`, `contracts/smart-add-contract.md`.
  - Implementation notes: If helper methods are missing for dynamic routes, document the gap before editing. Do not remove old routes in this task.
  - Possible bugs: Accidentally using a route pattern as a concrete location, or keeping `expensesNewAi` as the new target.
  - Fix strategy: Add route helper methods only when needed and cover them with route tests.
  - Verification: Route constants exist and target screens are confirmed in the router.
  - Stop condition: The canonical target for each add choice is known.

## Phase 2: Foundation

- [X] T003 [Widgets] Create smart add sheet widget in `lib/features/dashboard/presentation/widgets/smart_add_sheet.dart`
  - Why: Add choices should be isolated from the dashboard so the UI is testable and reusable.
  - Expected result: A bottom sheet widget renders AI text, quick add, and receipt/unavailable choices using the existing app style.
  - Inputs: `plan.md`, `data-model.md`, `contracts/smart-add-contract.md`, `lib/core/theme/`, `lib/core/widgets/glass_card.dart`, `lib/core/widgets/gradient_button.dart`, `lib/core/widgets/glass_bottom_sheet.dart`.
  - Implementation notes: Use existing theme tokens and shared components. Do not add new colors, shadows, fonts, or fake data. Keep text bounded for Arabic.
  - Possible bugs: Bottom sheet overlaps bottom navigation, Arabic text clips, disabled choices still look tappable.
  - Fix strategy: Use constrained layout, `SafeArea`, clear disabled styling from existing tokens, and narrow viewport checks.
  - Verification: A widget test can pump the sheet without overflow.
  - Stop condition: Sheet renders all planned choices without navigation logic embedded in the dashboard.

- [X] T004 [Widgets] Add add-choice model/state inside `lib/features/dashboard/presentation/widgets/smart_add_sheet.dart`
  - Why: Each choice needs a predictable id, title, subtitle, icon, availability state, and action for tests.
  - Expected result: Choices are created from a small typed structure instead of repeated ad hoc widgets.
  - Inputs: `data-model.md`, `contracts/smart-add-contract.md`.
  - Implementation notes: Keep the model presentation-focused. Do not create backend models or persistence. Add stable keys for tests.
  - Possible bugs: Model becomes too abstract or puts route strings in many places.
  - Fix strategy: Keep only fields the sheet needs and pass callbacks/routes from the caller.
  - Verification: Tests can identify choices by stable keys and availability state.
  - Stop condition: Choices are easy to audit and no duplicated choice UI remains.

## Phase 3: User Story 1 - One Clear Add Button

- [X] T005 [US1] Replace stacked FABs in `lib/features/dashboard/presentation/home_dashboard_screen.dart`
  - Why: Two floating add/AI buttons confuse the user about where to add an expense.
  - Expected result: Home screen shows exactly one primary add entry button.
  - Inputs: `home-add-audit.md`, `smart_add_sheet.dart`, current theme/shared widget files.
  - Implementation notes: Preserve the current dashboard layout and visual identity. Remove only the duplicated floating add/AI pattern.
  - Possible bugs: Add button blocks bottom nav, loses tooltip/semantics, or looks visually unrelated to current UI.
  - Fix strategy: Keep placement close to the current primary FAB position and add a clear accessibility label.
  - Verification: Widget test finds one primary add entry and no separate small AI expense FAB.
  - Stop condition: The home screen has one add button and still compiles.

- [X] T006 [US1] Open smart add sheet from the home add button in `lib/features/dashboard/presentation/home_dashboard_screen.dart`
  - Why: The single add button must reveal the available add methods.
  - Expected result: Tapping the add button opens the smart add sheet.
  - Inputs: `smart_add_sheet.dart`, `contracts/smart-add-contract.md`.
  - Implementation notes: Use the existing bottom-sheet pattern. Prevent repeated rapid taps from stacking multiple sheets.
  - Possible bugs: Multiple sheets stack, dismiss does not work, or context is invalid after navigation.
  - Fix strategy: Use a single `showModalBottomSheet`/existing helper call and close the sheet before navigation.
  - Verification: Widget test taps add, sees AI text and quick add choices, dismisses sheet cleanly.
  - Stop condition: Add button opens and closes the sheet reliably.

## Phase 4: User Story 2 - Correct Add Choices

- [X] T007 [US2] Wire AI text choice to `AppRoutes.expensesNewText` from `lib/features/dashboard/presentation/widgets/smart_add_sheet.dart`
  - Why: AI expense entry should use the canonical AI text flow, not the older duplicate AI screen.
  - Expected result: Choosing AI text closes the sheet and opens `AddExpenseAiTextScreen`.
  - Inputs: `lib/app/routes.dart`, `lib/app/router.dart`, `add_expense_ai_text_screen.dart`, `contracts/smart-add-contract.md`.
  - Implementation notes: New navigation should use route constants/helper methods. Do not call old proxy or AI services here.
  - Possible bugs: Route opens the old `AiExpenseScreen`, or navigation happens before the sheet closes.
  - Fix strategy: Verify the route constant and use a callback that dismisses first, then navigates.
  - Verification: Route/widget test confirms AI text choice navigates to `AppRoutes.expensesNewText`.
  - Stop condition: Home to AI text takes no more than two taps.

- [X] T008 [US2] Wire quick add choice to `AppRoutes.expensesNewQuick` from `lib/features/dashboard/presentation/widgets/smart_add_sheet.dart`
  - Why: Quick add must remain the fastest manual entry path.
  - Expected result: Choosing quick add closes the sheet and opens `AddExpenseQuickScreen`.
  - Inputs: `lib/app/routes.dart`, `lib/app/router.dart`, `add_expense_quick_screen.dart`.
  - Implementation notes: Keep quick add visually second after AI text unless product review changes order.
  - Possible bugs: Quick add route fails because providers are missing or the sheet remains visible above the screen.
  - Fix strategy: Reuse existing router context and add focused navigation test coverage.
  - Verification: Route/widget test confirms quick add choice navigates to `AppRoutes.expensesNewQuick`.
  - Stop condition: Home to quick add takes no more than two taps.

- [X] T009 [US2] Make receipt choice honest in `lib/features/dashboard/presentation/widgets/smart_add_sheet.dart`
  - Why: Receipt must not look functional unless it is actually wired to real receipt behavior.
  - Expected result: Receipt is disabled/unavailable with a clear reason, or routes to `AppRoutes.expensesNewReceipt` only if the real flow is enabled.
  - Inputs: `add_expense_receipt_screen.dart`, `contracts/smart-add-contract.md`, `specs/024-real-ai-expense-refactor/plan.md`.
  - Implementation notes: Do not use mock receipt data. Disabled receipt should be readable and non-tappable.
  - Possible bugs: Disabled receipt still triggers navigation, or unavailable text overflows in Arabic.
  - Fix strategy: Separate enabled and disabled tap handlers and test both states.
  - Verification: Widget test confirms disabled receipt does not navigate and displays an unavailable reason.
  - Stop condition: Receipt is never presented as fake-working.

## Phase 5: User Story 3 - Separate Assistant From Expense Add

- [X] T010 [US3] Preserve top-bar AI assistant behavior in `lib/features/dashboard/presentation/home_dashboard_screen.dart`
  - Why: The top-bar AI icon should keep meaning assistant/help, while the add sheet AI text means creating an expense.
  - Expected result: Top-bar AI still opens `AiAssistantSheet`; it does not open expense entry.
  - Inputs: `home_dashboard_screen.dart`, `lib/features/ai/presentation/ai_assistant_sheet.dart`.
  - Implementation notes: Keep wording and iconography clear enough that assistant AI and expense AI do not compete.
  - Possible bugs: Removing the stacked AI FAB accidentally removes the assistant action too.
  - Fix strategy: Keep top-bar action separate in the audit and add a test that taps it.
  - Verification: Widget test confirms top-bar AI opens assistant/help separately from the add sheet.
  - Stop condition: Both AI meanings are still reachable and distinct.

## Phase 6: User Story 4 - RTL/LTR And Polish

- [X] T011 [US4] Add Arabic/English labels for smart add choices in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`
  - Why: The add sheet must not introduce hardcoded mixed-language text.
  - Expected result: AI text, quick add, receipt, and unavailable reason labels exist in both Arabic and English.
  - Inputs: Existing ARB files, `smart_add_sheet.dart`, localization setup in `lib/app/app.dart`.
  - Implementation notes: If localization wiring is still being fixed by `024-real-ai-expense-refactor`, keep this task coordinated and avoid duplicate keys.
  - Possible bugs: Missing ARB keys break generation, or labels are too long for small screens.
  - Fix strategy: Add keys to both ARB files, run generation, and shorten subtitles if needed.
  - Verification: `& 'C:\flutter\bin\flutter.bat' gen-l10n`.
  - Stop condition: Smart add labels are ready for Arabic RTL and English LTR.

- [X] T012 [Tests] Add smart add widget tests in `test/features/dashboard/smart_add_sheet_test.dart`
  - Why: The sheet is a new repeated entry point and should not regress.
  - Expected result: Tests cover enabled AI text, enabled quick add, disabled receipt, dismissal, Arabic RTL, and English LTR.
  - Inputs: `smart_add_sheet.dart`, `quickstart.md`, test harness if available.
  - Implementation notes: Use stable keys/semantics for critical controls instead of brittle full text where possible.
  - Possible bugs: Tests fail because localization or providers are not available in the harness.
  - Fix strategy: Wrap tests with a minimal localized MaterialApp/router harness and inject callbacks.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test test/features/dashboard/smart_add_sheet_test.dart`.
  - Stop condition: Smart add sheet tests pass or exact unrelated harness blocker is documented.

- [X] T013 [Tests] Add/update home dashboard tests in `test/features/dashboard/home_dashboard_test.dart`
  - Why: The home screen must prove it has one add entry and separate assistant behavior.
  - Expected result: Tests assert one add button, no stacked AI expense FAB, add sheet opens, and top-bar AI remains assistant.
  - Inputs: `home_dashboard_screen.dart`, `smart_add_sheet.dart`, current app test harness.
  - Implementation notes: Keep test fakes in `test/`, not production code. Do not introduce mock financial data to the app.
  - Possible bugs: Existing dashboard dependencies make the test too heavy.
  - Fix strategy: Use the existing shared test harness or create the smallest focused harness for dashboard dependencies.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test test/features/dashboard/home_dashboard_test.dart`.
  - Stop condition: Dashboard tests cover the new entry behavior.

- [X] T014 [Polish] Run focused analyzer and dashboard verification
  - Why: The change touches a high-traffic screen and navigation.
  - Expected result: Analyzer and focused dashboard tests pass, or exact pre-existing failures are documented.
  - Inputs: Completed tasks T003-T013.
  - Implementation notes: Do not broaden cleanup outside smart add files unless it blocks verification.
  - Possible bugs: Analyzer exposes unrelated existing issues from current branch.
  - Fix strategy: Separate new failures from pre-existing failures and fix only relevant ones.
  - Verification: `& 'C:\flutter\bin\flutter.bat' analyze`, smart add sheet test, home dashboard test, manual narrow-screen checks.
  - Stop condition: Smart add entry is verified enough for Mohamed to review in the app.

## Dependencies And Execution Order

```text
T001-T002 block implementation.
T003-T004 block dashboard integration.
T005-T006 block all navigation choices.
T007-T009 can be implemented after T006.
T010 can run after T005.
T011 can run in parallel with T012-T013 if localization keys are coordinated.
T014 runs last.
```

## MVP Scope

```text
T001, T002, T003, T004, T005, T006, T007, T008, T009
```
