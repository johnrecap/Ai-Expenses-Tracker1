import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/core/widgets/progress_bar.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CategoryBudgetsListScreen extends StatelessWidget {
  const CategoryBudgetsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final reportState = _reportStateOf(context);
    final periodStart = reportState?.selectedPeriod?.startDate ?? now;
    final month = periodStart.month;
    final year = periodStart.year;
    final categoryBudgetRepository = context.read<CategoryBudgetRepository>();
    final categories = _activeCategories(_categoryStateOf(context));
    final categorySummaries = reportState?.categorySummaries ?? const [];
    final currency = _displayCurrency(context);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: 'Category Budgets',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                trailing: IconButton(
                  tooltip: 'Add category budget',
                  icon: const Icon(Icons.add, color: AppColors.onSurface),
                  onPressed: () => _showCategoryBudgetEditor(
                    context,
                    repository: categoryBudgetRepository,
                    month: month,
                    year: year,
                    currency: currency,
                    categories: categories,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<CategoryBudget>>(
                  stream: _watchCategoryBudgets(
                    categoryBudgetRepository,
                    month: month,
                    year: year,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const EmptyState(
                        icon: Icons.error_outline,
                        title: 'Could not load category budgets',
                        subtitle: 'Try again after checking your connection.',
                      );
                    }

                    final budgets = [...snapshot.data ?? const <CategoryBudget>[]]
                      ..sort((a, b) {
                        final aName = _categoryNameFor(
                          categoryId: a.categoryId,
                          categories: categories,
                          summaries: categorySummaries,
                        );
                        final bName = _categoryNameFor(
                          categoryId: b.categoryId,
                          categories: categories,
                          summaries: categorySummaries,
                        );
                        return aName.compareTo(bName);
                      });

                    if (budgets.isEmpty) {
                      return _EmptyCategoryBudgets(
                        canCreate: categories.isNotEmpty,
                        onCreate: () => _showCategoryBudgetEditor(
                          context,
                          repository: categoryBudgetRepository,
                          month: month,
                          year: year,
                          currency: currency,
                          categories: categories,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.containerPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Allocations',
                            style: AppTextStyles.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (reportState?.loading ?? false) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Spending is updating...',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (reportState?.error != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Spending could not be refreshed.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          for (final budget in budgets)
                            _BudgetRow(
                              label: _categoryNameFor(
                                categoryId: budget.categoryId,
                                categories: categories,
                                summaries: categorySummaries,
                              ),
                              allocated: budget.amount,
                              spent: _spentForCategory(
                                budget.categoryId,
                                categorySummaries,
                              ),
                              currency: currency,
                              color: _categoryColorFor(
                                budget.categoryId,
                                categories,
                              ),
                              onEdit: () => _showCategoryBudgetEditor(
                                context,
                                repository: categoryBudgetRepository,
                                month: month,
                                year: year,
                                currency: currency,
                                categories: categories,
                                existingBudget: budget,
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

Stream<List<CategoryBudget>> _watchCategoryBudgets(
  CategoryBudgetRepository repository, {
  required int month,
  required int year,
}) async* {
  yield await repository.getCategoryBudgets(month: month, year: year);
  yield* repository.watchCategoryBudgets(month: month, year: year);
}

ReportState? _reportStateOf(BuildContext context) {
  try {
    return context.watch<ReportCubit>().state;
  } catch (_) {
    return null;
  }
}

CategoryState? _categoryStateOf(BuildContext context) {
  try {
    return context.watch<CategoryBloc>().state;
  } catch (_) {
    return null;
  }
}

List<Category> _activeCategories(CategoryState? state) {
  if (state is! CategoryLoaded) return const [];
  return state.categories.where((category) => !category.isArchived).toList();
}

String _displayCurrency(BuildContext context) {
  try {
    final budgetState = context.watch<BudgetBloc>().state;
    if (budgetState is BudgetLoaded && budgetState.budget != null) {
      return budgetState.budget!.currency;
    }
  } catch (_) {}
  try {
    final settingsState = context.watch<SettingsCubit>().state;
    if (settingsState is SettingsSuccess) {
      return settingsState.settings.baseCurrency;
    }
  } catch (_) {}
  return 'EGP';
}

String _currentUserId(BuildContext context, CategoryBudget? existingBudget) {
  if (existingBudget?.userId.trim().isNotEmpty ?? false) {
    return existingBudget!.userId;
  }
  try {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return authState.user.userId;
  } catch (_) {}
  return '';
}

String _categoryNameFor({
  required String categoryId,
  required List<Category> categories,
  required List<ReportCategorySummary> summaries,
}) {
  for (final category in categories) {
    if (_sameCategory(category.categoryId, categoryId)) return category.name;
  }
  for (final summary in summaries) {
    if (_sameCategory(summary.categoryId, categoryId)) {
      return summary.categoryName;
    }
  }
  return categoryId.trim().isEmpty ? 'Missing category' : categoryId;
}

double _spentForCategory(
  String categoryId,
  List<ReportCategorySummary> summaries,
) {
  for (final summary in summaries) {
    if (_sameCategory(summary.categoryId, categoryId)) return summary.amount;
  }
  return 0;
}

Color _categoryColorFor(String categoryId, List<Category> categories) {
  for (final category in categories) {
    if (_sameCategory(category.categoryId, categoryId)) {
      return Color(category.color);
    }
  }
  return AppColors.primary;
}

bool _sameCategory(String left, String right) {
  return left.trim().toLowerCase() == right.trim().toLowerCase();
}

String _categoryBudgetId({
  required String categoryId,
  required int month,
  required int year,
}) {
  return '$year-${month.toString().padLeft(2, '0')}-$categoryId';
}

void _showCategoryBudgetEditor(
  BuildContext context, {
  required CategoryBudgetRepository repository,
  required int month,
  required int year,
  required String currency,
  required List<Category> categories,
  CategoryBudget? existingBudget,
}) {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController(
    text: existingBudget == null ? '' : existingBudget.amount.toStringAsFixed(0),
  );
  var selectedCategoryId =
      existingBudget?.categoryId ?? (categories.isEmpty ? null : categories.first.categoryId);
  var saving = false;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: GlassBottomSheet(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final canSave = categories.isNotEmpty && !saving;
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existingBudget == null
                          ? 'Add category budget'
                          : 'Edit category budget',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (categories.isEmpty)
                      Text(
                        'Create a category first, then add its monthly budget.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      )
                    else ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          filled: true,
                        ),
                        items: [
                          for (final category in categories)
                            DropdownMenuItem(
                              value: category.categoryId,
                              child: Text(category.name),
                            ),
                        ],
                        onChanged: existingBudget == null
                            ? (value) => setSheetState(
                                  () => selectedCategoryId = value,
                                )
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Monthly amount',
                          suffixText: currency,
                          filled: true,
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount.';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    GradientButton(
                      label: saving ? 'Saving...' : 'Save',
                      onPressed: canSave
                          ? () async {
                              if (!(formKey.currentState?.validate() ?? false)) {
                                return;
                              }
                              final categoryId = selectedCategoryId;
                              if (categoryId == null) return;
                              setSheetState(() => saving = true);
                              final now = DateTime.now();
                              final budget = CategoryBudget(
                                budgetId: existingBudget?.budgetId ??
                                    _categoryBudgetId(
                                      categoryId: categoryId,
                                      month: month,
                                      year: year,
                                    ),
                                userId: _currentUserId(context, existingBudget),
                                categoryId: categoryId,
                                amount: double.parse(
                                  amountController.text.trim(),
                                ),
                                month: month,
                                year: year,
                                createdAt: existingBudget?.createdAt ?? now,
                                updatedAt: now,
                              );
                              try {
                                await repository.saveCategoryBudget(budget);
                                if (context.mounted) Navigator.of(context).pop();
                              } catch (_) {
                                if (!context.mounted) return;
                                setSheetState(() => saving = false);
                                showAppToast(
                                  context,
                                  'Failed to save category budget.',
                                  isError: true,
                                );
                              }
                            }
                          : () {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  ).whenComplete(amountController.dispose);
}

class _EmptyCategoryBudgets extends StatelessWidget {
  const _EmptyCategoryBudgets({
    required this.canCreate,
    required this.onCreate,
  });

  final bool canCreate;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: 'No category budgets yet',
          subtitle: canCreate
              ? 'Add monthly limits for the categories you already use.'
              : 'Create categories first, then add monthly limits here.',
        ),
        if (canCreate)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.containerPadding,
            ),
            child: GradientButton(
              label: 'Add category budget',
              prefixIcon: const Icon(Icons.add, color: AppColors.onPrimary),
              onPressed: onCreate,
            ),
          ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.label,
    required this.allocated,
    required this.spent,
    required this.currency,
    required this.color,
    required this.onEdit,
  });

  final String label;
  final double allocated;
  final double spent;
  final String currency;
  final Color color;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final progress = allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
    final progressColor = spent > allocated ? AppColors.error : color;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
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
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${spent.toStringAsFixed(2)} / ${allocated.toStringAsFixed(2)} $currency',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              IconButton(
                tooltip: 'Edit category budget',
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ProgressBar(
            progress: progress,
            height: 6,
            progressColor: progressColor,
          ),
        ],
      ),
    );
  }
}
