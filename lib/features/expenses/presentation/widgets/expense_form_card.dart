import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';

class ExpenseFormCard extends StatelessWidget {
  const ExpenseFormCard({
    super.key,
    required this.merchantController,
    required this.amountController,
    this.categoryController,
    this.notesController,
    this.dateController,
    this.walletController,
    this.categories = const [],
    this.wallets = const [],
    this.selectedCategoryId,
    this.selectedWalletId,
    this.onCategoryChanged,
    this.onWalletChanged,
  });

  final TextEditingController merchantController;
  final TextEditingController amountController;
  final TextEditingController? categoryController;
  final TextEditingController? notesController;
  final TextEditingController? dateController;
  final TextEditingController? walletController;
  final List<String> categories;
  final List<String> wallets;
  final String? selectedCategoryId;
  final String? selectedWalletId;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<String>? onWalletChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(label: 'Merchant', child: _Input(controller: merchantController, hint: 'e.g. Starbucks')),
          const SizedBox(height: AppSpacing.md),
          _Field(label: 'Amount', child: _Input(controller: amountController, hint: '0.00', keyboardType: TextInputType.number)),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _Field(label: 'Category', child: _Dropdown(value: selectedCategoryId, items: categories, onChanged: onCategoryChanged)),
          ],
          if (wallets.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _Field(label: 'Wallet', child: _Dropdown(value: selectedWalletId, items: wallets, onChanged: onWalletChanged)),
          ],
          if (dateController != null) ...[
            const SizedBox(height: AppSpacing.md),
            _Field(label: 'Date', child: _Input(controller: dateController!, hint: 'Select date')),
          ],
          if (notesController != null) ...[
            const SizedBox(height: AppSpacing.md),
            _Field(label: 'Notes', child: _Input(controller: notesController!, hint: 'Optional', maxLines: 2)),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({required this.controller, required this.hint, this.keyboardType, this.maxLines = 1});
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.outline),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({this.value, required this.items, this.onChanged});
  final String? value;
  final List<String> items;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: AppRadii.pill,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged != null ? (v) { if (v != null) onChanged!(v); } : null,
        ),
      ),
    );
  }
}
