# Contract: Payment Method And Optional Wallet Behavior

## Global Rules

1. Payment method is required for every saved expense.
2. Wallet account is optional for every saved expense.
3. Missing payment method resolves to the user's default payment method.
4. Missing or unavailable default resolves to Cash.
5. Wallet account fields are written only when the user selects an existing wallet account or AI matches one confidently.

## Settings Contract

### Default Payment Method Selector

Visible options:

- Cash
- Visa/Card
- Wallet
- Bank Transfer

Expected behavior:

- Current default is shown from settings.
- Selecting an option persists it through the existing settings repository.
- A save failure keeps the previous setting and shows an honest error state.
- Labels must be localizable in Arabic and English.

## Quick Add Contract

Inputs:

- Amount
- Category
- Optional merchant/description
- Payment method selector
- Optional wallet account selector

Save behavior:

| User choice | Saved payment method | Saved wallet fields |
| --- | --- | --- |
| No method, no wallet | Settings default or Cash fallback | Empty |
| Cash, no wallet | Cash | Empty |
| Visa/Card, no wallet | Visa | Empty |
| Wallet, no wallet | Wallet | Empty |
| Bank Transfer, no wallet | Bank Transfer | Empty |
| Existing wallet selected | Wallet unless explicitly designed otherwise | Selected wallet id/name |

## AI Text Add Contract

Detection precedence:

1. Explicit text payment method.
2. User default payment method.
3. Cash fallback.

Keyword intent examples:

| Text intent | Expected method |
| --- | --- |
| `cash`, `كاش`, `نقدي` | Cash |
| `visa`, `card`, `فيزا`, `كارت` | Visa/Card |
| `wallet`, `محفظة`, wallet provider name | Wallet |
| `transfer`, `bank transfer`, `تحويل`, `انستاباي`, `instapay` | Bank Transfer |

Review behavior:

- User can change payment method before saving.
- User can save without wallet account.
- Wallet missing fields are not required when all other required fields exist.

## Persistence Contract

Expense document/entity:

- `paymentMethod`: required valid storage value.
- `walletAccountId`: optional.
- `walletAccountName`: optional.

Settings document/entity:

- `defaultPaymentMethod`: required valid storage value.

Firestore/local rules:

- Must accept valid payment method with null/absent wallet fields.
- Must reject invalid payment method values.
