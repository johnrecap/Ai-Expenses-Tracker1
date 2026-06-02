import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SettingsRepository _settingsRepository;

  OnboardingCubit(this._settingsRepository) : super(const OnboardingState());

  void setLanguage(String code) {
    emit(state.copyWith(language: code));
  }

  void setCurrency(String code) {
    emit(state.copyWith(currency: _normalizeCurrency(code), errorMessage: null));
  }

  void setNotificationChoices({
    required bool dailyReminderEnabled,
    required bool weeklyDigestEnabled,
    String? dailyReminderTime,
  }) {
    emit(
      state.copyWith(
        dailyReminderEnabled: dailyReminderEnabled,
        weeklyDigestEnabled: weeklyDigestEnabled,
        dailyReminderTime: dailyReminderTime,
        errorMessage: null,
      ),
    );
  }

  Future<void> completeOnboarding({
    required bool notificationsEnabled,
    bool? dailyReminderEnabled,
    bool? weeklyDigestEnabled,
    String? dailyReminderTime,
  }) async {
    if (state.loading) return;
    final normalizedCurrency = _normalizeCurrency(state.currency);
    emit(
      state.copyWith(
        loading: true,
        completed: false,
        errorMessage: null,
        currency: normalizedCurrency,
      ),
    );
    try {
      final settings = await _settingsRepository.ensureDefaultSettings();
      final dailyEnabled =
          notificationsEnabled && (dailyReminderEnabled ?? state.dailyReminderEnabled);
      final weeklyEnabled =
          notificationsEnabled && (weeklyDigestEnabled ?? state.weeklyDigestEnabled);
      final reminderTime = dailyEnabled
          ? _normalizeReminderTime(dailyReminderTime ?? state.dailyReminderTime)
          : null;
      final notificationSettings = notificationsEnabled
          ? settings.notificationSettings.copyWith(
              budgetAlerts: true,
              recurringReminders: dailyEnabled,
              subscriptionRenewals: true,
              weeklyDigest: weeklyEnabled,
              aiQuotaWarnings: true,
              dailyReminder: dailyEnabled,
              dailyReminderTime: reminderTime,
              clearDailyReminderTime: !dailyEnabled,
            )
          : const NotificationSettings.disabled();
      final updated = settings.copyWith(
        languagePreference: state.language == 'ar'
            ? LanguagePreference.arabic
            : LanguagePreference.english,
        baseCurrency: normalizedCurrency,
        notificationSettings: notificationSettings,
        onboardingCompleted: true,
        onboardingVersion: UserSettings.currentOnboardingVersion,
        updatedAt: DateTime.now(),
      );
      await _settingsRepository.saveSettings(updated);
      emit(
        state.copyWith(
          loading: false,
          completed: true,
          errorMessage: null,
          dailyReminderEnabled: dailyEnabled,
          weeklyDigestEnabled: weeklyEnabled,
          dailyReminderTime: reminderTime,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          completed: false,
          errorMessage: 'Failed to save onboarding settings. Please try again.',
        ),
      );
    }
  }

  String _normalizeCurrency(String code) {
    final normalized = code.trim().toUpperCase();
    return RegExp(r'^[A-Z]{3}$').hasMatch(normalized) ? normalized : 'EGP';
  }

  String _normalizeReminderTime(String value) {
    final trimmed = value.trim();
    final match24h = RegExp(r'^([01][0-9]|2[0-3]):[0-5][0-9]$');
    if (match24h.hasMatch(trimmed)) return trimmed;

    final match12h = RegExp(
      r'^(\d{1,2}):([0-5][0-9])\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (match12h == null) return '20:00';
    var hour = int.tryParse(match12h.group(1) ?? '') ?? 20;
    final minute = match12h.group(2) ?? '00';
    final period = (match12h.group(3) ?? 'PM').toUpperCase();
    if (period == 'AM' && hour == 12) hour = 0;
    if (period == 'PM' && hour < 12) hour += 12;
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }
}

class OnboardingState {
  final String language;
  final String currency;
  final bool dailyReminderEnabled;
  final bool weeklyDigestEnabled;
  final String dailyReminderTime;
  final bool loading;
  final bool completed;
  final String? errorMessage;

  const OnboardingState({
    this.language = 'en',
    this.currency = 'EGP',
    this.dailyReminderEnabled = true,
    this.weeklyDigestEnabled = true,
    this.dailyReminderTime = '20:00',
    this.loading = false,
    this.completed = false,
    this.errorMessage,
  });

  bool get error => errorMessage != null;

  OnboardingState copyWith({
    String? language,
    String? currency,
    bool? dailyReminderEnabled,
    bool? weeklyDigestEnabled,
    String? dailyReminderTime,
    bool? loading,
    bool? completed,
    String? errorMessage,
  }) {
    return OnboardingState(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      loading: loading ?? this.loading,
      completed: completed ?? this.completed,
      errorMessage: errorMessage,
    );
  }
}
