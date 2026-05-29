import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({
    super.key,
    required this.title,
    required this.summary,
    this.severity,
    this.onTap,
  });

  final String title;
  final String summary;
  final String? severity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: AppRadii.card,
          gradient: LinearGradient(
            colors: [
              AppColors.aiGradientStart,
              AppColors.aiGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassCardFill,
            borderRadius: BorderRadius.circular(22.5),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 18, color: AppColors.secondaryContainer),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (severity != null) ...[
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withAlpha(150),
                        borderRadius: AppRadii.pill,
                      ),
                      child: Text(
                        severity!,
                        style: AppTextStyles.labelCaps.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                summary,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
