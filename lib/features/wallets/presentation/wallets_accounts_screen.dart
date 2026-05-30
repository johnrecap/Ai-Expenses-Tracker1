import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/empty_state.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:expenses_tracker/app/routes.dart';

class WalletsAccountsScreen extends StatelessWidget {
  const WalletsAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            AppTopBar(
              title: 'Wallets',
              trailing: IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                onPressed: () => _showWalletForm(context),
              ),
            ),
            Expanded(
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state.status == WalletStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.wallets.isEmpty) {
                    return const EmptyState(icon: Icons.wallet_outlined, title: 'No wallets yet');
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.containerPadding),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Accounts', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      ...state.wallets.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _WalletCard(
                          wallet: w,
                          onTap: () => _showWalletForm(context, existing: w),
                        ),
                      )),
                      if (state.transfers.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text('Recent Transfers', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: AppSpacing.sm),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(children: [
                            ...state.transfers.take(5).map((t) => _TransferRow(
                              label: '${t.fromWalletId} → ${t.toWalletId}',
                              amount: t.amount.toStringAsFixed(3),
                              date: '${t.date.day}/${t.date.month}',
                            )),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 80),
                    ]),
                  );
                },
              ),
            ),
            AppBottomNav(
              selectedIndex: 3,
              onDestinationSelected: (i) {
                switch (i) {
                  case 0: context.go(AppRoutes.home);
                  case 1: context.go(AppRoutes.reports);
                  case 2: context.go(AppRoutes.budgets);
                  case 3: context.go(AppRoutes.wallets);
                  case 4: context.go(AppRoutes.settings);
                }
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _showWalletForm(BuildContext context, {WalletAccount? existing}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WalletForm(existing: existing),
    );
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
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: (wallet.balance >= 0 ? AppColors.primaryContainer : AppColors.errorContainer).withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              wallet.name.isNotEmpty ? wallet.name.substring(0, min(wallet.name.length, 2)).toUpperCase() : '?',
              style: AppTextStyles.titleMedium.copyWith(color: wallet.balance >= 0 ? AppColors.primary : AppColors.error),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(wallet.name, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
            Text(wallet.type, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          ]),
        ),
        Text(
          '${wallet.balance.toStringAsFixed(3)} ${wallet.currency}',
          style: AppTextStyles.bodyLarge.copyWith(color: wallet.balance >= 0 ? AppColors.onSurface : AppColors.error, fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}

class _TransferRow extends StatelessWidget {
  const _TransferRow({required this.label, required this.amount, required this.date});
  final String label;
  final String amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
          child: const Icon(Icons.swap_horiz, size: 16, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface)),
            Text(date, style: AppTextStyles.labelCaps.copyWith(color: AppColors.outline)),
          ]),
        ),
        Text(amount, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
      ]),
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
  String _type = 'cash';
  String _currency = 'KWD';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _balanceCtrl.text = widget.existing!.balance.toString();
      _type = widget.existing!.type;
      _currency = widget.existing!.currency;
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
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: AppSpacing.lg),
          Text(widget.existing != null ? 'Edit Wallet' : 'New Wallet', style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name', filled: true, fillColor: AppColors.surfaceContainerLow, border: OutlineInputBorder(borderSide: BorderSide.none))),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type', filled: true, fillColor: AppColors.surfaceContainerLow, border: OutlineInputBorder(borderSide: BorderSide.none)),
            items: ['cash', 'current', 'savings', 'credit'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Expanded(child: TextField(controller: _balanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Balance', filled: true, fillColor: AppColors.surfaceContainerLow, border: OutlineInputBorder(borderSide: BorderSide.none)))),
            const SizedBox(width: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              items: ['KWD', 'EGP', 'USD', 'SAR', 'AED'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _currency = v!),
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(widget.existing != null ? 'Update' : 'Create'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ]),
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }
    final balanceText = _balanceCtrl.text.trim();
    if (balanceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a balance')),
      );
      return;
    }
    final balance = double.tryParse(balanceText);
    if (balance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
      return;
    }
    final bloc = context.read<WalletBloc>();

    if (widget.existing != null) {
      bloc.add(UpdateWallet(widget.existing!.copyWith(name: name, type: _type, balance: balance, currency: _currency)));
    } else {
      bloc.add(CreateWallet(WalletAccount(
        walletId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '', name: name, type: _type, balance: balance,
        currency: _currency, icon: '', color: 0xFF006875,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      )));
    }
    Navigator.pop(context);
  }
}

int min(int a, int b) => a < b ? a : b;
