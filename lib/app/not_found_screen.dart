import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 80, color: AppColors.outlineVariant),
                const SizedBox(height: AppSpacing.lg),
                Text('Page Not Found', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface)),
                const SizedBox(height: AppSpacing.sm),
                Text("The page you're looking for doesn't exist or is not available yet.",
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: const Text('Go Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
