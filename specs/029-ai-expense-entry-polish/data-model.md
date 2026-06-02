# Data Model: AI Expense Entry Polish

## AI Input Field

Represents the natural-language text the user enters before AI parsing.

Relevant state:

- `text`: user-entered description.
- `focus`: whether the keyboard is active.
- `status`: empty, typing, parsing, parse failed, draft ready.

Validation:

- Empty or whitespace-only text cannot be parsed.
- Text and hint must render inside the visible input field.
- Keyboard focus must be cleared when the user presses done, Parse, or Save.

## AI Draft Review

Represents the parsed expense suggestion before final save.

Relevant state:

- `amount`
- `currency`
- `description`
- `categoryId`
- `categoryName`
- `paymentMethod`
- `walletAccountId`
- `walletAccountName`
- `missingFields`
- `confidence`

Validation:

- Amount must be present and greater than zero before saving.
- Category must be selected or confidently mapped before saving.
- Wallet is optional and must not appear as a required missing field by itself.
- Payment method falls back to existing default payment behavior from feature 028.

## AI Save Action

Represents the final user action after AI draft review.

Relevant state:

- `saving`: save is in progress.
- `saved`: repository write succeeded.
- `errorMessage`: user-facing save or validation failure.

Validation:

- Save is blocked for missing amount/category.
- Save uses the existing authenticated user id.
- Save writes through the existing expense repository boundary.
- Save does not create fake wallet data.

## Post-save Refresh

Represents the app state update after a successful AI expense save.

Refresh targets:

- Expense list state.
- Home dashboard totals that depend on expenses.
- Reports state.
- Current month budget state.

Validation:

- Refresh starts immediately after successful save.
- Refresh uses the current month/year at refresh time.
- Refresh does not require restarting or backgrounding the app.
