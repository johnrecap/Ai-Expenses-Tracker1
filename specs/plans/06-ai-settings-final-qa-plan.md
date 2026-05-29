# AI, Settings, Empty States, And Final QA Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete AI surfaces, settings, missing lightweight states, and final QA for the UI-only prototype.

**Architecture:** Build AI and settings screens from static mock insights,
static chat messages, local-only input state, and shared settings rows. Add
reusable empty/no-results/not-found surfaces and run full compile, dependency,
viewport, and RTL checks.

**Tech Stack:** Flutter, foundation widgets, mock AI/settings data, widget tests.

---

## Depends On

- `specs/plans/00-foundation-plan.md`
- Prior feature plans for shared shell and visual patterns.

## Screens Covered

- `ai_advice_insights`
- `ai_history_assistant`
- `ai_assistant_bottom_sheet`
- `settings_main`

Additional surfaces:

- Empty states for lists/reports/budgets/goals/wallets/subscriptions/AI history.
- No-results state for search/filter.
- `/not-found`.

## Why

AI and settings are the easiest places to accidentally implement real services,
auth, persistence, or APIs. This plan keeps them visual-only and then verifies
the whole app.

## Expected Result

AI advice, Arabic AI history, AI assistant bottom sheet, settings, empty states,
not-found, and final QA pass are complete.

## Source References

- `stitch_ai_expenses_tracker_pro/ai_advice_insights/*`
- `stitch_ai_expenses_tracker_pro/ai_history_assistant/*`
- `stitch_ai_expenses_tracker_pro/ai_assistant_bottom_sheet/*`
- `stitch_ai_expenses_tracker_pro/settings_main/*`
- `specs/screens-inventory.md`
- `specs/component-map.md`
- `specs/design-system.md`

## Files And Ownership

- Create: `lib/features/ai/presentation/ai_advice_screen.dart`
- Create: `lib/features/ai/presentation/ai_history_screen.dart`
- Create: `lib/features/ai/presentation/ai_assistant_sheet.dart`
- Create: `lib/features/ai/presentation/widgets/chat_bubble.dart`
- Create: `lib/features/ai/presentation/widgets/suggested_prompt_chip.dart`
- Create: `lib/features/settings/presentation/settings_screen.dart`
- Create: `lib/features/settings/presentation/widgets/settings_row.dart`
- Create/modify: `lib/core/widgets/empty_state.dart`
- Create: `lib/app/not_found_screen.dart`
- Modify: `lib/app/router.dart`
- Modify: `lib/core/mock/mock_data.dart`
- Test: `test/features/ai/ai_ui_test.dart`
- Test: `test/features/settings/settings_test.dart`
- Test: `test/app/final_ui_contract_test.dart`

## Tasks

- [ ] T601 [AI] Build AI advice screen.
  - Why: AI advice is a major app promise but must remain static and offline.
  - Expected result: `/ai/advice` renders insight cards and recommendation sections from `MockAiInsight`.
  - Inputs: `ai_advice_insights/screen.png`, `ai_advice_insights/code.html`.
  - Implementation notes: Use `AiInsightCard`; no AI SDK, network, or prompt execution.
  - Possible bugs: worker adds AI API client, insight cards duplicate dashboard card code, long insight text overflows.
  - Fix strategy: remove API package, reuse shared card, constrain text and make screen scrollable.
  - Verification: AI advice widget test and forbidden dependency search pass.

- [ ] T602 [AI] Build AI history screen with Arabic RTL readiness.
  - Why: This screen validates Arabic typography, RTL chat alignment, prompt chips, and chat input layout.
  - Expected result: `/ai/history` renders mock chat history, Arabic prompt chips, and input row.
  - Inputs: `ai_history_assistant/screen.png`, `ai_history_assistant/code.html`.
  - Implementation notes: Use clean Arabic strings, IBM Plex Sans Arabic fallback, and `TextDirection.rtl` test.
  - Possible bugs: mojibake copied from HTML, user/assistant bubbles align wrong, input row clips at 360px.
  - Fix strategy: rewrite Arabic copy, use directional alignment, make prompt chips horizontally scrollable.
  - Verification: RTL widget test verifies bubble alignment and no overflow.

- [ ] T603 [AI] Build AI assistant bottom sheet.
  - Why: This is the second modal surface and must behave well with keyboard/safe area.
  - Expected result: `/ai/assistant` or assistant trigger opens `GlassBottomSheet` with mock messages, prompt chips, and input.
  - Inputs: `ai_assistant_bottom_sheet/screen.png`, `ai_assistant_bottom_sheet/code.html`.
  - Implementation notes: Sending a message may append local mock text only.
  - Possible bugs: sheet too tall, keyboard hides input, network call added.
  - Fix strategy: cap sheet height, use scrollable body and safe footer, remove network code.
  - Verification: bottom sheet test opens, sends local message, and closes.

- [ ] T604 [Settings] Build settings screen and rows.
  - Why: Settings completes the main shell and validates static toggles/profile UI.
  - Expected result: `/settings` renders profile header, settings rows, toggles, and local-only actions.
  - Inputs: `settings_main/screen.png`, `settings_main/code.html`.
  - Implementation notes: Toggles use widget state only; subpage rows route to placeholders or show local feedback.
  - Possible bugs: preferences persistence added, account management implied, row styling duplicated.
  - Fix strategy: keep state local, use `SettingsRow`, avoid auth/profile services.
  - Verification: settings test toggles controls without external calls.

- [ ] T605 [States] Add reusable empty, no-results, and not-found states.
  - Why: The exports miss important edge states; the prototype needs graceful UI without backend.
  - Expected result: `EmptyState` variants and `/not-found` are available and wired to routes/search placeholders.
  - Inputs: missing/deferred screens section in `specs/screens-inventory.md`.
  - Implementation notes: Use abstract native icons or local assets; no generated network imagery.
  - Possible bugs: empty state too decorative, not-found route loops, no-results state changes global data.
  - Fix strategy: keep empty state compact, route unknown paths to one widget, derive no-results from local search state.
  - Verification: tests cover `/not-found` and no-results rendering.

- [ ] T606 [QA] Run final UI-only verification.
  - Why: This proves all plans produced a native Flutter UI-only prototype.
  - Expected result: compile, analyze, tests, dependency search, and viewport checks pass or environment failures are documented.
  - Inputs: all implementation files and all specs.
  - Implementation notes: Fix root causes in shared widgets/tokens first.
  - Possible bugs: hidden WebView/API dependency, raw duplicated styles, narrow overflow, wrong RTL icon direction.
  - Fix strategy: run forbidden search, inspect every hit, add regression tests for overflows, replace non-directional APIs.
  - Verification: final gate below passes.

## Final Verification Gate

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

If Android tooling is unavailable:

```powershell
flutter build web
```

Forbidden dependency search:

```powershell
rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api|openai|anthropic|camera|image_picker|speech" lib pubspec.yaml test
```

Viewport checks:

```text
360x800 LTR
360x800 RTL
375x812 LTR
375x812 RTL
390x844 LTR
390x844 RTL
```

## Acceptance Criteria

- AI advice, AI history, AI assistant sheet, and settings render natively.
- Empty/no-results/not-found states exist.
- No real AI/API/auth/settings persistence/backend/WebView exists.
- Every detected Stitch screen has a native Flutter counterpart.
- Final compile, tests, dependency search, and viewport checks pass or exact environment blocker is documented.

## Stop Condition

The UI-only prototype is complete only after this plan's final verification gate
passes.
