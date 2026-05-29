# Feature Specification: Dashboard And Expenses

**Feature Branch**: `003-dashboard-expenses`

**Created**: 2026-05-28

**Status**: Draft pending approval

**Input**: Rebuild dashboard, expenses list, and expense filters bottom sheet as native UI-only Flutter screens.

## Mandatory Agent Prerequisites

- `AGENTS.md` was read.
- `.specify/memory/constitution.md` was read.
- `.agents/workflows/development.md` was read.
- `.agents/skill-matcher.json` was read.
- Relevant skills were searched in `.agents/skills/` and `.agent/skills/`.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

**Scope guard**: Dashboard and expense views use static mock data and local UI state only. No backend, database, API calls, persistence, WebView, or HTML rendering.

## User Scenarios & Testing

### User Story 1 - View Dashboard Summary (Priority: P1)

As a user, I want to see my financial dashboard summary so I can understand my spending at a glance.

**Why this priority**: The dashboard is the primary app home and validates app shell, metric cards, insight cards, transaction preview, and bottom navigation.

**Independent Test**: Open `/home` with mock data and verify all dashboard sections render at required widths in LTR and RTL.

**Acceptance Scenarios**:

1. **Given** mock user and expense data, **When** `/home` opens, **Then** the dashboard shows greeting, metrics, AI insight, recent transactions, and bottom nav.
2. **Given** a 360px viewport, **When** large amounts render, **Then** text does not overflow.

---

### User Story 2 - Browse Expenses (Priority: P1)

As a user, I want to browse grouped expenses and search/filter visually so I can inspect mock transactions.

**Why this priority**: Expenses list is the core repeated list and search/chip surface.

**Independent Test**: Open `/expenses`, scroll grouped transactions, and interact with local search/chips without external calls.

**Acceptance Scenarios**:

1. **Given** mock expense data, **When** `/expenses` opens, **Then** grouped transaction sections render from mock arrays.
2. **Given** long merchant names, **When** rows render at 360px, **Then** the amount column remains visible and text is constrained.

---

### User Story 3 - Adjust Expense Filters Locally (Priority: P2)

As a user, I want to open a filter bottom sheet and change filters visually without saving them permanently.

**Why this priority**: This validates modal bottom sheet behavior and local-only controls.

**Independent Test**: Tap filter control, open the sheet, change controls, apply/reset locally, and close the sheet.

**Acceptance Scenarios**:

1. **Given** the expenses list, **When** the filter action is tapped, **Then** a native bottom sheet opens.
2. **Given** the filter sheet, **When** reset/apply is tapped, **Then** the action affects only local visual state.

### Edge Cases

- Bottom nav may cover the last transaction.
- Horizontal chips may overflow on 360px width.
- Bottom sheet content may exceed available height.
- Local search/filter must not imply backend queries.
- Transaction row code must not be duplicated between dashboard and expenses list.

## Requirements

### Functional Requirements

- **FR-001**: `/home` MUST render a native dashboard from static mock data.
- **FR-002**: `/expenses` MUST render a native grouped expense list from static mock data.
- **FR-003**: Expense filters MUST render as a native bottom sheet, not a full WebView or HTML surface.
- **FR-004**: Search, chips, and filters MAY update local visible mock state only.
- **FR-005**: Transaction rows MUST be reusable between dashboard and expenses list.
- **FR-006**: Bottom navigation MUST not hide scrollable content.
- **FR-007**: Layouts MUST support 360x800, 375x812, and 390x844 in LTR and RTL.
- **FR-008**: The feature MUST NOT add backend, API, database, persistence, WebView, or HTML rendering.

### Key Entities

- **DashboardMetric**: Label, amount/value, trend, icon token.
- **TransactionSection**: Date label and list of mock expenses.
- **ExpenseFilterState**: Local query, selected categories, date range, amount range, and wallet filters.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Dashboard and expenses screens render with zero overflow exceptions across required viewports and directions.
- **SC-002**: At least one route/widget test verifies dashboard renders from mock data.
- **SC-003**: At least one test opens and closes the filter bottom sheet.
- **SC-004**: Forbidden dependency search has zero implementation hits for backend, API, database, persistence, WebView, or HTML rendering.

## Assumptions

- Foundation shared widgets, mock data, and routes are available.
- Expense add/edit routes may still be placeholders until feature 004.
- Search/filter behavior can be visual/local and does not need full data correctness.
