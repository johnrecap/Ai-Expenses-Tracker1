import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseFilterCubit extends Cubit<ExpenseFilterState> {
  ExpenseFilterCubit() : super(const ExpenseFilterState());

  void replaceExpenses(List<Expense> expenses) {
    emit(
      ExpenseFilterState(
        allExpenses: expenses,
        filteredExpenses: _apply(
          expenses,
          state.filter,
          minAmount: state.minAmount,
          maxAmount: state.maxAmount,
          walletAccountId: state.walletAccountId,
        ),
        filter: state.filter,
        minAmount: state.minAmount,
        maxAmount: state.maxAmount,
        walletAccountId: state.walletAccountId,
      ),
    );
  }

  void updateQuery(String query) {
    final trimmed = query.trim();
    final newFilter = state.filter.copyWith(
      searchQuery: trimmed.isEmpty ? null : trimmed,
      clearSearch: trimmed.isEmpty,
    );
    _emitFiltered(
      filter: newFilter,
      minAmount: state.minAmount,
      maxAmount: state.maxAmount,
      walletAccountId: state.walletAccountId,
    );
  }

  void updateFilter(ExpenseFilter filter) {
    _emitFiltered(
      filter: filter,
      minAmount: state.minAmount,
      maxAmount: state.maxAmount,
      walletAccountId: state.walletAccountId,
    );
  }

  void applyFilters({
    String? searchQuery,
    bool clearSearch = false,
    String? categoryId,
    bool clearCategory = false,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDateRange = false,
    double? minAmount,
    double? maxAmount,
    bool replaceAmountRange = false,
    String? walletAccountId,
    bool clearWallet = false,
  }) {
    final trimmedQuery = searchQuery?.trim();
    final newFilter = state.filter.copyWith(
      searchQuery: trimmedQuery == null || trimmedQuery.isEmpty ? null : trimmedQuery,
      clearSearch: clearSearch || trimmedQuery == '',
      categoryId: categoryId,
      clearCategory: clearCategory,
      startDate: startDate,
      endDate: endDate,
      clearStart: clearDateRange,
      clearEnd: clearDateRange,
    );

    _emitFiltered(
      filter: newFilter,
      minAmount: replaceAmountRange ? minAmount : state.minAmount,
      maxAmount: replaceAmountRange ? maxAmount : state.maxAmount,
      walletAccountId: clearWallet ? null : walletAccountId ?? state.walletAccountId,
    );
  }

  void updateDateRange(DateTime? startDate, DateTime? endDate) {
    applyFilters(
      startDate: startDate,
      endDate: endDate,
      clearDateRange: startDate == null && endDate == null,
    );
  }

  void updateCategory(String? categoryId) {
    applyFilters(categoryId: categoryId, clearCategory: categoryId == null);
  }

  void updateAmountRange({double? minAmount, double? maxAmount}) {
    applyFilters(
      minAmount: minAmount,
      maxAmount: maxAmount,
      replaceAmountRange: true,
    );
  }

  void updateWallet(String? walletAccountId) {
    applyFilters(
      walletAccountId: walletAccountId,
      clearWallet: walletAccountId == null,
    );
  }

  void reset() {
    const f = ExpenseFilter.empty;
    emit(
      ExpenseFilterState(
        allExpenses: state.allExpenses,
        filteredExpenses: _apply(state.allExpenses, f),
        filter: f,
      ),
    );
  }

  void _emitFiltered({
    required ExpenseFilter filter,
    double? minAmount,
    double? maxAmount,
    String? walletAccountId,
  }) {
    emit(
      ExpenseFilterState(
        allExpenses: state.allExpenses,
        filteredExpenses: _apply(
          state.allExpenses,
          filter,
          minAmount: minAmount,
          maxAmount: maxAmount,
          walletAccountId: walletAccountId,
        ),
        filter: filter,
        minAmount: minAmount,
        maxAmount: maxAmount,
        walletAccountId: walletAccountId,
      ),
    );
  }

  List<Expense> _apply(
    List<Expense> expenses,
    ExpenseFilter filter, {
    double? minAmount,
    double? maxAmount,
    String? walletAccountId,
  }) {
    final query = filter.searchQuery?.trim().toLowerCase();
    return expenses.where((e) {
      if (query != null && query.isNotEmpty) {
        final desc = e.description.toLowerCase();
        final cat = e.categoryName.toLowerCase();
        final merchant = e.merchant?.toLowerCase() ?? '';
        if (!desc.contains(query) && !cat.contains(query) && !merchant.contains(query)) {
          return false;
        }
      }
      if (filter.categoryId != null && e.categoryId != filter.categoryId) return false;
      if (filter.excludedCategoryIds?.contains(e.categoryId) ?? false) return false;
      if (filter.paymentMethod != null && e.paymentMethod != filter.paymentMethod) return false;
      if (filter.startDate != null && e.date.isBefore(filter.startDate!)) return false;
      if (filter.endDate != null && e.date.isAfter(filter.endDate!)) return false;
      if (minAmount != null && e.amount < minAmount) return false;
      if (maxAmount != null && e.amount > maxAmount) return false;
      if (walletAccountId != null && e.walletAccountId != walletAccountId) return false;
      return true;
    }).toList();
  }
}

class ExpenseFilterState {
  final List<Expense> allExpenses;
  final List<Expense> filteredExpenses;
  final ExpenseFilter filter;
  final double? minAmount;
  final double? maxAmount;
  final String? walletAccountId;

  const ExpenseFilterState({
    this.allExpenses = const [],
    this.filteredExpenses = const [],
    this.filter = ExpenseFilter.empty,
    this.minAmount,
    this.maxAmount,
    this.walletAccountId,
  });

  bool get hasActiveFilters =>
      filter.hasActiveFilters || minAmount != null || maxAmount != null || walletAccountId != null;
}
