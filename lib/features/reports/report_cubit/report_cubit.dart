import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportCubit extends Cubit<ReportState> {
  final ExpenseRepository _expenseRepo;

  ReportCubit(this._expenseRepo) : super(const ReportState());

  Future<void> load({DateTime? startDate, DateTime? endDate}) async {
    emit(state.copyWith(loading: true));
    try {
      final expenses = await _expenseRepo.getExpensesByFilter(
        ExpenseFilter(startDate: startDate, endDate: endDate),
      );
      final totals = _computeCategoryTotals(expenses);
      final trends = _computeDailyTrends(expenses);
      final comparison = _computeMonthComparison(expenses);
      emit(ReportState(
        expenses: expenses,
        categoryTotals: totals,
        dailyTrends: trends,
        monthComparison: comparison,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Failed to load report.'));
    }
  }

  Map<String, double> _computeCategoryTotals(List<Expense> expenses) {
    final map = <String, double>{};
    for (final e in expenses) {
      map[e.categoryName] = (map[e.categoryName] ?? 0) + e.amount;
    }
    return map;
  }

  List<DailyTotal> _computeDailyTrends(List<Expense> expenses) {
    final byDay = <String, double>{};
    for (final e in expenses) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      byDay[key] = (byDay[key] ?? 0) + e.amount;
    }
    final sorted = byDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    double running = 0;
    return sorted.map((e) {
      running += e.value;
      return DailyTotal(e.key, e.value, running);
    }).toList();
  }

  MonthComparison _computeMonthComparison(List<Expense> expenses) {
    final now = DateTime.now();
    final thisMonth = expenses.where((e) => e.date.month == now.month && e.date.year == now.year).fold<double>(0, (s, e) => s + e.amount);
    final lastMonth = expenses.where((e) {
      final d = DateTime(now.year, now.month - 1);
      return e.date.month == d.month && e.date.year == d.year;
    }).fold<double>(0, (s, e) => s + e.amount);
    final pct = lastMonth > 0 ? ((thisMonth - lastMonth) / lastMonth * 100) : 0.0;
    return MonthComparison(thisMonth, lastMonth, pct);
  }
}

class ReportState {
  final bool loading;
  final String? error;
  final List<Expense> expenses;
  final Map<String, double> categoryTotals;
  final List<DailyTotal> dailyTrends;
  final MonthComparison? monthComparison;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportState({
    this.loading = false, this.error, this.expenses = const [],
    this.categoryTotals = const {}, this.dailyTrends = const [],
    this.monthComparison, this.startDate, this.endDate,
  });

  double get totalSpent => expenses.fold(0, (s, e) => s + e.amount);

  ReportState copyWith({
    bool? loading, String? error, List<Expense>? expenses,
    Map<String, double>? categoryTotals, List<DailyTotal>? dailyTrends,
    MonthComparison? monthComparison, DateTime? startDate, DateTime? endDate,
    bool clearError = false,
  }) {
    return ReportState(
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      expenses: expenses ?? this.expenses,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      dailyTrends: dailyTrends ?? this.dailyTrends,
      monthComparison: monthComparison ?? this.monthComparison,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
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
