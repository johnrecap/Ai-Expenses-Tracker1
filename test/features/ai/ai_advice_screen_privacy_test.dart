import 'package:expenses_tracker/features/ai/data/ai_gateway_models.dart';
import 'package:expenses_tracker/features/ai/domain/advice_summary.dart';
import 'package:expenses_tracker/features/ai/domain/advice_summary_cache.dart';
import 'package:expenses_tracker/features/ai/presentation/ai_advice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opening advice screen does not call remote AI before user asks', (
    tester,
  ) async {
    var gatewayCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AiAdviceScreen(
          summaryCache: AdviceSummaryCache.seeded(_summary()),
          adviceRequester: (request) async {
            gatewayCalls += 1;
            return const AiGatewayAdviceResponse(
              requestId: 'req-1',
              advice: 'Compact advice.',
              groundedSummary: 'Compact summary.',
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(gatewayCalls, 0);

    final askAiButton = find.widgetWithText(FilledButton, 'Ask AI');
    await tester.scrollUntilVisible(
      askAiButton,
      250,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(askAiButton);
    await tester.pump();

    expect(gatewayCalls, 1);
  });
}

AdviceSummary _summary() {
  return AdviceSummary(
    period: AdviceSummaryPeriod.currentMonth(DateTime(2026, 6, 1)),
    currency: 'EGP',
    totalSpent: 900,
    dailyAverage: 30,
    budgetAmount: 1000,
    budgetRemaining: 100,
    budgetUsedPercent: 90,
    topCategories: const [
      CategorySpendSummary(
        categoryName: 'Food',
        amount: 500,
        percent: 55.5,
      ),
    ],
    riskFlags: const ['budget_near_limit'],
  );
}
