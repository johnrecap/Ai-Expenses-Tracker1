import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/payment_method_selector.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/security/cubit/app_lock_cubit.dart';
import 'package:expenses_tracker/features/security/presentation/create_pin_screen.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/services/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.notificationService,
  });

  final NotificationService? notificationService;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsFailure) {
          _showUnavailable(context, state.message);
        }
      },
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
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
                        _NotificationSection(
                          notificationService: notificationService ?? NotificationService.instance,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PrivacySection(),
                        const SizedBox(height: AppSpacing.md),
                        _QuotaStatusSection(),
                        const SizedBox(height: AppSpacing.md),
                        _profileSection(context),
                        const SizedBox(height: AppSpacing.md),
                        _SupportSection(),
                        const SizedBox(height: AppSpacing.md),
                        const _DangerSection(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                AppBottomNav(
                  selectedIndex: 4,
                  onDestinationSelected: (i) {
                    switch (i) {
                      case 0:
                        context.go(AppRoutes.home);
                      case 1:
                        context.go(AppRoutes.reports);
                      case 2:
                        context.go(AppRoutes.budgets);
                      case 3:
                        context.go(AppRoutes.wallets);
                      case 4:
                        context.go(AppRoutes.settings);
                    }
                  },
                ),
              ],
            ),
          ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLockCubit? cubit;
    try {
      cubit = context.read<AppLockCubit>();
    } catch (_) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<AppLockCubit, AppLockState>(
      bloc: cubit,
      builder: (context, state) => _Section(
        title: 'Security',
        subtitle: 'App lock, PIN, and biometrics',
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'PIN Lock',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
            ),
            subtitle: Text(
              'Require PIN to open the app',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
            value: state.appLockEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: state.isBusy ? null : (v) => _toggleLock(context, v),
          ),
          if (state.appLockEnabled && state.hasPin)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Change PIN',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
              onTap: state.isBusy ? null : () => _openPinScreen(context, changeExisting: true),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Biometric Unlock',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
            ),
            subtitle: Text(
              state.biometricAvailable ? 'Use fingerprint or face' : 'Not available on this device',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
            value: state.biometricEnabled,
            activeThumbColor: AppColors.primary,
            onChanged:
                (state.isBusy ||
                    !state.appLockEnabled ||
                    !state.hasPin ||
                    !state.biometricAvailable)
                ? null
                : (v) => cubit?.setBiometricEnabled(v),
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
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<AppLockCubit>(),
          child: CreatePinScreen(changeExistingPin: changeExisting),
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settings = _settingsFromState(state);
        final currency = settings?.baseCurrency ?? UserSettings.defaultBaseCurrency;
        final paymentMethod = settings?.defaultPaymentMethod ?? PaymentMethod.cash;
        final l10n = AppLocalizations.of(context);

        return _Section(
          title: 'Appearance',
          subtitle: 'Language, currency, and payment defaults',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: Text(
                'Language',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
              ),
              subtitle: Text(
                'English / العربية',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
              onTap: state is SettingsSaving
                  ? null
                  : () => _showLanguageSheet(
                      context,
                      settings?.languagePreference ?? LanguagePreference.system,
                    ),
            ),
            const Divider(height: 1, color: AppColors.surfaceContainerHigh),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_money, color: AppColors.primary),
              title: Text(
                'Currency',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
              ),
              subtitle: Text(
                currency,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
              onTap: state is SettingsSaving
                  ? null
                  : () => _showCurrencySheet(context, settings),
            ),
            const Divider(height: 1, color: AppColors.surfaceContainerHigh),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.payments_outlined, color: AppColors.primary),
              title: Text(
                l10n?.settingsDefaultPaymentMethod ?? 'Default payment method',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
              ),
              subtitle: Text(
                paymentMethodLabel(context, paymentMethod),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
              onTap: state is SettingsSaving
                  ? null
                  : () => _showDefaultPaymentMethodSheet(context, paymentMethod),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _showLanguageSheet(
  BuildContext context,
  LanguagePreference currentPreference,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.containerPadding,
              0,
              AppSpacing.containerPadding,
              AppSpacing.containerPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final preference in LanguagePreference.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _languageLabel(preference),
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                    ),
                    trailing: currentPreference == preference
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await context.read<SettingsCubit>().saveLanguagePreference(preference);
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _showCurrencySheet(
  BuildContext context,
  UserSettings? settings,
) async {
  if (settings == null) {
    _showUnavailable(context, 'Settings are still loading.');
    return;
  }
  final currencies = settings.supportedCurrencies.isEmpty
      ? UserSettings.defaultSupportedCurrencies
      : settings.supportedCurrencies;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.containerPadding,
              0,
              AppSpacing.containerPadding,
              AppSpacing.containerPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currency',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final currency in currencies)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      currency,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                    ),
                    trailing: settings.baseCurrency == currency
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await context.read<SettingsCubit>().saveBaseCurrency(currency);
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _languageLabel(LanguagePreference preference) {
  return switch (preference) {
    LanguagePreference.system => 'System default',
    LanguagePreference.english => 'English',
    LanguagePreference.arabic => 'العربية',
  };
}

Future<void> _showDefaultPaymentMethodSheet(
  BuildContext context,
  PaymentMethod currentMethod,
) async {
  final l10n = AppLocalizations.of(context);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.containerPadding,
            0,
            AppSpacing.containerPadding,
            AppSpacing.containerPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.settingsDefaultPaymentMethod ?? 'Default payment method',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...paymentMethodOptions.map(
                (method) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    paymentMethodLabel(sheetContext, method),
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                  ),
                  trailing: currentMethod == method
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await context.read<SettingsCubit>().saveDefaultPaymentMethod(method);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({required this.notificationService});

  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final settings = _settingsFromState(state);
        final notificationSettings = settings?.notificationSettings;
        final notificationsEnabled = notificationSettings == null
            ? false
            : _notificationsEnabled(notificationSettings);
        final isSaving = state is SettingsSaving;

        return _Section(
          title: 'Notifications',
          subtitle: 'Budget alerts and reminders',
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Push Notifications',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
              ),
              subtitle: Text(
                'Get alerts for budgets and bills',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
              value: notificationsEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: isSaving
                  ? null
                  : (v) => _saveNotificationPreference(
                      context,
                      state,
                      v,
                      notificationService,
                    ),
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
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: 'Privacy & Data',
      subtitle: l10n?.settingsLocalOnlyTitle ?? 'Local-only storage',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.phone_android_outlined, color: AppColors.primary),
          title: Text(
            l10n?.settingsLocalOnlyTitle ?? 'Local-only storage',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
          ),
          subtitle: Text(
            [
              l10n?.settingsLocalOnlySubtitle ??
                  'Your financial data is stored on this device, not in cloud backup.',
              l10n?.settingsLocalOnlyRisk ??
                  'Deleting the app or losing this phone can remove your data.',
            ].join(' '),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
          title: Text(
            'Privacy Policy',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
          ),
          subtitle: Text(
            'Not available yet',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          trailing: const Icon(Icons.info_outline, size: 18, color: AppColors.onSurfaceVariant),
          onTap: () => _showUnavailable(context, 'Privacy Policy is not available yet.'),
        ),
        const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description_outlined, color: AppColors.primary),
          title: Text(
            'Terms of Service',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
          ),
          subtitle: Text(
            'Not available yet',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          trailing: const Icon(Icons.info_outline, size: 18, color: AppColors.onSurfaceVariant),
          onTap: () => _showUnavailable(context, 'Terms of Service is not available yet.'),
        ),
      ],
    );
  }
}

