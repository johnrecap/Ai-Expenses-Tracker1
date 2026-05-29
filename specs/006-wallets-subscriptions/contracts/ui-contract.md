# UI Contract: Wallets And Subscriptions

## Routes

- `/wallets`
- `/subscriptions`

## Component Contracts

### WalletCard

- Accepts wallet view data and optional tap callback.
- Shows balance, account type, trend, and local visual identity.
- Must fit one-column mobile layout.

### TransferPreviewTile

- Accepts transfer preview data.
- Uses directional layout and constrained amount text.

### SubscriptionCard

- Accepts subscription view data.
- Shows vendor, recurring amount, next bill, status, and local identity mark.
- No remote image loading.

## Interaction Contracts

- Add wallet/subscription actions are local-only or placeholder-only.
- No bank, billing, or payment flows are started.
- No data is persisted.
