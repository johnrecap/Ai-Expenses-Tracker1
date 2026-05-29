import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/onboarding/presentation/notifications_screen.dart';

void main() {
  group('NotificationsScreen', () {
    testWidgets('renders header and first toggle card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotificationsScreen()),
      );

      expect(find.text('STEP 3 OF 3'), findsOneWidget);
      expect(find.text('Stay in the Loop'), findsOneWidget);
      expect(find.text('Daily Reminder'), findsOneWidget);
      expect(find.text('ALLOW NOTIFICATIONS'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    });

    testWidgets('has toggle switches', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotificationsScreen()),
      );

      final switches = find.byType(Switch);
      expect(switches, findsAtLeast(1));
    });

    testWidgets('renders second card when scrolled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotificationsScreen()),
      );

      await tester.scrollUntilVisible(
        find.text('Weekly Digest'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Weekly Digest'), findsOneWidget);
    });
  });
}
