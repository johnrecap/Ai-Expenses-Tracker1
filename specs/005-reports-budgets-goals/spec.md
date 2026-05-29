# Feature Specification: Reports, Budgets, And Goals

**Feature Branch**: `005-reports-budgets-goals`

**Created**: 2026-05-28

**Status**: Draft pending approval

**Input**: Rebuild reports, report drilldown, monthly financial story, budgets, category budgets, edit monthly budget, and saving goals as native UI-only Flutter screens.

## Mandatory Agent Prerequisites

- `AGENTS.md` was read.
- `.specify/memory/constitution.md` was read.
- `.agents/workflows/development.md` was read.
- `.agents/skill-matcher.json` was read.
- Relevant skills were searched in `.agents/skills/` and `.agent/skills/`.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`.

**Scope guard**: Reporting, budget, and goal screens use mock data and native visuals only. No analytics backend, database, persistence, API calls, WebView, HTML rendering, or screenshots-as-UI.

## User Scenarios & Testing

### User Story 1 - Review Spending Reports (Priority: P1)

As a user, I want reports and category drilldown screens so I can inspect spending trends visually.

**Why this priority**: Reports validate charts, summary cards, category rows, and route parameters.

**Independent Test**: Open `/reports` and `/reports/category/:categoryId` with mock data and verify native chart/summary components render.

**Acceptance Scenarios**:

1. **Given** mock report data, **When** `/reports` opens, **Then** summary, chart, and category breakdown render natively.
2. **Given** a known category ID, **When** the drilldown route opens, **Then** category details render without backend calls.

---

### User Story 2 - Review Monthly Story (Priority: P2)

As a user, I want a monthly financial story screen so I can see a narrative summary of my mock month.

**Why this priority**: It is a detected screen and validates long scrollable narrative layout.

**Independent Test**: Open `/story/monthly` and scroll through story panels at required widths.

**Acceptance Scenarios**:

1. **Given** monthly mock data, **When** the story opens, **Then** narrative panels and metrics render without clipping.

---

### User Story 3 - Manage Budgets And Goals Visually (Priority: P1)

As a user, I want budget and saving goal screens so I can review planning progress with mock data.

**Why this priority**: These screens validate progress bars/rings and editable local forms.

**Independent Test**: Open budget, category budgets, edit budget, and goals routes; interact with sliders/forms locally only.

**Acceptance Scenarios**:

1. **Given** mock budgets, **When** `/budgets` opens, **Then** budget overview and progress values render.
2. **Given** the edit budget screen, **When** a value changes, **Then** only local visual state changes.
3. **Given** mock goals, **When** `/goals` opens, **Then** goal cards and progress rings render.

### Edge Cases

- Chart labels can overflow at 360px.
- Category route ID may not exist.
- Progress values may exceed 100% if not clamped.
- Edit budget must not persist.
- Screenshots must not be used as chart UI.

## Requirements

### Functional Requirements

- **FR-001**: `/reports` MUST render a native reports overview from mock report data.
- **FR-002**: `/reports/category/:categoryId` MUST render native drilldown or safe not-found state.
- **FR-003**: `/story/monthly` MUST render the monthly financial story.
- **FR-004**: `/budgets`, `/budgets/categories`, and `/budgets/monthly/edit` MUST render native budget screens.
- **FR-005**: `/goals` MUST render saving goals from static mock data.
- **FR-006**: Charts and progress visuals MUST be native Flutter widgets or an approved lightweight chart widget, not screenshots.
- **FR-007**: Edit budget controls MUST use local state only.
- **FR-008**: Layouts MUST fit 360x800, 375x812, and 390x844 in LTR and RTL.
- **FR-009**: The feature MUST NOT add backend, database, persistence, API calls, WebView, HTML rendering, or screenshots-as-UI.

### Key Entities

- **ReportSummary**: Total, comparison, trend, period.
- **CategoryBreakdown**: Category ID, amount, percent, trend.
- **BudgetDraft**: Local monthly budget edit values.
- **GoalProgress**: Goal ID, saved, target, clamped progress.
- **StoryPanel**: Title, metric, description, visual emphasis.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Seven covered screens render natively without overflow at required viewports.
- **SC-002**: Progress values are clamped in tests for budgets and goals.
- **SC-003**: Known and unknown report category IDs are handled without crash.
- **SC-004**: Forbidden search has zero implementation hits for backend, API, persistence, WebView, HTML rendering, or screenshot-as-UI patterns.

## Assumptions

- Foundation metric, progress, card, and mock data patterns are available.
- A chart dependency is optional and must be approved before adding; simple native `CustomPaint` is preferred for prototype charts.
