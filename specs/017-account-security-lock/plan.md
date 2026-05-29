# Implementation Plan: Account Security Lock

**Branch**: `017-account-security-lock` | **Date**: 2026-05-29 | **Spec**: `specs/017-account-security-lock/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

## Summary

Add account/profile management, safe account deletion, PIN setup/unlock, biometric fallback, secure storage, and settings integration.

## Why

`new app` has auth and a settings toggle, but lacks the production security flows from `Expense-Tracker-main`. These gaps affect privacy, trust, and release readiness.

## Expected Result

- `features/account/` with profile screen, cubit, services, models.
- `features/app_lock/` and/or `security/` with PIN/biometric services and lock screens.
- Settings routes to account and security flows.
- Tests for account deletion, profile update, PIN, and lock UI.

## Source References

- `Expense-Tracker-main/lib/screens/account/`
- `Expense-Tracker-main/lib/screens/app_lock/`
- `Expense-Tracker-main/lib/security/`
- `Expense-Tracker-main/test/account/`
- `Expense-Tracker-main/test/security/`
- `new app/lib/features/settings/presentation/settings_screen.dart`

## Technical Context

**Primary Dependencies**: `firebase_auth`, `flutter_secure_storage`, `local_auth`, `crypto`, `flutter_bloc`, `go_router`.

**Storage**: Firebase Auth for identity, secure storage for PIN hash/settings, repository/server for user-owned data deletion.

**Testing**: Bloc tests, service unit tests, widget tests.

**Constraints**: No secrets or PINs in logs; biometric must fallback to PIN; account deletion must be recoverable on failure.

## Constitution Check

- Security and persistence scope are allowed by constitution.
- Native Flutter widgets and shared design tokens are required.
- RTL/LTR and small viewport checks are required.

## Project Structure

```text
lib/features/account/
lib/features/app_lock/
lib/security/
lib/features/settings/
lib/app/routes.dart
lib/app/router.dart
test/account/
test/security/
```

## Implementation Batches

### Batch 1 - Account Profile

**Expected result**: Profile screen shows identity and lets user update display name.

### Batch 2 - Account Deletion

**Expected result**: Destructive deletion flow handles warning, reauth, backend/user-data deletion, auth deletion, and failure recovery.

### Batch 3 - App Lock

**Expected result**: PIN setup/unlock and biometric fallback protect the app on resume.

### Batch 4 - Settings, Routing, QA

**Expected result**: Settings links to profile/security; tests pass in EN/AR and required viewports.

## Possible Bugs And Fix Strategy

- **Deletion reports success before data deletion**: sequence service so data deletion completes first and surface partial failure.
- **Biometric unavailable crashes flow**: check availability and fallback to PIN.
- **PIN hash mismatch after app restart**: normalize PIN input and verify secure storage key names.
- **Lock appears over auth/login screens**: gate lock only for authenticated protected routes.
- **RTL keypad layout confusing**: use explicit numeric layout and localized text only.

## Verification Plan

```powershell
flutter analyze --no-pub
flutter test --no-pub test/account test/security test/features/settings
```

Manual checks: account profile update, deletion cancel/failure/success, PIN setup, unlock after resume, biometric fallback on a device.

## Stop Condition

Security flows are implemented, tested, localized, and no sensitive data is logged.
