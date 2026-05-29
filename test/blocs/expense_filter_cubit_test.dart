import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/expenses/expense_filter_cubit/expense_filter_cubit.dart';
import 'package:expense_repository/expense_repository.dart';

void main() {
  group('ExpenseFilterCubit', () {
    test('initial state has empty lists', () {
      final cubit = ExpenseFilterCubit();
      expect(cubit.state.allExpenses, isEmpty);
      expect(cubit.state.filteredExpenses, isEmpty);
    });

    test('replaceExpenses updates state', () {
      final cubit = ExpenseFilterCubit();
      final expenses = [
        Expense(expenseId: '1', category: Category.empty, date: DateTime.now(), amount: 100),
        Expense(expenseId: '2', category: Category.empty, date: DateTime.now(), amount: 200),
      ];
      cubit.replaceExpenses(expenses);
      expect(cubit.state.allExpenses.length, 2);
      expect(cubit.state.filteredExpenses.length, 2);
    });

    test('filter by query narrows results', () {
      final cubit = ExpenseFilterCubit();
      final expenses = [
        Expense(expenseId: '1', category: Category.empty.copyWith(name: 'Food'), date: DateTime.now(), amount: 100, description: 'Groceries'),
        Expense(expenseId: '2', category: Category.empty.copyWith(name: 'Transport'), date: DateTime.now(), amount: 50, description: 'Bus'),
      ];
      cubit.replaceExpenses(expenses);
      cubit.updateQuery('food');
      expect(cubit.state.filteredExpenses.length, 1);
    });

    test('reset clears filters', () {
      final cubit = ExpenseFilterCubit();
      cubit.replaceExpenses([]);
      cubit.updateQuery('test');
      cubit.reset();
      expect(cubit.state.filter.searchQuery, isNull);
    });
  });
}
