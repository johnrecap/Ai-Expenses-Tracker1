import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
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
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
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
                    title: 'Welcome Back',
                    subtitle: 'Log in to manage your financial insights.',
                    primaryButtonLabel: 'Log In',
                    showGoogleButton: true,
                    onGoogleSignIn: _onGoogleSignIn,
                    footerLabel: "Don't have an account?",
                    footerActionLabel: 'Sign up',
                    onFooterAction: () {
                      context.go(AppRoutes.signUp);
                    },
                    onPrimaryAction: _onLogin,
                    children: [
                      AuthTextField(
                        hintText: 'Email / \u0627\u0644\u0628\u0631\u064A\u062F \u0627\u0644\u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A',
                        prefixIcon: Icons.mail_outline,
                        controller: _emailController,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AuthTextField(
                        hintText: 'Password / \u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631',
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Enter your email first')),
                              );
                              return;
                            }
                            context.read<AuthBloc>().add(
                              AuthPasswordResetRequested(email),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password reset email sent if account exists')),
                            );
                          },
                          child: Text(
                            'Forgot password?',
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
                        'Secure private expense tracking.',
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
}
