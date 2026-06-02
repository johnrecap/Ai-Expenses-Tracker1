import '../../../core/ai/models/ai_parsed_expense.dart';
import '../data/ai_gateway_client.dart';
import '../data/ai_gateway_models.dart';

/// Compatibility wrapper for older widgets while the AI entry UI migrates to
/// [AiGatewayClient]. It does not read mobile `.env` files and never sends a
/// shared API key from Flutter.
class AiApiService {
  AiApiService({AiGatewayClient? gatewayClient})
    : _gatewayClient = gatewayClient ?? AiGatewayClient();

  final AiGatewayClient _gatewayClient;

  bool get isConfigured => true;

  Future<AiParsedExpense?> parseExpense(String input) async {
    try {
      return parseExpenseStrict(input);
    } on AiGatewayClientException {
      return null;
    }
  }

  Future<AiParsedExpense?> parseExpenseStrict(String input) async {
    final response = await _gatewayClient.parseExpense(
      AiGatewayParseTextRequest(
        input: input,
        now: DateTime.now(),
        locale: 'ar-EG',
        defaultCurrency: 'EGP',
        categories: const [],
      ),
    );
    final draft = response.draft;
    return AiParsedExpense(
      amount: draft.amount,
      currency: draft.currency,
      category: draft.categoryName,
      date: draft.date,
      note: draft.description,
      confidence: draft.confidence,
      missingFields: draft.missingFields,
      originalInput: input,
    );
  }

  Future<String?> getAdvice(String prompt) async {
    return null;
  }
}
