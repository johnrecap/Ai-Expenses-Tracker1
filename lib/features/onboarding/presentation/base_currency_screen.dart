import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/app_background.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/features/onboarding/onboarding_cubit/onboarding_cubit.dart';
import 'package:expenses_tracker/app/routes.dart';

class BaseCurrencyScreen extends StatefulWidget {
  const BaseCurrencyScreen({super.key});

  @override
  State<BaseCurrencyScreen> createState() => _BaseCurrencyScreenState();
}

class _BaseCurrencyScreenState extends State<BaseCurrencyScreen> {
  String _selectedCurrency = 'EGP';

  static const _currencies = [
    _CurrencyOption(code: 'EGP', name: 'Egyptian Pound', flag: 'EG'),
    _CurrencyOption(code: 'USD', name: 'US Dollar', flag: 'US'),
    _CurrencyOption(code: 'EUR', name: 'Euro', flag: 'EU'),
    _CurrencyOption(code: 'AED', name: 'UAE Dirham', flag: 'AE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 20, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ProgressDot(isActive: false),
                        const SizedBox(width: 4),
                        _ProgressDot(isActive: true),
                        const SizedBox(width: 4),
                        _ProgressDot(isActive: false),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Base Currency',
                  style: AppTextStyles.displayMobile.copyWith(color: AppColors.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Select your primary currency.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _currencies.map((currency) {
                    final isSelected = _selectedCurrency == currency.code;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCurrency = currency.code),
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        fillColor: isSelected
                            ? AppColors.primaryContainer.withAlpha(25)
                            : AppColors.glassCardFill,
                        borderColor: isSelected ? AppColors.primary : AppColors.glassCardBorder,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(currency.flag, style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              currency.code,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: isSelected ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currency.name,
                              style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                _LivePreviewCard(selectedCurrency: _selectedCurrency),
                const SizedBox(height: AppSpacing.lg),
                GradientButton(
                  label: 'Continue',
                  onPressed: () {
                    context.read<OnboardingCubit>().setCurrency(_selectedCurrency);
                    context.go(AppRoutes.onboardingNotifications);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrencyOption {
  final String code;
  final String name;
  final String flag;
  const _CurrencyOption({required this.code, required this.name, required this.flag});
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
        borderRadius: AppRadii.pill,
      ),
    );
  }
}

class _LivePreviewCard extends StatelessWidget {
  const _LivePreviewCard({required this.selectedCurrency});
  final String selectedCurrency;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Live Preview', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
              const Spacer(),
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.secondaryContainer),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleText(text: '\$'),
                const SizedBox(width: 4),
                const Text('10.00', style: AppTextStyles.titleMedium),
                const SizedBox(width: 4),
                const Icon(Icons.swap_horiz, size: 18, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('485.50', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
                const SizedBox(width: 4),
                _CircleText(text: _getSymbol(selectedCurrency)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              'Estimated rate',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withAlpha(153)),
            ),
          ),
        ],
      ),
    );
  }

  static String _getSymbol(String code) {
    switch (code) {
      case 'EGP':
        return '\u00A3';
      case 'USD':
        return '\$';
      case 'EUR':
        return '\u20AC';
      case 'AED':
        return '\u062F';
      default:
        return '\$';
    }
  }
}

class _CircleText extends StatelessWidget {
  const _CircleText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
