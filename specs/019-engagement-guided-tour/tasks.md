# Tasks: Engagement Guided Tour

**Input**: `specs/019-engagement-guided-tour/spec.md`, `specs/019-engagement-guided-tour/plan.md`

## Phase 1: Guided Tour

- [ ] T019-001 [US1] Create guided tour models and cubit in `lib/guided_tour/`
  - Why: `new app` has no tour state management despite tests/spec references.
  - Expected result: Tour state tracks active step, completion, skip, replay, and persistence fields.
  - Inputs: `Expense-Tracker-main/lib/guided_tour/`.
  - Implementation notes: Store completion in `UserSettings`; keep route-agnostic step definitions.
  - Possible bugs: tour restarts every app launch.
  - Fix strategy: persist completed version and only auto-start newer versions.
  - Verification: `test/guided_tour/guided_tour_cubit_test.dart`.

- [ ] T019-002 [P] [US1] Add tour overlay widgets in `lib/guided_tour/widgets/`
  - Why: Tour needs reusable spotlight, connector, and step card components.
  - Expected result: Overlay highlights target widgets and renders controls.
  - Inputs: reference tour overlay widgets, `lib/core/theme/`.
  - Implementation notes: Use design tokens; support safe areas and RTL connector mirroring.
  - Possible bugs: overlay blocks system back or hides target on 360x800.
  - Fix strategy: constrain card placement and add scroll/placement fallback.
  - Verification: tour overlay widget tests in LTR/RTL.

- [ ] T019-003 [US1] Integrate tour targets into home/dashboard/settings screens
  - Why: Tour must highlight real UI elements.
  - Expected result: Key widgets expose stable target ids and tour starts after first onboarding.
  - Inputs: `HomeDashboardScreen`, bottom nav, settings route.
  - Implementation notes: Avoid duplicating UI just for tour targets.
  - Possible bugs: target key missing after responsive layout changes.
  - Fix strategy: create helper target wrapper and test target preparation.
  - Verification: home tour widget test.

## Phase 2: Engagement Calculations

- [ ] T019-004 [US2] Add engagement models in `lib/engagement/models/`
  - Why: Streak, health, prompt, and digest outputs need typed values.
  - Expected result: Models for tracking streak, health score, weekly digest, and retention prompt.
  - Inputs: reference engagement models.
  - Implementation notes: Keep models independent from UI widgets.
  - Possible bugs: score labels hardcoded English.
  - Fix strategy: store semantic levels and localize labels in UI.
  - Verification: model unit tests.

- [ ] T019-005 [US2] Implement engagement services in `lib/engagement/services/`
  - Why: Calculations must be deterministic and testable.
  - Expected result: Services calculate streak, health score, digest, and prompts from expenses/budgets/settings.
  - Inputs: reference services and fixture expense data.
  - Implementation notes: Avoid network calls; use repository data already loaded.
  - Possible bugs: multi-currency totals are inconsistent with reports.
  - Fix strategy: reuse finance calculation service from reports/budgets.
  - Verification: `test/engagement/*_test.dart`.

- [ ] T019-006 [US2] Add engagement UI panels in `lib/engagement/widgets/`
  - Why: Users need visible digest, score, and prompt surfaces.
  - Expected result: Dashboard/settings can render compact engagement panels and weekly digest screen.
  - Inputs: reference widgets, current dashboard design.
  - Implementation notes: Keep panels compact; no marketing-style hero sections.
  - Possible bugs: too many panels clutter dashboard.
  - Fix strategy: make panels collapsible or show only the highest-priority prompt.
  - Verification: weekly digest widget test.

## Phase 3: Notifications

- [ ] T019-007 [US3] Complete notification service in `lib/services/notifications/notification_service.dart`
  - Why: Onboarding/settings mention notifications but scheduling is incomplete.
  - Expected result: Initialization, permission request, channel setup, and cancellation helpers.
  - Inputs: reference notification service.
  - Implementation notes: Gracefully handle denied permissions and unsupported platforms.
  - Possible bugs: tests fail on desktop due to plugin calls.
  - Fix strategy: inject platform/service interface and mock in tests.
  - Verification: service unit tests with mocks.

- [ ] T019-008 [US3] Implement notification scheduler in `lib/services/notifications/notification_scheduler.dart`
  - Why: Budget, recurring, subscription, and digest reminders need stable scheduling.
  - Expected result: Scheduler creates/cancels jobs based on settings and finance state.
  - Inputs: reference scheduler, settings model, recurring/budget services.
  - Implementation notes: Use stable ids to prevent duplicates.
  - Possible bugs: time zone initialization missing.
  - Fix strategy: initialize timezone before scheduling and test ids.
  - Verification: `test/engagement/notification_scheduler_test.dart`.

- [ ] T019-009 [US3] Wire notification preferences in onboarding and settings screens
  - Why: User toggles must change actual scheduled jobs.
  - Expected result: Onboarding/settings save preferences and trigger scheduler refresh.
  - Inputs: `NotificationsScreen`, `SettingsScreen`, `SettingsCubit`.
  - Implementation notes: Keep denied-permission messaging user-safe.
  - Possible bugs: settings toggles still use local `setState` only.
  - Fix strategy: route all toggles through `SettingsCubit`.
  - Verification: settings/onboarding tests.

## Final Verification

- [ ] T019-010 [Polish] Run engagement/tour/notification QA
  - Why: Overlay and notification regressions are user-visible and easy to miss.
  - Expected result: Tests pass and manual checks cover first-run, replay, RTL, and permission denied.
  - Inputs: completed engagement work.
  - Implementation notes: Do not block core app if notifications fail.
  - Possible bugs: tour overlay flakiness from animation timing.
  - Fix strategy: disable animations or pump settled frames in tests.
  - Verification: `flutter analyze --no-pub`; `flutter test --no-pub test/guided_tour test/engagement test/services`.
