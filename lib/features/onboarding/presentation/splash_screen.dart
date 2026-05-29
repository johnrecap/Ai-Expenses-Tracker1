import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/app/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _minDisplayTimer;
  bool _minDisplayDone = false;
  AuthState? _pendingAuthState;

  @override
  void initState() {
    super.initState();
    _minDisplayTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _minDisplayDone = true);
      _maybeNavigate();
    });
  }

  void _maybeNavigate() {
    if (!mounted || !_minDisplayDone) return;
    final state = _pendingAuthState ?? context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      try {
        final settings = context.read<SettingsCubit>().state;
        if (settings is SettingsSuccess && !settings.settings.onboardingCompleted) {
          context.go(AppRoutes.onboardingLanguage);
          return;
        }
      } catch (_) {}
      context.go(AppRoutes.home);
    } else if (state is AuthUnauthenticated || state is AuthFailure) {
      context.go(AppRoutes.login);
    } else {
      _minDisplayTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) _maybeNavigate();
      });
    }
  }

  @override
  void dispose() {
    _minDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return current is AuthAuthenticated || current is AuthUnauthenticated || current is AuthFailure;
      },
      listener: (context, state) {
        _pendingAuthState = state;
        _maybeNavigate();
      },
      child: Scaffold(
        body: AppBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.xl,
                      border: Border.all(color: AppColors.glassCardBorder, width: 1),
                      gradient: const LinearGradient(
                        colors: [Color(0x3300E5FF), AppColors.glassCardFill],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 96,
                      height: 96,
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
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primaryGradientEnd, AppColors.primaryGradientStart],
                    ).createShader(bounds),
                    child: const Text(
                      'AI Expenses Tracker',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Intelligent Financial Clarity',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.onSurfaceVariant.withAlpha(204),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryFixedDim),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'INITIALIZING AI ENGINE',
                    style: AppTextStyles.labelCaps.copyWith(
                      color: AppColors.onSurfaceVariant.withAlpha(153),
                    ),
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
