enum SyncChangeType { upsert, delete }

class SyncChange {
  final String id;
  final String entityType;
  final String entityId;
  final SyncChangeType changeType;
  final Map<String, dynamic> data;
  final String clientChangeId;
  final String deviceId;
  final String userId;
  final DateTime timestamp;
  final int? serverRevision;
  final String status;
  final String? failureReason;

  const SyncChange({
    required this.id, required this.entityType, required this.entityId,
    required this.changeType, required this.data, required this.clientChangeId,
    required this.deviceId, required this.userId, required this.timestamp,
    this.serverRevision, this.status = 'pending', this.failureReason,
  });

  SyncChange copyWithApproved({required int serverRevision, required String status}) =>
      SyncChange(id: id, entityType: entityType, entityId: entityId, changeType: changeType,
          data: data, clientChangeId: clientChangeId, deviceId: deviceId, userId: userId,
          timestamp: timestamp, serverRevision: serverRevision, status: status);

  SyncChange copyWithFailed({required String reason, required String status}) =>
      SyncChange(id: id, entityType: entityType, entityId: entityId, changeType: changeType,
          data: data, clientChangeId: clientChangeId, deviceId: deviceId, userId: userId,
          timestamp: timestamp, serverRevision: serverRevision, status: status, failureReason: reason);
}
