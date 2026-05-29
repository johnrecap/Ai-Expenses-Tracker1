# UI Contract: Add And Edit Expense

## Routes

- `/expenses/new/quick`: quick manual entry.
- `/expenses/new/text`: AI text entry mock.
- `/expenses/new/receipt`: receipt entry mock.
- `/expenses/:expenseId/edit`: edit existing mock expense.

## Component Contracts

### SegmentedModeControl

- Accepts selected mode and mode change callback.
- Stable height and touch targets.
- Direction-aware layout.

### AmountInputHero

- Accepts amount text, currency, and input callback.
- Must constrain large values at 360px.

### ExpenseFormCard

- Accepts draft values, category options, wallet options, and callbacks.
- No persistence or save service.

### AiExpenseParsePanel

- Accepts text input and local parse callback.
- Shows static mock suggestion after parse.
- No AI/network imports.

### ReceiptUploadPanel

- Accepts local mock upload callback.
- Shows mock parsed state.
- No camera, file picker, OCR, or permission imports.

## Interaction Contracts

- Save shows local feedback or navigates locally only.
- Parse/upload toggles local state only.
- Edit unknown ID shows safe not-found state.
