# Tasks: Launch, Onboarding, And Auth Mock

**Input**: Design documents from `/specs/002-launch-onboarding-auth/`

**Prerequisites**: `specs/001-foundation/` approved and implemented

## Mandatory First Read And Skill Gate

Skills used for task generation: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`, `flutter-setup-localization`.

## Non-Negotiable Rules

- UI only. No real auth, Firebase, backend, database, API calls, persistence, notification permission APIs, WebView, or HTML rendering.
- Native Flutter widgets only.
- Reuse foundation components and tokens.
- Responsive for 360x800, 375x812, 390x844.
- Arabic RTL and English LTR ready.

## Phase 1: Onboarding Components

- [ ] T101 [P] [US1] Create `OnboardingOptionCard` in `lib/features/onboarding/presentation/widgets/onboarding_option_card.dart`
  - Why: Language, currency, and notification options share the same selectable card pattern.
  - Expected result: A reusable selected/unselected option card renders with directional padding.
  - Inputs: `specs/component-map.md`, onboarding Stitch exports.
  - Implementation notes: Use `GlassCard`, theme tokens, and `TextAlign.start`; no hardcoded screen copy.
  - Possible bugs: Cards overflow at 360px; selection state styling differs between screens.
  - Fix strategy: Constrain card width, centralize selected state styling, and add a narrow widget test.
  - Verification: Widget test renders selected and unselected cards in LTR and RTL.

- [ ] T102 [US1] Build splash screen in `lib/features/onboarding/presentation/splash_screen.dart`
  - Why: Splash is the first detected export and verifies app launch visuals.
  - Expected result: `/splash` renders native background, logo/mark, and loading affordance.
  - Inputs: `stitch_ai_expenses_tracker_pro/splash_loading/screen.png`, `code.html`, local logo asset.
  - Implementation notes: Use native widgets; do not embed screenshot as the screen UI.
  - Possible bugs: Logo asset missing; loading animation causes flaky tests; layout too tall at 360x800.
  - Fix strategy: Add fallback icon, tolerate animation in tests, and keep body centered with safe constraints.
  - Verification: Route and widget smoke test for `/splash`.

- [ ] T103 [US2] Build language screen in `lib/features/onboarding/presentation/language_screen.dart`
  - Why: This screen validates English/Arabic readiness early.
  - Expected result: `/onboarding/language` displays language cards and a local continue action.
  - Inputs: `onboarding_language_selection/screen.png`, `code.html`.
  - Implementation notes: Use clean Arabic labels; selection is local widget state only.
  - Possible bugs: Mojibake Arabic copied from HTML; RTL card alignment wrong.
  - Fix strategy: Rewrite Arabic copy manually and add RTL widget test.
  - Verification: LTR and RTL viewport tests at 360, 375, and 390 widths.

- [ ] T104 [US2] Build currency screen in `lib/features/onboarding/presentation/base_currency_screen.dart`
  - Why: Currency choice is part of onboarding and feeds later mock display assumptions.
  - Expected result: `/onboarding/currency` shows base currency options with local selected state.
  - Inputs: `onboarding_base_currency/screen.png`, `code.html`.
  - Implementation notes: Do not persist currency; use local mock preference state.
  - Possible bugs: Currency codes wrap badly; selected state persists globally.
  - Fix strategy: Use constrained text and keep state inside the screen or temporary demo state only.
  - Verification: Widget test selects a currency and confirms visual change.

- [ ] T105 [US2] Build notification screen in `lib/features/onboarding/presentation/notifications_screen.dart`
  - Why: The export includes notification choices but real permissions are out of scope.
  - Expected result: `/onboarding/notifications` shows local toggles/cards and continue action.
  - Inputs: `onboarding_notifications/screen.png`, `code.html`.
  - Implementation notes: No OS permission APIs; toggles mutate local widget state only.
  - Possible bugs: Permission package added; toggles overflow; continue button hidden near bottom.
  - Fix strategy: Remove permission dependency, make content scrollable, use safe footer padding.
  - Verification: Test toggles options without platform permission calls.

## Phase 2: Auth Mock Screens

- [ ] T106 [P] [US3] Create `AuthPanel` in `lib/features/auth/presentation/widgets/auth_panel.dart`
  - Why: Login and sign-up share panel, fields, primary button, divider, and footer links.
  - Expected result: One reusable auth panel supports both variants.
  - Inputs: `login_authentication`, `sign_up`, `specs/component-map.md`.
  - Implementation notes: Use local text fields and visual provider button; no auth service imports.
  - Possible bugs: Screen-local duplicate forms; keyboard overflow; provider button implies real Google auth.
  - Fix strategy: Consolidate into `AuthPanel`, wrap with scroll view, and label actions as mock/local.
  - Verification: Auth panel widget test renders login and sign-up variants.

- [ ] T107 [US3] Build login screen in `lib/features/auth/presentation/login_screen.dart`
  - Why: Login export must have a native counterpart without real auth.
  - Expected result: `/auth/login` renders visual email/password form and local CTA behavior.
  - Inputs: `login_authentication/screen.png`, `code.html`.
  - Implementation notes: Submit navigates locally or shows mock snackbar; forgot password stays inert or placeholder-only.
  - Possible bugs: Auth SDK added; form validation blocks demo; forgot link routes nowhere.
  - Fix strategy: Remove auth imports, keep validation visual, and use approved placeholder route.
  - Verification: Login test enters text and taps CTA with no external call.

- [ ] T108 [US3] Build sign-up screen in `lib/features/auth/presentation/sign_up_screen.dart`
  - Why: Sign-up export must be present while preserving no-real-auth scope.
  - Expected result: `/auth/sign-up` renders visual sign-up form and local CTA behavior.
  - Inputs: `sign_up/screen.png`, `code.html`.
  - Implementation notes: No account creation, email verification, or backend state.
  - Possible bugs: User data persisted; provider auth wired accidentally; keyboard clips fields.
  - Fix strategy: Keep state in controllers only, remove provider integrations, make page scrollable.
  - Verification: Sign-up widget test at 360x800 with keyboard-safe layout.

## Phase 3: Routes And Verification

- [ ] T109 [Routes] Wire entry/auth routes in `lib/app/router.dart`
  - Why: The user must navigate through the entry flow using central routes.
  - Expected result: All six routes resolve to native screens.
  - Inputs: `contracts/ui-contract.md`, foundation routes.
  - Implementation notes: Route actions stay local; no auth guards.
  - Possible bugs: Route loops, missing sign-up route, auth guard added.
  - Fix strategy: Add route smoke tests and remove guard logic.
  - Verification: Entry route test covers `/splash`, onboarding routes, login, and sign-up.

- [ ] T110 [Polish] Run compile, viewport, RTL, and forbidden dependency checks
  - Why: Entry/auth must stay UI-only before main app screens start.
  - Expected result: Commands pass or environment blockers are documented; no forbidden implementation hits.
  - Inputs: Completed entry/auth feature files.
  - Implementation notes: Inspect auth-related search hits carefully.
  - Possible bugs: False positives in docs; hidden permission/auth package; narrow overflow.
  - Fix strategy: Remove implementation violations and fix layout at shared component level.
  - Verification: `flutter pub get`, `flutter analyze`, `flutter test`, debug build, viewport checks, forbidden search.

## Dependencies And Execution Order

T101 blocks onboarding screens. T106 blocks auth screens. T109 depends on T102-T108. T110 is final.

## Acceptance Criteria

- Six screens render natively.
- Onboarding selections are local-only.
- Login/sign-up do not authenticate.
- Notification UI does not request permissions.
- Required viewport and RTL/LTR checks pass.
