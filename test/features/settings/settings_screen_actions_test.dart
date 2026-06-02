import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/settings/presentation/settings_screen.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/services/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('SettingsScreen actions', () {
    testWidgets('push notification switch saves real settings', (tester) async {
      final settingsRepository = _FakeSettingsRepository(
        UserSettings.defaults(userId: 'user-1'),
      );
      final platform = _FakeNotificationPlatform();

      await _pumpSettings(
        tester,
        settingsRepository,
        notificationService: NotificationService(platform: platform),
      );

      expect(settingsRepository.savedSettings, isNull);

      await tester.tap(find.text('Push Notifications'));
      await tester.pumpAndSettle();

      final saved = settingsRepository.savedSettings;
      expect(saved, isNotNull);
      expect(saved!.notificationSettings.budgetAlerts, isFalse);
      expect(saved.notificationSettings.recurringReminders, isFalse);
      expect(saved.notificationSettings.subscriptionRenewals, isFalse);
      expect(saved.notificationSettings.aiQuotaWarnings, isFalse);
      expect(platform.cancelledIds, NotificationService.managedScheduledNotificationIds);
    });

    testWidgets('enabling push notifications requests permission first', (tester) async {
      final settingsRepository = _FakeSettingsRepository(
        UserSettings.defaults(userId: 'user-1').copyWith(
          notificationSettings: const NotificationSettings.disabled(),
        ),
      );
      final platform = _FakeNotificationPlatform(
        notificationsAllowed: false,
        permissionResult: true,
      );

      await _pumpSettings(
        tester,
        settingsRepository,
        notificationService: NotificationService(platform: platform),
      );

      await tester.tap(find.text('Push Notifications'));
      await tester.pumpAndSettle();

      final saved = settingsRepository.savedSettings;
      expect(platform.permissionRequests, 1);
      expect(saved, isNotNull);
      expect(saved!.notificationSettings.budgetAlerts, isTrue);
      expect(saved.notificationSettings.subscriptionRenewals, isTrue);
    });

    testWidgets('profile and subscription rows navigate to real routes', (tester) async {
      final settingsRepository = _FakeSettingsRepository(
        UserSettings.defaults(userId: 'user-1'),
      );

      await _pumpSettings(tester, settingsRepository);

      await tester.ensureVisible(find.text('Profile'));
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile destination'), findsOneWidget);

      await tester.tap(find.text('Back to settings'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Subscription'));
      await tester.tap(find.text('Subscription'));
      await tester.pumpAndSettle();

      expect(find.text('Subscription destination'), findsOneWidget);
    });

    testWidgets('backup and restore rows are removed', (tester) async {
      final settingsRepository = _FakeSettingsRepository(
        UserSettings.defaults(userId: 'user-1'),
      );

      await _pumpSettings(tester, settingsRepository);

      expect(find.text('Backup Data'), findsNothing);
      expect(find.text('Restore Data'), findsNothing);
      expect(find.text('Backup and sync'), findsNothing);
      expect(find.textContaining('cloud backup'), findsOneWidget);
    });

    testWidgets('settings explain local-only data loss risk', (tester) async {
      final settingsRepository = _FakeSettingsRepository(
        UserSettings.defaults(userId: 'user-1'),
      );

      await _pumpSettings(tester, settingsRepository);

      await tester.ensureVisible(find.text('Local-only storage').first);

      expect(find.text('Local-only storage'), findsAtLeastNWidgets(1));
      expect(find.textContaining('stored on this device'), findsOneWidget);
      expect(find.textContaining('Deleting the app or losing this phone'), findsOneWidget);
    });

    testWidgets('default payment method selector saves real settings', (tester) async {
      final settingsRepository = _FakeSettingsRepository(
        UserSettings.defaults(userId: 'user-1'),
      );

      await _pumpSettings(tester, settingsRepository);

      final row = find.text('Default payment method');
      await tester.ensureVisible(row);
      await tester.tap(row.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bank Transfer').last);
      await tester.pumpAndSettle();

      final saved = settingsRepository.savedSettings;
      expect(saved, isNotNull);
      expect(saved!.defaultPaymentMethod, PaymentMethod.bankTransfer);
    });

    testWidgets('default payment method selector shows save failures', (tester) async {
      final settingsRepository = _FakeSettingsRepository(
        UserSettings.defaults(userId: 'user-1'),
        failOnSave: true,
      );

      await _pumpSettings(tester, settingsRepository);

      final row = find.text('Default payment method');
      await tester.ensureVisible(row);
      await tester.tap(row.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Visa/Card').last);
      await tester.pumpAndSettle();

      expect(find.text('Failed to save.'), findsOneWidget);
      expect(settingsRepository.savedSettings, isNull);
    });
  });
}

Future<void> _pumpSettings(
  WidgetTester tester,
  _FakeSettingsRepository settingsRepository, {
  NotificationService? notificationService,
}) async {
  final authRepository = _FakeAuthRepository();
  final router = GoRouter(
    initialLocation: AppRoutes.settings,
    routes: [
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => SettingsScreen(
          notificationService: notificationService,
        ),
      ),
      GoRoute(
        path: AppRoutes.accountProfile,
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Profile destination'),
                TextButton(
                  onPressed: () => context.go(AppRoutes.settings),
                  child: const Text('Back to settings'),
                ),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Subscription destination')),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (_) => AuthBloc(authRepository)..add(AuthUserChanged(authRepository.currentUser)),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(settingsRepository)..loadSettings(),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeNotificationPlatform implements NotificationPlatform {
  _FakeNotificationPlatform({
    this.notificationsAllowed = true,
    this.permissionResult = true,
  });

  bool notificationsAllowed;
  bool permissionResult;
  int permissionRequests = 0;
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
  }) async {}

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings, {this.failOnSave = false});

  UserSettings settings;
  final bool failOnSave;
  UserSettings? savedSettings;

  @override
  Future<UserSettings> ensureDefaultSettings() async => settings;

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    if (failOnSave) throw StateError('local write failed');
    this.settings = settings;
    savedSettings = settings;
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

class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser>.broadcast();
  final _user = const AppUser(
    userId: 'user-1',
    email: 'user@example.com',
    displayName: 'User',
  );

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser> get user => _controller.stream;

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<AppUser> reauthenticate({required String email, required String password}) async => _user;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AppUser> updateEmail(String email) async => _user;

  @override
  Future<AppUser> signIn({required String email, required String password}) async => _user;

  @override
  Future<AppUser?> signInWithGoogle() async => _user;

  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => _user;

  @override
  Future<AppUser> updateDisplayName(String displayName) async => _user;

  @override
  Future<AppUser> reauthenticateWithGoogle() async => _user;
}
