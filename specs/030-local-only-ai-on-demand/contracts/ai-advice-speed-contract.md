# Contract: Fast AI Advice Request

## Goal

AI advice must feel fast because the app sends only a small precomputed summary.

## Request Trigger

AI advice request is sent only when the user explicitly taps an AI action such as:

- Ask AI
- Analyze my spending
- Suggest savings
- Review subscriptions

No background AI advice upload is allowed.

## Payload Shape

The request must include:

- `clientRequestId`
- `locale`
- `defaultCurrency`
- `now`
- `period`
- `summary`

The request must not include by default:

- Full expenses list
- Merchant names
- Expense descriptions
- Receipt OCR text
- User email
- Phone number
- Raw wallet transaction history

## Payload Size Budget

- Typical account: below 10 KB serialized JSON.
- Heavy account: below 25 KB serialized JSON.
- Top categories capped at 5.
- Trend flags capped at 5.
- Subscription records capped at summarized totals unless user explicitly asks for subscription review.

## Speed Budget

- Local summary read/build before request: target under 150 ms.
- Local advice render: target under 300 ms after opening screen.
- AI network timeout: short user-facing timeout, recommended 8 seconds.
- UI must keep local advice visible while AI is loading.

## Failure Contract

If AI fails, times out, or quota blocks:

- Keep local advice visible.
- Show a concise error.
- Offer Retry only if retry is useful.
- Do not clear existing local or cached advice.

## Privacy Contract

The app should prefer aggregate numbers and short labels. If a future feature needs raw rows, it must be a separate explicit consent flow and separate Spec Kit plan.
