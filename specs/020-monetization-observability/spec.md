# Feature Specification: Monetization Observability

**Feature Branch**: `020-monetization-observability`
**Created**: 2026-05-29
**Status**: Draft
**Input**: Complete monetization, ads, premium gating, feature flags, and privacy-safe observability missing from `new app`.

## Mandatory Agent Prerequisites

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

**Scope guard**: AdMob, premium entitlement, purchase abstraction, feature gates, feature flags, and privacy-safe observability are in scope. Export screen and Firebase Functions are out of scope.

## User Scenarios & Testing

### User Story 1 - Free And Premium Plans (Priority: P1)

As a user, I want to understand Free vs Premium benefits and upgrade without losing access to core expense tracking.

**Why this priority**: Monetization exists only as stubs in `new app`; reference app includes plan/policy/entitlement models and UI.

**Independent Test**: Open premium screen, verify plan benefits, simulate entitlement active/inactive, and ensure core tracking remains free.

### User Story 2 - Ads With Consent And Frequency Caps (Priority: P1)

As a free user, I want ads to be respectful, consent-aware, and not disruptive.

**Why this priority**: `google_mobile_ads` is disabled in `new app`, and ad policy models/widgets are missing.

**Independent Test**: Simulate consent denied/accepted, premium user, frequency cap reached, and ad load failure.

### User Story 3 - Privacy-Safe Observability (Priority: P2)

As an operator, I want health, feature flag, and error signals without collecting raw sensitive finance data.

**Why this priority**: `new app` lacks `observability/`; production debugging needs safe telemetry boundaries.

**Independent Test**: Emit sample events and verify no raw descriptions, receipt text, PINs, tokens, or provider keys are included.

## Requirements

### Functional Requirements

- **FR-001**: Monetization models MUST represent plan, entitlement, quota policy, ad placement policy, consent, and purchase verification state.
- **FR-002**: Free users MUST retain core expense tracking.
- **FR-003**: Premium users MUST not see ads and MUST receive configured premium benefits.
- **FR-004**: Ads MUST respect consent, frequency caps, placement policies, debug/test ids, and load failures.
- **FR-005**: Feature gates MUST degrade gracefully with upgrade prompts, not crashes.
- **FR-006**: Observability MUST never log raw sensitive user finance/auth/security data.
- **FR-007**: All monetization copy MUST be localized and RTL-ready.

### Key Entities

- **Monetization Plan**: Free or Premium benefit set.
- **Entitlement Snapshot**: Current premium state and expiry.
- **Ad Placement Policy**: Where ads can appear and frequency limits.
- **Feature Flag**: Runtime toggle for risky features.
- **Observability Event**: Safe technical event without sensitive payload.

## Success Criteria

- **SC-001**: Core tracking remains usable when premium and ads fail.
- **SC-002**: Premium entitlement removes ads in tests.
- **SC-003**: Ad failures show no blocking error to users.
- **SC-004**: Observability tests prove sensitive fields are redacted or omitted.

## Assumptions

- Real purchase receipt validation should be server-side before public launch.
- Test ad ids are allowed in debug only.
- Feature gates should start locally configurable, then become server-configurable later.
