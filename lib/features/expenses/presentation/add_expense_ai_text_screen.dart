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
import 'package:expenses_tracker/features/ai/data/ai_gateway_client.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/expenses/domain/ai_expense_draft_mapper.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:expenses_tracker/monetization/widgets/entry_quota_status.dart';
import 'package:expenses_tracker/monetization/widgets/rewarded_quota_sheet.dart';
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
  WalletAccount? _selectedWallet;
  PaymentMethod? _selectedPaymentMethod;
  AiExpenseDraftSelection? _draft;
  String? _pendingAiQuotaOperationId;
  bool _requestedQuotaLoad = false;

  @override
  void initState() {
    super.initState();
    _merchant.addListener(_manualFieldsChanged);
    _amount.addListener(_manualFieldsChanged);
  }

  @override
  void dispose() {
    _merchant.removeListener(_manualFieldsChanged);
    _amount.removeListener(_manualFieldsChanged);
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _manualFieldsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedQuotaLoad) return;
    _requestedQuotaLoad = true;
    unawaited(_maybeReadEntryQuotaCubit(context)?.load() ?? Future<void>.value());
  }

  void _applyDraft(
    AiExpenseDraftSelection draft, {
    required List<Category> categories,
    required List<WalletAccount> wallets,
  }) {
    setState(() {
      _draft = draft;
      final amount = draft.amount;
      final currency = draft.currency ?? UserSettings.defaultBaseCurrency;
      if (amount != null && amount > 0) {
        _amount.text = amount.toStringAsFixed(currency.toUpperCase() == 'KWD' ? 3 : 2);
      }
      if (draft.description?.trim().isNotEmpty == true) {
        _merchant.text = draft.description!;
      }
      _selectedCategory = _findCategory(
        categories,
        categoryId: draft.categoryId,
        categoryName: draft.categoryName,
      );
      _selectedWallet = _findWallet(
        wallets,
        walletId: draft.walletAccountId,
        walletName: draft.walletAccountName,
      );
      _selectedPaymentMethod = _selectedWallet != null
          ? PaymentMethod.wallet
          : draft.paymentMethod ?? _defaultPaymentMethod(context);
    });
  }

  Future<void> _onSave(
    BuildContext context, {
    required List<Category> categories,
    required List<WalletAccount> wallets,
  }) async {
    FocusScope.of(context).unfocus();

    final amountText = _amount.text.trim();
    final merchant = _merchant.text.trim();
    final amount = double.tryParse(amountText) ?? _draft?.amount;

    if (amount == null || amount <= 0) {
      showAppToast(context, 'Please enter a valid amount', isError: true);
      return;
    }
    final wallet = _selectedWallet;
    final category =
        _selectedCategory ??
        _findCategory(
          categories,
          categoryId: _draft?.categoryId,
          categoryName: _draft?.categoryName,
        ) ??
        (categories.length == 1 ? categories.first : null);

    if (category == null) {
      showAppToast(context, 'Please select a category', isError: true);
      return;
    }

    final quotaCubit = _maybeReadEntryQuotaCubit(context);
    if (quotaCubit != null) {
      final decision = await quotaCubit.canSave(EntryQuotaKind.ai);
      if (!mounted || !context.mounted) return;
      if (!decision.allowed) {
        if (decision.type == EntryQuotaDecisionType.blocked) {
          _showAiRewardSheet(context);
        } else {
          showAppToast(context, decision.message, isError: true);
        }
        return;
      }
    }

    if (!mounted || !context.mounted) return;
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.userId : '';
    final walletCurrency = wallet?.currency.trim().toUpperCase();
    final draftCurrency = _draft?.currency?.trim().toUpperCase();
    final paymentMethod = _effectivePaymentMethod(context, selectedWallet: wallet);
    final draft = AiExpenseDraftSelection(
      amount: amount,
      currency: walletCurrency?.isNotEmpty == true
          ? walletCurrency
          : draftCurrency?.isNotEmpty == true
          ? draftCurrency
          : _defaultCurrency(context),
      date: _draft?.date ?? DateTime.now(),
      categoryId: category.categoryId,
      categoryName: category.name,
      walletAccountId: wallet?.walletId,
      walletAccountName: wallet?.name,
      description: merchant.isNotEmpty ? merchant : _draft?.description,
      merchant: _draft?.merchant,
      paymentMethod: paymentMethod,
      confidence: _draft?.confidence ?? 0,
      gatewayRequestId: _draft?.gatewayRequestId,
    );

    _pendingAiQuotaOperationId = const Uuid().v4();
    context.read<AiExpenseEntryCubit>()
      ..updateDraft(draft)
      ..saveDraft(
        userId: userId,
        categories: categories,
        wallets: wallets,
        defaultPaymentMethod: _defaultPaymentMethod(context),
      );
  }

  void _showAiRewardSheet(BuildContext context) {
    final quotaCubit = _maybeReadEntryQuotaCubit(context);
    if (quotaCubit == null) {
      showAppToast(context, 'Entry limits are unavailable right now.', isError: true);
      return;
    }
    final monetizationCubit = _maybeReadMonetizationCubit(context);
    var loading = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final adsAvailable = monetizationCubit
                    ?.state
                    .adPolicyFor(AdPlacement.rewardedAiEntries)
                    .allowed ??
                false;
            return RewardedQuotaSheet(
              placement: EntryQuotaRewardPlacement.rewardedAiEntries,
              adsAvailable: adsAvailable,
              loading: loading,
              onCancel: () => Navigator.of(sheetContext).pop(),
              onWatchAd: !adsAvailable || loading || monetizationCubit == null
                  ? null
                  : () async {
                      setSheetState(() => loading = true);
                      final adResult = await monetizationCubit.showRewardedAd(
                        placement: AdPlacement.rewardedAiEntries,
                      );
                      final quotaResult = await quotaCubit.grantRewardFromAdResult(
                        placement: EntryQuotaRewardPlacement.rewardedAiEntries,
                        adResult: adResult,
                      );
                      if (!sheetContext.mounted) return;
                      setSheetState(() => loading = false);
                      if (quotaResult.changed || quotaResult.duplicate) {
                        Navigator.of(sheetContext).pop();
                        if (mounted) showAppToast(context, quotaResult.message);
                      } else if (mounted) {
                        showAppToast(context, quotaResult.message, isError: true);
                      }
                    },
            );
          },
        );
      },
    );
  }

  Future<void> _handleAiSaveSuccess(BuildContext context) async {
    final operationId = _pendingAiQuotaOperationId;
    _pendingAiQuotaOperationId = null;
    final quotaCubit = _maybeReadEntryQuotaCubit(context);
    if (operationId != null && quotaCubit != null) {
      final result = await quotaCubit.consumeAfterSuccessfulSave(
        kind: EntryQuotaKind.ai,
        operationId: operationId,
      );
      if (!mounted || !context.mounted) return;
      if (result.status == EntryQuotaMutationStatus.unavailable) {
        showAppToast(context, result.message, isError: true);
      }
    }

    if (!mounted || !context.mounted) return;
    _refreshAfterAiSave(context);
    showAppToast(context, 'Expense saved');
    if (Navigator.canPop(context)) {
      context.pop();
    } else {
      context.go('/expenses');
    }
  }

  void _refreshAfterAiSave(BuildContext context) {
    final now = DateTime.now();
    try {
      context.read<GetExpensesBloc>().add(RefreshExpenses());
    } catch (_) {
      // Focused tests may mount this screen without the app-level expense bloc.
    }
    try {
      context.read<ReportCubit>().load(now: now);
    } catch (_) {
      // Focused tests may mount this screen without reports.
    }
    try {
      context.read<BudgetBloc>().add(BudgetLoad(now.month, now.year));
    } catch (_) {
      // Focused tests may mount this screen without budgets.
    }
  }

  Widget _buildSaveButton(
    BuildContext context, {
    required List<Category> categories,
    required List<WalletAccount> wallets,
  }) {
    return BlocBuilder<AiExpenseEntryCubit, AiExpenseEntryState>(
      builder: (context, state) {
        final saving = state.status == AiExpenseEntryStatus.saving;
        final missingFields = _missingRequiredFields(categories);
        final canSave = !saving && missingFields.isEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientButton(
              label: saving ? 'Saving...' : 'Save Expense',
              onPressed: canSave
                  ? () => _onSave(
                      context,
                      categories: categories,
                      wallets: wallets,
                    )
                  : null,
            ),
            if (!canSave && !saving) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _missingSaveMessage(missingFields),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildQuotaStatus(BuildContext context) {
    if (_maybeReadEntryQuotaCubit(context) == null) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<EntryQuotaCubit, EntryQuotaState>(
      builder: (context, state) {
        if (state.quotaUnavailable) {
          return Text(
            state.errorMessage ?? 'Entry limits are unavailable right now.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          );
        }
        return EntryQuotaStatus(
          kind: EntryQuotaKind.ai,
          remaining: state.aiRemaining,
          isPremium: state.isPremium,
        );
      },
    );
  }

  List<String> _missingRequiredFields(List<Category> categories) {
    final missing = <String>[];
    final amount = double.tryParse(_amount.text.trim()) ?? _draft?.amount;
    if (amount == null || amount <= 0) {
      missing.add('amount');
    }
    final category =
        _selectedCategory ??
        _findCategory(
          categories,
          categoryId: _draft?.categoryId,
          categoryName: _draft?.categoryName,
        ) ??
        (categories.length == 1 ? categories.first : null);
    if (category == null) {
      missing.add('category');
    }
    return missing;
  }

  String _missingSaveMessage(List<String> missingFields) {
    if (missingFields.length == 1 && missingFields.first == 'amount') {
      return 'Add an amount before saving.';
    }
    if (missingFields.length == 1 && missingFields.first == 'category') {
      return 'Select a category before saving.';
    }
    return 'Add an amount and category before saving.';
  }

  WalletState? _watchWalletState(BuildContext context) {
    try {
      return context.watch<WalletBloc>().state;
    } catch (_) {
      return null;
    }
  }

  EntryQuotaCubit? _maybeReadEntryQuotaCubit(BuildContext context) {
    try {
      return context.read<EntryQuotaCubit>();
    } catch (_) {
      return null;
    }
  }

  MonetizationCubit? _maybeReadMonetizationCubit(BuildContext context) {
    try {
      return context.read<MonetizationCubit>();
    } catch (_) {
      return null;
    }
  }

  void _navigateMode(int index) {
    switch (index) {
      case 0:
        context.go('/expenses/new/quick');
      case 2:
        showAppToast(
          context,
          'Receipt scanning is not available yet. Use AI text for now.',
          isError: true,
        );
      default:
        break;
    }
  }

  String _defaultCurrency(BuildContext context) {
    try {
      final state = context.read<SettingsCubit>().state;
      if (state is SettingsSuccess) return state.settings.baseCurrency;
      if (state is SettingsSaving) return state.tentative.baseCurrency;
    } catch (_) {
      // Screen tests and isolated routes may not mount SettingsCubit.
    }
    return UserSettings.defaultBaseCurrency;
  }

  PaymentMethod _defaultPaymentMethod(BuildContext context) {
    try {
      final state = context.read<SettingsCubit>().state;
      if (state is SettingsSuccess) return state.settings.defaultPaymentMethod;
      if (state is SettingsSaving) return state.tentative.defaultPaymentMethod;
    } catch (_) {
      // Screen tests and isolated routes may not mount SettingsCubit.
    }
    return PaymentMethod.cash;
  }

  PaymentMethod _effectivePaymentMethod(
    BuildContext context, {
    WalletAccount? selectedWallet,
  }) {
    if (selectedWallet != null) return PaymentMethod.wallet;
    return _selectedPaymentMethod ?? _draft?.paymentMethod ?? _defaultPaymentMethod(context);
  }

  Category? _findCategory(
    List<Category> categories, {
    String? categoryId,
    String? categoryName,
  }) {
    final id = categoryId?.trim();
    if (id != null && id.isNotEmpty) {
      for (final category in categories) {
        if (category.categoryId == id) return category;
      }
    }
    final name = categoryName?.trim().toLowerCase();
    if (name == null || name.isEmpty) return null;
    for (final category in categories) {
      if (category.name.trim().toLowerCase() == name) return category;
    }
    return null;
  }

  WalletAccount? _findWallet(
    List<WalletAccount> wallets, {
    String? walletId,
    String? walletName,
  }) {
    final id = walletId?.trim();
    if (id != null && id.isNotEmpty) {
      for (final wallet in wallets) {
        if (wallet.walletId == id) return wallet;
      }
    }
    final name = walletName?.trim().toLowerCase();
    if (name == null || name.isEmpty) return null;
    for (final wallet in wallets) {
      if (wallet.name.trim().toLowerCase() == name) return wallet;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AiExpenseEntryCubit(
        gatewayClient: AiGatewayClient(),
        expenseRepository: context.read<ExpenseRepository>(),
      ),
      child: Builder(
        builder: (context) {
          final categoryState = context.watch<CategoryBloc>().state;
          final categories = categoryState is CategoryLoaded
              ? categoryState.categories
              : <Category>[];
          final walletState = _watchWalletState(context);
          final wallets = walletState?.wallets ?? const <WalletAccount>[];
          if (_selectedWallet != null &&
              !wallets.any((wallet) => wallet.walletId == _selectedWallet!.walletId)) {
            _selectedWallet = null;
          }
          final walletsUnavailable = walletState?.status == WalletStatus.error;
          final defaultCurrency = _defaultCurrency(context);
          final effectivePaymentMethod = _effectivePaymentMethod(
            context,
            selectedWallet: _selectedWallet,
          );
          final locale = Localizations.localeOf(context).toLanguageTag();

          return BlocListener<AiExpenseEntryCubit, AiExpenseEntryState>(
            listener: (context, state) {
              if (state.status == AiExpenseEntryStatus.draftReady &&
                  state.draft != null &&
                  state.draft != _draft) {
                _applyDraft(state.draft!, categories: categories, wallets: wallets);
              }
              if (state.status == AiExpenseEntryStatus.saved) {
                unawaited(_handleAiSaveSuccess(context));
              }
              if (state.status == AiExpenseEntryStatus.draftReady && state.errorMessage != null) {
                showAppToast(context, state.errorMessage!, isError: true);
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
                              'AI Text',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
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
                          categories: categories,
                          defaultCurrency: defaultCurrency,
                          defaultPaymentMethod: _defaultPaymentMethod(context),
                          locale: locale,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildQuotaStatus(context),
                        const SizedBox(height: AppSpacing.md),
                        _buildSaveButton(
                          context,
                          categories: categories,
                          wallets: wallets,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (categories.isNotEmpty) ...[
                          Text(
                            'Category',
                            style: AppTextStyles.labelCaps.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: categories.map((cat) {
                              final selected = _selectedCategory?.categoryId == cat.categoryId;
                              return GestureDetector(
                                onTap: () => setState(
                                  () => _selectedCategory = selected ? null : cat,
                                ),
                                child: Chip(
                                  label: Text(cat.name),
                                  backgroundColor: selected
                                      ? AppColors.primaryContainer
                                      : AppColors.surfaceContainerHigh,
                                  labelStyle: AppTextStyles.bodySmall.copyWith(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                  ),
                                  side: BorderSide.none,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        if (walletsUnavailable) ...[
                          Text(
                            'Wallets are unavailable. You can still save the expense without a wallet.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ] else if (wallets.isEmpty) ...[
                          Text(
                            'Wallet is optional. This expense will be saved without a wallet.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
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
                        const SizedBox(height: AppSpacing.md),
                        ExpenseFormCard(
                          merchantController: _merchant,
                          amountController: _amount,
                          wallets: wallets.map((w) => w.name).toList(),
                          selectedWalletId: _selectedWallet?.name,
                          onWalletChanged: (v) => setState(() {
                            _selectedWallet = _findWallet(wallets, walletName: v);
                            if (_selectedWallet != null) {
                              _selectedPaymentMethod = PaymentMethod.wallet;
                            }
                          }),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
