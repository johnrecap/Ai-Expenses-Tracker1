# Data Model: Real AI Expense Refactor

## Existing Entities To Preserve

### Expense

Represents a confirmed user spending record.

Key fields:

- id
- user id
- amount
- currency
- date
- category id/name
- wallet id/name
- payment method
- description/note
- source: manual, AI, recurring, or receipt
- created and updated timestamps

Validation:

- Amount must be positive.
- Currency must be valid.
- Date must be present.
- Required ownership must match signed-in user.
- Category and wallet should resolve to current user data when required by the save flow.

### Category

Represents a user-owned expense group.

Key fields:

- id
- name
- icon
- color
- archive status

Validation:

- Name is required.
- Archived categories should not be default targets for new expenses unless explicitly selected.

### Wallet

Represents a user-owned payment source.

Key fields:

- id
- name
- type
- balance
- currency
- icon/color

Validation:

- Name is required.
- Currency is required.
- Balance must be valid money.

### User Settings

Represents app preferences.

Key fields:

- language preference
- base currency
- supported currencies
- default payment method
- notification settings
- onboarding state

Validation:

- Language is one of system, English, or Arabic.
- Base currency is valid.

## New/Refined Entities

### Expense Text Input

Temporary state before AI parsing.

Fields:

- raw text
- locale
- default currency
- client request id
- created timestamp

Validation:

- Raw text must be non-empty before parse.
- Raw text must remain visible if parsing fails.

### AI Expense Draft

Temporary review state created from AI parsing or receipt extraction.

Fields:

- original input
- amount
- currency
- date
- category suggestion
- matched category id
- wallet suggestion
- matched wallet id
- merchant/description
- confidence
- missing fields
- gateway request id
- quota status

Validation:

- Draft can be displayed even if incomplete.
- Draft cannot be saved until required fields are valid.
- User edits override AI suggestions.

State transitions:

```text
empty -> typing -> parsing -> draftReady -> editing -> saving -> saved
                         \-> parseFailed -> editing/manual
                         \-> quotaBlocked -> manualFallback
```

### AI Gateway Error

Represents a safe user-facing failure.

Fields:

- request id
- error code
- user-safe message
- quota status when applicable

Validation:

- Must not contain raw prompt text, secrets, or full provider response.

### Empty State

Represents a screen with no real user data.

Fields:

- title
- message
- icon
- primary action label
- primary action route or command

Validation:

- Must not show fake financial values.
- Must guide the user to the next useful action.

### Action Availability

Represents whether a visible action is usable.

Values:

- ready
- needs setup
- unavailable
- disabled by quota
- disabled by auth/session

Validation:

- Unavailable actions must explain why.
- Hidden or disabled actions must not look like successful working features.

