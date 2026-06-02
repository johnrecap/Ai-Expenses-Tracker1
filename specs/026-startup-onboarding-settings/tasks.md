# Tasks: Startup Onboarding Settings

**Input**: Design documents from `specs/026-startup-onboarding-settings/`

**Prerequisites**: [spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md), [contracts/](contracts/)

**Project Type**: Production Flutter app behavior/backend settings fix

## Mandatory First Read And Skill Gate

Before executing tasks, the agent MUST read:

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.agents/workflows/development.md`
- `.agents/MANDATORY_RULES.md`
- `.agents/skill-matcher.json`
- Relevant `SKILL.md` files

**Required skills**: `speckit-implement`, `flutter-add-widget-test`, `dart-run-static-analysis`; use `flutter-setup-localization` for locale wiring details if needed.

**Analyzer rule**: Do not run a full-project `flutter analyze`. Do not analyze all of `lib` or all of `packages/expense_repository/lib`. Run analyzer only on files changed by this feature and the focused tests touched by this feature.

## Phase 1: Setup And Baseline

- [X] T001 [Setup] Record current failures and flow notes in `specs/026-startup-onboarding-settings/baseline.md`
  - Why: The repo has active agents and existing changes; a baseline prevents mixing old failures with this feature.
  - Expected result: A short file documenting current startup/onboarding issues, commands attempted, and any known pre-existing analyzer/test failures.
  - Inputs: `quickstart.md`, current `git status`, current focused test output if practical.
  - Implementation notes: Do not include secrets or raw `.env` values. This is a note file only.
  - Possible bugs: Baseline becomes too broad or includes unrelated AI/dashboard failures.
  - Fix strategy: Keep scope to startup, onboarding, settings, notifications, and focused tests.
  - Verification: `baseline.md` exists and lists relevant known issues.
  - Stop condition: Current state is documented before code edits.

- [X] T002 [Setup] Audit current settings/onboarding data flow in `specs/026-startup-onboarding-settings/flow-audit.md`
  - Why: The worker needs exact paths from screen to repository to Firestore before changing behavior.
  - Expected result: Audit lists startup routing, language save, currency save, notification save, and settings repository path.
  - Inputs: `lib/app/app.dart`, `lib/app/router.dart`, onboarding screens, `OnboardingCubit`, `FirebaseSettingsRepository`, `firestore.rules`.
  - Implementation notes: Mark each path as working, partial, or broken.
  - Possible bugs: Missing local repository mode or Firestore rule mismatch.
  - Fix strategy: Include Firebase primary and local repository compatibility notes separately.
  - Verification: Audit file includes all four requested areas.
  - Stop condition: No requested area remains unclassified.

## Phase 2: Startup Routing Foundation

- [X] T003 [US1] Add startup/settings decision tests in `test/features/onboarding/startup_routing_test.dart`
  - Why: Startup routing currently risks sending incomplete users to home.
  - Expected result: Tests cover unauthenticated -> login, authenticated incomplete -> onboarding, authenticated complete -> home, settings failure -> retry/error.
  - Inputs: `contracts/startup-routing-contract.md`, `SplashScreen`, `AppRouter`, existing test harness.
  - Implementation notes: Prefer deterministic fake repositories/blocs over real Firebase.
  - Possible bugs: Existing splash timer makes tests slow/flaky.
  - Fix strategy: Extract or isolate startup decision logic if needed so tests do not depend on real timers.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test test/features/onboarding/startup_routing_test.dart`.
  - Stop condition: Tests initially fail for the known bug or pass after implementation.

- [X] T004 [US1] Fix authenticated startup decision in `lib/features/onboarding/presentation/splash_screen.dart` and `lib/app/app.dart`
  - Why: Splash must wait for settings before routing authenticated users.
  - Expected result: Authenticated users with incomplete/missing settings go to onboarding; completed users go home.
  - Inputs: `startup-routing-contract.md`, `SettingsCubit`, `SettingsRepository`, current `App` provider setup.
  - Implementation notes: Keep UI style unchanged. Avoid swallowing settings load errors and routing home. Ensure `SettingsCubit.loadSettings()` or equivalent is called at the right time.
  - Possible bugs: Route flicker, infinite loading, accessing `SettingsCubit` before provider exists.
  - Fix strategy: Provide settings before splash needs it or move startup decision into a provider-backed state.
  - Verification: Startup routing focused tests.
  - Stop condition: Authenticated startup no longer routes to home before settings are known.

