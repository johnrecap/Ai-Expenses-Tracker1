import 'package:expense_repository/expense_repository.dart';

/// Shared interface for local stores (in-memory or SQLite-backed).
///
/// Both [LocalRepositoryStore] and [DriftLocalRepositoryStore] conform to
/// this interface so that [LocalExpenseRepository] and friends can accept
/// either implementation without knowing about the storage backend.
abstract class LocalStoreInterface {
  String get userId;
  int get expensesLoadedVersion;
  Future<void> get ready;

  // -- properties
  List<Expense> get expenses;
  List<Category> get categories;
  List<Budget> get budgets;
  Budget? get budget;
  UserSettings? get settings;
  List<SavingGoal> get goals;
  List<WalletAccount> get wallets;
  List<Transfer> get transfers;
  List<CategoryBudget> get categoryBudgets;
  List<CategoryAlias> get categoryAliases;
  List<RecurringExpense> get recurringExpenses;
  List<AiActionLog> get aiActionLogs;
  List<SyncChange> get pendingChanges;

  // -- streams
  Stream<List<Expense>> watchExpenses();
  Stream<List<Category>> watchCategories();
  Stream<Budget?> watchBudget();
  Stream<UserSettings> watchSettings();
  Stream<List<SavingGoal>> watchGoals();
  Stream<List<WalletAccount>> watchWallets();
  Stream<List<Transfer>> watchTransfers();
  Stream<List<CategoryBudget>> watchCategoryBudgets();
  Stream<List<CategoryAlias>> watchCategoryAliases();
  Stream<List<RecurringExpense>> watchRecurringExpenses();
  Stream<List<AiActionLog>> watchAiActionLogs();
  Stream<List<SyncChange>> watchPendingChanges();

  // -- mutations
  Future<void> upsertExpense(Expense e);
  Future<void> deleteExpense(String id);
  Future<void> upsertCategory(Category c);
  Future<void> upsertBudget(Budget b);
  Future<void> upsertSettings(UserSettings s);
  Future<void> upsertGoal(SavingGoal g);
  Future<void> deleteGoal(String id);
  Future<void> upsertWallet(WalletAccount w);
  Future<void> upsertTransfer(Transfer t);
  Future<void> upsertCategoryBudget(CategoryBudget b);
  Future<void> upsertCategoryAlias(CategoryAlias a);
  Future<void> deleteCategoryAlias(String id);
  Future<void> upsertRecurringExpense(RecurringExpense e);
  Future<void> deleteRecurringExpense(String id);
  Future<void> upsertAiActionLog(AiActionLog l);
  Future<void> applyRemoteChange(SyncChange change);
  void markUploadedChanges(List<String> ids);
  void markSyncChangesUpdated();
}
