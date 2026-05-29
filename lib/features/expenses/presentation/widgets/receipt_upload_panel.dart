import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';

class ReceiptUploadPanel extends StatefulWidget {
  const ReceiptUploadPanel({super.key});

  @override
  State<ReceiptUploadPanel> createState() => _ReceiptUploadPanelState();
}

class _ReceiptUploadPanelState extends State<ReceiptUploadPanel> {
  bool _isParsed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isParsed = true),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadii.card,
              border: Border.all(
                color: _isParsed ? AppColors.primaryContainer : AppColors.outlineVariant,
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _isParsed ? Icons.check_circle : Icons.receipt_long,
                  size: 48,
                  color: _isParsed ? AppColors.primary : AppColors.outline,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _isParsed ? 'Receipt parsed!' : 'Tap to upload receipt',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: _isParsed ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!_isParsed) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Camera & file picker are visual-only in this prototype',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_isParsed) ...[
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
                    Text('Parsed from receipt', style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _ParsedRow(label: 'Merchant', value: 'Carrefour Market'),
                _ParsedRow(label: 'Amount', value: '28.750 KWD'),
                _ParsedRow(label: 'Date', value: 'May 28, 2026'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ParsedRow extends StatelessWidget {
  const _ParsedRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant))),
          Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
