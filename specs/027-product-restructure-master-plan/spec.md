# Feature Specification: Product Restructure Master Plan

**Feature Branch**: `027-product-restructure-master-plan`

**Created**: 2026-05-31

**Status**: Draft

**Input**: User description: "اعمل الخطط الكامله للتعديلات ديه" after full product review and agent reports.

## Mandatory Agent Prerequisites *(mandatory)*

Before drafting this specification, the agent read:

- `AGENTS.md`
- `.specify/memory/constitution.md`
- `.agents/workflows/development.md`
- `.agents/MANDATORY_RULES.md`
- `.agents/skill-matcher.json`
- Relevant Spec Kit skills

**Skills used**:

- `speckit-specify`: convert the review into a user-facing feature specification.
- `speckit-plan`: structure implementation phases and verification gates.
- `speckit-tasks`: produce dependency-ordered task cards for agents.

**Scope guard**: This is a production Flutter app plan. It includes real Firebase Auth, Firestore, Cloudflare AI Gateway, local/Drift/VPS sync, notifications, exports, analytics, exchange rates, security, monetization, Arabic/English, and RTL/LTR. No mock data may remain in production user flows.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - New User Starts Correctly (Priority: P1)

A new user opens the app, chooses language, base currency, notification preferences, signs in or creates an account, and reaches the home screen only after required setup is complete.

**Why this priority**: If the first run is broken, every later feature can be skipped or misconfigured.

**Independent Test**: Create a new account, complete onboarding, close and reopen the app, and confirm the same settings are preserved.

**Acceptance Scenarios**:

1. **Given** a new authenticated user without settings, **When** the app starts, **Then** the user sees onboarding before home.
2. **Given** a completed user, **When** the app starts, **Then** the user goes to home without repeating onboarding.
3. **Given** a selected Arabic language, **When** onboarding completes, **Then** the app uses Arabic RTL.
4. **Given** a selected English language, **When** onboarding completes, **Then** the app uses English LTR.

---

### User Story 2 - User Adds Expenses From One Clear Entry (Priority: P1)

The user opens the home screen and uses one Add button to add an expense manually, by text AI, or by receipt when receipt scanning is truly available.

**Why this priority**: Adding expenses is the core job of the app. The old product had too many competing entry points.

**Independent Test**: From home, tap Add, choose Quick Add or AI Text, review the form, save a real expense, and see it appear in the expense list.

**Acceptance Scenarios**:

1. **Given** the user is on home, **When** they tap Add, **Then** one clear sheet opens with available choices.
2. **Given** receipt scanning is not fully wired, **When** the sheet opens, **Then** receipt is disabled or clearly marked unavailable.
3. **Given** AI text returns a draft, **When** required fields are missing, **Then** the app asks the user to complete them before save.
4. **Given** a saved expense, **When** the user opens the list, **Then** the expense appears with correct amount, currency, category, wallet, and date.

---

### User Story 3 - User Manages Real Expenses (Priority: P1)

The user views, filters, edits, and deletes real expenses without losing hidden fields such as owner, currency, wallet, payment method, or AI source.

**Why this priority**: The review found visual filters that do not filter and edit flows that can overwrite important data.

**Independent Test**: Add multiple expenses, filter by date/category/wallet/amount, edit one, and confirm all original metadata is preserved.

**Acceptance Scenarios**:

1. **Given** several expenses across months, **When** the user selects "This Month", **Then** only current-month expenses are shown.
2. **Given** an expense with wallet and currency, **When** the user edits its title or amount, **Then** wallet and currency remain correct.
3. **Given** no expenses match filters, **When** filters are applied, **Then** the app shows a helpful empty state.

---

### User Story 4 - User Understands Their Money (Priority: P1)

The user sees accurate home totals, reports, category details, monthly story, monthly budget, category budgets, saving goals, recurring expenses, and subscriptions.

**Why this priority**: Finance insight must be correct. Current screens sometimes show all-time totals as "This Month" or static numbers.

**Independent Test**: Create expenses in different months and categories, then confirm dashboard, reports, budgets, and category drilldown all reflect the selected period.

**Acceptance Scenarios**:

1. **Given** expenses in multiple months, **When** home opens, **Then** "This Month" uses current-month data only.
2. **Given** the user taps a category in reports, **When** drilldown opens, **Then** it shows the real expenses for that category.
3. **Given** a category budget exists, **When** spending approaches the limit, **Then** the budget screen and alerts show correct progress.
4. **Given** an active subscription, **When** subscriptions opens, **Then** it appears as a subscription and not as a generic recurring expense.