- [X] T005 [US1] Fix onboarding route provider availability in `lib/app/router.dart` and `lib/app/app.dart`
  - Why: Onboarding screens currently can be public routes while requiring authenticated onboarding providers.
  - Expected result: Onboarding routes are only accessible in a state where required cubits/repositories exist, or they redirect safely.
  - Inputs: `router.dart`, `app.dart`, `onboarding_cubit.dart`, `startup-routing-contract.md`.
  - Implementation notes: Preserve unauthenticated login/sign-up behavior. Do not make onboarding crash for missing providers.
  - Possible bugs: Unauthenticated users get stuck on splash or authenticated users get redirected away from onboarding.
  - Fix strategy: Add route tests for direct onboarding path access with auth states.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test test/app/routes_test.dart`.
  - Stop condition: Onboarding provider access is safe.

## Phase 3: Settings Persistence

- [X] T006 [P] [US2] Add settings repository tests in `test/features/settings/settings_repository_test.dart`
  - Why: Existing settings must be preserved while onboarding writes only selected fields.
  - Expected result: Tests cover missing settings default creation, existing settings preservation, language update, currency update, and notification settings shape.
  - Inputs: `settings-persistence-contract.md`, `UserSettings`, `NotificationSettings`, local/fake repository patterns.
  - Implementation notes: Use test doubles or local repository store; do not call real Firestore.
  - Possible bugs: Tests depend on Firestore or become too broad.
  - Fix strategy: Use repository interface and fake/local implementation for focused behavior.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test test/features/settings/settings_repository_test.dart`.
  - Stop condition: Persistence expectations are locked.

- [X] T007 [US3] Make `ensureDefaultSettings` preserve existing settings in `packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart`
  - Why: Current default creation can overwrite existing settings.
  - Expected result: Existing settings are returned unchanged; defaults are written only when the document is missing.
  - Inputs: `settings-persistence-contract.md`, `firebase_settings_repo.dart`, `UserSettings`.
  - Implementation notes: Avoid recursive `getSettings()`/`ensureDefaultSettings()` loops. Keep Firestore path unchanged.
  - Possible bugs: Infinite recursion when settings are missing or duplicate writes.
  - Fix strategy: Read document directly inside `ensureDefaultSettings` before writing defaults.
  - Verification: Repository tests or focused unit tests.
  - Stop condition: Defaults no longer overwrite existing settings.

- [X] T008 [US2] Extend `OnboardingState` and save behavior in `lib/features/onboarding/onboarding_cubit/onboarding_cubit.dart`
  - Why: The final onboarding save needs actual language, currency, notification choices, loading, completion, and error behavior.
  - Expected result: `completeOnboarding` persists selected language/currency/notifications, preserves unrelated settings, and exposes errors.
  - Inputs: `data-model.md`, `settings-persistence-contract.md`, `notification-contract.md`.
  - Implementation notes: Use existing settings if present. Normalize currency. Do not navigate from the cubit; expose state for UI.
  - Possible bugs: Save double-submits, errors are swallowed, notification choices ignored.
  - Fix strategy: Disable final buttons while loading and map caught errors to an error message.
  - Verification: Cubit tests for success/failure and saved fields.
  - Stop condition: Onboarding save is truthful and testable.

- [X] T009 [US4] Align notification model/entity/rules in `packages/expense_repository/lib/src/models/notification_settings.dart`, `packages/expense_repository/lib/src/entities/user_settings_entity.dart`, and `firestore.rules`
  - Why: App model, Firestore serialization, and Firestore validation currently disagree about notification fields.
  - Expected result: The same supported notification fields are serialized, parsed, and accepted by rules.
  - Inputs: `notification-contract.md`, `NotificationSettings`, `UserSettingsEntity`, `firestore.rules`.
  - Implementation notes: Keep Firestore rules strict; do not allow arbitrary maps. Add optional daily reminder time with bounded format if implemented.
  - Possible bugs: Existing settings documents missing new fields fail parsing or writes fail rules.
  - Fix strategy: Provide defaults when fields are missing and update rules to allow the chosen shape.
  - Verification: Focused settings serialization tests; Firestore rules tests if harness exists.
  - Stop condition: Notification settings no longer lose fields or get rejected.

