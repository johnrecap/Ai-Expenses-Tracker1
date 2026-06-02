import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/progress_bar.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';

class BudgetsOverviewScreen extends StatelessWidget {
  const BudgetsOverviewScreen({super.key});

  String _displayCurrency(BuildContext context) {
    try {
      final s = context.read<SettingsCubit>().state;
      if (s is SettingsSuccess) return s.settings.baseCurrency;
    } catch (_) {}
    return UserSettings.defaultBaseCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, budgetState) {
              return BlocBuilder<ReportCubit, ReportState>(
                builder: (context, reportCubitState) {
                  final budget = budgetState is BudgetLoaded ? budgetState.budget : null;
                  final totalBudget = budget?.amount ?? 0.0;
                  final spent = reportCubitState.totalSpent;
                  final progress = totalBudget > 0 ? (spent / totalBudget).clamp(0.0, 1.0) : 0.0;

                  return Column(
                    children: [
                      AppTopBar(
                        title: 'Budgets',
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.onSurface),
                          onPressed: () => context.go(AppRoutes.budgetsMonthlyEdit),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.containerPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'THIS MONTH',
                                      style: AppTextStyles.labelCaps.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          spent.toStringAsFixed(2),
                                          style: AppTextStyles.displayMobile.copyWith(
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        Text(
                                          ' / ${totalBudget.toStringAsFixed(2)} ${_displayCurrency(context)}',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    ProgressBar(
                                      progress: progress,
                                      progressColor: progress > 0.9
                                          ? AppColors.error
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}% used',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      '${(totalBudget - spent).clamp(0, double.infinity).toStringAsFixed(2)} ${_displayCurrency(context)} remaining',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                'Category Breakdown',
                                style: AppTextStyles.labelCaps.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              if (!reportCubitState.loading)
                                ...reportCubitState.categoryTotals.entries.take(6).map((entry) {
                                  final catProgress = totalBudget > 0
                                      ? (entry.value / totalBudget).clamp(0.0, 1.0)
                                      : 0.0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                    child: _CategoryBudgetTile(
                                      label: entry.key,
                                      spent: entry.value,
                                      cap: totalBudget,
                                      progress: catProgress,
                                      color: AppColors.primary,
                                    ),
                                  );
                                }),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                      AppBottomNav(
                        selectedIndex: 2,
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
                            default:
                              break;
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryBudgetTile extends StatelessWidget {
  final String label;
  final double spent;
  final double cap;
  final double progress;
  final Color color;
  const _CategoryBudgetTile({
    required this.label,
    required this.spent,
    required this.cap,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${spent.toStringAsFixed(2)} / ${cap.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ProgressBar(progress: progress, progressColor: progress > 0.9 ? AppColors.error : color),
        ],
      ),
    );
  }
}
