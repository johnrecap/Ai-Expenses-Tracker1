import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseSettingsRepository implements SettingsRepository {
  static const docId = 'profile';
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseSettingsRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      assert(userId.isNotEmpty);

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('users/$userId/settings').doc(docId);

  @override
  Future<UserSettings> getSettings() async {
    final snapshot = await _doc.get();
    if (!snapshot.exists || snapshot.data() == null) return ensureDefaultSettings();
    final entity = UserSettingsEntity.fromDocument(snapshot.data()!);
    return _toModel(entity);
  }

  @override
  Stream<UserSettings> watchSettings() {
    return _doc.snapshots().asyncMap((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return ensureDefaultSettings();
      return _toModel(UserSettingsEntity.fromDocument(snapshot.data()!));
    });
  }

  UserSettings _toModel(UserSettingsEntity e) => UserSettings(
    userId: e.userId,
    appDisplayName: e.appDisplayName,
    languagePreference: LanguagePreference.fromStorageValue(e.languagePreference),
    baseCurrency: e.baseCurrency,
    supportedCurrencies: e.supportedCurrencies,
    conversionRates: e.conversionRates,
    defaultPaymentMethod: PaymentMethod.fromStorageValue(e.defaultPaymentMethod),
    notificationSettings: e.notificationSettings,
    onboardingCompleted: e.onboardingCompleted,
    onboardingVersion: e.onboardingVersion,
    guidedTourCompletedVersion: e.guidedTourCompletedVersion,
    guidedTourSkippedVersion: e.guidedTourSkippedVersion,
    guidedTourLastStepId: e.guidedTourLastStepId,
    exchangeRatesUpdatedAt: e.exchangeRatesUpdatedAt,
    updatedAt: e.updatedAt,
  );

  @override
  Future<void> saveSettings(UserSettings settings) async {
    await _doc.set(settings.toEntity().toDocument());
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    final current = await getSettings();
    await saveSettings(
      current.copyWith(baseCurrency: currencyCode.trim().toUpperCase(), updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> updateLanguagePreference(LanguagePreference pref) async {
    final current = await getSettings();
    await saveSettings(current.copyWith(languagePreference: pref, updatedAt: DateTime.now()));
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod method) async {
    final current = await getSettings();
    await saveSettings(current.copyWith(defaultPaymentMethod: method, updatedAt: DateTime.now()));
  }

  @override
  Future<UserSettings> ensureDefaultSettings() async {
    final snapshot = await _doc.get();
    if (snapshot.exists && snapshot.data() != null) {
      return _toModel(UserSettingsEntity.fromDocument(snapshot.data()!));
    }
    final defaults = UserSettings.defaults(userId: userId);
    await saveSettings(defaults);
    return defaults;
  }
}
