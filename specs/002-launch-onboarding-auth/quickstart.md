# Quickstart: Launch, Onboarding, And Auth Mock

## Implementation Order

1. Confirm foundation routes and shared widgets exist.
2. Build `OnboardingOptionCard`.
3. Build splash and three onboarding screens.
4. Build `AuthPanel`.
5. Build login and sign-up screens.
6. Wire routes.
7. Add LTR/RTL and viewport widget tests.
8. Run forbidden dependency search.

## Commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Viewport Checks

- 360x800 LTR and RTL
- 375x812 LTR and RTL
- 390x844 LTR and RTL

## Stop Condition

Stop when all six screens render natively, route tests pass, forms stay local-only, and forbidden dependency search has no implementation hits.
