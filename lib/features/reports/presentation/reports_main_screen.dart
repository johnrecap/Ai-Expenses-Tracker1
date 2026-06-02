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
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/core/widgets/progress_bar.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'widgets/report_summary_card.dart';

class ReportsMainScreen extends StatelessWidget {
  const ReportsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: BlocBuilder<ReportCubit, ReportState>(
            builder: (context, reportState) {
              final currency = _displayCurrency(context);
              return Column(
                children: [
                  const AppTopBar(title: 'Reports'),
                  Expanded(
                    child: reportState.loading
                        ? const Center(child: CircularProgressIndicator())
                        : reportState.expenses.isEmpty
                        ? const EmptyState(
                            icon: Icons.pie_chart,
                            title: 'No data',
                            subtitle: 'Add expenses to see your reports',
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(AppSpacing.containerPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReportSummaryCard(
                                  total: '${reportState.totalSpent.toStringAsFixed(2)} $currency',
                                  comparison:
                                      '${reportState.monthComparison != null ? (reportState.monthComparison!.changePercent > 0 ? "+" : "") : ""}${reportState.monthComparison?.changePercent.toStringAsFixed(1) ?? "0"}% vs last month',
                                  period: reportState.periodLabel,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'Categories',
                                  style: AppTextStyles.labelCaps.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                ...reportState.categorySummaries.take(6).map((summary) {
                                  final pct = reportState.totalSpent > 0
                                      ? (summary.amount / reportState.totalSpent).clamp(0.0, 1.0)
                                      : 0.0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                    child: GestureDetector(
                                      onTap: () => context.go(
                                        '/reports/category/${Uri.encodeComponent(summary.categoryId)}',
                                      ),
                                      child: _CategoryRow(
                                        label: summary.categoryName,
                                        amount: summary.amount,
                                        percent: pct,
                                        currency: currency,
                                        color: _colorForCategory(summary.categoryName),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                  ),
                  AppBottomNav(
                    selectedIndex: 1,
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
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Color _colorForCategory(String name) {
    switch (name) {
      case 'Food':
        return const Color(0xFFFF7043);
      case 'Transport':
        return const Color(0xFF42A5F5);
      case 'Shopping':
        return const Color(0xFFAB47BC);
      case 'Housing':
        return const Color(0xFF66BB6A);
      case 'Entertainment':
        return const Color(0xFFFFCA28);
      case 'Healthcare':
        return const Color(0xFFEF5350);
      case 'Utilities':
        return const Color(0xFF8D6E63);
      default:
        return AppColors.primary;
    }
  }

  static String _displayCurrency(BuildContext context) {
    try {
      final state = context.watch<SettingsCubit>().state;
      if (state is SettingsSuccess) return state.settings.baseCurrency;
    } catch (_) {}
    return UserSettings.defaultBaseCurrency;
  }
}

class _CategoryRow extends StatelessWidget {
  final String label;
  final double amount;
  final double percent;
  final String currency;
  final Color color;
  const _CategoryRow({
    required this.label,
    required this.amount,
    required this.percent,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${amount.toStringAsFixed(1)} $currency (${(percent * 100).toStringAsFixed(0)}%)',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ProgressBar(progress: percent, height: 6, progressColor: color),
      ],
    );
  }
}
