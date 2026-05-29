import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/onboarding/presentation/language_screen.dart';

void main() {
  group('OnboardingLanguageScreen', () {
    testWidgets('renders header and options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OnboardingLanguageScreen()),
      );

      expect(find.text('Choose your app language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('toggles selection on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OnboardingLanguageScreen()),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      await tester.tap(find.text('العربية'));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('renders in RTL without overflow at 360', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: OnboardingLanguageScreen(),
          ),
        ),
      );
      expect(find.byType(OnboardingLanguageScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at all required widths', (tester) async {
      for (final width in [360.0, 375.0, 390.0]) {
        tester.view.physicalSize = Size(width * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        await tester.pumpWidget(
          const MaterialApp(home: OnboardingLanguageScreen()),
        );
        expect(find.byType(OnboardingLanguageScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
