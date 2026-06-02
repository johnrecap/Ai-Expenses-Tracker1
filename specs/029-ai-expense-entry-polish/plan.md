# Production Flutter Implementation Plan: AI Expense Entry Polish

**Branch**: `main` | **Date**: 2026-05-31 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/029-ai-expense-entry-polish/spec.md`

## Mandatory First Read And Skill Gate

Completed before writing this plan:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Loaded relevant skills.

**Skills used**:

- `speckit-specify`: created the feature specification and quality checklist.
- `speckit-plan`: created this implementation plan and design artifacts.
- `speckit-tasks`: generated an executable task list.
- `flutter-fix-layout-issues`: guided the input layout and overflow risk handling.

## Summary

Polish the AI text expense entry flow so the input field looks correct, the keyboard closes when the user finishes typing, the save button appears directly under the AI review area, and saved AI expenses refresh the visible app data immediately.

## Why

The AI entry screen is a core app promise. If the input field looks broken, the keyboard stays open, the save button is hidden at the bottom, or saved expenses do not appear immediately, the user loses trust in both the AI feature and the backend save flow.

## Expected Result

- AI input text and hint stay inside a properly padded field.
- Microphone and parse controls are visually separate from text entry.
- Pressing keyboard done/enter hides the keyboard and safely moves the AI flow forward.
- Save button is directly below the AI suggestion/review area.
- Missing amount/category shows a clear message without red-screen failures.
- Saving AI expense without a wallet remains supported.
- Expense list, home/report totals, and budget state refresh after AI save.
- Focused widget/unit tests cover the changed behavior.

## Source References

- `specs/029-ai-expense-entry-polish/spec.md`
- `specs/029-ai-expense-entry-polish/research.md`
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_radii.dart`
- `lib/core/theme/app_text_styles.dart`
- `lib/core/widgets/gradient_button.dart`
- `lib/core/widgets/payment_method_selector.dart`
- `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
- `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- `lib/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart`
- `lib/app/app.dart`
- `lib/features/expenses/get_expenses_bloc/get_expenses_bloc.dart`
- `lib/features/reports/report_cubit/report_cubit.dart`
- `lib/features/budgets/budget_bloc/budget_bloc.dart`
- `test/features/expenses/ai_expense_parse_panel_user_states_test.dart`
- `test/features/expenses/add_expense_ai_text_screen_test.dart`
- `test/features/expenses/ai_expense_entry_cubit_test.dart`
- `test/blocs/get_expenses_bloc_test.dart`

## Technical Context

**Language/Version**: Flutter app with Dart SDK constraint `^3.12.0`.

**Primary Dependencies**: Existing Flutter SDK, Material widgets, `flutter_bloc`, `go_router`, Firebase/Firestore repository boundary, local repository boundary, current AI gateway client.

**Storage**: Existing `ExpenseRepository.createExpense`, `watchExpenses`, and report/budget data refresh paths. No schema migration expected.

**Testing**: Focused widget tests for AI input/save placement, cubit/unit tests for save state, and focused analyzer on touched files.

**Target Platform**: Flutter mobile app verified at 360x800, 375x812, and 390x844 in Arabic RTL and English LTR.

**Project Type**: Production Flutter mobile app UI and state refresh refinement.

**Performance Goals**: No extra AI network call after parse; no visible delay in save completion beyond existing repository write. Refresh should start immediately after save success.

**Constraints**:

- Do not create mock production expenses.
- Do not require wallet creation before saving.
- Do not add direct AI provider keys to Flutter.
- Do not introduce a new visual language.
- Do not run full-project analysis or test during this feature unless explicitly requested.
- Preserve existing quick-add behavior.

## Required Plan Detail

### Files And Ownership

Own for implementation:

- `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
- `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- `lib/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart`
- `lib/features/expenses/presentation/cubit/ai_expense_entry_state.dart`
- `test/features/expenses/ai_expense_parse_panel_user_states_test.dart`
- `test/features/expenses/add_expense_ai_text_screen_test.dart`
- `test/features/expenses/ai_expense_entry_cubit_test.dart`

Read or lightly touch only if needed for refresh integration:

- `lib/app/app.dart`
- `lib/features/expenses/get_expenses_bloc/get_expenses_bloc.dart`
- `lib/features/reports/report_cubit/report_cubit.dart`
- `lib/features/budgets/budget_bloc/budget_bloc.dart`
- `test/blocs/get_expenses_bloc_test.dart`
- `test/blocs/create_expense_bloc_test.dart`

Do not touch unless a focused test proves a contract issue:

- `packages/expense_repository/`
- `workers/ai-gateway/`
- `server/`
- `functions/`

### Reuse Strategy

- Use `AppTheme.inputDecorationTheme` principles for field fill, focused border, and padding.
- Use `AppColors`, `AppSpacing`, `AppRadii`, and `AppTextStyles`.
- Keep `GradientButton` as the primary save action.
- Keep `PaymentMethodSelector` and `ExpenseFormCard` for optional manual corrections.
- Avoid adding new colors, fonts, or decorative patterns.

### Mock Data Strategy

No mock production data. Tests may use fake repositories/blocs only as isolated test doubles. The running app must use the existing repository and AI gateway boundaries.

