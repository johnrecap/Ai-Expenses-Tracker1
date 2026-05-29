# Feature Specification: Wallets And Subscriptions

**Feature Branch**: `006-wallets-subscriptions`

**Created**: 2026-05-28

**Status**: Draft pending approval

**Input**: Rebuild wallet/account and subscriptions center exports as native UI-only Flutter screens.

## Mandatory Agent Prerequisites

- `AGENTS.md` was read.
- `.specify/memory/constitution.md` was read.
- `.agents/workflows/development.md` was read.
- `.agents/skill-matcher.json` was read.
- Relevant skills were searched in `.agents/skills/` and `.agent/skills/`.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

**Scope guard**: Wallet and subscription screens are static visual surfaces only. No bank connection, Plaid, billing, payment, subscription API, backend, database, persistence, WebView, remote logos, or HTML rendering.

## User Scenarios & Testing

### User Story 1 - View Wallets And Accounts (Priority: P1)

As a user, I want to view account cards and transfer preview rows so I can inspect mock balances.

**Why this priority**: Wallets are a main financial surface and validate account cards, balance formatting, and bottom navigation.

**Independent Test**: Open `/wallets` with mock wallet data and verify account cards render at required widths.

**Acceptance Scenarios**:

1. **Given** mock wallets, **When** `/wallets` opens, **Then** wallet cards and transfer preview render without bank integrations.
2. **Given** an add wallet action, **When** it is tapped, **Then** only local visual feedback or placeholder navigation occurs.

---

### User Story 2 - View Subscriptions (Priority: P1)

As a user, I want a subscriptions center so I can review recurring mock expenses.

**Why this priority**: Subscriptions screen validates recurring expense cards, summary cards, and AI insight reuse without billing integrations.

**Independent Test**: Open `/subscriptions` and verify summary, subscription cards, and insight render from mock data.

**Acceptance Scenarios**:

1. **Given** mock subscriptions, **When** `/subscriptions` opens, **Then** subscription cards render with next billing and status.
2. **Given** an action like add/review subscription, **When** it is tapped, **Then** no billing or remote service is called.

### Edge Cases

- Remote brand logos from HTML must not be used at runtime.
- Account grid can overflow at 360px.
- Add wallet/subscription actions must not imply persistence.
- Balance and recurring amounts can overflow if unconstrained.
- Bank/billing packages are forbidden.

## Requirements

### Functional Requirements

- **FR-001**: `/wallets` MUST render wallet/account cards from static mock data.
- **FR-002**: `/wallets` MUST render transfer preview rows from static mock data.
- **FR-003**: `/subscriptions` MUST render subscription summary and cards from static mock data.
- **FR-004**: Wallet and subscription actions MUST be local-only or placeholder-only.
- **FR-005**: Brand/account visuals MUST use local icons, initials, or approved local assets only.
- **FR-006**: Layouts MUST fit 360x800, 375x812, and 390x844 in LTR and RTL.
- **FR-007**: The feature MUST NOT add bank, billing, payment, backend, API, database, persistence, remote image, WebView, or HTML rendering dependencies.

### Key Entities

- **WalletCardViewData**: Wallet ID, name, type, balance, currency, trend, visual icon.
- **TransferPreview**: Source, destination, amount, date label, status.
- **SubscriptionCardViewData**: Vendor, recurring amount, next billing date, status, visual identity.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Wallets and subscriptions screens render without overflow at required viewports.
- **SC-002**: Tests render all mock wallet and subscription statuses.
- **SC-003**: Forbidden search has zero implementation hits for bank, billing, payment, backend, API, persistence, WebView, remote logos, or HTML rendering.
- **SC-004**: Add/review actions are verified as local-only or placeholder-only.

## Assumptions

- Foundation mock wallets and subscriptions exist or are extended statically.
- Remote logo URLs in exports are replaced with local initials/icons.
