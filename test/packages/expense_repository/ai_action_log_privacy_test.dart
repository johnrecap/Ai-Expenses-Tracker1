import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiActionLogPrivacy', () {
    test('removes raw prompt output and financial structured fields', () {
      final safe = AiActionLogPrivacy.sanitize(
        AiActionLog(
          actionId: 'action-1',
          userId: 'user-1',
          actionType: 'parse_text',
          input: 'Spent 250 EGP at merchant@example.com',
          output: 'Parsed merchant and amount',
          structuredJson: const {
            'intent': 'add_expense',
            'amount': 250,
            'description': 'Lunch at Merchant',
            'merchant': 'Merchant',
            'walletAccountId': 'wallet-1',
            'confidence': 0.92,
            'missingFields': ['wallet', 'amount'],
            'errorCode': 'quota_exceeded',
          },
          success: false,
          error: 'Provider failed with raw prompt',
          quotaUsed: 2,
          createdAt: DateTime.utc(2026, 5, 31),
        ),
      );

      expect(safe.input, isEmpty);
      expect(safe.output, isNull);
      expect(safe.error, 'AI request failed.');
      expect(safe.structuredJson, {
        'intent': 'add_expense',
        'confidence': 0.92,
        'missingFields': ['wallet', 'amount'],
        'errorCode': 'quota_exceeded',
      });
      expect(safe.structuredJson, isNot(contains('amount')));
      expect(safe.structuredJson, isNot(contains('merchant')));
      expect(safe.structuredJson, isNot(contains('walletAccountId')));
    });

    test('local repository stores sanitized logs only', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalAiActionLogRepository(store: store);

      await repository.logAction(
        AiActionLog(
          actionId: 'action-1',
          userId: 'user-1',
          actionType: 'parse_text',
          input: 'Taxi 80 EGP',
          output: 'Taxi expense parsed',
          structuredJson: const {'amount': 80, 'status': 'parsed'},
          success: true,
          createdAt: DateTime.utc(2026, 5, 31),
        ),
      );

      final saved = await repository.getLogs();
      expect(saved.single.input, isEmpty);
      expect(saved.single.output, isNull);
      expect(saved.single.structuredJson, {'status': 'parsed'});
    });
  });
}
