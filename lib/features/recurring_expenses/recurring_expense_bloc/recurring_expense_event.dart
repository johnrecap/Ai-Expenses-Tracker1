part of 'recurring_expense_bloc.dart';

sealed class RecurringExpenseEvent {
  const RecurringExpenseEvent();
}

class RecurringExpensesWatched extends RecurringExpenseEvent {
  const RecurringExpensesWatched();
}

class RecurringExpensesUpdated extends RecurringExpenseEvent {
  final List<RecurringExpense> items;
  const RecurringExpensesUpdated(this.items);
}

class CreateRecurringExpense extends RecurringExpenseEvent {
  final RecurringExpense expense;
  const CreateRecurringExpense(this.expense);
}

class UpdateRecurringExpense extends RecurringExpenseEvent {
  final RecurringExpense expense;
  const UpdateRecurringExpense(this.expense);
}

class DeleteRecurringExpense extends RecurringExpenseEvent {
  final String recurringExpenseId;
  const DeleteRecurringExpense(this.recurringExpenseId);
}

class ToggleRecurringExpenseActive extends RecurringExpenseEvent {
  final RecurringExpense expense;
  const ToggleRecurringExpenseActive(this.expense);
}
