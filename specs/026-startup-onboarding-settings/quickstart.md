# Quickstart: Startup Onboarding Settings

## Manual Review

1. Sign in with a user that has no settings document.
2. Open the app and confirm splash routes to language onboarding.
3. Select Arabic and continue.
4. Select EGP and continue.
5. Disable weekly digest, choose daily reminder state, and allow notifications.
6. Confirm the app waits for save success before opening home.
7. Restart the app and confirm it opens home, not onboarding.
8. Confirm app locale follows saved language.
9. Repeat with English and another supported currency.
10. Repeat skip notifications and confirm no reminder is scheduled.

## Commands

```powershell
& 'C:\flutter\bin\flutter.bat' gen-l10n
& 'C:\flutter\bin\flutter.bat' analyze lib/app/app.dart lib/app/router.dart lib/main.dart lib/features/onboarding/onboarding_cubit/onboarding_cubit.dart lib/features/onboarding/presentation/splash_screen.dart lib/features/onboarding/presentation/notifications_screen.dart lib/services/notifications/notification_service.dart packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart packages/expense_repository/lib/src/entities/user_settings_entity.dart packages/expense_repository/lib/src/models/notification_settings.dart test/features/onboarding test/features/settings test/app/routes_test.dart
& 'C:\flutter\bin\flutter.bat' test test/features/onboarding
& 'C:\flutter\bin\flutter.bat' test test/features/settings
& 'C:\flutter\bin\flutter.bat' test test/app/routes_test.dart
```

Do not run a full-project analyzer for this feature unless Mohamed explicitly asks. Do not analyze all of `lib` or all of `packages/expense_repository/lib`. Keep analysis scoped to exact files touched by this feature plus focused tests.

## Files To Inspect Before Editing

1. `lib/app/app.dart`
2. `lib/app/router.dart`
3. `lib/features/onboarding/onboarding_cubit/onboarding_cubit.dart`
4. `lib/features/onboarding/presentation/splash_screen.dart`
5. `lib/features/onboarding/presentation/language_screen.dart`
6. `lib/features/onboarding/presentation/base_currency_screen.dart`
7. `lib/features/onboarding/presentation/notifications_screen.dart`
8. `lib/features/settings/settings_cubit/settings_cubit.dart`
9. `lib/l10n/app_language_cubit.dart`
10. `packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart`
11. `packages/expense_repository/lib/src/entities/user_settings_entity.dart`
12. `packages/expense_repository/lib/src/models/notification_settings.dart`
13. `firestore.rules`
14. `lib/services/notifications/notification_service.dart`
15. `android/app/src/main/AndroidManifest.xml`

## Visual Checks

```text
360x800 Arabic RTL
360x800 English LTR
375x812 Arabic RTL
375x812 English LTR
390x844 Arabic RTL
390x844 English LTR
```