## Phase 4: UI Flow And Localization

- [X] T010 [US2] Wire saved language into app locale in `lib/app/app.dart` and `lib/l10n/app_language_cubit.dart`
  - Why: Language selection is useless while `MaterialApp` is hardcoded to Arabic.
  - Expected result: App uses saved language preference; generated app localization delegate is included.
  - Inputs: `AppLocalizations`, `LanguagePreference`, `SettingsCubit`, `AppLanguageCubit`, `flutter-setup-localization` guidance.
  - Implementation notes: Remove fixed `Locale('ar')`. Support Arabic, English, and system where possible. Keep unauthenticated app fallback reasonable.
  - Possible bugs: Generated import path mismatch, locale not updating after settings save, widgets lacking localization delegate.
  - Fix strategy: Use generated `AppLocalizations.localizationsDelegates` if available and add focused locale tests.
  - Verification: `& 'C:\flutter\bin\flutter.bat' gen-l10n` and locale focused tests.
  - Stop condition: Saved language drives app locale.

- [X] T011 [US2] Add/update language onboarding tests in `test/features/onboarding/language_screen_test.dart`
  - Why: The language screen should update onboarding state and support both directions.
  - Expected result: Tests cover selecting English/Arabic and continuing without provider crashes.
  - Inputs: `language_screen.dart`, test harness, `OnboardingCubit`.
  - Implementation notes: Keep tests focused on behavior, not pixel styling.
  - Possible bugs: Test harness missing localization or bloc providers.
  - Fix strategy: Wrap with localized MaterialApp and fake settings repository.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test test/features/onboarding/language_screen_test.dart`.
  - Stop condition: Language screen behavior is covered.

- [X] T012 [US3] Add/update currency onboarding tests in `test/features/onboarding/base_currency_screen_test.dart`
  - Why: Base currency affects financial calculations and AI defaults.
  - Expected result: Tests cover selecting a non-default currency and continuing to notifications.
  - Inputs: `base_currency_screen.dart`, `OnboardingCubit`, test harness.
  - Implementation notes: Include at least EGP and USD/AED path.
  - Possible bugs: Back button or navigation makes tests brittle.
  - Fix strategy: Use router test harness with explicit routes.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test test/features/onboarding/base_currency_screen_test.dart`.
  - Stop condition: Currency selection updates state and navigation remains valid.

- [X] T013 [US4] Update notification onboarding UI behavior in `lib/features/onboarding/presentation/notifications_screen.dart`
  - Why: The UI currently ignores toggles/time and navigates before save completes.
  - Expected result: Final buttons await `completeOnboarding`, pass actual choices, disable during loading, show errors, then navigate home on success.
  - Inputs: `notification-contract.md`, `OnboardingCubit`, current notification screen.
  - Implementation notes: Preserve visual style. Do not schedule fake notifications from UI directly unless routed through notification service abstraction.
  - Possible bugs: Double submit, stale time formatting, navigation after widget disposed.
  - Fix strategy: Use bloc listener/state and guard `mounted`.
  - Verification: Notification screen tests.
  - Stop condition: Notification screen save/navigation is honest.

## Phase 5: Notification Device Setup

- [X] T014 [US4] Initialize notification service safely in `lib/main.dart` and `lib/services/notifications/notification_service.dart`
  - Why: Notification service methods currently do nothing unless initialized.
  - Expected result: Service initializes at startup or before onboarding scheduling, with safe error handling.
  - Inputs: `notification-contract.md`, `notification_service.dart`, `main.dart`.
  - Implementation notes: Do not crash app if notification plugin init fails. Do not print secrets.
  - Possible bugs: Initialization fails on unsupported platforms or tests.
  - Fix strategy: Catch and report safe errors; allow service injection/fakes in tests if needed.
  - Verification: Notification service tests or analyzer.
  - Stop condition: Notification service can be initialized before use.

