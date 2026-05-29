import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/features/security/cubit/app_lock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: BlocConsumer<AppLockCubit, AppLockState>(
            listener: (context, state) {
              if (state.message != null && state.message!.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.containerPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock, size: 40, color: AppColors.primary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Expense Tracker Locked',
                          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Enter your PIN to continue',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextField(
                          controller: _pinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 8,
                          enabled: !state.isBusy,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleMedium.copyWith(letterSpacing: 8),
                          decoration: InputDecoration(
                            hintText: '••••',
                            hintStyle: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.outlineVariant,
                              letterSpacing: 8,
                            ),
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          onSubmitted: (_) => _unlockWithPin(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        GradientButton(
                          label: state.isBusy ? 'Verifying...' : 'Unlock',
                          onPressed: state.isBusy ? () {} : () => _unlockWithPin(),
                        ),
                        if (state.biometricEnabled) ...[
                          const SizedBox(height: AppSpacing.md),
                          TextButton.icon(
                            onPressed: state.isBusy ? null : _unlockWithBiometrics,
                            icon: const Icon(Icons.fingerprint, color: AppColors.primary),
                            label: Text(
                              'Use Biometrics',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _unlockWithPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;
    final unlocked = await context.read<AppLockCubit>().unlockWithPin(pin);
    if (unlocked) _pinController.clear();
  }

  Future<void> _unlockWithBiometrics() async {
    await context.read<AppLockCubit>().unlockWithBiometrics();
  }
}
