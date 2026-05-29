# Implementation Plan: Local First Sync Parity

**Branch**: `015-local-first-sync-parity` | **Date**: 2026-05-29 | **Spec**: `specs/015-local-first-sync-parity/spec.md`

## Mandatory First Read And Skill Gate

**Skills used**: `speckit-specify`, `speckit-plan`, `speckit-tasks`, `semantic-code-search`.

## Summary

Replace `new app` in-memory local stubs with persistent local repositories and complete sync behavior modeled after `Expense-Tracker-main`.

## Why

The current package has partial repository interfaces but lacks Drift, full local entity coverage, robust `VpsApiClient` errors, durable queue state, sync cursor behavior, and user-facing sync visibility.

## Expected Result

- `packages/expense_repository` supports persistent local storage.
- All repository interfaces have Firebase and local implementations.
- Sync queue and coordinator handle offline changes and retries.
- Runtime modes are tested.
- Sync status banner or equivalent UI is wired into the app shell.

## Source References

- `Expense-Tracker-main/packages/expense_repository/lib/src/local/`
- `Expense-Tracker-main/packages/expense_repository/lib/src/sync/`
- `Expense-Tracker-main/packages/expense_repository/lib/src/api/vps_api_client.dart`
- `Expense-Tracker-main/lib/widgets/sync_status_banner.dart`

## Technical Context

**Language/Version**: Dart 3.12.0, Flutter 3.44.0.

**Primary Dependencies**: `drift`, `drift_dev`, `sqlite3_flutter_libs`, `path_provider`, `http`, existing `expense_repository`.

**Storage**: Drift/SQLite local database plus in-memory streams for UI updates.

**Testing**: Repository unit tests, sync coordinator tests, widget tests for sync status.

**Constraints**: No data loss, no unbounded retry loops, no secrets in local logs, no Export screen.

## Constitution Check

- Backend/local persistence is allowed by constitution v2.0.0.
- Three runtime modes are required by AGENTS.
- Flutter compile and tests are required per batch.
- Arabic/English sync status text must be localizable.

## Project Structure

```text
packages/expense_repository/lib/src/local/
packages/expense_repository/lib/src/sync/
packages/expense_repository/lib/src/api/
packages/expense_repository/test/
lib/widgets/ or lib/core/widgets/
lib/app/
test/api/
test/local/
```

## Implementation Batches

### Batch 1 - Persistent Local Database

**Expected result**: Drift schema covers every app-owned entity and sync changes.

### Batch 2 - Repository Parity

**Expected result**: Local implementations match Firebase interfaces and emit streams correctly.

### Batch 3 - Sync Coordinator And VPS Client

**Expected result**: Push/pull, retry, cursor, and error state behavior are deterministic.

### Batch 4 - UI Visibility And Runtime Mode Tests

**Expected result**: Users see sync state; tests prove mode switching.

## Possible Bugs And Fix Strategy

- **Schema mismatch with models**: compare fields against entity/model classes and add migrations.
- **Streams do not emit initial values**: schedule initial emission on watch methods.
- **Sync loops repeatedly push same change**: mark accepted changes and ignore no-op pulls.
- **Conflicts overwrite newer local data**: define last-write-wins and test timestamps.
- **Analyzer fails after Drift generation**: run build runner and include generated files rules.

## Verification Plan

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze --no-pub
flutter test --no-pub test/local test/api
```

## Stop Condition

All local-first repositories persist data, sync tests pass, and UI exposes sync state without blocking expense entry.
