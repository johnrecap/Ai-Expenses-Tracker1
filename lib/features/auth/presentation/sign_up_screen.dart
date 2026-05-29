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
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _nameController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
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
              child: AuthPanel(
                title: 'Create Account',
                subtitle: 'Join AI Expenses Tracker today.',
                primaryButtonLabel: 'Sign Up',
                footerLabel: 'Already have an account?',
                footerActionLabel: 'Log in',
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
                    hintText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    hintText: 'Email Address',
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'By signing up, you agree to our Terms & Privacy Policy.',
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
}
