import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/auth/presentation/login_screen.dart';
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
  group('LoginScreen', () {
    testWidgets('renders welcome message and form', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(_localizedHarnessApp(harness, const LoginScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('renders Arabic locale without mixed field hints', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(
        _localizedHarnessApp(harness, const LoginScreen(), locale: const Locale('ar')),
      );

      expect(find.text('أهلا برجوعك'), findsOneWidget);
      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.textContaining(' / '), findsNothing);
      expect(find.textContaining('ط§'), findsNothing);
    });

    testWidgets('has email and password fields', (tester) async {
      final harness = AppTestHarness();
      await tester.pumpWidget(_localizedHarnessApp(harness, const LoginScreen()));

      expect(find.byType(TextField), findsNWidgets(2));
    });
  });
}
