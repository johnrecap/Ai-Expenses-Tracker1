# Research: Startup Onboarding Settings

## Decision 1: Keep onboarding after authentication

**Decision**: Onboarding settings remain tied to the signed-in user and are saved under the user's settings document.

**Rationale**: The app already stores settings under authenticated user data. Moving onboarding before login would require temporary local storage and merge behavior that is outside this fix.

**Alternatives considered**:

- Move onboarding before login: rejected because user settings need a user id.
- Store anonymous onboarding locally first: rejected because it adds sync/merge complexity.

## Decision 2: Startup must wait for settings before routing

**Decision**: The startup flow must load or ensure settings before sending an authenticated user to home.

**Rationale**: Current behavior can go to home before settings are loaded, skipping onboarding.

**Alternatives considered**:

- Let home detect missing settings: rejected because onboarding is a routing decision, not a dashboard responsibility.
- Keep splash timer-only routing: rejected because it does not wait for required state.

## Decision 3: Preserve settings when completing onboarding

**Decision**: Completing onboarding should use existing settings when present and update only onboarding-related fields.

**Rationale**: Calling a default-settings writer every time can reset unrelated settings and create data loss.

**Alternatives considered**:

- Always overwrite defaults: rejected because it can erase existing profile/settings choices.
- Split each onboarding step into separate writes: rejected for now because final save is easier to keep atomic and retryable.

## Decision 4: App locale must be driven from settings

**Decision**: The app should include generated localization delegates and set locale from saved language preference.

**Rationale**: Choosing a language is not meaningful if `MaterialApp` is hardcoded to Arabic.

**Alternatives considered**:

- Keep hardcoded Arabic: rejected because the app targets Arabic and English.
- Use a separate language cubit disconnected from repository settings: rejected because saved settings are the source of truth.

## Decision 5: Notification onboarding saves preferences and local device setup

**Decision**: Notification onboarding must save the user's choices and initialize/request local notification permission before scheduling local reminders.

**Rationale**: The current UI has toggles, but choices are not persisted and the service is not initialized.

**Alternatives considered**:

- Store notification choices only, no device setup: rejected because the Allow button implies device notification behavior.
- Schedule without permission/timezone setup: rejected because it can fail silently.

## Decision 6: Firestore rules and serialization must match the model

**Decision**: Notification model fields, entity serialization, and Firestore validation must support the same shape.

**Rationale**: Mismatched fields cause either silent data loss or rejected writes.

**Alternatives considered**:

- Keep only two notification fields: rejected because onboarding exposes daily/weekly behavior and the model already has broader preferences.
- Loosen Firestore rules broadly: rejected because finance data needs strict validation.
