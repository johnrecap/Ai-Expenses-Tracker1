import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'dart:async';

void main() {
  test('GetExpensesBloc initial state is GetExpensesInitial', () {
    final bloc = GetExpensesBloc(_MockExpenseRepo());
    expect(bloc.state, isA<GetExpensesInitial>());
    bloc.close();
  });

  test('GetExpensesBloc refresh emits success', () async {
    final bloc = GetExpensesBloc(_MockExpenseRepo());
    bloc.add(RefreshExpenses());
    await Future.delayed(const Duration(milliseconds: 100));
    expect(bloc.state, isA<GetExpensesSuccess>());
    bloc.close();
  });
}

class _MockExpenseRepo implements ExpenseRepository {
  @override Future<void> createExpense(Expense e) async {}
  @override Future<void> updateExpense(Expense e) async {}
  @override Future<void> deleteExpense(String id) async {}
  @override Future<Expense?> getExpenseById(String id) async => null;
  @override Future<List<Expense>> getExpenses() async => [];
  @override Stream<List<Expense>> watchExpenses() => Stream.value([]);
  @override Future<List<Expense>> getExpensesByFilter(ExpenseFilter f) async => [];
}
