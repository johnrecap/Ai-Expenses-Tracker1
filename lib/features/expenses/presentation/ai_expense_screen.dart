import 'package:flutter/material.dart';
import 'package:expense_repository/expense_repository.dart';
import '../../../core/ai/models/ai_parsed_expense.dart';

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

class _AiExpenseScreenState extends State<AiExpenseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _textController = TextEditingController();
  bool _isProcessing = false;
  AiParsedExpense? _parsedResult;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'إضافة بالذكاء الاصطناعي',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // خلفية متحركة
          _AnimatedBackground(),
          
          // المحتوى
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // عنوان متحرك
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                      ),
                    ),
                    child: const Text(
                      'اكتب مصروفك بالعربي أو الإنجليزي',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // أمثلة
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(13),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyan.withAlpha(77),
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
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // حقل الإدخال
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(13),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.cyan.withAlpha(77),
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'اكتب هنا...',
                          hintStyle: TextStyle(
                            color: Colors.white.withAlpha(100),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.mic,
                              color: Colors.cyan,
                            ),
                            onPressed: () {
                              // TODO: Voice input
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // زر المعالجة
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _processInput,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          _isProcessing ? 'جاري المعالجة...' : '✨ فهم المصروف',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // النتيجة
                  if (_parsedResult != null)
                    Expanded(
                      child: _ParsedExpenseCard(
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
                          // TODO: Edit expense
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
            style: TextStyle(
              color: Colors.cyan.withAlpha(204),
              fontSize: 14,
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
    });

    // TODO: Call AI parser
    // محاكاة للـ parsing
    await Future<void>.delayed(const Duration(seconds: 1));

    setState(() {
      _isProcessing = false;
      _parsedResult = AiParsedExpense(
        amount: 200,
        currency: 'EGP',
        category: 'food',
        date: DateTime.now(),
        note: input,
        confidence: 0.95,
        missingFields: const [],
        originalInput: input,
      );
    });
  }
}

/// خلفية متحركة
class _AnimatedBackground extends StatefulWidget {
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0A0E21),
                  const Color(0xFF1A1F3D),
                  _controller.value,
                )!,
                Color.lerp(
                  const Color(0xFF1A1F3D),
                  const Color(0xFF0A0E21),
                  _controller.value,
                )!,
              ],
            ),
          ),
        );
      },
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyan.withAlpha(77),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withAlpha(26),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ فهمت مصروفك!',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldRow('💰 المبلغ', '${result.amount?.toString() ?? '???'} ${result.currency ?? ''}'),
          _buildFieldRow('📁 الفئة', result.category ?? '???'),
          _buildFieldRow('📅 التاريخ', result.date?.toString() ?? '???'),
          _buildFieldRow('📝 الملاحظات', result.note ?? '???'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check),
                  label: const Text('تأكيد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.white.withAlpha(77)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.cyan.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.cyan,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
