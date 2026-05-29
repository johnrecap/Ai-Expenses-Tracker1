import 'dart:async';
import 'package:expense_repository/expense_repository.dart';

class SyncCoordinator {
  final VpsApiClient apiClient;
  final LocalSyncQueue queue;
  int? _lastCursor;
  bool _isSyncing = false;

  SyncCoordinator({required this.apiClient, required this.queue});

  bool get isSyncing => _isSyncing;

  Future<void> syncNow({required String deviceId}) async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _pushPending(deviceId);
      await _pullRemote(deviceId);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushPending(String deviceId) async {
    final ready = queue.readyToSync;
    if (ready.isEmpty) return;
    queue.markSyncing(ready);
    try {
      final changes = ready.map((c) => {
        'clientChangeId': c.clientChangeId, 'entityType': c.entityType,
        'entityId': c.entityId, 'changeType': c.changeType.name, 'data': c.data,
      }).toList();
      final response = await apiClient.pushChanges(deviceId: deviceId, changes: changes);
      final accepted = List<String>.from(response['accepted'] as List? ?? []);
      queue.markSynced(accepted);
    } catch (_) {
      queue.markFailed(ready.map((c) => c.clientChangeId).toList(), 'sync_push_error');
    }
  }

  Future<void> _pullRemote(String deviceId) async {
    try {
      final response = await apiClient.pullChanges(cursor: _lastCursor);
      final changes = response['changes'] as List? ?? [];
      _lastCursor = response['nextCursor'] as int?;
    } catch (_) {
      // Pull failures are not critical - pending local changes will be pushed
    }
  }
}
