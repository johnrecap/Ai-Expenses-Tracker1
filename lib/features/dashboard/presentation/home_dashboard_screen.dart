import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import '../../expenses/presentation/widgets/transaction_tile.dart';
import '../../../features/ai/presentation/ai_assistant_sheet.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'تصبح على الخير';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر الـ AI
          FloatingActionButton.small(
            onPressed: () => context.go(AppRoutes.expensesNewAi),
            backgroundColor: AppColors.secondary,
            heroTag: 'ai_fab',
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // زر الإضافة العادي
          FloatingActionButton(
            onPressed: () => context.go(AppRoutes.expensesNewQuick),
            backgroundColor: AppColors.primary,
            heroTag: 'add_fab',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: BlocBuilder<GetExpensesBloc, GetExpensesState>(
            builder: (context, state) {
              final recentExpenses = state is GetExpensesSuccess
                  ? state.expenses.take(3).toList()
                  : <Expense>[];

              return Column(
                children: [
                  AppTopBar(
                    title: _getGreeting(context),
                    leading: IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.onSurface),
                      onPressed: () {},
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.auto_awesome, color: AppColors.secondaryContainer, size: 22),
                          onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AiAssistantSheet(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.person, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.containerPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            _HeroCard(),
                            const SizedBox(height: AppSpacing.md),
                            _InsightGrid(),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Text(
                                  'Recent Transactions',
                                  style: AppTextStyles.labelCaps.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => context.go(AppRoutes.expenses),
                                  child: Text(
                                    'View All',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            if (state is GetExpensesLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (recentExpenses.isEmpty)
                              const EmptyState(icon: Icons.receipt_long, title: 'No recent transactions')
                            else
                              GlassCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: recentExpenses.asMap().entries.map((entry) {
                                    final isLast = entry.key == recentExpenses.length - 1;
                                    return Column(
                                      children: [
                                        TransactionTile(expense: entry.value),
                                        if (!isLast)
                                          const Divider(
                                            height: 1,
                                            indent: AppSpacing.md,
                                            endIndent: AppSpacing.md,
                                            color: AppColors.surfaceContainerHigh,
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  AppBottomNav(
                    selectedIndex: 0,
                    onDestinationSelected: (index) {
                      switch (index) {
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
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reportState = context.watch<ReportCubit>().state;
    final spent = reportState.totalSpent;
    final budgetState = context.watch<BudgetBloc>().state;
    final budgetAmount = budgetState is BudgetLoaded ? budgetState.budget?.amount ?? 0.0 : 0.0;
    final remaining = (budgetAmount - spent).clamp(0, double.infinity);
    final progress = budgetAmount > 0 ? (spent / budgetAmount).clamp(0.0, 1.0) : 0.0;
    final topCategory = reportState.categoryTotals.entries.isNotEmpty
        ? reportState.categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;
    final currency = _readCurrency(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('THIS MONTH SPENDING', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
              const Spacer(),
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.secondaryContainer),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(spent.toStringAsFixed(2), style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface)),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(currency, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.surfaceContainerHigh),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget Left', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text('${remaining.toStringAsFixed(2)} $currency', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top Category', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(topCategory?.key ?? '—', style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 8,
            decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: AppRadii.pill),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: progress > 0.9 ? AppColors.error : AppColors.primaryContainer,
                  borderRadius: AppRadii.pill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _readCurrency(BuildContext context) {
    try {
      final s = context.read<SettingsCubit>().state;
      if (s is SettingsSuccess) return s.settings.baseCurrency;
    } catch (_) {}
    return 'KWD';
  }
}

class _InsightGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _InsightCard(
            icon: Icons.insights,
            iconColor: AppColors.tertiary,
            badge: 'New',
            title: 'Weekly Review',
            subtitle: 'Spending is down 12%',
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _InsightCard(
            icon: Icons.flag,
            iconColor: AppColors.secondary,
            title: 'Upcoming Bills',
            subtitle: '2 due this week',
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.iconColor,
    this.badge,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String? badge;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer.withAlpha(100),
                    borderRadius: AppRadii.pill,
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.labelCaps.copyWith(
                      color: AppColors.tertiary,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
