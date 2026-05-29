# Feature Specification: AI, Settings, Empty States, And Final QA

**Feature Branch**: `007-ai-settings-final-qa`

**Created**: 2026-05-28

**Status**: Draft pending approval

**Input**: Rebuild AI advice, AI history, AI assistant bottom sheet, settings, missing lightweight states, not-found, and final QA gates as native UI-only Flutter work.

## Mandatory Agent Prerequisites

- `AGENTS.md` was read.
- `.specify/memory/constitution.md` was read.
- `.agents/workflows/development.md` was read.
- `.agents/skill-matcher.json` was read.
- Relevant skills were searched in `.agents/skills/` and `.agent/skills/`.

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `flutter-ui-from-design`, `ui-only-prototype-guardrails`, `flutter-build-responsive-layout`, `flutter-setup-localization`.

**Scope guard**: AI and settings screens are visual/local only. No real AI calls, chat APIs, backend, auth/account service, persistence, database, API calls, WebView, or HTML rendering.

## User Scenarios & Testing

### User Story 1 - Review AI Advice (Priority: P1)

As a user, I want to view AI advice cards and recommendations so I can understand the product promise visually.

**Why this priority**: AI advice is a core product surface but must remain static and offline.

**Independent Test**: Open `/ai/advice` and verify insight cards render from mock data without API calls.

**Acceptance Scenarios**:

1. **Given** mock AI insights, **When** `/ai/advice` opens, **Then** AI cards and recommendations render natively.
2. **Given** the screen renders, **When** forbidden dependency search runs, **Then** no AI/network/backend client exists.

---

### User Story 2 - Use AI History And Assistant Visually (Priority: P1)

As a user, I want to see chat history and an assistant bottom sheet so I can inspect the AI interaction design.

**Why this priority**: These screens validate Arabic RTL, chat bubbles, prompt chips, keyboard-safe bottom sheet layout, and local-only message behavior.

**Independent Test**: Open `/ai/history` and `/ai/assistant`, send a local mock message, and verify no network call occurs.

**Acceptance Scenarios**:

1. **Given** Arabic chat history, **When** the screen renders in RTL, **Then** bubbles, prompt chips, and input align correctly.
2. **Given** the assistant sheet, **When** a message is sent, **Then** only local mock state changes.

---

### User Story 3 - Review Settings And Static States (Priority: P2)

As a user, I want settings rows, local toggles, empty states, no-results states, and not-found handling so the prototype feels complete.

**Why this priority**: Settings and missing states complete the exported app surface and prevent broken navigation.

**Independent Test**: Open `/settings`, toggle local controls, trigger not-found, and render empty/no-results variants.

**Acceptance Scenarios**:

1. **Given** settings screen, **When** a toggle changes, **Then** state changes locally without persistence.
2. **Given** an unknown route, **When** it opens, **Then** a native not-found screen appears.
3. **Given** an empty list variant, **When** it renders, **Then** reusable empty state UI appears.

### Edge Cases

- Arabic chat text may be corrupted in exported HTML and must be manually cleaned.
- Bottom sheet can overflow when keyboard is visible.
- Prompt chips can clip on 360px.
- Settings toggles must not persist.
- Profile/account actions must not imply real account services.
- Final QA must catch hidden forbidden dependencies and duplicated UI.

## Requirements

### Functional Requirements

- **FR-001**: `/ai/advice` MUST render native AI advice cards from static mock data.
- **FR-002**: `/ai/history` MUST render native chat history with Arabic RTL readiness.
- **FR-003**: `/ai/assistant` MUST render a native assistant bottom sheet or modal surface with local mock messaging only.
- **FR-004**: `/settings` MUST render native profile/settings rows and local toggles.
- **FR-005**: Reusable empty, no-results, and not-found states MUST exist.
- **FR-006**: AI and settings actions MUST be local-only or placeholder-only.
- **FR-007**: Final QA MUST verify all detected Stitch screens have native Flutter counterparts.
- **FR-008**: Final QA MUST verify 360x800, 375x812, and 390x844 in English LTR and Arabic RTL.
- **FR-009**: Final QA MUST run compile/test commands or document exact environment blockers.
- **FR-010**: The feature MUST NOT add AI APIs, chat APIs, backend, auth/account services, database, persistence, WebView, HTML rendering, or remote runtime assets.

### Key Entities

- **AiAdviceViewData**: Insight title, body, severity, related route, accent.
- **ChatBubbleViewData**: Author, text, timestamp, ownership, language direction.
- **SuggestedPrompt**: Label, route/context, local tap behavior.
- **SettingsRowViewData**: Icon, label, value, toggle/chevron type, local state.
- **EmptyStateViewData**: Title, body, icon, optional local CTA.

## Success Criteria

### Measurable Outcomes

- **SC-001**: AI advice, AI history, assistant sheet, settings, empty states, and not-found render without overflow at required viewports.
- **SC-002**: RTL widget tests cover Arabic chat bubbles and settings rows.
- **SC-003**: Final forbidden dependency search has zero implementation hits.
- **SC-004**: Final compile gate passes or exact environment blockers are documented.
- **SC-005**: 100% of detected Stitch screens are mapped to native Flutter routes or approved placeholders.

## Assumptions

- All previous feature batches are implemented before final QA.
- Chat send may append a local canned response or display a visual-only state.
- Settings subpages remain placeholders unless separately approved.
