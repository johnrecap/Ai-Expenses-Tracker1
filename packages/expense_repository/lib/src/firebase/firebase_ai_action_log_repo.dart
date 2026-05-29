import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseAiActionLogRepository implements AiActionLogRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseAiActionLogRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        assert(userId.isNotEmpty);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/aiActions');

  @override
  Future<void> logAction(AiActionLog log) async {
    await _col.doc(log.actionId).set(_toDoc(log));
  }

  @override
  Future<List<AiActionLog>> getLogs({int limit = 50}) async {
    final snapshot = await _col.orderBy('createdAt', descending: true).limit(limit).get();
    return snapshot.docs.map((d) => _fromDoc(d.data())).toList().cast<AiActionLog>();
  }

  @override
  Stream<List<AiActionLog>> watchLogs({int limit = 50}) {
    return _col.orderBy('createdAt', descending: true).limit(limit).snapshots().map(
      (snap) => snap.docs.map((d) => _fromDoc(d.data())).toList().cast<AiActionLog>(),
    );
  }

  Map<String, dynamic> _toDoc(AiActionLog log) => {
    'actionId': log.actionId, 'userId': log.userId,
    'actionType': log.actionType, 'input': log.input,
    'output': log.output, 'structuredJson': log.structuredJson,
    'success': log.success, 'error': log.error, 'quotaUsed': log.quotaUsed,
    'createdAt': Timestamp.fromDate(log.createdAt),
  };

  AiActionLog _fromDoc(Map<String, dynamic> d) {
    DateTime ts(v) => v is Timestamp ? v.toDate() : DateTime.now();
    return AiActionLog(
      actionId: d['actionId'] as String? ?? '',
      userId: d['userId'] as String? ?? '',
      actionType: d['actionType'] as String? ?? '',
      input: d['input'] as String? ?? '',
      output: d['output'] as String?,
      structuredJson: d['structuredJson'] as Map<String, dynamic>?,
      success: d['success'] as bool? ?? false,
      error: d['error'] as String?,
      quotaUsed: d['quotaUsed'] as int? ?? 0,
      createdAt: ts(d['createdAt']),
    );
  }
}
