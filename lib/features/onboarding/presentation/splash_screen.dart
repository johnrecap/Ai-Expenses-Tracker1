import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _minDisplayTimer;
  bool _minDisplayDone = false;
  AuthState? _pendingAuthState;
  bool _settingsLoadRequested = false;
  final RepositoryRuntimeMode _runtimeMode = RepositoryRuntimeMode.fromEnvironment();

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
    final authState = _pendingAuthState ?? context.read<AuthBloc>().state;
    final settingsState = _readSettingsState();
    final destination = decideStartupDestination(
      authState,
      settingsState,
      runtimeMode: _runtimeMode,
    );
    switch (destination) {
      case StartupDestination.login:
        context.go(AppRoutes.login);
      case StartupDestination.onboarding:
        context.go(AppRoutes.onboardingLanguage);
      case StartupDestination.home:
        context.go(AppRoutes.home);
      case StartupDestination.retry:
      case StartupDestination.waiting:
        _requestSettingsLoadIfNeeded(authState, settingsState);
    }
  }

  SettingsState? _readSettingsState() {
    try {
      return context.read<SettingsCubit>().state;
    } catch (_) {
      return null;
    }
  }

  void _requestSettingsLoadIfNeeded(AuthState authState, SettingsState? settingsState) {
    if (authState is! AuthAuthenticated) {
      return;
    }
    if (settingsState is SettingsInitial && !_settingsLoadRequested) {
      _settingsLoadRequested = true;
      context.read<SettingsCubit>().loadSettings();
    }
  }

  @override
  void dispose() {
    _minDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasSettingsCubit = _readSettingsState() != null;
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) {
            return current is AuthAuthenticated ||
                current is AuthUnauthenticated ||
                current is AuthFailure;
          },
          listener: (context, state) {
            _pendingAuthState = state;
            _requestSettingsLoadIfNeeded(state, _readSettingsState());
            _maybeNavigate();
          },
        ),
        if (hasSettingsCubit)
          BlocListener<SettingsCubit, SettingsState>(
            listener: (context, state) {
              if (state is! SettingsInitial) _settingsLoadRequested = false;
              _maybeNavigate();
            },
          ),
      ],
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
                    child: Text(
                      l10n.appTitle,
                      style: const TextStyle(
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
                    l10n.appSubtitle,
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
                  if (hasSettingsCubit)
                    BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, settingsState) {
                        if (settingsState is SettingsFailure) {
                          return Column(
                            children: [
                              Text(
                                settingsState.message,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextButton(
                                onPressed: () => context.read<SettingsCubit>().loadSettings(),
                                child: Text(l10n.retry),
                              ),
                            ],
                          );
                        }
                        return Text(
                          l10n.splashInitializing,
                          style: AppTextStyles.labelCaps.copyWith(
                            color: AppColors.onSurfaceVariant.withAlpha(153),
                          ),
                        );
                      },
                    )
                  else
                    Text(
                      l10n.splashInitializing,
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

enum StartupDestination {
  waiting,
  login,
  onboarding,
  home,
  retry,
}

@visibleForTesting
StartupDestination decideStartupDestination(
  AuthState authState,
  SettingsState? settingsState, {
  RepositoryRuntimeMode runtimeMode = RepositoryRuntimeMode.localOnly,
}) {
  if (runtimeMode == RepositoryRuntimeMode.localOnly) {
    if (authState is AuthUnauthenticated || authState is AuthFailure) {
      return StartupDestination.login;
    }
    if (authState is! AuthAuthenticated) return StartupDestination.waiting;
    if (settingsState == null) return StartupDestination.home;
    if (settingsState is SettingsInitial ||
        settingsState is SettingsLoading ||
        settingsState is SettingsSaving) {
      return StartupDestination.waiting;
    }
    if (settingsState is SettingsFailure) return StartupDestination.retry;
    if (settingsState is SettingsSuccess) {
      return settingsState.settings.requiresOnboarding
          ? StartupDestination.onboarding
          : StartupDestination.home;
    }
    return StartupDestination.home;
  }

  if (authState is AuthUnauthenticated || authState is AuthFailure) {
    return StartupDestination.login;
  }
  if (authState is! AuthAuthenticated) return StartupDestination.waiting;
  if (settingsState == null ||
      settingsState is SettingsInitial ||
      settingsState is SettingsLoading ||
      settingsState is SettingsSaving) {
    return StartupDestination.waiting;
  }
  if (settingsState is SettingsFailure) return StartupDestination.retry;
  if (settingsState is SettingsSuccess) {
    return settingsState.settings.requiresOnboarding
        ? StartupDestination.onboarding
        : StartupDestination.home;
  }
  return StartupDestination.waiting;
}
