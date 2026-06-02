# Production Flutter Implementation Plan: Smart Add Entry

**Branch**: `main` | **Date**: 2026-05-31 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/025-smart-add-entry/spec.md`

## Mandatory First Read And Skill Gate

Completed before writing this plan:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Searched installed skills.
- Loaded relevant skills.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`.

## Summary

Replace the home screen's stacked add and AI floating buttons with one primary smart add button. Tapping it opens a clear add-choice sheet for AI text, quick add, full/manual add if available, and receipt only if it has real behavior or an intentional unavailable state.

## Why

The current home screen has multiple competing add/AI entry points. A finance app should make the most repeated action obvious: adding an expense. One smart add entry reduces confusion and keeps AI expense entry as a method of adding, not a separate floating concept.

## Expected Result

- One primary add button on `HomeDashboardScreen`.
- A reusable add-choice sheet/widget.
- AI text and quick add reachable in no more than two taps.
- Receipt is hidden, disabled, or clearly unavailable if not fully working.
- Top-bar AI remains assistant/help, separate from add expense.
- Route usage moves toward `AppRoutes` constants.
- Tests cover home button visibility, choice sheet, and route selection.

## Source References

- `lib/features/dashboard/presentation/home_dashboard_screen.dart`
- `lib/features/expenses/presentation/add_expense_quick_screen.dart`
- `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- `lib/features/expenses/presentation/add_expense_receipt_screen.dart`
- `lib/features/expenses/presentation/ai_expense_screen.dart`
- `lib/app/routes.dart`
- `lib/app/router.dart`
- `lib/core/theme/`
- `lib/core/widgets/`
- `specs/025-smart-add-entry/screen-feature-inventory.md`
- `specs/025-smart-add-entry/research.md`
- `specs/025-smart-add-entry/data-model.md`
- `specs/025-smart-add-entry/contracts/smart-add-contract.md`

## Technical Context

**Language/Version**: Flutter / Dart.

**Primary Dependencies**: Existing Flutter, `go_router`, `flutter_bloc`, current shared widgets and theme tokens.

**Storage**: No storage changes in this feature.

**Testing**: Widget tests and route tests.

**Target Platform**: Mobile Flutter app at 360x800, 375x812, and 390x844 in Arabic RTL and English LTR.

**Project Type**: Production Flutter app UI improvement.

**Performance Goals**: Add sheet opens instantly, no layout jump, no bottom navigation overlap.

**Constraints**:

- Do not change design language.
- Do not add mock data.
- Do not add backend behavior.
- Do not expose fake receipt/AI behavior as working.
- Do not use hardcoded route strings for new navigation.

## Constitution Check

**Gate result**: PASS.

- Project law files read.
- Relevant skills loaded.
- Production app scope preserved.
- No WebView/HTML shortcut planned.
- Existing theme and shared widgets reused.
- Arabic RTL and English LTR checks planned.
- Compile/test checks planned.

## Project Structure

```text
specs/025-smart-add-entry/
  spec.md
  plan.md
  research.md
  data-model.md
  tasks.md
  screen-feature-inventory.md
  contracts/
    smart-add-contract.md
  quickstart.md

lib/
  features/dashboard/presentation/home_dashboard_screen.dart
  features/dashboard/presentation/widgets/smart_add_sheet.dart
  app/routes.dart
  app/router.dart
test/
  features/dashboard/smart_add_sheet_test.dart
  features/dashboard/home_dashboard_test.dart
```

## Reuse Strategy

- Use `AppColors`, `AppSpacing`, `AppTextStyles`, `AppRadii`.
- Use existing `GlassCard`, `GradientButton`, and bottom-sheet styling patterns.
- Keep the primary add button visually aligned with current primary color.
- Use AI gradient only inside the AI text choice, not as a second floating button.

## Phase 0: Research

Research decisions are captured in [research.md](research.md).

Key resolved decisions:

- Use one primary FAB instead of two stacked FABs.
- Use a bottom sheet because it fits multiple add choices and works well on mobile.
- Keep the top-bar AI icon for assistant/help only.
- Route AI expense entry to the canonical AI text route.
- Receipt should be disabled/hidden until real behavior is ready.

## Phase 1: Design

Design artifacts:

- [data-model.md](data-model.md)
- [contracts/smart-add-contract.md](contracts/smart-add-contract.md)
- [quickstart.md](quickstart.md)
- [screen-feature-inventory.md](screen-feature-inventory.md)

## Verification Plan

```powershell
& 'C:\flutter\bin\flutter.bat' analyze
& 'C:\flutter\bin\flutter.bat' test test/features/dashboard/home_dashboard_test.dart
& 'C:\flutter\bin\flutter.bat' test test/features/dashboard/smart_add_sheet_test.dart
```

Manual checks:

```text
Home screen 360x800 Arabic RTL
Home screen 360x800 English LTR
Open add sheet
Tap AI text
Tap quick add
Tap receipt unavailable state
Dismiss sheet
```

## Stop Condition

Feature is complete when the home screen has one add entry point, the add choice sheet routes correctly, unavailable choices are honest, and no UI overlap appears on required narrow screens.
