import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/monetization/models/monetization_plan.dart';
import 'package:flutter/material.dart';

class FreePremiumScreen extends StatelessWidget {
  const FreePremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: Text(
          'Subscription',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CurrentPlanCard(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Available Plans',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: AppSpacing.md),
                const _PlanCard(plan: MonetizationPlan.free, isCurrent: true),
                const SizedBox(height: AppSpacing.md),
                const _PlanCard(plan: MonetizationPlan.premium, isCurrent: false),
                const SizedBox(height: AppSpacing.lg),
                const _UnavailableNotice(),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Upgrade unavailable'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: null,
                  child: Text(
                    'Restore Purchases',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(60),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  'Free Plan',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                ),
                Text(
                  'Basic tracking and limited AI',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isCurrent});
  final MonetizationPlan plan;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final isPremium = plan.tier == PlanTier.premium;
    return GlassCard(
      borderColor: isPremium ? AppColors.primaryContainer : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                plan.title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isPremium ? AppColors.primary : AppColors.onSurface,
                ),
              ),
              const Spacer(),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Current',
                    style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary),
                  ),
                ),
              if (isPremium && !isCurrent)
                Text(
                  'Unavailable',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            plan.summary,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...plan.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: isPremium ? AppColors.primary : AppColors.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableNotice extends StatelessWidget {
  const _UnavailableNotice();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: AppColors.outlineVariant,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium is not available yet',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upgrade and restore stay disabled until real store billing is connected. Premium will use the store purchase state with a local entitlement cache. Ads stay disabled until a real ad provider is wired, and future ads must not interrupt expense entry, saving, typing, or AI parsing.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
