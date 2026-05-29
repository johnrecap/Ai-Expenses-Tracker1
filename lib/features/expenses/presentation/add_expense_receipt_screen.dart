import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/ai/services/ai_service.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'widgets/segmented_mode_control.dart';
import 'widgets/expense_form_card.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

class AddExpenseReceiptScreen extends StatefulWidget {
  const AddExpenseReceiptScreen({super.key});

  @override
  State<AddExpenseReceiptScreen> createState() => _AddExpenseReceiptScreenState();
}

class _AddExpenseReceiptScreenState extends State<AddExpenseReceiptScreen> {
  final _merchant = TextEditingController();
  final _amount = TextEditingController();
  String? _imagePath;
  Expense? _parsedExpense;
  bool _parsing = false;

  final _aiService = const MockAiService();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _onUpload() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;
      setState(() {
        _imagePath = file.path;
        _parsing = true;
      });

      final bytes = await file.readAsBytes();
      const maxBytes = 5 * 1024 * 1024; // 5MB
      var processedBytes = bytes;

      if (bytes.length > maxBytes) {
        // Compress image to max 2048px before base64 encoding
        final image = img.decodeImage(bytes);
        if (image != null) {
          final resized = img.copyResize(image, width: 2048); // maintains aspect ratio
          processedBytes = img.encodeJpg(resized, quality: 85);
        }
        // If decode fails, keep original bytes (image format not supported by the package)
      }

      final base64 = base64Encode(processedBytes);

      try {
        final result = await _aiService.extractReceipt(base64);
        final draft = _aiService.parseExpenseToDraft(result);
        setState(() {
          _parsedExpense = draft;
          if (draft != null) {
            _amount.text = draft.amount.toStringAsFixed(draft.currency.toUpperCase() == 'KWD' ? 3 : 2);
            _merchant.text = draft.description;
          }
        });
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI extraction failed. Enter details manually.')));
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not pick image')));
      }
    } finally {
      if (mounted) setState(() => _parsing = false);
    }
  }

  void _onSave() {
    final amountText = _amount.text.trim();
    final merchant = _merchant.text.trim();
    var amount = double.tryParse(amountText);

    if (_parsedExpense != null && amount == null) {
      amount = _parsedExpense!.amount;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.userId : '';
    final cat = _parsedExpense?.category ?? Category.empty.copyWith(categoryId: 'other', name: 'Other', icon: 'category', color: 0xFF9E9E9E);

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
      description: merchant.isNotEmpty ? merchant : 'Receipt expense',
      source: ExpenseSource.receipt,
      currency: _parsedExpense?.currency ?? 'EGP',
      paymentMethod: _parsedExpense?.paymentMethod ?? PaymentMethod.cash,
    );

    context.read<CreateExpenseBloc>().add(CreateExpense(expense));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense saved')));
          if (Navigator.canPop(context)) {
            context.pop();
          } else {
            context.go('/expenses');
          }
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
                      Text('Receipt Mode', style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SegmentedModeControl(selectedIndex: 2, modes: const ['Quick', 'AI Text', 'Receipt'], onChanged: _navigateMode),
                  const SizedBox(height: AppSpacing.lg),
                  GestureDetector(
                    onTap: _onUpload,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassCardBorder),
                      ),
                      child: _imagePath != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(_imagePath!), fit: BoxFit.cover, errorBuilder: (_, _, _) => _uploadPlaceholder()))
                          : _parsing
                              ? const Center(child: CircularProgressIndicator())
                              : _uploadPlaceholder(),
                    ),
                  ),
                  if (_parsedExpense != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: AppColors.primaryContainer.withAlpha(50), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.receipt_long, color: AppColors.primary, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text('Receipt parsed: ${_parsedExpense!.amount.toStringAsFixed(_parsedExpense!.currency.toUpperCase() == 'KWD' ? 3 : 2)} ${_parsedExpense!.currency} ${_parsedExpense!.description}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  ExpenseFormCard(merchantController: _merchant, amountController: _amount),
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

  Widget _uploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 40, color: AppColors.onSurfaceVariant.withAlpha(100)),
        const SizedBox(height: AppSpacing.sm),
        Text('Tap to upload receipt', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  void _navigateMode(int index) {
    switch (index) {
      case 0: context.go('/expenses/new/quick');
      case 1: context.go('/expenses/new/text');
      default:
        break;
    }
  }
}
