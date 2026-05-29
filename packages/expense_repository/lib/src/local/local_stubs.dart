import 'package:expense_repository/expense_repository.dart';
import 'local_store_interface.dart';

class LocalCategoryAliasRepository implements CategoryAliasRepository {
  final LocalStoreInterface store;
  LocalCategoryAliasRepository({required this.store});

  @override
  Future<void> createAlias(CategoryAlias a) async => store.upsertCategoryAlias(a);

  @override
  Future<void> deleteAlias(String id) async => store.deleteCategoryAlias(id);

  @override
  Future<List<CategoryAlias>> getAliases() async => store.categoryAliases;

  @override
  Stream<List<CategoryAlias>> watchAliases() => store.watchCategoryAliases();
}

class LocalCategoryBudgetRepository implements CategoryBudgetRepository {
  final LocalStoreInterface store;
  LocalCategoryBudgetRepository({required this.store});

  @override
  Future<void> saveCategoryBudget(CategoryBudget b) async =>
      store.upsertCategoryBudget(b);

  @override
  Future<CategoryBudget?> getCategoryBudget({
    required String categoryId,
    required int month,
    required int year,
  }) async {
    final results = store.categoryBudgets.where((b) =>
        b.categoryId == categoryId && b.month == month && b.year == year).toList();
    return results.isEmpty ? null : results.first;
  }

  @override
  Future<List<CategoryBudget>> getCategoryBudgets({
    required int month,
    required int year,
  }) async =>
      store.categoryBudgets.where((b) => b.month == month && b.year == year).toList();

  @override
  Stream<List<CategoryBudget>> watchCategoryBudgets({
    required int month,
    required int year,
  }) =>
      store.watchCategoryBudgets().map(
          (list) => list.where((b) => b.month == month && b.year == year).toList());
}

class LocalRecurringExpenseRepository implements RecurringExpenseRepository {
  final LocalStoreInterface store;
  LocalRecurringExpenseRepository({required this.store});

  @override
  Future<void> create(RecurringExpense e) async => store.upsertRecurringExpense(e);

  @override
  Future<void> update(RecurringExpense e) async => store.upsertRecurringExpense(e);

  @override
  Future<void> delete(String id) async => store.deleteRecurringExpense(id);

  @override
  Future<List<RecurringExpense>> getAll() async => store.recurringExpenses;

  @override
  Stream<List<RecurringExpense>> watchAll() => store.watchRecurringExpenses();
}

class LocalAiActionLogRepository implements AiActionLogRepository {
  final LocalStoreInterface store;
  LocalAiActionLogRepository({required this.store});

  @override
  Future<void> logAction(AiActionLog l) async => store.upsertAiActionLog(l);

  @override
  Future<List<AiActionLog>> getLogs({int limit = 50}) async =>
      store.aiActionLogs.take(limit).toList();

  @override
  Stream<List<AiActionLog>> watchLogs({int limit = 50}) =>
      store.watchAiActionLogs().map((list) => list.take(limit).toList());
}

class LocalWalletAccountRepository implements WalletAccountRepository {
  final LocalStoreInterface store;
  LocalWalletAccountRepository({required this.store});

  @override
  Future<void> createWallet(WalletAccount w) async => store.upsertWallet(w);

  @override
  Future<void> updateWallet(WalletAccount w) async => store.upsertWallet(w);

  @override
  Future<void> deleteWallet(String id) async { /* no-op for local */ }

  @override
  Future<List<WalletAccount>> getWallets() async => store.wallets;

  @override
  Stream<List<WalletAccount>> watchWallets() => store.watchWallets();
}

class LocalTransferRepository implements TransferRepository {
  final LocalStoreInterface store;
  LocalTransferRepository({required this.store});

  @override
  Future<void> createTransfer(Transfer t) async => store.upsertTransfer(t);

  @override
  Future<List<Transfer>> getTransfers() async => store.transfers;

  @override
  Stream<List<Transfer>> watchTransfers() => store.watchTransfers();
}
