import 'package:expenses_tracker/monetization/presentation/free_premium_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('premium actions are visibly unavailable and disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FreePremiumScreen(),
      ),
    );

    expect(find.text('Premium is not available yet'), findsOneWidget);
    expect(find.textContaining('local entitlement cache'), findsAtLeastNWidgets(1));
    expect(find.textContaining('must not interrupt expense entry'), findsOneWidget);
    expect(find.text('Upgrade unavailable'), findsOneWidget);
    expect(find.text('Restore Purchases'), findsOneWidget);
    expect(find.text('4.99 USD/mo'), findsNothing);

    final upgradeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Upgrade unavailable'),
    );
    final restoreButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Restore Purchases'),
    );

    expect(upgradeButton.onPressed, isNull);
    expect(restoreButton.onPressed, isNull);
  });
}
