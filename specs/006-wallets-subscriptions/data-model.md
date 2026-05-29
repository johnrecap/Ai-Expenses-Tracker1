# Data Model: Wallets And Subscriptions

## WalletCardViewData

- `walletId`
- `name`
- `type`
- `balance`
- `currency`
- `trendLabel`
- `iconTextOrName`

## TransferPreview

- `id`
- `sourceWalletId`
- `destinationWalletId`
- `amount`
- `currency`
- `dateLabel`
- `status`

## SubscriptionCardViewData

- `subscriptionId`
- `vendor`
- `amount`
- `currency`
- `nextBillingLabel`
- `status`
- `identityTextOrIcon`
- `hasAiWarning`

## Validation Rules

- No remote logo URLs.
- Actions do not persist.
- Amount text must be constrained at 360px.
- Status values must map to known visual variants with fallback.
