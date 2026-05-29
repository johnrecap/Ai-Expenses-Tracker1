import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/ai/services/ai_service.dart';

class AiExpenseParsePanel extends StatefulWidget {
  final void Function(Expense? expense)? onParsed;

  const AiExpenseParsePanel({super.key, this.onParsed});

  @override
  State<AiExpenseParsePanel> createState() => _AiExpenseParsePanelState();
}

class _AiExpenseParsePanelState extends State<AiExpenseParsePanel> {
  final _controller = TextEditingController();
  bool _loading = false;
  Expense? _parsedExpense;

  final _aiService = const MockAiService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onParse() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);

    try {
      final result = await _aiService.parseExpense(text, AiContext(now: DateTime.now()));
      final draft = _aiService.parseExpenseToDraft(result);
      setState(() => _parsedExpense = draft);
      widget.onParsed?.call(draft);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI parsing failed. Enter details manually.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: AppRadii.card,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: 4,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Describe your expense...\ne.g. "Spent 25 KWD on lunch at The Avenues"',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.outline),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.mic_none, size: 20, color: AppColors.outline, semanticLabel: 'Microphone - visual only'),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _onParse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
                      ),
                      icon: _loading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
                          : const Icon(Icons.auto_awesome, size: 16),
                      label: Text('Parse', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_parsedExpense != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withAlpha(20),
              borderRadius: AppRadii.card,
              border: Border.all(color: AppColors.primaryContainer.withAlpha(80)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Text('AI Suggestion', style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _SuggestionRow(
                  label: 'Description',
                  value: _parsedExpense!.description,
                ),
                _SuggestionRow(
                  label: 'Amount',
                  value: '${_parsedExpense!.amount.toStringAsFixed(_parsedExpense!.currency.toUpperCase() == 'KWD' ? 3 : 2)} ${_parsedExpense!.currency}',
                ),
                _SuggestionRow(
                  label: 'Category',
                  value: _parsedExpense!.categoryName,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
