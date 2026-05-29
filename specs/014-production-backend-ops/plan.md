# Implementation Plan: Production Backend Ops

**Branch**: `014-production-backend-ops` | **Date**: 2026-05-29 | **Spec**: `specs/014-production-backend-ops/spec.md`

**Input**: Feature specification from `specs/014-production-backend-ops/spec.md`.

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

## Summary

Port or reconcile the production VPS backend and Firebase deployment config from `Expense-Tracker-main` into `new app`, while explicitly excluding Firebase Functions and Export screen work.

## Why

`new app` has Flutter Firebase/Auth dependencies and repository clients, but it lacks the deployable backend and Firebase rules required to protect and sync real data. This plan removes the gap between a UI app that compiles and a production app that can be operated.

## Expected Result

- `server/` with source, migrations, scripts, tests, `package.json`, and lockfile.
- Firebase deployment files in repository root.
- Backend runbooks under `docs/backend/`.
- CI-ready commands for server typecheck/tests.
- No `functions/` requirement and no Export screen scope.

## Source References

- `C:/Users/SOUQ/Downloads/apps/Expense-Tracker/Expense-Tracker-main/server/`
- `C:/Users/SOUQ/Downloads/apps/Expense-Tracker/Expense-Tracker-main/firebase.json`
- `C:/Users/SOUQ/Downloads/apps/Expense-Tracker/Expense-Tracker-main/firestore.rules`
- `C:/Users/SOUQ/Downloads/apps/Expense-Tracker/Expense-Tracker-main/firestore.indexes.json`
- `C:/Users/SOUQ/Downloads/apps/Expense-Tracker/Expense-Tracker-main/docs/backend/`

## Technical Context

**Language/Version**: Node.js 20, TypeScript, Flutter 3.44.0, Dart 3.12.0.

**Primary Dependencies**: Fastify, PostgreSQL, Drizzle ORM, Firebase Admin SDK, Vitest or project reference test runner.

**Storage**: PostgreSQL for VPS mode; Firestore for Firebase legacy mode.

**Testing**: `npm ci`, `npm run typecheck`, `npm test` under `server/`; Firebase rules validation where available.

**Constraints**: No Firebase Functions, no AI provider secrets in Flutter, no committed server secrets, no WebView.

## Constitution Check

- Project law and skills were read.
- Backend scope is allowed by constitution v2.0.0.
- Firebase Functions are excluded by user correction.
- Export screen is excluded by user correction.
- Secrets remain outside Git.
- Backend tests and Flutter compile checks are planned before completion.

## Project Structure

```text
server/
  src/
  tests/
  scripts/
  package.json
  package-lock.json
  drizzle.config.ts
firebase.json
firestore.rules
firestore.indexes.json
docs/backend/
```

## Implementation Batches

### Batch 1 - Backend Source Parity

**Why**: `new app` lacks the deployable VPS API.
**Expected result**: `server/` structure is present and aligned with the reference server.
**Acceptance criteria**: Server source and package files exist; no `functions/` dependency is introduced.

### Batch 2 - Firebase Legacy Rules And Indexes

**Why**: Flutter repositories use Firestore in `firebaseLegacy` mode.
**Expected result**: Rules and indexes protect user-owned paths and support query patterns.
**Acceptance criteria**: Rules include `users/{userId}` ownership checks; indexes match repository queries.

### Batch 3 - Runbooks And Validation

**Why**: Agents need clear deployment and failure recovery instructions.
**Expected result**: Backend setup, migration, backup, and rollback docs exist.
**Acceptance criteria**: A maintainer can run local validation and know required env vars.

## Possible Bugs And Fix Strategy

- **Missing env var causes server boot failure**: add explicit env validation and runbook examples.
- **Rules block valid Firestore writes**: compare repository collection paths against rules and add emulator tests.
- **Auth bypass risk**: require Firebase token verification on every user-owned endpoint.
- **Secrets leak in docs**: use placeholders and `.env.example` only.

## Verification Plan

```powershell
cd server
npm ci
npm run typecheck
npm test
cd ..
flutter analyze --no-pub
flutter test --no-pub
```

## Stop Condition

Do not mark this plan complete until server validation passes or exact environment blockers are documented, Firebase files exist, and no Firebase Functions implementation is added.
