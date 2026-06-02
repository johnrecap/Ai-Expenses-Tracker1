# Contract: Startup Routing

## Inputs

- Authentication state.
- Current user's settings document.
- Current onboarding version.

## Decisions

- Unauthenticated or auth failure: route to `AppRoutes.login`.
- Authenticated and settings missing: create/ensure default settings, then route to `AppRoutes.onboardingLanguage`.
- Authenticated and onboarding incomplete: route to `AppRoutes.onboardingLanguage`.
- Authenticated and onboarding complete for current version: route to `AppRoutes.home`.
- Settings load/save failure: show error/retry and do not route to home.

## Constraints

- Onboarding provider/state must exist for onboarding routes.
- Startup must not decide based only on auth state when authenticated.
- Startup must not swallow settings errors and route to home.

## Test Contract

- Focused startup tests cover unauthenticated, authenticated incomplete, authenticated complete, and settings failure states.
