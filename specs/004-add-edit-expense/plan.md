# UI-Only Flutter Implementation Plan: Add And Edit Expense

**Branch**: `004-add-edit-expense` | **Date**: 2026-05-28 | **Spec**: `specs/004-add-edit-expense/spec.md`

**Input**: Feature specification from `/specs/004-add-edit-expense/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

## Summary

Implement the quick, AI text, receipt, and edit expense screens with shared native widgets and local form state. All AI, receipt, camera, upload, and save behaviors are mocked visually.

## Why

These screens are interactive and high-risk. The Stitch exports suggest AI parsing, receipt scanning, microphone/camera input, and saving. The plan preserves visual fidelity without implementing those services.

## Expected Result

- `/expenses/new/quick`
- `/expenses/new/text`
- `/expenses/new/receipt`
- `/expenses/:expenseId/edit`
- `SegmentedModeControl`, `AmountInputHero`, `ExpenseFormCard`, `AiExpenseParsePanel`, `ReceiptUploadPanel`
- Add/edit widget and route tests

## Source References

- `stitch_ai_expenses_tracker_pro/add_expense_quick_mode/`
- `stitch_ai_expenses_tracker_pro/add_expense_ai_text_mode/`
- `stitch_ai_expenses_tracker_pro/add_expense_receipt_mode/`
- `stitch_ai_expenses_tracker_pro/edit_expense/`
- `specs/component-map.md`
- `specs/design-system.md`

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**: Foundation widgets, mock expense/category/wallet data

**Storage**: N/A. Local widget/controller state only.

**Testing**: Widget tests for forms, route parameter behavior, LTR/RTL, and forbidden dependency search

**Target Platform**: Flutter mobile prototype verified at 360x800, 375x812, and 390x844

**Constraints**: No camera, OCR, microphone, file picker, AI API, backend, persistence, WebView, or HTML rendering

## Constitution Check

- Project law read: PASS
- Skills used: PASS
- UI-only scope preserved: PASS
- No WebView or HTML rendering planned: PASS
- Native Flutter widgets planned: PASS
- Reuse planned: PASS
- Local state only: PASS
- Required responsive and RTL checks planned: PASS
- Compile checks listed: PASS

## Project Structure

```text
lib/features/expenses/presentation/add_expense_quick_screen.dart
lib/features/expenses/presentation/add_expense_ai_text_screen.dart
lib/features/expenses/presentation/add_expense_receipt_screen.dart
lib/features/expenses/presentation/edit_expense_screen.dart
lib/features/expenses/presentation/widgets/
test/features/expenses/
```

**Structure Decision**: Keep all add/edit expense screens under the expenses feature because they share domain forms and mock expense data.

## Reuse Strategy

Use foundation widgets plus expense components. Create shared `ExpenseFormCard`, `SegmentedModeControl`, `AmountInputHero`, `AiExpenseParsePanel`, and `ReceiptUploadPanel` rather than screen-local variants.

## Mock Data Strategy

Create `ExpenseDraft` local state copied from mock expenses when editing. AI/receipt parsing toggles a static `MockParsedExpense`; no data is persisted or uploaded.

## Possible Bugs And Fix Strategy

- Camera/OCR/file picker package added: remove dependency and use local mock toggle.
- AI API call added: remove client/import and render static suggestion.
- Keyboard overflow: scroll body and safe-area footer.
- Amount overflow: constrain and fit large currency text.
- Route ID crash: route unknown IDs to not-found or safe fallback.
- Global mock mutation: copy values into local controllers.

## Verification Plan

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Forbidden search:

```powershell
rg -n "camera|image_picker|file_picker|ocr|speech|microphone|openai|anthropic|firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|api" lib pubspec.yaml test
```

Viewport checks: 360x800, 375x812, 390x844 in LTR and RTL.

## Phase 0: Research

Completed in `research.md`.

## Phase 1: Design

Completed in `data-model.md`, `contracts/ui-contract.md`, `quickstart.md`, and `tasks.md`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
