# Data Model: Smart Add Entry

## SmartAddChoice

Represents one method shown inside the add-choice sheet.

Fields:

- `id`: stable identifier for tests and analytics, such as `ai_text`, `quick_add`, `receipt`.
- `title`: localized visible title.
- `subtitle`: localized short explanation.
- `icon`: visual icon from the existing icon set.
- `state`: availability state.
- `destination`: route or callback used when the choice is enabled.

Validation:

- Enabled choices must have a destination.
- Disabled choices must have a visible reason.
- Titles and subtitles must be available in Arabic and English.
- Choices must not contain hardcoded route strings in new code.

## SmartAddChoiceState

Represents whether a choice can be used.

Values:

- `enabled`: user can tap and continue.
- `disabledNeedsSetup`: user needs a category, wallet, permission, or setup step first.
- `disabledUnavailable`: feature is not ready or temporarily unavailable.
- `hidden`: choice should not be shown in this context.

Validation:

- Disabled states must not navigate.
- Hidden choices must not leave visual gaps.
- Unavailable receipt must not pretend to parse receipts.

## SmartAddSheetResult

Represents what happens after a user picks a choice.

Fields:

- `choiceId`: selected `SmartAddChoice.id`.
- `action`: `navigate`, `showUnavailable`, or `dismiss`.
- `route`: destination route when action is `navigate`.

Validation:

- `navigate` requires a valid route.
- `showUnavailable` requires user-facing text.
- `dismiss` must not trigger navigation.

## HomeAddEntryState

Represents the home-screen add-entry surface.

Fields:

- `isSheetOpen`: whether the add sheet is visible.
- `availableChoices`: ordered choices to show.
- `textDirection`: current Arabic RTL or English LTR direction.

Validation:

- Home screen must expose exactly one primary add button.
- Top-bar AI remains outside this state and continues to open assistant/help.
