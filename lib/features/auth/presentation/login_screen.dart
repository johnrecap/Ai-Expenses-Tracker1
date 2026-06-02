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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      showAppToast(context, l10n.authEnterEmailPassword, isError: true);
      return;
    }
    context.read<AuthBloc>().add(
      AuthSignInRequested(email: email, password: password),
    );
  }

  void _onGoogleSignIn() {
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
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
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: Image.asset(
                      'assets/images/logo.png',
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AuthPanel(
                    title: l10n.loginTitle,
                    subtitle: l10n.loginSubtitle,
                    primaryButtonLabel: l10n.loginButton,
                    showGoogleButton: true,
                    googleButtonLabel: l10n.loginGoogleButton,
                    googleUnavailableMessage: l10n.authGoogleNotConfigured,
                    emailDividerLabel: l10n.authOrEmail,
                    onGoogleSignIn: _onGoogleSignIn,
                    footerLabel: l10n.loginFooterLabel,
                    footerActionLabel: l10n.signUpAction,
                    onFooterAction: () {
                      context.go(AppRoutes.signUp);
                    },
                    onPrimaryAction: _onLogin,
                    children: [
                      AuthTextField(
                        hintText: l10n.loginEmail,
                        prefixIcon: Icons.mail_outline,
                        controller: _emailController,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AuthTextField(
                        hintText: l10n.loginPassword,
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                            color: AppColors.outline,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () {
                            final email = _emailController.text.trim();
                            if (email.isEmpty) {
                              showAppToast(context, l10n.authEnterEmailFirst, isError: true);
                              return;
                            }
                            context.read<AuthBloc>().add(
                              AuthPasswordResetRequested(email),
                            );
                            showAppToast(context, l10n.authPasswordResetSent);
                          },
                          child: Text(
                            l10n.forgotPassword,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: AppColors.outline),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.securePrivateExpenseTracking,
                        style: AppTextStyles.labelCaps.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
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
