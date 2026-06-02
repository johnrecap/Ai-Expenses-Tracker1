import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ReceiptUploadPanel extends StatelessWidget {
  const ReceiptUploadPanel({
    super.key,
    this.onManualEntry,
  });

  final VoidCallback? onManualEntry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppRadii.card,
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.receipt_long,
                size: 48,
                color: AppColors.outline,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Receipt scanning is not available yet',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Use Quick Add or AI Text until real receipt OCR is connected.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
                textAlign: TextAlign.center,
              ),
              if (onManualEntry != null) ...[
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: onManualEntry,
                  icon: const Icon(Icons.add),
                  label: const Text('Open manual entry'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
