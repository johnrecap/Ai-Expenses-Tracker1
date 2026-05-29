# Data Model: Foundation Mock Data

## MockUser

- `id`: stable mock ID
- `displayName`: visible profile name
- `avatarAsset`: local optional asset
- `localeCode`: `en` or `ar`
- `baseCurrency`: currency code

## MockCategory

- `id`
- `label`
- `iconName`
- `colorToken`

## MockExpense

- `id`
- `merchant`
- `categoryId`
- `amount`
- `currency`
- `date`
- `walletId`
- `notes`
- `visualStatus`

## MockWallet

- `id`
- `name`
- `type`
- `balance`
- `currency`
- `trendLabel`

## MockBudget

- `id`
- `monthLabel`
- `cap`
- `spent`
- `categoryAllocations`

## MockGoal

- `id`
- `title`
- `targetAmount`
- `savedAmount`
- `deadlineLabel`

## MockSubscription

- `id`
- `vendor`
- `amount`
- `currency`
- `nextBillingLabel`
- `status`
- `hasAiWarning`

## MockReport

- `id`
- `periodLabel`
- `totalSpent`
- `comparisonLabel`
- `categoryBreakdown`
- `trendPoints`

## MockAiInsight

- `id`
- `title`
- `summary`
- `severity`
- `relatedRoute`

## MockChatMessage

- `id`
- `author`
- `text`
- `timestampLabel`
- `isUser`

## Validation Rules

- All IDs used in routes must resolve to one mock entity or a not-found state.
- Amounts must be finite and formatted by UI only.
- Progress values derived from amounts must be clamped between 0 and 1.
- Mock data files must not import HTTP, Firebase, database, or persistence packages.
