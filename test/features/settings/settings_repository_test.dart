import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalSettingsRepository', () {
    test('ensureDefaultSettings creates missing settings once', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repo = LocalSettingsRepository(store: store);

      final settings = await repo.ensureDefaultSettings();

      expect(settings.userId, 'user-1');
      expect(settings.onboardingCompleted, isFalse);
      expect(store.settings, same(settings));
    });

    test('ensureDefaultSettings preserves existing settings', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repo = LocalSettingsRepository(store: store);
      final existing = UserSettings.defaults(userId: 'user-1').copyWith(
        languagePreference: LanguagePreference.arabic,
        baseCurrency: 'USD',
        defaultPaymentMethod: PaymentMethod.visa,
        onboardingCompleted: true,
        onboardingVersion: UserSettings.currentOnboardingVersion,
      );
      await repo.saveSettings(existing);

      final ensured = await repo.ensureDefaultSettings();

      expect(ensured.languagePreference, LanguagePreference.arabic);
      expect(ensured.baseCurrency, 'USD');
      expect(ensured.defaultPaymentMethod, PaymentMethod.visa);
      expect(ensured.onboardingCompleted, isTrue);
    });

    test('notification settings serialize and parse full supported shape', () {
      final settings = UserSettings.defaults(userId: 'user-1').copyWith(
        notificationSettings: const NotificationSettings(
          budgetAlerts: true,
          recurringReminders: true,
          subscriptionRenewals: false,
          weeklyDigest: true,
          aiQuotaWarnings: false,
          dailyReminder: true,
          dailyReminderTime: '20:30',
        ),
      );

      final document = settings.toEntity().toDocument();
      final notificationSettings = document['notificationSettings'] as Map<String, dynamic>;
      final parsed = UserSettingsEntity.fromDocument(document).toModel();

      expect(notificationSettings['subscriptionRenewals'], isFalse);
      expect(notificationSettings['weeklyDigest'], isTrue);
      expect(notificationSettings['aiQuotaWarnings'], isFalse);
      expect(notificationSettings['dailyReminder'], isTrue);
      expect(notificationSettings['dailyReminderTime'], '20:30');
      expect(parsed.notificationSettings.weeklyDigest, isTrue);
      expect(parsed.notificationSettings.dailyReminderTime, '20:30');
    });
  });
}