---

### User Story 5 - User Organizes Money Accounts (Priority: P2)

The user manages wallets/accounts, links expenses to wallets, and transfers money between wallets with balance changes reflected correctly.

**Why this priority**: Wallets exist but transfers and balance updates are incomplete.

**Independent Test**: Create two wallets, add an expense to one, transfer between wallets, and confirm both balances update correctly.

**Acceptance Scenarios**:

1. **Given** two wallets, **When** the user transfers money, **Then** the source decreases and destination increases.
2. **Given** insufficient source balance and strict balance mode, **When** the user tries to transfer, **Then** the app blocks or warns clearly.
3. **Given** an expense is saved, **When** the selected wallet is viewed, **Then** the expense impact is visible.

---

### User Story 6 - User Gets Honest AI Help (Priority: P2)

The user can use AI text parsing, receipt extraction, advice, assistant chat, and history only when they are backed by real services or clearly marked unavailable.

**Why this priority**: Mock AI advice/history damages trust in a finance app.

**Independent Test**: Use AI text, hit quota/auth/network errors, open advice/history, and confirm the app shows real results or honest empty/unavailable states.

**Acceptance Scenarios**:

1. **Given** AI quota is exhausted, **When** the user requests AI, **Then** the app explains the daily limit.
2. **Given** AI advice has no real data, **When** advice opens, **Then** it shows an empty state instead of fake advice.
3. **Given** AI history has no records, **When** history opens, **Then** it shows no history instead of sample chat.

---

### User Story 7 - User Controls Account, Security, Settings, And Premium (Priority: P2)

The user can edit account profile, delete account with reauthentication, enable app lock with PIN/biometric, change settings, and understand free/premium status without fake purchase behavior.

**Why this priority**: Account, security, and premium screens currently include no-op buttons and partial security enforcement.

**Independent Test**: Open settings, navigate to profile, enable PIN, background the app, return and unlock, then verify premium buttons are either real or unavailable.

**Acceptance Scenarios**:

1. **Given** app lock is enabled, **When** the app returns from background, **Then** the user must unlock before using financial screens.
2. **Given** delete account is requested, **When** reauthentication is required, **Then** the app asks for it and does not fake deletion.
3. **Given** purchases are not production-ready, **When** premium opens, **Then** upgrade is disabled or marked unavailable.

---

### User Story 8 - App Services Are Reliable And Private (Priority: P3)

Notifications, export, analytics, exchange rates, Firestore rules, local sync, VPS sync, and AI gateway contracts behave truthfully and do not leak sensitive data.

**Why this priority**: These services affect trust, privacy, and data correctness, but some are partial or unsafe on failure.

**Independent Test**: Schedule notifications, export a period, simulate exchange-rate failure, run Firestore rules tests, and exercise local/VPS sync contract tests.

**Acceptance Scenarios**:

1. **Given** exchange rates fail, **When** conversion is requested, **Then** the app does not silently use `1.0` unless currencies match.
2. **Given** analytics is enabled, **When** events are sent, **Then** raw amounts, notes, names, and descriptions are not sent.
3. **Given** VPS sync mode is selected, **When** pull and push run, **Then** local data changes are applied and conflicts are handled.

### Edge Cases

