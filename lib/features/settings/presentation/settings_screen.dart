import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsOn = true;
  bool _darkMode = false;
  bool _biometrics = false;

  void _saveSetting(UserSettings Function(UserSettings) update) {
    final cubit = context.read<SettingsCubit>();
    final current = cubit.state;
    if (current is SettingsSuccess) {
      cubit.saveSettings(update(current.settings));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const AppTopBar(title: 'Settings'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final user = authState is AuthAuthenticated ? authState.user : null;
                      return BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          final baseCurrency = settingsState is SettingsSuccess
                              ? settingsState.settings.baseCurrency
                              : 'KWD';
                          final displayName = user?.displayName ?? user?.email ?? 'User';

                          return Column(
                            children: [
                              GlassCard(
                                child: Row(
                                  children: [
                                    const CircleAvatar(radius: 28, backgroundColor: AppColors.primaryContainer, child: Icon(Icons.person, size: 28, color: AppColors.primary)),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(displayName, style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
                                          const SizedBox(height: 2),
                                          Text('Manage your profile', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.outline),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _SectionLabel(label: 'Preferences'),
                              const SizedBox(height: AppSpacing.sm),
                              GlassCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    _ToggleRow(icon: Icons.notifications_outlined, label: 'Notifications', value: _notificationsOn, onChanged: (v) {
                                      setState(() => _notificationsOn = v);
                                      _saveSetting((UserSettings s) => s.copyWith(notificationSettings: s.notificationSettings, updatedAt: DateTime.now()));
                                    }),
                                    const Divider(height: 1, indent: 56, color: AppColors.surfaceContainerHigh),
                                    _ToggleRow(icon: Icons.dark_mode_outlined, label: 'Dark Mode', value: _darkMode, onChanged: (v) {
                                      setState(() => _darkMode = v);
                                      _saveSetting((UserSettings s) => s.copyWith(updatedAt: DateTime.now()));
                                    }),
                                    const Divider(height: 1, indent: 56, color: AppColors.surfaceContainerHigh),
                                    _ToggleRow(icon: Icons.fingerprint, label: 'Biometric Lock', value: _biometrics, onChanged: (v) {
                                      setState(() => _biometrics = v);
                                      _saveSetting((UserSettings s) => s.copyWith(updatedAt: DateTime.now()));
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _SectionLabel(label: 'Data'),
                              const SizedBox(height: AppSpacing.sm),
                              GlassCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    _NavRow(icon: Icons.language, label: 'Language', value: 'English'),
                                    const Divider(height: 1, indent: 56, color: AppColors.surfaceContainerHigh),
                                    _NavRow(icon: Icons.currency_exchange, label: 'Base Currency', value: baseCurrency),
                                    const Divider(height: 1, indent: 56, color: AppColors.surfaceContainerHigh),
                                    _NavRow(icon: Icons.category, label: 'Categories', value: 'Manage'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _SectionLabel(label: 'About'),
                              const SizedBox(height: AppSpacing.sm),
                              GlassCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    _NavRow(icon: Icons.info_outline, label: 'Version', value: '1.0.0'),
                                    const Divider(height: 1, indent: 56, color: AppColors.surfaceContainerHigh),
                                    _NavRow(icon: Icons.description_outlined, label: 'Terms of Service'),
                                    const Divider(height: 1, indent: 56, color: AppColors.surfaceContainerHigh),
                                    _NavRow(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 80),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              AppBottomNav(
                selectedIndex: 4,
                onDestinationSelected: (i) {
                  switch (i) {
                    case 0: context.go(AppRoutes.home);
                    case 1: context.go(AppRoutes.reports);
                    case 2: context.go(AppRoutes.budgets);
                    case 3: context.go(AppRoutes.wallets);
                    case 4: context.go(AppRoutes.settings);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(label, style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.label, this.value});
  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22, color: AppColors.onSurfaceVariant),
      title: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.outline),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, size: 22, color: AppColors.onSurfaceVariant),
      title: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface)),
      value: value,
      onChanged: onChanged,
    );
  }
}
