# Contract: Local Data Reliability

## Scope

Owned files:

- `packages/expense_repository/lib/src/local/drift/drift_store.dart`
- `packages/expense_repository/lib/src/local/local_store_interface.dart`
- `packages/expense_repository/lib/src/local/local_repositories.dart`
- `packages/expense_repository/test/`
- focused app tests that consume repository results

## Guarantees

1. A local store exposes a readiness state or equivalent guarantee before reads that can produce defaults.
2. Repository reads wait for readiness or clearly report loading/failure through existing app state.
3. Repository writes do not report success until durable local persistence succeeds.
4. Save failures propagate to the bloc/cubit/UI layer as user-visible failures.
5. Local-only mode does not instantiate Firestore/VPS financial-data repositories.

## Acceptance Tests

- Create a store with existing settings and expenses, call reads immediately, and confirm existing data is returned.
- Simulate local write failure and confirm create/update/delete returns failure.
- Confirm default settings are not written before existing settings load.
- Confirm local-only factory output uses local repositories for app-owned financial data.

## Non-Goals

- No cloud sync.
- No Firestore migration.
- No broad repository rewrite outside the local runtime path.
