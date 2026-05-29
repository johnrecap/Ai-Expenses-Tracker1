class AiActionLog {
  final String actionId;
  final String userId;
  final String actionType;
  final String input;
  final String? output;
  final Map<String, dynamic>? structuredJson;
  final bool success;
  final String? error;
  final int quotaUsed;
  final DateTime createdAt;

  const AiActionLog({
    required this.actionId, required this.userId, required this.actionType,
    required this.input, this.output, this.structuredJson,
    required this.success, this.error, this.quotaUsed = 0,
    required this.createdAt,
  });
}
