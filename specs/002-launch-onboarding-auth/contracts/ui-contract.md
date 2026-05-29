# UI Contract: Launch, Onboarding, And Auth Mock

## Routes

- `/splash`: native splash/loading screen.
- `/onboarding/language`: language option cards.
- `/onboarding/currency`: currency option cards.
- `/onboarding/notifications`: local notification preference toggles.
- `/auth/login`: visual login form.
- `/auth/sign-up`: visual sign-up form.

## Component Contracts

### OnboardingOptionCard

- Accepts title, subtitle, icon, selected state, and tap callback.
- Uses theme tokens and directional padding.
- Must fit within 360px width.

### AuthPanel

- Accepts screen variant, fields, primary action, secondary link, and optional visual provider button.
- Does not import or call auth services.
- Must be scrollable when keyboard space is reduced.

## Interaction Contracts

- Primary onboarding buttons navigate locally.
- Login and sign-up CTAs show mock feedback or navigate locally.
- Forgot password remains inert or routes to approved placeholder only.
- Notification toggles change local state only.
