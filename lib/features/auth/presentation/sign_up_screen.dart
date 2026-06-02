import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/app_toast.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'widgets/auth_panel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _nameController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      showAppToast(context, l10n.authEnterEmailPassword, isError: true);
      return;
    }
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: email,
        password: password,
        displayName: displayName.isNotEmpty ? displayName : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.splash);
        } else if (state is AuthFailure) {
          showAppToast(context, _localizedAuthMessage(l10n, state.message), isError: true);
        }
      },
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerPadding,
                vertical: AppSpacing.xl,
              ),
              child: AuthPanel(
                title: l10n.signUpTitle,
                subtitle: l10n.signUpSubtitle,
                primaryButtonLabel: l10n.signUpButton,
                footerLabel: l10n.signUpFooterLabel,
                footerActionLabel: l10n.loginAction,
                onFooterAction: () {
                  context.go(AppRoutes.login);
                },
                onPrimaryAction: _onSignUp,
                headerIcon: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                children: [
                  AuthTextField(
                    hintText: l10n.signUpFullName,
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    hintText: l10n.signUpEmail,
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    hintText: l10n.signUpPassword,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.signUpTermsPrivacy,
                    style: AppTextStyles.labelCaps.copyWith(
                      color: AppColors.onSurfaceVariant.withAlpha(179),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _localizedAuthMessage(AppLocalizations l10n, String message) {
    switch (message) {
      case 'The email address is not valid.':
        return l10n.authErrorInvalidEmail;
      case 'This account has been disabled.':
        return l10n.authErrorUserDisabled;
      case 'Email or password is incorrect.':
        return l10n.authErrorWrongPassword;
      case 'An account already exists for this email.':
        return l10n.authErrorEmailInUse;
      case 'Password must be at least 6 characters.':
        return l10n.authErrorWeakPasswordMin;
      case 'Check your internet connection.':
        return l10n.authErrorNetwork;
      case 'This sign-in method is not enabled.':
        return l10n.authErrorOperationNotAllowed;
      case 'Too many attempts. Try again later.':
        return l10n.authErrorTooManyRequests;
      default:
        return l10n.authErrorGeneral;
    }
  }
}
