import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/mock/mock_data.dart';
import 'package:expenses_tracker/app/routes.dart';

class WalletsAccountsScreen extends StatelessWidget {
  const WalletsAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const AppTopBar(title: 'Wallets & Accounts'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Accounts', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      ...MockData.wallets.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _WalletCard(wallet: w),
                      )),
                      const SizedBox(height: AppSpacing.md),
                      Text('Recent Transfers', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _TransferRow(label: 'NBK Current \u2192 KFH Savings', amount: '500.000 KWD', date: 'May 25'),
                            const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md, color: AppColors.surfaceContainerHigh),
                            _TransferRow(label: 'Cash Wallet \u2192 NBK Current', amount: '200.000 KWD', date: 'May 20'),
                            const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md, color: AppColors.surfaceContainerHigh),
                            _TransferRow(label: 'KFH Savings \u2192 Burgan Credit', amount: '1,500.000 KWD', date: 'May 15'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.wallet});
  final dynamic wallet;

  @override
  Widget build(BuildContext context) {
    final name = (wallet?.name as String?) ?? '';
    final balance = (wallet?.balance is double) ? wallet.balance : (wallet?.balance as num?)?.toDouble() ?? 0.0;
    final type = (wallet?.type as String?) ?? '';
    final currency = (wallet?.currency as String?) ?? 'KWD';
    final trendLabel = (wallet?.trendLabel as String?) ?? '';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: balance >= 0 ? AppColors.primaryContainer.withAlpha(30) : AppColors.errorContainer.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name.substring(0, name.length.clamp(0, 2)).toUpperCase() : '?',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: balance >= 0 ? AppColors.primary : AppColors.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                    Text(type, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Text(
                '${balance.toStringAsFixed(3)} $currency',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: balance >= 0 ? AppColors.onSurface : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (trendLabel.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(trendLabel, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
          ],
        ],
      ),
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
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
            child: const Icon(Icons.swap_horiz, size: 16, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface)),
                Text(date, style: AppTextStyles.labelCaps.copyWith(color: AppColors.outline)),
              ],
            ),
          ),
          Text(amount, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
