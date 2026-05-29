import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';

class AiExpenseParsePanel extends StatefulWidget {
  const AiExpenseParsePanel({super.key});

  @override
  State<AiExpenseParsePanel> createState() => _AiExpenseParsePanelState();
}

class _AiExpenseParsePanelState extends State<AiExpenseParsePanel> {
  final _controller = TextEditingController();
  bool _showSuggestion = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                      onPressed: () => setState(() => _showSuggestion = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
                      ),
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: Text('Parse', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_showSuggestion) ...[
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
                _SuggestionRow(label: 'Merchant', value: 'The Avenues Mall'),
                _SuggestionRow(label: 'Amount', value: '25.000 KWD'),
                _SuggestionRow(label: 'Category', value: 'Shopping'),
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
            width: 72,
            child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
