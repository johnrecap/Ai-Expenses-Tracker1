import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/features/onboarding/onboarding_cubit/onboarding_cubit.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';

class OnboardingLanguageScreen extends StatefulWidget {
  const OnboardingLanguageScreen({super.key});

  @override
  State<OnboardingLanguageScreen> createState() => _OnboardingLanguageScreenState();
}

class _OnboardingLanguageScreenState extends State<OnboardingLanguageScreen> {
  bool _isEnglish = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
            child: Column(
              children: [
                const SizedBox(height: 48),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.glassCardFill,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassCardBorder, width: 1),
                  ),
                  child: const Icon(Icons.language, size: 32, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.onboardingLanguageTitle,
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.onboardingLanguageSubtitle,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: ListView(
                    children: [
                      _LanguageCard(
                        title: l10n.onboardingLanguageEnglish,
                        subtitle: l10n.onboardingLanguageEnglishRegion,
                        iconData: Icons.language,
                        isSelected: _isEnglish,
                        onTap: () => setState(() => _isEnglish = true),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _LanguageCard(
                        title: l10n.onboardingLanguageArabic,
                        subtitle: l10n.onboardingLanguageArabicRegion,
                        iconData: Icons.language,
                        isSelected: !_isEnglish,
                        onTap: () => setState(() => _isEnglish = false),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: GradientButton(
                    label: l10n.continueButton,
                    onPressed: () {
                      context.read<OnboardingCubit>().setLanguage(_isEnglish ? 'en' : 'ar');
                      context.go(AppRoutes.onboardingCurrency);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData iconData;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      fillColor: isSelected ? AppColors.primaryContainer.withAlpha(25) : AppColors.glassCardFill,
      borderColor: isSelected ? AppColors.primary : AppColors.glassCardBorder,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer.withAlpha(30)
                    : AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
