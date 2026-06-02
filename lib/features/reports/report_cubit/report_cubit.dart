import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportCubit extends Cubit<ReportState> {
  final ExpenseRepository _expenseRepo;

  ReportCubit(this._expenseRepo) : super(const ReportState());

  Future<void> load({DateTime? startDate, DateTime? endDate, DateTime? now}) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final period = FinancialPeriod.resolve(
        startDate: startDate,
        endDate: endDate,
        now: now,
      );
      final previousPeriod = period.previousPeriod;
      final periodExpenses = _filterByPeriod(
        await _expenseRepo.getExpensesByFilter(
          ExpenseFilter(startDate: period.startDate, endDate: period.endDate),
        ),
        period,
      );
      final previousExpenses = _filterByPeriod(
        await _expenseRepo.getExpensesByFilter(
          ExpenseFilter(
            startDate: previousPeriod.startDate,
            endDate: previousPeriod.endDate,
          ),
        ),
        previousPeriod,
      );
      final summaries = _computeCategorySummaries(periodExpenses);
      final totals = _computeCategoryTotals(summaries);
      final trends = _computeDailyTrends(periodExpenses);
      final comparison = _computeMonthComparison(periodExpenses, previousExpenses);
      emit(
        ReportState(
          expenses: periodExpenses,
          categorySummaries: summaries,
          categoryTotals: totals,
          dailyTrends: trends,
          monthComparison: comparison,
          selectedPeriod: period,
          startDate: period.startDate,
          endDate: period.endDate,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Failed to load report.'));
    }
  }

  List<Expense> _filterByPeriod(List<Expense> expenses, FinancialPeriod period) {
    return expenses.where((expense) => period.contains(expense.date)).toList();
  }

  List<ReportCategorySummary> _computeCategorySummaries(List<Expense> expenses) {
    final map = <String, _CategoryAggregate>{};
    for (final expense in expenses) {
      final id = _categoryKey(expense);
      final current = map.putIfAbsent(
        id,
        () => _CategoryAggregate(
          categoryId: id,
          categoryName: _displayCategoryName(expense),
        ),
      );
      current.amount += expense.amount;
    }
    final summaries =
        map.values
            .map(
              (aggregate) => ReportCategorySummary(
                categoryId: aggregate.categoryId,
                categoryName: aggregate.categoryName,
                amount: aggregate.amount,
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));
    return summaries;
  }

  Map<String, double> _computeCategoryTotals(List<ReportCategorySummary> summaries) {
    final map = <String, double>{};
    for (final summary in summaries) {
      map[summary.categoryName] = (map[summary.categoryName] ?? 0) + summary.amount;
    }
    return map;
  }

  List<DailyTotal> _computeDailyTrends(List<Expense> expenses) {
    final byDay = <String, double>{};
    for (final e in expenses) {
      final key =
          '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      byDay[key] = (byDay[key] ?? 0) + e.amount;
    }
    final sorted = byDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    double running = 0;
    return sorted.map((e) {
      running += e.value;
      return DailyTotal(e.key, e.value, running);
    }).toList();
  }

  MonthComparison _computeMonthComparison(
    List<Expense> selectedExpenses,
    List<Expense> previousExpenses,
  ) {
    final thisMonth = selectedExpenses.fold<double>(0, (s, e) => s + e.amount);
    final lastMonth = previousExpenses.fold<double>(0, (s, e) => s + e.amount);
    final pct = lastMonth > 0 ? ((thisMonth - lastMonth) / lastMonth * 100) : 0.0;
    return MonthComparison(thisMonth, lastMonth, pct);
  }

  String _categoryKey(Expense expense) {
    final id = expense.categoryId.trim();
    if (id.isNotEmpty) return id;
    return _displayCategoryName(expense);
  }

  String _displayCategoryName(Expense expense) {
    final name = expense.categoryName.trim();
    if (name.isNotEmpty) return name;
    return expense.categoryId.trim().isNotEmpty ? expense.categoryId.trim() : 'Uncategorized';
  }
}

class ReportState {
  final bool loading;
  final String? error;
  final List<Expense> expenses;
  final List<ReportCategorySummary> categorySummaries;
  final Map<String, double> categoryTotals;
  final List<DailyTotal> dailyTrends;
  final MonthComparison? monthComparison;
  final FinancialPeriod? selectedPeriod;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportState({
    this.loading = false,
    this.error,
    this.expenses = const [],
    this.categorySummaries = const [],
    this.categoryTotals = const {},
    this.dailyTrends = const [],
    this.monthComparison,
    this.selectedPeriod,
    this.startDate,
    this.endDate,
  });

