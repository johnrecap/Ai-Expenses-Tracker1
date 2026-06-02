import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppAdSlotKind { homeBanner, expensesInline }

class AppAdSlot extends StatelessWidget {
  const AppAdSlot.homeBanner({super.key})
    : kind = AppAdSlotKind.homeBanner,
      placement = AdPlacement.nonCriticalBanner;

  const AppAdSlot.expensesInline({super.key})
    : kind = AppAdSlotKind.expensesInline,
      placement = AdPlacement.nonCriticalBanner;

  static const homeBannerKey = Key('home-ad-banner-slot');
  static const expensesInlineKey = Key('expenses-inline-ad-slot');

  final AppAdSlotKind kind;
  final AdPlacement placement;

  @override
  Widget build(BuildContext context) {
    final monetizationState = _maybeWatchMonetization(context);
    if (monetizationState == null) return const SizedBox.shrink();

    final decision = monetizationState.adPolicyFor(placement);
    if (!decision.allowed) return const SizedBox.shrink();

    final isInline = kind == AppAdSlotKind.expensesInline;
    return Padding(
      key: isInline ? expensesInlineKey : homeBannerKey,
      padding: EdgeInsetsDirectional.only(
        top: isInline ? 0 : AppSpacing.md,
        bottom: AppSpacing.md,
        start: isInline ? AppSpacing.containerPadding : 0,
        end: isInline ? AppSpacing.containerPadding : 0,
      ),
      child: Semantics(
        container: true,
        label: 'Ad slot',
        child: GlassCard(
          height: isInline ? 68 : 72,
          borderRadius: AppRadii.lg,
          fillColor: AppColors.surfaceContainerLowest.withAlpha(210),
          borderColor: AppColors.outlineVariant,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: AppRadii.md,
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Ad',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelCaps.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MonetizationState? _maybeWatchMonetization(BuildContext context) {
    try {
      return context.watch<MonetizationCubit>().state;
    } catch (_) {
      return null;
    }
  }
}
