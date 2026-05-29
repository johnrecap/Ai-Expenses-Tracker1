# Feature Specification: Engagement Guided Tour

**Feature Branch**: `019-engagement-guided-tour`
**Created**: 2026-05-29
**Status**: Draft
**Input**: Add missing engagement features from `Expense-Tracker-main`: guided tour, weekly digest, streaks, spending health score, retention prompts, and notification scheduling.

## Mandatory Agent Prerequisites

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

**Scope guard**: Engagement UI, local notifications, guided tour, and retention calculations are in scope. Export screen and Firebase Functions are out of scope.

## User Scenarios & Testing

### User Story 1 - Guided First Run (Priority: P1)

As a new user, I want a short guided tour that explains key expense-tracking actions after onboarding.

**Why this priority**: `new app` has onboarding but no replayable guided tour, reducing activation.

**Independent Test**: Fresh user completes onboarding, lands on home, sees tour, advances through steps, completes, and can replay from settings.

### User Story 2 - Spending Health And Streaks (Priority: P2)

As a user, I want visible progress signals such as tracking streak, spending health score, and weekly digest.

**Why this priority**: These reference features improve retention and give users reasons to return.

**Independent Test**: Use fixture expenses and verify calculated health score, streak, digest, and UI panels.

### User Story 3 - Useful Notifications (Priority: P2)

As a user, I want reminders for daily check-in, budget alerts, recurring due dates, and weekly digest when enabled.

**Why this priority**: Notifications are declared in onboarding/settings but scheduling behavior is incomplete.

**Independent Test**: Toggle notification preferences and verify scheduler receives expected jobs without duplicate scheduling.

## Requirements

### Functional Requirements

- **FR-001**: Guided tour MUST support step definitions, spotlight targets, connectors, next/back/skip/done, completion persistence, and replay.
- **FR-002**: Guided tour MUST support RTL connector direction and small mobile viewports.
- **FR-003**: Engagement services MUST calculate tracking streak, spending health score, weekly digest, and retention prompts from real expenses/settings.
- **FR-004**: Notification scheduler MUST honor user preferences and avoid duplicate scheduled notifications.
- **FR-005**: Engagement UI MUST use shared components and localized copy.
- **FR-006**: Notification permission UX MUST degrade gracefully when denied.

### Key Entities

- **Tour Step**: Target id, title, body, placement, and route.
- **Tracking Streak**: Consecutive days with tracked activity.
- **Spending Health Score**: Summary of budget adherence and spending patterns.
- **Weekly Digest**: Period summary with totals, changes, highlights, and prompts.
- **Notification Preference**: User toggles for check-in, budget, recurring, and digest.

## Success Criteria

- **SC-001**: Fresh user sees guided tour once and can replay it later.
- **SC-002**: Engagement calculations are deterministic for fixture expense data.
- **SC-003**: Notification scheduler does not create duplicate jobs for the same preference/date.
- **SC-004**: Tour overlay and digest screen pass RTL and required viewport checks.

## Assumptions

- App has access to user settings and expense streams from repository work.
- Local notifications are sufficient; push notifications are not required in this plan.
