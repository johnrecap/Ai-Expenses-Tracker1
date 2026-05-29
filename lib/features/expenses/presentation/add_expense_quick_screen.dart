import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'widgets/expense_form_card.dart';

class AddExpenseQuickScreen extends StatefulWidget {
  const AddExpenseQuickScreen({super.key});

  @override
  State<AddExpenseQuickScreen> createState() => _AddExpenseQuickScreenState();
}

class _AddExpenseQuickScreenState extends State<AddExpenseQuickScreen> {
  final _merchant = TextEditingController();
  final _amount = TextEditingController();
  Category? _selectedCategory;

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _onSave() {
    final amountText = _amount.text.trim();
    final merchant = _merchant.text.trim();
    if (amountText.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount and select a category')),
      );
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.userId : '';

    final cat = _selectedCategory!;
    final expense = Expense(
      expenseId: const Uuid().v4(),
      userId: userId,
      category: cat,
      categoryId: cat.categoryId,
      categoryName: cat.name,
      categoryIcon: cat.icon,
      categoryColor: cat.color,
      amount: amount,
      date: DateTime.now(),
      description: merchant.isNotEmpty ? merchant : cat.name,
      source: ExpenseSource.manual,
      paymentMethod: PaymentMethod.cash,
    );

    context.read<CreateExpenseBloc>().add(CreateExpense(expense));
  }

  String _displayCurrency(BuildContext context) {
    try {
      final s = context.read<SettingsCubit>().state;
      if (s is SettingsSuccess) return s.settings.baseCurrency;
    } catch (_) {}
    return 'KWD';
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryBloc>().state is CategoryLoaded
        ? (context.read<CategoryBloc>().state as CategoryLoaded).categories
        : <Category>[];

    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense saved')),
          );
          if (Navigator.canPop(context)) {
            context.pop();
          } else {
            context.go('/expenses');
          }
        } else if (state is CreateExpenseFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            context.pop();
                          } else {
                            context.go('/expenses');
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 20, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                      const Spacer(),
                      Text('Quick Add', style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: AppTextStyles.displayMobile.copyWith(color: AppColors.outline),
                        border: InputBorder.none,
                        suffix: Text(_displayCurrency(context), style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurfaceVariant)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: categories.map((cat) {
                      final selected = _selectedCategory?.categoryId == cat.categoryId;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = selected ? null : cat),
                        child: Chip(
                          label: Text(cat.name),
                          backgroundColor: selected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                          labelStyle: AppTextStyles.bodySmall.copyWith(
                            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                          ),
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ExpenseFormCard(
                    merchantController: _merchant,
                    amountController: _amount,
                    categories: categories.map((c) => c.name).toList(),
                    selectedCategoryId: _selectedCategory?.name,
                    onCategoryChanged: (v) => setState(() {
                      _selectedCategory = categories
                          .cast<Category?>()
                          .firstWhere((c) => c?.name.trim().toLowerCase() == v.trim().toLowerCase(), orElse: () => null);
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GradientButton(
                    label: 'Save Expense',
                    onPressed: _onSave,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
