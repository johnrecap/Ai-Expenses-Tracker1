import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/ai/models/ai_parsed_expense.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_top_bar.dart';
import 'package:expenses_tracker/features/ai/services/ai_expense_service.dart';
import 'package:expenses_tracker/features/ai/services/advisor_service.dart';
import 'package:expenses_tracker/shared/animations/pulse_animation.dart';
import 'widgets/ai_message_bubble.dart';
import 'widgets/ai_expense_preview.dart';

/// {@template ai_chat_screen}
/// A WhatsApp-style chat interface for interacting with the AI assistant.
///
/// Supports natural-language expense parsing, financial Q&A, and
/// actionable recommendations. Uses [AiExpenseService] for parsing
/// and [AdvisorService] for insights. Fully supports Arabic RTL
/// and English LTR with Material 3 design.
/// {@endtemplate}
class AiChatScreen extends StatefulWidget {
  /// {@macro ai_chat_screen}
  const AiChatScreen({
    super.key,
    required this.aiExpenseService,
    this.advisorService,
  });

  /// Service used to parse natural-language expense input.
  final AiExpenseService aiExpenseService;

  /// Optional advisor service for financial insights within chat.
  final AdvisorService? advisorService;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _ChatMessage {
  _ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.timestamp,
    this.parsedExpense,
  });

  final String id;
  final String text;
  final bool isUser;
  final String? timestamp;
  final AiParsedExpense? parsedExpense;
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  String? _error;

  static const _prompts = [
    'Show my spending',
    'How to save more?',
    'Budget tips',
    'Subscription review',
  ];

  static const _promptsAr = [
    'أرني مصاريفي',
    'كيف أوفر أكثر؟',
    'نصائح الميزانية',
    'راجع الاشتراكات',
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    _messages.add(
      _ChatMessage(
        id: 'welcome',
        text: isRTL
            ? 'مرحباً! أنا المساعد الذكي. كيف يمكنني مساعدتك اليوم؟'
            : 'Hello! I am your AI assistant. How can I help you with your finances today?',
        isUser: false,
        timestamp: _formatTime(DateTime.now()),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = _ChatMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: _formatTime(DateTime.now()),
    );

    setState(() {
      _messages.add(userMessage);
      _loading = true;
      _error = null;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Try parsing as expense first
      final result = await widget.aiExpenseService.processInput(text);

      if (result.canSave && result.completed.confidence >= 0.5) {
        final aiMessage = _ChatMessage(
          id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
          text: '',
          isUser: false,
          timestamp: _formatTime(DateTime.now()),
          parsedExpense: result.completed,
        );
        setState(() {
          _messages.add(aiMessage);
          _loading = false;
        });
      } else {
        // Fallback to general AI response
        final response = await _generateAiResponse(text);
        final aiMessage = _ChatMessage(
          id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
          text: response,
          isUser: false,
          timestamp: _formatTime(DateTime.now()),
        );
        setState(() {
          _messages.add(aiMessage);
          _loading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }

    _scrollToBottom();
  }

  Future<String> _generateAiResponse(String userText) async {
    // If advisor service is available, try to get a contextual response
    if (widget.advisorService != null) {
      try {
        final summary = widget.advisorService!.getSpendingSummary();
        final isRTL = Directionality.of(context) == TextDirection.rtl;

        if (userText.toLowerCase().contains('spending') ||
            userText.contains('مصاريف')) {
          return isRTL
              ? 'إجمالي المصاريف هذا الشهر: ${summary.monthlyTotal.toStringAsFixed(2)} ${summary.monthlyBudget != null ? "(الميزانية: ${summary.monthlyBudget!.toStringAsFixed(2)})" : ""}'
              : 'Your total spending this month: ${summary.monthlyTotal.toStringAsFixed(2)} ${summary.monthlyBudget != null ? "(Budget: ${summary.monthlyBudget!.toStringAsFixed(2)})" : ""}';
        }

        if (userText.toLowerCase().contains('save') ||
            userText.contains('وفر')) {
          final top = summary.topCategory ?? 'expenses';
          return isRTL
              ? 'للتوفير، حاول تقليل مصاريف $top. ماداتك اليومية: ${summary.dailyAverage.toStringAsFixed(2)}.'
              : 'To save more, try reducing your $top spending. Your daily average is ${summary.dailyAverage.toStringAsFixed(2)}.';
        }
      } on Exception {
        // Fall through to generic response
      }
    }

    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return isRTL
        ? 'فهمت رسالتك: "$userText". يمكنك إرسال مصارفك بطريقة طبيعية وسأساعدك في تسجيلها.'
        : 'I understood: "$userText". You can type expenses naturally and I will help you record them.';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final prompts = isRTL ? _promptsAr : _prompts;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: isRTL ? 'المساعد الذكي' : 'AI Assistant',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                  onPressed: () => context.pop(),
                ),
              ),
              // Prompt chips
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                ),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: prompts.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return _PromptChip(
                        label: prompts[index],
                        onTap: () => _onPromptTap(prompts[index]),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Messages list
              Expanded(
                child: _buildMessageList(),
              ),
              // Error banner
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.containerPadding,
                    vertical: AppSpacing.sm,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withAlpha(150),
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _error!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Input bar
              _buildInputBar(isRTL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Center(
        child: Text('Start a conversation...'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];

        if (msg.parsedExpense != null) {
          return AiExpensePreview(
            parsedExpense: msg.parsedExpense!,
            onConfirm: () {
              // TODO: navigate to add expense with pre-filled data
            },
            onEdit: () {
              // TODO: navigate to edit expense with parsed data
            },
          );
        }

        return AiMessageBubble(
          text: msg.text,
          isUser: msg.isUser,
          timestamp: msg.timestamp,
          showAvatar: !msg.isUser,
        );
      },
    );
  }

  Widget _buildInputBar(bool isRTL) {
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.containerPadding,
        end: AppSpacing.containerPadding,
        top: AppSpacing.sm,
        bottom: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.glassSheetFill,
        border: Border(
          top: BorderSide(color: AppColors.surfaceContainerHigh),
        ),
      ),
      child: Row(
        children: [
          PulseAnimation(
            child: GestureDetector(
              onTap: () {
                // TODO: trigger voice input
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic_none,
                  size: 22,
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _controller,
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: isRTL
                    ? 'اكتب رسالتك هنا...'
                    : 'Type your message...',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.outline,
                ),
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                ),
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
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.aiGradientStart,
                      AppColors.aiGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  size: 18,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onPromptTap(String prompt) {
    _controller.text = prompt;
    _sendMessage();
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
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.glassCardFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
