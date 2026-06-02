# Feature Specification: Default Payment Method

**Feature Branch**: `[028-default-payment-method]`

**Created**: 2026-05-31

**Status**: Ready for planning

**Input**: Users must be able to add expenses without first creating a wallet. If the user does not write or choose a payment method, the app must use a configurable default payment method. The default must be available in settings and should initially be cash.

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

- `speckit-specify`: to define the user-facing payment method behavior.
- `speckit-plan`: to create implementation planning artifacts.

**Scope guard**: This is production app behavior, not a UI-only prototype. The feature may update Flutter UI, expense mapping, user settings, Firestore/local repository contracts, and tests. It must not add mock financial data or put secrets in mobile code.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Save Expense Without Wallet (Priority: P1)

As a user, I want to save an expense even if I have not created a wallet, so I can start tracking spending immediately.

**Why this priority**: Requiring a wallet before the first expense blocks the most important app action.

**Independent Test**: Open quick add with no wallets, enter valid expense details, save, and verify the expense is stored with a payment method and no wallet link.

**Acceptance Scenarios**:

1. **Given** the user has no wallets, **When** they save a quick expense, **Then** the expense is saved without requiring wallet creation.
2. **Given** the user has no wallets, **When** AI creates an expense draft, **Then** the user can confirm it without selecting a wallet.
3. **Given** an expense is saved without a wallet, **When** it appears in history/reports, **Then** it still shows the payment method clearly.

---

### User Story 2 - Use Default Payment Method When Missing (Priority: P1)

As a user, I want the app to choose my preferred payment method automatically when I do not mention one.

**Why this priority**: Most expense entries should be fast. The user should not be forced to repeat "cash" or "visa" every time.

**Independent Test**: Set default payment method to Visa, add a quick expense without choosing payment method, and verify the saved expense is Visa.

**Acceptance Scenarios**:

1. **Given** the default payment method is Cash, **When** the user saves an expense without choosing a method, **Then** the saved payment method is Cash.
2. **Given** the default payment method is Visa, **When** the user saves an expense without choosing a method, **Then** the saved payment method is Visa.
3. **Given** the default payment method is Wallet, **When** the user has no wallet, **Then** the expense is saved with payment method Wallet and no wallet link.

---

### User Story 3 - AI Detects Payment Method From Text (Priority: P1)

As a user, I want AI expense entry to detect payment method from my sentence when I write it.

**Why this priority**: AI should reduce manual edits and understand common MENA payment wording.

**Independent Test**: Parse sentences containing cash, visa/card, wallet, and transfer terms, then verify the draft payment method.

**Acceptance Scenarios**:

1. **Given** the user writes "دفعت 200 كاش أكل", **When** AI parses the text, **Then** the draft payment method is Cash.
2. **Given** the user writes "اشتريت بفيزا 500", **When** AI parses the text, **Then** the draft payment method is Visa.
3. **Given** the user writes "حولت 300", **When** AI parses the text, **Then** the draft payment method is Bank Transfer.
4. **Given** no payment words are present, **When** AI creates the draft, **Then** it uses the user's default payment method.

---

### User Story 4 - Manage Default In Settings (Priority: P2)

As a user, I want to choose the default payment method from settings so the app matches my habits.

**Why this priority**: Different users pay mostly by cash, card, wallet, or transfer.

**Independent Test**: Change the default payment method in settings, leave settings, reopen settings, and verify the selected value persists.

**Acceptance Scenarios**:

1. **Given** the user opens Settings, **When** they choose Default Payment Method, **Then** they see Cash, Visa/Card, Wallet, and Bank Transfer.
2. **Given** the user selects a method, **When** settings save successfully, **Then** new expenses use that method by default.
3. **Given** settings cannot be loaded, **When** the user adds an expense, **Then** the app falls back to Cash without crashing.

---

### User Story 5 - Link Wallet Only When Chosen (Priority: P2)

As a user with wallets, I want to link a wallet only when I intentionally choose one.

**Why this priority**: A payment method is not the same as a tracked wallet/account.

**Independent Test**: Add one expense with only Visa selected and another with a specific wallet selected. Verify only the second expense has wallet fields.

