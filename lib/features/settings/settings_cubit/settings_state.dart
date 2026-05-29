part of 'settings_cubit.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final UserSettings settings;
  const SettingsSuccess(this.settings);
}

class SettingsSaving extends SettingsState {
  final UserSettings tentative;
  const SettingsSaving(this.tentative);
}

class SettingsFailure extends SettingsState {
  final String message;
  const SettingsFailure(this.message);
}
