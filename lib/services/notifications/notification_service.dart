import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService();
  static const scheduledReminderNotificationId = 1000;
  static const dailyReminderNotificationId = 1001;
  static const managedScheduledNotificationIds = <int>[
    scheduledReminderNotificationId,
    dailyReminderNotificationId,
  ];

  NotificationService({NotificationPlatform? platform})
    : _platform = platform ?? FlutterLocalNotificationPlatform();

  final NotificationPlatform _platform;
  bool _initialized = false;
  Future<void>? _initializing;

  Future<void> initialize() async {
    if (_initialized) return;
    final existingInitialization = _initializing;
    if (existingInitialization != null) return existingInitialization;

    final initialization = _platform.initialize();
    _initializing = initialization;
    try {
      await initialization;
      _initialized = true;
    } finally {
      _initializing = null;
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      await initialize();
      return _platform.requestPermission();
    } catch (_) {
      return false;
    }
  }

  Future<bool> areNotificationsAllowed() async {
    try {
      await initialize();
      return _platform.areNotificationsAllowed();
    } catch (_) {
      return false;
    }
  }

  Future<NotificationDeliveryResult> showNotification({
    required String title,
    required String body,
    int id = 0,
    NotificationSettings? settings,
    NotificationSetting setting = NotificationSetting.budgetAlerts,
  }) async {
    if (settings != null && !_settingEnabled(settings, setting)) {
      return NotificationDeliveryResult.disabledBySettings;
    }

    try {
      await initialize();
      if (!await _platform.areNotificationsAllowed()) {
        return NotificationDeliveryResult.permissionDenied;
      }
      await _platform.show(
        id: id,
        title: title,
        body: body,
        channel: NotificationChannel.expenseAlerts,
      );
      return NotificationDeliveryResult.shown;
    } catch (_) {
      return NotificationDeliveryResult.failed;
    }
  }

  Future<NotificationScheduleResult> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    int id = scheduledReminderNotificationId,
    NotificationSettings? settings,
    NotificationSetting setting = NotificationSetting.recurringReminders,
    bool requestPermissionIfNeeded = true,
  }) async {
    if (settings != null && !_settingEnabled(settings, setting)) {
      return NotificationScheduleResult.disabledBySettings;
    }
    return _schedule(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      id: id,
      channel: NotificationChannel.reminders,
      requestPermissionIfNeeded: requestPermissionIfNeeded,
    );
  }

  Future<NotificationScheduleResult> scheduleDailyReminder({
    required String title,
    required String body,
    String? time24h,
    int id = dailyReminderNotificationId,
    NotificationSettings? settings,
    bool requestPermissionIfNeeded = true,
  }) async {
    final reminderTime = time24h ?? settings?.dailyReminderTime;
    if (settings != null && !settings.dailyReminder) {
      return NotificationScheduleResult.disabledBySettings;
    }
    final parsed = _parseTime24h(reminderTime);
    if (parsed == null) return NotificationScheduleResult.invalidTime;

    return _schedule(
      title: title,
      body: body,
      scheduledDate: _nextOccurrence(parsed),
      id: id,
      channel: NotificationChannel.dailyReminders,
      repeatsDaily: true,
      requestPermissionIfNeeded: requestPermissionIfNeeded,
    );
  }

  Future<NotificationScheduleResult> _schedule({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required int id,
    required NotificationChannel channel,
    bool repeatsDaily = false,
    required bool requestPermissionIfNeeded,
  }) async {
    try {
      await initialize();
      var allowed = await _platform.areNotificationsAllowed();
      if (!allowed && requestPermissionIfNeeded) {
        allowed = await _platform.requestPermission();
      }
      if (!allowed) return NotificationScheduleResult.permissionDenied;

      await _platform.schedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        channel: channel,
        repeatsDaily: repeatsDaily,
      );
      return NotificationScheduleResult.scheduled;
    } catch (_) {
      return NotificationScheduleResult.failed;
    }
  }

  _ReminderTime? _parseTime24h(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return _ReminderTime(hour, minute);
  }

  DateTime _nextOccurrence(_ReminderTime time) {
    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  bool _settingEnabled(NotificationSettings settings, NotificationSetting setting) {
    switch (setting) {
      case NotificationSetting.budgetAlerts:
        return settings.budgetAlerts;
      case NotificationSetting.recurringReminders:
        return settings.recurringReminders;
      case NotificationSetting.subscriptionRenewals:
        return settings.subscriptionRenewals;
      case NotificationSetting.weeklyDigest:
        return settings.weeklyDigest;
      case NotificationSetting.aiQuotaWarnings:
        return settings.aiQuotaWarnings;
      case NotificationSetting.dailyReminder:
        return settings.dailyReminder;
    }
  }

  Future<NotificationCancelResult> cancelManagedNotifications() async {
    try {
      await initialize();
      for (final id in managedScheduledNotificationIds) {
        await _platform.cancel(id);
      }
      return NotificationCancelResult.cancelled;
    } catch (_) {
      return NotificationCancelResult.failed;
    }
  }
}

