# Feature Specification: Local First Sync Parity

**Feature Branch**: `015-local-first-sync-parity`
**Created**: 2026-05-29
**Status**: Draft
**Input**: Complete the missing local-first/offline repository and sync features in `new app` compared with `Expense-Tracker-main`.

## Mandatory Agent Prerequisites

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

**Scope guard**: Local persistence, repository parity, sync queue, VPS client, and sync UI are in scope. Export screen and Firebase Functions are out of scope.

## User Scenarios & Testing

### User Story 1 - Offline Data Safety (Priority: P1)

As a user, I want expense and finance changes made offline to remain safe locally and sync when connection returns.

**Why this priority**: `new app` currently has in-memory local stubs; data can disappear and sync state is incomplete.

**Independent Test**: Run repository tests using local mode, create records, restart repository store, and verify records persist or are queued for sync.

### User Story 2 - Runtime Mode Parity (Priority: P1)

As an engineer, I want `firebaseLegacy`, `vpsLocalFirst`, and `migrationComparison` modes to behave predictably.

**Why this priority**: The constitution and AGENTS require three runtime modes, but the current `new app` repository package is partial.

**Independent Test**: Switch each runtime mode through dart-define and validate repository factory output, sync coordinator presence, and data behavior.

### User Story 3 - Sync Visibility (Priority: P2)

As a user, I want to know whether my latest changes are synced, pending, failed, or waiting for connectivity.

**Why this priority**: Finance apps need trust; silent sync failures create data-loss anxiety.

**Independent Test**: Force queued, syncing, synced, and failed states and verify UI banners/messages.

## Requirements

### Functional Requirements

- **FR-001**: Local repositories MUST cover expenses, categories, aliases, budgets, category budgets, recurring expenses, saving goals, settings, AI action logs, wallets, and transfers.
- **FR-002**: Local storage MUST persist data beyond process memory.
- **FR-003**: Sync queue MUST track entity type, entity id, operation, payload, status, retry reason, and timestamps.
- **FR-004**: `VpsApiClient` MUST require Firebase bearer tokens and surface retryable vs non-retryable failures.
- **FR-005**: `SyncCoordinator` MUST push pending changes, pull remote changes, apply results, and avoid infinite loops.
- **FR-006**: UI MUST expose sync state without blocking core tracking.

### Key Entities

- **Local Record**: Persisted app-owned finance entity.
- **Sync Change**: A queued mutation awaiting VPS acknowledgement.
- **Sync Cursor**: Incremental pull position for remote changes.
- **Runtime Mode**: Repository selection mode for Firebase, VPS, or migration comparison.

## Success Criteria

- **SC-001**: Local repository tests cover all supported entity types.
- **SC-002**: Offline writes remain visible after app restart in local-first mode.
- **SC-003**: Sync status is visible to users within one screen interaction after a change.
- **SC-004**: Migration comparison can detect parity mismatch without blocking the UI.

## Assumptions

- Drift/SQLite is the preferred persistent local database because the reference package already uses Drift.
- Server endpoints are provided by `specs/014-production-backend-ops`.
- Firebase legacy remains default until VPS pilot is approved.
