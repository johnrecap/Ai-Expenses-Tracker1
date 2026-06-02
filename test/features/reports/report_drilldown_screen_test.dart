import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/reports/presentation/report_drilldown_screen.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows expenses when route uses category id and display name differs', (
    tester,
  ) async {
    final repo = _MemoryExpenseRepository([
      _expense(
        id: 'food-1',
        categoryId: 'cat-food',
        categoryName: 'Food & Dining',
        date: DateTime(2026, 5, 8),
        amount: 120,
        description: 'Lunch',
      ),
      _expense(
        id: 'transport-1',
        categoryId: 'cat-transport',
        categoryName: 'Transport',
        date: DateTime(2026, 5, 10),
        amount: 35,
        description: 'Metro',
      ),
    ]);
    final cubit = ReportCubit(repo);
    await cubit.load(now: DateTime(2026, 5, 15));

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ReportDrilldownScreen(categoryId: 'cat-food'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Food & Dining'), findsWidgets);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Metro'), findsNothing);
    expect(find.text('No expenses for this category'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required DateTime date,
  required double amount,
  required String description,
}) {
  return Expense(
    expenseId: id,
    category: Category.empty.copyWith(
      categoryId: categoryId,
      name: categoryName,
      icon: 'category',
      color: 0xFF006875,
    ),
    date: date,
    amount: amount,
    description: description,
    currency: 'EGP',
  );
}

class _MemoryExpenseRepository implements ExpenseRepository {
  _MemoryExpenseRepository(this.expenses);

  final List<Expense> expenses;

  @override
  Future<void> createExpense(Expense expense) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String expenseId) async {}

  @override
  Future<Expense?> getExpenseById(String expenseId) async => null;

  @override
  Future<List<Expense>> getExpenses() async => expenses;

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(expenses);

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    return expenses.where((expense) {
      if (filter.startDate != null && expense.date.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null && expense.date.isAfter(filter.endDate!)) {
        return false;
      }
      return true;
    }).toList();
  }
}
