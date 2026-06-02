import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const paymentMethodOptions = <PaymentMethod>[
  PaymentMethod.cash,
  PaymentMethod.visa,
  PaymentMethod.wallet,
  PaymentMethod.bankTransfer,
];

String paymentMethodLabel(BuildContext context, PaymentMethod method) {
  final l10n = AppLocalizations.of(context);
  return switch (method) {
    PaymentMethod.cash => l10n?.paymentMethodCash ?? 'Cash',
    PaymentMethod.visa => l10n?.paymentMethodVisaCard ?? 'Visa/Card',
    PaymentMethod.wallet => l10n?.paymentMethodWallet ?? 'Wallet',
    PaymentMethod.bankTransfer => l10n?.paymentMethodBankTransfer ?? 'Bank Transfer',
  };
}

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    this.title,
    this.enabled = true,
  });

  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onChanged;
  final String? title;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTextStyles.labelCaps.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: paymentMethodOptions.map((method) {
            final selected = selectedMethod == method;
            return ChoiceChip(
              label: Text(paymentMethodLabel(context, method)),
              selected: selected,
              onSelected: enabled ? (_) => onChanged(method) : null,
              selectedColor: AppColors.primaryContainer,
              backgroundColor: AppColors.surfaceContainerHigh,
              disabledColor: AppColors.surfaceContainerHigh,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide.none,
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }
}
