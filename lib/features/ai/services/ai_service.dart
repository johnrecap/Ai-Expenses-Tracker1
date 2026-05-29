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

  AiService({this.gatewayUrl = ''});

  Future<AiResponse> parseExpenseText(String input, AiContext context) async {
    await Future.delayed(const Duration(milliseconds: 500));
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
    return null;
  }
}

class MockAiService extends AiService {
  MockAiService() : super();

  Future<AiResponse> extractReceipt(String base64Image) async {
    return AiResponse(description: 'Receipt scanned', amount: 0, confidence: 0.5);
  }
}
