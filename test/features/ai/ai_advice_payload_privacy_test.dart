import 'dart:convert';

import 'package:expenses_tracker/features/ai/domain/advice_summary.dart';
import 'package:expenses_tracker/features/ai/domain/ai_advice_request_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AI advice payload sends compact summary without raw financial text', () {
    final request = const AiAdviceRequestMapper().map(
      AdviceSummary(
        period: AdviceSummaryPeriod.currentMonth(DateTime(2026, 6, 1)),
        currency: 'EGP',
        totalSpent: 1200,
        dailyAverage: 40,
        walletBalancesSummary: const {
          'totalBalance': 3000,
          'walletCount': 2,
          'merchantName': 'Private Coffee Shop',
          'expenseDescription': 'Bought private medicine',
          'receiptRawText': 'SECRET RECEIPT TEXT',
          'recentExpenses': [
            {'merchant': 'Hidden Market', 'description': 'Private item'},
          ],
        },
        savingGoalsProgress: const {
          'activeGoals': 1,
          'receiptNote': 'Do not upload this receipt note',
        },
      ),
      locale: 'en',
      now: DateTime.utc(2026, 6, 1, 12),
      clientRequestId: 'client-privacy',
    );

    final encoded = jsonEncode(request.toJson());

    expect(encoded, contains('totalBalance'));
    expect(encoded, contains('walletCount'));
    expect(encoded, isNot(contains('Private Coffee Shop')));
    expect(encoded, isNot(contains('Bought private medicine')));
    expect(encoded, isNot(contains('SECRET RECEIPT TEXT')));
    expect(encoded, isNot(contains('Hidden Market')));
    expect(encoded, isNot(contains('Do not upload this receipt note')));
    expect(utf8.encode(encoded).length, lessThan(10 * 1024));
  });
}
