import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';

class MonthlyFinancialStoryScreen extends StatelessWidget {
  const MonthlyFinancialStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportState = context.read<ReportCubit>().state;
    final currency = _displayCurrency(context);
    final totalSpent = reportState.totalSpent;
    final categories = reportState.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = categories.isNotEmpty ? categories.first : null;
    final comparison = reportState.monthComparison;
    final topExpense = reportState.expenses.isNotEmpty
        ? reportState.expenses.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: 'Monthly Story',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StoryPanel(
                        icon: Icons.account_balance_wallet,
                        title: 'This Month Summary',
                        body: reportState.loading
                            ? 'Loading...'
                            : 'Your total spending this month is ${totalSpent.toStringAsFixed(2)} $currency'
                                  '${comparison != null ? ' - ${comparison.changePercent > 0 ? "up" : "down"} ${comparison.changePercent.abs().toStringAsFixed(1)}% vs last month' : ''}.',
                      ),
                      if (topCategory != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _StoryPanel(
                          icon: Icons.pie_chart,
                          title: 'Top Category: ${topCategory.key}',
                          body:
                              '${topCategory.key} at ${topCategory.value.toStringAsFixed(2)} $currency makes up ${totalSpent > 0 ? (topCategory.value / totalSpent * 100).toStringAsFixed(0) : "0"}% of your monthly spend.',
                        ),
                      ],
                      if (topExpense != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _StoryPanel(
                          icon: Icons.trending_up,
                          title: 'Biggest Single Expense',
                          body:
                              'Your largest single expense was ${topExpense.merchant ?? topExpense.description} for ${topExpense.amount.toStringAsFixed(2)} ${topExpense.currency} on ${topExpense.date.day}/${topExpense.date.month}.',
                        ),
                      ],
                      if (categories.length >= 2) ...[
                        const SizedBox(height: AppSpacing.md),
                        _StoryPanel(
                          icon: Icons.category,
                          title: 'Your Top Categories',
                          body: categories
                              .take(3)
                              .map((e) => '${e.key} (${e.value.toStringAsFixed(1)} $currency)')
                              .join(', '),
                        ),
                      ],
                      if (reportState.expenses.isEmpty && !reportState.loading) ...[
                        const SizedBox(height: AppSpacing.md),
                        const _StoryPanel(
                          icon: Icons.add_circle,
                          title: 'No expenses yet',
                          body:
                              'Start tracking your expenses to see your monthly financial story come to life.',
                        ),
                      ],
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

  String _displayCurrency(BuildContext context) {
    try {
      final state = context.watch<SettingsCubit>().state;
      if (state is SettingsSuccess) return state.settings.baseCurrency;
    } catch (_) {}
    return UserSettings.defaultBaseCurrency;
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
          ),
        ],
      ),
    );
  }
}
