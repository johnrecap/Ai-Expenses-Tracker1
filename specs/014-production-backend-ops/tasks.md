# Tasks: Production Backend Ops

**Input**: `specs/014-production-backend-ops/spec.md`, `specs/014-production-backend-ops/plan.md`

## Phase 1: Backend Source

- [x] T014-001 [US1] Port or reconcile VPS backend source into `server/`
  - Why: `new app` has no deployable VPS backend, so `vpsLocalFirst` cannot work.
  - Expected result: `server/src`, `server/tests`, `server/scripts`, `server/package.json`, `server/package-lock.json`, and `server/drizzle.config.ts` exist.
  - Inputs: `Expense-Tracker-main/server/`, `specs/014-production-backend-ops/plan.md`.
  - Implementation notes: Preserve Fastify/PostgreSQL/Drizzle architecture. Do not add Firebase Functions.
  - Possible bugs: stale import paths, missing package lock, scripts referencing the old project name.
  - Fix strategy: run server typecheck, update imports/scripts, and compare directory inventory against the reference.
  - Verification: `cd server; npm ci; npm run typecheck`.

- [x] T014-002 [P] [US1] Reconcile server environment validation in `server/src/config/env.ts`
  - Why: Operators need deterministic startup failures when required config is missing.
  - Expected result: Required env vars are documented and validated without exposing secret values.
  - Inputs: `Expense-Tracker-main/server/src/config/env.ts`, `docs/backend/vps-postgres-runbook.md`.
  - Implementation notes: Keep Firebase Admin credentials and database URLs out of Git.
  - Possible bugs: local tests fail because required env vars are always enforced.
  - Fix strategy: provide test-safe defaults or test-specific env loading.
  - Verification: server tests pass in local/test environment.

## Phase 2: Firebase Legacy Config

- [x] T014-003 [US2] Add Firebase deployment files at repository root
  - Why: Firestore legacy mode needs deployable rules and indexes.
  - Expected result: `.firebaserc`, `firebase.json`, `firestore.rules`, and `firestore.indexes.json` exist.
  - Inputs: `Expense-Tracker-main/firebase.json`, `Expense-Tracker-main/firestore.rules`, `Expense-Tracker-main/firestore.indexes.json`.
  - Implementation notes: Match collection paths used in `packages/expense_repository/lib/src/firebase/`.
  - Possible bugs: rules use old collection names like `recurring_expenses` while current code uses `recurringExpenses`.
  - Fix strategy: use `rg -n "collection\\(" packages/expense_repository/lib/src/firebase` and align rules/indexes.
  - Verification: rules review plus Firebase emulator/rules tests if available.

- [x] T014-004 [P] [US2] Document Firestore ownership matrix in `docs/firebase/firestore-schema.md`
  - Why: Future agents need a map of user-owned collections before editing rules.
  - Expected result: Each collection has owner path, read/write rule, and repository file.
  - Inputs: Firebase repository files and reference docs.
  - Implementation notes: Include expenses, categories, budgets, category budgets, recurring rules, saving goals, settings, AI action logs, wallets, transfers.
  - Possible bugs: undocumented collection creates production access failures.
  - Fix strategy: compare document against `rg -n "users/\\$userId" packages/expense_repository/lib/src/firebase`.
  - Verification: every Firebase repository collection appears in the matrix.

## Phase 3: Operations And CI Hooks

- [x] T014-005 [US3] Create backend runbook in `docs/backend/vps-postgres-runbook.md`
  - Why: Server setup and rollback must not rely on tribal knowledge.
  - Expected result: Runbook covers setup, env vars, migrations, health checks, backups, restore drills, and rollback.
  - Inputs: `Expense-Tracker-main/docs/backend/vps-postgres-runbook.md`.
  - Implementation notes: Use placeholders for secrets. State that Cloudflare Worker handles AI provider keys.
  - Possible bugs: runbook commands drift from `server/package.json`.
  - Fix strategy: copy exact script names from package scripts and update docs when scripts change.
  - Verification: a new maintainer can follow the runbook to run local checks.

- [x] T014-006 [P] [US3] Add backend validation notes to `README.md`
  - Why: The main project README should point agents to server checks quickly.
  - Expected result: README lists server setup and validation commands.
  - Inputs: `server/package.json`, backend runbook.
  - Implementation notes: Keep README concise; deep detail stays in `docs/backend/`.
  - Possible bugs: duplicated docs become inconsistent.
  - Fix strategy: README links to runbook instead of copying full instructions.
  - Verification: README references `docs/backend/vps-postgres-runbook.md`.

## Dependencies

T014-001 blocks T014-002 and T014-005. T014-003 blocks T014-004. T014-006 can run after T014-005.

## Final Verification

- [x] T014-007 [Polish] Run server and Flutter validation commands
  - Why: Backend plans must end with compile/test confidence.
  - Expected result: Server checks and Flutter checks pass or exact blockers are recorded.
  - Inputs: Completed tasks.
  - Implementation notes: Do not mark complete if Firebase Functions were added.
  - Possible bugs: network-restricted `npm ci`, missing local Node, Flutter analyzer timeout.
  - Fix strategy: document environment failure exactly and rerun when dependencies are available.
  - Verification: `cd server; npm ci; npm run typecheck; npm test`; `flutter analyze --no-pub`; `flutter test --no-pub`.
