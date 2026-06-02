import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/features/expenses/presentation/widgets/segmented_mode_control.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddExpenseReceiptScreen extends StatelessWidget {
  const AddExpenseReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.expenses);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Receipt',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedModeControl(
                  selectedIndex: 2,
                  modes: const ['Quick', 'AI Text', 'Receipt'],
                  onChanged: (index) => _navigateMode(context, index),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: AppColors.onSurfaceVariant,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Receipt scanning is not available yet',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'This screen is disabled until real receipt OCR is connected. Use Quick Add or AI Text to add the expense now.',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GradientButton(
                        label: 'Open Quick Add',
                        prefixIcon: const Icon(Icons.add, color: AppColors.onPrimary, size: 18),
                        onPressed: () => context.go(AppRoutes.expensesNewQuick),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton.icon(
                        onPressed: () => context.go(AppRoutes.expensesNewText),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Use AI Text'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateMode(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.expensesNewQuick);
      case 1:
        context.go(AppRoutes.expensesNewText);
      default:
        break;
    }
  }
}
