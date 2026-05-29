# UI-Only Flutter Implementation Plan: Launch, Onboarding, And Auth Mock

**Branch**: `002-launch-onboarding-auth` | **Date**: 2026-05-28 | **Spec**: `specs/002-launch-onboarding-auth/spec.md`

**Input**: Feature specification from `/specs/002-launch-onboarding-auth/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`, `flutter-setup-localization`.

## Summary

Build six native Flutter screens for launch, onboarding preferences, login, and sign-up using foundation components and local state only.

## Why

This batch establishes the user entry flow, demonstrates locale/currency preference UI, and includes auth-looking screens without real auth. It removes risk around first-run navigation, keyboard overflow, and accidental auth/permission dependencies.

## Expected Result

- `/splash`
- `/onboarding/language`
- `/onboarding/currency`
- `/onboarding/notifications`
- `/auth/login`
- `/auth/sign-up`
- Reusable `OnboardingOptionCard` and `AuthPanel`
- Entry/auth widget and route tests

## Source References

- `stitch_ai_expenses_tracker_pro/splash_loading/screen.png`
- `stitch_ai_expenses_tracker_pro/splash_loading/code.html`
- `stitch_ai_expenses_tracker_pro/onboarding_language_selection/`
- `stitch_ai_expenses_tracker_pro/onboarding_base_currency/`
- `stitch_ai_expenses_tracker_pro/onboarding_notifications/`
- `stitch_ai_expenses_tracker_pro/login_authentication/`
- `stitch_ai_expenses_tracker_pro/sign_up/`
- `specs/design-system.md`
- `specs/component-map.md`

## Technical Context

**Language/Version**: Flutter 3.44.0 / Dart 3.12.0

**Primary Dependencies**: Foundation widgets, Material widgets, optional route package from foundation

**Storage**: N/A. Local widget state only.

**Testing**: Widget tests for screens, route smoke tests, LTR/RTL viewport checks

**Target Platform**: Flutter mobile prototype verified at 360x800, 375x812, and 390x844

**Project Type**: UI-only Flutter mobile app prototype

**Performance Goals**: Stable first-run transitions and scrollable keyboard-safe forms

**Constraints**: No auth SDK, Google auth, permission API, persistence, backend, WebView, or HTML rendering

## Constitution Check

- Project law read: PASS
- Skills used: PASS
- UI-only scope preserved: PASS
- No WebView or HTML rendering planned: PASS
- Native Flutter widgets planned: PASS
- Reuse of foundation widgets planned: PASS
- Mock/local state only: PASS
- Required responsive and RTL checks planned: PASS
- Compile checks listed: PASS

## Project Structure

```text
lib/features/onboarding/presentation/
lib/features/onboarding/presentation/widgets/
lib/features/auth/presentation/
lib/features/auth/presentation/widgets/
test/features/onboarding/
test/features/auth/
```

**Structure Decision**: Keep onboarding and auth UI in separate feature folders; keep shared primitives in `lib/core/widgets/`.

## Reuse Strategy

Use `AppBackground`, `GlassCard`, `GradientButton`, `AppTopBar`, `IconCircleButton`, and theme tokens. Create `OnboardingOptionCard` and `AuthPanel` only once and reuse across variants.

## Mock Data Strategy

Use local option lists for language, currency, notification choices, and local form controllers. No persistence or auth state is introduced.

## Possible Bugs And Fix Strategy

- Keyboard overflow: wrap form body in `SingleChildScrollView` and safe footer.
- Mojibake Arabic: manually rewrite clean Arabic strings.
- Real permission/auth creep: remove packages/imports and replace with local visual state.
- Route loops: add route smoke tests for all entry paths.
- Logo asset failure: verify foundation asset registration and fallback icon.

## Verification Plan

Run:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Forbidden dependency search:

```powershell
rg -n "firebase|Firebase|google_sign_in|auth|OAuth|http|dio|permission|notifications|WebView|webview|shared_preferences|api" lib pubspec.yaml test
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
