import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.threshold = 0,
    this.thresholdColor,
  });

  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final double threshold;
  final Color? thresholdColor;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final fillColor = clampedProgress >= threshold && threshold > 0
        ? thresholdColor ?? AppColors.error
        : progressColor ?? AppColors.primary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerHigh,
        borderRadius: AppRadii.pill,
      ),
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: clampedProgress,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: AppRadii.pill,
          ),
        ),
      ),
    );
  }
}
