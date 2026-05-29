import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseFilterCubit extends Cubit<ExpenseFilterState> {
  ExpenseFilterCubit() : super(const ExpenseFilterState());

  void replaceExpenses(List<Expense> expenses) {
    emit(ExpenseFilterState(allExpenses: expenses, filteredExpenses: _apply(expenses, state.filter)));
  }

  void updateQuery(String query) {
    final newFilter = state.filter.copyWith(searchQuery: query);
    emit(ExpenseFilterState(allExpenses: state.allExpenses, filteredExpenses: _apply(state.allExpenses, newFilter), filter: newFilter));
  }

  void updateFilter(ExpenseFilter filter) {
    emit(ExpenseFilterState(allExpenses: state.allExpenses, filteredExpenses: _apply(state.allExpenses, filter), filter: filter));
  }

  void reset() {
    final f = ExpenseFilter.empty;
    emit(ExpenseFilterState(allExpenses: state.allExpenses, filteredExpenses: _apply(state.allExpenses, f), filter: f));
  }

  List<Expense> _apply(List<Expense> expenses, ExpenseFilter filter) {
    final query = filter.searchQuery?.trim().toLowerCase();
    return expenses.where((e) {
      if (query != null && query.isNotEmpty) {
        final desc = e.description.toLowerCase();
        final cat = e.categoryName.toLowerCase();
        if (!desc.contains(query) && !cat.contains(query)) return false;
      }
      if (filter.categoryId != null && e.categoryId != filter.categoryId) return false;
      if (filter.paymentMethod != null && e.paymentMethod != filter.paymentMethod) return false;
      if (filter.startDate != null && e.date.isBefore(filter.startDate!)) return false;
      if (filter.endDate != null && e.date.isAfter(filter.endDate!)) return false;
      return true;
    }).toList();
  }
}

class ExpenseFilterState {
  final List<Expense> allExpenses;
  final List<Expense> filteredExpenses;
  final ExpenseFilter filter;

  const ExpenseFilterState({
    this.allExpenses = const [],
    this.filteredExpenses = const [],
    this.filter = ExpenseFilter.empty,
  });
}
