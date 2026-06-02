import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/core/widgets/payment_method_selector.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:expenses_tracker/monetization/widgets/entry_quota_status.dart';
import 'package:expenses_tracker/monetization/widgets/rewarded_quota_sheet.dart';
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
  WalletAccount? _selectedWallet;
  PaymentMethod? _selectedPaymentMethod;
  bool _quotaChecking = false;
  String? _pendingQuotaOperationId;
  String? _pendingQuotaExpenseId;

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_quotaChecking) {
      return;
    }

    final amountText = _amount.text.trim();
    final merchant = _merchant.text.trim();
    if (amountText.isEmpty || _selectedCategory == null) {
      showAppToast(context, 'Please enter amount and select a category', isError: true);
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      showAppToast(context, 'Please enter a valid amount', isError: true);
      return;
    }

    final quotaCubit = _maybeRead<EntryQuotaCubit>();
    if (quotaCubit != null) {
      setState(() => _quotaChecking = true);
      final decision = await quotaCubit.canSave(EntryQuotaKind.normal);
      if (!mounted) {
        return;
      }
      setState(() => _quotaChecking = false);

      if (!decision.allowed) {
        if (decision.type == EntryQuotaDecisionType.blocked) {
          await _showNormalRewardSheet();
        } else {
          showAppToast(context, decision.message, isError: true);
        }
        return;
      }
    }

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.userId : '';

    final cat = _selectedCategory!;
    final wallet = _selectedWallet;
    final currency = _displayCurrency(context, selectedWallet: wallet);
    final paymentMethod = _effectivePaymentMethod(context, selectedWallet: wallet);
    final now = DateTime.now();
    final expense = Expense(
      expenseId: const Uuid().v4(),
      userId: userId,
      category: cat,
      categoryId: cat.categoryId,
      categoryName: cat.name,
      categoryIcon: cat.icon,
      categoryColor: cat.color,
      amount: amount,
      date: now,
      description: merchant.isNotEmpty ? merchant : cat.name,
      source: ExpenseSource.manual,
      paymentMethod: paymentMethod,
      currency: currency,
      createdAt: now,
      updatedAt: now,
      walletAccountId: wallet?.walletId,
      walletAccountName: wallet?.name,
    );

    _pendingQuotaOperationId = expense.expenseId;
    _pendingQuotaExpenseId = expense.expenseId;
    context.read<CreateExpenseBloc>().add(CreateExpense(expense));
  }

  Future<void> _onCreateExpenseSuccess() async {
    final quotaCubit = _maybeRead<EntryQuotaCubit>();
    final operationId = _pendingQuotaOperationId;
    final expenseId = _pendingQuotaExpenseId;

    if (quotaCubit != null && operationId != null) {
      final result = await quotaCubit.consumeAfterSuccessfulSave(
        kind: EntryQuotaKind.normal,
        operationId: operationId,
        expenseId: expenseId,
      );
      if (!mounted) {
        return;
      }
      if (result.status == EntryQuotaMutationStatus.unavailable) {
        showAppToast(context, result.message, isError: true);
        return;
      }
    }

    _pendingQuotaOperationId = null;
    _pendingQuotaExpenseId = null;
    showAppToast(context, 'Expense saved');
    if (Navigator.canPop(context)) {
      context.pop();
    } else {
      context.go('/expenses');
    }
  }

  Future<void> _showNormalRewardSheet() async {
    final monetizationCubit = _maybeRead<MonetizationCubit>();
    final quotaCubit = _maybeRead<EntryQuotaCubit>();
    final adsAvailable =
        monetizationCubit
            ?.state
            .adPolicyFor(AdPlacement.rewardedNormalEntries)
            .allowed ??
        false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        var rewardLoading = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return RewardedQuotaSheet(
              placement: EntryQuotaRewardPlacement.rewardedNormalEntries,
              adsAvailable: adsAvailable,
              loading: rewardLoading,
              onCancel: () => Navigator.of(sheetContext).pop(),
              onWatchAd: adsAvailable && monetizationCubit != null && quotaCubit != null
                  ? () async {
                      setSheetState(() => rewardLoading = true);
                      final adResult = await monetizationCubit.showRewardedAd(
                        placement: AdPlacement.rewardedNormalEntries,
                      );
                      final grant = await quotaCubit.grantRewardFromAdResult(
                        placement: EntryQuotaRewardPlacement.rewardedNormalEntries,
                        adResult: adResult,
                      );
                      if (!mounted || !sheetContext.mounted) {
                        return;
                      }
                      setSheetState(() => rewardLoading = false);
                      if (grant.status == EntryQuotaMutationStatus.granted) {
                        Navigator.of(sheetContext).pop();
                        showAppToast(context, 'Extra entries added');
                      } else {
                        showAppToast(context, grant.message, isError: true);
                      }
                    }
                  : null,
            );
          },
        );
      },
    );
  }

  String _displayCurrency(BuildContext context, {WalletAccount? selectedWallet}) {
    final walletCurrency = selectedWallet?.currency.trim().toUpperCase();
    if (walletCurrency != null && walletCurrency.isNotEmpty) {
      return walletCurrency;
    }
    try {
      final s = context.read<SettingsCubit>().state;
      if (s is SettingsSuccess) return s.settings.baseCurrency;
    } catch (_) {}
    return UserSettings.defaultBaseCurrency;
  }

  PaymentMethod _defaultPaymentMethod(BuildContext context) {
    try {
      final s = context.read<SettingsCubit>().state;
      if (s is SettingsSuccess) return s.settings.defaultPaymentMethod;
      if (s is SettingsSaving) return s.tentative.defaultPaymentMethod;
    } catch (_) {}
    return PaymentMethod.cash;
  }

  PaymentMethod _effectivePaymentMethod(
    BuildContext context, {
    WalletAccount? selectedWallet,
  }) {
    if (selectedWallet != null) return PaymentMethod.wallet;
    return _selectedPaymentMethod ?? _defaultPaymentMethod(context);
  }

  WalletState? _watchWalletState(BuildContext context) {
    try {
      return context.watch<WalletBloc>().state;
    } catch (_) {
      return null;
    }
  }

  T? _maybeRead<T extends Object>() {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  Widget _buildQuotaStatus() {
    if (_maybeRead<EntryQuotaCubit>() == null) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<EntryQuotaCubit, EntryQuotaState>(
      builder: (context, state) {
        if (state.snapshot == null && !state.isPremium) {
          return const SizedBox.shrink();
        }
        return EntryQuotaStatus(
          kind: EntryQuotaKind.normal,
          remaining: state.normalRemaining,
          isPremium: state.isPremium,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryBloc>().state is CategoryLoaded
        ? (context.read<CategoryBloc>().state as CategoryLoaded).categories
        : <Category>[];
    final walletState = _watchWalletState(context);
    final wallets = walletState?.wallets ?? const <WalletAccount>[];
    if (_selectedWallet != null &&
        !wallets.any((wallet) => wallet.walletId == _selectedWallet!.walletId)) {
      _selectedWallet = null;
    }
    final isSaving = context.watch<CreateExpenseBloc>().state is CreateExpenseLoading;
    final effectivePaymentMethod = _effectivePaymentMethod(
      context,
      selectedWallet: _selectedWallet,
    );

    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          unawaited(_onCreateExpenseSuccess());
        } else if (state is CreateExpenseFailure) {
          _pendingQuotaOperationId = null;
          _pendingQuotaExpenseId = null;
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
                            Icons.close,
                            size: 20,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Quick Add',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                      ),
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
                        suffix: Text(
                          _displayCurrency(context, selectedWallet: _selectedWallet),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuotaStatus(),
                  const SizedBox(height: AppSpacing.lg),
                  if (categories.isEmpty)
                    Text(
                      'No categories available. Create a category before saving.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: categories.map((cat) {
                        final selected = _selectedCategory?.categoryId == cat.categoryId;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = selected ? null : cat),
                          child: Chip(
                            label: Text(cat.name),
                            backgroundColor: selected
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerHigh,
                            labelStyle: AppTextStyles.bodySmall.copyWith(
                              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                  if (walletState?.status == WalletStatus.error) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Wallets are unavailable. You can still save the expense without a wallet.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ] else if (wallets.isEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Wallet is optional. This expense will be saved without a wallet.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  PaymentMethodSelector(
                    title: 'Payment Method',
                    selectedMethod: effectivePaymentMethod,
                    onChanged: (method) => setState(() {
                      _selectedPaymentMethod = method;
                      if (method != PaymentMethod.wallet) {
                        _selectedWallet = null;
                      }
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ExpenseFormCard(
                    merchantController: _merchant,
                    amountController: _amount,
                    categories: categories.map((c) => c.name).toList(),
                    selectedCategoryId: _selectedCategory?.name,
                    wallets: wallets.map((w) => w.name).toList(),
                    selectedWalletId: _selectedWallet?.name,
                    onCategoryChanged: (v) => setState(() {
                      _selectedCategory = categories.cast<Category?>().firstWhere(
                        (c) => c?.name.trim().toLowerCase() == v.trim().toLowerCase(),
                        orElse: () => null,
                      );
                    }),
                    onWalletChanged: (v) => setState(() {
                      _selectedWallet = wallets.cast<WalletAccount?>().firstWhere(
                        (w) => w?.name.trim().toLowerCase() == v.trim().toLowerCase(),
                        orElse: () => null,
                      );
                      if (_selectedWallet != null) {
                        _selectedPaymentMethod = PaymentMethod.wallet;
                      }
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GradientButton(
                    label: isSaving || _quotaChecking ? 'Saving...' : 'Save Expense',
                    onPressed: isSaving || _quotaChecking ? null : () => unawaited(_onSave()),
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
