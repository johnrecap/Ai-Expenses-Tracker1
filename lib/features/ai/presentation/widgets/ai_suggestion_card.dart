import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/shared/animations/pulse_animation.dart';

/// {@template ai_suggestion_card}
/// An actionable recommendation card showing a savings tip with an
/// estimated potential savings amount.
///
/// Features a gradient border, pulse animation on the savings badge,
/// and slide-up + fade-in entrance animation.
/// {@endtemplate}
class AiSuggestionCard extends StatefulWidget {
  /// {@macro ai_suggestion_card}
  const AiSuggestionCard({
    super.key,
    required this.title,
    required this.body,
    this.potentialSavings,
    this.currency = 'EGP',
    this.onTap,
    this.onDismiss,
  });

  /// Short title of the recommendation.
  final String title;

  /// Detailed explanation of the recommendation.
  final String body;

  /// Estimated potential savings amount (optional).
  final double? potentialSavings;

  /// Currency code to display next to savings.
  final String currency;

  /// Called when the user taps the card.
  final VoidCallback? onTap;

  /// Called when the user swipes/dismisses the card.
  final VoidCallback? onDismiss;

  @override
  State<AiSuggestionCard> createState() => _AiSuggestionCardState();
}

class _AiSuggestionCardState extends State<AiSuggestionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: const BoxDecoration(
              borderRadius: AppRadii.card,
              gradient: LinearGradient(
                colors: [
                  AppColors.aiGradientStart,
                  AppColors.aiGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.glassCardFill,
                borderRadius: BorderRadius.circular(22.5),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: AppColors.secondaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.onDismiss != null)
                        GestureDetector(
                          onTap: widget.onDismiss,
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.outline,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (widget.potentialSavings != null &&
                      widget.potentialSavings! > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    PulseAnimation(
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withAlpha(60),
                          borderRadius: AppRadii.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.savings_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _savingsText(),
                              style: AppTextStyles.labelCaps.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _savingsText() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final amount = widget.potentialSavings!.toStringAsFixed(2);
    if (isRTL) {
      return 'توفير محتمل: $amount ${widget.currency}';
    }
    return 'Save ~$amount ${widget.currency}';
  }
}
