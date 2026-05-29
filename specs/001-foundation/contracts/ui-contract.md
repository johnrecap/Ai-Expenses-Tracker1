# UI Contract: Foundation

## Route Contract

All planned routes from `specs/ui-only-flutter-prototype.md` must exist as constants in `lib/app/routes.dart`. During foundation they may resolve to native placeholder screens.

Required route groups:

- Splash and onboarding
- Auth mock screens
- Home, expenses, reports, budgets, goals, wallets, subscriptions, AI, settings
- Modal paths for filters and AI assistant
- `/not-found`

## Shared Widget Contract

Shared widgets must:

- Use theme tokens, not raw visual constants.
- Accept content/data through constructors.
- Use directional spacing and alignment.
- Render at 360 logical pixels without overflow.
- Avoid screen-specific copy unless explicitly passed in.

## Mock Data Contract

Mock data must:

- Be static and deterministic.
- Live under `lib/core/mock/`.
- Avoid repositories, services, async fetchers, persistence, and APIs.
- Provide enough records to render repeated lists and cards.

## Forbidden Contract

Foundation must not add imports or packages for:

- Firebase
- HTTP/Dio/API clients
- WebView or HTML rendering
- Databases or shared preferences
- Real authentication
- OCR, camera, microphone, AI service calls, billing, or payment integrations
