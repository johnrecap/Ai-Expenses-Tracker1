import 'models/models.dart';

abstract class ExpenseRepository {
  Future<void> createExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);
  Future<Expense?> getExpenseById(String expenseId);
  Future<List<Expense>> getExpenses();
  Stream<List<Expense>> watchExpenses();
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter);
}
