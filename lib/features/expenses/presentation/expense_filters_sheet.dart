import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_gradients.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';
import 'package:expenses_tracker/features/expenses/expense_filter_cubit/expense_filter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseFiltersSheet extends StatefulWidget {
  const ExpenseFiltersSheet({super.key});

  @override
  State<ExpenseFiltersSheet> createState() => _ExpenseFiltersSheetState();
}

class _ExpenseFiltersSheetState extends State<ExpenseFiltersSheet> {
  late final TextEditingController _searchController;
  late final TextEditingController _minAmountController;
  late final TextEditingController _maxAmountController;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _categoryId;
  String? _walletAccountId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _minAmountController = TextEditingController();
    _maxAmountController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final filterState = context.read<ExpenseFilterCubit>().state;
    final filter = filterState.filter;
    _searchController.text = filter.searchQuery ?? '';
    _minAmountController.text = _formatAmount(filterState.minAmount);
    _maxAmountController.text = _formatAmount(filterState.maxAmount);
    _startDate = filter.startDate;
    _endDate = filter.endDate;
    _categoryId = filter.categoryId;
    _walletAccountId = filterState.walletAccountId;
    _initialized = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseFilterCubit, ExpenseFilterState>(
      builder: (context, filterState) {
        final categories = _categoryOptions(filterState.allExpenses);
        final wallets = _walletOptions(filterState.allExpenses);

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: GlassBottomSheet(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.containerPadding,
                    AppSpacing.sm,
                    AppSpacing.containerPadding,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Filters',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.surfaceContainerHigh),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionLabel(label: 'Search'),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _searchController,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search expenses...',
                            hintStyle: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.outline,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionLabel(label: 'Date'),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _OptionChip(
                              label: 'All dates',
                              isActive: _startDate == null && _endDate == null,
                              onTap: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                              },
                            ),
                            _OptionChip(
                              label: 'This month',
                              isActive: _isCurrentMonth(_startDate, _endDate),
                              onTap: () => setState(_selectCurrentMonth),
                            ),
                            _OptionChip(
                              label: 'Last month',
                              isActive: _isLastMonth(_startDate, _endDate),
                              onTap: () => setState(_selectLastMonth),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionLabel(label: 'Categories'),
                        const SizedBox(height: AppSpacing.sm),
                        if (categories.isEmpty)
                          const _UnavailableNote(
                            text: 'No category data is available for these expenses.',
                          )
                        else
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _OptionChip(
                                label: 'All categories',
                                isActive: _categoryId == null,
                                onTap: () => setState(() => _categoryId = null),
                              ),
                              ...categories.map(
                                (category) => _OptionChip(
                                  label: category.name,
                                  icon: Icons.category,
                                  isActive: _categoryId == category.id,
                                  onTap: () => setState(() {
                                    _categoryId = category.id;
                                  }),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionLabel(label: 'Amount'),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: _AmountField(
                                key: const Key('expenseFilterMinAmount'),
                                controller: _minAmountController,
                                label: 'Min amount',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _AmountField(
                                key: const Key('expenseFilterMaxAmount'),
                                controller: _maxAmountController,
                                label: 'Max amount',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionLabel(label: 'Wallet'),
                        const SizedBox(height: AppSpacing.sm),
                        if (wallets.isEmpty)
                          const _UnavailableNote(
                            text: 'Wallet data is unavailable for these expenses.',
                          )
                        else
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _OptionChip(
                                label: 'All wallets',
                                isActive: _walletAccountId == null,
                                onTap: () => setState(() => _walletAccountId = null),
                              ),
                              ...wallets.map(
                                (wallet) => _OptionChip(
                                  label: wallet.name,
                                  icon: Icons.account_balance_wallet,
                                  isActive: _walletAccountId == wallet.id,
                                  onTap: () => setState(() {
                                    _walletAccountId = wallet.id;
                                  }),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.containerPadding,
                    AppSpacing.md,
                    AppSpacing.containerPadding,
                    AppSpacing.xl,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.glassSheetFill,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.surfaceContainerHigh,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetFilters,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.primaryContainer.withAlpha(100),
                            ),
                            padding: const EdgeInsetsDirectional.symmetric(
                              vertical: 16,
                            ),
                            shape: const StadiumBorder(),
                            foregroundColor: AppColors.primary,
                            minimumSize: const Size(0, 48),
                          ),
                          child: Text(
                            'Reset',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppGradients.primaryAction,
                            borderRadius: AppRadii.pill,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _applyFilters,
                              borderRadius: AppRadii.pill,
                              child: const Center(
                                child: Text(
                                  'Apply Filters',
                                  style: TextStyle(
                                    color: AppColors.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyFilters() {
    final minAmount = _parseAmount(_minAmountController.text);
    final maxAmount = _parseAmount(_maxAmountController.text);
    if (minAmount == null && _minAmountController.text.trim().isNotEmpty) {
      _showAmountError();
      return;
    }
    if (maxAmount == null && _maxAmountController.text.trim().isNotEmpty) {
      _showAmountError();
      return;
    }
    if (minAmount != null && maxAmount != null && minAmount > maxAmount) {
      _showAmountError();
      return;
    }

    context.read<ExpenseFilterCubit>().applyFilters(
      searchQuery: _searchController.text,
      clearSearch: _searchController.text.trim().isEmpty,
      categoryId: _categoryId,
      clearCategory: _categoryId == null,
      startDate: _startDate,
      endDate: _endDate,
      clearDateRange: _startDate == null && _endDate == null,
      minAmount: minAmount,
      maxAmount: maxAmount,
      replaceAmountRange: true,
      walletAccountId: _walletAccountId,
      clearWallet: _walletAccountId == null,
    );
    Navigator.of(context).pop();
  }

  void _resetFilters() {
    context.read<ExpenseFilterCubit>().reset();
    setState(() {
      _searchController.clear();
      _minAmountController.clear();
      _maxAmountController.clear();
      _startDate = null;
      _endDate = null;
      _categoryId = null;
      _walletAccountId = null;
    });
  }

  void _showAmountError() {
    showAppToast(context, 'Enter a valid amount range.', isError: true);
  }

  void _selectCurrentMonth() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month);
    _endDate = DateTime(now.year, now.month + 1).subtract(
      const Duration(microseconds: 1),
    );
  }

  void _selectLastMonth() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month - 1);
    _endDate = DateTime(now.year, now.month).subtract(
      const Duration(microseconds: 1),
    );
  }

  bool _isCurrentMonth(DateTime? start, DateTime? end) {
    final now = DateTime.now();
    final expectedStart = DateTime(now.year, now.month);
    final expectedEnd = DateTime(now.year, now.month + 1).subtract(
      const Duration(microseconds: 1),
    );
    return start == expectedStart && end == expectedEnd;
  }

  bool _isLastMonth(DateTime? start, DateTime? end) {
    final now = DateTime.now();
    final expectedStart = DateTime(now.year, now.month - 1);
    final expectedEnd = DateTime(now.year, now.month).subtract(
      const Duration(microseconds: 1),
    );
    return start == expectedStart && end == expectedEnd;
  }

  List<_FilterOption> _categoryOptions(List<Expense> expenses) {
    final options = <String, _FilterOption>{};
    for (final expense in expenses) {
      final id = expense.categoryId.trim();
      final name = expense.categoryName.trim();
      if (id.isEmpty || name.isEmpty) continue;
      options.putIfAbsent(id, () => _FilterOption(id, name));
    }
    return options.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<_FilterOption> _walletOptions(List<Expense> expenses) {
    final options = <String, _FilterOption>{};
    for (final expense in expenses) {
      final id = expense.walletAccountId?.trim();
      final name = expense.walletAccountName?.trim();
      if (id == null || id.isEmpty || name == null || name.isEmpty) continue;
      options.putIfAbsent(id, () => _FilterOption(id, name));
    }
    return options.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  double? _parseAmount(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  String _formatAmount(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }
}

class _FilterOption {
  const _FilterOption(this.id, this.name);

  final String id;
  final String name;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelCaps.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
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
          gradient: isActive ? AppGradients.primaryAction : null,
          color: isActive ? null : AppColors.glassCardFill,
          borderRadius: AppRadii.pill,
          border: isActive ? null : Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

class _UnavailableNote extends StatelessWidget {
  const _UnavailableNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
