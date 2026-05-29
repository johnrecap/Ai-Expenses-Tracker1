import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class GlassBottomSheet extends StatelessWidget {
  const GlassBottomSheet({
    super.key,
    required this.child,
    this.padding,
    this.showHandle = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.sheet,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: padding ?? AppSpacing.cardPadding,
          decoration: const BoxDecoration(
            color: AppColors.glassSheetFill,
            borderRadius: AppRadii.sheet,
            boxShadow: [AppShadows.modalSheet],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) ...[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: AppRadii.pill,
                    ),
                  ),
                ),
              ],
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
