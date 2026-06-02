import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'widgets/expense_form_card.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late final TextEditingController _merchant;
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  Expense? _expense;

  @override
  void initState() {
    super.initState();
    _merchant = TextEditingController();
    _amount = TextEditingController();
    _notes = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<GetExpensesBloc>().state;
    if (state is GetExpensesSuccess) {
      final found = state.expenses.cast<Expense?>().firstWhere(
        (e) => e?.expenseId == widget.expenseId,
        orElse: () => null,
      );
      if (found != null && _expense == null) {
        setState(() {
          _expense = found;
          _merchant.text = found.description;
          _amount.text = found.amount.toString();
          _notes.text = '';
        });
      }
    }
  }

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (_expense == null) return;
    final amountText = _amount.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      showAppToast(context, 'Please enter a valid amount', isError: true);
      return;
    }
    final updated = _expense!.copyWith(
      amount: amount,
      description: _merchant.text.trim().isNotEmpty ? _merchant.text.trim() : _expense!.description,
      updatedAt: DateTime.now(),
    );
    context.read<CreateExpenseBloc>().add(UpdateExpense(updated));
  }

  @override
  Widget build(BuildContext context) {
    if (_expense == null) {
      return Scaffold(
        body: AppBackground(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.outline),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Expense not found',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      context.pop();
                    } else {
                      context.go('/expenses');
                    }
                  },
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          showAppToast(context, 'Expense updated');
          if (Navigator.canPop(context)) {
            context.pop();
          } else {
            context.go('/expenses');
          }
        } else if (state is CreateExpenseFailure) {
          showAppToast(context, state.message, isError: true);
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
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Edit Expense',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ExpenseFormCard(
                    merchantController: _merchant,
                    amountController: _amount,
                    notesController: _notes,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GradientButton(
                    label: 'Update Expense',
                    onPressed: _onUpdate,
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
