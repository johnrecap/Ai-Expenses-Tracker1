import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/features/expenses/presentation/add_expense_receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('receipt screen is honest unavailable instead of fake parsed data', (tester) async {
    await tester.pumpWidget(_TestApp(initialLocation: AppRoutes.expensesNewReceipt));

    expect(find.text('Receipt scanning is not available yet'), findsOneWidget);
    expect(find.text('Open Quick Add'), findsOneWidget);
    expect(find.text('Use AI Text'), findsOneWidget);
    expect(find.textContaining('Receipt parsed'), findsNothing);
    expect(find.textContaining('Carrefour'), findsNothing);
    expect(find.textContaining('28.750 KWD'), findsNothing);
    expect(find.text('Tap to upload receipt'), findsNothing);
  });

  testWidgets('receipt screen routes to quick add fallback', (tester) async {
    await tester.pumpWidget(_TestApp(initialLocation: AppRoutes.expensesNewReceipt));

    await tester.tap(find.text('Open Quick Add'));
    await tester.pumpAndSettle();

    expect(find.text('quick-target'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  _TestApp({required String initialLocation})
    : _router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: AppRoutes.expensesNewReceipt,
            builder: (_, _) => const AddExpenseReceiptScreen(),
          ),
          GoRoute(
            path: AppRoutes.expensesNewQuick,
            builder: (_, _) => const Scaffold(body: Text('quick-target')),
          ),
          GoRoute(
            path: AppRoutes.expensesNewText,
            builder: (_, _) => const Scaffold(body: Text('ai-text-target')),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            builder: (_, _) => const Scaffold(body: Text('expenses-target')),
          ),
        ],
      );

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
