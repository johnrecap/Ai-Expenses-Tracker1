part of 'recurring_expense_bloc.dart';

sealed class RecurringExpenseState {
  const RecurringExpenseState();
}

class RecurringExpenseInitial extends RecurringExpenseState {
  const RecurringExpenseInitial();
}

class RecurringExpenseLoading extends RecurringExpenseState {
  const RecurringExpenseLoading();
}

class RecurringExpenseLoaded extends RecurringExpenseState {
  final List<RecurringExpense> items;
  const RecurringExpenseLoaded(this.items);

  /// Returns items that are currently active (endDate is null or in the future)
  List<RecurringExpense> get activeItems => items.where(_isActive).toList();

  /// Returns items that are inactive (endDate is in the past)
  List<RecurringExpense> get inactiveItems => items.where((e) => !_isActive(e)).toList();

  static bool _isActive(RecurringExpense e) =>
      e.endDate == null || e.endDate!.isAfter(DateTime.now());
}

class RecurringExpenseError extends RecurringExpenseState {
  final String message;
  const RecurringExpenseError(this.message);
}
