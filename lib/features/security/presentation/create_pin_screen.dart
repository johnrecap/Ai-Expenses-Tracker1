import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/features/security/cubit/app_lock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePinScreen extends StatefulWidget {
  final bool changeExistingPin;
  final bool popOnSave;

  const CreatePinScreen({
    this.changeExistingPin = false,
    this.popOnSave = true,
    super.key,
  });

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: Text(
          widget.changeExistingPin ? 'Change PIN' : 'Create PIN',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface),
        ),
      ),
      body: AppBackground(
        child: BlocConsumer<AppLockCubit, AppLockState>(
          listener: (context, state) {
            if (state.message != null && state.message!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.containerPadding),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline, size: 36, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.changeExistingPin ? 'Enter your new PIN' : 'Create your PIN',
                      style: AppTextStyles.headlineMedium.copyWith(color: AppColors.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.changeExistingPin
                          ? 'Choose a new 4-8 digit PIN'
                          : 'Choose a 4-8 digit PIN to secure your app',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.titleMedium.copyWith(letterSpacing: 6),
                            decoration: InputDecoration(
                              labelText: 'PIN',
                              labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                              hintText: '••••',
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
                            validator: _validatePin,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _confirmPinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.titleMedium.copyWith(letterSpacing: 6),
                            decoration: InputDecoration(
                              labelText: 'Confirm PIN',
                              labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                              hintText: '••••',
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
                            validator: _validateConfirmation,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GradientButton(
                      label: state.isBusy
                          ? 'Saving...'
                          : widget.changeExistingPin
                              ? 'Save New PIN'
                              : 'Enable App Lock',
                      onPressed: state.isBusy ? null : _savePin,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validatePin(String? value) {
    final pin = value?.trim() ?? '';
    if (!RegExp(r'^\d{4,8}$').hasMatch(pin)) {
      return 'PIN must be 4 to 8 digits';
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    final confirmation = value?.trim() ?? '';
    if (confirmation != _pinController.text.trim()) {
      return 'PINs do not match';
    }
    return null;
  }

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AppLockCubit>();
    final pin = _pinController.text.trim();
    final saved = widget.changeExistingPin
        ? await cubit.changePin(pin)
        : await cubit.enableLockWithPin(pin);
    if (!mounted || !saved || !widget.popOnSave) return;
    Navigator.pop(context, true);
  }
}
