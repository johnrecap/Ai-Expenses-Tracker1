import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:expenses_tracker/app/routes.dart';

class WalletsAccountsScreen extends StatelessWidget {
  const WalletsAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listenWhen: (previous, current) =>
          current.message != null && previous.message != current.message,
      listener: (context, state) {
        showAppToast(context, state.message!, isError: state.status == WalletStatus.error);
      },
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                AppTopBar(
                  title: 'Wallets',
                  trailing: BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, state) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            key: const ValueKey('wallet-transfer-button'),
                            tooltip: 'Transfer',
                            icon: const Icon(
                              Icons.swap_horiz,
                              color: AppColors.primary,
                            ),
                            onPressed: state.wallets.length < 2
                                ? null
                                : () => _showTransferForm(context, state.wallets),
                          ),
                          IconButton(
                            key: const ValueKey('wallet-add-button'),
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _showWalletForm(context),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, state) {
                      if (state.status == WalletStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.wallets.isEmpty) {
                        return const EmptyState(
                          icon: Icons.wallet_outlined,
                          title: 'No wallets yet',
                        );
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(
                          AppSpacing.containerPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accounts',
                              style: AppTextStyles.labelCaps.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ...state.wallets.map(
                              (wallet) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: _WalletCard(
                                  wallet: wallet,
                                  onTap: () => _showWalletForm(
                                    context,
                                    existing: wallet,
                                  ),
                                ),
                              ),
                            ),
                            if (state.transfers.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Recent Transfers',
                                style: AppTextStyles.labelCaps.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              GlassCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    ...state.transfers
                                        .take(5)
                                        .map(
                                          (transfer) => _TransferRow(
                                            label:
                                                '${_walletNameById(state.wallets, transfer.fromWalletId)} -> ${_walletNameById(state.wallets, transfer.toWalletId)}',
                                            amount:
                                                '${transfer.amount.toStringAsFixed(3)} ${_walletCurrencyById(state.wallets, transfer.fromWalletId)}',
                                            date: '${transfer.date.day}/${transfer.date.month}',
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 80),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                AppBottomNav(
                  selectedIndex: 3,
                  onDestinationSelected: (index) {
                    switch (index) {
                      case 0:
                        context.go(AppRoutes.home);
                      case 1:
                        context.go(AppRoutes.reports);
                      case 2:
                        context.go(AppRoutes.budgets);
                      case 3:
                        context.go(AppRoutes.wallets);
                      case 4:
                        context.go(AppRoutes.settings);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _walletNameById(List<WalletAccount> wallets, String walletId) {
    for (final wallet in wallets) {
      if (wallet.walletId == walletId) return wallet.name;
    }
    return walletId;
  }

  String _walletCurrencyById(List<WalletAccount> wallets, String walletId) {
    for (final wallet in wallets) {
      if (wallet.walletId == walletId) return wallet.currency;
    }
    return '';
  }

  void _showTransferForm(BuildContext context, List<WalletAccount> wallets) {
    final bloc = context.read<WalletBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _TransferForm(wallets: wallets),
      ),
    );
  }

  void _showWalletForm(BuildContext context, {WalletAccount? existing}) {
    final bloc = context.read<WalletBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _WalletForm(existing: existing),
      ),
    );
  }
}

class _TransferForm extends StatefulWidget {
  const _TransferForm({required this.wallets});

  final List<WalletAccount> wallets;

  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late String _fromWalletId;
  late String _toWalletId;

  @override
  void initState() {
    super.initState();
    _fromWalletId = widget.wallets.first.walletId;
    _toWalletId = widget.wallets.firstWhere((wallet) => wallet.walletId != _fromWalletId).walletId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromWallet = _walletById(_fromWalletId);
    final toWallet = _walletById(_toWalletId);

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Transfer Money',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              key: const ValueKey('wallet-transfer-source'),
              initialValue: _fromWalletId,
              decoration: const InputDecoration(
                labelText: 'From',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              items: widget.wallets
                  .map(
                    (wallet) => DropdownMenuItem(
                      value: wallet.walletId,
                      child: Text(
                        '${wallet.name} (${wallet.balance.toStringAsFixed(3)} ${wallet.currency})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _fromWalletId = value;
                  if (_toWalletId == value) {
                    _toWalletId = widget.wallets
                        .firstWhere((wallet) => wallet.walletId != value)
                        .walletId;
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              key: const ValueKey('wallet-transfer-destination'),
              initialValue: _toWalletId,
              decoration: const InputDecoration(
                labelText: 'To',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              items: widget.wallets
                  .where((wallet) => wallet.walletId != _fromWalletId)
                  .map(
                    (wallet) => DropdownMenuItem(
                      value: wallet.walletId,
                      child: Text(
                        '${wallet.name} (${wallet.balance.toStringAsFixed(3)} ${wallet.currency})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _toWalletId = value);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const ValueKey('wallet-transfer-amount'),
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: fromWallet == null ? 'Amount' : 'Amount (${fromWallet.currency})',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: const OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const ValueKey('wallet-transfer-note'),
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            if (fromWallet != null &&
                toWallet != null &&
                fromWallet.currency != toWallet.currency) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Transfers need wallets with the same currency.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              key: const ValueKey('wallet-transfer-submit'),
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Transfer'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  WalletAccount? _walletById(String walletId) {
    for (final wallet in widget.wallets) {
      if (wallet.walletId == walletId) return wallet;
    }
    return null;
  }

  void _save() {
    final source = _walletById(_fromWalletId);
    final destination = _walletById(_toWalletId);
    final amount = double.tryParse(_amountCtrl.text.trim());
    final message = _validate(source, destination, amount);

    if (message != null) {
      showAppToast(context, message, isError: true);
      return;
    }

    final now = DateTime.now();
    final note = _noteCtrl.text.trim();
    context.read<WalletBloc>().add(
      CreateTransfer(
        Transfer(
          transferId: 'transfer-${now.microsecondsSinceEpoch}',
          userId: source!.userId.isNotEmpty ? source.userId : destination!.userId,
          fromWalletId: source.walletId,
          toWalletId: destination!.walletId,
          amount: amount!,
          note: note.isEmpty ? null : note,
          date: now,
          createdAt: now,
        ),
      ),
    );
    Navigator.pop(context);
  }

  String? _validate(
    WalletAccount? source,
    WalletAccount? destination,
    double? amount,
  ) {
    if (source == null) return 'Choose a source wallet.';
    if (destination == null) return 'Choose a destination wallet.';
    if (source.walletId == destination.walletId) {
      return 'Choose two different wallets.';
    }
    if (amount == null || amount <= 0 || amount.isNaN || amount.isInfinite) {
      return 'Enter a valid transfer amount.';
    }
    if (source.currency != destination.currency) {
      return 'Transfers need wallets with the same currency.';
    }
    if (source.balance < amount) return 'Insufficient wallet balance.';
    return null;
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.wallet, this.onTap});
  final WalletAccount wallet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (wallet.balance >= 0 ? AppColors.primaryContainer : AppColors.errorContainer)
                  .withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                wallet.name.isNotEmpty
                    ? wallet.name.substring(0, min(wallet.name.length, 2)).toUpperCase()
                    : '?',
                style: AppTextStyles.titleMedium.copyWith(
                  color: wallet.balance >= 0 ? AppColors.primary : AppColors.error,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  wallet.type,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${wallet.balance.toStringAsFixed(3)} ${wallet.currency}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: wallet.balance >= 0 ? AppColors.onSurface : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({
    required this.label,
    required this.amount,
    required this.date,
  });
  final String label;
  final String amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.swap_horiz,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  date,
                  style: AppTextStyles.labelCaps.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletForm extends StatefulWidget {
  const _WalletForm({this.existing});
  final WalletAccount? existing;

  @override
  State<_WalletForm> createState() => _WalletFormState();
}

class _WalletFormState extends State<_WalletForm> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  static const _walletTypes = ['cash', 'bank', 'card', 'mobile_wallet', 'other'];
  String _type = 'cash';
  String _currency = UserSettings.defaultBaseCurrency;
  bool _loadedDefaultCurrency = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _balanceCtrl.text = widget.existing!.balance.toString();
      _type = _walletTypes.contains(widget.existing!.type) ? widget.existing!.type : 'other';
      _currency = widget.existing!.currency.toUpperCase();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.existing == null && !_loadedDefaultCurrency) {
      _currency = _defaultCurrency(context);
      _loadedDefaultCurrency = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyOptions = _currencyOptions(context);
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.existing != null ? 'Edit Wallet' : 'New Wallet',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              items: [
                for (final type in _walletTypes) DropdownMenuItem(value: type, child: Text(type)),
              ],
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _balanceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Balance',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    items: currencyOptions
                        .map(
                          (currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _currency = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              key: const ValueKey('wallet-save-button'),
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(widget.existing != null ? 'Update' : 'Create'),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showAppToast(context, 'Please enter a name', isError: true);
      return;
    }
    final balanceText = _balanceCtrl.text.trim();
    if (balanceText.isEmpty) {
      showAppToast(context, 'Please enter a balance', isError: true);
      return;
    }
    final balance = double.tryParse(balanceText);
    if (balance == null) {
      showAppToast(context, 'Please enter a valid number', isError: true);
      return;
    }
    final bloc = context.read<WalletBloc>();
    final userId = _currentUserId(context, widget.existing?.userId);

    if (widget.existing != null) {
      bloc.add(
        UpdateWallet(
          widget.existing!.copyWith(
            userId: userId,
            name: name,
            type: _type,
            balance: balance,
            currency: _currency,
          ),
        ),
      );
    } else {
      bloc.add(
        CreateWallet(
          WalletAccount(
            walletId: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            name: name,
            type: _type,
            balance: balance,
            currency: _currency,
            icon: '',
            color: 0xFF006875,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }
    Navigator.pop(context);
  }

  String _currentUserId(BuildContext context, String? fallback) {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.userId.trim().isNotEmpty) {
        return authState.user.userId;
      }
    } catch (_) {}
    try {
      final user = context.read<AuthRepository>().currentUser;
      if (user != null && user.userId.trim().isNotEmpty) {
        return user.userId;
      }
    } catch (_) {}
    return fallback?.trim().isNotEmpty == true ? fallback!.trim() : '';
  }

  String _defaultCurrency(BuildContext context) {
    try {
      final state = context.read<SettingsCubit>().state;
      if (state is SettingsSuccess) return state.settings.baseCurrency;
    } catch (_) {}
    return UserSettings.defaultBaseCurrency;
  }

  List<String> _currencyOptions(BuildContext context) {
    try {
      final state = context.watch<SettingsCubit>().state;
      if (state is SettingsSuccess) {
        return {
              state.settings.baseCurrency,
              ...state.settings.supportedCurrencies,
              _currency,
            }
            .where((currency) => currency.trim().isNotEmpty)
            .map((currency) => currency.toUpperCase())
            .toList();
      }
    } catch (_) {}
    return {
          UserSettings.defaultBaseCurrency,
          ...UserSettings.defaultSupportedCurrencies,
          _currency,
        }
        .where((currency) => currency.trim().isNotEmpty)
        .map((currency) => currency.toUpperCase())
        .toList();
  }
}

int min(int a, int b) => a < b ? a : b;
