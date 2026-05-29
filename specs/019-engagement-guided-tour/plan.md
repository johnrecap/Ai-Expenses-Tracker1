# Implementation Plan: Engagement Guided Tour

**Branch**: `019-engagement-guided-tour` | **Date**: 2026-05-29 | **Spec**: `specs/019-engagement-guided-tour/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

## Summary

Port engagement and guided tour capabilities into the redesigned `new app` architecture, including tour overlays, streaks, health score, weekly digest, retention prompts, and notification scheduling.

## Why

The comparison found `lib/guided_tour/` and `lib/engagement/` absent in `new app`. Onboarding and notifications are present visually but lack the retention mechanics implemented in the reference app.

## Expected Result

- Guided tour cubit, models, overlay widgets, and dashboard integration.
- Engagement services and panels.
- Weekly digest screen.
- Notification scheduler connected to preferences.
- Tests for tour geometry/state and engagement calculations.

## Source References

- `Expense-Tracker-main/lib/guided_tour/`
- `Expense-Tracker-main/lib/engagement/`
- `Expense-Tracker-main/lib/services/notifications/`
- `Expense-Tracker-main/test/guided_tour/`
- `Expense-Tracker-main/test/engagement/`
- `new app/lib/features/onboarding/`
- `new app/lib/features/settings/`

## Technical Context

**Primary Dependencies**: `flutter_bloc`, `flutter_local_notifications`, `timezone`, existing repository package.

**Storage**: User settings for tour completion and notification preferences.

**Testing**: Cubit tests, service calculation tests, widget tests for tour/digest.

**Constraints**: No intrusive notifications, no duplicate schedules, no layout overflow on small phones.

## Constitution Check

- Engagement features are native Flutter and repository-backed.
- RTL/LTR and viewport checks are planned.
- No backend Functions or Export work is included.

## Project Structure

```text
lib/guided_tour/
lib/engagement/
lib/services/notifications/
lib/features/settings/
lib/features/onboarding/
test/guided_tour/
test/engagement/
test/services/
```

## Implementation Batches

### Batch 1 - Guided Tour

**Expected result**: Tour can start, advance, skip, complete, persist, and replay.

### Batch 2 - Engagement Calculations

**Expected result**: Streak, health score, digest, and retention prompt services are deterministic.

### Batch 3 - Notifications

**Expected result**: Scheduler honors preferences for check-in, budget, recurring, subscription, and digest reminders.

### Batch 4 - UI Integration And QA

**Expected result**: Home/settings/onboarding expose engagement features without clutter.

## Possible Bugs And Fix Strategy

- **Spotlight target missing after async screen load**: wait for post-frame layout and retry target lookup.
- **Connector direction wrong in RTL**: make geometry direction-aware and test RTL.
- **Notification duplicates**: use stable notification ids per user/preference/date.
- **Digest uses stale currency data**: calculate from repository/settings at render time.
- **Retention prompts feel intrusive**: cap frequency and let users dismiss.

## Verification Plan

```powershell
flutter analyze --no-pub
flutter test --no-pub test/guided_tour test/engagement test/services
```

Manual checks: fresh onboarding tour, replay from settings, Arabic RTL overlay, notification permission denied/allowed flows.

## Stop Condition

Guided tour and engagement features are implemented, localized, tested, and do not block core expense tracking.
