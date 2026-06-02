import 'dart:async';

import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

void showAppToast(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    return;
  }

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      final top = MediaQuery.viewPaddingOf(context).top + AppSpacing.md;
      return PositionedDirectional(
        top: top,
        start: AppSpacing.containerPadding,
        end: AppSpacing.containerPadding,
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isError ? AppColors.error : AppColors.onSurface,
              borderRadius: AppRadii.card,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);

  var effectiveDuration = duration;
  assert(() {
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      effectiveDuration = Duration.zero;
    }
    return true;
  }());

  if (effectiveDuration == Duration.zero) {
    scheduleMicrotask(() {
      if (entry.mounted) entry.remove();
    });
    return;
  }

  unawaited(
    Future<void>.delayed(effectiveDuration).then((_) {
      if (entry.mounted) entry.remove();
    }),
  );
}
