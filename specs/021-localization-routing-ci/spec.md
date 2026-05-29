# Feature Specification: Localization Routing CI

**Feature Branch**: `021-localization-routing-ci`
**Created**: 2026-05-29
**Status**: Draft
**Input**: Complete missing localization, RTL readiness, route coverage, CI/security automation, release tools, and documentation.

## Mandatory Agent Prerequisites

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

**Scope guard**: Localization, route inventory, analyzer/test automation, CodeQL, release-signing docs/tools, and QA runbooks are in scope. Export screen and Firebase Functions are out of scope.

## User Scenarios & Testing

### User Story 1 - Complete EN/AR Experience (Priority: P1)

As an English or Arabic user, I want all app-owned labels, errors, empty states, settings, and guidance to appear in my chosen language and direction.

**Why this priority**: `new app` has 122 EN keys vs 1043 in the reference app, and many hardcoded English strings.

**Independent Test**: Switch English/Arabic and run widget tests plus visual checks for required viewports.

### User Story 2 - Complete Route Coverage (Priority: P1)

As a user, I want every implemented screen and action to be reachable through stable routes and navigation.

**Why this priority**: Some constants exist without routes, and several missing features need new routes.

**Independent Test**: Route table test verifies every route constant has a `GoRoute` or documented deferral.

### User Story 3 - Automated Quality Gates (Priority: P2)

As a maintainer, I want CI to run Flutter, server, Worker, and security checks so regressions are caught before merge.

**Why this priority**: `new app` lacks `.github` workflows and release/verification tools.

**Independent Test**: CI workflow validates syntax and local commands mirror CI steps.

## Requirements

### Functional Requirements

- **FR-001**: All app-owned visible strings MUST use localization keys.
- **FR-002**: Arabic layout MUST use RTL and pass no-overflow checks on 360x800, 375x812, and 390x844.
- **FR-003**: Route constants MUST map to actual routes or be removed/documented as deferred.
- **FR-004**: CI MUST run Flutter analyze/tests and backend/Worker checks where those folders exist.
- **FR-005**: CodeQL or equivalent security scanning MUST cover JavaScript/TypeScript backend code.
- **FR-006**: Release-signing and toolchain verification docs/scripts MUST exist without committed secrets.
- **FR-007**: Firebase Functions and Export screen MUST remain excluded from this plan.

### Key Entities

- **Localization Key**: Stable key for app-owned string in EN/AR ARB files.
- **Route Contract**: Path, screen owner, auth requirement, source feature.
- **CI Workflow**: Automated validation for Flutter, server, Worker, and security.
- **QA Runbook**: Manual viewport/RTL/release checklist.

## Success Criteria

- **SC-001**: Hardcoded English app-owned strings are reduced to an approved allowlist.
- **SC-002**: Route test covers all public route constants.
- **SC-003**: CI workflows can run Flutter, server, Worker, and CodeQL checks.
- **SC-004**: Release docs identify signing steps without storing keys in Git.

## Assumptions

- Existing generated localization files can be regenerated with `flutter gen-l10n`.
- CI can skip server/Worker jobs when folders are not present, or depend on specs 014/016 being implemented first.
