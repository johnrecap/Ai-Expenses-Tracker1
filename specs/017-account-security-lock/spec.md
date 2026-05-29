# Feature Specification: Account Security Lock

**Feature Branch**: `017-account-security-lock`
**Created**: 2026-05-29
**Status**: Draft
**Input**: Add the account/profile management and app lock security capabilities missing from `new app`.

## Mandatory Agent Prerequisites

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

**Scope guard**: Account profile, account deletion, reauthentication, PIN lock, biometric unlock, secure storage, and settings integration are in scope. Export screen and Firebase Functions are out of scope.

## User Scenarios & Testing

### User Story 1 - Manage Account Profile (Priority: P1)

As a user, I want to view and update my profile and understand account capabilities.

**Why this priority**: `new app` only shows a profile row in settings; the full account screen and service layer are missing.

**Independent Test**: Sign in, open account profile, update display name, and verify UI reflects the new value.

### User Story 2 - Delete Account Safely (Priority: P1)

As a user, I want to delete my account only after clear warnings and reauthentication.

**Why this priority**: Account deletion is a high-risk privacy operation that must not partially delete or falsely report success.

**Independent Test**: Use disposable accounts for email/password and Google flows, simulate stale session, cancel, fail, retry, and success states.

### User Story 3 - Lock The App (Priority: P2)

As a user, I want to protect the app with PIN and optional biometric unlock.

**Why this priority**: The dependency and settings toggle exist, but there is no real app lock flow.

**Independent Test**: Create PIN, background/resume app, verify unlock screen blocks app until PIN or biometric succeeds.

## Requirements

### Functional Requirements

- **FR-001**: Users MUST be able to open account profile from settings.
- **FR-002**: Users MUST be able to update display name through the auth/profile layer.
- **FR-003**: Account deletion MUST require destructive warning and reauthentication when required by Firebase.
- **FR-004**: Account deletion MUST delete user-owned app data before reporting Auth deletion success.
- **FR-005**: PIN MUST be stored only as a secure hash in secure storage.
- **FR-006**: Biometric unlock MUST be optional and gracefully fallback to PIN.
- **FR-007**: Security copy MUST be localized and RTL-ready.

### Key Entities

- **Account Identity**: User id, email, display name, provider metadata.
- **Reauthentication Request**: Credential flow required before sensitive actions.
- **App Lock State**: PIN enabled, biometric enabled, lock status, failure count.

## Success Criteria

- **SC-001**: Account deletion failure never leaves the UI claiming success.
- **SC-002**: PIN unlock blocks protected screens after app resume when lock is enabled.
- **SC-003**: No PIN, auth token, or biometric detail is logged.
- **SC-004**: Account/security screens pass LTR and RTL widget checks.

## Assumptions

- Firebase Auth remains identity provider.
- Server account deletion endpoints are handled by `specs/014-production-backend-ops`; Flutter coordinates UX and service calls.
- Biometric availability varies by device and must never block PIN fallback.
