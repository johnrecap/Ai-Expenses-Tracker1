import 'package:expense_repository/expense_repository.dart';

/// Shared interface for local stores (in-memory or SQLite-backed).
///
/// Both [LocalRepositoryStore] and [DriftLocalRepositoryStore] conform to
/// this interface so that [LocalExpenseRepository] and friends can accept
/// either implementation without knowing about the storage backend.
abstract class LocalStoreInterface {
  String get userId;
  int get expensesLoadedVersion;

  // -- properties
  List<Expense> get expenses;
  List<Category> get categories;
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
  void upsertExpense(Expense e);
  void deleteExpense(String id);
  void upsertCategory(Category c);
  void upsertBudget(Budget b);
  void upsertSettings(UserSettings s);
  void upsertGoal(SavingGoal g);
  void deleteGoal(String id);
  void upsertWallet(WalletAccount w);
  void upsertTransfer(Transfer t);
  void upsertCategoryBudget(CategoryBudget b);
  void upsertCategoryAlias(CategoryAlias a);
  void deleteCategoryAlias(String id);
  void upsertRecurringExpense(RecurringExpense e);
  void deleteRecurringExpense(String id);
  void upsertAiActionLog(AiActionLog l);
  void markUploadedChanges(List<String> ids);
  void markSyncChangesUpdated();
}
