# Contract: Notification Onboarding

## User Choices

- Allow notifications.
- Skip notifications.
- Daily reminder enabled/disabled.
- Weekly digest enabled/disabled.
- Daily reminder time when enabled.

## Device Behavior

- Initialize local notification service before showing or scheduling.
- Request notification permission on platforms that require it.
- Schedule daily reminder only when permission is granted and daily reminder is enabled.
- Do not schedule reminders when user skips or permission is denied.
- If scheduling cannot be safely configured, save settings honestly and show non-blocking unavailable/error feedback.

## Backend/Settings Behavior

- Save notification fields in `UserSettings.notificationSettings`.
- Firestore serialization and rules must preserve the same fields.

## Test Contract

- Tests cover allow, skip, permission denied, and no silent navigation on save failure.
