# Contract: Settings Persistence

## Stored Path

Primary backend:

```text
users/{userId}/settings/profile
```

## Required Fields

- `userId`
- `languagePreference`
- `baseCurrency`
- `supportedCurrencies`
- `conversionRates`
- `defaultPaymentMethod`
- `notificationSettings`
- `onboardingCompleted`
- `onboardingVersion`
- `guidedTourCompletedVersion`
- `guidedTourSkippedVersion`
- `updatedAt`

## Onboarding Save Behavior

- Load existing settings if present.
- If missing, create defaults once.
- Apply selected language.
- Apply selected base currency and include it in supported currencies.
- Apply selected notification settings.
- Set `onboardingCompleted` to true.
- Set `onboardingVersion` to current version.
- Preserve unrelated settings fields.
- Navigate only after save success.

## Firestore Rule Contract

- Rules must accept the same notification fields serialized by the app.
- Rules must reject invalid currency, invalid language, wrong user id, and malformed notification settings.

## Test Contract

- Repository tests cover missing settings, preserving existing settings, language save, currency save, and notification settings shape.
