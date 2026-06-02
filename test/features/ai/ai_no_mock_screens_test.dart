import 'package:expenses_tracker/features/ai/presentation/ai_advice_screen.dart';
import 'package:expenses_tracker/features/ai/presentation/ai_assistant_sheet.dart';
import 'package:expenses_tracker/features/ai/presentation/ai_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('AI advice shows local state instead of mock advice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpScreen(tester, const AiAdviceScreen());

    expect(find.text('Instant local advice'), findsOneWidget);
    expect(find.text('Start tracking expenses'), findsOneWidget);
    expect(find.text('AI advice is not available yet'), findsNothing);
    expect(find.textContaining('KWD'), findsNothing);
    expect(find.textContaining('Subscription Overlap Detected'), findsNothing);
    expect(find.textContaining('Dining Spike This Month'), findsNothing);
  });

  testWidgets('AI history shows empty state instead of sample chat history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);

    await pumpScreen(tester, const AiHistoryScreen());

    expect(find.text('No AI history yet'), findsOneWidget);
    expect(find.text('Use AI text entry'), findsOneWidget);
    expect(find.textContaining('KWD'), findsNothing);
    expect(find.textContaining('Show my spending'), findsNothing);
    expect(find.textContaining('Here is your May spending'), findsNothing);
  });

  testWidgets('AI assistant sheet disables chat instead of demo replies', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);

    await pumpScreen(
      tester,
      const Scaffold(
        body: AiAssistantSheet(),
      ),
    );

    expect(find.text('AI assistant is not available yet'), findsOneWidget);
    expect(find.text('Use AI text entry'), findsOneWidget);
    expect(find.textContaining('demo mode'), findsNothing);
    expect(find.textContaining('I received your message'), findsNothing);
    expect(find.textContaining('KWD'), findsNothing);
  });
}
