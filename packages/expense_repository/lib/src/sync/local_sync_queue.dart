import 'package:expense_repository/expense_repository.dart';

class LocalSyncQueue {
  final List<SyncChange> pending;
  final void Function(List<String>) onUploaded;
  final VoidCallback onChanged;
  bool _retryScheduled = false;

  LocalSyncQueue({required this.pending, required this.onUploaded, required this.onChanged});

  List<SyncChange> get readyToSync => pending.where((c) => c.status != 'synced').toList();

  void markSyncing(List<SyncChange> changes) {
    for (final c in changes) {
      pending[pending.indexOf(c)] = c.copyWithApproved(serverRevision: 0, status: 'syncing');
    }
    onChanged();
  }

  void markSynced(List<String> clientChangeIds) {
    for (final id in clientChangeIds) {
      final idx = pending.indexWhere((c) => c.clientChangeId == id);
      if (idx >= 0) pending[idx] = pending[idx].copyWithApproved(serverRevision: 0, status: 'synced');
    }
    onUploaded(clientChangeIds);
  }

  void markFailed(List<String> clientChangeIds, String reason) {
    for (final id in clientChangeIds) {
      final idx = pending.indexWhere((c) => c.clientChangeId == id);
      if (idx >= 0) pending[idx] = pending[idx].copyWithFailed(reason: reason, status: 'failed');
    }
    onChanged();
  }
}

typedef VoidCallback = void Function();
