import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/auth/presentation/widgets/auth_panel.dart';

Widget wrapWithMaterial(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('AuthPanel', () {
    testWidgets('renders login variant', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          AuthPanel(
            title: 'Welcome Back',
            subtitle: 'Log in to your account',
            primaryButtonLabel: 'Log In',
            showGoogleButton: true,
            footerLabel: "Don't have an account?",
            footerActionLabel: 'Sign up',
            onPrimaryAction: () {},
            children: [
              const AuthTextField(hintText: 'Email', prefixIcon: Icons.mail_outline),
              const SizedBox(height: 16),
              const AuthTextField(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Or email'), findsOneWidget);
    });

    testWidgets('renders sign-up variant', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          AuthPanel(
            title: 'Create Account',
            subtitle: 'Join today',
            primaryButtonLabel: 'Sign Up',
            footerLabel: 'Already have an account?',
            footerActionLabel: 'Log in',
            onPrimaryAction: () {},
            headerIcon: const Icon(Icons.person_add, size: 32),
            children: [
              const AuthTextField(hintText: 'Full Name', prefixIcon: Icons.person_outline),
            ],
          ),
        ),
      );

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('primary button fires callback', (tester) async {
      var fired = false;
      await tester.pumpWidget(
        wrapWithMaterial(
          AuthPanel(
            title: 'Test',
            subtitle: '',
            primaryButtonLabel: 'Go',
            onPrimaryAction: () => fired = true,
            children: const [],
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      expect(fired, true);
    });

    testWidgets('renders in RTL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                child: AuthPanel(
                  title: 'تسجيل الدخول',
                  subtitle: 'مرحباً',
                  primaryButtonLabel: 'دخول',
                  onPrimaryAction: () {},
                  children: const [],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.text('دخول'), findsOneWidget);
    });
  });
}
