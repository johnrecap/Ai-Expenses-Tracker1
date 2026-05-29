import 'package:flutter/material.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/progress_ring.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal});

  final SavingGoal goal;

  @override
  Widget build(BuildContext context) {
    final target = goal.targetAmount;
    final current = goal.currentAmount;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final deadline = goal.deadline != null
        ? '${goal.deadline!.year}-${goal.deadline!.month.toString().padLeft(2, '0')}'
        : 'No deadline';

    return GlassCard(
      child: Row(
        children: [
          ProgressRing(progress: progress, size: 72, strokeWidth: 5),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text('${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                    const Spacer(),
                    Text(deadline, style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
