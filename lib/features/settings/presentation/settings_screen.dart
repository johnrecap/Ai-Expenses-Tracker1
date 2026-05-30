import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/security/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/features/security/presentation/create_pin_screen.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            const AppTopBar(title: 'Settings'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SecuritySection(),
                    const SizedBox(height: AppSpacing.md),
                    _AppearanceSection(),
                    const SizedBox(height: AppSpacing.md),
                    _NotificationSection(),
                    const SizedBox(height: AppSpacing.md),
                    _PrivacySection(),
                    const SizedBox(height: AppSpacing.md),
                    _DataSection(),
                    const SizedBox(height: AppSpacing.md),
                    _profileSection(context),
                    const SizedBox(height: AppSpacing.md),
                    _SupportSection(),
                    const SizedBox(height: AppSpacing.md),
                    _DangerSection(context),
                    const SizedBox(height: 80),
                  ],
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
          ]),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.subtitle, required this.children});
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        ],
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ]),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLockCubit? cubit;
    try { cubit = context.read<AppLockCubit>(); } catch (_) { return const SizedBox.shrink(); }

    return BlocBuilder<AppLockCubit, AppLockState>(
      bloc: cubit,
      builder: (context, state) => _Section(
        title: 'Security',
        subtitle: 'App lock, PIN, and biometrics',
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('PIN Lock', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
            subtitle: Text('Require PIN to open the app', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
            value: state.appLockEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: state.isBusy ? null : (v) => _toggleLock(context, v),
          ),
          if (state.appLockEnabled && state.hasPin)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Change PIN', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
              onTap: state.isBusy ? null : () => _openPinScreen(context, changeExisting: true),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Biometric Unlock', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
            subtitle: Text(state.biometricAvailable ? 'Use fingerprint or face' : 'Not available on this device',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
            value: state.biometricEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (state.isBusy || !state.appLockEnabled || !state.hasPin || !state.biometricAvailable)
                ? null : (v) => cubit?.setBiometricEnabled(v),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLock(BuildContext context, bool enabled) async {
    if (enabled) {
      await _openPinScreen(context);
    } else {
      await context.read<AppLockCubit>().disableLock();
    }
  }

  Future<void> _openPinScreen(BuildContext context, {bool changeExisting = false}) async {
    await Navigator.push(context, MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: context.read<AppLockCubit>(),
        child: CreatePinScreen(changeExistingPin: changeExisting),
      ),
    ));
  }
}

class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final currency = state is SettingsSuccess 
            ? state.settings.baseCurrency 
            : 'KWD';
        
        return _Section(
          title: 'Appearance',
          subtitle: 'Language and currency',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: Text('Language', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
              subtitle: Text('English / العربية', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
              onTap: () => context.go(AppRoutes.onboardingLanguage),
            ),
            const Divider(height: 1, color: AppColors.surfaceContainerHigh),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_money, color: AppColors.primary),
              title: Text('Currency', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
              subtitle: Text(currency, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
              onTap: () => context.go(AppRoutes.onboardingCurrency),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final notificationsEnabled = state is SettingsSuccess 
            ? true // TODO: Add notificationsEnabled to UserSettings
            : true;
        
        return _Section(
          title: 'Notifications',
          subtitle: 'Budget alerts and reminders',
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Push Notifications', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
              subtitle: Text('Get alerts for budgets and bills', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              value: notificationsEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (v) {
                // TODO: Save notification preference
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _PrivacySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Privacy & Data',
      subtitle: 'Control your data',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
          title: Text('Privacy Policy', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.onSurfaceVariant),
          onTap: () {},
        ),
        const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description_outlined, color: AppColors.primary),
          title: Text('Terms of Service', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.onSurfaceVariant),
          onTap: () {},
        ),
      ],
    );
  }
}

class _DataSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Data',
      subtitle: 'Backup and sync',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.backup_outlined, color: AppColors.primary),
          title: Text('Backup Data', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          subtitle: Text('Save a local backup of your data', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          onTap: () {},
        ),
        const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.restore_outlined, color: AppColors.primary),
          title: Text('Restore Data', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          subtitle: Text('Restore from a previous backup', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          onTap: () {},
        ),
      ],
    );
  }
}

Widget _profileSection(BuildContext context) {
  return _Section(
    title: 'Account',
    subtitle: 'Profile and subscription',
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.person_outline, color: AppColors.primary),
        title: Text('Profile', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
        subtitle: Text('Name, email, account settings', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: () {},
      ),
      const Divider(height: 1, color: AppColors.surfaceContainerHigh),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.workspace_premium, color: AppColors.primary),
        title: Text('Subscription', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
        subtitle: Text('Free plan', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: () {},
      ),
    ],
  );
}

class _SupportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Support',
      subtitle: 'Help and feedback',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.help_outline, color: AppColors.primary),
          title: Text('Help Center', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          trailing: const Icon(Icons.open_in_new, size: 18, color: AppColors.onSurfaceVariant),
          onTap: () {},
        ),
        const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.feedback_outlined, color: AppColors.primary),
          title: Text('Send Feedback', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          onTap: () {},
        ),
        const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline, color: AppColors.primary),
          title: Text('About', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          subtitle: Text('Version 1.0.0+1', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          enabled: false,
        ),
      ],
    );
  }
}

class _DangerSection extends StatelessWidget {
  const _DangerSection(this.context);
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Danger Zone',
      subtitle: 'Irreversible actions',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
          title: Text('Delete Account', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
          subtitle: Text('Permanently delete all data', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          onTap: () => _showDeleteDialog(context),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete all your data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete Forever', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}
