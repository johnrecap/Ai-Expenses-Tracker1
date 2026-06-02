import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/expenses/expense_filter_cubit/expense_filter_cubit.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/expense_filters_sheet.dart';
import 'package:expenses_tracker/features/expenses/presentation/expenses_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expense filters', () {
    testWidgets('date category amount wallet and reset change visible expenses', (
      tester,
    ) async {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month, 15);
      final previousMonth = DateTime(now.year, now.month - 1, 15);
      final expenses = [
        _expense(
          id: 'coffee',
          description: 'Coffee',
          amount: 75,
          categoryId: 'food',
          categoryName: 'Food',
          walletId: 'cash',
          walletName: 'Cash Wallet',
          date: thisMonth,
        ),
        _expense(
          id: 'taxi',
          description: 'Taxi',
          amount: 220,
          categoryId: 'transport',
          categoryName: 'Transport',
          walletId: 'card',
          walletName: 'Card Wallet',
          date: previousMonth,
        ),
      ];

      await _pumpExpensesList(tester, expenses);

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Taxi'), findsOneWidget);

      await tester.tap(find.text('This Month'));
      await tester.pump();

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Taxi'), findsNothing);

      await _resetFromSheet(tester);

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Taxi'), findsOneWidget);

      await _openFilters(tester);
      await _tapSheetOption(tester, 'Transport');
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Coffee'), findsNothing);
      expect(find.text('Taxi'), findsOneWidget);

      await _resetFromSheet(tester);

      await _openFilters(tester);
      final maxAmount = find.byKey(const Key('expenseFilterMaxAmount'));
      await tester.ensureVisible(maxAmount);
      await tester.enterText(maxAmount, '100');
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Taxi'), findsNothing);

      await _resetFromSheet(tester);

      await _openFilters(tester);
      await _tapSheetOption(tester, 'Card Wallet');
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Coffee'), findsNothing);
      expect(find.text('Taxi'), findsOneWidget);

      await _resetFromSheet(tester);

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Taxi'), findsOneWidget);
    });
  });
}

Future<void> _pumpExpensesList(
  WidgetTester tester,
  List<Expense> expenses,
) async {
  final repository = _StaticExpenseRepository(expenses);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<GetExpensesBloc>(
          create: (_) => GetExpensesBloc(repository)..add(GetExpenses()),
        ),
        BlocProvider<ExpenseFilterCubit>(
          create: (_) => ExpenseFilterCubit(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const ExpensesListScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _openFilters(WidgetTester tester) async {
  await tester.tap(find.text('More Filters'));
  await tester.pumpAndSettle();
}

Future<void> _tapSheetOption(WidgetTester tester, String label) async {
  final finder = find.descendant(
    of: find.byType(ExpenseFiltersSheet),
    matching: find.text(label),
  );
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _resetFromSheet(WidgetTester tester) async {
  await _openFilters(tester);
  await tester.tap(find.text('Reset'));
  await tester.pump();
  await tester.tap(find.text('Apply Filters'));
  await tester.pumpAndSettle();
}

Expense _expense({
  required String id,
  required String description,
  required double amount,
  required String categoryId,
  required String categoryName,
  required String walletId,
  required String walletName,
  required DateTime date,
}) {
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: Category.empty.copyWith(
      categoryId: categoryId,
      name: categoryName,
      icon: 'category',
      color: 0xff006875,
    ),
    categoryId: categoryId,
    categoryName: categoryName,
    date: date,
    amount: amount,
    description: description,
    currency: 'EGP',
    walletAccountId: walletId,
    walletAccountName: walletName,
  );
}

class _StaticExpenseRepository implements ExpenseRepository {
  const _StaticExpenseRepository(this.expenses);

  final List<Expense> expenses;

  @override
  Future<void> createExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String expenseId) async {}

  @override
  Future<Expense?> getExpenseById(String expenseId) async => null;

  @override
  Future<List<Expense>> getExpenses() async => expenses;

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async => expenses;

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(expenses);
}
