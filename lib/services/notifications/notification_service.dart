import 'dart:async';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> showNotification({required String title, required String body, int id = 0}) async {
    if (!_initialized) return;
    await _plugin.show(id, title, body, const NotificationDetails(
      android: AndroidNotificationDetails('expenses', 'Expense Alerts', importance: Importance.high),
      iOS: DarwinNotificationDetails(),
    ));
  }

  Future<void> scheduleNotification({required String title, required String body, required DateTime scheduledDate, int id = 0}) async {
    if (!_initialized) return;
    await _plugin.zonedSchedule(id, title, body, tz.TZDateTime.from(scheduledDate, tz.local), const NotificationDetails(
      android: AndroidNotificationDetails('reminders', 'Reminders'),
      iOS: DarwinNotificationDetails(),
    ), androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }
}

class NotificationScheduler {
  final ExpenseRepository expenseRepository;

  NotificationScheduler(this.expenseRepository);

  Future<void> handleExpenseCreated({required Expense expense, required BudgetRepository budgetRepo}) async {
    try {
      final budget = await budgetRepo.getCurrentMonthBudget(month: expense.date.month, year: expense.date.year);
      if (budget == null) return;
      final expenses = await expenseRepository.getExpensesByFilter(
        ExpenseFilter(startDate: DateTime(budget.year, budget.month, 1)),
      );
      final total = expenses.fold<double>(0, (s, e) => s + e.amount);
      final pct = budget.amount > 0 ? total / budget.amount * 100 : 0;
      if (pct >= budget.warningThresholdPercent) {
        await NotificationService.instance.showNotification(
          title: 'Budget Alert',
          body: 'You have used ${pct.round()}% of your monthly budget.',
        );
      }
    } catch (_) {}
  }

  Future<void> checkSubscriptions(List<Map<String, dynamic>> subscriptions) async {
    for (final sub in subscriptions) {
      final renewal = sub['nextRenewalDate'] as DateTime?;
      if (renewal != null) {
        final days = renewal.difference(DateTime.now()).inDays;
        if (days <= 3 && days > 0) {
          await NotificationService.instance.showNotification(
            title: 'Subscription Renewal',
            body: '${sub['name']} renews in $days days.',
          );
        }
      }
    }
  }
}
