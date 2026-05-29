import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/expenses/presentation/widgets/transaction_tile.dart';
import 'package:expenses_tracker/features/expenses/presentation/widgets/transaction_section.dart';

Category _testCategory() => Category(
  categoryId: 'cat-1',
  name: 'Food',
  icon: 'restaurant',
  color: 0xFFFF7043,
  userId: 'test-user',
);

Expense _testExpense({
  String id = 'exp-1',
  String description = 'Test Store',
  String categoryId = 'cat-1',
  double amount = 50.0,
  String currency = 'KWD',
}) {
  return Expense(
    expenseId: id,
    category: _testCategory(),
    date: DateTime.now(),
    amount: amount,
    currency: currency,
    description: description,
    categoryId: categoryId,
    categoryName: 'Food',
    categoryIcon: 'restaurant',
    categoryColor: 0xFFFF7043,
  );
}

void main() {
  group('TransactionTile', () {
    testWidgets('renders merchant and amount', (tester) async {
      final expense = _testExpense(description: 'Test Store', amount: 50.0);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: TransactionTile(expense: expense))),
      );

      expect(find.text('Test Store'), findsOneWidget);
      expect(find.textContaining('50.000'), findsOneWidget);
      expect(find.textContaining('KWD'), findsOneWidget);
    });

    testWidgets('supports onTap', (tester) async {
      var tapped = false;
      final expense = _testExpense(description: 'Tap Store', amount: 10.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(
              expense: expense,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Store'));
      expect(tapped, true);
    });
  });

  group('TransactionSection', () {
    testWidgets('renders date label and expenses', (tester) async {
      final expenses = [
        _testExpense(id: 'exp-1', description: 'Talabat Delivery', amount: 12.5),
        _testExpense(id: 'exp-2', description: 'Carrefour Market', amount: 28.75),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TransactionSection(
                dateLabel: 'Today, May 28',
                expenses: expenses,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Today, May 28'), findsOneWidget);
      expect(find.byType(TransactionTile), findsNWidgets(2));
    });
  });
}