- User loses internet during onboarding save, AI parsing, or sync.
- User has no categories, wallets, budgets, goals, or expenses yet.
- Existing Firestore settings documents are missing new fields.
- Arabic text is long on 360x800 screens.
- User switches language after onboarding.
- User edits an AI-created expense.
- Receipt AI is not available or quota is exhausted.
- Notification permission is denied.
- Exchange-rate provider fails or returns stale data.
- Existing fake/mock data must not appear as real user data.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST route new and returning users according to authentication and onboarding completion state.
- **FR-002**: The app MUST persist language, base currency, and notification choices without overwriting unrelated settings.
- **FR-003**: The app MUST apply Arabic RTL and English LTR based on saved preference.
- **FR-004**: Home MUST expose one primary Add entry point.
- **FR-005**: Quick add MUST save real expenses with the displayed currency and selected wallet/category.
- **FR-006**: AI text add MUST use the secure AI gateway path and require user review before save.
- **FR-007**: Receipt add MUST use the real receipt extraction path or be visibly unavailable.
- **FR-008**: Production screens MUST NOT show mock financial data, fake AI history, fake advice, fake premium status, or fake purchases.
- **FR-009**: Expense filters MUST change the real expense list results.
- **FR-010**: Edit expense MUST preserve existing hidden fields unless the user changes them.
- **FR-011**: Dashboard and reports MUST use the selected/current period rather than all-time totals when labeled as monthly.
- **FR-012**: Report drilldown MUST open real expenses for the selected category.
- **FR-013**: Monthly and category budgets MUST use real budget records and real spending for the relevant period.
- **FR-014**: Saving goals MUST support create, view, edit, update progress, and delete or archive.
- **FR-015**: Recurring expenses and subscriptions MUST be distinct user concepts.
- **FR-016**: Wallet transfers MUST update the affected wallet balances or clearly document balance behavior.
- **FR-017**: Category aliases MUST be manageable and usable by AI/category matching.
- **FR-018**: AI advice, assistant, and history MUST be backed by real data/services or honest empty/unavailable states.
- **FR-019**: Settings rows MUST either perform a real action or clearly show that the feature is unavailable.
- **FR-020**: App lock MUST be enforced when the app resumes after the configured lock condition.
- **FR-021**: PIN changes MUST require current PIN or biometric confirmation.
- **FR-022**: Account deletion MUST require reauthentication when needed and must not pretend to delete data.
- **FR-023**: Premium purchase and ads MUST be real verified flows or disabled/unavailable.
- **FR-024**: Notifications MUST respect user settings and platform permission state.
- **FR-025**: Export MUST include the selected period and relevant fields without leaving confusing incomplete output.
- **FR-026**: Analytics MUST avoid sending raw financial values, notes, names, or descriptions.
- **FR-027**: Exchange-rate failure MUST not silently produce incorrect conversions.
- **FR-028**: Firestore rules and app serialization MUST agree on allowed fields and enum values.
- **FR-029**: Local/Drift/VPS sync MUST have a consistent push/pull contract before being presented as working.
- **FR-030**: Verification MUST use scoped analyzer/test commands for touched files and documented focused checks, not a broad cleanup pass unless explicitly requested.

### Key Entities *(include if feature involves data)*

- **User Setup State**: Language, currency, notifications, onboarding completion, and settings load state.
- **Expense Entry Draft**: User-entered or AI-parsed draft requiring review before save.
- **Expense**: Real saved spending record with amount, currency, category, wallet, owner, source, date, and notes.
- **Category Alias**: User-managed words that map merchants or phrases to a category.
- **Wallet Transfer**: Movement of money from one wallet to another with date, amount, source, destination, and balance effect.
- **Monthly Budget**: Spending cap for a period and currency.
- **Category Budget**: Spending cap for a category within a period.
- **Financial Insight**: Report, story, alert, or advice derived from real user data.
- **AI Request Record**: Metadata for AI calls, quota, status, and history without storing unsafe raw secrets.
- **Security State**: App lock, PIN status, biometric preference, last background time, and unlock status.
- **Subscription Entitlement**: Free/premium status verified by a trusted source.
- **Sync Change**: Local change queued for remote sync with operation, timestamp, status, and conflict result.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new user can complete setup and reach home without skipping required choices.
- **SC-002**: A returning user with completed setup reaches home in one startup path without repeating onboarding.
- **SC-003**: From home, adding a quick expense or AI text expense requires no more than two taps before the entry form/draft is visible.
- **SC-004**: No production screen presents mock data as real user financial data.
- **SC-005**: Monthly dashboard, reports, and budgets match the same date period in focused test data.
- **SC-006**: Expense edit preserves owner, currency, wallet, payment method, and source unless deliberately changed.
- **SC-007**: AI quota/auth/network failures display clear user messages.
- **SC-008**: Arabic RTL and English LTR render without critical overflow on 360x800, 375x812, and 390x844.
- **SC-009**: Firestore rules accept valid app writes for all planned expense sources and reject invalid ownership.
- **SC-010**: Local/VPS sync contract tests prove push and pull use the same operation names and apply pulled data locally.

## Assumptions

- Firebase Auth remains identity provider.
- Firestore remains primary app data backend until VPS sync is made production-ready.
- Cloudflare AI Gateway is the only production path for AI provider calls.
- Features not backed by real services must be hidden, disabled, or clearly labeled unavailable.
- The previous Smart Add work in `specs/025-smart-add-entry/` is the current starting point for home add entry.
- The previous AI foundation work in `specs/024-real-ai-expense-refactor/` is partially complete and should be continued rather than restarted.
- The startup/onboarding work in `specs/026-startup-onboarding-settings/` remains the source plan for the first-run flow.
