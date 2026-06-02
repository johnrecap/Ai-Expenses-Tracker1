import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/services/notifications/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationService', () {
    test('initialize is idempotent and does not request permission', () async {
      final platform = _FakeNotificationPlatform();
      final service = NotificationService(platform: platform);

      await service.initialize();
      await service.initialize();

      expect(platform.initializeCalls, 1);
      expect(platform.permissionRequests, 0);
    });

    test('daily reminder respects disabled settings before platform calls', () async {
      final platform = _FakeNotificationPlatform();
      final service = NotificationService(platform: platform);

      final result = await service.scheduleDailyReminder(
        title: 'Reminder',
        body: 'Log expenses',
        time24h: '20:00',
        settings: const NotificationSettings.disabled(),
      );

      expect(result, NotificationScheduleResult.disabledBySettings);
      expect(platform.initializeCalls, 0);
      expect(platform.permissionRequests, 0);
      expect(platform.scheduleCalls, 0);
    });

    test('daily reminder requests permission only when scheduling needs it', () async {
      final platform = _FakeNotificationPlatform(
        notificationsAllowed: false,
        permissionResult: true,
      );
      final service = NotificationService(platform: platform);

      final result = await service.scheduleDailyReminder(
        title: 'Reminder',
        body: 'Log expenses',
        time24h: '20:00',
        settings: const NotificationSettings(
          dailyReminder: true,
          dailyReminderTime: '20:00',
        ),
      );

      expect(result, NotificationScheduleResult.scheduled);
      expect(platform.initializeCalls, 1);
      expect(platform.permissionRequests, 1);
      expect(platform.scheduleCalls, 1);
      expect(platform.lastRepeatsDaily, isTrue);
    });

    test('daily reminder rejects invalid time without platform calls', () async {
      final platform = _FakeNotificationPlatform();
      final service = NotificationService(platform: platform);

      final result = await service.scheduleDailyReminder(
        title: 'Reminder',
        body: 'Log expenses',
        time24h: '25:99',
        settings: const NotificationSettings(dailyReminder: true),
      );

      expect(result, NotificationScheduleResult.invalidTime);
      expect(platform.initializeCalls, 0);
      expect(platform.scheduleCalls, 0);
    });

    test('showNotification respects disabled notification category', () async {
      final platform = _FakeNotificationPlatform();
      final service = NotificationService(platform: platform);

      final result = await service.showNotification(
        title: 'Budget Alert',
        body: 'Limit reached',
        settings: const NotificationSettings(budgetAlerts: false),
        setting: NotificationSetting.budgetAlerts,
      );

      expect(result, NotificationDeliveryResult.disabledBySettings);
      expect(platform.initializeCalls, 0);
      expect(platform.showCalls, 0);
    });

    test('cancelManagedNotifications cancels app-managed reminder ids', () async {
      final platform = _FakeNotificationPlatform();
      final service = NotificationService(platform: platform);

      final result = await service.cancelManagedNotifications();

      expect(result, NotificationCancelResult.cancelled);
      expect(platform.initializeCalls, 1);
      expect(platform.cancelledIds, NotificationService.managedScheduledNotificationIds);
    });

    test('schedule does not run when permission is denied', () async {
      final platform = _FakeNotificationPlatform(
        notificationsAllowed: false,
        permissionResult: false,
      );
      final service = NotificationService(platform: platform);

      final result = await service.scheduleDailyReminder(
        title: 'Reminder',
        body: 'Log expenses',
        time24h: '20:00',
        settings: const NotificationSettings(
          dailyReminder: true,
          dailyReminderTime: '20:00',
        ),
      );

      expect(result, NotificationScheduleResult.permissionDenied);
      expect(platform.permissionRequests, 1);
      expect(platform.scheduleCalls, 0);
    });
  });
}

class _FakeNotificationPlatform implements NotificationPlatform {
  _FakeNotificationPlatform({
    this.notificationsAllowed = true,
    this.permissionResult = true,
  });

  bool notificationsAllowed;
  bool permissionResult;
  int initializeCalls = 0;
  int permissionRequests = 0;
  int showCalls = 0;
  int scheduleCalls = 0;
  final cancelledIds = <int>[];
  bool? lastRepeatsDaily;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequests += 1;
    notificationsAllowed = permissionResult;
    return permissionResult;
  }

  @override
  Future<bool> areNotificationsAllowed() async => notificationsAllowed;

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required NotificationChannel channel,
  }) async {
    showCalls += 1;
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationChannel channel,
    required bool repeatsDaily,
  }) async {
    scheduleCalls += 1;
    lastRepeatsDaily = repeatsDaily;
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }
}
