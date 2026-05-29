# Feature Specification: Launch, Onboarding, And Auth Mock

**Feature Branch**: `002-launch-onboarding-auth`

**Created**: 2026-05-28

**Status**: Draft pending approval

**Input**: Rebuild splash, onboarding, login, and sign-up exports as native UI-only Flutter screens.

## Mandatory Agent Prerequisites

- `AGENTS.md` was read.
- `.specify/memory/constitution.md` was read.
- `.agents/workflows/development.md` was read.
- `.agents/skill-matcher.json` was read.
- Relevant skills were searched in `.agents/skills/` and `.agent/skills/`.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`, `flutter-setup-localization`.

**Scope guard**: These are visual entry screens only. No real authentication, notification permissions, persistence, backend, Firebase, API calls, WebView, or HTML rendering.

## User Scenarios & Testing

### User Story 1 - First App Launch (Priority: P1)

As a first-time user, I want to see the splash and onboarding sequence so I understand the prototype entry flow.

**Why this priority**: It establishes the first-run path and locale/currency visual state before main screens.

**Independent Test**: Navigate from `/splash` through onboarding routes with local state only.

**Acceptance Scenarios**:

1. **Given** the app opens at `/splash`, **When** the splash advances, **Then** the language onboarding screen appears.
2. **Given** the language screen, **When** a language is selected, **Then** selected styling updates locally.

---

### User Story 2 - Visual Preferences (Priority: P1)

As a user, I want to choose language, base currency, and notification preferences visually without actual persistence.

**Why this priority**: These screens validate RTL/LTR readiness and local-only preference controls.

**Independent Test**: Tap language, currency, and notification options and confirm only visual state changes.

**Acceptance Scenarios**:

1. **Given** the currency screen, **When** a currency is selected, **Then** the option card visually changes and the next route is available.
2. **Given** the notifications screen, **When** a toggle is changed, **Then** no OS permission dialog is requested.

---

### User Story 3 - Mock Login And Sign-Up (Priority: P2)

As a reviewer, I want login and sign-up screens that look complete while making it clear they are not real auth.

**Why this priority**: The exports include auth surfaces, but real auth is forbidden.

**Independent Test**: Fill form fields and tap CTAs; the app navigates locally or shows visual feedback without service calls.

**Acceptance Scenarios**:

1. **Given** the login screen, **When** the primary button is tapped, **Then** the app performs only local navigation or mock feedback.
2. **Given** the sign-up screen, **When** a user enters text, **Then** fields behave visually without network requests.

### Edge Cases

- Arabic strings from exported HTML may be mojibake and require manual clean text.
- Keyboard height can cause form overflow on 360x800.
- Forgot password link is missing as an exported screen and must stay inert or route to a placeholder.
- Notification screen must not call OS permission APIs.
- Google-style button must not use real Google auth.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST provide native Flutter routes for splash, language onboarding, currency onboarding, notification onboarding, login, and sign-up.
- **FR-002**: Onboarding selections MUST update local visual state only.
- **FR-003**: Login and sign-up fields MUST be visual-only forms with no real authentication.
- **FR-004**: Notification preference controls MUST NOT request OS notification permissions.
- **FR-005**: All six screens MUST reuse foundation widgets and theme tokens.
- **FR-006**: Screens MUST support English LTR and Arabic RTL readiness.
- **FR-007**: Layouts MUST fit 360x800, 375x812, and 390x844.
- **FR-008**: The feature MUST NOT add backend, Firebase, auth SDKs, APIs, persistence, WebView, or HTML rendering.

### Key Entities

- **OnboardingOption**: Visual label, optional subtitle, icon token, selected state.
- **MockAuthFormState**: Local field text and visual validation state only.
- **MockPreferenceState**: Local language, currency, and notification toggle selections.

## Success Criteria

### Measurable Outcomes

- **SC-001**: All six entry/auth screens render natively at required viewports without overflow.
- **SC-002**: Entry flow route test completes from `/splash` to `/auth/login` and `/auth/sign-up`.
- **SC-003**: Forbidden dependency search reports zero implementation hits for auth, Firebase, notification APIs, network, persistence, WebView, or HTML rendering.
- **SC-004**: RTL widget tests cover at least language onboarding and one auth screen.

## Assumptions

- Foundation route and shared widget work is complete.
- Login submit may navigate to `/home` placeholder or show a mock snackbar.
- Forgot password is deferred unless the user approves a placeholder.
