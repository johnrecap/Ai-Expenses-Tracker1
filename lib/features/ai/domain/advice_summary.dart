// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:crypto/crypto.dart';

class AdviceSummary {
  AdviceSummary({
    required Object period,
    required this.currency,
    required this.totalSpent,
    required this.dailyAverage,
    double? budgetAmount,
    double? budgetRemaining,
    double? budgetUsedPercent,
    List<AdviceSummaryCategory> topCategories = const [],
    List<String> categoryTrendFlags = const [],
    this.subscriptionsTotal = 0,
    this.recurringTotal = 0,
    Object? walletBalancesSummary,
    Object? savingGoalsProgress,
    double? monthComparisonPercent,
    List<String> riskFlags = const [],
    String? summaryHash,
  }) : period = AdviceSummaryPeriod.from(period),
       budgetAmount = budgetAmount ?? 0,
       budgetRemaining = budgetRemaining ?? 0,
       budgetUsedPercent = budgetUsedPercent ?? 0,
       topCategories = List.unmodifiable(topCategories.take(5)),
       categoryTrendFlags = List.unmodifiable(categoryTrendFlags.take(5)),
       walletBalancesSummary = WalletBalancesSummary.from(walletBalancesSummary),
       savingGoalsProgress = SavingGoalsProgress.from(savingGoalsProgress),
       monthComparisonPercent = monthComparisonPercent ?? 0,
       riskFlags = List.unmodifiable(riskFlags.take(5)),
       _summaryHash = summaryHash;

  factory AdviceSummary.empty({
    DateTime? now,
    String currency = 'EGP',
  }) {
    final effectiveNow = now ?? DateTime.now();
    return AdviceSummary(
      period: AdviceSummaryPeriod.currentMonth(effectiveNow),
      currency: currency,
      totalSpent: 0,
      dailyAverage: 0,
      budgetAmount: 0,
      budgetRemaining: 0,
      budgetUsedPercent: 0,
      topCategories: const [],
      categoryTrendFlags: const [],
      subscriptionsTotal: 0,
      recurringTotal: 0,
      walletBalancesSummary: const WalletBalancesSummary(
        totalBalance: 0,
        walletCount: 0,
      ),
      savingGoalsProgress: const SavingGoalsProgress(
        totalTarget: 0,
        totalSaved: 0,
        averageProgressPercent: 0,
        activeGoalCount: 0,
      ),
      monthComparisonPercent: 0,
      riskFlags: const [],
    );
  }

  final AdviceSummaryPeriod period;
  final String currency;
  final double totalSpent;
  final double dailyAverage;
  final double budgetAmount;
  final double budgetRemaining;
  final double budgetUsedPercent;
  final List<AdviceSummaryCategory> topCategories;
  final List<String> categoryTrendFlags;
  final double subscriptionsTotal;
  final double recurringTotal;
  final WalletBalancesSummary walletBalancesSummary;
  final SavingGoalsProgress savingGoalsProgress;
  final double monthComparisonPercent;
  final List<String> riskFlags;
  final String? _summaryHash;

  String get summaryHash {
    if (_summaryHash != null) return _summaryHash;
    final bytes = utf8.encode(jsonEncode(toJson()));
    return sha256.convert(bytes).toString();
  }

  Map<String, Object?> toJson() {
    return {
      'period': period.toJson(),
      'currency': currency,
      'totalSpent': _round(totalSpent),
      'dailyAverage': _round(dailyAverage),
      'budgetAmount': _round(budgetAmount),
      'budgetRemaining': _round(budgetRemaining),
      'budgetUsedPercent': _round(budgetUsedPercent),
      'topCategories': topCategories.take(5).map((item) => item.toJson()).toList(),
      'categoryTrendFlags': categoryTrendFlags.take(5).toList(),
      'subscriptionsTotal': _round(subscriptionsTotal),
      'recurringTotal': _round(recurringTotal),
      'walletBalancesSummary': walletBalancesSummary.toJson(),
      'savingGoalsProgress': savingGoalsProgress.toJson(),
      'monthComparisonPercent': _round(monthComparisonPercent),
      'riskFlags': riskFlags.take(5).toList(),
    };
  }

  static double _round(double value) => double.parse(value.toStringAsFixed(2));
}

