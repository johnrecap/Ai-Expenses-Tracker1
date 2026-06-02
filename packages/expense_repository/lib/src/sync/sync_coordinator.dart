import 'dart:async';
import 'package:expense_repository/expense_repository.dart';

class SyncCoordinator {
  final VpsApiClient apiClient;
  final LocalSyncQueue queue;
  final LocalStoreInterface? localStore;
  String? _lastCursor;
  bool _isSyncing = false;

  SyncCoordinator({
    required this.apiClient,
    required this.queue,
    this.localStore,
  });

  bool get isSyncing => _isSyncing;

  Future<void> syncNow({required String deviceId}) async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _pushPending(deviceId);
      await _pullRemote();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushPending(String deviceId) async {
    final ready = queue.readyToSync;
    if (ready.isEmpty) return;
    queue.markSyncing(ready);
    try {
      final changes = ready.map((c) => c.toPushPayload()).toList();
      final response = await apiClient.pushChanges(deviceId: deviceId, changes: changes);
      final accepted = _acceptedClientChangeIds(response);
      queue.markSynced(accepted);
    } catch (_) {
      queue.markFailed(
        ready.map((c) => c.clientChangeId).toList(),
        'sync_push_error',
      );
    }
  }

  Future<void> _pullRemote() async {
    try {
      final response = await apiClient.pullChanges(cursor: _lastCursor);
      final changes = _pulledChanges(response);
      final store = localStore;
      if (store != null) {
        for (final change in changes) {
          await store.applyRemoteChange(change);
        }
      }
      _lastCursor = _cursorFrom(response['nextCursor'] ?? response['cursor']);
    } catch (_) {
      // Pull failures are not critical - pending local changes will be pushed
    }
  }

  List<String> _acceptedClientChangeIds(Map<String, dynamic> response) {
    final raw = response['accepted'];
    if (raw is! List) return const [];

    final ids = <String>[];
    for (final item in raw) {
      if (item is String) {
        ids.add(item);
      } else if (item is Map) {
        final clientChangeId = item['clientChangeId']?.toString();
        if (clientChangeId != null && clientChangeId.isNotEmpty) {
          ids.add(clientChangeId);
        }
      }
    }
    return ids;
  }

  List<SyncChange> _pulledChanges(Map<String, dynamic> response) {
    final raw = response['changes'] ?? response['items'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => SyncChange.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  String? _cursorFrom(Object? value) {
    final cursor = value?.toString();
    if (cursor == null || cursor.isEmpty) return null;
    return cursor;
  }
}
