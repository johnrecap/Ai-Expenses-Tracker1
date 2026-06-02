import 'package:cloud_firestore/cloud_firestore.dart';

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
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.changeType,
    required this.data,
    required this.clientChangeId,
    required this.deviceId,
    required this.userId,
    required this.timestamp,
    this.serverRevision,
    this.status = 'pending',
    this.failureReason,
  });

  factory SyncChange.fromJson(Map<String, dynamic> json) {
    return SyncChange(
      id: json['id'] as String? ?? json['clientChangeId'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      changeType: _changeTypeFromValue(json['changeType'] ?? json['operation']),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      clientChangeId: json['clientChangeId'] as String? ?? json['id'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      timestamp: _dateFromValue(json['timestamp'] ?? json['clientUpdatedAt']),
      serverRevision: (json['serverRevision'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'pending',
      failureReason: json['failureReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType,
    'entityId': entityId,
    'changeType': changeType.name,
    'operation': changeType.name,
    'data': _jsonSafeMap(data),
    'clientChangeId': clientChangeId,
    'deviceId': deviceId,
    'userId': userId,
    'timestamp': timestamp.toIso8601String(),
    'clientUpdatedAt': timestamp.toIso8601String(),
    if (serverRevision != null) 'serverRevision': serverRevision,
    'status': status,
    if (failureReason != null) 'failureReason': failureReason,
  };

  Map<String, dynamic> toPushPayload() => {
    'clientChangeId': clientChangeId,
    'entityType': entityType,
    'entityId': entityId,
    'operation': changeType.name,
    'changeType': changeType.name,
    'data': _jsonSafeMap(data),
    'clientUpdatedAt': timestamp.toIso8601String(),
  };

  SyncChange copyWithApproved({required int serverRevision, required String status}) => SyncChange(
    id: id,
    entityType: entityType,
    entityId: entityId,
    changeType: changeType,
    data: data,
    clientChangeId: clientChangeId,
    deviceId: deviceId,
    userId: userId,
    timestamp: timestamp,
    serverRevision: serverRevision,
    status: status,
  );

  SyncChange copyWithFailed({required String reason, required String status}) => SyncChange(
    id: id,
    entityType: entityType,
    entityId: entityId,
    changeType: changeType,
    data: data,
    clientChangeId: clientChangeId,
    deviceId: deviceId,
    userId: userId,
    timestamp: timestamp,
    serverRevision: serverRevision,
    status: status,
    failureReason: reason,
  );

  static SyncChangeType _changeTypeFromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'delete' || normalized == 'deleted') {
      return SyncChangeType.delete;
    }
    return SyncChangeType.upsert;
  }

  static DateTime _dateFromValue(Object? value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static Map<String, dynamic> _jsonSafeMap(Map<String, dynamic> value) {
    return value.map((key, item) => MapEntry(key, _jsonSafe(item)));
  }

  static Object? _jsonSafe(Object? value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), _jsonSafe(item)));
    }
    if (value is Iterable) return value.map(_jsonSafe).toList();
    return value;
  }
}
