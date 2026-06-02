import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:expenses_tracker/features/onboarding/presentation/splash_screen.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';

import '../../helpers/app_test_harness.dart';

Widget wrapWithRouter(Widget child) {
  final harness = AppTestHarness();
  return harness.wrapProviders(
    MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            pageBuilder: (context, state) => NoTransitionPage(child: child),
          ),
          GoRoute(
            path: '/onboarding/language',
            pageBuilder: (context, state) => const NoTransitionPage(child: Scaffold()),
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('SplashScreen', () {
    testWidgets('renders logo and loading text', (tester) async {
      await tester.pumpWidget(wrapWithRouter(const SplashScreen()));
      await tester.pump();

      expect(find.text('AI Expenses Tracker'), findsOneWidget);
      expect(find.text('Intelligent Financial Clarity'), findsOneWidget);
      expect(find.text('Initializing AI engine'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders at key viewport widths', (tester) async {
      for (final width in [360.0, 375.0, 390.0]) {
        tester.view.physicalSize = Size(width * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        await tester.pumpWidget(wrapWithRouter(const SplashScreen()));
        await tester.pump();
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
