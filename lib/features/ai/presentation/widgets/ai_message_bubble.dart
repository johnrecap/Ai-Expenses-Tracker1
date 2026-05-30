import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';

/// {@template ai_message_bubble}
/// A WhatsApp-style chat bubble for the AI chat interface.
///
/// AI messages appear on the left with a soft surface color,
/// user messages appear on the right with the primary brand color.
/// Includes a subtle fade-in + slide-up animation on first appearance.
/// {@endtemplate}
class AiMessageBubble extends StatefulWidget {
  /// {@macro ai_message_bubble}
  const AiMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.timestamp,
    this.showAvatar = true,
  });

  /// The message text content.
  final String text;

  /// `true` if the message is from the user (right side).
  /// `false` for AI messages (left side).
  final bool isUser;

  /// Optional timestamp label displayed below the bubble.
  final String? timestamp;

  /// Whether to show the AI avatar icon for non-user messages.
  final bool showAvatar;

  @override
  State<AiMessageBubble> createState() => _AiMessageBubbleState();
}

class _AiMessageBubbleState extends State<AiMessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final alignment = widget.isUser
        ? (isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.end)
        : (isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: widget.isUser ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  if (!widget.isUser && widget.showAvatar) ...[
                    const _AiAvatar(),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsetsDirectional.only(
                        start: AppSpacing.md,
                        end: AppSpacing.md,
                        top: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isUser
                            ? AppColors.primary
                            : AppColors.surfaceContainerLow,
                        borderRadius: _borderRadius(isRTL),
                      ),
                      child: Text(
                        widget.text,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: widget.isUser
                              ? AppColors.onPrimary
                              : AppColors.onSurface,
                          height: 1.5,
                        ),
                        textDirection: _textDirection(),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.timestamp != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.timestamp!,
                  style: AppTextStyles.labelCaps.copyWith(
                    color: AppColors.outline,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  BorderRadiusDirectional _borderRadius(bool isRTL) {
    const radius = Radius.circular(18);
    const smallRadius = Radius.circular(4);

    if (widget.isUser) {
      return const BorderRadiusDirectional.only(
        topStart: radius,
        topEnd: radius,
        bottomStart: radius,
        bottomEnd: smallRadius,
      );
    }

    return const BorderRadiusDirectional.only(
      topStart: radius,
      topEnd: radius,
      bottomStart: smallRadius,
      bottomEnd: radius,
    );
  }

  TextDirection _textDirection() {
    // Simple heuristic: if text contains Arabic characters, use RTL
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(widget.text);
    return hasArabic ? TextDirection.rtl : TextDirection.ltr;
  }
}

/// Small AI avatar icon shown next to AI messages.
class _AiAvatar extends StatelessWidget {
  const _AiAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.aiGradientStart, AppColors.aiGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.auto_awesome,
        size: 16,
        color: AppColors.onPrimary,
      ),
    );
  }
}
