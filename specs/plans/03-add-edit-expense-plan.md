# Add And Edit Expense Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the add expense quick, AI text, receipt, and edit expense screens.

**Architecture:** Use one shared add/edit expense form system with mode-specific
panels. All parsing, receipt upload, camera, microphone, and save behavior is
mock-only local state.

**Tech Stack:** Flutter, foundation widgets, mock expenses/categories/wallets,
native forms.

---

## Depends On

- `specs/plans/00-foundation-plan.md`
- `specs/plans/02-dashboard-expenses-plan.md` for transaction/category components.

## Screens Covered

- `add_expense_quick_mode`
- `add_expense_ai_text_mode`
- `add_expense_receipt_mode`
- `edit_expense`

## Why

These screens are interactive and high-risk because the Stitch export visually
suggests AI parsing, receipt scanning, microphone input, camera, and save
actions. The prototype must show the UI without implementing those services.

## Expected Result

Users can open add/edit routes, switch modes, type into visual fields, see mock
AI/receipt suggestions, and tap save buttons without any backend or device
integration.

## Source References

- `stitch_ai_expenses_tracker_pro/add_expense_quick_mode/*`
- `stitch_ai_expenses_tracker_pro/add_expense_ai_text_mode/*`
- `stitch_ai_expenses_tracker_pro/add_expense_receipt_mode/*`
- `stitch_ai_expenses_tracker_pro/edit_expense/*`
- `specs/component-map.md`

## Files And Ownership

- Create: `lib/features/expenses/presentation/add_expense_quick_screen.dart`
- Create: `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
- Create: `lib/features/expenses/presentation/add_expense_receipt_screen.dart`
- Create: `lib/features/expenses/presentation/edit_expense_screen.dart`
- Create: `lib/features/expenses/presentation/widgets/segmented_mode_control.dart`
- Create: `lib/features/expenses/presentation/widgets/amount_input_hero.dart`
- Create: `lib/features/expenses/presentation/widgets/expense_form_card.dart`
- Create: `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
- Create: `lib/features/expenses/presentation/widgets/receipt_upload_panel.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/expenses/add_edit_expense_test.dart`

## Tasks

- [ ] T301 [Widgets] Build shared add/edit expense components.
  - Why: Four screens share the same mode selector, category chips, wallet/currency rows, and form fields.
  - Expected result: `SegmentedModeControl`, `AmountInputHero`, `ExpenseFormCard`, `AiExpenseParsePanel`, and `ReceiptUploadPanel` exist.
  - Inputs: all add/edit expense exports and `specs/component-map.md`.
  - Implementation notes: Components accept mock values and callbacks; no service calls.
  - Possible bugs: components become screen-specific, fixed widths overflow, controllers leak.
  - Fix strategy: parameterize labels/values, constrain width, dispose controllers in stateful owners.
  - Verification: component tests render all panels at 360px.

- [ ] T302 [Screen] Build quick add expense screen.
  - Why: Quick mode is the primary manual entry flow.
  - Expected result: `/expenses/new/quick` shows amount hero, category chips, wallet/currency rows, and save CTA.
  - Inputs: `add_expense_quick_mode/screen.png`, `code.html`.
  - Implementation notes: Save action shows local visual feedback or navigates back; it does not mutate persistent data.
  - Possible bugs: amount font overflows, keyboard covers CTA, category chips wrap poorly.
  - Fix strategy: use constrained amount text, scrollable body, sticky safe-area footer, horizontal/wrap chip layout as needed.
  - Verification: quick add widget test enters an amount and taps save without external calls.

- [ ] T303 [Screen] Build AI text add expense screen.
  - Why: This screen must communicate AI capability visually while remaining static/offline.
  - Expected result: `/expenses/new/text` shows natural-language input, mock parse CTA, review banner, and prefilled suggestion card.
  - Inputs: `add_expense_ai_text_mode/screen.png`, `code.html`.
  - Implementation notes: Parse button toggles a local suggested result; microphone button is visual-only.
  - Possible bugs: AI SDK added, microphone permission used, textarea grows past viewport.
  - Fix strategy: remove SDK/permission code, keep mock state, cap textarea height with scroll.
  - Verification: forbidden dependency search and screen test for local parse state.

- [ ] T304 [Screen] Build receipt add expense screen.
  - Why: Receipt mode is visually important but must not implement camera/OCR/file picking.
  - Expected result: `/expenses/new/receipt` shows dashed upload panel, mock scanning/progress, parsed form fields, and save CTA.
  - Inputs: `add_expense_receipt_mode/screen.png`, `code.html`.
  - Implementation notes: Upload/camera button toggles a local mock parsed state only.
  - Possible bugs: camera/OCR/file picker dependency added, scan animation causes test flake, form footer overlaps nav.
  - Fix strategy: remove prohibited packages, simplify animation in tests, add bottom safe padding.
  - Verification: receipt mode test toggles mock parsed state without platform permissions.

- [ ] T305 [Screen] Build edit expense screen.
  - Why: Existing expense editing uses the same form concepts but with prefilled mock data.
  - Expected result: `/expenses/:expenseId/edit` shows prefilled merchant/category/date/amount fields.
  - Inputs: `edit_expense/screen.png`, `code.html`, mock expense IDs.
  - Implementation notes: Copy mock values into local controllers; do not mutate global mock data unless state is intentionally ephemeral.
  - Possible bugs: missing ID crashes, edits change global mock list, route param not handled.
  - Fix strategy: route unknown IDs to not-found or first mock item; use local state; add ID lookup test.
  - Verification: edit route test opens a known and unknown expense ID.

## Possible Bugs And Fix Strategy

- Service creep: remove camera, OCR, microphone, AI, storage, or network packages.
- Keyboard overflow: wrap forms in scroll views and use safe footer padding.
- Mode state bugs: keep each screen's mode state local or route-specific.
- Duplicated forms: consolidate in `ExpenseFormCard`.

## Verification

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Forbidden dependency search:

```powershell
rg -n "camera|image_picker|firebase|Firebase|http|dio|WebView|webview|ocr|speech|sqflite|shared_preferences|api" lib pubspec.yaml test
```

## Acceptance Criteria

- Four covered screens render natively.
- No camera, OCR, microphone, AI, backend, API, database, persistence, WebView, or HTML rendering exists.
- Forms fit required mobile viewports.
- Arabic RTL does not break field alignment or action icons.

## Stop Condition

Do not start reports/budgets/goals until expense form components and route tests
are stable.
