import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:flutter/material.dart';

class RewardedQuotaSheet extends StatelessWidget {
  const RewardedQuotaSheet({
    super.key,
    required this.placement,
    required this.adsAvailable,
    required this.onWatchAd,
    this.onCancel,
    this.loading = false,
  });

  static const watchAdButtonKey = Key('rewarded-quota-watch-ad-button');
  static const unavailableKey = Key('rewarded-quota-ads-unavailable');
  static const loadingKey = Key('rewarded-quota-loading');

  final EntryQuotaRewardPlacement placement;
  final bool adsAvailable;
  final bool loading;
  final VoidCallback? onWatchAd;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final rewardAmount = _rewardAmount;
    final isAi = placement == EntryQuotaRewardPlacement.rewardedAiEntries;

    return SafeArea(
      top: false,
      child: GlassBottomSheet(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isRtl ? 'وصلت إلى الحد اليومي' : 'Daily limit reached',
                textAlign: TextAlign.start,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _promiseText(isRtl: isRtl, isAi: isAi, amount: rewardAmount),
                textAlign: TextAlign.start,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (loading)
                const Center(
                  key: loadingKey,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (!adsAvailable)
                Text(
                  key: unavailableKey,
                  isRtl
                      ? 'الإعلانات غير متاحة الآن. حاول مرة أخرى لاحقا.'
                      : 'Ads are unavailable right now. Try again later.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                )
              else
                GradientButton(
                  key: watchAdButtonKey,
                  label: isRtl ? 'شاهد إعلانا' : 'Watch ad',
                  onPressed: onWatchAd,
                  prefixIcon: const Icon(
                    Icons.play_circle_outline,
                    color: AppColors.onPrimary,
                    size: 20,
                  ),
                ),
              if (onCancel != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onCancel,
                  child: Text(isRtl ? 'ليس الآن' : 'Not now'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int get _rewardAmount {
    switch (placement) {
      case EntryQuotaRewardPlacement.rewardedNormalEntries:
        return EntryQuotaDefaults.rewardedNormalGrant;
      case EntryQuotaRewardPlacement.rewardedAiEntries:
        return EntryQuotaDefaults.rewardedAiGrant;
    }
  }

  String _promiseText({
    required bool isRtl,
    required bool isAi,
    required int amount,
  }) {
    if (isRtl) {
      return isAi
          ? 'شاهد إعلانا واحدا لتحصل على $amount إدخالات ذكاء اصطناعي إضافية اليوم.'
          : 'شاهد إعلانا واحدا لتحصل على $amount إدخالات يدوية إضافية اليوم.';
    }
    return isAi
        ? 'Watch one ad to get $amount extra AI entries today.'
        : 'Watch one ad to get $amount extra entries today.';
  }
}
