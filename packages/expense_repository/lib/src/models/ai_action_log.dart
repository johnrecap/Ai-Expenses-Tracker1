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

class AiActionLogPrivacy {
  AiActionLogPrivacy._();

  static AiActionLog sanitize(AiActionLog log) {
    return AiActionLog(
      actionId: log.actionId,
      userId: log.userId,
      actionType: _safeLabel(log.actionType, fallback: 'ai_action'),
      input: '',
      output: null,
      structuredJson: _sanitizeStructuredJson(log.structuredJson),
      success: log.success,
      error: log.error == null ? null : 'AI request failed.',
      quotaUsed: log.quotaUsed < 0 ? 0 : log.quotaUsed,
      createdAt: log.createdAt,
    );
  }

  static Map<String, dynamic>? _sanitizeStructuredJson(
    Map<String, dynamic>? value,
  ) {
    if (value == null || value.isEmpty) return null;

    final sanitized = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = entry.key.trim();
      if (key.isEmpty || _isSensitiveKey(key)) continue;

      final normalized = key.toLowerCase();
      final rawValue = entry.value;
      if (rawValue is bool) {
        sanitized[key] = rawValue;
      } else if (rawValue is num && _safeNumericKeys.contains(normalized)) {
        sanitized[key] = rawValue;
      } else if (rawValue is String && _safeStringKeys.contains(normalized)) {
        sanitized[key] = _safeLabel(rawValue);
      } else if (rawValue is List && normalized == 'missingfields') {
        sanitized[key] = rawValue
            .whereType<String>()
            .map(_safeLabel)
            .where((item) => item.isNotEmpty)
            .take(10)
            .toList(growable: false);
      }
    }
    return sanitized.isEmpty ? null : Map.unmodifiable(sanitized);
  }

  static String _safeLabel(String value, {String fallback = ''}) {
    final normalized = value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_');
    if (normalized.isEmpty) return fallback;
    return normalized.length <= 64 ? normalized : normalized.substring(0, 64);
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    if (normalized == 'id' || normalized.endsWith('id')) return true;
    return _sensitiveKeyParts.any((part) => normalized.contains(part));
  }

  static const _safeStringKeys = {
    'actiontype',
    'errorcode',
    'intent',
    'locale',
    'source',
    'status',
    'type',
  };

  static const _safeNumericKeys = {
    'confidence',
    'quotaused',
  };

  static const _sensitiveKeyParts = {
    'amount',
    'balance',
    'budget',
    'category',
    'description',
    'email',
    'expense',
    'input',
    'merchant',
    'name',
    'note',
    'output',
    'price',
    'prompt',
    'raw',
    'response',
    'subscription',
    'text',
    'total',
    'user',
    'wallet',
  };
}
