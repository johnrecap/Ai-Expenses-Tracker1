# Feature Specification: Startup Onboarding Settings

**Feature Branch**: `[026-startup-onboarding-settings]`

**Created**: 2026-05-31

**Status**: Draft

**Input**: Fix and validate startup routing, language onboarding, base currency onboarding, and notification onboarding so they use real saved settings and honest notification behavior.

## Mandatory Agent Prerequisites *(mandatory)*

Before drafting this specification, the agent completed the required first-read gate:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Searched installed skills for relevant workflows.
- Loaded matching `SKILL.md` files.

**Skills used**:

- `speckit-specify`: define the required product behavior.
- `speckit-plan`: create planning artifacts and implementation approach.
- `speckit-tasks`: create executable task cards.
- `speckit-implement`: provide the implementation workflow for the worker agent.
- `flutter-add-widget-test`: guide focused widget tests for onboarding screens.

**Scope guard**: This is production Flutter behavior. It may update app routing, settings persistence, localization wiring, notification configuration, Firestore settings serialization/rules, and focused tests. It must not introduce fake data, hardcoded secrets, WebView, or a new design language.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Correct Startup Destination (Priority: P1)

As a signed-in user, I want the app to open the right destination based on whether onboarding is complete, so I do not skip required setup or repeat setup unnecessarily.

**Why this priority**: Startup routing is the first product decision after authentication. A wrong route can make all later settings unreliable.

**Independent Test**: Simulate signed-in users with completed and incomplete onboarding and verify the app routes to home or onboarding language correctly.

**Acceptance Scenarios**:

1. **Given** a signed-in user has no settings or incomplete onboarding, **When** the splash flow finishes, **Then** the app opens language onboarding.
2. **Given** a signed-in user has completed onboarding, **When** the splash flow finishes, **Then** the app opens the home dashboard.
3. **Given** an unauthenticated user opens the app, **When** auth state resolves, **Then** the app opens login.

---

### User Story 2 - Language Selection Applies And Persists (Priority: P1)

As a user choosing Arabic or English, I want the choice to be saved and applied across the app, so the interface uses the language I selected.

**Why this priority**: The app targets Egypt/MENA and must support Arabic/English reliably.

**Independent Test**: Choose Arabic or English during onboarding, complete onboarding, restart the app state, and verify saved settings drive the app locale.

**Acceptance Scenarios**:

1. **Given** the user selects Arabic, **When** onboarding completes, **Then** the stored language preference is Arabic and the app uses Arabic direction/locale.
2. **Given** the user selects English, **When** onboarding completes, **Then** the stored language preference is English and the app uses English direction/locale.
3. **Given** language saving fails, **When** the user presses continue, **Then** the app shows an error and does not pretend setup completed.

---

### User Story 3 - Base Currency Selection Persists Safely (Priority: P1)

As a user selecting a base currency, I want the selected currency to be saved without resetting existing settings unexpectedly.

**Why this priority**: Base currency affects expenses, budgets, AI parsing defaults, and reports.

**Independent Test**: Select EGP, USD, EUR, or AED and verify saved settings contain the normalized base currency and supported currency list.

**Acceptance Scenarios**:

1. **Given** the user selects EGP, **When** onboarding completes, **Then** base currency is saved as `EGP`.
2. **Given** existing settings already exist, **When** onboarding completes, **Then** only onboarding fields are updated and unrelated settings are preserved.
3. **Given** settings save fails, **When** the user presses continue, **Then** the app stays on onboarding with a clear retry path.

---

### User Story 4 - Notification Onboarding Is Honest (Priority: P2)

As a user choosing notification options, I want the app to save what I selected and only request/schedule notifications when the device supports it.

**Why this priority**: Notification prompts are trust-sensitive. Fake toggles or unsupported scheduling make the app feel broken.

**Independent Test**: Toggle notification options, allow/skip, and verify saved settings, device permission handling, and scheduled reminder behavior.

**Acceptance Scenarios**:

1. **Given** the user enables daily reminder and chooses a time, **When** they allow notifications, **Then** the selection is saved and the app requests permission before scheduling.
2. **Given** the user disables notifications or skips, **When** onboarding completes, **Then** notification settings are saved as disabled and no reminder is scheduled.
3. **Given** notification permission is denied, **When** onboarding completes, **Then** saved settings reflect disabled/unavailable notifications and the app still completes setup honestly.

### Edge Cases

- Settings document does not exist for a signed-in user.
- Firestore rejects settings due to validation rules.
- Existing settings include fields not touched by onboarding.
- User presses onboarding final action repeatedly.
- User navigates back from currency or notification screens.
- Arabic is selected on a narrow phone screen.
- Android notification permission is unavailable or denied.
- Timezone setup for scheduled notifications is not ready.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Startup MUST load or ensure user settings before deciding whether to open home or onboarding.
- **FR-002**: Startup MUST not route a signed-in user to home when onboarding is incomplete.
- **FR-003**: Startup MUST route unauthenticated users to login.
- **FR-004**: Onboarding routes MUST only be usable when the required onboarding state/provider exists.
- **FR-005**: Language selection MUST persist as a user setting.
- **FR-006**: Saved language preference MUST drive app locale and text direction.
- **FR-007**: App localization delegates MUST include the generated application localization delegate.
- **FR-008**: Base currency selection MUST persist as a normalized currency code.
- **FR-009**: Completing onboarding MUST preserve unrelated existing settings.
- **FR-010**: Completing onboarding MUST wait for save success before navigating to home.
- **FR-011**: Completing onboarding MUST expose save failure instead of navigating as if setup succeeded.
- **FR-012**: Notification onboarding MUST save the actual user choices, including disabled/skipped states.
- **FR-013**: Notification settings serialization, backend validation, and models MUST agree on supported notification fields.
- **FR-014**: Device notification service MUST be initialized before showing or scheduling local notifications.
- **FR-015**: Android notification permission support MUST be declared and requested where needed.
- **FR-016**: Scheduled notification behavior MUST initialize timezone data or avoid scheduling until it is safe.
- **FR-017**: Tests MUST cover startup routing, settings persistence, language application, currency persistence, and notification save behavior.

### Key Entities

- **User Settings**: Saved profile settings containing language, base currency, notification settings, and onboarding status.
- **Onboarding Draft**: Temporary state containing selected language, selected currency, notification choices, and loading/error state before final save.
- **Notification Settings**: User-level preferences for budget alerts, recurring reminders, weekly digest, subscription renewals, AI quota warnings, and optional daily reminder metadata.
- **Startup Decision**: The result of auth state plus settings state: login, onboarding, home, or error/retry.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A signed-in user with incomplete onboarding reaches the first onboarding screen 100% of the time in focused startup tests.
- **SC-002**: A signed-in user with completed onboarding reaches home 100% of the time in focused startup tests.
- **SC-003**: Arabic and English selections persist and drive app locale in focused tests.
- **SC-004**: Currency selection persists as a three-letter uppercase code in focused tests.
- **SC-005**: Notification allow/skip flows save distinct settings in focused tests.
- **SC-006**: Firestore settings rules and app serialization accept the same notification settings shape.
- **SC-007**: Focused onboarding/settings tests pass, and any broader analyzer/test failures are documented as pre-existing or fixed.

## Assumptions

- Firebase/Firestore remains the primary backend for this feature.
- VPS/local-first work is not the implementation target for this task unless existing runtime mode requires a small compatibility fix.
- Onboarding happens after authentication because settings are stored under the signed-in user.
- The app should preserve the existing visual design of onboarding screens.
- Notification delivery can be local device notifications for now; no push-notification server is required in this feature.
