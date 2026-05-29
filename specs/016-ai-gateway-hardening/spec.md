# Feature Specification: AI Gateway Hardening

**Feature Branch**: `016-ai-gateway-hardening`
**Created**: 2026-05-29
**Status**: Draft
**Input**: Complete production AI gateway parity for `new app` using Cloudflare Worker and server-side boundaries, excluding Firebase Functions.

## Mandatory Agent Prerequisites

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

**Scope guard**: Cloudflare Worker, Flutter AI client, Firebase Auth token forwarding, quota UI, receipt/advice/parse flows, and AI action logs are in scope. Firebase Functions fallback is explicitly out of scope.

## User Scenarios & Testing

### User Story 1 - Safe AI Expense Drafts (Priority: P1)

As a user, I want AI to parse Arabic or English expense text into an editable draft without saving automatically.

**Why this priority**: AI entry is a differentiator, but accidental writes would damage user trust.

**Independent Test**: Send valid and ambiguous AI text, verify an editable preview appears and no expense is persisted until confirmation.

### User Story 2 - Receipt And Advice Through Gateway (Priority: P1)

As a user, I want receipt extraction and spending advice to work through the protected AI gateway.

**Why this priority**: `new app` has simplified AI client code and lacks the richer gateway contract, quota metadata, and provider error handling.

**Independent Test**: Mock Worker responses for parse, receipt, advice, quota errors, timeout, malformed output, and unauthenticated requests.

### User Story 3 - AI Quota And History (Priority: P2)

As a user, I want to see remaining AI usage and review AI action history.

**Why this priority**: Quota and history make AI transparent and support monetization.

**Independent Test**: Simulate quota states and verify settings/advice/history surfaces update.

## Requirements

### Functional Requirements

- **FR-001**: Flutter AI calls MUST route only through Cloudflare Worker or server-owned gateway endpoints.
- **FR-002**: Flutter MUST NOT contain AI provider keys.
- **FR-003**: AI parse, receipt, and advice responses MUST produce editable previews, not automatic writes.
- **FR-004**: Gateway client MUST attach Firebase bearer token when available and fail clearly when missing.
- **FR-005**: Client MUST map timeout, malformed output, rate limit, auth, and provider failures to user-safe states.
- **FR-006**: AI action logs MUST be persisted through repository interfaces.
- **FR-007**: Firebase Functions fallback MUST NOT be implemented.

### Key Entities

- **AI Context**: Locale, currency, payment method, categories, recent expenses, and budget summary.
- **AI Draft**: Editable parsed expense data with confidence and missing fields.
- **AI Usage Status**: Remaining quota, reset time, plan, and rate-limit state.
- **AI Action Log**: Auditable record of previewed/accepted/rejected AI action.

## Success Criteria

- **SC-001**: AI text parsing supports Arabic and English input in tests.
- **SC-002**: 100% of AI write actions require explicit user confirmation.
- **SC-003**: Gateway failure states produce visible, localized fallback messages.
- **SC-004**: No AI provider secret appears in Flutter source or committed config.

## Assumptions

- Cloudflare Worker under `workers/ai-gateway/` is the production AI boundary.
- Server can own future monetization/quota validation, but provider calls remain outside Flutter.
- Receipt image preprocessing should happen client-side only for size/mime validation, not OCR.
