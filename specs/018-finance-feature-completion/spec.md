# Feature Specification: Finance Feature Completion

**Feature Branch**: `018-finance-feature-completion`
**Created**: 2026-05-29
**Status**: Draft
**Input**: Complete finance product features missing or mock-only in `new app`: categories management, recurring expenses, subscriptions, wallets, transfers, and related data wiring.

## Mandatory Agent Prerequisites

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

**Scope guard**: Finance data UI and repository wiring are in scope. Export screen is out of scope by user decision.

## User Scenarios & Testing

### User Story 1 - Manage Categories (Priority: P1)

As a user, I want to create, edit, archive, and choose categories so my expenses match my real life.

**Why this priority**: Expense entry depends on categories; `new app` has category bloc basics but no full category management screen.

**Independent Test**: Create category, edit icon/color/name, archive it, and verify add/filter/report screens update.

### User Story 2 - Recurring Payments And Subscriptions (Priority: P1)

As a user, I want recurring expense rules to drive subscription summaries and due reminders.

**Why this priority**: Subscriptions screen in `new app` is mock-only; reference app models recurring payments as the source of subscription insights.

**Independent Test**: Create a monthly recurring rule, see it in subscriptions, apply due item once, and verify no duplicate generation.

### User Story 3 - Wallets And Transfers (Priority: P2)

As a user, I want wallets/accounts and transfers to affect balances and expense payment sources.

**Why this priority**: `new app` shows wallet mock cards but lacks complete CRUD and transfer workflows.

**Independent Test**: Create wallet, add expense from wallet, transfer between wallets, and verify balances update.

## Requirements

### Functional Requirements

- **FR-001**: Category management MUST support create, edit, archive, icon, color, and default category seeding.
- **FR-002**: Add/edit expense MUST use real categories and wallet/payment sources, not mock lists.
- **FR-003**: Recurring expenses MUST support frequency, start/end date, next run date, active/archive state, and apply-once behavior.
- **FR-004**: Subscription center MUST derive active subscriptions from recurring expenses.
- **FR-005**: Wallets MUST support CRUD, archived state, balances, and assignment to expenses.
- **FR-006**: Transfers MUST support wallet-to-wallet movement without double-counting spending.
- **FR-007**: All finance surfaces MUST be localized and responsive for required mobile viewports.

### Key Entities

- **Category**: User-owned classification with icon, color, archived state.
- **Recurring Expense**: Rule that can generate or represent repeated payments.
- **Subscription Summary**: View model derived from recurring expenses.
- **Wallet Account**: User-owned account with type, currency, balance/opening balance.
- **Transfer**: Money movement between wallets.

## Success Criteria

- **SC-001**: A new user can create an expense with a default or custom category.
- **SC-002**: Subscription center contains no hardcoded mock subscription data.
- **SC-003**: Wallet balances update after expenses and transfers in tests.
- **SC-004**: Category/recurring/wallet screens pass 360x800, 375x812, and 390x844 checks in EN and AR.

## Assumptions

- Repository parity work from `specs/015-local-first-sync-parity` provides local and remote persistence.
- Export is intentionally not part of this feature.
- Existing `new app` visual language is preserved.
