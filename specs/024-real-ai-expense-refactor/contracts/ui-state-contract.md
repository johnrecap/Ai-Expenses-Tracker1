# Contract: UI State And Real Data Behavior

## General Screen States

Every primary screen must support:

- loading
- loaded with real data
- empty with next action
- error with retry or guidance
- unavailable only when intentionally not ready

Primary screens:

- Splash
- Onboarding language
- Onboarding currency
- Onboarding notifications
- Login
- Sign-up
- Dashboard
- Expenses list
- Expense filters
- Quick add expense
- AI text add expense
- Receipt add expense
- Edit expense
- Reports
- Budgets
- Goals
- Wallets
- Subscriptions
- AI advice
- AI history
- AI assistant
- Settings
- Account profile
- Security unlock/PIN

## No Mock Data Rules

- New accounts show empty states, not fake transactions.
- Existing accounts show only that user's real saved data.
- Demo/test fixtures must not be imported by production screens.
- If a feature is not connected yet, it must be unavailable or hidden, not populated with fake data.

## Expense Entry Rules

All expense entry modes must share:

- required field validation
- user-friendly errors
- save loading state
- success handling
- cancellation handling
- same visual language

AI-specific rules:

- AI creates a draft.
- Draft is editable.
- Save is disabled until required fields are valid.
- User confirmation is required.
- AI failure keeps the original typed input.

## Action Audit Rules

Each visible action must be categorized as:

- working
- needs setup
- temporarily unavailable
- intentionally disabled

No action may silently do nothing.

## Acceptance Tests

- New test account shows no fake data on primary screens.
- Every visible main action opens a real flow or shows a clear unavailable/setup message.
- AI draft cannot save with missing amount/category/date/wallet when those are required.
- Saved AI expense appears in expenses list and dashboard summaries.

