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
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'widgets/segmented_mode_control.dart';
import 'widgets/ai_expense_parse_panel.dart';
import 'widgets/expense_form_card.dart';

class AddExpenseAiTextScreen extends StatefulWidget {
  const AddExpenseAiTextScreen({super.key});

  @override
  State<AddExpenseAiTextScreen> createState() => _AddExpenseAiTextScreenState();
}

class _AddExpenseAiTextScreenState extends State<AddExpenseAiTextScreen> {
  final _merchant = TextEditingController();
  final _amount = TextEditingController();
  Category? _selectedCategory;
  Expense? _parsedExpense;

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _onParseResult(Expense? expense) {
    setState(() {
      _parsedExpense = expense;
      if (expense != null) {
        _amount.text = expense.amount.toStringAsFixed(expense.currency.toUpperCase() == 'KWD' ? 3 : 2);
        _merchant.text = expense.description;
        _selectedCategory = expense.category;
      }
    });
  }

  void _onSave() {
    final amountText = _amount.text.trim();
    final merchant = _merchant.text.trim();

    var amount = double.tryParse(amountText);
    if (_parsedExpense != null && amount == null) {
      amount = _parsedExpense!.amount;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.userId : '';
    final cat = _selectedCategory ?? _parsedExpense?.category ??
        Category.empty.copyWith(categoryId: 'other', name: 'Other', icon: 'category', color: 0xFF9E9E9E);

    final expense = Expense(
      expenseId: const Uuid().v4(),
      userId: userId,
      category: cat,
      categoryId: cat.categoryId,
      categoryName: cat.name,
      categoryIcon: cat.icon,
      categoryColor: cat.color,
      amount: amount,
      date: _parsedExpense?.date ?? DateTime.now(),
      description: merchant.isNotEmpty ? merchant : 'AI Text expense',
      source: ExpenseSource.aiText,
      currency: _parsedExpense?.currency ?? 'EGP',
      paymentMethod: _parsedExpense?.paymentMethod ?? PaymentMethod.cash,
    );

    context.read<CreateExpenseBloc>().add(CreateExpense(expense));
  }

  void _navigateMode(int index) {
    switch (index) {
      case 0: context.go('/expenses/new/quick');
      case 2: context.go('/expenses/new/receipt');
      default:
        break;
    }
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
                          decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 20, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                      const Spacer(),
                      Text('AI Text', style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SegmentedModeControl(
                    selectedIndex: 1,
                    modes: const ['Quick', 'AI Text', 'Receipt'],
                    onChanged: _navigateMode,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AiExpenseParsePanel(
                    onParsed: _onParseResult,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Category chips below the result
                  if (categories.isNotEmpty) ...[
                    Text('Category', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.sm),
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
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  ExpenseFormCard(
                    merchantController: _merchant,
                    amountController: _amount,
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
