import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../data/ai_gateway_models.dart';
import 'advice_summary.dart';

const int aiAdviceTopCategoryLimit = 5;
const int aiAdviceTrendFlagLimit = 5;
const int aiAdviceRiskFlagLimit = 5;

class AiAdviceRequestMapper {
  const AiAdviceRequestMapper({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  AiGatewayAdviceRequest map(
    AdviceSummary summary, {
    required String locale,
    required DateTime now,
    String? clientRequestId,
  }) {
    return AiGatewayAdviceRequest(
      period: _gatewayPeriod(summary),
      now: now,
      locale: locale,
      defaultCurrency: summary.currency,
      clientRequestId: clientRequestId ?? _uuid.v4(),
      summary: _compactSummary(summary),
    );
  }

  Map<String, Object?> _compactSummary(AdviceSummary summary) {
    return {
      'summaryHash': summary.summaryHash,
      'currency': summary.currency,
      'totalSpent': _roundMoney(summary.totalSpent),
      'dailyAverage': _roundMoney(summary.dailyAverage),
      'budgetAmount': _roundMoney(summary.budgetAmount),
      'budgetRemaining': _roundMoney(summary.budgetRemaining),
      'budgetUsedPercent': _roundPercent(summary.budgetUsedPercent),
      'topCategories': summary.topCategories
          .take(aiAdviceTopCategoryLimit)
          .map(
            (category) => {
              'name': category.name,
              'amount': _roundMoney(category.amount),
              'percent': _roundPercent(category.percent),
            },
          )
          .toList(),
      'categoryTrendFlags': summary.categoryTrendFlags
          .where((flag) => flag.trim().isNotEmpty)
          .take(aiAdviceTrendFlagLimit)
          .toList(),
      'subscriptionsTotal': _roundMoney(summary.subscriptionsTotal),
      'recurringTotal': _roundMoney(summary.recurringTotal),
      'walletBalancesSummary': _sanitizeNestedMap(
        summary.walletBalancesSummary.toJson(),
      ),
      'savingGoalsProgress': _sanitizeNestedMap(summary.savingGoalsProgress.toJson()),
      'monthComparisonPercent': _roundPercent(summary.monthComparisonPercent),
      'riskFlags': summary.riskFlags
          .where((flag) => flag.trim().isNotEmpty)
          .take(aiAdviceRiskFlagLimit)
          .toList(),
    };
  }

  String _gatewayPeriod(AdviceSummary summary) {
    final label = summary.period.label.toLowerCase();
    if (label.contains('week')) return 'week';
    return 'month';
  }

  Map<String, Object?> _sanitizeNestedMap(Map<String, Object?> input) {
    final output = <String, Object?>{};
    for (final entry in input.entries) {
      if (_looksLikeRawKey(entry.key)) continue;
      output[entry.key] = _sanitizeValue(entry.value);
    }
    return output;
  }

  Object? _sanitizeValue(Object? value) {
    if (value is num) return _roundMoney(value.toDouble());
    if (value is String) return value;
    if (value is bool || value == null) return value;
    if (value is Map<String, Object?>) return _sanitizeNestedMap(value);
    if (value is Map) {
      return _sanitizeNestedMap(
        value.map((key, item) => MapEntry('$key', item)),
      );
    }
    if (value is Iterable) {
      return value.take(5).map(_sanitizeValue).toList();
    }
    return '$value';
  }

  bool _looksLikeRawKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('merchant') ||
        normalized.contains('description') ||
        normalized.contains('receipt') ||
        normalized.contains('rawtext') ||
        normalized.contains('transaction') ||
        normalized.contains('expense');
  }

  double _roundMoney(double value) => double.parse(value.toStringAsFixed(2));

  double _roundPercent(double value) => double.parse(value.toStringAsFixed(1));
}

String hashAdviceSummaryJson(Map<String, Object?> summaryJson) {
  return sha256.convert(utf8.encode(jsonEncode(summaryJson))).toString();
}
