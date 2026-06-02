import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/expenses/presentation/ai_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('legacy AI expense screen redirects to canonical AI text route', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.expensesNewAi,
      routes: [
        GoRoute(
          path: AppRoutes.expensesNewAi,
          builder: (_, _) => const AiExpenseScreen(),
        ),
        GoRoute(
          path: AppRoutes.expensesNewText,
          builder: (_, _) => const Scaffold(body: Text('ai-text-target')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('ai-text-target'), findsOneWidget);
  });
}
