import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/expenses/presentation/expenses_list_screen.dart';

void main() {
  group('ExpensesListScreen', () {
    testWidgets('renders search and filter chips', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ExpensesListScreen()));

      expect(find.text('AI Expenses Tracker'), findsOneWidget);
    });

    testWidgets('has bottom navigation', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ExpensesListScreen()));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('shows filter sheet on More Filters tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ExpensesListScreen()));

      await tester.tap(find.text('More Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });
  });
}
