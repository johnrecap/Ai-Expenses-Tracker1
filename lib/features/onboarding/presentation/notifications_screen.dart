import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/features/onboarding/onboarding_cubit/onboarding_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'package:expenses_tracker/services/notifications/notification_service.dart';
import 'package:expenses_tracker/app/routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.notificationService,
  });

  final NotificationService? notificationService;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _dailyReminder = true;
  bool _weeklyDigest = true;
  String _deliveryTime = '20:00';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          showAppToast(context, state.errorMessage!, isError: true);
          return;
        }
        if (state.completed) {
          context.read<AppLanguageCubit>().setPreference(
            state.language == 'ar' ? LanguagePreference.arabic : LanguagePreference.english,
          );
          try {
            context.read<SettingsCubit>().loadSettings();
          } catch (_) {}
          context.go(AppRoutes.home);
        }
      },
      builder: (context, onboardingState) {
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ProgressDot(isActive: false),
                            SizedBox(width: 4),
                            _ProgressDot(isActive: false),
                            SizedBox(width: 4),
                            _ProgressDot(isActive: true),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.onboardingStepThree,
                      style: AppTextStyles.labelCaps.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.onboardingNotificationsTitle,
                      style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.onboardingNotificationsSubtitle,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: ListView(
                        children: [
                          _NotificationCard(
                            icon: Icons.notifications_active,
                            iconColor: AppColors.primary,
                            title: l10n.onboardingDailyReminderTitle,
                            subtitle: l10n.onboardingDailyReminderSubtitle,
                            isToggled: _dailyReminder,
                            onToggle: onboardingState.loading
                                ? (_) {}
                                : (v) => setState(() => _dailyReminder = v),
                            trailing: _dailyReminder
                                ? Padding(
                                    padding: const EdgeInsets.only(top: AppSpacing.md),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule,
                                          size: 14,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          l10n.onboardingNotificationTime,
                                          style: AppTextStyles.labelCaps.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: _pickTime,
                                          child: Container(
                                            padding: const EdgeInsetsDirectional.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: AppColors.outlineVariant),
                                              borderRadius: AppRadii.pill,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  _deliveryTime,
                                                  style: AppTextStyles.labelCaps.copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.expand_more,
                                                  size: 16,
                                                  color: AppColors.primary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _NotificationCard(
                            icon: Icons.mark_email_unread,
                            iconColor: AppColors.secondaryContainer,
                            title: l10n.onboardingWeeklyDigestTitle,
                            subtitle: l10n.onboardingWeeklyDigestSubtitle,
                            isToggled: _weeklyDigest,
                            onToggle: onboardingState.loading
                                ? (_) {}
                                : (v) => setState(() => _weeklyDigest = v),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: IgnorePointer(
                        ignoring: onboardingState.loading,
                        child: Opacity(
                          opacity: onboardingState.loading ? 0.65 : 1,
                          child: GradientButton(
                            label: onboardingState.loading
                                ? l10n.onboardingSaving
                                : l10n.onboardingEnableNotifications,
                            onPressed: () => _finishOnboarding(allowNotifications: true),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xl),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: onboardingState.loading
                              ? null
                              : () => _finishOnboarding(allowNotifications: false),
                          child: Text(
                            l10n.skipForNow,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _finishOnboarding({required bool allowNotifications}) async {
    final l10n = AppLocalizations.of(context)!;
    final reminderTime = _deliveryTime;
    final notificationService = widget.notificationService ?? NotificationService.instance;
    var permissionGranted = false;
    if (allowNotifications) {
      permissionGranted = await notificationService.requestNotificationPermission();
      if (permissionGranted && _dailyReminder) {
        await notificationService.scheduleDailyReminder(
          title: l10n.expenseReminderTitle,
          body: l10n.expenseReminderBody,
          time24h: reminderTime,
          settings: NotificationSettings(
            budgetAlerts: true,
            recurringReminders: true,
            subscriptionRenewals: true,
            weeklyDigest: _weeklyDigest,
            aiQuotaWarnings: true,
            dailyReminder: true,
            dailyReminderTime: reminderTime,
          ),
          requestPermissionIfNeeded: false,
        );
      }
    }
    if (!mounted) return;
    context.read<OnboardingCubit>().setNotificationChoices(
      dailyReminderEnabled: _dailyReminder,
      weeklyDigestEnabled: _weeklyDigest,
      dailyReminderTime: reminderTime,
    );
    await context.read<OnboardingCubit>().completeOnboarding(
      notificationsEnabled: allowNotifications && permissionGranted,
      dailyReminderEnabled: _dailyReminder,
      weeklyDigestEnabled: _weeklyDigest,
      dailyReminderTime: reminderTime,
    );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (time != null && mounted) {
      setState(() {
        _deliveryTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
        borderRadius: AppRadii.pill,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isToggled,
    required this.onToggle,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isToggled;
  final ValueChanged<bool> onToggle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isToggled,
                  onChanged: onToggle,
                  activeTrackColor: AppColors.primaryContainer,
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
            if (trailing != null) ...[
              const Divider(height: 24, color: AppColors.surfaceContainerHigh),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
