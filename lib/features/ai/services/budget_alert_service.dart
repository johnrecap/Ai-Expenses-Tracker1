import 'dart:developer' as developer;

import 'package:expense_repository/expense_repository.dart';

import '../../../services/notifications/notification_service.dart';

/// {@template budget_alert_service}
/// Monitors the user's spending against their monthly budget and triggers
/// local notifications when thresholds are crossed.
///
/// The service checks the current month's total expenses against the active
/// [Budget] and fires alerts at configurable percentages (default 50%, 80%,
/// 100%). It also supports programmatic queries so the UI can display
/// alert banners without relying solely on push notifications.
/// {@endtemplate}
class BudgetAlertService {
  /// Creates a [BudgetAlertService].
  ///
  /// [expenseRepository] and [budgetRepository] provide the data needed to
  /// compute spending ratios. [notificationService] is used to display alerts.
  BudgetAlertService({
    required this.expenseRepository,
    required this.budgetRepository,
    required this.notificationService,
  });

  final ExpenseRepository expenseRepository;
  final BudgetRepository budgetRepository;
  final NotificationService notificationService;

  /// Threshold percentages at which alerts are fired.
  static const List<int> defaultThresholds = [50, 80, 100];

  /// Checks the current month's spending and returns any active alerts.
  ///
  /// Also triggers local notifications for newly crossed thresholds.
  Future<List<BudgetAlert>> checkBudgetAlerts({
    List<int> thresholds = defaultThresholds,
  }) async {
    try {
      final now = DateTime.now();
      final budget = await budgetRepository.getCurrentMonthBudget(
        month: now.month,
        year: now.year,
      );

      if (budget == null || budget.amount <= 0) {
        return const [];
      }

      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final expenses = await expenseRepository.getExpensesByFilter(
        ExpenseFilter(startDate: monthStart, endDate: monthEnd),
      );

      final totalSpent = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
      final percentUsed = budget.amount > 0 ? (totalSpent / budget.amount) * 100 : 0.0;

      final alerts = <BudgetAlert>[];
      for (final threshold in thresholds) {
        if (percentUsed >= threshold) {
          final isNewlyCrossed = await _isNewlyCrossed(threshold, now);
          if (isNewlyCrossed) {
            await _sendNotification(threshold, percentUsed, totalSpent, budget);
          }
          alerts.add(
            BudgetAlert(
              thresholdPercent: threshold,
              currentPercent: percentUsed,
              totalSpent: totalSpent,
              budgetAmount: budget.amount,
              currency: budget.currency,
              isNewlyCrossed: isNewlyCrossed,
            ),
          );
        }
      }

      // Save the highest threshold crossed so we don't spam notifications.
      await _recordHighestThresholdCrossed(
        _highestCrossed(thresholds, percentUsed),
        now,
      );

      return alerts;
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Budget alert check failed',
        name: 'BudgetAlertService',
        error: e,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  /// Returns a quick summary of the current budget status without firing
  /// notifications.
  Future<BudgetStatus> getBudgetStatus() async {
    try {
      final now = DateTime.now();
      final budget = await budgetRepository.getCurrentMonthBudget(
        month: now.month,
        year: now.year,
      );

      if (budget == null || budget.amount <= 0) {
        return const BudgetStatus.noBudget();
      }

      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final expenses = await expenseRepository.getExpensesByFilter(
        ExpenseFilter(startDate: monthStart, endDate: monthEnd),
      );

      final totalSpent = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
      final percentUsed = budget.amount > 0 ? (totalSpent / budget.amount) * 100 : 0.0;
      final remaining = budget.amount - totalSpent;

      return BudgetStatus(
        hasBudget: true,
        budgetAmount: budget.amount,
        totalSpent: totalSpent,
        remaining: remaining,
        percentUsed: percentUsed,
        currency: budget.currency,
        isOverBudget: totalSpent > budget.amount,
        daysRemaining: monthEnd.day - now.day,
      );
    } on Exception catch (e, stackTrace) {
      developer.log(
        'Budget status query failed',
        name: 'BudgetAlertService',
        error: e,
        stackTrace: stackTrace,
      );
      return const BudgetStatus.noBudget();
    }
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  Future<void> _sendNotification(
    int threshold,
    double percentUsed,
    double totalSpent,
    Budget budget,
  ) async {
    final title = _alertTitle(threshold);
    final body = _alertBody(threshold, percentUsed, totalSpent, budget);

    await notificationService.showNotification(
      id: 1000 + threshold,
      title: title,
      body: body,
    );
  }

  String _alertTitle(int threshold) {
    switch (threshold) {
      case 100:
        return 'Budget Exceeded';
      case 80:
        return 'Budget Warning';
      default:
        return 'Budget Alert';
    }
  }

  String _alertBody(int threshold, double percent, double total, Budget budget) {
    final currency = budget.currency;
    if (threshold >= 100) {
      final over = total - budget.amount;
      return 'You have exceeded your monthly budget by ${over.toStringAsFixed(2)} $currency.';
    }
    return 'You have used ${percent.toStringAsFixed(0)}% of your monthly budget (${total.toStringAsFixed(2)} / ${budget.amount.toStringAsFixed(2)} $currency).';
  }

  // ---------------------------------------------------------------------------
  // Threshold tracking (naive in-memory; can be backed by secure storage)
  // ---------------------------------------------------------------------------

  final Map<String, int> _crossedThresholds = {};

  String _key(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}';

  Future<bool> _isNewlyCrossed(int threshold, DateTime now) async {
    final previous = _crossedThresholds[_key(now)] ?? 0;
    return threshold > previous;
  }

  Future<void> _recordHighestThresholdCrossed(int threshold, DateTime now) async {
    _crossedThresholds[_key(now)] = threshold;
  }

  int _highestCrossed(List<int> thresholds, double percentUsed) {
    var highest = 0;
    for (final t in thresholds) {
      if (percentUsed >= t) highest = t;
    }
    return highest;
  }
}

/// {@template budget_alert}
/// Represents a single budget threshold alert.
/// {@endtemplate}
class BudgetAlert {
  /// Creates a [BudgetAlert].
  const BudgetAlert({
    required this.thresholdPercent,
    required this.currentPercent,
    required this.totalSpent,
    required this.budgetAmount,
    required this.currency,
    required this.isNewlyCrossed,
  });

  /// The threshold that was crossed (e.g. 80 for 80%).
  final int thresholdPercent;

  /// The actual percentage of budget used.
  final double currentPercent;

  /// Total amount spent this month.
  final double totalSpent;

  /// The budget limit.
  final double budgetAmount;

  /// Currency code.
  final String currency;

  /// Whether this threshold was crossed for the first time today.
  final bool isNewlyCrossed;

  /// Severity derived from the threshold.
  AlertSeverity get severity {
    if (thresholdPercent >= 100) return AlertSeverity.critical;
    if (thresholdPercent >= 80) return AlertSeverity.warning;
    return AlertSeverity.info;
  }
}

/// {@template budget_status}
/// A snapshot of the current month's budget health.
/// {@endtemplate}
class BudgetStatus {
  /// Creates a [BudgetStatus].
  const BudgetStatus({
    required this.hasBudget,
    required this.budgetAmount,
    required this.totalSpent,
    required this.remaining,
    required this.percentUsed,
    required this.currency,
    required this.isOverBudget,
    required this.daysRemaining,
  });

  /// Factory for when no budget is set.
  const BudgetStatus.noBudget()
      : hasBudget = false,
        budgetAmount = 0,
        totalSpent = 0,
        remaining = 0,
        percentUsed = 0,
        currency = 'EGP',
        isOverBudget = false,
        daysRemaining = 0;

  final bool hasBudget;
  final double budgetAmount;
  final double totalSpent;
  final double remaining;
  final double percentUsed;
  final String currency;
  final bool isOverBudget;
  final int daysRemaining;

  /// Daily spending limit needed to stay within budget for the rest of the month.
  double get suggestedDailyLimit =>
      daysRemaining > 0 ? remaining / daysRemaining : 0;
}

/// Severity levels for budget alerts.
enum AlertSeverity { info, warning, critical }
