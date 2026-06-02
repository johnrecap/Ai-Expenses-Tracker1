import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/language_preference.dart';
import '../models/notification_settings.dart';
import '../models/payment_method.dart';
import '../models/user_settings.dart';

class UserSettingsEntity {
  final String userId;
  final String? appDisplayName;
  final String languagePreference;
  final String baseCurrency;
  final List<String> supportedCurrencies;
  final Map<String, double> conversionRates;
  final String defaultPaymentMethod;
  final NotificationSettings notificationSettings;
  final bool onboardingCompleted;
  final int onboardingVersion;
  final int guidedTourCompletedVersion;
  final int guidedTourSkippedVersion;
  final String? guidedTourLastStepId;
  final DateTime? exchangeRatesUpdatedAt;
  final DateTime updatedAt;

  const UserSettingsEntity({
    required this.userId,
    this.appDisplayName,
    required this.languagePreference,
    required this.baseCurrency,
    required this.supportedCurrencies,
    required this.conversionRates,
    required this.defaultPaymentMethod,
    required this.notificationSettings,
    required this.onboardingCompleted,
    required this.onboardingVersion,
    required this.guidedTourCompletedVersion,
    required this.guidedTourSkippedVersion,
    this.guidedTourLastStepId,
    this.exchangeRatesUpdatedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() => {
    'userId': userId,
    if (appDisplayName != null) 'appDisplayName': appDisplayName,
    'languagePreference': languagePreference,
    'baseCurrency': baseCurrency,
    'supportedCurrencies': supportedCurrencies,
    'conversionRates': conversionRates,
    'defaultPaymentMethod': defaultPaymentMethod,
    'notificationSettings': {
      'budgetAlerts': notificationSettings.budgetAlerts,
      'recurringReminders': notificationSettings.recurringReminders,
      'subscriptionRenewals': notificationSettings.subscriptionRenewals,
      'weeklyDigest': notificationSettings.weeklyDigest,
      'aiQuotaWarnings': notificationSettings.aiQuotaWarnings,
      'dailyReminder': notificationSettings.dailyReminder,
      if (notificationSettings.dailyReminderTime != null)
        'dailyReminderTime': notificationSettings.dailyReminderTime,
    },
    'onboardingCompleted': onboardingCompleted,
    'onboardingVersion': onboardingVersion,
    'guidedTourCompletedVersion': guidedTourCompletedVersion,
    'guidedTourSkippedVersion': guidedTourSkippedVersion,
    if (guidedTourLastStepId != null) 'guidedTourLastStepId': guidedTourLastStepId,
    if (exchangeRatesUpdatedAt != null)
      'exchangeRatesUpdatedAt': Timestamp.fromDate(exchangeRatesUpdatedAt!),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  static UserSettingsEntity fromDocument(Map<String, dynamic> data) {
    DateTime? dt(dynamic v) => v is Timestamp ? v.toDate() : null;
    final ns = data['notificationSettings'] as Map<String, dynamic>? ?? const {};
    return UserSettingsEntity(
      userId: data['userId'] as String? ?? '',
      appDisplayName: data['appDisplayName'] as String?,
      languagePreference: data['languagePreference'] as String? ?? 'system',
      baseCurrency: data['baseCurrency'] as String? ?? 'EGP',
      supportedCurrencies: List<String>.from(data['supportedCurrencies'] as List? ?? []),
      conversionRates: Map<String, double>.from(
        (data['conversionRates'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
            ) ??
            {},
      ),
      defaultPaymentMethod: data['defaultPaymentMethod'] as String? ?? 'cash',
      notificationSettings: NotificationSettings(
        budgetAlerts: ns['budgetAlerts'] as bool? ?? true,
        recurringReminders: ns['recurringReminders'] as bool? ?? true,
        subscriptionRenewals: ns['subscriptionRenewals'] as bool? ?? true,
        weeklyDigest: ns['weeklyDigest'] as bool? ?? false,
        aiQuotaWarnings: ns['aiQuotaWarnings'] as bool? ?? true,
        dailyReminder: ns['dailyReminder'] as bool? ?? false,
        dailyReminderTime: ns['dailyReminderTime'] as String?,
      ),
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      onboardingVersion: data['onboardingVersion'] as int? ?? 0,
      guidedTourCompletedVersion: data['guidedTourCompletedVersion'] as int? ?? 0,
      guidedTourSkippedVersion: data['guidedTourSkippedVersion'] as int? ?? 0,
      guidedTourLastStepId: data['guidedTourLastStepId'] as String?,
      exchangeRatesUpdatedAt: dt(data['exchangeRatesUpdatedAt']),
      updatedAt: dt(data['updatedAt']) ?? DateTime.now(),
    );
  }

  UserSettings toModel() => UserSettings(
    userId: userId,
    appDisplayName: appDisplayName,
    languagePreference: LanguagePreference.fromStorageValue(languagePreference),
    baseCurrency: baseCurrency,
    supportedCurrencies: supportedCurrencies,
    conversionRates: conversionRates,
    defaultPaymentMethod: PaymentMethod.fromStorageValue(defaultPaymentMethod),
    notificationSettings: notificationSettings,
    onboardingCompleted: onboardingCompleted,
    onboardingVersion: onboardingVersion,
    guidedTourCompletedVersion: guidedTourCompletedVersion,
    guidedTourSkippedVersion: guidedTourSkippedVersion,
    guidedTourLastStepId: guidedTourLastStepId,
    exchangeRatesUpdatedAt: exchangeRatesUpdatedAt,
    updatedAt: updatedAt,
  );
}