class _QuotaStatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    EntryQuotaCubit? cubit;
    try {
      cubit = context.read<EntryQuotaCubit>();
    } catch (_) {
      cubit = null;
    }

    if (cubit == null) {
      return const _Section(
        title: 'Daily entry limits',
        subtitle: 'Local quota visibility',
        children: [
          _QuotaUnavailableTile(),
        ],
      );
    }

    return BlocBuilder<EntryQuotaCubit, EntryQuotaState>(
      bloc: cubit,
      builder: (context, state) {
        final isPremium = state.isPremium || (state.snapshot?.isPremium ?? false);
        return _Section(
          title: 'Daily entry limits',
          subtitle: isPremium
              ? 'Premium active'
              : 'Local to this device/account, not cloud tracking',
          children: [
            if (state.loading)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                title: Text(
                  'Loading entry limits',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                ),
                subtitle: Text(
                  'Checking today\'s local quota on this device/account.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              )
            else if (state.quotaUnavailable)
              const _QuotaUnavailableTile()
            else ...[
              _QuotaLimitTile(
                icon: Icons.receipt_long_outlined,
                title: 'Manual entries',
                value: isPremium ? 'Unlimited with Premium' : '${state.normalRemaining} left today',
              ),
              const Divider(height: 1, color: AppColors.surfaceContainerHigh),
              _QuotaLimitTile(
                icon: Icons.auto_awesome_outlined,
                title: 'AI entries',
                value: isPremium ? 'Unlimited with Premium' : '${state.aiRemaining} left today',
              ),
              const Divider(height: 1, color: AppColors.surfaceContainerHigh),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isPremium ? Icons.workspace_premium : Icons.phone_android_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  isPremium ? 'Premium active' : 'Stored locally',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                ),
                subtitle: Text(
                  isPremium
                      ? 'Ad-free and quota-free on this device/account. This does not move financial data online.'
                      : 'These limits are local to this device/account and are not cloud tracking.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _QuotaLimitTile extends StatelessWidget {
  const _QuotaLimitTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
      ),
      subtitle: Text(
        value,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _QuotaUnavailableTile extends StatelessWidget {
  const _QuotaUnavailableTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.info_outline, color: AppColors.primary),
      title: Text(
        'Entry limits unavailable',
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
      ),
      subtitle: Text(
        'Entry limits are unavailable right now. They are local to this device/account.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
      ),
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
        subtitle: Text(
          'Name, email, account settings',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: () => _openProfile(context),
      ),
      const Divider(height: 1, color: AppColors.surfaceContainerHigh),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.workspace_premium, color: AppColors.primary),
        title: Text(
          'Subscription',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
        ),
        subtitle: Text(
          'Free plan - premium unavailable yet',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: () => context.go(AppRoutes.subscription),
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
          title: Text(
            'Help Center',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
          ),
          subtitle: Text(
            'Not available yet',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          trailing: const Icon(Icons.info_outline, size: 18, color: AppColors.onSurfaceVariant),
          onTap: () => _showUnavailable(context, 'Help Center is not available yet.'),
        ),
        const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.feedback_outlined, color: AppColors.primary),
          title: Text(
            'Send Feedback',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
          ),
          subtitle: Text(
            'Not available yet',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          trailing: const Icon(Icons.info_outline, color: AppColors.onSurfaceVariant),
          onTap: () => _showUnavailable(context, 'Feedback is not available yet.'),
        ),
        const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline, color: AppColors.primary),
          title: Text('About', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface)),
          subtitle: Text(
            'Version 1.0.0+1',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          enabled: false,
        ),
      ],
    );
  }
}

