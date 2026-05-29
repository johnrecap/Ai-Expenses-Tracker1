import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/auth/presentation/sign_up_screen.dart';

void main() {
  group('SignUpScreen', () {
    testWidgets('renders create account form', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('has three text fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

      expect(find.byType(TextField), findsNWidgets(3));
    });
  });
}
