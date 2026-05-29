# Feature Specification: Backend Integration & Production Architecture

**Feature Branch**: `008-backend-integration`

**Created**: 2026-05-28

**Status**: Draft

**Input**: Port the existing production backend logic from `Expense-Tracker-main` into the new redesigned app (`new app`), while preserving the new 25-screen UI and design system. Package: `expenses_tracker`. State: `flutter_bloc` + `go_router`. Backend: Firebase + VPS with runtime mode toggle. AI: Cloudflare Worker + Firebase Functions + Gemini. Features: auth, expenses, categories, budgets, reports, AI, settings, wallets, goals, subscriptions, ads, premium, guided tour, onboarding, notifications, exchange rates.

## Mandatory Agent Prerequisites

Before drafting this specification, the agent MUST:

- Read `AGENTS.md`.
- Read `.specify/memory/constitution.md`.
- Read `.agents/workflows/development.md`.
- Read `.agents/skill-matcher.json`.
- Search `.agents/skills/` and `.agent/skills/` for relevant skills.
- Load matching `SKILL.md` files and follow them.

**Skills used**: speckit-specify, speckit-plan, speckit-tasks, flutter-ui-from-design, flutter-build-responsive-layout, ui-only-prototype-guardrails (adapted for production scope).

**Scope guard**: This spec transitions the project from UI-only prototype to full production app with backend, Firebase, real auth, database, API calls, AI services, and persistence.

## User Scenarios & Testing

### User Story 1 - Authentication & Identity (Priority: P1)

A new user opens the app, sees the splash screen, goes through onboarding (language, currency, notifications), then signs up with email/password or Google Sign-In. An existing user logs in and is taken to the home dashboard. The user can view and edit their profile, change their display name, and delete their account with reauthentication.

**Why this priority**: Authentication is the gateway to all user-scoped data. Without auth, no expenses, budgets, or AI features can be personalized or persisted.

**Independent Test**: Can be fully tested by installing the app, completing onboarding, creating an account, logging out, and logging back in. The auth state must persist across app restarts.

**Acceptance Scenarios**:

1. **Given** a fresh install, **When** the user opens the app, **Then** they see splash -> onboarding -> auth gate.
2. **Given** the auth gate, **When** the user enters valid email/password, **Then** they are registered, logged in, and taken to the home dashboard.
3. **Given** the auth gate, **When** the user taps Google Sign-In, **Then** they are authenticated via Firebase and taken to the home dashboard.
4. **Given** a logged-in user, **When** they navigate to Account Profile, **Then** they can edit their display name and see their auth provider.
5. **Given** a logged-in user, **When** they request account deletion, **Then** they must reauthenticate and confirm before data is removed.

---

### User Story 2 - Expense Tracking (Priority: P1)

A user adds expenses manually (quick add), via AI text parsing ("I spent 50 dollars on groceries yesterday"), or via receipt photo. Expenses are saved to the backend (Firebase or VPS depending on runtime mode), appear in the expense list, and can be edited or deleted. The list supports filtering by date range, category, payment method, and search query.

**Why this priority**: Expense tracking is the core value proposition of the app. All other features (budgets, reports, AI) depend on expense data.

**Independent Test**: Can be fully tested by adding 5+ expenses via all three entry methods, verifying they appear in the list, applying filters, editing one, and deleting one.

**Acceptance Scenarios**:

1. **Given** the add expense screen, **When** the user fills amount, category, date, and notes, **Then** the expense is saved and appears in the list.
2. **Given** the AI text add screen, **When** the user types "coffee 5 dollars", **Then** the AI parses it and pre-fills the expense form for confirmation.
3. **Given** the receipt add screen, **When** the user captures a receipt, **Then** the AI extracts items/amounts and pre-fills the form.
4. **Given** the expense list, **When** the user applies a date filter, **Then** only matching expenses are shown.
5. **Given** an expense in the list, **When** the user taps edit, **Then** they can modify fields and save.

---

### User Story 3 - Categories & Budgets (Priority: P1)

A user manages expense categories (create, edit color/icon, delete). They set a monthly total budget and per-category budgets. The app tracks spending against budgets and shows progress indicators. When a budget is close to exceeded, the user receives visual warnings.

**Why this priority**: Budgeting is the primary financial control feature. Users need categories to organize expenses and budgets to control spending.

