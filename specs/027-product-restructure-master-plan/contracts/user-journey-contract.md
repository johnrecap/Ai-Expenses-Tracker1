# Contract: User Journey Acceptance

## Startup And Setup

- A user without completed setup cannot reach the home dashboard.
- A user with completed setup does not repeat setup on normal app launch.
- Language choice changes visible text direction and language.
- Currency choice is used by default in expense entry and summaries.
- Notification choice is saved before navigating home.

## Expense Entry

- Home has one primary Add entry.
- Add opens Quick Add, AI Text, and Receipt only if Receipt is real or clearly unavailable.
- Every save path creates the same real expense shape.
- AI and receipt paths always show a review step.
- Save failure is shown and does not pretend success.

## Financial Overview

- "This Month" uses current-month data.
- Report drilldown shows the selected category's real expenses.
- Budgets compare against the same period as the label.
- Empty data uses empty states, not fake numbers.

## AI Experiences

- AI text uses secure gateway.
- Receipt uses receipt extraction endpoint or is disabled.
- Advice, chat, and history show real results or honest empty/unavailable states.
- Quota, auth, and network errors are visible.

## Security And Settings

- Settings rows do real actions or show unavailable status.
- App lock blocks app use after resume when enabled.
- Account deletion requires reauthentication when required.
- Premium/ads are real or disabled.

## Backend Services

- Firestore rules accept valid app writes.
- Notification scheduling respects permissions and user choices.
- Exports include selected period and relevant fields.
- Analytics does not send sensitive financial raw values.
- Exchange-rate failure does not silently create wrong conversions.
- VPS sync mode is not presented as working until push/pull contracts are aligned.
