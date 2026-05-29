import 'models/ai_action_log.dart';

abstract class AiActionLogRepository {
  Future<void> logAction(AiActionLog log);
  Future<List<AiActionLog>> getLogs({int limit = 50});
  Stream<List<AiActionLog>> watchLogs({int limit = 50});
}
