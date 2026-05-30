import 'dart:developer' as developer;

import 'package:expense_repository/expense_repository.dart';

import 'models/ai_parsed_expense.dart';

/// {@template smart_completion}
/// Fills missing fields in an [AiParsedExpense] using historical data from the
/// local Drift database.
///
/// The service queries the user's spending history to infer sensible defaults
/// for missing fields such as category, currency, and amount. It also recalculates
/// the confidence score based on how many fields were successfully completed.
///
/// This is a pure Dart service with no Flutter dependencies — it can be used
/// from BLoCs, services, or directly from the UI layer.
/// {@endtemplate}
class SmartCompletion {
  /// Creates a [SmartCompletion] instance.
  ///
  /// [store] provides synchronous access to the local Drift-backed data.
  SmartCompletion({required this.store});

  /// The local store interface backed by Drift (SQLite).
  final LocalStoreInterface store;

  /// Completes missing fields in [parsed] using database context.
  ///
  /// Returns a new [AiParsedExpense] with inferred values and an updated
  /// confidence score. The original input and already-known fields are
  /// preserved.
  ///
  /// Example:
  /// ```dart
  /// final completed = await smartCompletion.complete(parsedExpense);
  /// print(completed.category); // e.g. "food"
  /// print(completed.confidence); // higher than original
  /// ```
  Future<AiParsedExpense> complete(AiParsedExpense parsed) async {
    if (parsed.missingFields.isEmpty) {
      return parsed;
    }

    try {
      final expenses = store.expenses;
      final categories = store.categories;

      var amount = parsed.amount;
      var currency = parsed.currency;
      var category = parsed.category;
      var date = parsed.date;
      var note = parsed.note;
      var missingFields = List<String>.from(parsed.missingFields);

      // -- Infer category ----------------------------------------------------
      if (missingFields.contains('category')) {
        final inferredCategory = _inferCategory(
          parsed.originalInput,
          expenses,
          categories,
        );
        if (inferredCategory != null) {
          category = inferredCategory;
          missingFields.remove('category');
        }
      }

      // -- Infer currency ----------------------------------------------------
      if (missingFields.contains('currency')) {
        final inferredCurrency = _inferCurrency(expenses);
        if (inferredCurrency != null) {
          currency = inferredCurrency;
          missingFields.remove('currency');
        }
      }

      // -- Infer amount (average of similar expenses) ------------------------
      if (missingFields.contains('amount')) {
        final inferredAmount = _inferAmount(
          parsed.originalInput,
          category,
          expenses,
        );
        if (inferredAmount != null) {
          amount = inferredAmount;
          missingFields.remove('amount');
        }
      }

      // -- Infer date (default to today) -------------------------------------
      if (missingFields.contains('date')) {
        date = DateTime.now();
        missingFields.remove('date');
      }

      // -- Infer note --------------------------------------------------------
      if (missingFields.contains('note') && parsed.originalInput.isNotEmpty) {
        note = parsed.originalInput.trim();
        missingFields.remove('note');
      }

      // -- Recalculate confidence --------------------------------------------
      const totalFields = 5;
      final foundFields = totalFields - missingFields.length;
      final newConfidence = (foundFields / totalFields).clamp(0.0, 1.0);

      // Blend with original confidence so we don't over-promise.
      final blendedConfidence =
          (parsed.confidence * 0.3 + newConfidence * 0.7).clamp(0.0, 1.0);

      return AiParsedExpense(
        amount: amount,
        currency: currency,
        category: category,
        date: date,
        note: note,
        confidence: blendedConfidence,
        missingFields: List<String>.unmodifiable(missingFields),
        originalInput: parsed.originalInput,
      );
    } on Exception catch (e, stackTrace) {
      developer.log(
        'SmartCompletion failed',
        error: e,
        stackTrace: stackTrace,
        name: 'SmartCompletion',
      );
      // Return the original with slightly reduced confidence.
      return parsed.copyWith(
        confidence: (parsed.confidence * 0.9).clamp(0.0, 1.0),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Private inference helpers
  // -------------------------------------------------------------------------

  /// Infers a category from the user's input text and historical data.
  ///
  /// First tries keyword matching against known category aliases and names,
  /// then falls back to the most frequently used category overall.
  String? _inferCategory(
    String input,
    List<Expense> expenses,
    List<Category> categories,
  ) {
    final lowerInput = input.toLowerCase();

    // 1. Try to match category aliases (e.g. "lunch" -> "food").
    for (final alias in store.categoryAliases) {
      if (lowerInput.contains(alias.name.toLowerCase())) {
        final match = categories.firstWhere(
          (c) => c.categoryId == alias.categoryId,
          orElse: () => Category.empty,
        );
        if (match.categoryId.isNotEmpty) {
          return match.name.toLowerCase();
        }
      }
    }

    // 2. Try to match category names directly.
    for (final cat in categories.where((c) => !c.isArchived)) {
      if (lowerInput.contains(cat.name.toLowerCase())) {
        return cat.name.toLowerCase();
      }
    }

    // 3. Fallback: most frequently used category in the last 30 days.
    final now = DateTime.now();
    final recentExpenses = expenses.where(
      (e) => e.date.isAfter(now.subtract(const Duration(days: 30))),
    );

    if (recentExpenses.isEmpty) {
      // Global fallback: most used category ever.
      return _mostFrequentCategory(expenses);
    }

    return _mostFrequentCategory(recentExpenses.toList());
  }

  /// Returns the most frequently occurring category name in [expenses].
  String? _mostFrequentCategory(List<Expense> expenses) {
    if (expenses.isEmpty) return null;

    final frequency = <String, int>{};
    for (final e in expenses) {
      final name = e.categoryName.toLowerCase();
      frequency[name] = (frequency[name] ?? 0) + 1;
    }

    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  /// Infers the user's default currency from historical expenses.
  String? _inferCurrency(List<Expense> expenses) {
    if (expenses.isEmpty) {
      // Fallback to settings if available.
      final settings = store.settings;
      if (settings != null && settings.baseCurrency.isNotEmpty) {
        return settings.baseCurrency;
      }
      return 'EGP';
    }

    final frequency = <String, int>{};
    for (final e in expenses) {
      frequency[e.currency] = (frequency[e.currency] ?? 0) + 1;
    }

    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  /// Infers a likely amount based on similar past expenses.
  ///
  /// If [category] is known, averages expenses in that category from the
  /// last 90 days. Otherwise averages all recent expenses.
  double? _inferAmount(String input, String? category, List<Expense> expenses) {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 90));

    List<Expense> relevant;
    if (category != null && category.isNotEmpty) {
      relevant = expenses.where(
        (e) =>
            e.categoryName.toLowerCase() == category.toLowerCase() &&
            e.date.isAfter(cutoff),
      ).toList();
    } else {
      relevant = expenses.where((e) => e.date.isAfter(cutoff)).toList();
    }

    if (relevant.isEmpty) {
      // Try without the 90-day window.
      if (category != null && category.isNotEmpty) {
        relevant = expenses
            .where(
              (e) => e.categoryName.toLowerCase() == category.toLowerCase(),
            )
            .toList();
      } else {
        relevant = expenses;
      }
    }

    if (relevant.isEmpty) return null;

    final total = relevant.fold<double>(0.0, (sum, e) => sum + e.amount);
    final average = total / relevant.length;

    // Round to a sensible number of decimal places.
    return double.parse(average.toStringAsFixed(2));
  }
}