### Possible Bugs And Fix Strategy

- **Bug**: Text still appears too close to the input edge.  
  **Fix**: Ensure the `TextField` owns non-zero `contentPadding` and the input surface has a visible fill/focus boundary.

- **Bug**: Microphone/parse row makes the text field feel like one crowded box.  
  **Fix**: Put controls in a separate row below the field with clear spacing or divider behavior.

- **Bug**: Keyboard done inserts a newline instead of closing.  
  **Fix**: Use a done action and explicitly unfocus on submitted/parse.

- **Bug**: Save button is visible but tries to save incomplete draft.  
  **Fix**: Disable or guard save until amount/category are valid, and show missing-field feedback.

- **Bug**: AI save still does not refresh home/list/reports.  
  **Fix**: Trigger the same refresh targets that app-level create success uses after AI save success.

- **Bug**: Refresh uses stale month when app stays open across month boundary.  
  **Fix**: Resolve `DateTime.now()` at refresh time, not once during app startup.

- **Bug**: Arabic labels or long hints overflow.  
  **Fix**: Keep labels short, allow wrapping where appropriate, and verify required small viewports.

## Constitution Check

**Gate result**: PASS.

- Project law files read.
- Relevant skills loaded.
- Production app scope preserved.
- No WebView/HTML shortcut planned.
- No mock financial production data planned.
- Existing AI gateway boundary preserved.
- Existing theme and shared widgets reused.
- Arabic RTL and English LTR checks planned.
- Focused verification planned.

**Template conflict note**: The bundled Spec Kit template contains UI-only prototype wording, but the repository constitution defines a production Flutter app. This plan follows the constitution and the user's production behavior request.

## Project Structure

```text
specs/029-ai-expense-entry-polish/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
    ai-expense-entry-contract.md
  checklists/
    requirements.md
  tasks.md

lib/
  features/expenses/
    presentation/
      add_expense_ai_text_screen.dart
      widgets/ai_expense_parse_panel.dart
      cubit/ai_expense_entry_cubit.dart
      cubit/ai_expense_entry_state.dart
  app/app.dart

test/
  features/expenses/
    ai_expense_parse_panel_user_states_test.dart
    add_expense_ai_text_screen_test.dart
    ai_expense_entry_cubit_test.dart
```

**Structure Decision**: Keep implementation in existing expenses presentation/cubit files. Do not create a new AI entry module unless implementation reveals real duplication.

## Phase 0: Research

Research decisions are captured in [research.md](research.md).

Key decisions:

- Rebuild the AI input as a real field surface.
- Keyboard done action should close the keyboard and safely continue parsing.
- Save belongs directly under the AI review area.
- Refresh after AI save must be explicit because AI save bypasses the shared create-success listener.
- Use focused verification only.

## Phase 1: Design

Design artifacts:

- [data-model.md](data-model.md)
- [contracts/ai-expense-entry-contract.md](contracts/ai-expense-entry-contract.md)
- [quickstart.md](quickstart.md)

### State And Flow Design

1. User types natural language in the AI input field.
2. User presses keyboard done or Parse.
3. Keyboard focus is cleared.
4. AI parse request runs through the existing gateway client.
5. AI suggestion/review appears inside the AI panel.
6. Save button appears directly under the AI panel/review area.
7. Save validates amount and category, while wallet remains optional.
8. Successful save triggers shared refresh for expenses, reports, and current budget.
9. User returns to the previous screen or expense list with fresh data visible.

## Verification Plan

Focused formatting:

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' format lib\features\expenses\presentation\widgets\ai_expense_parse_panel.dart lib\features\expenses\presentation\add_expense_ai_text_screen.dart lib\features\expenses\presentation\cubit\ai_expense_entry_cubit.dart test\features\expenses\ai_expense_parse_panel_user_states_test.dart test\features\expenses\add_expense_ai_text_screen_test.dart test\features\expenses\ai_expense_entry_cubit_test.dart
```

Focused analyzer:

```powershell
& 'C:\flutter\bin\flutter.bat' analyze lib\features\expenses\presentation\widgets\ai_expense_parse_panel.dart lib\features\expenses\presentation\add_expense_ai_text_screen.dart lib\features\expenses\presentation\cubit\ai_expense_entry_cubit.dart test\features\expenses\ai_expense_parse_panel_user_states_test.dart test\features\expenses\add_expense_ai_text_screen_test.dart test\features\expenses\ai_expense_entry_cubit_test.dart
```

Focused tests:

```powershell
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_parse_panel_user_states_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\add_expense_ai_text_screen_test.dart
& 'C:\flutter\bin\flutter.bat' test --no-pub test\features\expenses\ai_expense_entry_cubit_test.dart
```

Manual checks:

- AI input text and hint stay inside the field.
- Pressing keyboard done closes the keyboard.
- Parse closes the keyboard before loading.
- Save appears under the AI suggestion/review area.
- Saving with no wallet succeeds when amount/category are valid.
- Home, expense list, reports, and budget totals update after AI save.
- Check 360x800, 375x812, and 390x844 in English LTR and Arabic RTL.

## Stop Condition

Stop when focused tests pass, touched-file analyzer passes, and manual device review confirms the input field, keyboard behavior, save placement, and immediate refresh behavior.
