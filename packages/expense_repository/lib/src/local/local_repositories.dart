import 'package:expense_repository/expense_repository.dart';

class LocalExpenseRepository implements ExpenseRepository {
  final LocalStoreInterface store;
  LocalExpenseRepository({required this.store});

  @override
  Future<void> createExpense(Expense e) async {
    await store.ready;
    final walletUpdates = _walletUpdatesForCreate(e);
    await store.upsertExpense(e);
    try {
      await _applyWalletUpdates(walletUpdates);
    } catch (_) {
      await store.deleteExpense(e.expenseId);
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(Expense e) async {
    await store.ready;
    final previous = store.expenses.where((item) => item.expenseId == e.expenseId).firstOrNull;
    final walletUpdates = _walletUpdatesForUpdate(previous: previous, next: e);
    final originalWallets = _originalWallets(walletUpdates);
    await store.upsertExpense(e);
    try {
      await _applyWalletUpdates(walletUpdates);
    } catch (_) {
      if (previous == null) {
        await store.deleteExpense(e.expenseId);
      } else {
        await store.upsertExpense(previous);
      }
      await _restoreWallets(originalWallets);
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    await store.ready;
    final previous = store.expenses.where((item) => item.expenseId == id).firstOrNull;
    final walletUpdates = previous == null
        ? const <WalletAccount>[]
        : _walletUpdatesForDelete(previous);
    final originalWallets = _originalWallets(walletUpdates);
    await store.deleteExpense(id);
    try {
      await _applyWalletUpdates(walletUpdates);
    } catch (_) {
      if (previous != null) await store.upsertExpense(previous);
      await _restoreWallets(originalWallets);
      rethrow;
    }
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    await store.ready;
    return store.expenses.where((e) => e.expenseId == id).firstOrNull;
  }

  @override
  Future<List<Expense>> getExpenses() async {
    await store.ready;
    return store.expenses;
  }

  @override
  Stream<List<Expense>> watchExpenses() => store.watchExpenses();
  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    await store.ready;
    final query = filter.searchQuery?.trim().toLowerCase();
    return store.expenses.where((e) {
      if (query != null && query.isNotEmpty) {
        if (!e.description.toLowerCase().contains(query) &&
            !e.categoryName.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (filter.startDate != null && e.date.isBefore(filter.startDate!)) return false;
      if (filter.endDate != null && e.date.isAfter(filter.endDate!)) return false;
      return true;
    }).toList();
  }

  List<WalletAccount> _walletUpdatesForCreate(Expense expense) {
    final wallet = _walletForExpense(expense);
    if (wallet == null) return const [];
    return [
      wallet.copyWith(
        balance: wallet.balance - expense.amount,
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<WalletAccount> _walletUpdatesForUpdate({
    required Expense? previous,
    required Expense next,
  }) {
    final balances = {for (final wallet in store.wallets) wallet.walletId: wallet};
    if (previous != null) {
      final previousWallet = _walletForExpense(previous, wallets: balances);
      if (previousWallet != null) {
        balances[previousWallet.walletId] = previousWallet.copyWith(
          balance: previousWallet.balance + previous.amount,
          updatedAt: DateTime.now(),
        );
      }
    }

    final nextWallet = _walletForExpense(next, wallets: balances);
    if (nextWallet != null) {
      balances[nextWallet.walletId] = nextWallet.copyWith(
        balance: nextWallet.balance - next.amount,
        updatedAt: DateTime.now(),
      );
    }

    return _changedWallets(balances);
  }

  List<WalletAccount> _walletUpdatesForDelete(Expense expense) {
    final wallet = _walletForExpense(expense);
    if (wallet == null) return const [];
    return [
      wallet.copyWith(
        balance: wallet.balance + expense.amount,
        updatedAt: DateTime.now(),
      ),
    ];
  }

  WalletAccount? _walletForExpense(
    Expense expense, {
    Map<String, WalletAccount>? wallets,
  }) {
    final walletId = expense.walletAccountId;
    if (walletId == null || walletId.trim().isEmpty) return null;
    final wallet = (wallets ?? {for (final item in store.wallets) item.walletId: item})[walletId];
    if (wallet == null) {
      throw const WalletTransferException('Selected wallet was not found.');
    }
    if (wallet.currency != expense.currency) {
      throw const WalletTransferException('Expense currency must match wallet currency.');
    }
    return wallet;
  }

  List<WalletAccount> _changedWallets(Map<String, WalletAccount> updated) {
    return updated.values.where((wallet) {
      final current = store.wallets.where((item) => item.walletId == wallet.walletId).firstOrNull;
      return current == null ||
          current.balance != wallet.balance ||
          current.updatedAt != wallet.updatedAt;
    }).toList();
  }

  Map<String, WalletAccount> _originalWallets(List<WalletAccount> updates) {
    final originals = <String, WalletAccount>{};
    for (final update in updates) {
      final current = store.wallets.where((wallet) => wallet.walletId == update.walletId).firstOrNull;
      if (current != null) originals[current.walletId] = current;
    }
    return originals;
  }

  Future<void> _applyWalletUpdates(List<WalletAccount> wallets) async {
    for (final wallet in wallets) {
      await store.upsertWallet(wallet);
    }
  }

  Future<void> _restoreWallets(Map<String, WalletAccount> wallets) async {
    for (final wallet in wallets.values) {
      await store.upsertWallet(wallet);
    }
  }
}

class LocalCategoryRepository implements CategoryRepository {
  final LocalStoreInterface store;
  LocalCategoryRepository({required this.store});

  @override
  Future<void> createCategory(Category c) async => store.upsertCategory(c);
  @override
  Future<void> updateCategory(Category c) async => store.upsertCategory(c);
  @override
  Future<void> archiveCategory(Category c) async {
    c.isArchived = true;
    await store.upsertCategory(c);
  }

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async {
    await store.ready;
    return store.categories.where((c) => includeArchived || !c.isArchived).toList();
  }

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) => store
      .watchCategories()
      .map((list) => list.where((c) => includeArchived || !c.isArchived).toList());
}

class LocalBudgetRepository implements BudgetRepository {
  final LocalStoreInterface store;
  LocalBudgetRepository({required this.store});

  @override
  Future<void> saveBudget(Budget b) async => store.upsertBudget(b);
  @override
  Future<Budget?> getCurrentMonthBudget({required int month, required int year}) async {
    await store.ready;
    return _budgetFor(month: month, year: year);
  }

  @override
  Stream<Budget?> watchCurrentMonthBudget({required int month, required int year}) async* {
    await store.ready;
    yield _budgetFor(month: month, year: year);
    yield* store.watchBudget().map((_) => _budgetFor(month: month, year: year));
  }

  Budget? _budgetFor({required int month, required int year}) {
    return store.budgets
        .where((budget) => budget.month == month && budget.year == year)
        .firstOrNull;
  }
}

class LocalSettingsRepository implements SettingsRepository {
  final LocalStoreInterface store;
  LocalSettingsRepository({required this.store});

  @override
  Future<UserSettings> getSettings() async {
    await store.ready;
    return store.settings ?? await ensureDefaultSettings();
  }

  @override
  Stream<UserSettings> watchSettings() async* {
    await store.ready;
    if (store.settings == null) {
      await store.upsertSettings(UserSettings.defaults(userId: store.userId));
    }
    yield* store.watchSettings();
  }

  @override
  Future<void> saveSettings(UserSettings s) async => store.upsertSettings(s);
  @override
  Future<void> updateBaseCurrency(String c) async {
    final s = await getSettings();
    await saveSettings(s.copyWith(baseCurrency: c, updatedAt: DateTime.now()));
  }

  @override
  Future<void> updateLanguagePreference(LanguagePreference p) async {
    final s = await getSettings();
    await saveSettings(s.copyWith(languagePreference: p, updatedAt: DateTime.now()));
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod m) async {
    final s = await getSettings();
    await saveSettings(s.copyWith(defaultPaymentMethod: m, updatedAt: DateTime.now()));
  }

  @override
  Future<UserSettings> ensureDefaultSettings() async {
    await store.ready;
    final existing = store.settings;
    if (existing != null) return existing;
    final d = UserSettings.defaults(userId: store.userId);
    await store.upsertSettings(d);
    return d;
  }
}

class LocalSavingGoalRepository implements SavingGoalRepository {
  final LocalStoreInterface store;
  LocalSavingGoalRepository({required this.store});
  @override
  Future<void> createSavingGoal(SavingGoal g) async => store.upsertGoal(g);
  @override
  Future<void> updateSavingGoal(SavingGoal g) async => store.upsertGoal(g);
  @override
  Future<void> deleteSavingGoal(String id) async => store.deleteGoal(id);
  @override
  Future<List<SavingGoal>> getSavingGoals() async {
    await store.ready;
    return store.goals;
  }

  @override
  Stream<List<SavingGoal>> watchSavingGoals() => store.watchGoals();
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
