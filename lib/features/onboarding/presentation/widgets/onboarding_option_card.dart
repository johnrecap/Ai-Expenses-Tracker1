import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';

class OnboardingOptionCard extends StatelessWidget {
  const OnboardingOptionCard({
    super.key,
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
      fillColor: isSelected
          ? AppColors.primaryContainer.withAlpha(25)
          : AppColors.glassCardFill,
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
