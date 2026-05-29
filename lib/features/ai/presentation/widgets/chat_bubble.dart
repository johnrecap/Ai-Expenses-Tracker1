import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : AppColors.surfaceContainerLow,
              borderRadius: BorderRadiusDirectional.only(
                topStart: const Radius.circular(16),
                topEnd: const Radius.circular(16),
                bottomStart: isUser ? const Radius.circular(16) : const Radius.circular(4),
                bottomEnd: isUser ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: isUser ? AppColors.onPrimary : AppColors.onSurface,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(timestamp, style: AppTextStyles.labelCaps.copyWith(color: AppColors.outline, fontSize: 10)),
        ],
      ),
    );
  }
}