abstract class NotificationPlatform {
  Future<void> initialize();

  Future<bool> requestPermission();

  Future<bool> areNotificationsAllowed();

  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
  });

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationChannel channel,
    required bool repeatsDaily,
  });

  Future<void> cancel(int id);
}

class FlutterLocalNotificationPlatform implements NotificationPlatform {
  FlutterLocalNotificationPlatform({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _timezoneInitialized = false;

  @override
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final mac = _plugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      return await mac?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  @override
  Future<bool> areNotificationsAllowed() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
  }) {
    return _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.displayName,
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationChannel channel,
    required bool repeatsDaily,
  }) {
    _initializeTimezone();
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.displayName),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: repeatsDaily ? DateTimeComponents.time : null,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);

  void _initializeTimezone() {
    if (_timezoneInitialized) return;
    tzdata.initializeTimeZones();
    _timezoneInitialized = true;
  }
}

enum NotificationSetting {
  budgetAlerts,
  recurringReminders,
  subscriptionRenewals,
  weeklyDigest,
  aiQuotaWarnings,
  dailyReminder,
}

enum NotificationChannel {
  expenseAlerts('expenses', 'Expense Alerts'),
  reminders('reminders', 'Reminders'),
  dailyReminders('daily_reminders', 'Daily reminders');

  const NotificationChannel(this.id, this.displayName);

  final String id;
  final String displayName;
}

enum NotificationDeliveryResult {
  shown,
  disabledBySettings,
  permissionDenied,
  failed,
}

enum NotificationScheduleResult {
  scheduled,
  disabledBySettings,
  permissionDenied,
  invalidTime,
  failed,
}

enum NotificationCancelResult {
  cancelled,
  failed,
}

class NotificationScheduler {
  NotificationScheduler(
    this.expenseRepository, {
    this.settingsRepository,
    NotificationService? notificationService,
  }) : notificationService = notificationService ?? NotificationService.instance;

  final ExpenseRepository expenseRepository;
  final SettingsRepository? settingsRepository;
  final NotificationService notificationService;

  Future<void> handleExpenseCreated({
    required Expense expense,
    required BudgetRepository budgetRepo,
  }) async {
    try {
      final budget = await budgetRepo.getCurrentMonthBudget(
        month: expense.date.month,
        year: expense.date.year,
      );
      if (budget == null) return;
      final expenses = await expenseRepository.getExpensesByFilter(
        ExpenseFilter(startDate: DateTime(budget.year, budget.month, 1)),
      );
      final total = expenses.fold<double>(0, (s, e) => s + e.amount);
      final pct = budget.amount > 0 ? total / budget.amount * 100 : 0;
      if (pct >= budget.warningThresholdPercent) {
        final settings = await _loadNotificationSettings();
        await notificationService.showNotification(
          title: 'Budget Alert',
          body: 'You have used ${pct.round()}% of your monthly budget.',
          settings: settings,
          setting: NotificationSetting.budgetAlerts,
        );
      }
    } catch (_) {}
  }

  Future<void> checkSubscriptions(List<Map<String, dynamic>> subscriptions) async {
    final settings = await _loadNotificationSettings();
    if (settings != null && !settings.subscriptionRenewals) return;

    for (final sub in subscriptions) {
      final renewal = sub['nextRenewalDate'] as DateTime?;
      if (renewal != null) {
        final days = renewal.difference(DateTime.now()).inDays;
        if (days <= 3 && days > 0) {
          await notificationService.showNotification(
            title: 'Subscription Renewal',
            body: '${sub['name']} renews in $days days.',
            settings: settings,
            setting: NotificationSetting.subscriptionRenewals,
          );
        }
      }
    }
  }

  Future<NotificationSettings?> _loadNotificationSettings() async {
    final repository = settingsRepository;
    if (repository == null) return null;
    try {
      return (await repository.getSettings()).notificationSettings;
    } catch (_) {
      return null;
    }
  }
}

class _ReminderTime {
  const _ReminderTime(this.hour, this.minute);

  final int hour;
  final int minute;
}
