import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/budgets/presentation/category_budgets_list_screen.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders repository category budgets without static rows', (
    tester,
  ) async {
    final now = DateTime.now();
    final repo = _FakeCategoryBudgetRepository([
      CategoryBudget(
        budgetId: '${now.year}-${now.month.toString().padLeft(2, '0')}-groceries',
        userId: 'user-1',
        categoryId: 'groceries',
        amount: 250,
        month: now.month,
        year: now.year,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    final reportCubit = _SeededReportCubit()
      ..seed(
        ReportState(
          categorySummaries: const [
            ReportCategorySummary(
              categoryId: 'groceries',
              categoryName: 'Groceries',
              amount: 80,
            ),
          ],
          selectedPeriod: FinancialPeriod.currentMonth(now: now),
        ),
      );

    await tester.pumpWidget(
      RepositoryProvider<CategoryBudgetRepository>.value(
        value: repo,
        child: BlocProvider<ReportCubit>.value(
          value: reportCubit,
          child: const MaterialApp(home: CategoryBudgetsListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('80.00 / 250.00 EGP'), findsOneWidget);
    expect(find.text('Food & Dining'), findsNothing);
    expect(find.text('Transport'), findsNothing);
    expect(find.text('Shopping'), findsNothing);
    expect(find.text('Entertainment'), findsNothing);
    expect(find.text('Healthcare'), findsNothing);
    expect(find.text('Utilities'), findsNothing);

    await reportCubit.close();
  });

  testWidgets('shows honest empty state when repository has no budgets', (
    tester,
  ) async {
    final repo = _FakeCategoryBudgetRepository(const []);

    await tester.pumpWidget(
      RepositoryProvider<CategoryBudgetRepository>.value(
        value: repo,
        child: const MaterialApp(home: CategoryBudgetsListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No category budgets yet'), findsOneWidget);
    expect(find.text('Food & Dining'), findsNothing);
  });
}

class _FakeCategoryBudgetRepository implements CategoryBudgetRepository {
  _FakeCategoryBudgetRepository(List<CategoryBudget> budgets)
    : _budgets = [...budgets];

  final List<CategoryBudget> _budgets;
  final _controller = StreamController<List<CategoryBudget>>.broadcast();

  @override
  Future<List<CategoryBudget>> getCategoryBudgets({
    required int month,
    required int year,
  }) async {
    return _budgets
        .where((budget) => budget.month == month && budget.year == year)
        .toList();
  }

  @override
  Future<CategoryBudget?> getCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  }) async {
    final matches = await getCategoryBudgets(month: month, year: year);
    for (final budget in matches) {
      if (budget.categoryId == categoryId) return budget;
    }
    return null;
  }

  @override
  Future<void> saveCategoryBudget(CategoryBudget budget) async {
    _budgets.removeWhere((item) => item.budgetId == budget.budgetId);
    _budgets.add(budget);
    _controller.add(_budgets);
  }

  @override
  Stream<List<CategoryBudget>> watchCategoryBudgets({
    required int month,
    required int year,
  }) {
    return _controller.stream.map(
      (budgets) => budgets
          .where((budget) => budget.month == month && budget.year == year)
          .toList(),
    );
  }
}

class _SeededReportCubit extends ReportCubit {
  _SeededReportCubit() : super(_NoopExpenseRepository());

  void seed(ReportState state) => emit(state);
}

class _NoopExpenseRepository implements ExpenseRepository {
  @override
  Future<void> createExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String expenseId) async {}

  @override
  Future<Expense?> getExpenseById(String expenseId) async => null;

  @override
  Future<List<Expense>> getExpenses() async => const [];

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async =>
      const [];

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Stream<List<Expense>> watchExpenses() => const Stream.empty();
}
