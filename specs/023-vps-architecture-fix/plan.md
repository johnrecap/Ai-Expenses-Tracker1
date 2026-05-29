# Implementation Plan: VPS Architecture Fix

**Branch**: `023-vps-architecture-fix` | **Date**: 2026-05-29 | **Spec**: `specs/023-vps-architecture-fix/spec.md`

## Why
`vpsLocalFirst` mode is the architecture Mohamed wants: Firebase Auth only, PostgreSQL for data, SQLite for offline. Currently 4 blockers prevent this from working.

## Strategy
Fix in dependency order: storage → stubs → sync → VPS connection.

## Implementation Batches

### Batch 1: Drift Integration
- Add `drift`, `drift_flutter`, `sqlite3_flutter_libs` dependencies
- Create `DriftLocalRepositoryStore` with tables for expenses, categories, budgets, wallets, transfers, settings, goals
- Replace in-memory Maps with Drift DAOs

### Batch 2: Fix Stub Repos
- Rewire all 6 stub repositories to use Drift store
- Add stream support via Drift `.watch()`

### Batch 3: Fix Sync Pull
- Modify `_pullRemote()` to upsert pulled data into local store
- Add merge strategy for conflicts (last-write-wins with timestamp)

### Batch 4: VPS Connection
- Configure `VPS_API_BASE_URL` dart-define
- Test Firebase token flow
- End-to-end smoke test

## Risks
- Drift code generation requires `dart run build_runner build`
- Schema migration must not break existing firebaseLegacy mode
- VPS server must be deployed and accessible

## Verification
```bash
flutter run --dart-define=REPOSITORY_RUNTIME_MODE=vpsLocalFirst
# Verify: create expense, restart app, expense still exists
# Verify: check VPS PostgreSQL for synced data
```
