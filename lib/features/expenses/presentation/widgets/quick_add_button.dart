import 'package:flutter/material.dart';
import 'package:expenses_tracker/shared/animations/pulse_animation.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_gradients.dart';
import 'package:expenses_tracker/core/theme/app_shadows.dart';

/// {@template quick_add_button}
/// A floating quick-add button with a pulsing gradient background.
///
/// Tapping the button triggers [onTap]. The button pulses gently
/// to draw attention without being distracting.
/// {@endtemplate}
class QuickAddButton extends StatelessWidget {
  /// {@macro quick_add_button}
  const QuickAddButton({
    super.key,
    required this.onTap,
    this.icon = Icons.add,
    this.size = 56,
    this.tooltip,
  });

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  /// Icon to display inside the button.
  final IconData icon;

  /// Diameter of the circular button.
  final double size;

  /// Optional tooltip text.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = PulseAnimation(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: AppGradients.aiAction,
            shape: BoxShape.circle,
            boxShadow: [
              AppShadows.subtleTop,
              BoxShadow(
                color: Color(0x336833EA),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.onPrimary,
            size: size * 0.4,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    return button;
  }
}
