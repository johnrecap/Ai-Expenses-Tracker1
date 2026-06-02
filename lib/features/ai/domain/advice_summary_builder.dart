import 'package:expense_repository/expense_repository.dart';

import 'advice_summary.dart';

class AdviceSummaryBuilder {
  const AdviceSummaryBuilder();

  AdviceSummary build({
    required List<Expense> expenses,
    Budget? budget,
    List<WalletAccount> wallets = const [],
    List<SavingGoal> savingGoals = const [],
    List<RecurringExpense> recurringExpenses = const [],
    DateTime? now,
    String? currency,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final period = AdviceSummaryPeriod.currentMonth(effectiveNow);
    final currentMonthExpenses = expenses
        .where((expense) => _isInRange(expense.date, period.start, period.end))
        .toList();
    final previousStart = DateTime(effectiveNow.year, effectiveNow.month - 1);
    final previousEnd = DateTime(effectiveNow.year, effectiveNow.month);
    final previousMonthExpenses = expenses
        .where((expense) => _isInRange(expense.date, previousStart, previousEnd))
        .toList();

    final summaryCurrency =
        currency ??
        budget?.currency ??
        _firstNonEmpty(currentMonthExpenses.map((expense) => expense.currency)) ??
        _firstNonEmpty(wallets.map((wallet) => wallet.currency)) ??
        'EGP';

    final totalSpent = _sum(currentMonthExpenses.map((expense) => expense.amount));
    final previousTotal = _sum(previousMonthExpenses.map((expense) => expense.amount));
    final dayCount =
        effectiveNow.month == period.start.month && effectiveNow.year == period.start.year
        ? effectiveNow.day
        : period.end.difference(period.start).inDays;
    final dailyAverage = dayCount > 0 ? totalSpent / dayCount : 0.0;
    final budgetAmount = budget?.amount ?? 0.0;
    final budgetRemaining = budgetAmount > 0 ? budgetAmount - totalSpent : 0.0;
    final budgetUsedPercent = budgetAmount > 0 ? totalSpent / budgetAmount * 100 : 0.0;

    final categoryTotals = <String, double>{};
    for (final expense in currentMonthExpenses) {
      final categoryName = _safeLabel(expense.categoryName);
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + expense.amount;
    }

    final topCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recurringTotal = _sum(recurringExpenses.map((expense) => expense.amount));
    final walletTotal = _sum(wallets.map((wallet) => wallet.balance));
    final totalGoalTarget = _sum(savingGoals.map((goal) => goal.targetAmount));
    final totalGoalSaved = _sum(savingGoals.map((goal) => goal.currentAmount));
    final monthComparisonPercent = previousTotal > 0
        ? (totalSpent - previousTotal) / previousTotal * 100
        : 0.0;

    return AdviceSummary(
      period: period,
      currency: summaryCurrency,
      totalSpent: totalSpent,
      dailyAverage: dailyAverage,
      budgetAmount: budgetAmount,
      budgetRemaining: budgetRemaining,
      budgetUsedPercent: budgetUsedPercent,
      topCategories: topCategories
          .take(5)
          .map(
            (entry) => CategorySpendSummary(
              categoryName: entry.key,
              amount: entry.value,
              percent: totalSpent > 0 ? entry.value / totalSpent * 100 : 0,
            ),
          )
          .toList(growable: false),
      categoryTrendFlags: _trendFlags(
        budgetUsedPercent: budgetUsedPercent,
        monthComparisonPercent: monthComparisonPercent,
        topCategories: topCategories,
      ),
      subscriptionsTotal: recurringTotal,
      recurringTotal: recurringTotal,
      walletBalancesSummary: WalletBalancesSummary(
        totalBalance: walletTotal,
        walletCount: wallets.length,
      ),
      savingGoalsProgress: SavingGoalsProgress(
        totalTarget: totalGoalTarget,
        totalSaved: totalGoalSaved,
        averageProgressPercent: totalGoalTarget > 0 ? totalGoalSaved / totalGoalTarget * 100 : 0,
        activeGoalCount: savingGoals.length,
      ),
      monthComparisonPercent: monthComparisonPercent,
      riskFlags: _riskFlags(
        budgetUsedPercent: budgetUsedPercent,
        budgetRemaining: budgetRemaining,
        recurringTotal: recurringTotal,
        totalSpent: totalSpent,
      ),
    );
  }

  static bool _isInRange(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  static double _sum(Iterable<double> values) {
    return values.fold<double>(0, (total, value) => total + value);
  }

  static String _safeLabel(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Uncategorized' : trimmed;
  }

  static String? _firstNonEmpty(Iterable<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static List<String> _trendFlags({
    required double budgetUsedPercent,
    required double monthComparisonPercent,
    required List<MapEntry<String, double>> topCategories,
  }) {
    final flags = <String>[];
    if (budgetUsedPercent >= 100) {
      flags.add('budget_over_limit');
    } else if (budgetUsedPercent >= 80) {
      flags.add('budget_near_limit');
    }
    if (monthComparisonPercent >= 15) {
      flags.add('spending_up_vs_last_month');
    } else if (monthComparisonPercent <= -15) {
      flags.add('spending_down_vs_last_month');
    }
    if (topCategories.isNotEmpty) {
      flags.add('top_category_${_flagSlug(topCategories.first.key)}');
    }
    return flags.take(5).toList(growable: false);
  }

  static List<String> _riskFlags({
    required double budgetUsedPercent,
    required double budgetRemaining,
    required double recurringTotal,
    required double totalSpent,
  }) {
    final flags = <String>[];
    if (budgetUsedPercent >= 100) {
      flags.add('overspending');
    } else if (budgetUsedPercent >= 80) {
      flags.add('budget_near_limit');
    }
    if (budgetRemaining < 0) {
      flags.add('negative_budget_remaining');
    }
    if (totalSpent > 0 && recurringTotal / totalSpent >= 0.25) {
      flags.add('high_recurring_share');
    }
    return flags.take(5).toList(growable: false);
  }

  static String _flagSlug(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return slug.isEmpty ? 'uncategorized' : slug;
  }
}
