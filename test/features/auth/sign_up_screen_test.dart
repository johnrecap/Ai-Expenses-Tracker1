import 'package:expenses_tracker/features/auth/presentation/sign_up_screen.dart';
import 'package:expenses_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('SignUpScreen', () {
    testWidgets('renders create account form', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(_localizedHarnessApp(harness, const SignUpScreen()));

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('renders Arabic locale without broken text', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(
        _localizedHarnessApp(harness, const SignUpScreen(), locale: const Locale('ar')),
      );

      expect(find.text('إنشاء حساب'), findsWidgets);
      expect(find.text('الاسم بالكامل'), findsOneWidget);
      expect(find.textContaining('ط§'), findsNothing);
    });

    testWidgets('has three text fields', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(_localizedHarnessApp(harness, const SignUpScreen()));

      expect(find.byType(TextField), findsNWidgets(3));
    });
  });
}
