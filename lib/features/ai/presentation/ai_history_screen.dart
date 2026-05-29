import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/features/ai/services/ai_service.dart';
import 'widgets/chat_bubble.dart';

class AiHistoryScreen extends StatefulWidget {
  const AiHistoryScreen({super.key});

  @override
  State<AiHistoryScreen> createState() => _AiHistoryScreenState();
}

class _AiHistoryScreenState extends State<AiHistoryScreen> {
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
      id: 'local-${_messages.length}',
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
                      _PromptChip(label: 'Show my spending', onTap: () => _onPromptTap('Show my spending')),
                      const SizedBox(width: AppSpacing.sm),
                      _PromptChip(label: 'How to save more?', onTap: () => _onPromptTap('How to save more?')),
                      const SizedBox(width: AppSpacing.sm),
                      _PromptChip(label: 'Budget tips', onTap: () => _onPromptTap('Budget tips')),
                      const SizedBox(width: AppSpacing.sm),
                      _PromptChip(label: 'Subscription review', onTap: () => _onPromptTap('Subscription review')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
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
      ),
    );
  }

  void _onPromptTap(String prompt) {
    _controller.text = prompt;
    _sendMessage();
  }

  Widget _buildMessageList() {
    if (_loading && _messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
      children: _messages.map((msg) => ChatBubble(
        text: msg.text,
        isUser: msg.isUser,
        timestamp: msg.timestampLabel,
      )).toList(),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
