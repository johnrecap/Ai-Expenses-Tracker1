import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.trendLabel,
    this.trendUp,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  final String label;
  final String value;
  final String? trendLabel;
  final bool? trendUp;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trendColor = trendUp == true
        ? AppColors.primary
        : trendUp == false
            ? AppColors.error
            : null;

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primaryContainer).withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface),
          ),
          if (trendLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                if (trendColor != null)
                  Icon(
                    trendUp == true ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: trendColor,
                  ),
                if (trendColor != null) const SizedBox(width: 4),
                Text(
                  trendLabel!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: trendColor ?? AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