- [X] T015 [US4] Add Android notification permission/config in `android/app/src/main/AndroidManifest.xml` and notification service permission flow
  - Why: Android 13+ requires runtime notification permission.
  - Expected result: Manifest declares notification permission and service requests/checks permission before scheduling/showing.
  - Inputs: `AndroidManifest.xml`, `flutter_local_notifications` plugin APIs, `notification-contract.md`.
  - Implementation notes: Keep platform-specific code inside service. Do not request permission when user skipped notifications.
  - Possible bugs: API differences across plugin versions.
  - Fix strategy: Use the installed package version's Android plugin API and verify with analyzer.
  - Verification: Analyzer and service tests if practical.
  - Stop condition: Permission path is explicit and safe.

- [X] T016 [US4] Configure safe scheduled notification behavior in `lib/services/notifications/notification_service.dart`
  - Why: Scheduled notifications use timezone objects and can fail if timezone is not initialized.
  - Expected result: Timezone initialization is handled or scheduling is skipped with a safe result until configured.
  - Inputs: `notification_service.dart`, `timezone` package behavior.
  - Implementation notes: Prefer a typed result from scheduling instead of silent no-op.
  - Possible bugs: Missing timezone dependency import or schedule test failure.
  - Fix strategy: Add needed initialization carefully and verify package availability before imports.
  - Verification: Focused notification service tests or analyzer.
  - Stop condition: Scheduling no longer fails silently due to uninitialized timezone.

## Final Phase: Verification And Polish

- [X] T017 [Tests] Add/update notification onboarding tests in `test/features/onboarding/notifications_screen_test.dart`
  - Why: Allow/skip notification behavior was previously fake.
  - Expected result: Tests cover allow with choices, skip, save failure, and no immediate navigation before save success.
  - Inputs: `notifications_screen.dart`, `OnboardingCubit`, fake settings repository, fake notification service if introduced.
  - Implementation notes: Keep tests deterministic and avoid real notification plugin.
  - Possible bugs: Tests try to use platform channels.
  - Fix strategy: Inject or mock notification behavior outside widget tests.
  - Verification: `& 'C:\flutter\bin\flutter.bat' test test/features/onboarding/notifications_screen_test.dart`.
  - Stop condition: Notification onboarding behavior is covered.

- [X] T018 [Polish] Run focused verification commands
  - Why: Startup/onboarding changes are cross-cutting and can break routes or localization.
  - Expected result: Generated localization, scoped analyzer, and focused tests pass or exact unrelated failures are documented.
  - Inputs: Completed implementation.
  - Implementation notes: Do not hide failures. Separate pre-existing failures from new failures. Do not run repo-wide analyzer.
  - Possible bugs: Analyzer reports unrelated files touched by other agents.
  - Fix strategy: Fix new/touched-file issues first and document unrelated failures.
  - Verification:
    `& 'C:\flutter\bin\flutter.bat' gen-l10n`,
    `& 'C:\flutter\bin\flutter.bat' analyze lib/app/app.dart lib/app/router.dart lib/main.dart lib/features/onboarding/onboarding_cubit/onboarding_cubit.dart lib/features/onboarding/presentation/splash_screen.dart lib/features/onboarding/presentation/notifications_screen.dart lib/services/notifications/notification_service.dart packages/expense_repository/lib/src/firebase/firebase_settings_repo.dart packages/expense_repository/lib/src/entities/user_settings_entity.dart packages/expense_repository/lib/src/models/notification_settings.dart test/features/onboarding test/features/settings test/app/routes_test.dart`,
    `& 'C:\flutter\bin\flutter.bat' test test/features/onboarding`,
    `& 'C:\flutter\bin\flutter.bat' test test/app/routes_test.dart`.
  - Stop condition: Feature is verified enough for review.

## Dependencies And Execution Order

```text
T001-T002 block code edits.
T003 should be written before T004-T005 where practical.
T004-T005 block reliable onboarding flow.
T006 can run in parallel with T003 after baseline.
T007-T009 block final onboarding save.
T010-T013 depend on startup/settings foundation.
T014-T016 depend on notification settings decisions.
T017-T018 run after implementation.
```

## MVP Scope

```text
T001-T005, T007-T010, T013, T018
```