class _DangerSection extends StatelessWidget {
  const _DangerSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Danger Zone',
      subtitle: 'Irreversible actions',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
          title: Text(
            'Delete Account',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
          subtitle: Text(
            'Open profile to manage account deletion',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          onTap: () => _openProfile(context),
        ),
      ],
    );
  }
}

UserSettings? _settingsFromState(SettingsState state) {
  if (state is SettingsSuccess) return state.settings;
  if (state is SettingsSaving) return state.tentative;
  return null;
}

bool _notificationsEnabled(NotificationSettings settings) {
  return settings.budgetAlerts ||
      settings.recurringReminders ||
      settings.subscriptionRenewals ||
      settings.weeklyDigest ||
      settings.aiQuotaWarnings ||
      settings.dailyReminder;
}

Future<void> _saveNotificationPreference(
  BuildContext context,
  SettingsState state,
  bool enabled,
  NotificationService notificationService,
) async {
  final current = _settingsFromState(state);
  if (current == null) {
    _showUnavailable(context, 'Settings are still loading.');
    return;
  }
  final l10n = AppLocalizations.of(context);
  await context.read<SettingsCubit>().saveNotificationPreference(
    enabled: enabled,
    notificationService: notificationService,
    dailyReminderTitle: l10n?.expenseReminderTitle ?? 'Expense reminder',
    dailyReminderBody: l10n?.expenseReminderBody ?? 'Log your expenses',
  );
}

void _openProfile(BuildContext context) {
  final authState = context.read<AuthBloc>().state;
  if (authState is AuthAuthenticated) {
    context.go(AppRoutes.accountProfile, extra: {'user': authState.user});
    return;
  }
  final currentUser = context.read<AuthRepository>().currentUser;
  final localUser = currentUser != null && currentUser.isNotEmpty
      ? currentUser
      : const AppUser(userId: 'local-only-device', email: '', providerId: 'local');
  context.go(AppRoutes.accountProfile, extra: {'user': localUser});
}

void _showUnavailable(BuildContext context, String message) {
  showAppToast(context, message, isError: true);
}