  double get totalSpent => expenses.fold(0, (s, e) => s + e.amount);
  String get periodLabel => selectedPeriod?.label ?? 'This Month';

  List<Expense> expensesForCategory(String categoryKey) {
    final decoded = Uri.decodeComponent(categoryKey).trim();
    return expenses.where((expense) {
      return _sameCategoryValue(expense.categoryId, decoded) ||
          _sameCategoryValue(expense.categoryName, decoded);
    }).toList();
  }

  String categoryNameFor(String categoryKey) {
    final decoded = Uri.decodeComponent(categoryKey).trim();
    for (final summary in categorySummaries) {
      if (_sameCategoryValue(summary.categoryId, decoded) ||
          _sameCategoryValue(summary.categoryName, decoded)) {
        return summary.categoryName;
      }
    }
    return decoded;
  }

  ReportState copyWith({
    bool? loading,
    String? error,
    List<Expense>? expenses,
    List<ReportCategorySummary>? categorySummaries,
    Map<String, double>? categoryTotals,
    List<DailyTotal>? dailyTrends,
    MonthComparison? monthComparison,
    FinancialPeriod? selectedPeriod,
    DateTime? startDate,
    DateTime? endDate,
    bool clearError = false,
  }) {
    return ReportState(
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      expenses: expenses ?? this.expenses,
      categorySummaries: categorySummaries ?? this.categorySummaries,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      dailyTrends: dailyTrends ?? this.dailyTrends,
      monthComparison: monthComparison ?? this.monthComparison,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

bool _sameCategoryValue(String value, String expected) {
  return value.trim().toLowerCase() == expected.trim().toLowerCase();
}

class FinancialPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final String label;

  const FinancialPeriod({
    required this.startDate,
    required this.endDate,
    required this.label,
  });

  factory FinancialPeriod.resolve({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? now,
  }) {
    if (startDate == null && endDate == null) {
      return FinancialPeriod.currentMonth(now: now);
    }
    final anchor = startDate ?? endDate ?? now ?? DateTime.now();
    final start = startDate ?? DateTime(anchor.year, anchor.month);
    final end = endDate ?? _monthEnd(anchor);
    return FinancialPeriod(startDate: start, endDate: end, label: _labelFor(start, end));
  }

  factory FinancialPeriod.currentMonth({DateTime? now}) {
    final anchor = now ?? DateTime.now();
    final start = DateTime(anchor.year, anchor.month);
    return FinancialPeriod(
      startDate: start,
      endDate: _monthEnd(anchor),
      label: 'This Month',
    );
  }

  FinancialPeriod get previousPeriod {
    final previousStart = DateTime(startDate.year, startDate.month - 1);
    return FinancialPeriod(
      startDate: previousStart,
      endDate: _monthEnd(previousStart),
      label: 'Last Month',
    );
  }

  bool contains(DateTime date) {
    return !date.isBefore(startDate) && !date.isAfter(endDate);
  }

  static DateTime _monthEnd(DateTime anchor) {
    return DateTime(anchor.year, anchor.month + 1).subtract(
      const Duration(microseconds: 1),
    );
  }

  static String _labelFor(DateTime start, DateTime end) {
    final current = FinancialPeriod.currentMonth();
    if (start.year == current.startDate.year &&
        start.month == current.startDate.month &&
        end.year == current.endDate.year &&
        end.month == current.endDate.month) {
      return 'This Month';
    }
    return '${start.year}-${start.month.toString().padLeft(2, '0')}';
  }
}

class ReportCategorySummary {
  final String categoryId;
  final String categoryName;
  final double amount;

  const ReportCategorySummary({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
  });
}

class DailyTotal {
  final String date;
  final double amount;
  final double cumulativeAmount;
  const DailyTotal(this.date, this.amount, this.cumulativeAmount);
}

class MonthComparison {
  final double thisMonth;
  final double lastMonth;
  final double changePercent;
  const MonthComparison(this.thisMonth, this.lastMonth, this.changePercent);
}

class _CategoryAggregate {
  final String categoryId;
  final String categoryName;
  double amount = 0;

  _CategoryAggregate({
    required this.categoryId,
    required this.categoryName,
  });
}
