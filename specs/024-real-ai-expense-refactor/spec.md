# Feature Specification: Real AI Expense Refactor

**Feature Branch**: `[024-real-ai-expense-refactor]`

**Created**: 2026-05-31

**Status**: Draft

**Input**: User description: "Fix the UI, especially AI expense entry from natural language, remove all mock data, and make every visible app feature work with real user data."

## Mandatory Agent Prerequisites *(mandatory)*

Before drafting this specification, the agent completed the required first-read gate:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/MANDATORY_RULES.md`.
- Read `.agents/skill-matcher.json`.
- Searched installed skills for relevant workflows.
- Loaded matching `SKILL.md` files.

**Skills used**:

- `speckit-specify`: to turn Mohamed's product request into a testable feature specification.
- `speckit-plan`: to prepare the implementation planning phase after the spec.
- `speckit-tasks`: to generate dependency-ordered implementation tasks after the plan.
- `flutter-apply-architecture-best-practices`: to shape the refactor around clear UI, logic, and data responsibilities.
- `flutter-setup-localization`: to plan correct Arabic/English and RTL/LTR behavior.
- `flutter-use-http-package`: to plan safe client-to-gateway communication for real AI actions.
- `flutter-fix-layout-issues`: to plan UI cleanup for narrow mobile screens and bottom sheets.
- `dart-run-static-analysis`: to require analyzer and test verification.

**Scope guard**: This feature explicitly amends the older UI-only prototype scope. The current project constitution defines this app as a production Flutter expense tracker. For this feature, mock data is out of scope, and real authenticated user data, secure AI gateway usage, persistence, and verification are in scope.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add Expense With AI Text (Priority: P1)

As a signed-in user, I want to type a natural sentence such as "دفعت 250 جنيه أكل امبارح" and see a clear draft expense that I can review, correct, and save.

**Why this priority**: This is the highest-value feature Mohamed called out directly. It must work reliably because it turns the app from a manual tracker into an AI-assisted tracker.

**Independent Test**: Can be tested by typing an Arabic and an English expense sentence, confirming the shown amount, category, date, currency, and note, then saving and seeing the expense in the real expenses list.

**Acceptance Scenarios**:

1. **Given** a signed-in user with at least one category and wallet, **When** the user enters an Arabic spending sentence, **Then** the app shows a reviewable draft with amount, currency, category, date, wallet, and description before saving.
2. **Given** the AI result is incomplete, **When** amount, category, wallet, or date is missing, **Then** the app clearly asks the user to fill the missing fields and does not save until required data is valid.
3. **Given** the user edits the draft, **When** the user taps save, **Then** the saved expense uses the user's corrected values, not the original AI suggestion.
4. **Given** the AI service is unavailable or the daily limit is reached, **When** the user tries to parse text, **Then** the app shows a helpful message and allows manual entry without losing the typed text.

---

### User Story 2 - No Mock Data Anywhere (Priority: P1)

As a real user, I want every screen to show my own data or a useful empty state, never fake transactions, fake wallets, fake goals, fake subscriptions, or fake AI chat messages.

**Why this priority**: Mock data creates false confidence and makes the app look working when the real flows are broken.

**Independent Test**: Can be tested with a brand-new account and an account with real saved data. The new account must show empty states; the existing account must show only that user's data.

**Acceptance Scenarios**:

1. **Given** a new account with no expenses, **When** the user opens dashboard, expenses, reports, budgets, wallets, goals, subscriptions, AI history, and settings, **Then** no fake financial entries appear.
2. **Given** an account with real saved expenses, **When** the user opens dashboard, expenses, reports, and budgets, **Then** totals and lists are based only on that user's saved data.
3. **Given** a screen has no data yet, **When** the user opens it, **Then** the screen shows a clear empty state and the next useful action.

---

### User Story 3 - Consistent UI For Expense Entry (Priority: P2)

As a user, I want quick add, manual add, AI text add, receipt add, and edit expense screens to feel like one consistent flow.

**Why this priority**: The current experience has repeated panels and inconsistent states. Consistency reduces mistakes when users record money.

**Independent Test**: Can be tested by opening every add/edit expense path and confirming shared layout, validation, save behavior, and error messages.

**Acceptance Scenarios**:

1. **Given** the user opens any expense entry mode, **When** required data is missing, **Then** the same validation style and message pattern appears.
2. **Given** the user switches between manual and AI-assisted entry, **When** fields are filled or corrected, **Then** the app keeps the user's input and does not unexpectedly reset valid values.
3. **Given** the user saves an expense from any entry mode, **When** save succeeds, **Then** the app returns to the correct place and the new or updated expense is visible.

---

### User Story 4 - Arabic, English, RTL, And LTR Work Correctly (Priority: P2)

As a MENA user, I want the app to fully respect Arabic and English without mixed labels, wrong icon direction, clipped text, or broken mobile layouts.

**Why this priority**: Egypt/MENA users are a primary audience, and broken RTL or mixed language makes the app feel untrustworthy.

**Independent Test**: Can be tested by switching between Arabic and English, then checking all primary screens at narrow mobile sizes.

**Acceptance Scenarios**:

1. **Given** the user chooses Arabic, **When** the app displays navigation, settings, forms, and AI expense flows, **Then** text is Arabic and direction is right-to-left.
2. **Given** the user chooses English, **When** the same screens appear, **Then** text is English and direction is left-to-right.
3. **Given** the device width is narrow, **When** long Arabic labels or AI messages appear, **Then** content wraps cleanly without hiding buttons or overlapping fields.

---

### User Story 5 - Every Visible Action Works Or Is Clearly Disabled (Priority: P3)

As a user, I want each visible button, menu item, and screen action to either work with real behavior or be hidden/disabled with a clear reason.

**Why this priority**: A production app should not contain dead buttons, fake actions, or placeholder screens.

**Independent Test**: Can be tested by tapping every visible primary action on the main screens and confirming that it succeeds, opens the correct flow, or is intentionally unavailable with a clear message.

**Acceptance Scenarios**:

1. **Given** the user opens the dashboard, expenses, reports, budgets, wallets, goals, subscriptions, AI, account, and settings, **When** the user taps primary and secondary actions, **Then** each action has a real result or a clear unavailable state.
2. **Given** a feature depends on required setup, **When** that setup is missing, **Then** the app explains what the user must do next.

### Edge Cases

- The AI returns a valid amount but no category.
- The AI returns a category name that does not exist for the user.
- The sentence contains multiple possible amounts.
- The sentence contains no currency.
- The user has no wallet yet.
- The user is offline or loses connection during AI parsing or saving.
- The user's session expires while using AI.
- The user switches language while on an expense form.
- Arabic text is long enough to overflow on 360px-wide screens.
- The AI limit is reached before parsing succeeds.
- A saved expense is deleted or changed from another device while the current screen is open.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST not show mock financial data in production user flows.
- **FR-002**: The app MUST show empty states when the signed-in user has no data for a screen.
- **FR-003**: The app MUST show only the signed-in user's real saved financial data.
- **FR-004**: Users MUST be able to enter expense text in Arabic or English and receive a reviewable draft expense.
- **FR-005**: The app MUST require user confirmation before saving an AI-generated expense.
- **FR-006**: The app MUST allow users to edit AI-generated amount, currency, category, date, wallet, and description before saving.
- **FR-007**: The app MUST block saving if required fields are missing or invalid.
- **FR-008**: The app MUST preserve the user's typed text when AI parsing fails.
- **FR-009**: The app MUST avoid placing AI provider secrets or shared gateway secrets inside the mobile app.
- **FR-010**: The app MUST use authenticated user identity when requesting AI actions.
- **FR-011**: The app MUST not print secrets, prompts, raw financial text, or AI response bodies in logs.
- **FR-012**: Expense entry screens MUST use one consistent review, validation, save, success, and failure pattern.
- **FR-013**: Dashboard, expenses, reports, budgets, wallets, goals, subscriptions, AI history, account, and settings MUST either work with real behavior or show a clearly intentional unavailable state.
- **FR-014**: The app MUST respect the user's selected language across app restart.
- **FR-015**: Arabic screens MUST use right-to-left layout and English screens MUST use left-to-right layout.
- **FR-016**: Directional icons, navigation, rows, and bottom sheets MUST mirror correctly between Arabic and English.
- **FR-017**: All primary screens MUST avoid text overlap, clipped labels, and hidden action buttons at common narrow phone sizes.
- **FR-018**: The app MUST provide user-friendly messages for AI quota, connection, authentication, parsing, and save failures.
- **FR-019**: Existing saved data MUST remain readable after the refactor.
- **FR-020**: The refactor MUST preserve the existing visual identity unless Mohamed approves a design change.

### Key Entities *(include if feature involves data)*

- **User Data State**: Represents whether the signed-in user has expenses, wallets, budgets, categories, goals, subscriptions, AI history, and settings data.
- **Expense Text Input**: The sentence typed by the user before AI parsing.
- **AI Expense Draft**: A temporary review item containing suggested amount, currency, category, date, wallet, and description before saving.
- **Expense**: A confirmed financial record saved by the user.
- **Category**: A user-selectable expense type used for grouping and reports.
- **Wallet**: The payment source used for an expense.
- **Empty State**: A screen state shown when real data does not exist yet.
- **Language Preference**: The user's selected Arabic, English, or system language behavior.
- **Action Availability State**: Whether a visible feature is ready, needs setup, temporarily unavailable, or intentionally disabled.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new user account shows zero fake financial entries across all primary screens.
- **SC-002**: A user can complete AI text expense entry from typing to saved expense in under 60 seconds when the AI service is available.
- **SC-003**: At least 90% of common Arabic and English expense phrases tested produce a draft with amount and date, or a clear missing-field prompt.
- **SC-004**: 100% of AI-generated expenses require user confirmation before saving.
- **SC-005**: 100% of primary visible actions either complete successfully, navigate to the correct flow, or show a clear unavailable/setup message.
- **SC-006**: Arabic and English primary screens show no text overlap or hidden required buttons at 360x800, 375x812, and 390x844.
- **SC-007**: No mobile build artifact includes `.env` as an app asset.
- **SC-008**: App logs contain no secrets, raw AI prompts, raw financial text, or raw AI response bodies during normal and failure flows.
- **SC-009**: Existing expenses, wallets, categories, budgets, and settings remain visible and usable after the refactor.
- **SC-010**: Automated Flutter checks pass or any remaining failures are documented with exact file names and reasons.

## Assumptions

- Mohamed wants to keep the current app and improve it instead of starting a new project.
- The current visual identity should be preserved unless Mohamed later approves a redesign.
- Firebase Authentication remains the user identity source.
- Existing saved user data must be preserved.
- The secure AI gateway is the required path for AI requests.
- New users may start with no data, so empty states are a normal product state, not an error.
- Category and wallet setup may be required before saving a complete expense.
- Receipt scanning can be treated as a real feature only if the secure AI gateway supports it; otherwise it must be clearly marked unavailable instead of faked.
