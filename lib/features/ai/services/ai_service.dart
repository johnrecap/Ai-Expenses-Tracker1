import 'package:expense_repository/expense_repository.dart';
import 'ai_gateway_client.dart';

class AiService {
  final AiGatewayClient _client;

  AiService({required String gatewayUrl, AiGatewayClient? client})
      : _client = client ?? AiGatewayClient(baseUrl: gatewayUrl);

  Future<Map<String, dynamic>> parseExpense(String text) async {
    return _client.parseExpense(text);
  }

  Future<Map<String, dynamic>> extractReceipt(String imageBase64) async {
    return _client.extractReceipt(imageBase64);
  }

  Future<Map<String, dynamic>> getAdvice({required Map<String, double> categoryTotals, required double totalSpent}) async {
    return _client.getAdvice({
      'categoryTotals': categoryTotals,
      'totalSpent': totalSpent,
    });
  }

  Expense? parseExpenseToDraft(Map<String, dynamic> aiResponse) {
    try {
      final json = aiResponse['structuredJson'] as Map<String, dynamic>?;
      if (json == null) return null;
      final amount = (json['amount'] as num?)?.toDouble();
      if (amount == null || amount <= 0) return null;
      return Expense(
        expenseId: '',
        category: Category.empty.copyWith(name: json['category'] as String? ?? ''),
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        amount: amount,
        description: json['description'] as String? ?? '',
        paymentMethod: PaymentMethod.cash,
      );
    } catch (_) {
      return null;
    }
  }
}
