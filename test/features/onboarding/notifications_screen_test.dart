import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/onboarding/presentation/notifications_screen.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';

import '../../helpers/app_test_harness.dart';

Widget _localizedHarnessApp(
  AppTestHarness harness,
  Widget child, {
  Locale locale = const Locale('en'),
}) {
  return harness.wrapProviders(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  group('NotificationsScreen', () {
    testWidgets('renders header and first toggle card', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(
        _localizedHarnessApp(harness, const NotificationsScreen()),
      );

      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Stay in the Loop'), findsOneWidget);
      expect(find.text('Daily Reminder'), findsOneWidget);
      expect(find.text('Allow Notifications'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    });

    testWidgets('renders Arabic locale without broken text', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(
        _localizedHarnessApp(
          harness,
          const NotificationsScreen(),
          locale: const Locale('ar'),
        ),
      );

      expect(find.text('الخطوة ٣ من ٣'), findsOneWidget);
      expect(find.text('خليك متابع'), findsOneWidget);
      expect(find.textContaining('ط§'), findsNothing);
    });

    testWidgets('has toggle switches', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(
        _localizedHarnessApp(harness, const NotificationsScreen()),
      );

      final switches = find.byType(Switch);
      expect(switches, findsAtLeast(1));
    });

    testWidgets('renders second card when scrolled', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(
        _localizedHarnessApp(harness, const NotificationsScreen()),
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
