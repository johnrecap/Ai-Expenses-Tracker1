import 'dart:async';
import 'package:expense_repository/expense_repository.dart';
import '../sync/sync_change.dart';
import 'local_store_interface.dart';

class LocalRepositoryStore implements LocalStoreInterface {
  final String userId;
  final Map<String, Expense> _expenses = {};
  final Map<String, Category> _categories = {};
  final Map<String, Budget> _budgets = {};
  final Map<String, UserSettings> _settings = {};
  final Map<String, SavingGoal> _goals = {};
  final Map<String, WalletAccount> _wallets = {};
  final Map<String, Transfer> _transfers = {};
  final Map<String, CategoryBudget> _categoryBudgets = {};
  final Map<String, CategoryAlias> _categoryAliases = {};
  final Map<String, RecurringExpense> _recurringExpenses = {};
  final List<AiActionLog> _aiActionLogs = [];

  final List<SyncChange> pendingChanges = [];
  int _changeCounter = 0;

  final _expenseController = StreamController<List<Expense>>.broadcast();
  final _categoryController = StreamController<List<Category>>.broadcast();
  final _budgetController = StreamController<Budget?>.broadcast();
  final _settingsController = StreamController<UserSettings>.broadcast();
  final _goalController = StreamController<List<SavingGoal>>.broadcast();
  final _walletController = StreamController<List<WalletAccount>>.broadcast();
  final _transferController = StreamController<List<Transfer>>.broadcast();
  final _categoryBudgetController =
      StreamController<List<CategoryBudget>>.broadcast();
  final _categoryAliasController =
      StreamController<List<CategoryAlias>>.broadcast();
  final _recurringExpenseController =
      StreamController<List<RecurringExpense>>.broadcast();
  final _aiActionLogController =
      StreamController<List<AiActionLog>>.broadcast();
  final _pendingController = StreamController<List<SyncChange>>.broadcast();

  LocalRepositoryStore({required this.userId});

  int get expensesLoadedVersion => _expenses.length;

  void _emitExpenses() {
    final list = _expenses.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    _expenseController.add(list);
  }

  void _enqueue(String entityType, String entityId, Map<String, dynamic> data) {
    pendingChanges.add(SyncChange(
      id: 'change-${++_changeCounter}', entityType: entityType, entityId: entityId,
      changeType: SyncChangeType.upsert, data: data, clientChangeId: '$entityType-$entityId-$_changeCounter',
      deviceId: 'flutter-$userId', userId: userId, timestamp: DateTime.now(),
    ));
    _pendingController.add(List.unmodifiable(pendingChanges));
  }

  void _enqueueDelete(String entityType, String entityId, Map<String, dynamic> data) {
    pendingChanges.add(SyncChange(
      id: 'change-${++_changeCounter}', entityType: entityType, entityId: entityId,
      changeType: SyncChangeType.delete, data: data, clientChangeId: '$entityType-$entityId-$_changeCounter',
      deviceId: 'flutter-$userId', userId: userId, timestamp: DateTime.now(),
    ));
    _pendingController.add(List.unmodifiable(pendingChanges));
  }

  void markUploadedChanges(List<String> ids) {
    pendingChanges.removeWhere((c) => ids.contains(c.id));
    _pendingController.add(List.unmodifiable(pendingChanges));
  }

  void markSyncChangesUpdated() {
    _pendingController.add(List.unmodifiable(pendingChanges));
  }

  Stream<List<Expense>> watchExpenses() => _expenseController.stream;
  Stream<List<Category>> watchCategories() => _categoryController.stream;
  Stream<Budget?> watchBudget() => _budgetController.stream;
  Stream<UserSettings> watchSettings() => _settingsController.stream;
  Stream<List<SavingGoal>> watchGoals() => _goalController.stream;
  Stream<List<WalletAccount>> watchWallets() => _walletController.stream;
  Stream<List<Transfer>> watchTransfers() => _transferController.stream;
  Stream<List<CategoryBudget>> watchCategoryBudgets() =>
      _categoryBudgetController.stream;
  Stream<List<CategoryAlias>> watchCategoryAliases() =>
      _categoryAliasController.stream;
  Stream<List<RecurringExpense>> watchRecurringExpenses() =>
      _recurringExpenseController.stream;
  Stream<List<AiActionLog>> watchAiActionLogs() =>
      _aiActionLogController.stream;
  Stream<List<SyncChange>> watchPendingChanges() => _pendingController.stream;

