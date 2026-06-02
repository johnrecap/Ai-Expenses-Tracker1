import '../data/ai_gateway_models.dart';

class AiAdviceCacheEntry {
  const AiAdviceCacheEntry({
    required this.summaryHash,
    required this.period,
    required this.locale,
    required this.response,
    required this.createdAt,
  });

  final String summaryHash;
  final String period;
  final String locale;
  final AiGatewayAdviceResponse response;
  final DateTime createdAt;
}

class AiAdviceCache {
  AiAdviceCache({this.ttl = const Duration(hours: 6)});

  final Duration ttl;
  final Map<String, AiAdviceCacheEntry> _entries = {};

  AiGatewayAdviceResponse? read({
    required String summaryHash,
    required String period,
    required String locale,
    DateTime? now,
  }) {
    final key = _key(summaryHash: summaryHash, period: period, locale: locale);
    final entry = _entries[key];
    if (entry == null) return null;
    final currentTime = now ?? DateTime.now();
    if (currentTime.difference(entry.createdAt) > ttl) {
      _entries.remove(key);
      return null;
    }
    return entry.response;
  }

  void write({
    required String summaryHash,
    required String period,
    required String locale,
    required AiGatewayAdviceResponse response,
    DateTime? createdAt,
  }) {
    final key = _key(summaryHash: summaryHash, period: period, locale: locale);
    _entries[key] = AiAdviceCacheEntry(
      summaryHash: summaryHash,
      period: period,
      locale: locale,
      response: response,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  void invalidateSummary(String summaryHash) {
    _entries.removeWhere((_, entry) => entry.summaryHash == summaryHash);
  }

  void clear() {
    _entries.clear();
  }

  String _key({
    required String summaryHash,
    required String period,
    required String locale,
  }) {
    return '$summaryHash|$period|$locale';
  }
}
