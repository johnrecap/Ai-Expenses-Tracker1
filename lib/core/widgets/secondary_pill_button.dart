import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SecondaryPillButton extends StatelessWidget {
  const SecondaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.isActive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.outlineVariant,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: isActive ? AppColors.primaryContainer.withAlpha(25) : Colors.transparent,
        foregroundColor: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
        minimumSize: Size(width ?? 0, 44),
        textStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(label),
    );
  }
}