  void upsertExpense(Expense e) { _expenses[e.expenseId] = e; _emitExpenses(); _enqueue('expense', e.expenseId, e.toEntity().toDocument()); }
  void deleteExpense(String id) { _expenses.remove(id); _emitExpenses(); _enqueueDelete('expense', id, {}); }
  List<Expense> get expenses => _expenses.values.toList();

  void upsertCategory(Category c) { _categories[c.categoryId] = c; _categoryController.add(_categories.values.toList()); _enqueue('category', c.categoryId, c.toEntity().toDocument()); }
  List<Category> get categories => _categories.values.toList();

  void upsertBudget(Budget b) { _budgets[b.budgetId] = b; _budgetController.add(b); _enqueue('budget', b.budgetId, b.toEntity().toDocument()); }
  Budget? get budget => _budgets.values.isNotEmpty ? _budgets.values.first : null;

  void upsertSettings(UserSettings s) { _settings['profile'] = s; _settingsController.add(s); _enqueue('settings', 'profile', s.toEntity().toDocument()); }
  UserSettings? get settings => _settings['profile'];

  void upsertGoal(SavingGoal g) { _goals[g.goalId] = g; _goalController.add(_goals.values.toList()); _enqueue('savingGoal', g.goalId, _goalToDoc(g)); }
  void deleteGoal(String id) { _goals.remove(id); _goalController.add(_goals.values.toList()); _enqueueDelete('savingGoal', id, {}); }
  List<SavingGoal> get goals => _goals.values.toList();

  void upsertWallet(WalletAccount w) { _wallets[w.walletId] = w; _walletController.add(_wallets.values.toList()); _enqueue('wallet', w.walletId, _walletToDoc(w)); }
  List<WalletAccount> get wallets => _wallets.values.toList();

  void upsertTransfer(Transfer t) { _transfers[t.transferId] = t; _transferController.add(_transfers.values.toList()); _enqueue('transfer', t.transferId, _transferToDoc(t)); }
  List<Transfer> get transfers => _transfers.values.toList();

  void upsertCategoryBudget(CategoryBudget b) { _categoryBudgets[b.budgetId] = b; _categoryBudgetController.add(_categoryBudgets.values.toList()); _enqueue('categoryBudget', b.budgetId, _categoryBudgetToDoc(b)); }
  List<CategoryBudget> get categoryBudgets => _categoryBudgets.values.toList();

  void upsertCategoryAlias(CategoryAlias a) { _categoryAliases[a.aliasId] = a; _categoryAliasController.add(_categoryAliases.values.toList()); _enqueue('categoryAlias', a.aliasId, _categoryAliasToDoc(a)); }
  void deleteCategoryAlias(String id) { _categoryAliases.remove(id); _categoryAliasController.add(_categoryAliases.values.toList()); _enqueueDelete('categoryAlias', id, {}); }
  List<CategoryAlias> get categoryAliases => _categoryAliases.values.toList();

  void upsertRecurringExpense(RecurringExpense e) { _recurringExpenses[e.recurringExpenseId] = e; _recurringExpenseController.add(_recurringExpenses.values.toList()); _enqueue('recurringExpense', e.recurringExpenseId, _recurringExpenseToDoc(e)); }
  void deleteRecurringExpense(String id) { _recurringExpenses.remove(id); _recurringExpenseController.add(_recurringExpenses.values.toList()); _enqueueDelete('recurringExpense', id, {}); }
  List<RecurringExpense> get recurringExpenses => _recurringExpenses.values.toList();

  void upsertAiActionLog(AiActionLog l) { _aiActionLogs.add(l); _aiActionLogController.add(List.unmodifiable(_aiActionLogs)); _enqueue('aiActionLog', l.actionId, _aiActionLogToDoc(l)); }
  List<AiActionLog> get aiActionLogs => List.unmodifiable(_aiActionLogs);

  Map<String, dynamic> _goalToDoc(SavingGoal g) => {
    'goalId': g.goalId, 'userId': g.userId, 'name': g.name,
    'targetAmount': g.targetAmount, 'currentAmount': g.currentAmount,
    'currency': g.currency, 'color': g.color,
    if (g.deadline != null) 'deadline': g.deadline!.toIso8601String(),
  };
  Map<String, dynamic> _walletToDoc(WalletAccount w) => {'walletId': w.walletId, 'name': w.name, 'balance': w.balance, 'currency': w.currency, 'type': w.type, 'icon': w.icon, 'color': w.color};
}
