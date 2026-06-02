# Data Model: Product Restructure Master Plan

## User Setup State

Represents what the app needs before the user reaches home.

**Fields**:

- `language`: Arabic, English, or system preference.
- `baseCurrency`: selected currency code.
- `notifications`: notification choices, reminder time, digest preference, permission state.
- `onboardingComplete`: whether required setup is complete.
- `settingsLoadState`: loading, loaded, failed.

**Rules**:

- Existing settings must not be overwritten by defaults.
- Language must control direction and text.
- Notification choice must not schedule notifications if permission is denied.

## Expense Entry Draft

Represents a draft before saving an expense.

**Fields**:

- `amount`, `currency`, `date`, `description`
- `categoryId`, `categoryName`
- `walletId`, `walletName`
- `source`: manual, AI text, receipt
- `missingFields`
- `reviewedByUser`

**Rules**:

- Drafts from AI or receipt must be reviewed before save.
- Save must be disabled until required fields are valid.
- Missing category or wallet must be visible to the user.

## Expense

Represents a real saved spending record.

**Fields**:

- Owner/user id
- Amount and currency
- Date and period
- Category
- Wallet/account
- Payment method
- Source
- Description/note
- Created/updated timestamps

**Rules**:

- Edit must preserve all existing fields not explicitly changed.
- Monthly reporting must use date boundaries.
- Firestore rules must accept all valid source values used by the app.

## Category Alias

Represents words that map text or merchant names to categories.

**Fields**:

- `categoryId`
- `alias`
- `language`
- `createdAt`

**Rules**:

- Alias must be unique per user/category context.
- Archived categories should not be chosen automatically for new expenses.

## Wallet Transfer

Represents money moved between wallets/accounts.

**Fields**:

- Source wallet
- Destination wallet
- Amount/currency
- Date
- Note
- Status

**Rules**:

- Source and destination cannot be the same.
- Balance behavior must be explicit.
- Transfer must be reversible or editable only through a clear policy.

## Financial Period

Represents the time window used by home, reports, budgets, and story.

**Fields**:

- Start date
- End date
- Label
- Previous period link

**Rules**:

- "This Month" means current calendar month unless user selects another period.
- All screens using monthly numbers must share the same period.

## Budget

Represents planned spending.

**Fields**:

- Monthly total budget
- Category budget
- Currency
- Period
- Threshold alerts

**Rules**:

- Budget comparison uses expenses in the same period.
- Category budgets must use that category's spend, not total budget as a category cap.

## Saving Goal

Represents a target the user saves toward.

**Fields**:

- Name
- Target amount
- Current amount
- Currency
- Deadline
- Status

**Rules**:

- Progress must be editable.
- Completed, active, and archived goals must be distinguishable.

## Recurring Expense

Represents repeated financial obligation.

**Fields**:

- Amount/currency
- Category/wallet
- Frequency
- Next run
- Status
- Type: generic recurring or subscription if kept in one model

**Rules**:

- Subscriptions must not be inferred from all active recurring expenses without a type.

## AI Request Record

Represents metadata for AI usage and user-visible history.

**Fields**:

- Type: parse text, receipt, advice, chat
- Status: success, quota, auth error, failure
- Timestamps
- Safe metadata
- Result summary

**Rules**:

- No provider secrets.
- Avoid storing raw financial text unless explicitly required and privacy-reviewed.
- History screen must show real records or an empty state.

## Security State

Represents app lock and account protection.

**Fields**:

- App lock enabled
- PIN configured
- Biometric enabled
- Last background time
- Lock state
- Failed attempts

**Rules**:

- Unlock must gate financial screens.
- PIN change must verify current PIN or biometric.

## Sync Change

Represents local-first sync work.

**Fields**:

- Entity type
- Entity id
- Operation
- Client updated time
- Payload
- Sync status
- Conflict state

**Rules**:

- Operation names must match server contract.
- Pull must apply remote changes locally.
- Pending changes must survive app restart.
