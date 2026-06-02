import 'package:expenses_tracker/features/ai/domain/advice_summary.dart';
import 'package:expenses_tracker/features/ai/domain/advice_summary_cache.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_models.dart';
import 'package:expenses_tracker/features/ai/presentation/ai_advice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows local advice immediately without AI gateway', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: AiAdviceScreen(
          summaryCache: AdviceSummaryCache.seeded(_summary()),
        ),
      ),
    );

    expect(find.text('Instant local advice'), findsOneWidget);
    expect(find.text('Close to budget limit'), findsOneWidget);
    expect(find.text('Top category this month'), findsOneWidget);
    expect(find.text('AI advice is not available yet'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Ask AI on demand'),
      250,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Ask AI on demand'), findsOneWidget);
  });

  testWidgets('keeps local advice visible when Ask AI is tapped', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: AiAdviceScreen(
          summaryCache: AdviceSummaryCache.seeded(_summary()),
          adviceRequester: (request) async {
            expect(request.period, 'month');
            expect(request.summary.toString(), isNot(contains('merchant')));
            return const AiGatewayAdviceResponse(
              requestId: 'req-advice',
              advice: 'Reduce food spending by 10% this week.',
              groundedSummary: 'Food is the top category.',
            );
          },
        ),
      ),
    );

    final askAiButton = find.widgetWithText(FilledButton, 'Ask AI');
    await tester.scrollUntilVisible(
      askAiButton,
      250,
      scrollable: find.byType(Scrollable),
    );
    await tester.ensureVisible(askAiButton);
    await tester.pump();
    await tester.tap(askAiButton);
    await tester.pump();

    expect(find.text('Close to budget limit'), findsOneWidget);
    expect(find.text('Reduce food spending by 10% this week.'), findsOneWidget);
  });

  testWidgets('keeps local advice visible when AI request fails', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: AiAdviceScreen(
          summaryCache: AdviceSummaryCache.seeded(_summary()),
          adviceRequester: (_) async {
            throw const AiGatewayClientException(
              code: AiGatewayErrorCode.network,
              message: 'Network problem.',
            );
          },
        ),
      ),
    );

    final askAiButton = find.widgetWithText(FilledButton, 'Ask AI');
    await tester.scrollUntilVisible(
      askAiButton,
      250,
      scrollable: find.byType(Scrollable),
    );
    await tester.ensureVisible(askAiButton);
    await tester.pumpAndSettle();
    await tester.tap(askAiButton);
    await tester.pump();

    expect(find.text('Close to budget limit'), findsOneWidget);
    expect(find.textContaining('Network problem.'), findsOneWidget);
  });
}

AdviceSummary _summary() {
  return AdviceSummary(
    period: AdviceSummaryPeriod.currentMonth(DateTime(2026, 5, 20)),
    currency: 'EGP',
    totalSpent: 900,
    dailyAverage: 45,
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
    categoryTrendFlags: const ['budget_near_limit'],
    subscriptionsTotal: 0,
    recurringTotal: 0,
    walletBalancesSummary: const WalletBalancesSummary(
      totalBalance: 300,
      walletCount: 1,
    ),
    savingGoalsProgress: const SavingGoalsProgress(
      totalTarget: 0,
      totalSaved: 0,
      averageProgressPercent: 0,
      activeGoalCount: 0,
    ),
    monthComparisonPercent: 10,
    riskFlags: const ['budget_near_limit'],
  );
}
