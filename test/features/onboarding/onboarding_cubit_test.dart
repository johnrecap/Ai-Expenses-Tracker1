import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/onboarding/onboarding_cubit/onboarding_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingCubit', () {
    test('completeOnboarding saves selected language currency and notifications', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repo = LocalSettingsRepository(store: store);
      await repo.saveSettings(
        UserSettings.defaults(userId: 'user-1').copyWith(
          defaultPaymentMethod: PaymentMethod.wallet,
        ),
      );
      final cubit = OnboardingCubit(repo)
        ..setLanguage('ar')
        ..setCurrency('usd')
        ..setNotificationChoices(
          dailyReminderEnabled: true,
          weeklyDigestEnabled: true,
          dailyReminderTime: '08:15 PM',
        );

      await cubit.completeOnboarding(
        notificationsEnabled: true,
        dailyReminderEnabled: true,
        weeklyDigestEnabled: true,
        dailyReminderTime: '08:15 PM',
      );

      final saved = await repo.getSettings();
      expect(cubit.state.completed, isTrue);
      expect(saved.languagePreference, LanguagePreference.arabic);
      expect(saved.baseCurrency, 'USD');
      expect(saved.defaultPaymentMethod, PaymentMethod.wallet);
      expect(saved.onboardingCompleted, isTrue);
      expect(saved.notificationSettings.dailyReminder, isTrue);
      expect(saved.notificationSettings.weeklyDigest, isTrue);
      expect(saved.notificationSettings.dailyReminderTime, '20:15');
    });

    test('skip notifications saves disabled notification settings', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repo = LocalSettingsRepository(store: store);
      final cubit = OnboardingCubit(repo);

      await cubit.completeOnboarding(notificationsEnabled: false);

      final saved = await repo.getSettings();
      expect(saved.notificationSettings.budgetAlerts, isFalse);
      expect(saved.notificationSettings.recurringReminders, isFalse);
      expect(saved.notificationSettings.weeklyDigest, isFalse);
      expect(saved.notificationSettings.dailyReminder, isFalse);
    });
  });
}
