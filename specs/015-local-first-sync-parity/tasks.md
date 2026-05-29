# Tasks: Local First Sync Parity

**Input**: `specs/015-local-first-sync-parity/spec.md`, `specs/015-local-first-sync-parity/plan.md`

## Phase 1: Dependencies And Schema

- [ ] T015-001 [US1] Add local database dependencies to `packages/expense_repository/pubspec.yaml`
  - Why: Persistent offline storage requires Drift/SQLite, not in-memory stubs.
  - Expected result: Package has `drift`, `drift_dev`, and SQLite runtime dependencies aligned with Flutter/Dart versions.
  - Inputs: Reference package `Expense-Tracker-main/packages/expense_repository/pubspec.yaml`.
  - Implementation notes: Avoid unrelated root dependency upgrades.
  - Possible bugs: dependency conflict with Dart 3.12 constraints.
  - Fix strategy: use `dart pub outdated` in the package and adjust minimal compatible versions.
  - Verification: `cd packages/expense_repository; dart pub get`.

- [ ] T015-002 [US1] Create Drift schema in `packages/expense_repository/lib/src/local/tables/`
  - Why: Every local-first entity needs durable tables and indexes.
  - Expected result: Tables cover expenses, categories, aliases, budgets, category budgets, recurring expenses, saving goals, settings, AI action logs, wallets, transfers, and sync changes.
  - Inputs: Reference `local/tables/synced_tables.dart`, current models/entities.
  - Implementation notes: Include user id, entity id, updated timestamp, archived flags where applicable.
  - Possible bugs: field type mismatch causes serialization loss.
  - Fix strategy: compare every entity field and add conversion helpers for enums/dates.
  - Verification: build runner succeeds and schema tests compile.

## Phase 2: Repository Implementations

- [ ] T015-003 [US1] Replace `local_stubs.dart` with durable local repositories
  - Why: Current `Stream.value` and list-backed stores lose data and do not react to updates.
  - Expected result: Local repositories read/write Drift and emit live streams.
  - Inputs: `Expense-Tracker-main/packages/expense_repository/lib/src/local/`.
  - Implementation notes: Preserve existing repository interfaces; do not change UI screens for this task.
  - Possible bugs: stream subscribers miss initial state.
  - Fix strategy: emit current records immediately when `watch*` is called.
  - Verification: repository tests for create/update/delete/watch.

- [ ] T015-004 [P] [US1] Add complete local entity serializers in `packages/expense_repository/lib/src/entities/`
  - Why: Local and remote stores must share the same domain semantics.
  - Expected result: Entity conversion covers money snapshots, sync status, category budgets, recurring rules, wallets, and transfers.
  - Inputs: Reference entity files and current model files.
  - Implementation notes: Keep conversion deterministic and test date/time fields.
  - Possible bugs: enum names differ between old and new model versions.
  - Fix strategy: add explicit storage values and fallback behavior.
  - Verification: entity round-trip unit tests.

## Phase 3: Sync Runtime

- [ ] T015-005 [US2] Harden `VpsApiClient` in `packages/expense_repository/lib/src/api/vps_api_client.dart`
  - Why: Sync needs reliable error classification and token requirements.
  - Expected result: Client supports JSON GET/POST/PATCH, bearer token enforcement, timeout, retryable errors, and typed exceptions.
  - Inputs: Reference `VpsApiClient` from `Expense-Tracker-main`.
  - Implementation notes: Do not silently call VPS without an auth token.
  - Possible bugs: old code accepts null token and creates unauthenticated server requests.
  - Fix strategy: throw a retryable missing-token exception before network calls.
  - Verification: `test/api/vps_api_client_test.dart`.

- [ ] T015-006 [US2] Complete `SyncCoordinator` and queue in `packages/expense_repository/lib/src/sync/`
  - Why: Local-first mode needs deterministic push/pull and retry behavior.
  - Expected result: Coordinator pushes pending changes, marks accepted/failed, pulls by cursor, and updates local records.
  - Inputs: Reference sync coordinator, server sync contracts.
  - Implementation notes: Include backoff hooks but keep UI non-blocking.
  - Possible bugs: repeated pull re-applies same remote change.
  - Fix strategy: persist cursor and ignore already-applied revision/client ids.
  - Verification: `test/api/sync_coordinator_test.dart`.

- [ ] T015-007 [P] [US2] Update `repository_factory.dart` for runtime mode parity
  - Why: AGENTS requires `firebaseLegacy`, `vpsLocalFirst`, and `migrationComparison`.
  - Expected result: Factory returns complete bundles for all modes, including sync coordinator where appropriate.
  - Inputs: Current and reference repository factories.
  - Implementation notes: Pass auth repository/token provider into VPS mode.
  - Possible bugs: sync coordinator created before auth is ready.
  - Fix strategy: make token provider lazy and retryable.
  - Verification: factory unit tests for all runtime modes.

## Phase 4: Sync UI

- [ ] T015-008 [US3] Add sync status component in `lib/core/widgets/sync_status_banner.dart`
  - Why: Users need trust that data is saved, pending, syncing, or failed.
  - Expected result: A reusable banner renders localized status states and retry action.
  - Inputs: Reference `lib/widgets/sync_status_banner.dart`, `lib/core/theme/`.
  - Implementation notes: Use existing colors/tokens; keep compact for 360x800; support RTL.
  - Possible bugs: banner overlaps bottom navigation.
  - Fix strategy: place it inside app scaffold content with safe bottom padding.
  - Verification: widget tests for queued/syncing/failed/synced in LTR and RTL.

- [ ] T015-009 [US3] Wire sync status into `lib/app/app.dart` or app shell
  - Why: Sync status should be global, not duplicated per screen.
  - Expected result: Authenticated app shell listens to pending sync stream and displays the shared banner.
  - Inputs: Repository bundle, router/app shell files.
  - Implementation notes: Avoid creating a new repository per rebuild.
  - Possible bugs: provider scope loses sync stream on route change.
  - Fix strategy: provide repository bundle above router and keep stream ownership stable.
  - Verification: navigate between screens while sync state remains visible.

## Final Verification

- [ ] T015-010 [Polish] Run local-first verification suite
  - Why: Offline/sync changes are high data-loss risk.
  - Expected result: Analyze/tests pass or exact blocker is documented.
  - Inputs: Completed local repository and sync work.
  - Implementation notes: Include entity round-trip, repository stream, sync conflict, and runtime mode tests.
  - Possible bugs: generated Drift files stale.
  - Fix strategy: rerun build runner and format generated imports.
  - Verification: `dart run build_runner build --delete-conflicting-outputs`; `flutter analyze --no-pub`; `flutter test --no-pub test/local test/api`.
