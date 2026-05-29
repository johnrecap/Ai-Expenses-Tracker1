import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/onboarding/presentation/widgets/onboarding_option_card.dart';

Widget wrapWithMaterial(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('OnboardingOptionCard', () {
    testWidgets('renders selected state', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          OnboardingOptionCard(
            title: 'English',
            subtitle: 'United States',
            iconData: Icons.language,
            isSelected: true,
            onTap: () {},
          ),
        ),
      );
      expect(find.text('English'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders unselected state', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          OnboardingOptionCard(
            title: 'Arabic',
            subtitle: 'Middle East',
            iconData: Icons.language,
            isSelected: false,
            onTap: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('onTap callback fires', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithMaterial(
          OnboardingOptionCard(
            title: 'Test',
            subtitle: 'Sub',
            iconData: Icons.star,
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Test'));
      expect(tapped, true);
    });

    testWidgets('renders in RTL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: OnboardingOptionCard(
                title: 'العربية',
                subtitle: 'الشرق الأوسط',
                iconData: Icons.language,
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('الشرق الأوسط'), findsOneWidget);
    });
  });
}
