import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/ai/models/ai_parsed_expense.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';

/// {@template ai_expense_preview}
/// Displays a parsed expense from natural-language input with a
/// confidence indicator and missing-field warnings.
///
/// Used inside the chat flow when the user types an expense like
/// "I spent 50 EGP on lunch yesterday".
/// {@endtemplate}
class AiExpensePreview extends StatefulWidget {
  /// {@macro ai_expense_preview}
  const AiExpensePreview({
    super.key,
    required this.parsedExpense,
    this.onConfirm,
    this.onEdit,
  });

  /// The parsed expense data from the AI parser.
  final AiParsedExpense parsedExpense;

  /// Called when the user confirms and wants to save the expense.
  final VoidCallback? onConfirm;

  /// Called when the user wants to edit the parsed expense.
  final VoidCallback? onEdit;

  @override
  State<AiExpensePreview> createState() => _AiExpensePreviewState();
}

class _AiExpensePreviewState extends State<AiExpensePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expense = widget.parsedExpense;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadii.card,
            border: Border.all(color: AppColors.surfaceContainerHigh),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with confidence badge
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.aiGradientStart,
                          AppColors.aiGradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      isRTL ? 'معاينة المصروف' : 'Expense Preview',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  _ConfidenceBadge(confidence: expense.confidence),
                ],
              ),
              const Divider(height: AppSpacing.lg),

              // Parsed fields
              _FieldRow(
                label: isRTL ? 'المبلغ' : 'Amount',
                value: expense.amount != null
                    ? '${expense.amount!.toStringAsFixed(2)} ${expense.currency ?? 'EGP'}'
                    : null,
                icon: Icons.attach_money,
              ),
              _FieldRow(
                label: isRTL ? 'الفئة' : 'Category',
                value: expense.category,
                icon: Icons.category_outlined,
              ),
              _FieldRow(
                label: isRTL ? 'التاريخ' : 'Date',
                value: expense.date != null
                    ? _formatDate(expense.date!)
                    : null,
                icon: Icons.calendar_today_outlined,
              ),
              _FieldRow(
                label: isRTL ? 'الملاحظات' : 'Note',
                value: expense.note,
                icon: Icons.notes_outlined,
              ),

              // Missing fields warning
              if (expense.missingFields.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withAlpha(80),
                    borderRadius: AppRadii.md,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          isRTL
                              ? 'حقول ناقصة: ${expense.missingFields.join(', ')}'
                              : 'Missing: ${expense.missingFields.join(', ')}',
                          style: AppTextStyles.labelCaps.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(isRTL ? 'تعديل' : 'Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurface,
                        side: const BorderSide(color: AppColors.outlineVariant),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.onConfirm,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(isRTL ? 'تأكيد' : 'Confirm'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// A single row in the expense preview showing a label + value pair.
class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    this.value,
    required this.icon,
  });

  final String label;
  final String? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.outline),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual confidence indicator with color coding.
class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final (color, label) = _confidenceInfo(isRTL);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: AppRadii.pill,
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelCaps.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (Color, String) _confidenceInfo(bool isRTL) {
    if (confidence >= 0.8) {
      return (
        AppColors.primary,
        isRTL ? 'ثقة عالية' : 'High'
      );
    } else if (confidence >= 0.5) {
      return (
        const Color(0xFFE8A838),
        isRTL ? 'متوسط' : 'Medium'
      );
    }
    return (
      AppColors.error,
      isRTL ? 'منخفض' : 'Low'
    );
  }
}
