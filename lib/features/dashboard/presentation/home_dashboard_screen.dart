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
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/dashboard/presentation/widgets/smart_add_sheet.dart';
import 'package:expenses_tracker/features/recurring_expenses/recurring_expense_bloc/recurring_expense_bloc.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'package:expenses_tracker/monetization/widgets/app_ad_slot.dart';
import '../../expenses/presentation/widgets/transaction_tile.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  static const smartAddButtonKey = Key('home-smart-add-button');
  static const smartAddFabPaddingKey = Key('home-smart-add-fab-padding');
  static const menuButtonKey = Key('home-menu-button');
  static const profileButtonKey = Key('home-profile-button');
  static const drawerKey = Key('home-sidebar-drawer');
  static const topBarAiAssistantKey = Key('home-top-ai-assistant-button');
  static const double _fabBottomLift = 72;
  static const int _recentTransactionsPreviewLimit = 6;

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'تصبح على الخير';
  }

  void _openSmartAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SmartAddSheet(
        onRouteSelected: (route) {
          Navigator.of(sheetContext).pop();
          context.go(route);
        },
      ),
    );
  }

  String _smartAddButtonLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) return l10n.smartAddButtonLabel;
    return Localizations.localeOf(context).languageCode == 'ar' ? 'إضافة مصروف' : 'Add expense';
  }

  void _openProfile(BuildContext context) {
    final user = _readCurrentUser(context);
    context.go(
      AppRoutes.accountProfile,
      extra: user == null ? null : {'user': user},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _HomeSidebar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        key: smartAddFabPaddingKey,
        padding: const EdgeInsets.only(bottom: _fabBottomLift),
        child: FloatingActionButton(
          key: smartAddButtonKey,
          onPressed: () => _openSmartAddSheet(context),
          backgroundColor: AppColors.primary,
          heroTag: 'smart_add_fab',
          tooltip: _smartAddButtonLabel(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: BlocBuilder<GetExpensesBloc, GetExpensesState>(
            builder: (context, state) {
              final recentExpenses = state is GetExpensesSuccess
                  ? state.expenses.take(_recentTransactionsPreviewLimit).toList()
                  : <Expense>[];

              return Column(
                children: [
                  AppTopBar(
                    title: _getGreeting(context),
                    leading: Builder(
                      builder: (buttonContext) => IconButton(
                        key: menuButtonKey,
                        tooltip: 'Menu',
                        icon: const Icon(Icons.menu, color: AppColors.onSurface),
                        onPressed: () => Scaffold.of(buttonContext).openDrawer(),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: profileButtonKey,
                          tooltip: 'Profile',
                          onPressed: () => _openProfile(context),
                          icon: const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryContainer,
                            child: Icon(Icons.person, size: 16, color: AppColors.primary),
                          ),
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
                            const AppAdSlot.homeBanner(),
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
                              const EmptyState(
                                icon: Icons.receipt_long,
                                title: 'No recent transactions',
                              )
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

class _HomeSidebar extends StatelessWidget {
  const _HomeSidebar();

  void _navigate(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.go(route);
  }

  void _openProfile(BuildContext context) {
    final user = _readCurrentUser(context);
    Navigator.of(context).pop();
    context.go(
      AppRoutes.accountProfile,
      extra: user == null ? null : {'user': user},
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _readCurrentUser(context);
    final displayName = user?.displayName?.trim();
    final email = user?.email.trim();

    return Drawer(
      key: HomeDashboardScreen.drawerKey,
      backgroundColor: AppColors.surfaceContainerLowest,
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.containerPadding),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName?.isNotEmpty == true ? displayName! : 'Account',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (email?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            email!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _SidebarItem(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () => _openProfile(context),
            ),
            _SidebarItem(
              icon: Icons.receipt_long_outlined,
              title: 'Expenses',
              onTap: () => _navigate(context, AppRoutes.expenses),
            ),
            _SidebarItem(
              icon: Icons.query_stats_outlined,
              title: 'Reports',
              onTap: () => _navigate(context, AppRoutes.reports),
            ),
            _SidebarItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Budgets',
              onTap: () => _navigate(context, AppRoutes.budgets),
            ),
            _SidebarItem(
              icon: Icons.savings_outlined,
              title: 'Goals',
              onTap: () => _navigate(context, AppRoutes.goals),
            ),
            _SidebarItem(
              icon: Icons.credit_card_outlined,
              title: 'Wallets',
              onTap: () => _navigate(context, AppRoutes.wallets),
            ),
            _SidebarItem(
              icon: Icons.subscriptions_outlined,
              title: 'Subscriptions',
              onTap: () => _navigate(context, AppRoutes.subscriptions),
            ),
            _SidebarItem(
              icon: Icons.category_outlined,
              title: 'Categories',
              onTap: () => _navigate(context, AppRoutes.categories),
            ),
            _SidebarItem(
              icon: Icons.auto_awesome_outlined,
              title: 'AI Advice',
              onTap: () => _navigate(context, AppRoutes.aiAdvice),
            ),
            _SidebarItem(
              icon: Icons.history_outlined,
              title: 'AI History',
              onTap: () => _navigate(context, AppRoutes.aiHistory),
            ),
            _SidebarItem(
              icon: Icons.menu_book_outlined,
              title: 'Monthly Story',
              onTap: () => _navigate(context, AppRoutes.storyMonthly),
            ),
            const Divider(),
            _SidebarItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => _navigate(context, AppRoutes.settings),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurfaceVariant),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
      ),
      onTap: onTap,
    );
  }
}

AppUser? _readCurrentUser(BuildContext context) {
  try {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) return state.user;
  } catch (_) {}
  try {
    final user = context.read<AuthRepository>().currentUser;
    if (user != null && user.isNotEmpty) return user;
  } catch (_) {}
  return null;
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
              Text(
                'THIS MONTH SPENDING',
                style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.secondaryContainer),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                spent.toStringAsFixed(2),
                style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  currency,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
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
                    Text(
                      'Budget Left',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${remaining.toStringAsFixed(2)} $currency',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Category',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topCategory?.key ?? '—',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: AppRadii.pill,
            ),
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
    return UserSettings.defaultBaseCurrency;
  }
}

class _InsightGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expensesState = context.watch<GetExpensesBloc>().state;
    final expenses = expensesState is GetExpensesSuccess
        ? expensesState.expenses
        : const <Expense>[];
    final weeklySubtitle = _weeklyReviewSubtitle(expenses, _readCurrency(context));
    final upcomingSubtitle = _upcomingBillsSubtitle(context, _readCurrency(context));

    return Row(
      children: [
        Expanded(
          child: _InsightCard(
            icon: Icons.insights,
            iconColor: AppColors.tertiary,
            title: 'Weekly Review',
            subtitle: weeklySubtitle,
            onTap: () => context.go(AppRoutes.reports),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _InsightCard(
            icon: Icons.flag,
            iconColor: AppColors.secondary,
            title: 'Upcoming Bills',
            subtitle: upcomingSubtitle,
            onTap: () => context.go(AppRoutes.subscriptions),
          ),
        ),
      ],
    );
  }

  String _weeklyReviewSubtitle(List<Expense> expenses, String currency) {
    if (expenses.isEmpty) return 'Add expenses to see this week';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final previousWeekStart = weekStart.subtract(const Duration(days: 7));
    final thisWeek = _sumBetween(expenses, weekStart, today.add(const Duration(days: 1)));
    final previousWeek = _sumBetween(expenses, previousWeekStart, weekStart);
    if (thisWeek == 0) return 'No spending this week';
    if (previousWeek == 0) return '${thisWeek.toStringAsFixed(0)} $currency this week';
    final change = ((thisWeek - previousWeek) / previousWeek * 100).round();
    if (change == 0) return 'Same as last week';
    return change > 0 ? '+$change% vs last week' : '$change% vs last week';
  }

  double _sumBetween(List<Expense> expenses, DateTime start, DateTime end) {
    return expenses
        .where((expense) => !expense.date.isBefore(start) && expense.date.isBefore(end))
        .fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  String _upcomingBillsSubtitle(BuildContext context, String currency) {
    RecurringExpenseState? recurringState;
    try {
      recurringState = context.watch<RecurringExpenseBloc>().state;
    } catch (_) {
      recurringState = null;
    }
    if (recurringState is! RecurringExpenseLoaded) return 'No bill reminders yet';

    final now = DateTime.now();
    final upcoming =
        recurringState.activeItems
            .map((item) => _nextRun(item, now))
            .where((item) => item.date.difference(now).inDays <= 14)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    if (upcoming.isEmpty) return 'No bills in 14 days';
    final next = upcoming.first;
    return '${next.name}: ${next.amount.toStringAsFixed(0)} $currency in ${next.daysLeft}d';
  }

  _UpcomingBill _nextRun(RecurringExpense item, DateTime now) {
    final anchor = item.lastGeneratedDate ?? item.startDate;
    var next = anchor;
    while (!next.isAfter(now)) {
      next = switch (item.frequency.trim().toLowerCase()) {
        'daily' => next.add(const Duration(days: 1)),
        'weekly' => next.add(const Duration(days: 7)),
        'yearly' => DateTime(next.year + 1, next.month, next.day),
        _ => DateTime(next.year, next.month + 1, next.day),
      };
    }
    return _UpcomingBill(
      name: item.name,
      amount: item.amount,
      date: next,
      daysLeft: next.difference(now).inDays.clamp(0, 999),
    );
  }

  String _readCurrency(BuildContext context) {
    try {
      final s = context.read<SettingsCubit>().state;
      if (s is SettingsSuccess) return s.settings.baseCurrency;
    } catch (_) {}
    return UserSettings.defaultBaseCurrency;
  }
}

class _UpcomingBill {
  const _UpcomingBill({
    required this.name,
    required this.amount,
    required this.date,
    required this.daysLeft,
  });

  final String name;
  final double amount;
  final DateTime date;
  final int daysLeft;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadii.card,
      onTap: onTap,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.outline),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
