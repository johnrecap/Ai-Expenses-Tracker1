import 'language_detector.dart';

/// {@template ai_prompts}
/// Centralized collection of all AI service prompts used across the app.
///
/// Prompts are generated dynamically based on user input, detected language,
/// and available context. All methods return plain strings ready to be sent
/// to the AI gateway (Cloudflare Worker).
/// {@endtemplate}
class AiPrompts {
  /// Creates an [AiPrompts] instance.
  ///
  /// [languageDetector] is used to determine the prompt language.
  const AiPrompts({
    required this.languageDetector,
  });

  /// The language detector used to decide Arabic vs. English prompts.
  final LanguageDetector languageDetector;

  /// Available expense categories for the AI parser.
  static const List<String> _categories = <String>[
    'food',
    'transport',
    'shopping',
    'bills',
    'entertainment',
    'health',
    'other',
  ];

  /// Generates the parser prompt for a given [userInput].
  ///
  /// The prompt instructs the AI to extract:
  /// - amount (number or null)
  /// - currency ("EGP", "USD", or null)
  /// - category (one of [_categories] or null)
  /// - date ("YYYY-MM-DD" or null)
  /// - note (string or null)
  /// - confidence (0.0 to 1.0)
  /// - missingFields (list of missing field names)
  ///
  /// The prompt language matches the detected language of [userInput].
  String parser(String userInput) {
    final isAr = languageDetector.isArabic(userInput);
    final categoriesList = _categories.join(', ');

    if (isAr) {
      return '''أنت مساعد ذكي لتحليل المصاريف. العميل كتب:
"$userInput"

المطلوب:
1. استخرج: المبلغ، العملة، التاريخ، الملاحظات
2. الفئات المتاحة: $categoriesList
3. اللغة: ar
4. لو مش متأكد من حاجة، حط null
5. الـ confidence يبين قديم التأكد

الرد بـ JSON فقط:
{
  "amount": number أو null,
  "currency": "EGP" أو "USD" أو null,
  "category": "string" أو null,
  "date": "YYYY-MM-DD" أو null,
  "note": "string" أو null,
  "confidence": 0.0 إلى 1.0,
  "missingFields": ["amount", "category", ...]
}''';
    }

    return '''You are a smart expense parsing assistant. The user wrote:
"$userInput"

Instructions:
1. Extract: amount, currency, date, note
2. Available categories: $categoriesList
3. Language: en
4. If unsure about any field, use null
5. Provide a confidence score (0.0 to 1.0)

Reply with JSON only:
{
  "amount": number or null,
  "currency": "EGP" or "USD" or null,
  "category": "string" or null,
  "date": "YYYY-MM-DD" or null,
  "note": "string" or null,
  "confidence": 0.0 to 1.0,
  "missingFields": ["amount", "category", ...]
}''';
  }

  /// Generates the advisor prompt based on user spending data.
  ///
  /// [monthlyTotal] — total expenses for the current month.
  /// [categoryBreakdown] — map of category name to total amount.
  /// [monthlyBudget] — user's monthly budget, or null if not set.
  /// [dailyAverage] — average daily spending for the current month.
  /// [language] — "ar" or "en".
  String advisor({
    required double monthlyTotal,
    required Map<String, double> categoryBreakdown,
    required double? monthlyBudget,
    required double dailyAverage,
    required String language,
  }) {
    final categoriesJson = categoryBreakdown.entries
        .map((e) => '  "${e.key}": ${e.value}')
        .join(',\n');
    final budgetText = monthlyBudget != null
        ? monthlyBudget.toStringAsFixed(2)
        : (language == 'ar' ? 'غير محدد' : 'Not set');

    if (language == 'ar') {
      return '''أنت مستشار مالي ذكي. بيانات العميل:
- إجمالي المصاريف الشهرية: ${monthlyTotal.toStringAsFixed(2)} EGP
- المصاريف بحسب الفئة:
{
$categoriesJson
}
- الميزانية الشهرية: $budgetText EGP
- المتوسط اليومي: ${dailyAverage.toStringAsFixed(2)} EGP

المطلوب:
1. انشئ رؤية عن المصاريف
2. قدم نصيحة قابلة للتطبيق
3. اذكر التوفير المحتمل بالجنيه
4. اللغة: ar

الرد بـ JSON:
{
  "insights": [
    {
      "title": "...",
      "summary": "...",
      "severity": "low|medium|high",
      "potentialSavings": 0.0
    }
  ],
  "recommendations": [
    {
      "title": "...",
      "body": "...",
      "potentialSavings": 0.0
    }
  ]
}''';
    }

    return '''You are a smart financial advisor. User data:
- Monthly total expenses: ${monthlyTotal.toStringAsFixed(2)} EGP
- Category breakdown:
{
$categoriesJson
}
- Monthly budget: $budgetText EGP
- Daily average: ${dailyAverage.toStringAsFixed(2)} EGP

Instructions:
1. Generate an insight about spending patterns
2. Provide an actionable recommendation
3. Mention potential savings in EGP
4. Language: en

Reply with JSON:
{
  "insights": [
    {
      "title": "...",
      "summary": "...",
      "severity": "low|medium|high",
      "potentialSavings": 0.0
    }
  ],
  "recommendations": [
    {
      "title": "...",
      "body": "...",
      "potentialSavings": 0.0
    }
  ]
}''';
  }

  /// Generates a smart completion prompt to fill missing fields.
  ///
  /// [partialExpense] — map of already-known fields.
  /// [missingFields] — list of field names that need to be inferred.
  /// [language] — "ar" or "en".
  String smartCompletion({
    required Map<String, dynamic> partialExpense,
    required List<String> missingFields,
    required String language,
  }) {
    final knownJson = partialExpense.entries
        .map((e) => '  "${e.key}": ${e.value is String ? '"${e.value}"' : e.value}')
        .join(',\n');
    final missingList = missingFields.map((f) => '"$f"').join(', ');

    if (language == 'ar') {
      return '''أنت مساعد ذكي لتكميل بيانات المصاريف.

البيانات المعروفة:
{
$knownJson
}

الحقول الناقصة: [$missingList]

المطلوب:
1. حاول تخمين الحقول الناقصة بناءً على السياق
2. لو مش متأكد، حط null
3. الرد بـ JSON فقط

الرد:
{
${missingFields.map((f) => '  "$f": value أو null').join(',\n')}
}''';
    }

    return '''You are a smart expense completion assistant.

Known data:
{
$knownJson
}

Missing fields: [$missingList]

Instructions:
1. Infer the missing fields based on context
2. If unsure, use null
3. Reply with JSON only

Reply:
{
${missingFields.map((f) => '  "$f": value or null').join(',\n')}
}''';
  }

  /// Generates a voice transcription cleanup prompt.
  ///
  /// [rawTranscription] — the raw text from speech-to-text.
  /// [language] — "ar" or "en".
  String voiceCleanup(String rawTranscription, String language) {
    if (language == 'ar') {
      return r'''نظف النص التالي اللي جاي من التعرف على الصوت:
"$rawTranscription"

المطلوب:
1. صحح الأخطاء الإملائية والنحوية
2. حول الأرقام المكتوبة حروف لأرقام (مثلاً "خمسين" إلى 50)
3. حافظ على المعنى الأصلي
4. الرد بالنص النظيف فقط، بدون أي تعليقات''';
    }

    return r'''Clean up the following speech-to-text transcription:
"$rawTranscription"

Instructions:
1. Fix spelling and grammar errors
2. Convert written-out numbers to digits (e.g., "fifty" to 50)
3. Preserve the original meaning
4. Reply with the clean text only, no extra comments''';
  }
}
