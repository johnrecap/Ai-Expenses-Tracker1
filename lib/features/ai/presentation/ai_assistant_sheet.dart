import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';
import 'package:expenses_tracker/features/ai/services/ai_service.dart';
import 'widgets/chat_bubble.dart';

class AiAssistantSheet extends StatefulWidget {
  const AiAssistantSheet({super.key});

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final _controller = TextEditingController();
  final _aiService = const MockAiService();
  List<AiChatMessage> _messages = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _aiService.getChatHistory();
      if (mounted) {
        setState(() {
          _messages = history;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load chat history.';
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = AiChatMessage(
      id: 'sheet-${_messages.length}',
      author: 'You',
      text: text,
      timestampLabel: 'Now',
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _loading = true;
      _error = null;
    });
    _controller.clear();

    try {
      final response = await _aiService.sendChatMessage(text);
      if (mounted) {
        setState(() {
          _messages.add(response);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to get AI response. Please try again.';
        });
      }
    }
  }

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
                      decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surfaceContainerHigh),
            Expanded(
              child: _buildMessageList(),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withAlpha(150),
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
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
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (_loading)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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

  Widget _buildMessageList() {
    if (_loading && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      children: _messages.map((msg) => ChatBubble(
        text: msg.text,
        isUser: msg.isUser,
        timestamp: msg.timestampLabel,
      )).toList(),
    );
  }
}
