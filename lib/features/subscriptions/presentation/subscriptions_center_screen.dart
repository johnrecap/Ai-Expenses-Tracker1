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
          child: Column(children: [
            AppTopBar(
              title: 'Subscriptions',
              leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
            ),
            Expanded(
              child: BlocBuilder<RecurringExpenseBloc, RecurringExpenseState>(
                builder: (context, state) {
                  if (state is RecurringExpenseLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final expenses = state is RecurringExpenseLoaded ? state.expenses.where((e) => e.isActive).toList() : <RecurringExpense>[];

                  if (expenses.isEmpty) {
                    return const EmptyState(message: 'No active subscriptions');
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.containerPadding),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Active Subscriptions', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      ...expenses.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _SubscriptionCard(expense: e),
                      )),
                      const SizedBox(height: 80),
                    ]),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.expense});
  final RecurringExpense expense;

  @override
  Widget build(BuildContext context) {
    final frequencyLabel = {
      'daily': '/day', 'weekly': '/week', 'monthly': '/mo', 'yearly': '/year',
    }[expense.frequency] ?? '/mo';

    final nextBilling = expense.nextRunDate != null
        ? '${expense.nextRunDate!.day}/${expense.nextRunDate!.month}'
        : 'N/A';

    return GlassCard(
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              expense.description.isNotEmpty ? expense.description.substring(0, minS(expense.description.length, 2)).toUpperCase() : '?',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(expense.description, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${expense.amount.toStringAsFixed(3)} ${expense.currency}$frequencyLabel',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 2),
            Row(children: [
              Text('Next: $nextBilling', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(50),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(expense.isActive ? 'active' : 'paused',
                  style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary, fontSize: 10)),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

int minS(int a, int b) => a < b ? a : b;
