import 'package:expense_repository/expense_repository.dart';

class MigrationComparisonExpenseRepository implements ExpenseRepository {
  final ExpenseRepository legacy;
  final ExpenseRepository migrated;

  MigrationComparisonExpenseRepository({required this.legacy, required this.migrated});

  @override
  Future<void> createExpense(Expense e) async => migrated.createExpense(e);
  @override
  Future<void> updateExpense(Expense e) async => migrated.updateExpense(e);
  @override
  Future<void> deleteExpense(String id) async => migrated.deleteExpense(id);
  @override
  Future<Expense?> getExpenseById(String id) async => migrated.getExpenseById(id);
  @override
  Future<List<Expense>> getExpenses() async => migrated.getExpenses();
  @override
  Stream<List<Expense>> watchExpenses() => migrated.watchExpenses();
  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter f) async => migrated.getExpensesByFilter(f);
}
