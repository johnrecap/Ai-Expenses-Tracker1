import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';

class AiAssistantSheet extends StatelessWidget {
  const AiAssistantSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.48;
    return SizedBox(
      width: double.infinity,
      height: sheetHeight.clamp(360.0, 460.0).toDouble(),
      child: GlassBottomSheet(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerPadding,
                AppSpacing.sm,
                AppSpacing.containerPadding,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'AI Assistant',
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surfaceContainerHigh),
            Expanded(
              child: _buildUnavailableState(context),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerPadding,
                AppSpacing.sm,
                AppSpacing.containerPadding,
                AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.glassSheetFill,
                border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mic_none, size: 22, color: AppColors.outline),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Assistant chat is unavailable',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.outline),
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      size: 18,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailableState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'AI assistant is not available yet',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Chat will be enabled when it is connected to the real AI gateway. No demo replies are shown.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () {
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.push(AppRoutes.expensesNewText);
              },
              icon: const Icon(Icons.edit_note),
              label: const Text('Use AI text entry'),
            ),
          ],
        ),
      ),
    );
  }
}
