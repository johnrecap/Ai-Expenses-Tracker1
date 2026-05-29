# Tasks: AI, Settings, Empty States, And Final QA

**Input**: Design documents from `/specs/007-ai-settings-final-qa/`

**Prerequisites**: Previous six feature plans approved and implemented

## Mandatory First Read And Skill Gate

Skills used for task generation: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`, `flutter-setup-localization`.

## Non-Negotiable Rules

- UI only. No AI/chat API, backend, auth/account service, database, persistence, WebView, HTML rendering, or remote runtime assets.
- Native Flutter widgets only.
- Static mock data and local state only.
- Reuse shared components and tokens.
- Responsive for 360x800, 375x812, 390x844.
- Arabic RTL and English LTR ready.

## Phase 1: AI Components

- [ ] T601 [P] [US2] Create `ChatBubble` in `lib/features/ai/presentation/widgets/chat_bubble.dart`
  - Why: AI history and assistant sheet both need consistent chat bubble layout.
  - Expected result: User and assistant bubbles render with direction-aware alignment.
  - Inputs: `ai_history_assistant`, `ai_assistant_bottom_sheet`, mock chat messages.
  - Implementation notes: Use clean Arabic strings and `TextDirection.rtl` where appropriate.
  - Possible bugs: Arabic text copied as mojibake; user/assistant alignment wrong in RTL; bubble width overflows.
  - Fix strategy: Manually clean Arabic copy, use directional alignment, and constrain max bubble width.
  - Verification: Chat bubble widget test in LTR and RTL at 360px.

- [ ] T602 [P] [US2] Create `SuggestedPromptChip` in `lib/features/ai/presentation/widgets/suggested_prompt_chip.dart`
  - Why: Prompt shortcuts repeat in AI history and assistant sheet.
  - Expected result: Prompt chips render with stable size and local callbacks.
  - Inputs: AI exports and `specs/component-map.md`.
  - Implementation notes: Use horizontal scrolling when multiple chips are present.
  - Possible bugs: Chips clip at 360px; callbacks imply API prompts.
  - Fix strategy: Use horizontal `ListView` and local mock callbacks only.
  - Verification: Prompt chip row test at 360px.

## Phase 2: AI Screens

- [ ] T603 [US1] Build `AiAdviceScreen` in `lib/features/ai/presentation/ai_advice_screen.dart`
  - Why: AI advice is a core product promise and detected export.
  - Expected result: `/ai/advice` renders AI insight and recommendation cards from mock data.
  - Inputs: `ai_advice_insights/screen.png`, `code.html`, mock AI insights.
  - Implementation notes: Reuse `AiInsightCard`; no AI/network imports.
  - Possible bugs: AI API client added; long advice text overflows; duplicated dashboard insight card code.
  - Fix strategy: Remove API dependency, make content scrollable, reuse shared card.
  - Verification: AI advice widget test and forbidden search.

- [ ] T604 [US2] Build `AiHistoryScreen` in `lib/features/ai/presentation/ai_history_screen.dart`
  - Why: AI history validates Arabic RTL chat layout and prompt chips.
  - Expected result: `/ai/history` renders mock chat history, prompt chips, and input row.
  - Inputs: `ai_history_assistant/screen.png`, `code.html`.
  - Implementation notes: Use clean Arabic text; sending can append local canned response only.
  - Possible bugs: Input row clips; prompt chips overflow; network call introduced.
  - Fix strategy: Safe footer, horizontal chips, local state only.
  - Verification: RTL widget test sends local message.

- [ ] T605 [US2] Build `AiAssistantSheet` in `lib/features/ai/presentation/ai_assistant_sheet.dart`
  - Why: Assistant bottom sheet is a detected modal surface and must be keyboard-safe.
  - Expected result: `/ai/assistant` or assistant trigger opens native bottom sheet with mock messages and input.
  - Inputs: `ai_assistant_bottom_sheet/screen.png`, `code.html`.
  - Implementation notes: Use `GlassBottomSheet`, capped height, scrollable messages, safe-area footer.
  - Possible bugs: Sheet too tall; keyboard hides input; send calls API.
  - Fix strategy: Constrain height, add safe padding, and keep send local.
  - Verification: Sheet test opens, sends local message, and closes.

## Phase 3: Settings And States

- [ ] T606 [P] [US3] Create `SettingsRow` in `lib/features/settings/presentation/widgets/settings_row.dart`
  - Why: Settings rows repeat icons, labels, values, chevrons, and toggles.
  - Expected result: Reusable row supports static, chevron, and toggle variants.
  - Inputs: `settings_main/screen.png`, `code.html`.
  - Implementation notes: Toggles use local callbacks only; directional layout.
  - Possible bugs: Row styles duplicated; toggle persists; chevrons do not mirror in RTL.
  - Fix strategy: Centralize row styling, keep state in screen, and use directional icons where needed.
  - Verification: Settings row widget test in LTR and RTL.

- [ ] T607 [US3] Build `SettingsScreen` in `lib/features/settings/presentation/settings_screen.dart`
  - Why: Settings completes the main shell and detected screen set.
  - Expected result: `/settings` renders profile header, settings rows, local toggles, and placeholder actions.
  - Inputs: `settings_main/screen.png`, `code.html`, mock user/settings rows.
  - Implementation notes: No account service, auth, storage, or preferences packages.
  - Possible bugs: Profile action implies real account management; toggles persist; rows overflow.
  - Fix strategy: Placeholder/snackbar actions, local state only, constrained row text.
  - Verification: Settings test toggles local controls without external calls.

- [ ] T608 [US3] Add `EmptyState` variants and `NotFoundScreen` in `lib/core/widgets/empty_state.dart` and `lib/app/not_found_screen.dart`
  - Why: Missing empty/no-results/not-found states should be graceful and reusable.
  - Expected result: Reusable empty state and `/not-found` are available.
  - Inputs: Missing screens section in `specs/screens-inventory.md`.
  - Implementation notes: Use native icons/local assets only; compact layout for 360px.
  - Possible bugs: Not-found route loops; empty state too tall; remote illustration added.
  - Fix strategy: Route unknown paths to one screen, constrain content, and avoid remote assets.
  - Verification: Tests cover `/not-found` and empty/no-results rendering.

## Phase 4: Routes And Final QA

- [ ] T609 [Routes] Wire AI, settings, assistant, and not-found routes in `lib/app/router.dart`
  - Why: Final screens and fallback route must be reachable centrally.
  - Expected result: `/ai/advice`, `/ai/history`, `/ai/assistant`, `/settings`, and `/not-found` resolve correctly.
  - Inputs: `contracts/ui-contract.md`, route registry.
  - Implementation notes: Assistant may be represented as modal route while staying native.
  - Possible bugs: Assistant opens full screen unexpectedly; unknown route crashes.
  - Fix strategy: Add route tests and verify modal presentation.
  - Verification: Route smoke tests pass.

- [ ] T610 [QA] Verify every Stitch screen is mapped in `test/app/final_ui_contract_test.dart`
  - Why: Final QA must prove detected screens are accounted for.
  - Expected result: Contract test or checklist maps all detected screens to native routes/components or approved placeholders.
  - Inputs: `specs/screens-inventory.md`, all route files.
  - Implementation notes: This is a UI contract check, not a backend test.
  - Possible bugs: Missing screen route; modal sheets not counted; old placeholder remains.
  - Fix strategy: Add route/component mapping or document approved placeholder before final approval.
  - Verification: Final UI contract test passes.

- [ ] T611 [QA] Run final forbidden dependency and remote asset search
  - Why: The prototype must remain UI-only after all batches.
  - Expected result: No forbidden implementation hits remain.
  - Inputs: Completed app source.
  - Implementation notes: Inspect every hit and distinguish docs from source.
  - Possible bugs: False positives in comments; hidden package in `pubspec.yaml`; remote image call.
  - Fix strategy: Remove forbidden imports/packages and replace with mock/local widgets.
  - Verification: Final forbidden search command in `quickstart.md`.

- [ ] T612 [QA] Run final compile, test, viewport, and RTL checks
  - Why: Completion requires verified compile and mobile layout quality.
  - Expected result: Flutter commands pass or exact environment blockers are documented; required viewports and directions pass.
  - Inputs: Completed source and tests.
  - Implementation notes: Fix root causes in shared widgets/tokens first.
  - Possible bugs: Analyzer warnings, missing assets, Android tooling unavailable, narrow overflow, wrong RTL icon direction.
  - Fix strategy: Fix analyzer first, then assets, then platform issues; use web build fallback if Android unavailable.
  - Verification: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug` or documented fallback, plus 360/375/390 LTR/RTL visual checks.

## Dependencies And Execution Order

T601-T602 block AI chat surfaces. T606 blocks settings. T608 can run after foundation. T609 depends on screens/states. T610-T612 are final and depend on all selected implementation batches.

## Acceptance Criteria

- AI advice, AI history, assistant sheet, settings, empty states, and not-found render natively.
- No AI/chat API, backend, auth/account service, database, persistence, WebView, HTML rendering, or remote runtime assets.
- Every detected Stitch screen is mapped to a native route/component or approved placeholder.
- Final compile, test, forbidden search, viewport, and RTL/LTR checks pass or exact blockers are documented.
