import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_gradients.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_bottom_sheet.dart';

class ExpenseFiltersSheet extends StatefulWidget {
  const ExpenseFiltersSheet({super.key});

  @override
  State<ExpenseFiltersSheet> createState() => _ExpenseFiltersSheetState();
}

class _ExpenseFiltersSheetState extends State<ExpenseFiltersSheet> {
  final _searchController = TextEditingController();
  double _amountRange = 1500;
  final _activeCategories = {'Dining', 'Transport'};

  static const _allCategories = [
    ('Dining', Icons.restaurant),
    ('Groceries', Icons.shopping_cart),
    ('Transport', Icons.directions_car),
    ('Housing', Icons.home),
    ('Entertainment', Icons.movie),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: GlassBottomSheet(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerPadding,
                AppSpacing.sm,
                AppSpacing.containerPadding,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surfaceContainerHigh),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel(label: 'Search'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.outline),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.outline),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel(label: 'Date Range'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Expanded(
                          child: _DateField(value: 'Oct 1, 2023'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text('-', style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline)),
                        ),
                        const Expanded(
                          child: _DateField(value: 'Oct 31, 2023'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _SectionLabel(label: 'Categories'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _allCategories.map((cat) {
                        final isActive = _activeCategories.contains(cat.$1);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isActive) {
                                _activeCategories.remove(cat.$1);
                              } else {
                                _activeCategories.add(cat.$1);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              gradient: isActive ? AppGradients.primaryAction : null,
                              color: isActive ? null : AppColors.glassCardFill,
                              borderRadius: AppRadii.pill,
                              border: isActive ? null : Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat.$2,
                                  size: 16,
                                  color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  cat.$1,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        const _SectionLabel(label: 'Amount Range'),
                        const Spacer(),
                        Text(
                          '\$0 - \$${_amountRange.toInt().toString()}+',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _amountRange,
                      min: 0,
                      max: 5000,
                      divisions: 50,
                      activeColor: AppColors.primaryFixedDim,
                      inactiveColor: AppColors.surfaceContainerHigh,
                      onChanged: (v) => setState(() => _amountRange = v),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerPadding,
                AppSpacing.md,
                AppSpacing.containerPadding,
                AppSpacing.xl,
              ),
              decoration: const BoxDecoration(
                color: AppColors.glassSheetFill,
                border: Border(
                  top: BorderSide(color: AppColors.surfaceContainerHigh, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _amountRange = 1500;
                          _activeCategories.clear();
                          _searchController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryContainer.withAlpha(100)),
                        padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text('Reset', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppGradients.primaryAction,
                        borderRadius: AppRadii.pill,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: AppRadii.pill,
                          child: const Center(
                            child: Text(
                              'Apply Filters',
                              style: TextStyle(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelCaps.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.outline),
        hintText: value,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
