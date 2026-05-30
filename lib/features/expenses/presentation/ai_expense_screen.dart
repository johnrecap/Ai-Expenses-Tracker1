import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import '../../ai/services/ai_api_service.dart';
import 'widgets/expense_form_card.dart';

/// شاشة إضافة مصروف بالذكاء الاصطناعي
class AiExpenseScreen extends StatefulWidget {
  const AiExpenseScreen({super.key});

  static const routeName = '/ai-expense';

  @override
  State<AiExpenseScreen> createState() => _AiExpenseScreenState();
}

class _AiExpenseScreenState extends State<AiExpenseScreen> {
  final _aiInput = TextEditingController();
  final _merchant = TextEditingController();
  final _amount = TextEditingController();
  final _categoryController = TextEditingController();
  final _dateController = TextEditingController();
  String? _selectedCategoryId;
  bool _isProcessing = false;

  final _aiApiService = AiApiService();

  @override
  void dispose() {
    _aiInput.dispose();
    _merchant.dispose();
    _amount.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _processAiInput() async {
    final input = _aiInput.text.trim();
    if (input.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _aiApiService.parseExpense(input);
      if (!mounted) return;

      if (result != null) {
        setState(() {
          _merchant.text = result.note ?? '';
          _amount.text = result.amount?.toString() ?? '';
          _dateController.text = result.date?.toIso8601String() ?? '';
        });

        final categoryState = context.read<CategoryBloc>().state;
        final categories = (categoryState is CategoryLoaded) ? categoryState.categories : <Category>[];
        final categoryName = result.category?.toLowerCase() ?? '';
        final matched = categories.where((Category c) =>
            c.name.toLowerCase().contains(categoryName) ||
            categoryName.contains(c.name.toLowerCase())).toList();

        if (matched.isNotEmpty) {
          setState(() {
            _selectedCategoryId = matched.first.categoryId;
            _categoryController.text = matched.first.name;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _save() {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.userId : '';
    final currency = _readCurrency(context);

    final categoryBloc = context.read<CategoryBloc>();
    final categoryState = categoryBloc.state;
    final categories = (categoryState is CategoryLoaded) ? categoryState.categories : <Category>[];
    final selectedCategory = categories.firstWhere(
      (Category c) => c.categoryId == _selectedCategoryId,
      orElse: () => categories.isNotEmpty ? categories.first : Category.empty,
    );

    final expense = Expense(
      expenseId: const Uuid().v4(),
      userId: userId,
      amount: amount,
      currency: currency,
      category: selectedCategory,
      date: _dateController.text.isNotEmpty
          ? DateTime.tryParse(_dateController.text) ?? DateTime.now()
          : DateTime.now(),
      description: _merchant.text.trim(),
      source: ExpenseSource.aiText,
    );

    context.read<CreateExpenseBloc>().add(CreateExpense(expense));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense saved successfully!')),
    );

    context.go('/');
  }

  String _readCurrency(BuildContext context) {
    try {
      final s = context.read<SettingsCubit>().state;
      if (s is SettingsSuccess) return s.settings.baseCurrency;
    } catch (_) {}
    return 'KWD';
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = context.watch<CategoryBloc>().state;
    final categories = categoryState is CategoryLoaded ? categoryState.categories : <Category>[];
    final categoryNames = categories.map((c) => c.name).toList();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                      onPressed: () => context.go('/'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'AI Expense',
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Input
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Describe your expense',
                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              controller: _aiInput,
                              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                              decoration: InputDecoration(
                                hintText: 'e.g. 200 KWD for groceries at Lulu',
                                hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                                filled: true,
                                fillColor: AppColors.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                onPressed: _isProcessing ? () {} : _processAiInput,
                                label: _isProcessing ? 'Processing...' : 'Parse with AI',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Manual Form
                      ExpenseFormCard(
                        merchantController: _merchant,
                        amountController: _amount,
                        categoryController: _categoryController,
                        dateController: _dateController,
                        categories: categoryNames,
                        selectedCategoryId: _selectedCategoryId,
                        onCategoryChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                            _categoryController.text = value;
                          });
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          onPressed: _save,
                          label: 'Save Expense',
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
