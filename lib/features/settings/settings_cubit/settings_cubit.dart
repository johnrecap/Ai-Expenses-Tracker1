import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._settingsRepository) : super(SettingsInitial());

  Future<void> loadSettings() async {
    emit(SettingsLoading());
    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsSuccess(settings));
    } catch (_) {
      emit(const SettingsFailure('Failed to load settings.'));
    }
  }

  Future<void> saveBaseCurrency(String currencyCode) async {
    final current = state;
    if (current is! SettingsSuccess) return;
    final normalized = currencyCode.trim().toUpperCase();
    final updated = current.settings.copyWith(
      baseCurrency: normalized,
      supportedCurrencies: _withRequired(current.settings.supportedCurrencies, normalized),
      conversionRates: const {},
      clearExchangeRatesUpdatedAt: true,
      updatedAt: DateTime.now(),
    );
    emit(SettingsSaving(updated));
    try {
      await _settingsRepository.saveSettings(updated);
      emit(SettingsSuccess(updated));
    } catch (_) {
      emit(const SettingsFailure('Failed to save.'));
      emit(current);
    }
  }

  Future<void> saveLanguagePreference(LanguagePreference preference) async {
    final current = state;
    if (current is! SettingsSuccess) return;
    final updated = current.settings.copyWith(
      languagePreference: preference,
      updatedAt: DateTime.now(),
    );
    emit(SettingsSaving(updated));
    try {
      await _settingsRepository.saveSettings(updated);
      emit(SettingsSuccess(updated));
    } catch (_) {
      emit(const SettingsFailure('Failed to save.'));
      emit(current);
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    emit(SettingsSaving(settings));
    try {
      await _settingsRepository.saveSettings(settings);
      emit(SettingsSuccess(settings));
    } catch (_) {
      emit(const SettingsFailure('Failed to save.'));
    }
  }

  List<String> _withRequired(List<String> codes, String required) {
    final normalized = <String>[];
    for (final code in [...codes, required]) {
      final value = code.trim().toUpperCase();
      if (value.isEmpty || normalized.contains(value)) continue;
      normalized.add(value);
    }
    return normalized;
  }
}
