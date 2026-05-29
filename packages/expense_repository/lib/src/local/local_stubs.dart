import 'package:expense_repository/expense_repository.dart';
import '../local/local_repository_store.dart';

class LocalCategoryAliasRepository implements CategoryAliasRepository {
  final List<CategoryAlias> _aliases = [];
  @override Future<void> createAlias(CategoryAlias a) async => _aliases.add(a);
  @override Future<void> deleteAlias(String id) async => _aliases.removeWhere((a) => a.aliasId == id);
  @override Future<List<CategoryAlias>> getAliases() async => List.unmodifiable(_aliases);
  @override Stream<List<CategoryAlias>> watchAliases() => Stream.value(List.unmodifiable(_aliases));
}

class LocalCategoryBudgetRepository implements CategoryBudgetRepository {
  final List<CategoryBudget> _budgets = [];
  @override Future<void> saveCategoryBudget(CategoryBudget b) async { _budgets.removeWhere((x) => x.categoryId == b.categoryId); _budgets.add(b); }
  @override Future<CategoryBudget?> getCategoryBudget({required String categoryId, required int month, required int year}) async =>
      _budgets.where((b) => b.categoryId == categoryId && b.month == month && b.year == year).firstOrNull;
  @override Future<List<CategoryBudget>> getCategoryBudgets({required int month, required int year}) async =>
      _budgets.where((b) => b.month == month && b.year == year).toList();
  @override Stream<List<CategoryBudget>> watchCategoryBudgets({required int month, required int year}) =>
      Stream.value(_budgets.where((b) => b.month == month && b.year == year).toList());
}

class LocalRecurringExpenseRepository implements RecurringExpenseRepository {
  final List<RecurringExpense> _items = [];
  @override Future<void> create(RecurringExpense e) async => _items.add(e);
  @override Future<void> update(RecurringExpense e) async { _items.removeWhere((x) => x.recurringExpenseId == e.recurringExpenseId); _items.add(e); }
  @override Future<void> delete(String id) async => _items.removeWhere((x) => x.recurringExpenseId == id);
  @override Future<List<RecurringExpense>> getAll() async => List.unmodifiable(_items);
  @override Stream<List<RecurringExpense>> watchAll() => Stream.value(List.unmodifiable(_items));
}

class LocalAiActionLogRepository implements AiActionLogRepository {
  final List<AiActionLog> _logs = [];
  @override Future<void> logAction(AiActionLog l) async => _logs.add(l);
  @override Future<List<AiActionLog>> getLogs({int limit = 50}) async =>
      _logs.take(limit).toList();
  @override Stream<List<AiActionLog>> watchLogs({int limit = 50}) =>
      Stream.value(_logs.take(limit).toList());
}

class LocalWalletAccountRepository implements WalletAccountRepository {
  final LocalRepositoryStore store;
  LocalWalletAccountRepository({required this.store});
  @override Future<void> createWallet(WalletAccount w) async => store.upsertWallet(w);
  @override Future<void> updateWallet(WalletAccount w) async => store.upsertWallet(w);
  @override Future<void> deleteWallet(String id) async { /* no-op for local */ }
  @override Future<List<WalletAccount>> getWallets() async => store.wallets;
  @override Stream<List<WalletAccount>> watchWallets() => store.watchWallets();
}

class LocalTransferRepository implements TransferRepository {
  final List<Transfer> _transfers = [];
  @override Future<void> createTransfer(Transfer t) async => _transfers.add(t);
  @override Future<List<Transfer>> getTransfers() async => List.unmodifiable(_transfers);
  @override Stream<List<Transfer>> watchTransfers() => Stream.value(List.unmodifiable(_transfers));
}
