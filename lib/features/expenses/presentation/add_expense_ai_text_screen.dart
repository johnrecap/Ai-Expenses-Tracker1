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
import 'package:expenses_tracker/features/ai/ai_cubit/ai_assistant_cubit.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'widgets/segmented_mode_control.dart';
import 'widgets/ai_expense_parse_panel.dart';
import 'widgets/expense_form_card.dart';

class AddExpenseAiTextScreen extends StatefulWidget {
  const AddExpenseAiTextScreen({super.key});

  @override
  State<AddExpenseAiTextScreen> createState() => _AddExpenseAiTextScreenState();
}

class _AddExpenseAiTextScreenState extends State<AddExpenseAiTextScreen> {
  final _textController = TextEditingController();
  final _merchant = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _onParse() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter text to parse')));
      return;
    }
    context.read<AiAssistantCubit>().sendMessage(text);
  }

  void _onSave() {
    final cubit = context.read<AiAssistantCubit>();
    final parsed = cubit.state.parsedExpense;

    final amountText = _amount.text.trim();
    final merchant = _merchant.text.trim();
    var amount = double.tryParse(amountText);
    var description = merchant;

    if (parsed != null) {
      amount ??= parsed.amount;
      description = merchant.isNotEmpty ? merchant : parsed.description;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.userId : '';
    final cat = parsed?.category ?? Category.empty.copyWith(categoryId: 'other', name: 'Other', icon: 'category', color: 0xFF9E9E9E);

    final expense = Expense(
      expenseId: const Uuid().v4(),
      userId: userId,
      category: cat,
      categoryId: cat.categoryId,
      categoryName: cat.name,
      categoryIcon: cat.icon,
      categoryColor: cat.color,
      amount: amount,
      date: parsed?.date ?? DateTime.now(),
      description: description.isNotEmpty ? description : cat.name,
      source: ExpenseSource.aiText,
      paymentMethod: PaymentMethod.cash,
    );

    context.read<CreateExpenseBloc>().add(CreateExpense(expense));
  }

  @override
  Widget build(BuildContext context) {
    final aiState = context.watch<AiAssistantCubit>().state;

    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense saved')));
          context.pop();
        } else if (state is CreateExpenseFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 20, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                      const Spacer(),
                      Text('AI Text Mode', style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SegmentedModeControl(selectedIndex: 1, modes: const ['Quick', 'AI Text', 'Receipt'], onChanged: _navigateMode),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'e.g. Lunch 15 KWD at restaurant yesterday',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceContainerHigh,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: aiState.loading ? null : _onParse,
                      icon: aiState.loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
                      label: Text(aiState.loading ? 'Parsing...' : 'Parse with AI'),
                    ),
                  ),
                  if (aiState.parsedExpense != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: AppColors.primaryContainer.withAlpha(50), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${aiState.parsedExpense!.amount.toStringAsFixed(3)} KWD — ${aiState.parsedExpense!.description}',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
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

  void _navigateMode(int index) {
    switch (index) {
      case 0: context.go('/expenses/new/quick');
      case 2: context.go('/expenses/new/receipt');
      default:

    }
  }
}
