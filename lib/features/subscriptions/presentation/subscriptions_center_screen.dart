import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/ai_insight_card.dart';
import 'package:expenses_tracker/core/mock/mock_data.dart';
import 'package:expenses_tracker/app/routes.dart';

class SubscriptionsCenterScreen extends StatelessWidget {
  const SubscriptionsCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: 'Subscriptions',
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
                trailing: IconButton(
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add subscription - placeholder'))),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Active Subscriptions', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      ...MockData.subscriptions.map((sub) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _SubscriptionCard(subscription: sub),
                      )),
                      const SizedBox(height: AppSpacing.md),
                      ...MockData.aiInsights.where((a) => a.relatedRoute == '/subscriptions').map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AiInsightCard(title: insight.title, summary: insight.summary, severity: insight.severity),
                      )),
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

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscription});
  final dynamic subscription;

  @override
  Widget build(BuildContext context) {
    final vendor = (subscription?.vendor as String?) ?? '';
    final amount = (subscription?.amount is double) ? subscription.amount : (subscription?.amount as num?)?.toDouble() ?? 0.0;
    final currency = (subscription?.currency as String?) ?? 'KWD';
    final nextBilling = (subscription?.nextBillingLabel as String?) ?? '';
    final status = (subscription?.status as String?) ?? 'active';
    final hasWarning = subscription?.hasAiWarning == true;
    final initials = vendor.length >= 2 ? vendor.substring(0, 2).toUpperCase() : vendor.toUpperCase();
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: hasWarning ? AppColors.errorContainer.withAlpha(100) : AppColors.primaryContainer.withAlpha(30),
            ),
            child: Center(
              child: Text(initials,
                style: AppTextStyles.titleMedium.copyWith(
                  color: hasWarning ? AppColors.error : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(vendor, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${amount.toStringAsFixed(3)} $currency',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('Next: $nextBilling', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                    const Spacer(),
                    _StatusChip(status: status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryContainer.withAlpha(50) : AppColors.errorContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelCaps.copyWith(color: isActive ? AppColors.primary : AppColors.error, fontSize: 10),
      ),
    );
  }
}
