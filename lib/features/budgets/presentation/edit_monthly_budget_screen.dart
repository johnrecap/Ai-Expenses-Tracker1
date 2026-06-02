import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/theme/app_gradients.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';

class EditMonthlyBudgetScreen extends StatefulWidget {
  const EditMonthlyBudgetScreen({super.key});

  static const amountFieldKey = Key('monthly-budget-amount-field');
  static const saveButtonKey = Key('monthly-budget-save-button');
  static const amountErrorKey = Key('monthly-budget-amount-error');

  @override
  State<EditMonthlyBudgetScreen> createState() => _EditMonthlyBudgetScreenState();
}

class _EditMonthlyBudgetScreenState extends State<EditMonthlyBudgetScreen> {
  final _budgetController = TextEditingController();
  double _totalBudget = 0;
  bool _justSaved = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    final state = context.read<BudgetBloc>().state;
    if (state is BudgetLoaded && state.budget != null) {
      _totalBudget = state.budget!.amount;
    }
    _budgetController.text = _formatBudgetInput(_totalBudget);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = _displayCurrency(context);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: 'Edit Budget',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _closeScreen(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Monthly Budget',
                        style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${_totalBudget.toInt()} $currency',
                        style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: AppRadii.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.payments_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Enter monthly limit',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              key: EditMonthlyBudgetScreen.amountFieldKey,
                              controller: _budgetController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textInputAction: TextInputAction.done,
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.onSurface,
                              ),
                              inputFormatters: [
                                TextInputFormatter.withFunction((oldValue, newValue) {
                                  final text = newValue.text;
                                  if (text.isEmpty) return newValue;
                                  final valid = RegExp(r'^\d*\.?\d{0,2}$').hasMatch(text);
                                  return valid ? newValue : oldValue;
                                }),
                              ],
                              decoration: InputDecoration(
                                hintText: '0.00',
                                suffixText: currency,
                                filled: true,
                                fillColor: AppColors.surfaceContainerLowest,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: AppRadii.lg,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: AppRadii.lg,
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 1,
                                  ),
                                  borderRadius: AppRadii.lg,
                                ),
                              ),
                              onChanged: (value) {
                                final parsed = _parseBudget(value);
                                setState(() {
                                  _amountError = null;
                                  if (parsed != null) _totalBudget = parsed;
                                });
                              },
                              onSubmitted: (_) => _saveBudget(currency),
                            ),
                            if (_amountError != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _amountError!,
                                key: EditMonthlyBudgetScreen.amountErrorKey,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: const BoxDecoration(
                          gradient: AppGradients.primaryAction,
                          borderRadius: AppRadii.pill,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: EditMonthlyBudgetScreen.saveButtonKey,
                            onTap: () => _saveBudget(currency),
                            borderRadius: AppRadii.pill,
                            child: const Center(
                              child: Text(
                                'Save Budget',
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
                      const SizedBox(height: AppSpacing.md),
                      BlocBuilder<BudgetBloc, BudgetState>(
                        builder: (context, state) {
                          if (state is BudgetSaving) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (state is BudgetSaved && !_justSaved) {
                            _justSaved = true;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              showAppToast(context, 'Budget saved');
                              context.go(AppRoutes.home);
                            });
                            return const SizedBox.shrink();
                          }
                          if (state is BudgetError) {
                            return Text(
                              state.message,
                              style: const TextStyle(color: AppColors.error),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
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

  String _displayCurrency(BuildContext context) {
    try {
      final state = context.read<SettingsCubit>().state;
      if (state is SettingsSuccess) return state.settings.baseCurrency;
    } catch (_) {}
    return UserSettings.defaultBaseCurrency;
  }

  void _closeScreen(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    context.go(AppRoutes.budgets);
  }

  void _saveBudget(String currency) {
    if (_justSaved) return;
    final amount = _parseBudget(_budgetController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = 'Enter a valid budget amount.';
        _totalBudget = 0;
      });
      return;
    }
    setState(() {
      _amountError = null;
      _totalBudget = amount;
    });
    final userId = _readUserId();
    final state = context.read<BudgetBloc>().state;
    if (state is BudgetLoaded && state.budget != null) {
      final updated = state.budget!.copyWith(
        amount: amount,
        updatedAt: DateTime.now(),
      );
      context.read<BudgetBloc>().add(BudgetSave(updated));
    } else {
      final now = DateTime.now();
      final budget = Budget(
        budgetId: '${now.year}-${now.month}',
        userId: userId,
        month: now.month,
        year: now.year,
        amount: amount,
        currency: currency,
        warningThresholdPercent: 80,
        createdAt: now,
        updatedAt: now,
      );
      context.read<BudgetBloc>().add(BudgetSave(budget));
    }
  }

  double? _parseBudget(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
      return null;
    }
    return parsed;
  }

  String _readUserId() {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.userId.trim().isNotEmpty) {
        return authState.user.userId;
      }
    } catch (_) {}
    try {
      return context.read<AuthRepository>().currentUser?.userId ?? '';
    } catch (_) {}
    return '';
  }

  String _formatBudgetInput(double value) {
    if (value == 0) return '';
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }
}
