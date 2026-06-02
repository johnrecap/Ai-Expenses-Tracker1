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
import 'package:expenses_tracker/features/expenses/presentation/widgets/transaction_tile.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';

class ReportDrilldownScreen extends StatelessWidget {
  const ReportDrilldownScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final reportState = context.watch<ReportCubit>().state;
    final filtered = reportState.expensesForCategory(categoryId);
    final total = filtered.fold<double>(0, (s, e) => s + e.amount);
    final categoryName = filtered.isNotEmpty
        ? filtered.first.categoryName
        : reportState.categoryNameFor(categoryId);
    final currency = filtered.isNotEmpty ? filtered.first.currency : _displayCurrency(context);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: categoryName,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.pie_chart,
                        title: 'No expenses for this category',
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.containerPadding),
                            child: GlassCard(
                              child: Column(
                                children: [
                                  Text(
                                    total.toStringAsFixed(3),
                                    style: AppTextStyles.displayMobile.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$currency total',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    '${filtered.length} transaction${filtered.length == 1 ? '' : 's'}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.containerPadding,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => TransactionTile(expense: filtered[i]),
                            ),
                          ),
                        ],
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
