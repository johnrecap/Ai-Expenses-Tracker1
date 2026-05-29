import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 6,
    this.progressColor,
    this.backgroundColor,
    this.centerWidget,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final fillColor = progressColor ?? AppColors.primary;
    final bgColor = backgroundColor ?? AppColors.surfaceContainerHigh;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: bgColor,
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clampedProgress,
              strokeWidth: strokeWidth,
              color: fillColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          ?centerWidget,
          if (centerWidget == null)
            Text(
              '${(clampedProgress * 100).round()}%',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
