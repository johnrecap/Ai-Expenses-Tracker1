# Tasks: Add And Edit Expense

**Input**: Design documents from `/specs/004-add-edit-expense/`

**Prerequisites**: `specs/001-foundation/` and transaction/category components from `specs/003-dashboard-expenses/`

## Mandatory First Read And Skill Gate

Skills used for task generation: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

## Non-Negotiable Rules

- UI only. No camera, OCR, microphone, file picker, AI API, backend, database, persistence, WebView, or HTML rendering.
- Native Flutter widgets only.
- Local state and static mock data only.
- Reuse shared components and tokens.
- Responsive for 360x800, 375x812, 390x844.
- Arabic RTL and English LTR ready.

## Phase 1: Shared Add/Edit Components

- [ ] T301 [P] [US1] Create `SegmentedModeControl` in `lib/features/expenses/presentation/widgets/segmented_mode_control.dart`
  - Why: Quick, text, and receipt modes need one consistent selector.
  - Expected result: Stable segmented control renders selected mode and supports callbacks.
  - Inputs: add expense exports, `specs/component-map.md`.
  - Implementation notes: Use fixed touch target heights and directional layout.
  - Possible bugs: Control resizes between labels; RTL order is wrong.
  - Fix strategy: Use stable constraints and test in LTR/RTL.
  - Verification: Widget test switches modes at 360px.

- [ ] T302 [P] [US1] Create `AmountInputHero` in `lib/features/expenses/presentation/widgets/amount_input_hero.dart`
  - Why: Large amount input is central to quick add and can easily overflow.
  - Expected result: Amount display/input handles large values and currency labels.
  - Inputs: `add_expense_quick_mode/screen.png`, design tokens.
  - Implementation notes: Use constrained text, no viewport-scaled font sizes.
  - Possible bugs: Long values overflow; keyboard hides field.
  - Fix strategy: Constrain width, use responsive text handling, and keep page scrollable.
  - Verification: Test renders large amount at 360px.

- [ ] T303 [US1] Create `ExpenseFormCard` in `lib/features/expenses/presentation/widgets/expense_form_card.dart`
  - Why: Add and edit screens share merchant, date, category, wallet, notes, and CTA sections.
  - Expected result: A reusable form card accepts draft values and callbacks.
  - Inputs: all add/edit exports.
  - Implementation notes: Controllers are owned by screen state; form card stays reusable.
  - Possible bugs: Controllers leak; form becomes screen-specific; raw styles appear.
  - Fix strategy: Dispose controllers in owners and move visual constants into theme.
  - Verification: Form card widget test renders all fields.

- [ ] T304 [P] [US2] Create `AiExpenseParsePanel` in `lib/features/expenses/presentation/widgets/ai_expense_parse_panel.dart`
  - Why: AI text mode needs a parse UI while staying offline.
  - Expected result: Text area, parse button, and mock suggestion preview render.
  - Inputs: `add_expense_ai_text_mode/screen.png`, `code.html`.
  - Implementation notes: Parse toggles local state only; no AI/network client.
  - Possible bugs: AI SDK added; text area grows unbounded.
  - Fix strategy: Remove API imports and cap text area height.
  - Verification: Test taps parse and sees mock suggestion.

- [ ] T305 [P] [US2] Create `ReceiptUploadPanel` in `lib/features/expenses/presentation/widgets/receipt_upload_panel.dart`
  - Why: Receipt mode needs upload/camera-looking UI without platform integrations.
  - Expected result: Dashed upload panel and mock parsed state render.
  - Inputs: `add_expense_receipt_mode/screen.png`, `code.html`.
  - Implementation notes: Buttons toggle local mock state; no camera/OCR/file picker packages.
  - Possible bugs: Platform permission package added; scan animation flakes in tests.
  - Fix strategy: Remove prohibited packages and keep animation simple or disabled in tests.
  - Verification: Test toggles mock parsed state.

## Phase 2: Screens

