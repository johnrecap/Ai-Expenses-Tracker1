import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/settings/presentation/settings_screen.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/services/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Settings notification preference', () {
    testWidgets('disabling notifications cancels app-managed reminders', (tester) async {
      final events = <String>[];
      final settingsRepository = _FakeSettingsRepository(
        UserSettings.defaults(userId: 'user-1'),
        events: events,
      );
      final platform = _FakeNotificationPlatform(events: events);

      await _pumpSettings(
        tester,
        settingsRepository,
        notificationService: NotificationService(platform: platform),
      );

      await tester.tap(find.text('Push Notifications'));
      await tester.pumpAndSettle();

      expect(platform.cancelledIds, NotificationService.managedScheduledNotificationIds);
      expect(settingsRepository.savedSettings, isNotNull);
      expect(settingsRepository.savedSettings!.notificationSettings.budgetAlerts, isFalse);
      expect(settingsRepository.savedSettings!.notificationSettings.recurringReminders, isFalse);
      expect(events, <String>[
        'cancel:${NotificationService.scheduledReminderNotificationId}',
        'cancel:${NotificationService.dailyReminderNotificationId}',
        'save:false',
      ]);
    });

    testWidgets('permission denial leaves notifications disabled', (tester) async {
      final settingsRepository = _FakeSettingsRepository(
        UserSettings.defaults(userId: 'user-1').copyWith(
          notificationSettings: const NotificationSettings.disabled(),
        ),
      );
      final platform = _FakeNotificationPlatform(
        notificationsAllowed: false,
        permissionResult: false,
      );

      await _pumpSettings(
        tester,
        settingsRepository,
        notificationService: NotificationService(platform: platform),
      );

      await tester.tap(find.text('Push Notifications'));
      await tester.pumpAndSettle();

      expect(platform.permissionRequests, 1);
      expect(platform.scheduleCalls, 0);
      expect(platform.cancelledIds, isEmpty);
      expect(settingsRepository.savedSettings, isNull);
      expect(settingsRepository.settings.notificationSettings.budgetAlerts, isFalse);
      expect(find.text('Notification permission was not granted.'), findsOneWidget);
    });
  });
}

Future<void> _pumpSettings(
  WidgetTester tester,
  _FakeSettingsRepository settingsRepository, {
  required NotificationService notificationService,
}) async {
  await tester.pumpWidget(
    BlocProvider<SettingsCubit>(
      create: (_) => SettingsCubit(settingsRepository)..loadSettings(),
      child: MaterialApp(
        theme: AppTheme.light,
        home: SettingsScreen(notificationService: notificationService),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeNotificationPlatform implements NotificationPlatform {
  _FakeNotificationPlatform({
    this.notificationsAllowed = true,
    this.permissionResult = true,
    this.events,
  });

  bool notificationsAllowed;
  bool permissionResult;
  final List<String>? events;
  int permissionRequests = 0;
  int scheduleCalls = 0;
  final cancelledIds = <int>[];

  @override
  Future<void> initialize() async {}

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
  }) async {}

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
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
    events?.add('cancel:$id');
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings, {this.events});

  UserSettings settings;
  final List<String>? events;
  UserSettings? savedSettings;

  @override
  Future<UserSettings> ensureDefaultSettings() async => settings;

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    this.settings = settings;
    savedSettings = settings;
    events?.add('save:${settings.notificationSettings.budgetAlerts}');
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    settings = settings.copyWith(baseCurrency: currencyCode);
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    settings = settings.copyWith(defaultPaymentMethod: paymentMethod);
  }

  @override
  Future<void> updateLanguagePreference(LanguagePreference languagePreference) async {
    settings = settings.copyWith(languagePreference: languagePreference);
  }

  @override
  Stream<UserSettings> watchSettings() => Stream.value(settings);
}