**Independent Test**: Can be fully tested by creating 5+ categories, setting a monthly budget, adding expenses that consume budget, and verifying budget progress updates.

**Acceptance Scenarios**:

1. **Given** the categories screen, **When** the user creates a new category with color and icon, **Then** it appears in the category list and add-expense dropdown.
2. **Given** the budgets screen, **When** the user sets a monthly budget of $1000, **Then** the budget is saved and progress shows 0%.
3. **Given** an active budget, **When** expenses totaling $800 are added, **Then** the budget progress shows 80% with a warning color.
4. **Given** category budgets, **When** a category exceeds 90% of its budget, **Then** a warning indicator appears.

---

### User Story 4 - Reports & Analytics (Priority: P2)

A user views financial reports showing spending by category, trends over time, and comparisons. They can drill down into specific categories to see related expenses. The app generates a monthly financial story narrative summarizing their spending behavior.

**Why this priority**: Reports provide insights that help users understand their financial patterns. This is a key retention feature.

**Independent Test**: Can be fully tested by adding expenses across multiple categories and months, then viewing reports, drilldowns, and the monthly story.

**Acceptance Scenarios**:

1. **Given** the reports screen with expense data, **When** the user views the chart, **Then** spending by category is displayed accurately.
2. **Given** a category in the report chart, **When** the user taps it, **Then** they see a drilldown of expenses in that category.
3. **Given** the monthly story screen, **When** the user views it, **Then** a narrative summary of their spending is displayed.
4. **Given** multi-currency expenses, **When** the user views reports, **Then** amounts are converted to the base currency using exchange rates.

---

### User Story 5 - AI-Powered Features (Priority: P2)

A user interacts with AI to add expenses via natural language, extract data from receipts, get spending advice, and query their expense history conversationally. AI usage is tracked with daily quotas. Free users have limited quotas; premium users have higher or unlimited quotas.

**Why this priority**: AI differentiation is a core product strategy. It reduces friction in expense entry and provides intelligent insights.

**Independent Test**: Can be fully tested by using each AI feature (text parse, receipt, advice, history query) and verifying quota enforcement.

**Acceptance Scenarios**:

1. **Given** the AI text add screen, **When** the user submits text, **Then** the AI gateway returns parsed fields within 3 seconds.
2. **Given** the AI advice screen, **When** the user requests advice, **Then** personalized spending recommendations are displayed.
3. **Given** a free user who has used their daily quota, **When** they try to use AI, **Then** they see a quota exceeded message with premium upgrade option.
4. **Given** the AI assistant sheet, **When** the user asks "How much did I spend on food last month?", **Then** the AI queries history and returns an answer.

---

### User Story 6 - Wallets & Subscriptions (Priority: P2)

A user manages multiple wallets/accounts (cash, bank, credit card). They can view balances per wallet. The subscription center tracks recurring payments, shows upcoming renewals, and calculates monthly subscription impact on budgets.

**Why this priority**: Wallets and subscriptions are advanced financial management features that increase user engagement and app value.

**Independent Test**: Can be fully tested by creating wallets, assigning expenses to wallets, viewing wallet balances, and adding subscriptions.

**Acceptance Scenarios**:

1. **Given** the wallets screen, **When** the user adds a wallet with name and currency, **Then** it appears in the list.
2. **Given** wallets with expenses, **When** the user views wallet details, **Then** balances are calculated correctly.
3. **Given** the subscription center, **When** the user adds a subscription, **Then** renewal dates and monthly impact are displayed.

---

### User Story 7 - Settings, Onboarding & Guided Tour (Priority: P2)

A user customizes app settings (language, currency, theme, notifications, security). First-time users see an onboarding flow and a guided product tour highlighting key features. The tour can be replayed from settings.

**Why this priority**: Settings control user experience. Onboarding and guided tour improve activation and retention metrics.

**Independent Test**: Can be fully tested by changing each setting, verifying persistence, completing onboarding, and running the guided tour.

**Acceptance Scenarios**:

1. **Given** the settings screen, **When** the user changes language to Arabic, **Then** the entire app switches to RTL Arabic immediately.
2. **Given** the settings screen, **When** the user enables app lock and sets a PIN, **Then** the app requires PIN on next launch.
3. **Given** a first-time install, **When** the user opens the app, **Then** onboarding flow is shown before auth gate.
4. **Given** the home dashboard, **When** the guided tour starts, **Then** spotlight overlays highlight key UI elements with explanation cards.

