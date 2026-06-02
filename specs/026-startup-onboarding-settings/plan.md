# Production Flutter Implementation Plan: Startup Onboarding Settings

**Branch**: `main` | **Date**: 2026-05-31 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/026-startup-onboarding-settings/spec.md`

## Mandatory First Read And Skill Gate

Completed before writing this plan:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Searched installed skills.
- Loaded relevant skills.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `speckit-implement`, `flutter-add-widget-test`.

## Summary

Fix startup and onboarding so the app makes decisions from real saved settings: load settings before routing, persist language and base currency safely, apply saved locale, save notification choices honestly, and align notification model/entity/rules/device setup.

## Why

The current implementation can skip onboarding, hardcodes Arabic locale, saves onboarding asynchronously while navigating immediately, and exposes notification toggles that are not actually persisted or initialized. This makes the first-run experience unreliable and makes backend settings look correct on paper but wrong in product behavior.

## Expected Result

- Splash/startup routes authenticated users based on real settings.
- Onboarding routes have the required providers.
- Language selection is saved and applied to `MaterialApp`.
- Base currency selection is saved without resetting unrelated settings.
- Notification onboarding saves the actual choices and initializes/request local notification support safely.
- Firestore settings serialization and rules agree on notification fields.
- Focused tests cover startup routing, onboarding save, settings persistence, locale, and notifications.

## Source References

- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/features/onboarding/onboarding_cubit/onboarding_cubit.dart`
- `lib/features/onboarding/presentation/splash_screen.dart`
- `lib/features/onboarding/presentation/language_screen.dart`
- `lib/features/onboarding/presentation/base_currency_screen.dart`
- `lib/features/onboarding/presentation/notifications_screen.dart`
- `lib/features/settings/settings_cubit/settings_cubit.dart`
- `lib/l10n/app_language_cubit.dart`
- `lib/l10n/app_localizations.dart`
- `packages/expense_repository/lib/src/settings_repo.dart`
- `packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart`
- `packages/expense_repository/lib/src/entities/user_settings_entity.dart`
- `packages/expense_repository/lib/src/models/user_settings.dart`
- `packages/expense_repository/lib/src/models/notification_settings.dart`
- `firestore.rules`
- `lib/services/notifications/notification_service.dart`
- `android/app/src/main/AndroidManifest.xml`
- Existing tests under `test/features/onboarding/`, `test/app/`, and `test/helpers/`

## Technical Context

**Language/Version**: Flutter / Dart.

**Primary Dependencies**: Existing Flutter, `flutter_bloc`, `go_router`, Firebase Auth/Firestore, `flutter_local_notifications`, generated `AppLocalizations`.

**Storage**: Firestore user settings document remains primary: `users/{userId}/settings/profile`. Local repository mode should remain compatible where practical.

**Testing**: Focused widget/unit tests plus scoped analyzer on app/source paths only. Firestore rules should be reviewed and tested if existing Firestore test harness is available.

**Target Platform**: Mobile Flutter app verified at 360x800, 375x812, and 390x844 in Arabic RTL and English LTR.

**Project Type**: Production Flutter app behavior/backend settings fix.

**Performance Goals**: Startup should avoid route flicker and should not hang indefinitely on settings load failures.

**Constraints**:

- No new design language.
- No fake onboarding success.
- No hardcoded locale overriding saved preference.
- No broad VPS rewrite.
- No API keys or secrets.
- No WebView or HTML rendering.

## Constitution Check

**Gate result**: PASS with production-scope clarification.

- Project law files read.
- Relevant skills loaded.
- Production app scope followed.
- Firebase/Firestore settings backend is allowed by constitution.
- Local notification setup is allowed by constitution.
- No WebView/HTML shortcut planned.
- Existing theme/components reused.
- Arabic RTL and English LTR checks planned.
- Compile/test checks planned.

## Project Structure

```text
specs/026-startup-onboarding-settings/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
    startup-routing-contract.md
    settings-persistence-contract.md
    notification-contract.md
  tasks.md

lib/
  app/
    app.dart
    router.dart
  features/
    onboarding/
      onboarding_cubit/
      presentation/
    settings/
      settings_cubit/
  l10n/
  services/
    notifications/
packages/
  expense_repository/lib/src/
firestore.rules
android/app/src/main/AndroidManifest.xml
test/
```