**Acceptance Scenarios**:

1. **Given** the user chooses Cash, Visa, Wallet, or Bank Transfer without selecting a wallet account, **When** they save, **Then** `walletAccountId` and `walletAccountName` stay empty.
2. **Given** the user selects an existing wallet account, **When** they save, **Then** the expense stores both the payment method and the wallet account link.
3. **Given** a wallet account is unavailable or deleted, **When** the user saves, **Then** the app saves the payment method and does not block on the missing wallet.

### Edge Cases

- User has no settings document yet.
- Settings document has an unknown legacy payment method value.
- AI output contains a wallet name that does not exist.
- AI output contains both card and wallet terms.
- The user changes payment method after AI fills the draft.
- The selected default method is Wallet but the user has no wallets.
- Firestore rules reject an invalid payment method string.
- Arabic RTL labels are longer than English labels on small screens.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow saving a valid expense without a wallet account.
- **FR-002**: Every saved expense MUST have a valid payment method.
- **FR-003**: The system MUST keep wallet account fields optional for expenses.
- **FR-004**: The system MUST provide a user setting for default payment method.
- **FR-005**: The default payment method MUST initially be Cash for new or incomplete settings.
- **FR-006**: Users MUST be able to choose Cash, Visa/Card, Wallet, or Bank Transfer as their default.
- **FR-007**: Quick expense entry MUST use the selected payment method if the user chooses one.
- **FR-008**: Quick expense entry MUST use the default payment method when the user does not choose one.
- **FR-009**: AI expense entry MUST use a payment method explicitly detected from text before falling back to the default.
- **FR-010**: AI expense entry MUST fall back to the user's default payment method when the text has no payment method.
- **FR-011**: If settings cannot be read, expense entry MUST fall back to Cash and continue safely.
- **FR-012**: Selecting a wallet account MUST remain optional and must not be required for Wallet payment method.
- **FR-013**: If a wallet account is selected, the expense MUST preserve the selected wallet account link.
- **FR-014**: Firestore/local persistence MUST accept expenses with payment method and empty wallet fields.
- **FR-015**: Settings persistence MUST save and restore the default payment method.
- **FR-016**: The UI MUST clearly communicate that wallet selection is optional.
- **FR-017**: The UI MUST support Arabic RTL and English LTR labels without clipping on required mobile widths.
- **FR-018**: The feature MUST not create fake wallets, fake payment accounts, or mock expense data to satisfy the flow.

### Key Entities

- **Payment Method**: The required way the expense was paid. Allowed values are Cash, Visa/Card, Wallet, and Bank Transfer.
- **Default Payment Method Setting**: A user preference stored in settings and used when an expense has no explicit method.
- **Wallet Account Link**: Optional expense metadata that references a tracked wallet/account only when chosen or matched confidently.
- **AI Expense Draft**: A reviewable expense draft that may include a detected payment method and optional wallet suggestion.
- **Expense**: A saved transaction that always has amount, date, currency, source, and payment method, with optional wallet fields.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user with zero wallets can save a quick expense successfully.
- **SC-002**: A user with zero wallets can confirm an AI-created expense successfully.
- **SC-003**: When no payment method is entered, the saved expense uses the user's default payment method in 100% of covered flows.
- **SC-004**: Changing default payment method in settings affects the next quick and AI expense without requiring app restart.
- **SC-005**: Wallet account fields are empty for expenses where the user did not choose a wallet account.
- **SC-006**: Existing wallet-linked expense behavior remains unchanged when the user selects a wallet.
- **SC-007**: Focused tests cover Cash, Visa/Card, Wallet, Bank Transfer, missing settings fallback, and no-wallet save.
- **SC-008**: No UI text overlaps on 360x800, 375x812, and 390x844 in Arabic and English.

## Assumptions

- Existing `PaymentMethod` values remain the source of truth.
- `defaultPaymentMethod` already exists in user settings and should be completed through UI and entry flows rather than replaced.
- Cash is the safest fallback for missing, corrupt, or unavailable settings.
- Wallet/account tracking is an optional advanced layer, not a prerequisite for expense tracking.
- Existing Firestore security rules already allow valid payment method values and optional wallet fields, but must be verified.
