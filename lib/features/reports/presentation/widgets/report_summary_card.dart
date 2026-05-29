import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';

class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({
    super.key,
    required this.total,
    required this.comparison,
    required this.period,
  });

  final String total;
  final String comparison;
  final String period;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(period, style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
              const Spacer(),
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.secondaryContainer),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(total, style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface)),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                comparison.startsWith('+') ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: comparison.startsWith('+') ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(comparison, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
