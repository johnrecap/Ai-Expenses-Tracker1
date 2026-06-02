# Data Model: Startup Onboarding Settings

## UserSettings

Represents saved user preferences and onboarding status.

Fields used by this feature:

- `userId`: signed-in user id.
- `languagePreference`: `system`, `en`, or `ar`.
- `baseCurrency`: uppercase three-letter currency code.
- `supportedCurrencies`: list containing the base currency.
- `notificationSettings`: nested notification preferences.
- `onboardingCompleted`: whether onboarding is complete.
- `onboardingVersion`: completed onboarding version.
- `updatedAt`: last update timestamp.

Validation:

- `userId` must match the authenticated user.
- `baseCurrency` must be a valid uppercase three-letter code.
- `languagePreference` must be one of the supported values.
- Onboarding completion must not erase unrelated settings fields.

## OnboardingDraft

Temporary state while the user moves through onboarding.

Fields:

- `language`: selected language code.
- `currency`: selected base currency code.
- `notificationsEnabled`: final notification allow/skip choice.
- `dailyReminderEnabled`: whether daily reminder is selected.
- `weeklyDigestEnabled`: whether weekly digest is selected.
- `dailyReminderTime`: selected reminder time when daily reminder is enabled.
- `loading`: save in progress.
- `completed`: save completed.
- `errorMessage`: save or permission error.

Validation:

- `language` must be `en` or `ar`.
- `currency` must be normalized before saving.
- Final navigation happens only after successful save.

## NotificationSettings

Represents notification preferences saved with user settings.

Fields:

- `budgetAlerts`
- `recurringReminders`
- `subscriptionRenewals`
- `weeklyDigest`
- `aiQuotaWarnings`
- `dailyReminder`
- `dailyReminderTime`

Validation:

- Boolean fields must remain booleans.
- `dailyReminderTime` is optional and only meaningful when `dailyReminder` is true.
- Serialization and Firestore rules must support the same fields.

## StartupDecision

Represents where the app should go after auth/settings resolution.

Values:

- `login`
- `onboarding`
- `home`
- `retry`

Validation:

- Unauthenticated users go to `login`.
- Authenticated users without completed current onboarding go to `onboarding`.
- Authenticated users with completed current onboarding go to `home`.
- Settings load failures show a retry/error state instead of pretending success.
