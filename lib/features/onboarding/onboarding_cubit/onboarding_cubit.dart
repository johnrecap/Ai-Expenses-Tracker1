import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SettingsRepository _settingsRepository;

  OnboardingCubit(this._settingsRepository) : super(const OnboardingState());

  void setLanguage(String code) {
    emit(state.copyWith(language: code));
  }

  void setCurrency(String code) {
    emit(state.copyWith(currency: code));
  }

  Future<void> completeOnboarding({required bool notificationsEnabled}) async {
    emit(state.copyWith(loading: true));
    try {
      final settings = await _settingsRepository.ensureDefaultSettings();
      final updated = settings.copyWith(
        languagePreference: state.language == 'ar' ? LanguagePreference.arabic : LanguagePreference.english,
        baseCurrency: state.currency,
        notificationSettings: settings.notificationSettings,
        onboardingCompleted: true,
        onboardingVersion: UserSettings.currentOnboardingVersion,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.saveSettings(updated);
      emit(state.copyWith(loading: false, completed: true));
    } catch (_) {
      emit(state.copyWith(loading: false, error: true));
    }
  }
}

class OnboardingState {
  final String language;
  final String currency;
  final bool loading;
  final bool completed;
  final bool error;

  const OnboardingState({
    this.language = 'en',
    this.currency = 'EGP',
    this.loading = false,
    this.completed = false,
    this.error = false,
  });

  OnboardingState copyWith({
    String? language,
    String? currency,
    bool? loading,
    bool? completed,
    bool? error,
  }) {
    return OnboardingState(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      loading: loading ?? this.loading,
      completed: completed ?? this.completed,
      error: error ?? this.error,
    );
  }
}
