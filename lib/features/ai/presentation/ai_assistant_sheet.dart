import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';
import 'package:expenses_tracker/core/mock/mock_data.dart';
import 'package:expenses_tracker/core/mock/mock_models.dart';
import 'widgets/chat_bubble.dart';

class AiAssistantSheet extends StatefulWidget {
  const AiAssistantSheet({super.key});

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final _controller = TextEditingController();
  final _messages = <MockChatMessage>[
    ...MockData.chatMessages.take(2),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: GlassBottomSheet(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.containerPadding, AppSpacing.sm, AppSpacing.containerPadding, AppSpacing.sm),
              child: Row(
                children: [
                  Text('AI Assistant', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surfaceContainerHigh),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                children: _messages.map((msg) => ChatBubble(
                  text: msg.text,
                  isUser: msg.isUser,
                  timestamp: msg.timestampLabel,
                )).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.containerPadding, AppSpacing.sm, AppSpacing.containerPadding, AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.glassSheetFill,
                border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mic_none, size: 22, color: AppColors.outline),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Ask AI...',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.outline),
                        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() {
                          _messages.add(MockChatMessage(
                            id: 'sheet-${_messages.length}',
                            author: 'You',
                            text: _controller.text,
                            timestampLabel: 'Now',
                            isUser: true,
                          ));
                        });
                        _controller.clear();
                      }
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send, size: 18, color: AppColors.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
