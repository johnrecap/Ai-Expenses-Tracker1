# Contract: Local Only Data Ownership

## Product Rule

The app must treat on-device storage as the only production financial data store.

## Allowed Network Use

Allowed:

- Explicit AI advice/action requests.
- Ads SDK requests.
- App-store purchase/restore checks.
- Operational AI gateway quota/abuse checks.

Not allowed:

- Background financial data upload.
- Firestore writes for app-owned financial data.
- PostgreSQL/VPS writes for app-owned financial data.
- Sync push/pull in production local-only mode.

## Core Tracking Contract

Core tracking must work offline:

- Add expense
- Edit expense
- Delete expense
- List/filter expenses
- Categories
- Wallets
- Budgets
- Goals
- Subscriptions/recurring expenses
- Reports and monthly story from local data
- Settings

## Repository Contract

Production local-only mode must instantiate local repositories only.

Forbidden in local-only app data mode:

- `FirebaseExpenseRepo`
- `FirebaseCategoryRepository`
- `FirebaseBudgetRepository`
- `FirebaseSettingsRepository`
- `FirebaseWalletAccountRepository`
- VPS sync repositories as primary app data owner

## User Messaging Contract

Settings/onboarding must not imply cloud backup exists.

Required wording concept:

- Your financial data is stored on this device.
- Deleting the app or losing this phone can remove your data.
- AI advice sends only a small summary when you request it.