---

### User Story 8 - Monetization (Priority: P3)

A free user sees non-intrusive banner ads and has limited AI quotas. They can upgrade to Premium via in-app purchase to remove ads, increase AI quotas, and unlock advanced features. The app validates purchases through the backend.

**Why this priority**: Monetization is required for app sustainability. It must not degrade the core free experience.

**Independent Test**: Can be fully tested by verifying ads display for free users, purchase flow works, and premium features unlock after purchase.

**Acceptance Scenarios**:

1. **Given** a free user, **When** they view supported screens, **Then** banner ads are displayed unobtrusively.
2. **Given** the premium screen, **When** the user initiates purchase, **Then** the store flow completes and premium is unlocked.
3. **Given** a premium user, **When** they use AI features, **Then** higher or unlimited quotas apply.

---

### User Story 9 - Notifications & Exchange Rates (Priority: P3)

A user receives smart notifications for budget warnings, recurring expense reminders, and subscription renewals. Exchange rates are fetched daily and used for multi-currency conversion in reports and totals.

**Why this priority**: Notifications drive engagement. Exchange rates enable accurate multi-currency reporting for international users.

**Independent Test**: Can be fully tested by setting a low budget, adding expenses that exceed it, and verifying a notification is triggered. Exchange rates can be tested by adding expenses in different currencies.

**Acceptance Scenarios**:

1. **Given** a budget at 95% consumption, **When** a new expense exceeds the budget, **Then** a budget exceeded notification is triggered.
2. **Given** a recurring expense due tomorrow, **When** the scheduler runs, **Then** a reminder notification is shown.
3. **Given** expenses in USD and EUR, **When** the user views totals in SAR, **Then** amounts are converted using cached exchange rates.

---

### User Story 10 - VPS Sync & Data Migration (Priority: P3)

An advanced user or the app owner can switch the runtime mode from Firebase to VPS local-first. The app syncs data to a self-hosted PostgreSQL backend with offline-first support. A migration comparison mode allows verifying data parity before cutover.

**Why this priority**: VPS sync provides data independence from Firebase, lower costs at scale, and full data ownership. This is a strategic long-term feature.

**Independent Test**: Can be fully tested by switching to VPS mode, adding expenses, verifying sync to the server, pulling on a second device, and comparing with Firebase legacy.

**Acceptance Scenarios**:

1. **Given** the app in `firebaseLegacy` mode, **When** the runtime mode is switched to `vpsLocalFirst`, **Then** the app bootstraps from VPS and begins syncing.
2. **Given** the app in `vpsLocalFirst` mode, **When** the user adds an expense offline, **Then** it is queued and synced when online.
3. **Given** `migrationComparison` mode, **When** expenses are read, **Then** both Firebase and VPS results are compared and discrepancies flagged.

## Edge Cases

- What happens when Firebase Auth token expires mid-session? -> Silent refresh via Firebase SDK; if refresh fails, redirect to login.
- How does the app handle offline expense creation? -> Queue in local store; sync when connectivity returns. Show pending state clearly.
- What happens when AI gateway returns malformed JSON? -> Graceful fallback with error message; allow manual entry.
- How are duplicate expenses detected? -> Hash-based duplicate detection on amount + date + category; warn user before save.
- What happens during VPS sync conflict (same expense edited on two devices)? -> Last-write-wins with server revision; show sync conflict UI if needed.
- How does the app behave when exchange rates are stale (>24h)? -> Show stale indicator; use last known rate; do not block user actions.
- What happens if a premium purchase receipt is invalid? -> Do not unlock premium; show error; allow retry.
- How is user data handled during account deletion? -> Reauthenticate first; delete Firestore data; delete VPS data; delete Auth account; clear local storage.

## Requirements

### Functional Requirements

