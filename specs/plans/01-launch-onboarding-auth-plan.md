# Launch, Onboarding, And Auth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the entry, onboarding, login, and sign-up surfaces as native Flutter UI.

**Architecture:** Compose screens from foundation widgets, local state, and mock
navigation. Forms and selections are visual only and never call authentication,
permissions, storage, or backend services.

**Tech Stack:** Flutter, foundation widgets from Plan 00, static mock data,
widget tests.

---

## Depends On

- `specs/plans/00-foundation-plan.md`

## Screens Covered

- `splash_loading`
- `onboarding_language_selection`
- `onboarding_base_currency`
- `onboarding_notifications`
- `login_authentication`
- `sign_up`

## Why

These screens establish first-run flow, visual language choice, visual currency
choice, notification preference mock state, and the strict no-real-auth rule.

## Expected Result

Users can move through splash, onboarding, login, and sign-up screens using local
route transitions. No selection or form data is persisted.

## Source References

- `stitch_ai_expenses_tracker_pro/splash_loading/screen.png`
- `stitch_ai_expenses_tracker_pro/splash_loading/code.html`
- `stitch_ai_expenses_tracker_pro/onboarding_language_selection/*`
- `stitch_ai_expenses_tracker_pro/onboarding_base_currency/*`
- `stitch_ai_expenses_tracker_pro/onboarding_notifications/*`
- `stitch_ai_expenses_tracker_pro/login_authentication/*`
- `stitch_ai_expenses_tracker_pro/sign_up/*`
- `specs/design-system.md`
- `specs/component-map.md`

## Files And Ownership

- Create: `lib/features/onboarding/presentation/splash_screen.dart`
- Create: `lib/features/onboarding/presentation/language_screen.dart`
- Create: `lib/features/onboarding/presentation/base_currency_screen.dart`
- Create: `lib/features/onboarding/presentation/notifications_screen.dart`
- Create: `lib/features/onboarding/presentation/widgets/onboarding_option_card.dart`
- Create: `lib/features/auth/presentation/login_screen.dart`
- Create: `lib/features/auth/presentation/sign_up_screen.dart`
- Create: `lib/features/auth/presentation/widgets/auth_panel.dart`
- Modify: `lib/app/router.dart`
- Test: `test/features/onboarding/entry_flow_test.dart`
- Test: `test/features/auth/auth_ui_test.dart`

## Tasks

- [ ] T101 [Onboarding] Build splash and onboarding option components.
  - Why: The onboarding screens share selectable cards, CTA buttons, and centered content.
  - Expected result: `OnboardingOptionCard` and splash layout render with shared tokens.
  - Inputs: `splash_loading`, `onboarding_language_selection`, `onboarding_base_currency`, `onboarding_notifications`.
  - Implementation notes: Use `GradientButton`, `AppBackground`, `GlassCard`, and directional padding.
  - Possible bugs: option cards overflow at 360px, logo asset fails, or Arabic text comes from corrupted HTML encoding.
  - Fix strategy: make content scrollable, verify local logo asset, and rewrite Arabic strings manually from intended meaning.
  - Verification: widget tests render each onboarding screen at 360x800 LTR and RTL.

- [ ] T102 [Onboarding] Implement language, currency, and notification screens.
  - Why: These screens exercise local selection state and route transitions before main app shell.
  - Expected result: selected option styling changes locally; continue buttons navigate to the next mock route.
  - Inputs: onboarding exports and route list.
  - Implementation notes: Do not use locale persistence, notification permission APIs, or settings storage.
  - Possible bugs: selected state persists globally, notification toggle requests OS permissions, routes skip a step.
  - Fix strategy: keep state inside widgets or a temporary app-level demo state; replace OS behavior with mock toggles.
  - Verification: entry flow test taps through all onboarding routes.

- [ ] T103 [Auth] Build reusable auth panel and text-field visuals.
  - Why: Login and sign-up share glass panel, input rows, buttons, divider, and footer links.
  - Expected result: `AuthPanel` supports login and sign-up variants without duplicate layout.
  - Inputs: `login_authentication`, `sign_up`, `ai_expenses_tracker_logo`.
  - Implementation notes: Use local placeholders for Google/avatar imagery; no remote image URLs.
  - Possible bugs: form fields overflow with keyboard, remote Google image remains, or auth package gets added.
  - Fix strategy: wrap panel in `SingleChildScrollView`, replace images with local asset/icons, remove auth dependencies.
  - Verification: auth UI tests render both screens and forbidden dependency search has no auth/Firebase/API hits.

- [ ] T104 [Routes] Wire entry and auth routes.
  - Why: The entry flow must be navigable before main app plans begin.
  - Expected result: `/splash`, `/onboarding/language`, `/onboarding/currency`, `/onboarding/notifications`, `/auth/login`, `/auth/sign-up` resolve to screens.
  - Inputs: route registry from Plan 00.
  - Implementation notes: Buttons navigate locally; submit actions do not authenticate.
  - Possible bugs: login button implies real login, forgot password points to missing route, sign-up link loops.
  - Fix strategy: show a mock snackbar or navigate to `/home` placeholder; keep forgot password inert unless a placeholder route exists.
  - Verification: route smoke test covers all entry/auth paths.

## Possible Bugs And Fix Strategy

- Mojibake Arabic from HTML: replace with clean Arabic strings in Flutter.
- Auth creep: remove auth SDKs and keep form actions visual-only.
- Keyboard overflow: make auth/onboarding pages scrollable.
- Directionality mismatch: use `TextAlign.start` and directional padding.

## Verification

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Visual checks:

- 360x800 LTR and RTL
- 375x812 LTR and RTL
- 390x844 LTR and RTL

## Acceptance Criteria

- All six covered screens have native Flutter counterparts.
- No real authentication, notification permission, persistence, backend, API, or WebView behavior exists.
- Screen content fits required mobile widths.
- Arabic RTL mirrors layout where appropriate.

## Stop Condition

Do not start main dashboard/expenses implementation until entry/auth route tests
and responsive smoke tests pass.
