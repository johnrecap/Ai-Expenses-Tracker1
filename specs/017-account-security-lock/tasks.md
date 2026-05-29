# Tasks: Account Security Lock

**Input**: `specs/017-account-security-lock/spec.md`, `specs/017-account-security-lock/plan.md`

## Phase 1: Account Profile

- [ ] T017-001 [US1] Create account feature structure in `lib/features/account/`
  - Why: Settings currently has no real account management destination.
  - Expected result: Account models, services, cubit, and profile screen folders exist.
  - Inputs: `Expense-Tracker-main/lib/screens/account/`.
  - Implementation notes: Use existing `AppBackground`, `GlassCard`, `AppTopBar`, and theme tokens.
  - Possible bugs: duplicate profile UI inside settings and account screen.
  - Fix strategy: keep settings as entry point and account screen as detailed owner.
  - Verification: route compiles and screen smoke test renders.

- [ ] T017-002 [US1] Implement account profile cubit in `lib/features/account/cubit/`
  - Why: Profile loading/update needs testable state independent from widget state.
  - Expected result: Cubit loads identity, capabilities, update display name, and error states.
  - Inputs: `AuthBloc`, `AuthRepository`, reference account cubit.
  - Implementation notes: Use existing auth repository methods where possible.
  - Possible bugs: display name update does not refresh settings header.
  - Fix strategy: emit updated auth/profile state and listen in settings/profile widgets.
  - Verification: `test/account/account_profile_cubit_test.dart`.

- [ ] T017-003 [US1] Add account route in `lib/app/routes.dart` and `lib/app/router.dart`
  - Why: Users need a navigable profile screen from settings.
  - Expected result: `/account/profile` route opens profile screen.
  - Inputs: current router and settings screen.
  - Implementation notes: Protected route only; unauthenticated users redirect to login.
  - Possible bugs: route not found or redirects loop.
  - Fix strategy: include route in authenticated section and router tests.
  - Verification: `test/app/routes_test.dart`.

## Phase 2: Account Deletion

- [ ] T017-004 [US2] Implement account deletion service in `lib/features/account/services/account_deletion_service.dart`
  - Why: Deletion must coordinate user data cleanup and Auth deletion safely.
  - Expected result: Service supports warning, reauth required, retryable failure, and success states.
  - Inputs: Reference account deletion service, backend account API from `server/`.
  - Implementation notes: Data deletion must complete before reporting Auth deletion success.
  - Possible bugs: Auth user deleted while app data remains.
  - Fix strategy: call backend data deletion first, then Auth deletion; on Auth failure show recovery state.
  - Verification: `test/account/account_deletion_service_test.dart`.

- [ ] T017-005 [US2] Add reauthentication UI in `lib/features/account/presentation/`
  - Why: Firebase sensitive actions require recent login.
  - Expected result: Email/password and Google reauth paths support cancel, retry, and success.
  - Inputs: `AuthRepository.reauthenticate`, reference `reauth_request.dart`.
  - Implementation notes: Do not log credentials; keep forms localized and RTL-ready.
  - Possible bugs: cancel treated as failure and deletes account anyway.
  - Fix strategy: model cancel as explicit safe state and abort deletion.
  - Verification: widget tests for cancel/failure/success.

## Phase 3: App Lock

- [ ] T017-006 [US3] Create security services in `lib/security/`
  - Why: PIN and biometric behavior must be reusable and testable.
  - Expected result: `pin_service.dart`, `biometric_service.dart`, and `app_lock_service.dart` exist.
  - Inputs: `Expense-Tracker-main/lib/security/`.
  - Implementation notes: Store PIN hash in `flutter_secure_storage`; use `crypto` hashing with salt.
  - Possible bugs: plaintext PIN stored or printed.
  - Fix strategy: source search for PIN logging/storage and unit test hash behavior.
  - Verification: `test/security/pin_service_test.dart`.

- [ ] T017-007 [US3] Implement app lock cubit and screens in `lib/features/app_lock/`
  - Why: Settings toggle alone does not protect the app.
  - Expected result: Create PIN screen, unlock screen, failure states, biometric fallback.
  - Inputs: Reference app lock cubit and views.
  - Implementation notes: Use numeric keypad sized for 360x800; support RTL text but keep numbers stable.
  - Possible bugs: unlock screen appears before PIN setup is complete.
  - Fix strategy: model setup and locked states separately.
  - Verification: `test/security/app_lock_cubit_test.dart`, widget tests for screens.

- [ ] T017-008 [US3] Wire app lifecycle lock behavior in `lib/app/app.dart`
  - Why: App should lock after background/resume when enabled.
  - Expected result: Protected routes show unlock screen after resume based on settings.
  - Inputs: App root, router, app lock cubit.
  - Implementation notes: Do not show lock screen over login/signup.
  - Possible bugs: lock route creates navigation loop.
  - Fix strategy: add router guard conditions and tests.
  - Verification: manual background/resume check and route tests.

## Phase 4: Settings And QA

- [ ] T017-009 [US1] Update settings screen links in `lib/features/settings/presentation/settings_screen.dart`
  - Why: Users need discoverable profile and security controls.
  - Expected result: Profile row opens account profile; security section opens app lock setup/status.
  - Inputs: Settings screen, new routes.
  - Implementation notes: Replace local biometric toggle with persisted security state.
  - Possible bugs: settings still uses `setState` only.
  - Fix strategy: read/write through SettingsCubit/AppLockCubit.
  - Verification: settings widget test.

- [ ] T017-010 [Polish] Run security and privacy verification
  - Why: Security features cannot be marked complete without test evidence.
  - Expected result: Tests pass; source search finds no sensitive logging.
  - Inputs: completed account/security implementation.
  - Implementation notes: Include Arabic RTL visual checks for warnings and PIN screens.
  - Possible bugs: analyzer catches unused platform imports on unsupported platforms.
  - Fix strategy: use platform-aware service boundaries and stubs where needed.
  - Verification: `flutter analyze --no-pub`; `flutter test --no-pub test/account test/security`; `rg -n "pin|password|token" lib test`.
