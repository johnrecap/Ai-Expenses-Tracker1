# Feature Specification: Foundation

**Feature Branch**: `001-foundation`

**Created**: 2026-05-28

**Status**: Draft pending approval

**Input**: Create the UI-only Flutter foundation for AI Expenses Tracker before screen implementation.

## Mandatory Agent Prerequisites

- `AGENTS.md` was read.
- `.specify/memory/constitution.md` was read.
- `.agents/workflows/development.md` was read.
- `.agents/skill-matcher.json` was read.
- Relevant skills were searched in `.agents/skills/` and `.agent/skills/`.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`, `flutter-setup-localization`.

**Scope guard**: UI-only Flutter prototype. No backend, Firebase, real auth, database, API calls, persistence, WebView, or HTML rendering.

## User Scenarios & Testing

### User Story 1 - Compileable Placeholder App (Priority: P1)

As a reviewer, I need a clean Flutter project baseline so every later UI batch can be compiled and tested.

**Why this priority**: All screen work depends on a valid app structure and compile gate.

**Independent Test**: From the workspace root, run Flutter dependency, analyze, test, and debug build commands against the placeholder app.

**Acceptance Scenarios**:

1. **Given** the workspace root, **When** Flutter commands run, **Then** the placeholder app compiles without backend or WebView dependencies.
2. **Given** an unknown route, **When** it is opened, **Then** a native not-found placeholder is shown.

---

### User Story 2 - Shared Design System (Priority: P1)

As a UI implementer, I need centralized colors, typography, spacing, radii, shadows, gradients, and layout helpers so screens do not duplicate styles.

**Why this priority**: The Stitch exports repeat the same glass and finance UI patterns.

**Independent Test**: Render shared widgets with the theme in LTR and RTL at 360, 375, and 390 logical widths.

**Acceptance Scenarios**:

1. **Given** a shared glass card, **When** it is rendered in RTL, **Then** spacing and alignment remain direction-aware.
2. **Given** a primary button, **When** text is long, **Then** the button keeps stable dimensions without overflow.

---

### User Story 3 - Routes, Assets, And Mock Data (Priority: P2)

As a future screen worker, I need route constants, local assets, and static mock models before building feature screens.

**Why this priority**: Data-driven screens prevent duplicated hardcoded lists and accidental service layers.

**Independent Test**: Route smoke tests resolve all planned paths to placeholders and mock collection tests prove required data exists.

**Acceptance Scenarios**:

1. **Given** the planned route list, **When** each route is resolved, **Then** it returns a native placeholder or later screen slot.
2. **Given** mock collections, **When** a screen needs expenses, reports, wallets, subscriptions, or AI insights, **Then** static in-memory data exists.

### Edge Cases

- Flutter project already exists and must not be overwritten blindly.
- Stitch export folders must remain untouched.
- Logo asset may only exist as a screenshot and should be treated as a temporary local prototype asset.
- RTL checks must exist before Arabic-heavy screens are implemented.
- Forbidden package names may appear in docs; only implementation files block acceptance.

## Requirements

### Functional Requirements

- **FR-001**: The baseline app MUST compile from the workspace root.
- **FR-002**: The foundation MUST define central theme tokens for colors, gradients, typography, spacing, radii, and shadows.
- **FR-003**: The foundation MUST define responsive and directionality helpers for 360x800, 375x812, and 390x844.
- **FR-004**: The foundation MUST define reusable shared widgets before feature screens.
- **FR-005**: The foundation MUST define central route constants for every planned route.
- **FR-006**: The foundation MUST define static in-memory mock data and models.
- **FR-007**: The foundation MUST register local assets without remote runtime image URLs.
- **FR-008**: The foundation MUST include tests for theme, directionality, routes, and mock data.
- **FR-009**: The foundation MUST NOT introduce backend, auth, database, API, persistence, WebView, or HTML rendering dependencies.

### Key Entities

- **MockUser**: Visual profile, locale preference, and base currency.
- **MockExpense**: Merchant, category, amount, currency, date, wallet, notes, and visual sync state.
- **MockCategory**: Label, icon token, and color token.
- **MockWallet**: Account label, balance, type, trend, and visual status.
- **MockBudget**: Monthly cap, spent amount, remaining amount, and category allocations.
- **MockGoal**: Target, saved amount, deadline, and progress.
- **MockSubscription**: Vendor, amount, billing date, status, and insight flags.
- **MockReport**: Period totals, category breakdowns, and trend points.
- **MockAiInsight**: Title, summary, severity, and related route.
- **MockChatMessage**: Author, message text, timestamp, and direction.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Flutter dependency, analysis, tests, and one debug build command complete before screen batches begin.
- **SC-002**: 100% of planned route paths resolve to a placeholder or defined screen slot.
- **SC-003**: Shared widget smoke tests cover LTR and RTL at 360, 375, and 390 logical widths.
- **SC-004**: Forbidden dependency search has zero implementation hits.
- **SC-005**: All repeated mock collections needed by later screen groups contain at least one sample item.

## Assumptions

- The Flutter project is created in the workspace root, not inside the Stitch export folder.
- `go_router`, `intl`, and FlutterGen are allowed only if approved during implementation.
- All data remains deterministic and in-memory.
- Source screenshots and HTML are references only.
