# Contract: Settings And Notifications

## Scope

Owned files:

- `lib/features/settings/presentation/settings_screen.dart`
- `lib/features/settings/settings_cubit/settings_cubit.dart`
- `lib/features/onboarding/presentation/language_screen.dart`
- `lib/features/onboarding/presentation/base_currency_screen.dart`
- `lib/features/onboarding/presentation/notifications_screen.dart`
- `lib/services/notifications/notification_service.dart`
- focused settings and notification tests

## Settings Guarantees

1. Language changes from Settings do not reset currency.
2. Currency changes from Settings do not reset language.
3. Settings changes do not reopen onboarding.
4. Arabic and English labels are localized.

## Notification Guarantees

1. Disabling notifications cancels app-managed scheduled reminders.
2. Enabling notifications requests permission before scheduling.
3. If permission is denied, notifications remain disabled and the user gets clear feedback.
4. Existing notification settings are persisted and restored correctly.

## Acceptance Tests

- Arabic + USD can change language without changing USD.
- English + EGP can change currency without changing English.
- Disable notifications calls cancel on the managed scheduler.
- Enable denied permission does not save a misleading enabled state.
