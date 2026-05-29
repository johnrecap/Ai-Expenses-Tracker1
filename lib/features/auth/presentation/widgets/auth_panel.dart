import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_gradients.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';

class AuthPanel extends StatelessWidget {
  const AuthPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryButtonLabel,
    required this.onPrimaryAction,
    this.footerLabel,
    this.footerActionLabel,
    this.onFooterAction,
    this.showGoogleButton = false,
    this.onGoogleSignIn,
    required this.children,
    this.headerIcon,
  });

  final String title;
  final String subtitle;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryAction;
  final String? footerLabel;
  final String? footerActionLabel;
  final VoidCallback? onFooterAction;
  final bool showGoogleButton;
  final VoidCallback? onGoogleSignIn;
  final List<Widget> children;
  final Widget? headerIcon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (headerIcon != null) ...[
              Center(child: headerIcon),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              title,
              style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (showGoogleButton) ...[
              _GoogleButton(
                onPressed: onGoogleSignIn ?? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google auth not configured')),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'OR EMAIL',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            ...children,
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              height: 56,
              decoration: const BoxDecoration(
                gradient: AppGradients.primaryAction,
                borderRadius: AppRadii.pill,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPrimaryAction,
                  borderRadius: AppRadii.pill,
                  child: Center(
                    child: Text(
                      primaryButtonLabel,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (footerLabel != null || footerActionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    footerLabel ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (footerActionLabel != null) ...[
                    GestureDetector(
                      onTap: onFooterAction,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 4),
                        child: Text(
                          footerActionLabel!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
  });

  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.outline),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: AppColors.outline)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
  });

  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return _AuthTextField(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      controller: controller,
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.outlineVariant),
        padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
        shape: const StadiumBorder(),
        backgroundColor: AppColors.surfaceContainerLowest,
        foregroundColor: AppColors.onSurface,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Text(
                  'G',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Continue with Google',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
