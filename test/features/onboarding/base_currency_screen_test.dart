import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/onboarding/onboarding_cubit/onboarding_cubit.dart';
import 'package:expenses_tracker/features/onboarding/presentation/base_currency_screen.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/app_test_harness.dart';

Widget _localizedApp(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  group('BaseCurrencyScreen', () {
    testWidgets('renders header and key elements', (tester) async {
      await tester.pumpWidget(
        _localizedApp(const BaseCurrencyScreen()),
      );

      expect(find.text('Base Currency'), findsOneWidget);
      expect(find.text('EGP'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('displays currency options', (tester) async {
      await tester.pumpWidget(
        _localizedApp(const BaseCurrencyScreen()),
      );

      expect(find.text('USD'), findsOneWidget);
      expect(find.text('AED'), findsOneWidget);
    });

    testWidgets('selects USD and continues to notifications route', (tester) async {
      final harness = AppTestHarness();
      final router = GoRouter(
        initialLocation: AppRoutes.onboardingCurrency,
        routes: [
          GoRoute(
            path: AppRoutes.onboardingCurrency,
            builder: (context, state) => const BaseCurrencyScreen(),
          ),
          GoRoute(
            path: AppRoutes.onboardingNotifications,
            builder: (context, state) => const Scaffold(body: Text('notifications-step')),
          ),
        ],
      );
      await tester.pumpWidget(
        harness.wrapProviders(
          MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );

      final cubit = tester.element(find.byType(BaseCurrencyScreen)).read<OnboardingCubit>();
      await tester.tap(find.text('USD'));
      await tester.ensureVisible(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(cubit.state.currency, 'USD');
      expect(find.text('notifications-step'), findsOneWidget);
    });
  });
}
