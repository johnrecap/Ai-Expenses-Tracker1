# Data Model: Local Only With AI On Demand

## LocalFinancialStore

Represents all financial and app-owned records stored on the device.

Records:

- Expenses
- Categories
- Category aliases
- Wallets/accounts
- Transfers
- Monthly budgets
- Category budgets
- Saving goals
- Subscriptions/recurring expenses
- Settings
- Local AI history/advice cache

Validation:

- Must persist after app restart.
- Must work offline.
- Must not write app-owned financial data to Firestore or PostgreSQL.
- Must expose streams or change notifications for UI refresh.

## AdviceSummary

Compact local aggregate used for local tips and AI advice requests.

Fields:

- `period`: current month, last month, or selected range.
- `currency`
- `totalSpent`
- `dailyAverage`
- `budgetAmount`
- `budgetRemaining`
- `budgetUsedPercent`
- `topCategories`: at most 5 records with category name, amount, and percent.
- `categoryTrendFlags`: at most 5 short flags.
- `subscriptionsTotal`
- `recurringTotal`
- `walletBalancesSummary`
- `savingGoalsProgress`
- `monthComparisonPercent`
- `riskFlags`: short local flags such as overspending, budget near limit, subscription spike.

Validation:

- Must not include raw expense descriptions, merchant names, receipt text, or full transaction lists by default.
- Must be serializable to compact JSON.
- Normal payload target: under 10 KB.
- Heavy-user fallback target: under 25 KB.
- Must be safe to show/send in Arabic and English contexts.

## LocalAdvice

Deterministic advice generated locally.

Fields:

- `id`
- `type`
- `title`
- `body`
- `severity`
- `createdAt`
- `source = local`

Validation:

- Must render without internet.
- Must update from the latest local summary.
- Must be short and practical.

## AiAdviceRequest

On-demand AI request sent to the AI gateway.

Fields:

- `clientRequestId`
- `locale`
- `defaultCurrency`
- `now`
- `period`
- `summary`
- `premiumContext`: minimal entitlement/feature flags only.

Validation:

- Sent only after explicit user action.
- Uses compact `AdviceSummary`.
- Does not include raw financial rows by default.
- Times out quickly enough to keep the UI responsive.

## AiAdviceCache

Stores the last returned AI advice locally.

Fields:

- `requestSummaryHash`
- `advice`
- `createdAt`
- `locale`
- `period`
- `providerMetadata`

Validation:

- Can be shown while offline as "last AI advice".
- Invalidates when summary changes significantly.
- Does not store provider secrets.

## EntitlementSnapshot

Local view of premium status.

Fields:

- `isPremium`
- `source`
- `lastCheckedAt`
- `expiresAt`
- `features`

Validation:

- Premium hides ads and unlocks premium AI limits/features.
- Unknown state falls back to free or last-known safe state with Restore option.

## AdPolicyState

Local state controlling ad placement.

Fields:

- `isPremium`
- `sessionActionCount`
- `lastInterstitialAt`
- `consentState`
- `disabledPlacements`

Validation:

- Ads must not block adding an expense.
- Ads must not appear for premium users.
- Ads must respect consent state.
