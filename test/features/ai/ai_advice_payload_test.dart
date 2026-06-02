import 'dart:convert';

import 'package:expenses_tracker/features/ai/domain/ai_advice_cache.dart';
import 'package:expenses_tracker/features/ai/domain/ai_advice_request_mapper.dart';
import 'package:expenses_tracker/features/ai/domain/advice_summary.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiAdviceRequestMapper', () {
    test('maps typical summary to compact payload under 10KB', () {
      final request = const AiAdviceRequestMapper().map(
        _summary(categoryCount: 4, trendCount: 4, riskCount: 3),
        locale: 'ar-EG',
        now: DateTime.utc(2026, 5, 31, 12),
        clientRequestId: 'client-typical',
      );

      final json = request.toJson();
      final payloadBytes = utf8.encode(jsonEncode(json)).length;

      expect(payloadBytes, lessThan(10 * 1024));
      expect(json['clientRequestId'], 'client-typical');
      expect(json['defaultCurrency'], 'EGP');
      expect(jsonEncode(json), isNot(contains('merchant')));
      expect(jsonEncode(json), isNot(contains('description')));
      expect(jsonEncode(json), isNot(contains('receipt')));
      expect(jsonEncode(json), isNot(contains('transactions')));
    });

    test('normalizes current month summary period for gateway contract', () {
      final request = const AiAdviceRequestMapper().map(
        AdviceSummary(
          period: AdviceSummaryPeriod.currentMonth(DateTime(2026, 5, 31)),
          currency: 'EGP',
          totalSpent: 100,
          dailyAverage: 10,
        ),
        locale: 'en',
        now: DateTime.utc(2026, 5, 31, 12),
        clientRequestId: 'client-month',
      );

      expect(request.toJson()['period'], 'month');
    });

    test('caps heavy summary payload under 25KB', () {
      final request = const AiAdviceRequestMapper().map(
        _summary(categoryCount: 80, trendCount: 80, riskCount: 80),
        locale: 'en',
        now: DateTime.utc(2026, 5, 31, 12),
        clientRequestId: 'client-heavy',
      );

      final summary = request.toJson()['summary']! as Map<String, Object?>;
      final payloadBytes = utf8.encode(jsonEncode(request.toJson())).length;

      expect(payloadBytes, lessThan(25 * 1024));
      expect(summary['topCategories'], hasLength(aiAdviceTopCategoryLimit));
      expect(
        summary['categoryTrendFlags'],
        hasLength(aiAdviceTrendFlagLimit),
      );
      expect(summary['riskFlags'], hasLength(aiAdviceRiskFlagLimit));
    });

    test('drops raw-row-looking nested keys', () {
      final request = const AiAdviceRequestMapper().map(
        _summary(
          walletBalancesSummary: const {
            'cash': 1200,
            'recentExpenses': [
              {'merchant': 'Private shop', 'amount': 20},
            ],
            'receiptRawText': 'secret receipt text',
          },
        ),
        locale: 'en',
        now: DateTime.utc(2026, 5, 31, 12),
        clientRequestId: 'client-safe',
      );

      final encoded = jsonEncode(request.toJson());

      expect(encoded, contains('cash'));
      expect(encoded, isNot(contains('Private shop')));
      expect(encoded, isNot(contains('secret receipt text')));
    });
  });

  group('AiAdviceCache', () {
    test('reuses fresh advice only for matching summary, period, and locale', () {
      final cache = AiAdviceCache(ttl: const Duration(minutes: 10));
      const response = AiGatewayAdviceResponse(
        requestId: 'req-1',
        advice: 'Keep food spending below budget.',
        groundedSummary: 'Food is highest.',
      );
      final createdAt = DateTime.utc(2026, 5, 31, 12);

      cache.write(
        summaryHash: 'hash-1',
        period: 'month',
        locale: 'en',
        response: response,
        createdAt: createdAt,
      );

      expect(
        cache.read(
          summaryHash: 'hash-1',
          period: 'month',
          locale: 'en',
          now: createdAt.add(const Duration(minutes: 1)),
        ),
        same(response),
      );
      expect(
        cache.read(
          summaryHash: 'hash-2',
          period: 'month',
          locale: 'en',
          now: createdAt.add(const Duration(minutes: 1)),
        ),
        isNull,
      );
      expect(
        cache.read(
          summaryHash: 'hash-1',
          period: 'week',
          locale: 'en',
          now: createdAt.add(const Duration(minutes: 1)),
        ),
        isNull,
      );
    });

    test('expires stale advice', () {
      final cache = AiAdviceCache(ttl: const Duration(minutes: 10));
      final createdAt = DateTime.utc(2026, 5, 31, 12);
      cache.write(
        summaryHash: 'hash-1',
        period: 'month',
        locale: 'en',
        response: const AiGatewayAdviceResponse(
          requestId: 'req-1',
          advice: 'Cached advice.',
          groundedSummary: 'Cached summary.',
        ),
        createdAt: createdAt,
      );

      expect(
        cache.read(
          summaryHash: 'hash-1',
          period: 'month',
          locale: 'en',
          now: createdAt.add(const Duration(minutes: 11)),
        ),
        isNull,
      );
    });
  });
}

AdviceSummary _summary({
  int categoryCount = 5,
  int trendCount = 5,
  int riskCount = 5,
  Map<String, Object?> walletBalancesSummary = const {
    'cash': 2500,
    'bank': 12000,
  },
}) {
  return AdviceSummary(
    period: 'month',
    currency: 'EGP',
    totalSpent: 14500.45,
    dailyAverage: 483.35,
    budgetAmount: 18000,
    budgetRemaining: 3499.55,
    budgetUsedPercent: 80.6,
    topCategories: List.generate(
      categoryCount,
      (index) => AdviceSummaryCategory(
        name: 'Category $index',
        amount: 1000 + index * 12.35,
        percent: 22.2 - index,
      ),
    ),
    categoryTrendFlags: List.generate(
      trendCount,
      (index) => 'Category $index increased versus last month',
    ),
    subscriptionsTotal: 850,
    recurringTotal: 2100,
    walletBalancesSummary: walletBalancesSummary,
    savingGoalsProgress: const {
      'activeGoals': 2,
      'averageProgressPercent': 43.5,
    },
    monthComparisonPercent: 12.4,
    riskFlags: List.generate(riskCount, (index) => 'risk flag $index'),
    summaryHash: 'summary-hash',
  );
}
