import 'models/recurring_expense.dart';

abstract class RecurringExpenseRepository {
  Future<void> create(RecurringExpense expense);
  Future<void> update(RecurringExpense expense);
  Future<void> delete(String recurringExpenseId);
  Future<List<RecurringExpense>> getAll();
  Stream<List<RecurringExpense>> watchAll();
}
