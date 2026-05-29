import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';

class SegmentedModeControl extends StatelessWidget {
  const SegmentedModeControl({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.modes,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<String> modes;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppRadii.lg,
      ),
      child: Row(
        children: List.generate(modes.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadii.lg,
                ),
                child: Center(
                  child: Text(
                    modes[index],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
