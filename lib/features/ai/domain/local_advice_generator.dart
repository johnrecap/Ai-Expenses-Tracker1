import 'advice_summary.dart';

class LocalAdviceGenerator {
  const LocalAdviceGenerator();

  List<LocalAdvice> generate(AdviceSummary summary, {String locale = 'en'}) {
    final isArabic = locale.toLowerCase().startsWith('ar');
    final advice = <LocalAdvice>[];

    if (summary.budgetAmount > 0 && summary.budgetUsedPercent >= 100) {
      advice.add(
        LocalAdvice(
          id: 'local-budget-over',
          type: LocalAdviceType.budget,
          title: isArabic ? 'تخطيت الميزانية' : 'Budget is over limit',
          body: isArabic
              ? 'مصروفات الشهر وصلت ${_money(summary.totalSpent, summary.currency)}. راجع أكبر فئة وخفف المصروفات غير الضرورية.'
              : 'This month reached ${_money(summary.totalSpent, summary.currency)}. Review your top category and pause non-essential spending.',
          severity: LocalAdviceSeverity.high,
          createdAt: DateTime.now(),
        ),
      );
    } else if (summary.budgetAmount > 0 && summary.budgetUsedPercent >= 80) {
      advice.add(
        LocalAdvice(
          id: 'local-budget-near',
          type: LocalAdviceType.budget,
          title: isArabic ? 'قريب من حد الميزانية' : 'Close to budget limit',
          body: isArabic
              ? 'استخدمت ${summary.budgetUsedPercent.toStringAsFixed(0)}% من الميزانية. المتبقي ${_money(summary.budgetRemaining, summary.currency)}.'
              : 'You used ${summary.budgetUsedPercent.toStringAsFixed(0)}% of your budget. Remaining: ${_money(summary.budgetRemaining, summary.currency)}.',
          severity: LocalAdviceSeverity.medium,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (summary.topCategories.isNotEmpty) {
      final top = summary.topCategories.first;
      advice.add(
        LocalAdvice(
          id: 'local-top-category',
          type: LocalAdviceType.category,
          title: isArabic ? 'أكبر فئة هذا الشهر' : 'Top category this month',
          body: isArabic
              ? '${top.categoryName} تمثل ${top.percent.toStringAsFixed(0)}% من مصروفات الشهر. جرّب تقللها 10% الأسبوع الجاي.'
              : '${top.categoryName} is ${top.percent.toStringAsFixed(0)}% of this month. Try reducing it by 10% next week.',
          severity: LocalAdviceSeverity.low,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (summary.dailyAverage > 0) {
      advice.add(
        LocalAdvice(
          id: 'local-daily-average',
          type: LocalAdviceType.dailyAverage,
          title: isArabic ? 'متوسطك اليومي' : 'Daily average',
          body: isArabic
              ? 'متوسط الصرف اليومي ${_money(summary.dailyAverage, summary.currency)}. رقم صغير يوميًا يفرق في آخر الشهر.'
              : 'Your daily average is ${_money(summary.dailyAverage, summary.currency)}. A small daily cut can add up by month end.',
          severity: LocalAdviceSeverity.low,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (summary.recurringTotal > 0) {
      advice.add(
        LocalAdvice(
          id: 'local-recurring',
          type: LocalAdviceType.recurring,
          title: isArabic ? 'راجع المصروفات المتكررة' : 'Review recurring costs',
          body: isArabic
              ? 'المتكرر شهريًا حوالي ${_money(summary.recurringTotal, summary.currency)}. راجع الاشتراكات اللي مش بتستخدمها.'
              : 'Recurring costs are about ${_money(summary.recurringTotal, summary.currency)}. Check subscriptions you no longer use.',
          severity: LocalAdviceSeverity.medium,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (advice.isEmpty) {
      advice.add(
        LocalAdvice(
          id: 'local-empty',
          type: LocalAdviceType.general,
          title: isArabic ? 'ابدأ بتسجيل مصروفاتك' : 'Start tracking expenses',
          body: isArabic
              ? 'سجل كام مصروف خلال الأسبوع، وبعدها هنطلع لك نصائح محلية من بياناتك فقط.'
              : 'Add a few expenses this week, then local tips will be based only on your saved data.',
          severity: LocalAdviceSeverity.low,
          createdAt: DateTime.now(),
        ),
      );
    }

    return advice.take(4).toList(growable: false);
  }

  static String _money(double amount, String currency) {
    return '${amount.toStringAsFixed(2)} $currency';
  }
}

class LocalAdvice {
  const LocalAdvice({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.severity,
    required this.createdAt,
  });

  final String id;
  final LocalAdviceType type;
  final String title;
  final String body;
  final LocalAdviceSeverity severity;
  final DateTime createdAt;

  String get source => 'local';
}

enum LocalAdviceType { budget, category, dailyAverage, recurring, general }

enum LocalAdviceSeverity { low, medium, high }
