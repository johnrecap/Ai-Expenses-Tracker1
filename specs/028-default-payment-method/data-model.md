# Data Model: Default Payment Method

## PaymentMethod

Represents how an expense was paid.

Allowed values:

| Product label | Storage value | Meaning |
| --- | --- | --- |
| Cash | `cash` | Physical cash or unspecified cash-like payment |
| Visa/Card | `visa` | Card payment |
| Wallet | `wallet` | Digital wallet payment method, with or without a saved wallet account |
| Bank Transfer | `bank_transfer` | Bank transfer, InstaPay-like transfer, or account-to-account transfer |

Validation:

- Must be one of the allowed values.
- Unknown, missing, or corrupt values resolve to Cash.

## UserSettings

Represents persisted user preferences.

Relevant field:

- `defaultPaymentMethod`: required payment method used when a new expense has no explicit method.

Validation:

- New settings default to Cash.
- Settings save must persist the selected method.
- Settings load must safely normalize unknown values to Cash.

## Expense

Represents a saved transaction.

Relevant fields:

- `paymentMethod`: required.
- `walletAccountId`: optional.
- `walletAccountName`: optional.

Validation:

- Expense cannot be saved without a valid payment method.
- Expense can be saved without wallet fields.
- If a wallet account is selected, wallet fields must match the selected wallet.
- If no wallet account is selected, wallet fields stay empty even when payment method is Wallet.

## WalletAccount

Represents a tracked wallet/account.

Relationship:

- Optional relation from Expense to WalletAccount.
- A payment method of Wallet does not automatically require this relation.

## AI Expense Draft

Represents the review state before saving an AI-created expense.

Relevant fields:

- `paymentMethod`: optional until mapping applies fallback.
- `walletAccountId`: optional.
- `walletAccountName`: optional.
- `missingFields`: must not include wallet merely because no wallet exists.

Validation:

- If AI text provides a clear payment method, use it.
- If AI text has no clear payment method, use settings default.
- If settings default is unavailable, use Cash.
- Wallet suggestions only link when matched to an existing wallet account.
