import 'package:flutter/material.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'transaction_tile.dart';

class TransactionSection extends StatelessWidget {
  const TransactionSection({
    super.key,
    required this.dateLabel,
    required this.expenses,
    this.onTransactionTap,
  });

  final String dateLabel;
  final List<Expense> expenses;
  final ValueChanged<Expense>? onTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.containerPadding,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            dateLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: expenses.asMap().entries.map((entry) {
              final isLast = entry.key == expenses.length - 1;
              return Column(
                children: [
                  TransactionTile(
                    expense: entry.value,
                    onTap: onTransactionTap != null
                        ? () => onTransactionTap!(entry.value)
                        : null,
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                      color: AppColors.surfaceContainerHigh,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
