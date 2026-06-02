import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _MockExpenseRepo repo;

  setUp(() => repo = _MockExpenseRepo());

  group('ReportCubit', () {
    test('initial state has empty data', () {
      final cubit = ReportCubit(repo);
      expect(cubit.state.expenses, isEmpty);
      expect(cubit.state.categoryTotals, isEmpty);
    });

    test('load defaults to the current month instead of all time', () async {
      repo.expenses = [
        _expense(
          id: 'may-food',
          categoryId: 'cat-food',
          categoryName: 'Food',
          date: DateTime(2026, 5, 4),
          amount: 100,
        ),
        _expense(
          id: 'may-transport',
          categoryId: 'cat-transport',
          categoryName: 'Transport',
          date: DateTime(2026, 5, 9),
          amount: 50,
        ),
        _expense(
          id: 'april-food',
          categoryId: 'cat-food',
          categoryName: 'Food',
          date: DateTime(2026, 4, 20),
          amount: 70,
        ),
        _expense(
          id: 'june-food',
          categoryId: 'cat-food',
          categoryName: 'Food',
          date: DateTime(2026, 6, 1),
          amount: 999,
        ),
      ];
      final cubit = ReportCubit(repo);

      await cubit.load(now: DateTime(2026, 5, 15));

      expect(cubit.state.periodLabel, 'This Month');
      expect(cubit.state.startDate, DateTime(2026, 5));
      expect(cubit.state.endDate, DateTime(2026, 6).subtract(const Duration(microseconds: 1)));
      expect(cubit.state.expenses.map((expense) => expense.expenseId), [
        'may-food',
        'may-transport',
      ]);
      expect(cubit.state.totalSpent, 150);
      expect(cubit.state.categoryTotals['Food'], 100);
      expect(cubit.state.categoryTotals['Transport'], 50);
      expect(cubit.state.monthComparison?.thisMonth, 150);
      expect(cubit.state.monthComparison?.lastMonth, 70);
    });

    test(
      'category summaries use id while drilldown matching also supports name fallback',
      () async {
        repo.expenses = [
          _expense(
            id: 'food-1',
            categoryId: 'cat-food',
            categoryName: 'Food & Dining',
            date: DateTime(2026, 5, 8),
            amount: 120,
          ),
          _expense(
            id: 'transport-1',
            categoryId: 'cat-transport',
            categoryName: 'Food & Dining',
            date: DateTime(2026, 5, 10),
            amount: 35,
          ),
        ];
        final cubit = ReportCubit(repo);

        await cubit.load(now: DateTime(2026, 5, 15));

        final foodSummary = cubit.state.categorySummaries.firstWhere(
          (summary) => summary.categoryId == 'cat-food',
        );
        expect(foodSummary.categoryName, 'Food & Dining');
        expect(foodSummary.amount, 120);
        expect(cubit.state.expensesForCategory('cat-food').map((e) => e.expenseId), ['food-1']);
        expect(
          cubit.state
              .expensesForCategory(Uri.encodeComponent('Food & Dining'))
              .map((e) => e.expenseId),
          ['food-1', 'transport-1'],
        );
      },
    );
  });
}

Expense _expense({
  required String id,
  required String categoryId,
  required String categoryName,
  required DateTime date,
  required double amount,
}) {
  return Expense(
    expenseId: id,
    category: Category.empty.copyWith(
      categoryId: categoryId,
      name: categoryName,
      icon: 'category',
      color: 0xFF006875,
    ),
    date: date,
    amount: amount,
    description: id,
    currency: 'EGP',
  );
}

class _MockExpenseRepo implements ExpenseRepository {
  List<Expense> expenses = [];

  @override
  Future<void> createExpense(Expense e) async {}

  @override
  Future<void> updateExpense(Expense e) async {}

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<Expense?> getExpenseById(String id) async => null;

  @override
  Future<List<Expense>> getExpenses() async => expenses;

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(expenses);

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    return expenses.where((expense) {
      if (filter.startDate != null && expense.date.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null && expense.date.isAfter(filter.endDate!)) {
        return false;
      }
      return true;
    }).toList();
  }
}
