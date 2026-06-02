# Contract: AI Expense Entry UI And Refresh

## AI Input Visual Contract

The AI text input must:

- Have a visible input surface using existing app colors and radius tokens.
- Use non-zero internal text padding.
- Show hint and typed text inside the field boundary.
- Show focused state with the existing primary color behavior.
- Keep microphone and parse controls visually separate from the text entry area.
- Avoid introducing new colors or a new design language.

## Keyboard Contract

Expected behavior:

- Pressing keyboard done/enter clears focus.
- Pressing Parse clears focus before the parse loading state.
- Pressing Save clears focus before validation/save.
- Empty text still shows the existing "enter expense text first" style error.

## Save Placement Contract

Expected layout order:

1. Screen title and mode switcher.
2. AI input panel.
3. AI gateway error state or AI suggestion/review state.
4. Save button directly under the AI area when the user can act on the AI result or filled details.
5. Optional manual correction fields below.

Save rules:

- Amount and category are required.
- Wallet is optional.
- Missing required fields produce an inline/snackbar user message, not a red error screen.
- There must be one primary save button for the AI flow.

## Post-save Refresh Contract

After successful AI save:

- Expense list refresh is triggered.
- Report totals refresh is triggered.
- Current month budget refresh is triggered.
- Navigation may return to the previous page or expenses list only after save success handling is complete.

The refresh path must not:

- Create mock expenses.
- Add artificial delay.
- Require app restart.
- Depend only on repository streams when an explicit refresh is available.

## Error Contract

Expected error behavior:

- AI gateway failures keep the input visible and usable.
- Retry appears only when the gateway state says retry is allowed.
- Save failures show a user-facing message.
- Validation failures identify missing amount/category.
- No exception should surface as Flutter red-screen UI in normal user actions.
