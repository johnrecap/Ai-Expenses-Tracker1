# UI Contract: AI, Settings, Empty States, And Final QA

## Routes

- `/ai/advice`
- `/ai/history`
- `/ai/assistant`
- `/settings`
- `/not-found`

## Component Contracts

### ChatBubble

- Accepts chat view data and ownership state.
- Aligns user/assistant bubbles directionally.
- Supports Arabic RTL and English LTR.

### SuggestedPromptChip

- Accepts prompt label and local callback.
- Scrolls horizontally when prompts exceed width.

### AiAssistantSheet

- Uses native `GlassBottomSheet`.
- Contains messages, prompt chips, and input footer.
- Caps height and handles safe area.
- No network or AI service calls.

### SettingsRow

- Accepts icon, label, value, row type, and local toggle callback.
- Reused across all settings rows.
- No persistence.

### EmptyState

- Accepts title, body, icon, optional local CTA.
- Used for empty lists, no-results, and not-found-like surfaces where appropriate.

## Final QA Contract

Final QA must verify:

- Every detected Stitch screen has a native Flutter counterpart or approved placeholder.
- No forbidden dependency/import/use exists in implementation files.
- Required Flutter commands pass or blockers are documented.
- Required viewports and LTR/RTL directions are checked.