- **FR-001**: The app MUST support Firebase Authentication with email/password and Google Sign-In providers.
- **FR-002**: The app MUST persist user-scoped expense data to Firestore in `firebaseLegacy` mode.
- **FR-003**: The app MUST support a runtime mode toggle between `firebaseLegacy`, `vpsLocalFirst`, and `migrationComparison`.
- **FR-004**: The app MUST use `flutter_bloc` for state management and `go_router` for navigation.
- **FR-005**: The app MUST support Arabic RTL and English LTR with full localization.
- **FR-006**: The app MUST support adding expenses via manual entry, AI text parsing, and receipt image extraction.
- **FR-007**: The app MUST enforce AI usage quotas per user per day, with higher limits for premium users.
- **FR-008**: The app MUST support monthly budgets and per-category budgets with visual progress tracking.
- **FR-009**: The app MUST generate spending reports with category breakdowns, trends, and monthly narratives.
- **FR-010**: The app MUST support multiple wallets/accounts with per-wallet expense tracking.
- **FR-011**: The app MUST track recurring expenses and subscriptions with renewal notifications.
- **FR-012**: The app MUST support export to CSV, Excel, and PDF formats.
- **FR-013**: The app MUST show banner ads for free users and remove ads for premium users.
- **FR-014**: The app MUST support in-app purchases for premium upgrade with backend entitlement validation.
- **FR-015**: The app MUST send local notifications for budget warnings, recurring reminders, and subscription renewals.
- **FR-016**: The app MUST fetch and cache daily exchange rates for multi-currency conversion.
- **FR-017**: The app MUST support app lock with PIN and optional biometric authentication.
- **FR-018**: The app MUST provide a guided product tour for first-time users, replayable from settings.
- **FR-019**: The app MUST sync VPS data with offline-first local storage using a durable sync protocol.
- **FR-020**: The app MUST validate all user inputs (amount, category, date) with clear localized error messages.

### Key Entities

- **User**: Firebase Auth identity, display name, email, photo URL, provider, createdAt, premium status.
- **Expense**: id, userId, amount, currency, categoryId, date, paymentMethod, walletId, description, receiptImageUrl, createdAt, updatedAt, conversionSnapshot.
- **Category**: id, userId, name, color, icon, isDefault, createdAt.
- **Budget**: id, userId, amount, currency, month, year, alertThreshold, createdAt.
- **CategoryBudget**: id, userId, categoryId, amount, month, year, createdAt.
- **SavingGoal**: id, userId, name, targetAmount, currentAmount, currency, deadline, color, createdAt.
- **WalletAccount**: id, userId, name, type, currency, balance, icon, color, createdAt.
- **Subscription**: id, userId, name, amount, currency, frequency, nextRenewalDate, categoryId, createdAt.
- **RecurringExpense**: id, userId, name, amount, currency, categoryId, frequency, startDate, endDate, lastGeneratedDate, createdAt.
- **Settings**: userId, language, baseCurrency, theme, notificationsEnabled, budgetAlertsEnabled, appLockEnabled, biometricEnabled, aiQuota, createdAt, updatedAt.
- **AiActionLog**: id, userId, actionType, input, output, structuredJson, success, error, quotaUsed, createdAt.
- **ExchangeRate**: fromCurrency, toCurrency, rate, date, source, createdAt.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can complete onboarding and first expense entry in under 2 minutes.
- **SC-002**: AI text parsing returns structured results in under 3 seconds for 95% of inputs.
- **SC-003**: Expense list loads and filters 1000 expenses without perceptible lag (<500ms).
- **SC-004**: Budget warnings appear within 1 second of adding an expense that exceeds the threshold.
- **SC-005**: Sync to VPS completes within 2 seconds per batch of 50 changes on a stable connection.
- **SC-006**: App launch to interactive dashboard takes under 3 seconds after first install.
- **SC-007**: 100% of user-facing strings are localized in Arabic and English.
- **SC-008**: No data loss occurs during Firebase-to-VPS migration in comparison mode (100% parity).
- **SC-009**: Free users see ads on appropriate screens; premium users never see ads after purchase.
- **SC-010**: The app passes `flutter analyze` with zero errors and `flutter test` with 100% pass rate for implemented tests.

## Assumptions

- Firebase project is already configured and available (`ai-expenses-tracker-studio`).
- Cloudflare Worker AI gateway is deployed and accessible.
- VPS backend (`api.saeeddev.com`) is operational with PostgreSQL and sync endpoints.
- Google Play Console and AdMob accounts are set up for monetization.
- Users have stable internet for initial sync; offline mode is supported but not the primary use case.
- The existing 25-screen UI from the new app is preserved as the visual foundation.
- The `expenses_tracker` package name is used consistently across all imports.
