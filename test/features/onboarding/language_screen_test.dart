import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/onboarding/onboarding_cubit/onboarding_cubit.dart';
import 'package:expenses_tracker/features/onboarding/presentation/language_screen.dart';
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
  group('OnboardingLanguageScreen', () {
    testWidgets('renders header and options', (tester) async {
      await tester.pumpWidget(
        _localizedApp(const OnboardingLanguageScreen()),
      );

      expect(find.text('Choose your app language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('renders Arabic locale without broken text', (tester) async {
      await tester.pumpWidget(
        _localizedApp(const OnboardingLanguageScreen(), locale: const Locale('ar')),
      );

      expect(find.text('اختار لغة التطبيق'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(find.textContaining('ط§'), findsNothing);
    });

    testWidgets('toggles selection on tap', (tester) async {
      await tester.pumpWidget(
        _localizedApp(const OnboardingLanguageScreen()),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      await tester.tap(find.text('العربية'));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('selects Arabic and continues to currency route', (tester) async {
      final harness = AppTestHarness();
      final router = GoRouter(
        initialLocation: AppRoutes.onboardingLanguage,
        routes: [
          GoRoute(
            path: AppRoutes.onboardingLanguage,
            builder: (context, state) => const OnboardingLanguageScreen(),
          ),
          GoRoute(
            path: AppRoutes.onboardingCurrency,
            builder: (context, state) => const Scaffold(body: Text('currency-step')),
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

      final cubit = tester.element(find.byType(OnboardingLanguageScreen)).read<OnboardingCubit>();
      await tester.tap(find.text('العربية'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(cubit.state.language, 'ar');
      expect(find.text('currency-step'), findsOneWidget);
    });

    testWidgets('renders in RTL without overflow at 360', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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
          _localizedApp(const OnboardingLanguageScreen()),
        );
        expect(find.byType(OnboardingLanguageScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
