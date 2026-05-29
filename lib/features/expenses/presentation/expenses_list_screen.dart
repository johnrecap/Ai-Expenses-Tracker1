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
import 'package:expenses_tracker/core/widgets/search_field.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/expenses/expense_filter_cubit/expense_filter_cubit.dart';
import 'widgets/transaction_section.dart';
import 'expense_filters_sheet.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  final _searchController = TextEditingController();
  int _activeChip = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    context.read<ExpenseFilterCubit>().updateQuery(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.expensesNewQuick),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: 'AI Expenses Tracker',
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.onSurface),
                  onPressed: () {},
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.account_circle, color: AppColors.onSurface),
                  onPressed: () {},
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                ),
                child: Column(
                  children: [
                    SearchField(
                      controller: _searchController,
                      hintText: 'Search transactions...',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            icon: Icons.calendar_today,
                            label: 'This Month',
                            isActive: _activeChip == 0,
                            onTap: () => setState(() => _activeChip = 0),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterChip(
                            icon: Icons.category,
                            label: 'Category',
                            isActive: _activeChip == 1,
                            onTap: () => setState(() => _activeChip = 1),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterChip(
                            icon: Icons.payments,
                            label: 'Amount',
                            isActive: _activeChip == 2,
                            onTap: () => setState(() => _activeChip = 2),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterChip(
                            icon: Icons.tune,
                            label: 'More Filters',
                            isActive: _activeChip == 3,
                            onTap: () => _showFilterSheet(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
              Expanded(
                child: BlocConsumer<GetExpensesBloc, GetExpensesState>(
                  listener: (context, expensesState) {
                    if (expensesState is GetExpensesSuccess && expensesState.expenses.isNotEmpty) {
                      context.read<ExpenseFilterCubit>().replaceExpenses(expensesState.expenses);
                    }
                  },
                  builder: (context, expensesState) {
                    if (expensesState is GetExpensesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return BlocBuilder<ExpenseFilterCubit, ExpenseFilterState>(
                      builder: (context, filterState) {
                        final filtered = filterState.filteredExpenses;
                        if (filtered.isEmpty) {
                          return const EmptyState(icon: Icons.receipt_long, title: 'No transactions found', subtitle: 'Tap + to add your first expense');
                        }
                        final grouped = _groupByDate(filtered);
                        return ListView(
                          padding: const EdgeInsets.only(bottom: 80),
                          children: grouped.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: TransactionSection(
                                dateLabel: entry.key,
                                expenses: entry.value,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
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
          ),
        ),
      ),
    );
  }

  Map<String, List<Expense>> _groupByDate(List<Expense> expenses) {
    final map = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = _formatSectionDate(e.date);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  String _formatSectionDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today, ${_monthLabel(date)} ${date.day}';
    if (diff.inDays == 1) return 'Yesterday, ${_monthLabel(date)} ${date.day}';
    return '${_monthLabel(date)} ${date.day}, ${date.year}';
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[date.month - 1];
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExpenseFiltersSheet(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryContainer.withAlpha(30)
              : AppColors.glassCardFill,
          borderRadius: BorderRadius.circular(999),
          border: isActive
              ? Border.all(color: AppColors.primary, width: 1)
              : Border.all(color: AppColors.glassCardBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
