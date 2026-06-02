import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/expenses/expense_filter_cubit/expense_filter_cubit.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/expenses_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpensesListScreen', () {
    testWidgets('renders search and filter chips', (tester) async {
      await tester.pumpWidget(_wrapList());

      expect(find.text('AI Expenses Tracker'), findsOneWidget);
    });

    testWidgets('has bottom navigation', (tester) async {
      await tester.pumpWidget(_wrapList());

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('shows filter sheet on More Filters tap', (tester) async {
      await tester.pumpWidget(_wrapList());

      await tester.tap(find.text('More Filters'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
    });

    testWidgets('shows already-loaded expenses on first build', (tester) async {
      await tester.pumpWidget(
        _wrapList(
          preloadedExpenses: [
            _expense(description: 'Screen installment', categoryName: 'Utilities'),
          ],
        ),
      );

      expect(find.text('Screen installment'), findsOneWidget);
      expect(find.text('Utilities'), findsOneWidget);
      expect(find.text('No transactions found'), findsNothing);
    });

    testWidgets('lifts add FAB above the bottom navigation', (tester) async {
      await tester.pumpWidget(_wrapList());

      expect(find.byKey(ExpensesListScreen.addExpenseButtonKey), findsOneWidget);
      final fabPadding = tester.widget<Padding>(
        find.byKey(ExpensesListScreen.addExpenseFabPaddingKey),
      );
      expect(fabPadding.padding, const EdgeInsets.only(bottom: 72));
    });
  });
}

Widget _wrapList({List<Expense> preloadedExpenses = const []}) {
  final expenseRepository = _StaticExpenseRepository(preloadedExpenses);

  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => preloadedExpenses.isEmpty
            ? (GetExpensesBloc(expenseRepository)..add(GetExpenses()))
            : _LoadedGetExpensesBloc(expenseRepository, preloadedExpenses),
      ),
      BlocProvider(create: (_) => ExpenseFilterCubit()),
    ],
    child: const MaterialApp(home: ExpensesListScreen()),
  );
}

Expense _expense({
  String description = 'Lunch',
  String categoryId = 'food',
  String categoryName = 'Food',
}) {
  final now = DateTime(2026, 6);
  return Expense(
    expenseId: 'expense-1',
    userId: 'user-1',
    category: Category.empty.copyWith(
      categoryId: categoryId,
      name: categoryName,
      icon: 'receipt_long',
      color: 0xff006875,
    ),
    categoryId: categoryId,
    categoryName: categoryName,
    categoryIcon: 'receipt_long',
    categoryColor: 0xff006875,
    amount: 730,
    date: now,
    description: description,
    currency: 'EGP',
    createdAt: now,
    updatedAt: now,
  );
}

class _LoadedGetExpensesBloc extends GetExpensesBloc {
  _LoadedGetExpensesBloc(super.expenseRepository, List<Expense> expenses) {
    emit(GetExpensesSuccess(expenses));
  }
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
