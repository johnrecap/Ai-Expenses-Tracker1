import 'package:expense_repository/expense_repository.dart';

class AiPredictionPayload {
  final String period;
  final double expectedTotal;
  final String currency;
  final List<AiPredictionCategoryDriver> categoryDrivers;
  final String qualityNote;
  final DateTime generatedAt;

  const AiPredictionPayload({
    required this.period, required this.expectedTotal, required this.currency,
    required this.categoryDrivers, required this.qualityNote, required this.generatedAt,
  });
}

class AiPredictionCategoryDriver {
  final String category;
  final double expectedAmount;
  final int historyCount;

  const AiPredictionCategoryDriver({required this.category, required this.expectedAmount, required this.historyCount});
}

class AiAdvicePayload {
  final String title;
  final String summary;
  final String severity;
  final DateTime generatedAt;

  const AiAdvicePayload({required this.title, required this.summary, required this.severity, required this.generatedAt});
}

class SpendingPredictionService {
  const SpendingPredictionService();

  AiPredictionPayload predictMonth({required List<Expense> expenses, required DateTime now, required String currency}) {
    final normalizedCurrency = currency.trim().toUpperCase();
    final historical = expenses.where((e) => e.currency.toUpperCase() == normalizedCurrency && e.date.isBefore(DateTime(now.year, now.month))).toList();

    if (historical.isEmpty) {
      return AiPredictionPayload(
        period: 'month', expectedTotal: 0, currency: normalizedCurrency,
        categoryDrivers: const [], qualityNote: 'Not enough history for a prediction.', generatedAt: now,
      );
    }

    final monthTotals = <String, double>{};
    final categoryTotals = <String, _Bucket>{};
    for (final e in historical) {
      final key = '${e.date.year}-${e.date.month}';
      monthTotals[key] = (monthTotals[key] ?? 0) + e.amount;
      final name = e.categoryName.isNotEmpty ? e.categoryName : e.category.name;
      final bucket = categoryTotals.putIfAbsent(name, () => _Bucket());
      bucket.total += e.amount;
      bucket.count++;
    }

    final expectedTotal = monthTotals.values.fold<double>(0, (s, v) => s + v) / monthTotals.length;
    final monthCount = monthTotals.length;
    final drivers = categoryTotals.entries.map((e) => AiPredictionCategoryDriver(
      category: e.key, expectedAmount: e.value.total / monthCount, historyCount: e.value.count,
    )).toList()..sort((a, b) => b.expectedAmount.compareTo(a.expectedAmount));

    return AiPredictionPayload(
      period: 'month', expectedTotal: expectedTotal, currency: normalizedCurrency,
      categoryDrivers: drivers.take(5).toList(),
      qualityNote: 'Based on $monthCount historical month(s), not a financial guarantee.',
      generatedAt: now,
    );
  }
}

class _Bucket { double total = 0; int count = 0; }