class AdviceSummaryPeriod {
  const AdviceSummaryPeriod({
    required this.label,
    required this.start,
    required this.end,
  });

  factory AdviceSummaryPeriod.currentMonth(DateTime now) {
    return AdviceSummaryPeriod(
      label: 'current_month',
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1),
    );
  }

  factory AdviceSummaryPeriod.from(Object value) {
    if (value is AdviceSummaryPeriod) return value;
    return AdviceSummaryPeriod(
      label: value.toString(),
      start: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      end: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String label;
  final DateTime start;
  final DateTime end;

  Map<String, Object?> toJson() {
    return {
      'label': label,
      'start': _dateOnly(start),
      'end': _dateOnly(end),
    };
  }

  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class AdviceSummaryCategory {
  const AdviceSummaryCategory({
    required this.name,
    required this.amount,
    required this.percent,
  });

  final String name;
  final double amount;
  final double percent;

  String get categoryName => name;

  Map<String, Object?> toJson() {
    return {
      'categoryName': name,
      'amount': AdviceSummary._round(amount),
      'percent': AdviceSummary._round(percent),
    };
  }
}

class CategorySpendSummary extends AdviceSummaryCategory {
  const CategorySpendSummary({
    required String categoryName,
    required super.amount,
    required super.percent,
  }) : super(name: categoryName);
}

class WalletBalancesSummary {
  const WalletBalancesSummary({
    required this.totalBalance,
    required this.walletCount,
    this.extra = const {},
  });

  factory WalletBalancesSummary.from(Object? value) {
    if (value is WalletBalancesSummary) return value;
    if (value is Map) {
      final totalBalance = value['totalBalance'];
      final walletCount = value['walletCount'];
      return WalletBalancesSummary(
        totalBalance: totalBalance is num ? totalBalance.toDouble() : 0,
        walletCount: walletCount is num ? walletCount.toInt() : 0,
        extra: Map<String, Object?>.from(value)
          ..remove('totalBalance')
          ..remove('walletCount'),
      );
    }
    return const WalletBalancesSummary(totalBalance: 0, walletCount: 0);
  }

  final double totalBalance;
  final int walletCount;
  final Map<String, Object?> extra;

  Map<String, Object?> toJson() {
    return {
      'totalBalance': AdviceSummary._round(totalBalance),
      'walletCount': walletCount,
      ...extra,
    };
  }
}

class SavingGoalsProgress {
  const SavingGoalsProgress({
    required this.totalTarget,
    required this.totalSaved,
    required this.averageProgressPercent,
    required this.activeGoalCount,
    this.extra = const {},
  });

  factory SavingGoalsProgress.from(Object? value) {
    if (value is SavingGoalsProgress) return value;
    if (value is Map) {
      final totalTarget = value['totalTarget'];
      final totalSaved = value['totalSaved'];
      final averageProgressPercent = value['averageProgressPercent'];
      final activeGoalCount = value['activeGoalCount'] ?? value['activeGoals'];
      return SavingGoalsProgress(
        totalTarget: totalTarget is num ? totalTarget.toDouble() : 0,
        totalSaved: totalSaved is num ? totalSaved.toDouble() : 0,
        averageProgressPercent: averageProgressPercent is num
            ? averageProgressPercent.toDouble()
            : 0,
        activeGoalCount: activeGoalCount is num ? activeGoalCount.toInt() : 0,
        extra: Map<String, Object?>.from(value)
          ..remove('totalTarget')
          ..remove('totalSaved')
          ..remove('averageProgressPercent')
          ..remove('activeGoalCount')
          ..remove('activeGoals'),
      );
    }
    return const SavingGoalsProgress(
      totalTarget: 0,
      totalSaved: 0,
      averageProgressPercent: 0,
      activeGoalCount: 0,
    );
  }

  final double totalTarget;
  final double totalSaved;
  final double averageProgressPercent;
  final int activeGoalCount;
  final Map<String, Object?> extra;

  Map<String, Object?> toJson() {
    return {
      'totalTarget': AdviceSummary._round(totalTarget),
      'totalSaved': AdviceSummary._round(totalSaved),
      'averageProgressPercent': AdviceSummary._round(averageProgressPercent),
      'activeGoalCount': activeGoalCount,
      ...extra,
    };
  }
}