- [ ] T306 [US1] Build quick add screen in `lib/features/expenses/presentation/add_expense_quick_screen.dart`
  - Why: Quick mode is the primary add expense flow.
  - Expected result: `/expenses/new/quick` renders amount hero, category chips, form card, and save CTA.
  - Inputs: `add_expense_quick_mode/screen.png`, shared widgets.
  - Implementation notes: Save action is local feedback or navigation only.
  - Possible bugs: CTA hidden by keyboard; chips overflow; amount clips.
  - Fix strategy: Scroll body, safe footer, horizontal/wrap chips, constrained amount text.
  - Verification: Test enters amount and taps save without external call.

- [ ] T307 [US2] Build AI text screen in `lib/features/expenses/presentation/add_expense_ai_text_screen.dart`
  - Why: Detected AI add export needs native counterpart without AI service.
  - Expected result: `/expenses/new/text` renders prompt input, mock parse, suggestion preview, and form card.
  - Inputs: `add_expense_ai_text_mode/screen.png`, `AiExpenseParsePanel`.
  - Implementation notes: Microphone affordance is visual-only if present.
  - Possible bugs: Microphone permission added; parse implies network.
  - Fix strategy: Replace with inert icon/local state and run forbidden search.
  - Verification: Test parse button local behavior.

- [ ] T308 [US2] Build receipt screen in `lib/features/expenses/presentation/add_expense_receipt_screen.dart`
  - Why: Receipt export must be represented without camera/OCR/upload.
  - Expected result: `/expenses/new/receipt` renders upload panel, mock parsed fields, and save CTA.
  - Inputs: `add_expense_receipt_mode/screen.png`, `ReceiptUploadPanel`.
  - Implementation notes: No platform permissions; no file selection.
  - Possible bugs: File picker/camera dependency added; footer overlap.
  - Fix strategy: Remove dependency and add safe bottom padding.
  - Verification: Test upload tap produces mock state only.

- [ ] T309 [US3] Build edit screen in `lib/features/expenses/presentation/edit_expense_screen.dart`
  - Why: Edit route validates mock ID lookup and prefilled local form state.
  - Expected result: `/expenses/:expenseId/edit` shows prefilled form for known IDs and safe fallback for unknown IDs.
  - Inputs: `edit_expense/screen.png`, mock expenses.
  - Implementation notes: Copy mock values into local controllers; do not mutate static list.
  - Possible bugs: Unknown ID crash; global mock data changed permanently.
  - Fix strategy: Null-check lookup and keep edits local.
  - Verification: Tests for known and unknown expense IDs.

## Phase 3: Routes And Verification

- [ ] T310 [Routes] Wire add/edit routes in `lib/app/router.dart`
  - Why: Add/edit flows need stable central navigation.
  - Expected result: All four routes resolve to native screens.
  - Inputs: `contracts/ui-contract.md`, route registry.
  - Implementation notes: No auth guard or persistence hook.
  - Possible bugs: Dynamic parameter not parsed; wrong screen opens for mode.
  - Fix strategy: Add route tests for each path.
  - Verification: Route smoke tests pass.

- [ ] T311 [Polish] Run compile, viewport, RTL, and forbidden dependency checks
  - Why: This feature has the highest risk of service creep.
  - Expected result: Commands pass or blockers documented; forbidden search clean.
  - Inputs: Completed add/edit files.
  - Implementation notes: Inspect camera/OCR/AI/search hits carefully.
  - Possible bugs: False positives in docs; hidden package in `pubspec.yaml`; overflow under keyboard.
  - Fix strategy: Remove implementation violations and fix scroll/safe-area layout.
  - Verification: `flutter pub get`, `flutter analyze`, `flutter test`, debug build, viewport checks, forbidden search.

## Dependencies And Execution Order

T301-T305 create shared components. T306-T309 depend on them. T310 depends on screens. T311 is final.

## Acceptance Criteria

- Four screens render natively.
- Parse/upload/save are local-only.
- No camera/OCR/microphone/file picker/AI/backend/API/database/persistence/WebView/HTML rendering.
- Required viewport and RTL/LTR checks pass.
