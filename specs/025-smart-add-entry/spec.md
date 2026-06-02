# Feature Specification: Smart Add Entry

**Feature Branch**: `[025-smart-add-entry]`

**Created**: 2026-05-31

**Status**: Draft

**Input**: Replace the current multiple floating add/AI entry points on the home screen with one clear smart add entry that opens the correct expense entry choices.

## Mandatory Agent Prerequisites *(mandatory)*

Before drafting this specification, the agent completed the required first-read gate:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/skill-matcher.json`.
- Searched installed skills for relevant workflows.
- Loaded matching `SKILL.md` files.

**Skills used**:

- `speckit-specify`: to define the smart add feature behavior.
- `speckit-plan`: to create implementation planning artifacts.
- `speckit-tasks`: to create executable task steps.
- `flutter-ui-from-design`: to keep the UI aligned with existing theme and components.

**Scope guard**: This feature changes the home-screen add-entry experience only. It must preserve the current design language and must not introduce mock data, mobile secrets, or fake AI behavior.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - One Clear Add Button (Priority: P1)

As a user on the home screen, I want one obvious add button so I know where to start when recording an expense.

**Why this priority**: The current home screen has multiple add/AI entry points, which can confuse users.

**Independent Test**: Open the home screen and confirm there is one primary add button, not stacked add and AI floating buttons.

**Acceptance Scenarios**:

1. **Given** the user is on the home screen, **When** the screen loads, **Then** one primary add entry button is visible.
2. **Given** the user sees the add button, **When** the user taps it, **Then** a clear choice sheet/menu appears.

---

### User Story 2 - Choose The Right Add Method (Priority: P1)

As a user, I want the add button to show clear choices: AI text, quick add, full add, and receipt only if available.

**Why this priority**: The user should choose the right entry method without understanding route names or hidden feature states.

**Independent Test**: Tap the add button and verify each option opens the correct flow or clearly says it is unavailable.

**Acceptance Scenarios**:

1. **Given** the add choices are open, **When** the user taps AI text, **Then** the AI expense text flow opens.
2. **Given** the add choices are open, **When** the user taps quick add, **Then** the quick add flow opens.
3. **Given** receipt scanning is not fully ready, **When** receipt appears, **Then** it is disabled or marked unavailable instead of pretending to work.

---

### User Story 3 - Keep AI Assistant Separate From Add Expense (Priority: P2)

As a user, I want the AI assistant button to mean general help, while AI expense entry is inside the add menu.

**Why this priority**: AI assistant and AI expense entry are different actions and should not compete visually.

**Independent Test**: Home top bar AI opens assistant/help; add menu AI option opens expense entry.

**Acceptance Scenarios**:

1. **Given** the user taps the top-bar AI icon, **When** the sheet opens, **Then** it is clearly an assistant/help action.
2. **Given** the user taps add then AI text, **When** the flow opens, **Then** it is clearly for creating an expense.

---

### User Story 4 - Works In Arabic, English, And Narrow Screens (Priority: P2)

As a MENA user, I want the add menu to fit Arabic and English labels without overlap.

**Why this priority**: The home screen is used constantly and must be reliable on small phones.

**Independent Test**: Check the add button and menu at 360x800, 375x812, and 390x844 in Arabic RTL and English LTR.

**Acceptance Scenarios**:

1. **Given** Arabic is active, **When** the add menu opens, **Then** labels and icons align right-to-left correctly.
2. **Given** English is active, **When** the add menu opens, **Then** labels and icons align left-to-right correctly.
3. **Given** the phone is narrow, **When** the menu opens, **Then** no text overlaps or action is hidden.

### Edge Cases

- The user has no categories yet.
- The user has no wallet yet.
- The AI text feature is temporarily unavailable.
- Receipt scanning is not ready.
- The user opens the add menu then dismisses it.
- The user taps add repeatedly.
- The screen is in Arabic RTL.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The home screen MUST show one primary add expense entry point.
- **FR-002**: The home screen MUST remove the stacked add and AI floating buttons pattern.
- **FR-003**: The add entry point MUST open a choice menu or sheet with clear add methods.
- **FR-004**: The first choice SHOULD be AI text expense entry when available.
- **FR-005**: Quick add MUST remain available from the add choices.
- **FR-006**: Receipt entry MUST not appear as a working action unless it is actually wired to real behavior.
- **FR-007**: Unavailable add methods MUST be disabled, hidden, or clearly labelled as unavailable.
- **FR-008**: The AI assistant top-bar action MUST remain separate from AI expense entry.
- **FR-009**: Add choices MUST use existing colors, spacing, typography, radii, and shared components.
- **FR-010**: Add choices MUST support Arabic RTL and English LTR.
- **FR-011**: Add choices MUST avoid text clipping or hidden buttons at 360x800, 375x812, and 390x844.
- **FR-012**: Add choices MUST navigate using app route constants, not hardcoded path strings.

### Key Entities

- **Smart Add Button**: The single primary add entry point on the home screen.
- **Add Choice**: One selectable method such as AI text, quick add, full add, or receipt.
- **Availability State**: Whether each add choice is ready, needs setup, or unavailable.
- **Add Choice Sheet**: The menu/sheet that displays add methods.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The home screen has exactly one primary add entry button.
- **SC-002**: Users can reach AI text expense entry from the home screen in no more than two taps.
- **SC-003**: Users can reach quick add from the home screen in no more than two taps.
- **SC-004**: Receipt entry is not presented as working unless its real flow is available.
- **SC-005**: The add menu has no text overlap or hidden required actions at 360x800, 375x812, and 390x844 in Arabic and English.
- **SC-006**: Route tests confirm each add choice opens the intended destination or unavailable state.

## Assumptions

- The current visual identity stays unchanged.
- The smart add menu should be implemented as a bottom sheet or compact action menu using existing glass/card style.
- AI text is the preferred add method, but quick add remains important for speed.
- The broader secure AI refactor in `024-real-ai-expense-refactor` may update the target AI flow later; this feature should route to the canonical AI text route.

