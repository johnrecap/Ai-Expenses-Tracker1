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
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/features/recurring_expenses/recurring_expense_bloc/recurring_expense_bloc.dart';

class SubscriptionsCenterScreen extends StatelessWidget {
  const SubscriptionsCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: 'Subscriptions',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                  onPressed: () => context.pop(),
                ),
              ),
              Expanded(
                child: BlocBuilder<RecurringExpenseBloc, RecurringExpenseState>(
                  builder: (context, state) {
                    if (state is RecurringExpenseLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final activeItems = state is RecurringExpenseLoaded
                        ? state.activeItems
                        : <RecurringExpense>[];
                    final subscriptions = activeItems.where(_isSubscription).toList();

                    if (subscriptions.isEmpty) {
                      final recurringCount = activeItems.length;
                      return EmptyState(
                        icon: Icons.subscriptions_outlined,
                        title: 'No active subscriptions',
                        subtitle: recurringCount > 0
                            ? 'Recurring expenses in other categories are kept separate.'
                            : 'Items appear here only when they are categorized as subscriptions.',
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.containerPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Subscriptions',
                            style: AppTextStyles.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...subscriptions.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _SubscriptionCard(expense: e),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSubscription(RecurringExpense expense) {
  final normalizedCategory = expense.categoryId.trim().toLowerCase();
  return normalizedCategory == 'subscription' ||
      normalizedCategory == 'subscriptions' ||
      normalizedCategory == 'subs';
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.expense});
  final RecurringExpense expense;

  @override
  Widget build(BuildContext context) {
    final frequencyLabel =
        {
          'daily': '/day',
          'weekly': '/week',
          'monthly': '/mo',
          'yearly': '/year',
        }[expense.frequency] ??
        '/mo';

    final isActive = expense.endDate == null || expense.endDate!.isAfter(DateTime.now());
    final nextRun = expense.lastGeneratedDate != null
        ? '${expense.lastGeneratedDate!.day}/${expense.lastGeneratedDate!.month}'
        : _nextRunLabel(expense.startDate);

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                expense.name.isNotEmpty
                    ? expense.name.substring(0, minS(expense.name.length, 2)).toUpperCase()
                    : '?',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      expense.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${expense.amount.toStringAsFixed(3)} ${expense.currency}$frequencyLabel',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Next: $nextRun',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'active' : 'paused',
                        style: AppTextStyles.labelCaps.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _nextRunLabel(DateTime start) => '${start.day}/${start.month}';
}

int minS(int a, int b) => a < b ? a : b;
