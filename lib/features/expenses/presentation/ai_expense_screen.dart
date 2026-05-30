import 'package:flutter/material.dart';
import 'package:expense_repository/expense_repository.dart';
import '../../../core/ai/models/ai_parsed_expense.dart';
import '../../ai/services/ai_api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/glass_card.dart';

/// شاشة إضافة مصروف بالذكاء الاصطناعي
///
/// تفتح من:
/// - الصفحة الرئيسية (زر ✨ AI)
/// - زر الـ + (اختيار AI)
class AiExpenseScreen extends StatefulWidget {
  const AiExpenseScreen({super.key});

  static const routeName = '/ai-expense';

  @override
  State<AiExpenseScreen> createState() => _AiExpenseScreenState();
}

class _AiExpenseScreenState extends State<AiExpenseScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isProcessing = false;
  AiParsedExpense? _parsedResult;
  final _aiApiService = AiApiService();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'إضافة بالذكاء الاصطناعي',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // عنوان
                Text(
                  'اكتب مصروفك بالعربي أو الإنجليزي',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // أمثلة
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: AppRadii.lg,
                    border: Border.all(
                      color: AppColors.outlineVariant.withAlpha(77),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExample('🍔', '200 جنيه أكل امبارح'),
                      _buildExample('🚕', '50 جنيه مواصلات النهاردة'),
                      _buildExample('🛒', 'اشتريت هدوم بـ 500 من المحل'),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // حقل الإدخال
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: AppRadii.xl,
                    border: Border.all(
                      color: AppColors.outlineVariant.withAlpha(77),
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.onSurface,
                    ),
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'اكتب هنا...',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.outline,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.mic,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          // TODO: Voice input
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // زر المعالجة – uses AI secondary accent gradient per design system
                GradientButton(
                  label: _isProcessing ? 'جاري المعالجة...' : '✨ فهم المصروف',
                  onPressed: _isProcessing ? () {} : _processInput,
                  gradient: AppGradients.secondaryAi,
                  prefixIcon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome, color: Colors.white),
                ),

                const SizedBox(height: AppSpacing.lg),

                // النتيجة
                if (_parsedResult != null)
                  _ParsedExpenseCard(
                    result: _parsedResult!,
                    onConfirm: () {
                      // TODO: Save expense
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم حفظ المصروف!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    onEdit: () {
                      _showEditDialog(context);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExample(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processInput() async {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _parsedResult = null;
    });

    final result = await _aiApiService.parseExpense(input);

    setState(() {
      _isProcessing = false;
      _parsedResult = result ?? AiParsedExpense(
        amount: null,
        currency: null,
        category: null,
        date: null,
        note: input,
        confidence: 0.0,
        missingFields: const ['amount', 'category', 'date'],
        originalInput: input,
      );
    });
  }

  void _showEditDialog(BuildContext context) {
    final amountController = TextEditingController(text: _parsedResult?.amount?.toString() ?? '');
    final categoryController = TextEditingController(text: _parsedResult?.category ?? '');
    final dateController = TextEditingController(text: _parsedResult?.date?.toIso8601String().split('T').first ?? '');
    final noteController = TextEditingController(text: _parsedResult?.note ?? '');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المصروف'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'المبلغ'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'الفئة'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'التاريخ (YYYY-MM-DD)'),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'الملاحظات'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _parsedResult = AiParsedExpense(
                  amount: double.tryParse(amountController.text),
                  currency: _parsedResult?.currency ?? 'EGP',
                  category: categoryController.text.isEmpty ? null : categoryController.text,
                  date: dateController.text.isEmpty ? null : DateTime.tryParse(dateController.text),
                  note: noteController.text.isEmpty ? null : noteController.text,
                  confidence: 1.0,
                  missingFields: const [],
                  originalInput: _parsedResult?.originalInput ?? '',
                );
              });
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

/// بطاقة عرض المصروف المفهوم
class _ParsedExpenseCard extends StatelessWidget {
  final AiParsedExpense result;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;

  const _ParsedExpenseCard({
    required this.result,
    required this.onConfirm,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      fillColor: AppColors.surfaceContainerLowest,
      borderColor: AppColors.outlineVariant.withAlpha(102),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✨ فهمت مصروفك!',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFieldRow('💰 المبلغ', '${result.amount?.toString() ?? '???'} ${result.currency ?? ''}'),
          _buildFieldRow('📁 الفئة', result.category ?? '???'),
          _buildFieldRow('📅 التاريخ', result.date?.toString() ?? '???'),
          _buildFieldRow('📝 الملاحظات', result.note ?? '???'),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'تأكيد',
                  onPressed: onConfirm,
                  height: 56,
                  prefixIcon: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('تعديل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.outlineVariant.withAlpha(128)),
                    shape: const StadiumBorder(),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withAlpha(26),
              borderRadius: AppRadii.md,
            ),
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
