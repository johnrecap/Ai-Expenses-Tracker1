# UI-Only Flutter Implementation Plan: AI, Settings, Empty States, And Final QA

**Branch**: `007-ai-settings-final-qa` | **Date**: 2026-05-28 | **Spec**: `specs/007-ai-settings-final-qa/spec.md`

**Input**: Feature specification from `/specs/007-ai-settings-final-qa/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`, `flutter-setup-localization`.

## Summary

Implement AI advice, AI history, AI assistant bottom sheet, settings, reusable empty/no-results/not-found states, and final QA checks for the full UI-only prototype.

## Why

AI and settings are the easiest areas to accidentally implement real services, persistence, auth, or APIs. This final batch completes the screen set and verifies the whole app remains native, responsive, RTL-ready, and UI-only.

## Expected Result

- `/ai/advice`
- `/ai/history`
- `/ai/assistant`
- `/settings`
- `/not-found`
- Reusable empty/no-results states
- `ChatBubble`, `SuggestedPromptChip`, `SettingsRow`
- Final QA contract tests and dependency searches

## Source References

- `stitch_ai_expenses_tracker_pro/ai_advice_insights/`
- `stitch_ai_expenses_tracker_pro/ai_history_assistant/`
- `stitch_ai_expenses_tracker_pro/ai_assistant_bottom_sheet/`
- `stitch_ai_expenses_tracker_pro/settings_main/`
- `specs/screens-inventory.md`
- `specs/component-map.md`
- `specs/design-system.md`
- Previous feature plans under `specs/001-foundation/` through `specs/006-wallets-subscriptions/`

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**: Foundation widgets and mock data

**Storage**: N/A. Static mock data and local widget state only.

**Testing**: Widget tests, route tests, final forbidden dependency search, viewport and RTL checks

**Target Platform**: Flutter mobile prototype verified at 360x800, 375x812, and 390x844

**Constraints**: No AI/chat API, backend, auth/account service, database, persistence, WebView, HTML rendering, or remote runtime assets

## Constitution Check

- Project law read: PASS
- Skills used: PASS
- UI-only scope preserved: PASS
- No WebView or HTML rendering planned: PASS
- Native Flutter widgets planned: PASS
- Reuse planned: PASS
- Mock/local state only: PASS
- Required responsive and RTL checks planned: PASS
- Compile checks listed: PASS

## Project Structure

```text
lib/features/ai/presentation/
lib/features/ai/presentation/widgets/
lib/features/settings/presentation/
lib/features/settings/presentation/widgets/
lib/core/widgets/empty_state.dart
lib/app/not_found_screen.dart
test/features/ai/
test/features/settings/
test/app/
```

**Structure Decision**: AI and settings own their domain widgets; generic empty/not-found UI belongs in core/app.

## Reuse Strategy

Use `AiInsightCard`, `GlassBottomSheet`, `SearchField`, `FilterChipRow`, `GradientButton`, `GlassCard`, `AppTopBar`, `AppBottomNav`, `SectionHeader`, and theme/layout tokens. Create chat and settings components once.

## Mock Data Strategy

Use static `MockAiInsight`, `MockChatMessage`, `SuggestedPrompt`, and settings row data. Chat send and toggles mutate local widget state only and do not persist.

## Possible Bugs And Fix Strategy

- AI SDK/API added: remove dependency and use static mock messages.
- Arabic mojibake: manually rewrite clean Arabic text.
- RTL bubble alignment wrong: use directional alignment and RTL widget tests.
- Bottom sheet overflow: cap height, scroll body, safe footer.
- Settings persistence creep: keep toggles local and avoid preferences packages.
- Missing route states: add `/not-found` and reusable `EmptyState`.
- Duplicated UI after all batches: refactor repeated patterns into shared widgets.

## Verification Plan

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

Final forbidden search:

```powershell
rg -n "firebase|Firebase|http|dio|WebView|webview|sqflite|shared_preferences|supabase|amplify|OAuth|api|openai|anthropic|camera|image_picker|file_picker|speech|microphone|plaid|stripe|paypal|billing|payment|Image.network|NetworkImage" lib pubspec.yaml test
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

## Phase 0: Research

Completed in `research.md`.

## Phase 1: Design

Completed in `data-model.md`, `contracts/ui-contract.md`, `quickstart.md`, and `tasks.md`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
