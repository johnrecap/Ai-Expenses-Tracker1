import 'dart:developer' as developer;

import 'package:expense_repository/expense_repository.dart';

/// {@template recurring_detection_service}
/// Analyzes the user's expense history to detect recurring spending patterns.
///
/// A "recurring pattern" is identified when the same merchant / description
/// appears multiple times with similar amounts and regular time intervals.
/// The service returns a list of [DetectedPattern] objects that can be
/// presented to the user as suggestions for creating [RecurringExpense]
/// entries.
/// {@endtemplate}
class RecurringDetectionService {
  /// Creates a [RecurringDetectionService].
  ///
  /// [expenseRepository] provides access to historical expenses.
  RecurringDetectionService({required this.expenseRepository});

  final ExpenseRepository expenseRepository;

  /// Minimum number of occurrences to consider a pattern valid.
  static const int minOccurrences = 2;

  /// Maximum relative difference between amounts to be considered "similar".
  static const double amountTolerance = 0.15;

  /// Maximum days of deviation from a strict interval to still count as regular.
  static const int dayTolerance = 5;

  /// Analyzes all expenses and returns detected recurring patterns.
  Future<List<DetectedPattern>> detectPatterns() async {
    try {
      final expenses = await expenseRepository.getExpenses();
      if (expenses.length < minOccurrences) return const [];

      // Group expenses by normalized description / merchant.
      final groups = _groupByDescription(expenses);

      final patterns = <DetectedPattern>[];
      for (final group in groups.values) {
        if (group.length < minOccurrences) continue;

        final pattern = _analyzeGroup(group);
        if (pattern != null) {
          patterns.add(pattern);
        }
      }

      // Sort by confidence descending.
      patterns.sort((a, b) => b.confidence.compareTo(a.confidence));
      return patterns;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Recurring detection failed',
        name: 'RecurringDetectionService',
        error: e,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  /// Checks whether a newly created [expense] matches any existing recurring
  /// pattern and returns the matching pattern, or `null` if none.
  Future<DetectedPattern?> checkExpense(Expense expense) async {
    final patterns = await detectPatterns();
    final normalized = _normalizeDescription(expense.description);

    for (final pattern in patterns) {
      if (_normalizeDescription(pattern.description) == normalized) {
        final amountDiff = (pattern.averageAmount - expense.amount).abs();
        final relativeDiff =
            pattern.averageAmount > 0 ? amountDiff / pattern.averageAmount : 0;
        if (relativeDiff <= amountTolerance) {
          return pattern;
        }
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Grouping
  // ---------------------------------------------------------------------------

  Map<String, List<Expense>> _groupByDescription(List<Expense> expenses) {
    final map = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = _normalizeDescription(e.description);
      if (key.isEmpty) continue;
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  String _normalizeDescription(String description) {
    return description
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
  }

  // ---------------------------------------------------------------------------
  // Pattern analysis
  // ---------------------------------------------------------------------------

  DetectedPattern? _analyzeGroup(List<Expense> group) {
    // Sort by date ascending.
    group.sort((a, b) => a.date.compareTo(b.date));

    final amounts = group.map((e) => e.amount).toList();
    final avgAmount = amounts.reduce((a, b) => a + b) / amounts.length;

    // Filter out outliers.
    final similar = group.where((e) {
      final diff = (e.amount - avgAmount).abs();
      return avgAmount > 0 ? diff / avgAmount <= amountTolerance : true;
    }).toList();

    if (similar.length < minOccurrences) return null;

    // Compute intervals in days between consecutive expenses.
    final intervals = <int>[];
    for (var i = 1; i < similar.length; i++) {
      final days = similar[i].date.difference(similar[i - 1].date).inDays;
      if (days > 0) intervals.add(days);
    }

    if (intervals.isEmpty) return null;

    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

    // Check regularity: most intervals should be within tolerance of the average.
    final regularIntervals = intervals.where((d) {
      return (d - avgInterval).abs() <= dayTolerance;
    }).length;

    final regularityRatio = intervals.isNotEmpty ? regularIntervals / intervals.length : 0.0;

    // Confidence is based on number of occurrences and regularity.
    final confidence = ((similar.length * 0.1) + (regularityRatio * 0.5)).clamp(0.0, 1.0);

    // Infer frequency label.
    final frequency = _inferFrequency(avgInterval);

    // Latest date in the group.
    final lastDate = similar.last.date;

    // Next expected date based on average interval.
    final nextExpectedDate = lastDate.add(Duration(days: avgInterval.round()));

    return DetectedPattern(
      description: similar.first.description,
      category: similar.first.category,
      averageAmount: avgAmount,
      currency: similar.first.currency,
      frequency: frequency,
      occurrences: similar.length,
      lastDate: lastDate,
      nextExpectedDate: nextExpectedDate,
      confidence: confidence,
      sampleExpenseIds: similar.map((e) => e.expenseId).toList(),
    );
  }

  String _inferFrequency(double avgDays) {
    if (avgDays <= 2) return 'daily';
    if (avgDays <= 10) return 'weekly';
    if (avgDays <= 20) return 'biweekly';
    if (avgDays <= 40) return 'monthly';
    if (avgDays <= 100) return 'quarterly';
    return 'yearly';
  }
}

/// {@template detected_pattern}
/// Represents a recurring spending pattern detected in the user's history.
/// {@endtemplate}
class DetectedPattern {
  /// Creates a [DetectedPattern].
  const DetectedPattern({
    required this.description,
    required this.category,
    required this.averageAmount,
    required this.currency,
    required this.frequency,
    required this.occurrences,
    required this.lastDate,
    required this.nextExpectedDate,
    required this.confidence,
    required this.sampleExpenseIds,
  });

  /// The common description / merchant name.
  final String description;

  /// The most common category for this pattern.
  final Category category;

  /// Average monetary amount across occurrences.
  final double averageAmount;

  /// Currency code (e.g. 'EGP').
  final String currency;

  /// Inferred frequency label: daily, weekly, biweekly, monthly, quarterly, yearly.
  final String frequency;

  /// Number of matching occurrences found.
  final int occurrences;

  /// Date of the most recent occurrence.
  final DateTime lastDate;

  /// Predicted date of the next occurrence.
  final DateTime nextExpectedDate;

  /// Confidence score (0.0 to 1.0).
  final double confidence;

  /// IDs of the expenses that formed this pattern.
  final List<String> sampleExpenseIds;

  /// Whether the pattern is strong enough to suggest to the user.
  bool get isStrong => confidence >= 0.6 && occurrences >= 3;
}
