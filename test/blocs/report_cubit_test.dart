import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expense_repository/expense_repository.dart';

void main() {
  late _MockExpenseRepo repo;

  setUp(() => repo = _MockExpenseRepo());

  group('ReportCubit', () {
    test('initial state has empty data', () {
      final cubit = ReportCubit(repo);
      expect(cubit.state.expenses, isEmpty);
      expect(cubit.state.categoryTotals, isEmpty);
    });

    test('load computes category totals', () async {
      repo._expenses = [
        Expense(expenseId: '1', category: Category.empty.copyWith(name: 'Food'), date: DateTime.now(), amount: 100),
        Expense(expenseId: '2', category: Category.empty.copyWith(name: 'Food'), date: DateTime.now(), amount: 50),
      ];
      final cubit = ReportCubit(repo);
      await cubit.load();
      expect(cubit.state.categoryTotals['Food'], 150);
      expect(cubit.state.totalSpent, 150);
    });
  });
}

class _MockExpenseRepo implements ExpenseRepository {
  List<Expense> _expenses = [];

  @override Future<void> createExpense(Expense e) async {}
  @override Future<void> updateExpense(Expense e) async {}
  @override Future<void> deleteExpense(String id) async {}
  @override Future<Expense?> getExpenseById(String id) async => null;
  @override Future<List<Expense>> getExpenses() async => _expenses;
  @override Stream<List<Expense>> watchExpenses() => Stream.value(_expenses);
  @override Future<List<Expense>> getExpensesByFilter(ExpenseFilter f) async => _expenses;
}
