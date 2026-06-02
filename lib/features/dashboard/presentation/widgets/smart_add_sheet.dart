import 'package:flutter/material.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_gradients.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';

enum SmartAddChoiceState {
  enabled,
  disabledNeedsSetup,
  disabledUnavailable,
  hidden,
}

class SmartAddChoice {
  const SmartAddChoice({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.state,
    this.route,
    this.disabledReason,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final SmartAddChoiceState state;
  final String? route;
  final String? disabledReason;

  bool get isEnabled => state == SmartAddChoiceState.enabled;
}

class SmartAddSheet extends StatelessWidget {
  const SmartAddSheet({
    super.key,
    required this.onRouteSelected,
    this.onDismiss,
  });

  static const sheetKey = Key('smart-add-sheet');
  static const closeKey = Key('smart-add-close');
  static const aiTextChoiceKey = Key('smart-add-choice-ai_text');
  static const quickAddChoiceKey = Key('smart-add-choice-quick_add');
  static const receiptChoiceKey = Key('smart-add-choice-receipt');

  final ValueChanged<String> onRouteSelected;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final strings = _SmartAddStrings.of(context);
    final choices = _buildChoices(
      strings,
    ).where((choice) => choice.state != SmartAddChoiceState.hidden).toList(growable: false);

    return SafeArea(
      top: false,
      child: GlassBottomSheet(
        padding: EdgeInsets.zero,
        child: ConstrainedBox(
          key: sheetKey,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.78,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.containerPadding,
              AppSpacing.sm,
              AppSpacing.containerPadding,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.title,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            strings.subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Tooltip(
                      message: strings.close,
                      child: IconButton(
                        key: closeKey,
                        onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                for (final choice in choices) ...[
                  _SmartAddChoiceTile(
                    key: _keyForChoice(choice.id),
                    choice: choice,
                    onTap: choice.isEnabled && choice.route != null
                        ? () => onRouteSelected(choice.route!)
                        : null,
                  ),
                  if (choice != choices.last) const SizedBox(height: AppSpacing.cardGutter),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<SmartAddChoice> _buildChoices(_SmartAddStrings strings) {
    return [
      SmartAddChoice(
        id: 'ai_text',
        title: strings.aiTextTitle,
        subtitle: strings.aiTextSubtitle,
        icon: Icons.auto_awesome,
        state: SmartAddChoiceState.enabled,
        route: AppRoutes.expensesNewText,
      ),
      SmartAddChoice(
        id: 'quick_add',
        title: strings.quickAddTitle,
        subtitle: strings.quickAddSubtitle,
        icon: Icons.add_circle_outline,
        state: SmartAddChoiceState.enabled,
        route: AppRoutes.expensesNewQuick,
      ),
      SmartAddChoice(
        id: 'receipt',
        title: strings.receiptTitle,
        subtitle: strings.receiptSubtitle,
        icon: Icons.receipt_long,
        state: SmartAddChoiceState.disabledUnavailable,
        route: null,
        disabledReason: strings.receiptUnavailable,
      ),
    ];
  }

  Key _keyForChoice(String id) {
    return switch (id) {
      'ai_text' => aiTextChoiceKey,
      'quick_add' => quickAddChoiceKey,
      'receipt' => receiptChoiceKey,
      _ => Key('smart-add-choice-$id'),
    };
  }
}

class _SmartAddChoiceTile extends StatelessWidget {
  const _SmartAddChoiceTile({
    super.key,
    required this.choice,
    required this.onTap,
  });

  final SmartAddChoice choice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final foreground = enabled ? AppColors.onSurface : AppColors.onSurfaceVariant;
    final iconBackground = choice.id == 'ai_text' ? null : AppColors.surfaceContainerHigh;
    final direction = Directionality.of(context);

    return Semantics(
      button: enabled,
      enabled: enabled,
      label: choice.title,
      child: Material(
        color: enabled ? AppColors.glassCardFill : AppColors.surfaceContainerLow,
        borderRadius: AppRadii.lg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.lg,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadii.lg,
              border: Border.all(
                color: enabled ? AppColors.glassCardBorder : AppColors.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                _ChoiceIcon(
                  icon: choice.icon,
                  enabled: enabled,
                  gradient: choice.id == 'ai_text' ? AppGradients.secondaryAi : null,
                  backgroundColor: iconBackground,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        choice.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(color: foreground),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        choice.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (choice.disabledReason != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          choice.disabledReason!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelCaps.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  enabled
                      ? direction == TextDirection.rtl
                            ? Icons.arrow_back_ios_new
                            : Icons.arrow_forward_ios
                      : Icons.lock_outline,
                  size: 18,
                  color: enabled ? AppColors.primary : AppColors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceIcon extends StatelessWidget {
  const _ChoiceIcon({
    required this.icon,
    required this.enabled,
    this.gradient,
    this.backgroundColor,
  });

  final IconData icon;
  final bool enabled;
  final Gradient? gradient;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradient == null ? backgroundColor : null,
        gradient: enabled ? gradient : null,
      ),
      child: Icon(
        icon,
        size: 22,
        color: gradient != null && enabled ? AppColors.onPrimary : AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _SmartAddStrings {
  const _SmartAddStrings({
    required this.title,
    required this.subtitle,
    required this.close,
    required this.aiTextTitle,
    required this.aiTextSubtitle,
    required this.quickAddTitle,
    required this.quickAddSubtitle,
    required this.receiptTitle,
    required this.receiptSubtitle,
    required this.receiptUnavailable,
  });

  final String title;
  final String subtitle;
  final String close;
  final String aiTextTitle;
  final String aiTextSubtitle;
  final String quickAddTitle;
  final String quickAddSubtitle;
  final String receiptTitle;
  final String receiptSubtitle;
  final String receiptUnavailable;

  static _SmartAddStrings of(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      return _SmartAddStrings(
        title: l10n.smartAddSheetTitle,
        subtitle: l10n.smartAddSheetSubtitle,
        close: l10n.smartAddClose,
        aiTextTitle: l10n.smartAddAiTextTitle,
        aiTextSubtitle: l10n.smartAddAiTextSubtitle,
        quickAddTitle: l10n.smartAddQuickAddTitle,
        quickAddSubtitle: l10n.smartAddQuickAddSubtitle,
        receiptTitle: l10n.smartAddReceiptTitle,
        receiptSubtitle: l10n.smartAddReceiptSubtitle,
        receiptUnavailable: l10n.smartAddReceiptUnavailable,
      );
    }

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? _arabicFallback : _englishFallback;
  }

  static const _englishFallback = _SmartAddStrings(
    title: 'Add expense',
    subtitle: 'Choose how you want to record this expense.',
    close: 'Close',
    aiTextTitle: 'AI text',
    aiTextSubtitle: 'Describe the expense in a sentence and review it before saving.',
    quickAddTitle: 'Quick add',
    quickAddSubtitle: 'Enter the amount and details manually.',
    receiptTitle: 'Receipt',
    receiptSubtitle: 'Scan a receipt when the real scanner is ready.',
    receiptUnavailable: 'Unavailable for now',
  );

  static const _arabicFallback = _SmartAddStrings(
    title: 'إضافة مصروف',
    subtitle: 'اختار الطريقة المناسبة لتسجيل المصروف.',
    close: 'إغلاق',
    aiTextTitle: 'نص ذكي',
    aiTextSubtitle: 'اكتب المصروف في جملة وراجعه قبل الحفظ.',
    quickAddTitle: 'إضافة سريعة',
    quickAddSubtitle: 'اكتب المبلغ والتفاصيل يدويًا.',
    receiptTitle: 'إيصال',
    receiptSubtitle: 'مسح الإيصال هيظهر لما الماسح الحقيقي يبقى جاهز.',
    receiptUnavailable: 'غير متاح حاليًا',
  );
}
