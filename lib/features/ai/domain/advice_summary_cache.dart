// ignore_for_file: prefer_initializing_formals

import 'package:expense_repository/expense_repository.dart';

import 'advice_summary.dart';
import 'advice_summary_builder.dart';

class AdviceSummaryCache {
  AdviceSummaryCache({
    required AdviceSummaryBuilder builder,
    ExpenseRepository? expenseRepository,
    BudgetRepository? budgetRepository,
    WalletAccountRepository? walletRepository,
    SavingGoalRepository? savingGoalRepository,
    RecurringExpenseRepository? recurringExpenseRepository,
    DateTime Function()? now,
    String defaultCurrency = 'EGP',
  }) : _builder = builder,
       _expenseRepository = expenseRepository,
       _budgetRepository = budgetRepository,
       _walletRepository = walletRepository,
       _savingGoalRepository = savingGoalRepository,
       _recurringExpenseRepository = recurringExpenseRepository,
       _now = now ?? DateTime.now,
       _defaultCurrency = defaultCurrency;

  AdviceSummaryCache.seeded(AdviceSummary summary)
    : _builder = const AdviceSummaryBuilder(),
      _expenseRepository = null,
      _budgetRepository = null,
      _walletRepository = null,
      _savingGoalRepository = null,
      _recurringExpenseRepository = null,
      _now = DateTime.now,
      _defaultCurrency = summary.currency,
      _summary = summary,
      _isStale = false;

  final AdviceSummaryBuilder _builder;
  final ExpenseRepository? _expenseRepository;
  final BudgetRepository? _budgetRepository;
  final WalletAccountRepository? _walletRepository;
  final SavingGoalRepository? _savingGoalRepository;
  final RecurringExpenseRepository? _recurringExpenseRepository;
  final DateTime Function() _now;
  final String _defaultCurrency;

  AdviceSummary? _summary;
  bool _isStale = true;

  AdviceSummary? get currentSummary => _summary;
  bool get isStale => _isStale;

  void update(AdviceSummary summary) {
    _summary = summary;
    _isStale = false;
  }

  void markStale() {
    _isStale = true;
  }

  Future<AdviceSummary> read() async {
    if (_summary != null && !_isStale) return _summary!;
    return refresh();
  }

  Future<AdviceSummary> refresh() async {
    final now = _now();
    final expenses = await _expenseRepository?.getExpenses() ?? const <Expense>[];
    final budget = await _budgetRepository?.getCurrentMonthBudget(
      month: now.month,
      year: now.year,
    );
    final wallets = await _walletRepository?.getWallets() ?? const <WalletAccount>[];
    final goals = await _savingGoalRepository?.getSavingGoals() ?? const <SavingGoal>[];
    final recurring = await _recurringExpenseRepository?.getAll() ?? const <RecurringExpense>[];

    final summary = _builder.build(
      expenses: expenses,
      budget: budget,
      wallets: wallets,
      savingGoals: goals,
      recurringExpenses: recurring,
      now: now,
      currency: _defaultCurrency,
    );
    update(summary);
    return summary;
  }
}
