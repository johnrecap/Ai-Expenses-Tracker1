import 'package:expense_repository/expense_repository.dart';

class AiContext {
  final DateTime now;
  final String? userId;
  final List<Category> categories;
  final List<CategoryAlias> categoryAliases;
  final List<Expense> expenses;
  final Budget? budget;
  final UserSettings? settings;
  final String defaultCurrency;
  final PaymentMethod defaultPaymentMethod;
  final String locale;

  const AiContext({
    required this.now,
    this.userId,
    this.categories = const [],
    this.categoryAliases = const [],
    this.expenses = const [],
    this.budget,
    this.settings,
    this.defaultCurrency = 'EGP',
    this.defaultPaymentMethod = PaymentMethod.cash,
    this.locale = 'en-US',
  });

  UserSettings get effectiveSettings {
    final s = settings;
    if (s != null) return s;
    return UserSettings.defaults(userId: userId ?? '').copyWith(
      baseCurrency: defaultCurrency,
      supportedCurrencies: [defaultCurrency],
      defaultPaymentMethod: defaultPaymentMethod,
    );
  }
}

class AiResponse {
  final String? description;
  final double? amount;
  final String? currency;
  final String? categoryId;
  final DateTime? date;
  final String? paymentMethod;
  final String? rawInput;
  final double confidence;

  const AiResponse({
    this.description,
    this.amount,
    this.currency,
    this.categoryId,
    this.date,
    this.paymentMethod,
    this.rawInput,
    this.confidence = 0,
  });

  bool get isParsed => amount != null && description != null;
}

class AiService {
  final String gatewayUrl;

  const AiService({this.gatewayUrl = ''});

  Future<AiResponse> parseExpenseText(String input, AiContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final words = input.trim().split(RegExp(r'\s+'));
    double? amount;
    String? description;

    for (final word in words) {
      final cleaned = word.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleaned.isNotEmpty) {
        amount = double.tryParse(cleaned);
        if (amount != null) break;
      }
    }

    final nonAmountWords = words
        .where((w) {
          final c = w.replaceAll(RegExp(r'[^0-9.]'), '');
          return c.isEmpty || double.tryParse(c) == null;
        })
        .join(' ');

    description = nonAmountWords.isNotEmpty ? nonAmountWords : input;

    return AiResponse(
      description: description,
      amount: amount,
      currency: context.defaultCurrency,
      date: context.now,
      paymentMethod: _detectPaymentMethod(input)?.storageValue,
      confidence: amount != null ? 0.8 : 0.3,
      rawInput: input,
    );
  }

  Future<AiResponse> parseExpense(String input, AiContext context) {
    return parseExpenseText(input, context);
  }

  Expense? parseExpenseToDraft(AiResponse response) {
    if (response.amount == null || response.description == null) return null;

    final cat = Category.empty.copyWith(
      categoryId: response.categoryId ?? 'other',
      name: response.categoryId ?? 'Other',
      icon: 'category',
      color: 0xFF9E9E9E,
    );

    return Expense(
      expenseId: '',
      amount: response.amount!,
      description: response.description!,
      category: cat,
      categoryId: cat.categoryId,
      categoryName: cat.name,
      categoryIcon: cat.icon,
      categoryColor: cat.color,
      currency: response.currency ?? 'USD',
      date: response.date ?? DateTime.now(),
      source: ExpenseSource.aiText,
      userId: '',
      paymentMethod: PaymentMethod.fromStorageValue(response.paymentMethod),
    );
  }

  PaymentMethod? _detectPaymentMethod(String input) {
    final normalized = input.toLowerCase();
    if (RegExp(r'\b(bank transfer|transfer|instapay|wire)\b').hasMatch(normalized) ||
        normalized.contains('تحويل') ||
        normalized.contains('انستاباي')) {
      return PaymentMethod.bankTransfer;
    }
    if (RegExp(r'\b(visa|card|credit|debit|mastercard)\b').hasMatch(normalized) ||
        normalized.contains('فيزا') ||
        normalized.contains('كارت') ||
        normalized.contains('بطاقة')) {
      return PaymentMethod.visa;
    }
    if (RegExp(
          r'\b(wallet|mobile wallet|vodafone cash|orange cash|etisalat cash)\b',
        ).hasMatch(normalized) ||
        normalized.contains('محفظ') ||
        normalized.contains('فودافون كاش') ||
        normalized.contains('اورنج كاش') ||
        normalized.contains('اتصالات كاش')) {
      return PaymentMethod.wallet;
    }
    if (RegExp(r'\b(cash|cashy)\b').hasMatch(normalized) ||
        normalized.contains('كاش') ||
        normalized.contains('نقد')) {
      return PaymentMethod.cash;
    }
    return null;
  }
}

class AiInsight {
  final String id;
  final String title;
  final String summary;
  final String severity;
  final String? relatedRoute;
  final DateTime generatedAt;

  const AiInsight({
    required this.id,
    required this.title,
    required this.summary,
    required this.severity,
    this.relatedRoute,
    required this.generatedAt,
  });
}

class AiRecommendation {
  final String id;
  final String title;
  final String body;
  final DateTime generatedAt;

  const AiRecommendation({
    required this.id,
    required this.title,
    required this.body,
    required this.generatedAt,
  });
}

class AiChatMessage {
  final String id;
  final String author;
  final String text;
  final String timestampLabel;
  final bool isUser;
  final DateTime timestamp;

  const AiChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.timestampLabel,
    required this.isUser,
    required this.timestamp,
  });
}
