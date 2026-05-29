# Data Model: Launch, Onboarding, And Auth Mock

## OnboardingOption

- `id`
- `title`
- `subtitle`
- `iconName`
- `isRecommended`

## MockPreferenceState

- `selectedLanguageId`
- `selectedCurrencyId`
- `notificationToggles`

## MockAuthFormState

- `email`
- `password`
- `displayName`
- `showPassword`
- `visualValidationMessage`

## Validation Rules

- Selections are local and reset on app restart.
- Form fields do not authenticate or persist.
- Notification toggles do not request OS permissions.
- Google-style sign-in button is visual only.
