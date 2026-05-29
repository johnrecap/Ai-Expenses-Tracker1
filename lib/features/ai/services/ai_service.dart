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
    required this.now, this.userId, this.categories = const [],
    this.categoryAliases = const [], this.expenses = const [],
    this.budget, this.settings, this.defaultCurrency = 'EGP',
    this.defaultPaymentMethod = PaymentMethod.cash, this.locale = 'en-US',
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
    this.description, this.amount, this.currency, this.categoryId,
    this.date, this.paymentMethod, this.rawInput, this.confidence = 0,
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

    final nonAmountWords = words.where((w) {
      final c = w.replaceAll(RegExp(r'[^0-9.]'), '');
      return c.isEmpty || double.tryParse(c) == null;
    }).join(' ');

    description = nonAmountWords.isNotEmpty ? nonAmountWords : input;

    return AiResponse(
      description: description, amount: amount,
      currency: context.defaultCurrency,
      date: context.now, confidence: amount != null ? 0.8 : 0.3,
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
      paymentMethod: PaymentMethod.cash,
    );
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

class MockAiService extends AiService {
  const MockAiService() : super();

  Future<AiResponse> extractReceipt(String base64Image) async {
    return const AiResponse(description: 'Receipt scanned', amount: 0, confidence: 0.5);
  }

  Future<List<AiInsight>> getInsights() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      AiInsight(
        id: 'ai-1',
        title: 'Subscription Overlap Detected',
        summary: 'You have both Netflix and YouTube Premium. Consider consolidating to save 3.500 KWD/month.',
        severity: 'warning',
        relatedRoute: '/subscriptions',
        generatedAt: DateTime.now(),
      ),
      AiInsight(
        id: 'ai-2',
        title: 'Dining Spike This Month',
        summary: 'Food expenses are 22% higher than last month. The Avenues Mall and Talabat account for most of the increase.',
        severity: 'info',
        relatedRoute: '/expenses',
        generatedAt: DateTime.now(),
      ),
      AiInsight(
        id: 'ai-3',
        title: 'Goal On Track',
        summary: 'Your Vacation to Dubai goal is 75% complete, 2 months ahead of schedule.',
        severity: 'success',
        relatedRoute: '/goals',
        generatedAt: DateTime.now(),
      ),
      AiInsight(
        id: 'ai-4',
        title: 'AWS Bill Increase',
        summary: 'Your AWS subscription has increased 15% this year. Review unused resources to optimize costs.',
        severity: 'warning',
        relatedRoute: '/subscriptions',
        generatedAt: DateTime.now(),
      ),
    ];
  }

  Future<List<AiRecommendation>> getRecommendations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      AiRecommendation(
        id: 'rec-1',
        title: 'Reduce dining spend',
        body: 'Set a weekly food budget of 50 KWD to save up to 200 KWD/month.',
        generatedAt: DateTime.now(),
      ),
      AiRecommendation(
        id: 'rec-2',
        title: 'Consolidate subscriptions',
        body: 'Switch to an annual plan for YouTube Premium and save 15%.',
        generatedAt: DateTime.now(),
      ),
      AiRecommendation(
        id: 'rec-3',
        title: 'Boost savings',
        body: 'Increase your monthly savings allocation by 10% to reach your car fund goal faster.',
        generatedAt: DateTime.now(),
      ),
    ];
  }

  Future<List<AiChatMessage>> getChatHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      AiChatMessage(
        id: 'msg-1',
        author: 'AI Assistant',
        text: 'Hello! How can I help you with your finances today?',
        timestampLabel: '10:30 AM',
        isUser: false,
        timestamp: DateTime.now(),
      ),
      AiChatMessage(
        id: 'msg-2',
        author: 'You',
        text: 'Show me my spending breakdown for May',
        timestampLabel: '10:31 AM',
        isUser: true,
        timestamp: DateTime.now(),
      ),
      AiChatMessage(
        id: 'msg-3',
        author: 'AI Assistant',
        text: 'Here is your May spending: Total is 845.500 KWD. Top categories: Food (245.5 KWD), Transport (85 KWD), Shopping (100 KWD). Would you like to see the full report?',
        timestampLabel: '10:31 AM',
        isUser: false,
        timestamp: DateTime.now(),
      ),
      AiChatMessage(
        id: 'msg-4',
        author: 'You',
        text: 'How can I reduce my spending?',
        timestampLabel: '10:32 AM',
        isUser: true,
        timestamp: DateTime.now(),
      ),
      AiChatMessage(
        id: 'msg-5',
        author: 'AI Assistant',
        text: 'I noticed a few opportunities:\n1. Your YouTube Premium and Netflix overlap - saving 3.500 KWD/month\n2. Dining out is 22% above average - consider meal planning\n3. Your AWS bill has unused resources\n\nWould you like me to create a budget plan?',
        timestampLabel: '10:33 AM',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<AiChatMessage> sendChatMessage(String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return AiChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      author: 'AI Assistant',
      text: 'I received your message: "$text". I\'m currently in demo mode — connect the AI gateway for real responses.',
      timestampLabel: 'Now',
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
