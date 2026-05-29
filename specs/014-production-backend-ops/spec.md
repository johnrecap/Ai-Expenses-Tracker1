# Feature Specification: Production Backend Ops

**Feature Branch**: `014-production-backend-ops`
**Created**: 2026-05-29
**Status**: Draft
**Input**: Close production gaps in `new app` compared with `Expense-Tracker-main`, excluding Firebase Functions because AI/server work should be handled by the VPS server and Cloudflare Worker, and excluding the Export screen.

## Mandatory Agent Prerequisites

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

**Scope guard**: Production backend, Firebase project config, Firestore rules, VPS server, tests, and runbooks are in scope. Firebase Functions and Export screen work are out of scope for this feature.

## User Scenarios & Testing

### User Story 1 - Deployable Backend Baseline (Priority: P1)

As a maintainer, I want the `new app` repository to contain the VPS backend and Firebase deployment files needed for a real production environment.

**Why this priority**: The Flutter app already imports Firebase and repository clients, but the repo does not contain `server/`, `firebase.json`, Firestore rules, or indexes.

**Independent Test**: From the repository root, verify backend files exist, server dependencies install, server typecheck/tests run, and Firebase rules/indexes are present.

**Acceptance Scenarios**:
1. **Given** a clean clone of `new app`, **When** a maintainer inspects the repository, **Then** `server/`, `firebase.json`, `firestore.rules`, and `firestore.indexes.json` are present.
2. **Given** the server dependencies are installed, **When** `npm run typecheck` and `npm test` run under `server/`, **Then** the backend validates without relying on Firebase Functions.

### User Story 2 - Safe Firestore Legacy Mode (Priority: P1)

As a signed-in user, I want my legacy Firestore data to remain protected and queryable while the VPS migration is prepared.

**Why this priority**: `new app` uses Firebase repositories, but missing security rules/indexes can either block valid data or allow unsafe access.

**Independent Test**: Review rules for user-owned collections and run emulator/rules tests where available.

**Acceptance Scenarios**:
1. **Given** a user is authenticated, **When** they read/write their own `users/{userId}` data, **Then** rules allow access.
2. **Given** a user attempts another user's data, **When** the request is evaluated, **Then** rules deny access.

### User Story 3 - Backend Runbook Ready (Priority: P2)

As an operator, I want clear setup, deployment, health check, migration, and rollback instructions.

**Why this priority**: The server is production-critical and must be operable by agents without guessing.

**Independent Test**: A new agent can follow the runbook to configure environment variables, run migrations, run health checks, and identify rollback paths.

## Requirements

### Functional Requirements

- **FR-001**: Repository MUST contain `server/` with Fastify/PostgreSQL/Drizzle source, tests, scripts, and package lock.
- **FR-002**: Repository MUST contain Firebase deployment files for legacy Auth/Firestore support: `.firebaserc`, `firebase.json`, `firestore.rules`, and `firestore.indexes.json`.
- **FR-003**: Server MUST verify Firebase Auth bearer tokens for user-owned API operations.
- **FR-004**: Server MUST expose health, user, account deletion, and sync endpoints equivalent to the production reference.
- **FR-005**: Server MUST avoid logging secrets, auth tokens, raw receipt text, or sensitive expense descriptions.
- **FR-006**: Firebase Functions MUST NOT be ported as part of this feature.
- **FR-007**: Export screen work MUST NOT be added as part of this feature.

### Key Entities

- **Backend Environment**: Runtime configuration for database URL, Firebase Admin credentials, host, CORS, and logging.
- **User Ownership Boundary**: Rules that ensure every data operation is scoped to the authenticated user.
- **Deployment Runbook**: Documentation describing setup, migrations, health checks, backups, and rollback.

## Success Criteria

- **SC-001**: A new agent can locate and run server validation commands in under 10 minutes.
- **SC-002**: Firestore rules clearly cover all user-owned collections used by the Flutter repositories.
- **SC-003**: No Firebase Functions folder is required for backend or AI flows.
- **SC-004**: Backend setup docs identify all required environment variables and no secrets are committed.

## Assumptions

- `Expense-Tracker-main/server/` is the reference implementation to port or reconcile.
- Cloudflare Worker remains the AI provider boundary.
- Firebase Auth remains the identity provider even when app data moves to VPS.
