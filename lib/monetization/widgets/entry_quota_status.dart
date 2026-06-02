import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:flutter/material.dart';

class EntryQuotaStatus extends StatelessWidget {
  const EntryQuotaStatus({
    super.key,
    required this.kind,
    required this.remaining,
    this.isPremium = false,
  });

  static const normalKey = Key('entry-quota-status-normal');
  static const aiKey = Key('entry-quota-status-ai');

  final EntryQuotaKind kind;
  final int remaining;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isAi = kind == EntryQuotaKind.ai;
    final label = _label(isRtl: isRtl, isAi: isAi);
    final value = isPremium
        ? (isRtl ? 'غير محدود مع Premium' : 'Unlimited with Premium')
        : (isRtl ? 'متبقي اليوم: $remaining' : '$remaining left today');

    return GlassCard(
      key: isAi ? aiKey : normalKey,
      borderRadius: AppRadii.lg,
      fillColor: AppColors.surfaceContainerLowest.withAlpha(220),
      borderColor: AppColors.outlineVariant,
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Icon(
            isAi ? Icons.auto_awesome_outlined : Icons.receipt_long_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelCaps.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _label({required bool isRtl, required bool isAi}) {
    if (isRtl) {
      return isAi ? 'إدخالات الذكاء الاصطناعي' : 'الإدخالات اليدوية';
    }
    return isAi ? 'AI entries' : 'Manual entries';
  }
}