## Reuse Strategy

- Reuse existing onboarding screens and visual components.
- Reuse `SettingsRepository`, `UserSettings`, and `NotificationSettings` instead of creating parallel settings models.
- Reuse generated `AppLocalizations`.
- Reuse existing `SettingsCubit` where it fits, but add startup/onboarding-specific behavior only where it reduces routing bugs.

## Phase 0: Research

Research decisions are captured in [research.md](research.md).

## Phase 1: Design

Design artifacts:

- [data-model.md](data-model.md)
- [contracts/startup-routing-contract.md](contracts/startup-routing-contract.md)
- [contracts/settings-persistence-contract.md](contracts/settings-persistence-contract.md)
- [contracts/notification-contract.md](contracts/notification-contract.md)
- [quickstart.md](quickstart.md)

## Possible Bugs And Fix Strategy

- **Startup routes home before settings load**: make routing wait on settings/startup decision.
- **Onboarding route missing provider**: ensure providers exist for authenticated onboarding paths or block public onboarding paths correctly.
- **Existing settings overwritten**: change default creation to return existing settings when present.
- **Locale still hardcoded**: remove fixed `Locale('ar')` and derive locale from saved settings.
- **Generated localization delegate missing**: add `AppLocalizations.delegate` or `AppLocalizations.localizationsDelegates`.
- **Notification save shape rejected by Firestore**: update entity serialization and rules together.
- **Android notifications denied silently**: request/check permission before scheduling and reflect denied state.
- **Timezone schedule failure**: initialize timezone data or skip scheduling safely with visible non-blocking feedback.
- **Tests flaky due timers**: use test-friendly startup decision logic and avoid relying on real timers where possible.

## Verification Plan

```powershell
& 'C:\flutter\bin\flutter.bat' gen-l10n
& 'C:\flutter\bin\flutter.bat' analyze lib/app/app.dart lib/app/router.dart lib/main.dart lib/features/onboarding/onboarding_cubit/onboarding_cubit.dart lib/features/onboarding/presentation/splash_screen.dart lib/features/onboarding/presentation/notifications_screen.dart lib/services/notifications/notification_service.dart packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart packages/expense_repository/lib/src/entities/user_settings_entity.dart packages/expense_repository/lib/src/models/notification_settings.dart test/features/onboarding test/features/settings test/app/routes_test.dart
& 'C:\flutter\bin\flutter.bat' test test/features/onboarding
& 'C:\flutter\bin\flutter.bat' test test/app/routes_test.dart
```

Run additional focused tests the worker creates:

```powershell
& 'C:\flutter\bin\flutter.bat' test test/features/settings
& 'C:\flutter\bin\flutter.bat' test test/services/notifications
```

Manual checks:

```text
New signed-in user -> onboarding
Completed signed-in user -> home
Arabic selected -> Arabic locale/direction
English selected -> English locale/direction
Currency selected -> saved base currency
Allow notifications -> permission/request/save behavior
Skip notifications -> disabled save behavior
```

## Implementation Phases

### Phase 1 - Startup Decision Foundation

Stop condition:

- Startup uses auth plus settings state.
- Incomplete onboarding cannot route to home.
- Onboarding routes have required providers.

### Phase 2 - Settings Persistence

Stop condition:

- Existing settings are preserved.
- Language, currency, onboarding completion, and notification fields save correctly.
- Firestore rules and serialization match.

### Phase 3 - Localization Application

Stop condition:

- Saved language drives app locale.
- Generated localization delegate is wired.
- Arabic/English focused tests pass.

### Phase 4 - Notification Setup

Stop condition:

- Notification onboarding saves actual user choices.
- Local notification service initializes and requests permission safely.
- Scheduling only happens when allowed and configured.

### Phase 5 - Verification And Polish

Stop condition:

- Focused tests/analyzer pass or exact unrelated failures are documented.
- Narrow RTL/LTR checks are acceptable.

## Analyzer Scope Rule

Do not run broad repo-wide analysis for this feature. Analyzer commands must be scoped to exact changed files in `lib`, exact changed files in `packages/expense_repository/lib`, and focused test files created or changed by this work. Do not analyze the whole `lib` tree or the whole repository package.
