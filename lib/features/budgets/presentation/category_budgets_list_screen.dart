import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/progress_bar.dart';

class CategoryBudgetsListScreen extends StatelessWidget {
  const CategoryBudgetsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(title: 'Category Budgets', leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monthly Allocations', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.md),
                      _BudgetRow(label: 'Food & Dining', allocated: 400, spent: 245.5, color: const Color(0xFFFF7043)),
                      _BudgetRow(label: 'Transport', allocated: 150, spent: 85, color: const Color(0xFF42A5F5)),
                      _BudgetRow(label: 'Shopping', allocated: 200, spent: 100, color: const Color(0xFFAB47BC)),
                      _BudgetRow(label: 'Entertainment', allocated: 150, spent: 60, color: const Color(0xFFFFCA28)),
                      _BudgetRow(label: 'Healthcare', allocated: 100, spent: 45, color: const Color(0xFFEF5350)),
                      _BudgetRow(label: 'Utilities', allocated: 200, spent: 52, color: const Color(0xFF8D6E63)),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.label, required this.allocated, required this.spent, required this.color});
  final String label;
  final double allocated;
  final double spent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = allocated > 0 ? spent / allocated : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${spent.toStringAsFixed(1)} / $allocated KWD', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ProgressBar(progress: progress, height: 6, progressColor: color),
        ],
      ),
    );
  }
}
