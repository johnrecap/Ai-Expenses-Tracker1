import 'models/models.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Stream<UserSettings> watchSettings();
  Future<void> saveSettings(UserSettings settings);
  Future<void> updateBaseCurrency(String currencyCode);
  Future<void> updateLanguagePreference(LanguagePreference languagePreference);
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod);
  Future<UserSettings> ensureDefaultSettings();
}
