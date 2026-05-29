import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/core/mock/mock_data.dart';
import 'package:expenses_tracker/core/mock/mock_models.dart';
import 'widgets/chat_bubble.dart';

class AiHistoryScreen extends StatefulWidget {
  const AiHistoryScreen({super.key});

  @override
  State<AiHistoryScreen> createState() => _AiHistoryScreenState();
}

class _AiHistoryScreenState extends State<AiHistoryScreen> {
  final _controller = TextEditingController();
  final _messages = [...MockData.chatMessages];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(title: 'AI Assistant', leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _PromptChip(label: 'Show my spending'),
                      const SizedBox(width: AppSpacing.sm),
                      _PromptChip(label: 'How to save more?'),
                      const SizedBox(width: AppSpacing.sm),
                      _PromptChip(label: 'Budget tips'),
                      const SizedBox(width: AppSpacing.sm),
                      _PromptChip(label: 'Subscription review'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                  children: _messages.map((msg) => ChatBubble(
                    text: msg.text,
                    isUser: msg.isUser,
                    timestamp: msg.timestampLabel,
                  )).toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(AppSpacing.containerPadding, AppSpacing.sm, AppSpacing.containerPadding, AppSpacing.md),
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
                          hintText: 'Ask AI anything...',
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
                              id: 'local-${_messages.length}',
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
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.glassCardFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
      ),
    );
  }
}
