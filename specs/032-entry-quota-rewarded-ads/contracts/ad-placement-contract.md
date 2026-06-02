# Contract: Banner And Inline Ad Placement

## Purpose

Keep non-rewarded ads visible only where they do not interfere with money entry.

## Allowed Placements

### Home Banner

- Free users only.
- Provider available and consent allows ads.
- Must not cover bottom navigation, floating add button, profile button, sidebar button, or scrollable content.
- Hidden for premium users.

### Expenses Inline

- Free users only.
- Provider available and consent allows ads.
- Only appears after real expense rows, starting after at least 6 expenses.
- Does not replace, hide, or reorder expense rows.
- Hidden for premium users.
- Hidden when the list is too short.

## Blocked Placements

- Expense entry screen body.
- Expense save flow.
- AI text field.
- AI typing/parsing area.
- Receipt selection or save flow.
- Any modal sheet where the primary action is Save, Confirm, or typing.

## UI Rules

- Use existing theme, spacing, and safe-area rules.
- No new design language.
- No ad slot may overlap the bottom navigation or floating add button.
- RTL and LTR layouts must preserve row order and safe spacing.
