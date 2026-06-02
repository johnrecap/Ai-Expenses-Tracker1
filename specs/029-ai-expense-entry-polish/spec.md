# Feature Specification: AI Expense Entry Polish

**Feature Branch**: `029-ai-expense-entry-polish`

**Created**: 2026-05-31

**Status**: Draft

**Input**: User reports that the AI expense text input looks wrong because text feels outside the field, the keyboard does not close after pressing enter, the save button is too low, and newly saved AI expenses do not update visible app data immediately.

## Mandatory Agent Prerequisites *(mandatory)*

Completed before drafting this specification:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Loaded relevant skills.

**Skills used**:

- `speckit-specify`: translate Mohamed's requested changes into a bounded feature spec.
- `speckit-plan`: create the implementation plan and design artifacts.
- `speckit-tasks`: create a dependency-ordered implementation task list.
- `flutter-fix-layout-issues`: guide the AI text input layout and overflow checks.

**Scope guard**: This is a production Flutter app. This feature is limited to the AI text expense entry screen, its AI input panel, save placement, keyboard behavior, and post-save refresh behavior. It must not introduce mock financial data, new AI provider secrets, or a new design language.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Type AI Expense Comfortably (Priority: P1)

As a user, I want the AI input box to look like a real input field, so that the text and hint stay clearly inside the field and the screen feels polished.

**Why this priority**: This is the first visual issue Mohamed reported. If the text field looks broken, the AI entry flow feels unreliable even before saving.

**Independent Test**: Open the AI text expense screen, type a normal expense sentence, and confirm the text stays visually inside the field with proper padding, focus state, and no clipping on small screens.

**Acceptance Scenarios**:

1. **Given** the AI text expense screen is open, **When** the field is empty, **Then** the hint appears inside a clearly bounded input area with comfortable padding.
2. **Given** the user types one or more lines, **When** the field has focus, **Then** the text remains inside the field and the focused state matches the app theme.
3. **Given** the keyboard is open, **When** the user presses the keyboard done/enter action, **Then** the keyboard closes and the app does not leave focus stuck in the field.

---

### User Story 2 - Save From The AI Area (Priority: P1)

As a user, I want the save button to appear directly under the AI result/review area, so I can save the AI-created expense without scrolling to the bottom of the whole form.

**Why this priority**: The current save button is separated from the AI result by category, payment, and manual fields, which makes the AI flow feel like a long manual form.

**Independent Test**: Parse an AI expense and confirm the save button is visible immediately under the AI widget/review area while still protecting against missing amount or category.

**Acceptance Scenarios**:

1. **Given** AI parsing returns a complete draft, **When** the suggestion is displayed, **Then** the save button appears immediately below the AI area.
2. **Given** the draft is missing required details, **When** the user tries to save, **Then** the app clearly tells the user what is missing without a red error page.
3. **Given** optional wallet information is missing, **When** the amount and category are valid, **Then** the expense can still be saved without requiring a wallet.

---

### User Story 3 - See Saved Expense Immediately (Priority: P1)

As a user, I want the home, expense list, budget, and reports data to update right after saving an AI expense, so I do not need to close and reopen the app.

**Why this priority**: A saved expense that does not appear immediately looks like the save failed or the database is broken.

**Independent Test**: Save an AI expense, return to the previous screen, and confirm the expense list and totals refresh in the same app session.

**Acceptance Scenarios**:

1. **Given** the user saves an AI expense successfully, **When** the save completes, **Then** the shared expense list refreshes immediately.
2. **Given** the saved expense belongs to the current month, **When** the user returns to Home or Reports, **Then** totals reflect the new expense without restarting the app.
3. **Given** repository streams are delayed or unavailable, **When** the save succeeds, **Then** the app still triggers an explicit refresh path.

---

### User Story 4 - Keep Mobile Layout Stable (Priority: P2)

As a user on Arabic or English mobile screens, I want the AI entry screen to stay readable and tappable, so I can complete the flow on small phones.

**Why this priority**: The app targets Egypt and MENA users and must work in Arabic RTL and English LTR.

**Independent Test**: Check the AI text expense screen at 360x800, 375x812, and 390x844 in LTR and RTL with keyboard open and closed.

**Acceptance Scenarios**:

1. **Given** a 360px wide screen, **When** the AI input, suggestion card, and save button are visible, **Then** no text overlaps or clips.
2. **Given** Arabic direction, **When** the user types and reviews a suggestion, **Then** alignment, action placement, and labels remain readable.

### Edge Cases

- Empty AI input should not parse or save.
- Multi-line AI text should not overflow or hide action buttons.
- Pressing done/enter should not add an unwanted blank line as the primary action.
- AI gateway errors should keep the input usable and show retry when allowed.
- Missing amount or category should block save with a clear message.
- Wallet absence must not block saving.
- Slow repository stream updates should not delay the visible refresh after save.
- Back/close navigation must not exit the whole app unexpectedly from an internal screen.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The AI input field MUST use a real input decoration or equivalent bounded input area with internal padding that matches existing app spacing and theme tokens.
- **FR-002**: The AI input text and hint MUST remain visually inside the field on 360x800, 375x812, and 390x844 screens.
- **FR-003**: The parse action and keyboard done/enter action MUST close the keyboard before or while processing the AI text.
- **FR-004**: The AI input field MUST visually separate text entry from secondary controls such as microphone and parse.
- **FR-005**: The AI save button MUST appear directly under the AI suggestion/review area, not after the full manual form.
- **FR-006**: The save action MUST prevent incomplete expenses and show a clear missing-fields message instead of a red error page.
- **FR-007**: Saving from AI text MUST not require a wallet account.
- **FR-008**: After successful AI save, the app MUST refresh shared expense data used by the expense list, home totals, reports, and current budget.
- **FR-009**: The feature MUST use real existing repositories and state, with no mock production data.
- **FR-010**: The feature MUST preserve Arabic RTL and English LTR readiness.
- **FR-011**: The feature MUST not add direct AI provider keys or move AI calls outside the existing gateway boundary.

### Key Entities

- **AI Input Field**: The user's natural-language expense text and its focus/keyboard state.
- **AI Draft Review**: The parsed amount, description, category, payment method, optional wallet, and missing-field state shown before save.
- **Post-save Refresh**: The app state update that makes newly saved expenses visible across list, home, budget, and reports.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On all required small mobile viewports, typed text and hint remain inside the AI input field with no visual clipping.
- **SC-002**: Pressing the keyboard done/enter action hides the keyboard in the AI entry flow.
- **SC-003**: A complete AI draft can be saved without scrolling past the manual details section.
- **SC-004**: A saved AI expense appears in visible app data during the same session without closing or reopening the app.
- **SC-005**: Focused tests for AI input behavior, save placement, and post-save refresh pass before implementation is marked complete.

## Assumptions

- The existing Cloudflare AI Gateway remains the AI boundary.
- The existing `AiExpenseEntryCubit` can keep owning parse/save unless implementation finds a smaller shared-save path.
- The current app theme, spacing, colors, and shared widgets remain the design source.
- No new backend endpoint is needed for this feature.
