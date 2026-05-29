import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/onboarding/presentation/base_currency_screen.dart';

void main() {
  group('BaseCurrencyScreen', () {
    testWidgets('renders header and key elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BaseCurrencyScreen()),
      );

      expect(find.text('Base Currency'), findsOneWidget);
      expect(find.text('EGP'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('displays currency options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BaseCurrencyScreen()),
      );

      expect(find.text('USD'), findsOneWidget);
      expect(find.text('AED'), findsOneWidget);
    });
  });
}
