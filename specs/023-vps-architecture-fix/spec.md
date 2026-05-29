# Feature Specification: VPS Architecture Fix

**Feature Branch**: `023-vps-architecture-fix`
**Created**: 2026-05-29
**Status**: Draft
**Input**: Make `vpsLocalFirst` mode fully functional. Currently Firebase Auth works but data layer has 4 blockers preventing production use without Firestore.

## Current Architecture

```
firebaseLegacy (working):
  Login  → Firebase Auth ✅
  Data   → Firebase Firestore ✅

vpsLocalFirst (broken):
  Login  → Firebase Auth ✅
  Data   → PostgreSQL (VPS) ❌
  Local  → SQLite ❌ (in-memory only)
  Sync   → Push/Pull ❌ (pull doesn't write)
```

## Blockers (4 Issues)

### B1: In-Memory Storage Only
`LocalRepositoryStore` uses Dart `Map`s — data lost on app close. Must replace with SQLite (Drift).

**Affected files:**
- `packages/expense_repository/lib/src/local/local_repository_store.dart`
- `packages/expense_repository/lib/src/local/local_repositories.dart`

### B2: Stub Repositories
6 repositories use `LocalStubStore()` with zero persistence:
- LocalCategoryAliasRepository
- LocalCategoryBudgetRepository
- LocalRecurringExpenseRepository
- LocalAiActionLogRepository
- LocalWalletAccountRepository
- LocalTransferRepository

### B3: VPS Not Connected
`VPS_API_BASE_URL` is empty by default. No dart-define, no server URL, no sync.

### B4: Sync Pull Not Applied
`SyncCoordinator._pullRemote()` fetches changes from VPS but never writes them to local store. Data is received and discarded.

## Fix Plan

### Phase 1: SQLite Migration
1. Add `drift` + `sqlite3` dependencies to `expense_repository/pubspec.yaml`
2. Create Drift database with tables for all entities
3. Replace `LocalRepositoryStore` with `DriftLocalRepositoryStore`
4. Fix all 6 stub repos to use the Drift store

### Phase 2: Sync Fix
1. Fix `_pullRemote()` to apply changes to local store
2. Add conflict resolution for concurrent edits
3. Add sync status UI banner

### Phase 3: VPS Connection
1. Set `VPS_API_BASE_URL` via dart-define
2. Ensure Firebase token is sent for auth on VPS API
3. Test end-to-end: create expense → sync to VPS → pull on second device

## Success Criteria
- [ ] Expenses persist after app restart in vpsLocalFirst mode
- [ ] Changes sync to VPS PostgreSQL
- [ ] Changes from VPS appear in local store
- [ ] Firebase Auth continues to work unchanged
- [ ] firebaseLegacy mode still works unchanged
