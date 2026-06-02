# Baseline: Startup Onboarding Settings

Date: 2026-05-31

## Workspace State

- Current branch: `main`.
- `check-prerequisites.ps1` could not complete normally because the repo is not on a Spec Kit feature branch.
- Existing working tree is dirty before this feature work. Notable unrelated changes are present in AI, dashboard, expense receipt, generated localization, platform registrants, `pubspec.yaml`, and tests.
- No secrets or `.env` values were inspected or recorded.

## Focused Commands Attempted

```powershell
& 'C:\flutter\bin\flutter.bat' test test/features/onboarding
```

Result: timed out after 120 seconds before code edits.

```powershell
& 'C:\flutter\bin\flutter.bat' test test/app/routes_test.dart
```

Result: timed out after 120 seconds before code edits.

## Current Feature Issues Observed From Code

- `MaterialApp.router` is hardcoded to `Locale('ar')`, so saved language cannot drive app locale.
- `AppLocalizations.delegate` is not wired into `MaterialApp.router`.
- `SettingsCubit` is created without loading settings at authenticated startup.
- `SplashScreen` routes authenticated users to home if settings are missing, loading, failing, or provider access throws.
- Onboarding routes are listed as public, even though onboarding screens read `OnboardingCubit`.
- `FirebaseSettingsRepository.ensureDefaultSettings()` overwrites defaults every call.
- `LocalSettingsRepository.ensureDefaultSettings()` also overwrites existing local settings.
- `OnboardingCubit.completeOnboarding()` ignores actual notification choices and does not preserve supported currency intent explicitly.
- `NotificationsScreen` navigates home immediately after calling `completeOnboarding()` without waiting for save success.
- `NotificationSettings` model includes more fields than Firestore serialization/rules persist.
- `NotificationService` does not initialize timezone data and silently no-ops when uninitialized.
- Android manifest does not declare `POST_NOTIFICATIONS`.

## Baseline Scope Note

This baseline is intentionally limited to startup, onboarding, settings persistence, localization, notification settings, and focused tests. Dashboard/smart-add/AI changes are treated as unrelated concurrent work.
