// ignore_for_file: annotate_overrides, prefer_initializing_formals, unnecessary_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/local/drift/drift_tables.dart';
import 'package:expense_repository/src/local/local_store_interface.dart';
import 'package:expense_repository/src/sync/sync_change.dart';
import 'package:expense_repository/src/sync/sync_entity_codec.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart'
    show applyWorkaroundToOpenSqlite3OnOldAndroidVersions;

/// Drift (SQLite)-backed replacement for [LocalRepositoryStore].
///
/// Provides the same public API — identical method names, signatures, stream
/// controllers, and sync-change enqueueing logic. Data is persisted to
/// SQLite via Drift instead of living only in memory (Dart Maps).
///
/// In-memory caches are maintained for fast reactive reads; every write waits
/// for SQLite persistence before the cache emits a successful update.
class DriftLocalRepositoryStore implements LocalStoreInterface {
  // ---- identity -----------------------------------------------------------
  final String userId;

  // ---- Drift database -----------------------------------------------------
  final AppDatabase _db;
  final File? _syncQueueFile;
  late final Future<void> _ready;

  // ---- in-memory caches (kept in sync with DB) ----------------------------
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

  // ---- sync infrastructure ------------------------------------------------
  final List<SyncChange> pendingChanges = [];
  int _changeCounter = 0;
  bool _suppressSyncQueue = false;

  // ---- stream controllers -------------------------------------------------
  final _expenseController = StreamController<List<Expense>>.broadcast();
  final _categoryController = StreamController<List<Category>>.broadcast();
  final _budgetController = StreamController<Budget?>.broadcast();
  final _settingsController = StreamController<UserSettings>.broadcast();
  final _goalController = StreamController<List<SavingGoal>>.broadcast();
  final _walletController = StreamController<List<WalletAccount>>.broadcast();
  final _transferController = StreamController<List<Transfer>>.broadcast();
  final _categoryBudgetController = StreamController<List<CategoryBudget>>.broadcast();
  final _categoryAliasController = StreamController<List<CategoryAlias>>.broadcast();
  final _recurringExpenseController = StreamController<List<RecurringExpense>>.broadcast();
  final _aiActionLogController = StreamController<List<AiActionLog>>.broadcast();
  final _pendingController = StreamController<List<SyncChange>>.broadcast();

  // ---- constructor --------------------------------------------------------
  DriftLocalRepositoryStore({
    required this.userId,
    AppDatabase? database,
    File? syncQueueFile,
  }) : _db = database ?? AppDatabase(_openConnection()),
       _syncQueueFile = syncQueueFile {
    _ready = _loadFromDatabase();
  }

  // -----------------------------------------------------------------------
  // Public API — identical signatures to LocalRepositoryStore
  // -----------------------------------------------------------------------

  int get expensesLoadedVersion => _expenses.length;
  Future<void> get ready => _ready;

  // -- streams -------------------------------------------------------------
  Stream<List<Expense>> watchExpenses() => _readyListStream(() => expenses, _expenseController.stream);
  Stream<List<Category>> watchCategories() =>
      _readyListStream(() => categories, _categoryController.stream);
  Stream<Budget?> watchBudget() => _readyValueStream(() => budget, _budgetController.stream);
  Stream<UserSettings> watchSettings() async* {
    await ready;
    final current = settings;
    if (current != null) yield current;
    yield* _settingsController.stream;
  }

  Stream<List<SavingGoal>> watchGoals() => _readyListStream(() => goals, _goalController.stream);
  Stream<List<WalletAccount>> watchWallets() => _readyListStream(() => wallets, _walletController.stream);
  Stream<List<Transfer>> watchTransfers() => _readyListStream(() => transfers, _transferController.stream);
  Stream<List<CategoryBudget>> watchCategoryBudgets() =>
      _readyListStream(() => categoryBudgets, _categoryBudgetController.stream);
  Stream<List<CategoryAlias>> watchCategoryAliases() =>
      _readyListStream(() => categoryAliases, _categoryAliasController.stream);
  Stream<List<RecurringExpense>> watchRecurringExpenses() =>
      _readyListStream(() => recurringExpenses, _recurringExpenseController.stream);
  Stream<List<AiActionLog>> watchAiActionLogs() =>
      _readyListStream(() => aiActionLogs, _aiActionLogController.stream);
  Stream<List<SyncChange>> watchPendingChanges() =>
      _readyListStream(() => List.unmodifiable(pendingChanges), _pendingController.stream);

  // -- expenses ------------------------------------------------------------
  Future<void> upsertExpense(Expense e) async {
    await ready;
    await _persistExpense(e);
    _expenses[e.expenseId] = e;
    _emitExpenses();
    _enqueue('expense', e.expenseId, e.toEntity().toDocument());
  }

  Future<void> deleteExpense(String id) async {
    await ready;
    await _deleteExpenseFromDb(id);
    _expenses.remove(id);
    _emitExpenses();
    _enqueueDelete('expense', id, {});
  }

  List<Expense> get expenses => _expenses.values.toList();

  // -- categories ----------------------------------------------------------
  Future<void> upsertCategory(Category c) async {
    await ready;
    await _persistCategory(c);
    _categories[c.categoryId] = c;
    _categoryController.add(_categories.values.toList());
    _enqueue('category', c.categoryId, c.toEntity().toDocument());
  }

  List<Category> get categories => _categories.values.toList();

  // -- budget --------------------------------------------------------------
  Future<void> upsertBudget(Budget b) async {
    await ready;
    await _persistBudget(b);
    _budgets[b.budgetId] = b;
    _budgetController.add(b);
    _enqueue('budget', b.budgetId, b.toEntity().toDocument());
  }

  Budget? get budget => _budgets.values.isNotEmpty ? _budgets.values.first : null;
  List<Budget> get budgets => _budgets.values.toList();

  // -- settings ------------------------------------------------------------
  Future<void> upsertSettings(UserSettings s) async {
    await ready;
    await _persistSettings(s);
    _settings['profile'] = s;
    _settingsController.add(s);
    _enqueue('settings', 'profile', s.toEntity().toDocument());
  }

  UserSettings? get settings => _settings['profile'];

  // -- goals ---------------------------------------------------------------
  Future<void> upsertGoal(SavingGoal g) async {
    await ready;
    await _persistGoal(g);
    _goals[g.goalId] = g;
    _goalController.add(_goals.values.toList());
    _enqueue('savingGoal', g.goalId, _goalToDoc(g));
  }

  Future<void> deleteGoal(String id) async {
    await ready;
    await _deleteGoalFromDb(id);
    _goals.remove(id);
    _goalController.add(_goals.values.toList());
    _enqueueDelete('savingGoal', id, {});
  }

  List<SavingGoal> get goals => _goals.values.toList();

  // -- wallets -------------------------------------------------------------
  Future<void> upsertWallet(WalletAccount w) async {
    await ready;
    await _persistWallet(w);
    _wallets[w.walletId] = w;
    _walletController.add(_wallets.values.toList());
    _enqueue('walletAccount', w.walletId, _walletToDoc(w));
  }

  List<WalletAccount> get wallets => _wallets.values.toList();

  // -- transfers -----------------------------------------------------------
  Future<void> upsertTransfer(Transfer t) async {
    await ready;
    await _persistTransfer(t);
    _transfers[t.transferId] = t;
    _transferController.add(_transfers.values.toList());
    _enqueue('transfer', t.transferId, _transferToDoc(t));
  }

  List<Transfer> get transfers => _transfers.values.toList();

  // -- category budgets ----------------------------------------------------
  Future<void> upsertCategoryBudget(CategoryBudget b) async {
    await ready;
    await _persistCategoryBudget(b);
    _categoryBudgets[b.budgetId] = b;
    _categoryBudgetController.add(_categoryBudgets.values.toList());
    _enqueue('categoryBudget', b.budgetId, _categoryBudgetToDoc(b));
  }

  List<CategoryBudget> get categoryBudgets => _categoryBudgets.values.toList();

  // -- category aliases -----------------------------------------------------
  Future<void> upsertCategoryAlias(CategoryAlias a) async {
    await ready;
    await _persistCategoryAlias(a);
    _categoryAliases[a.aliasId] = a;
    _categoryAliasController.add(_categoryAliases.values.toList());
    _enqueue('categoryAlias', a.aliasId, _categoryAliasToDoc(a));
  }

  Future<void> deleteCategoryAlias(String id) async {
    await ready;
    await _deleteCategoryAliasFromDb(id);
    _categoryAliases.remove(id);
    _categoryAliasController.add(_categoryAliases.values.toList());
    _enqueueDelete('categoryAlias', id, {});
  }

  List<CategoryAlias> get categoryAliases => _categoryAliases.values.toList();

  // -- recurring expenses ---------------------------------------------------
  Future<void> upsertRecurringExpense(RecurringExpense e) async {
    await ready;
    await _persistRecurringExpense(e);
    _recurringExpenses[e.recurringExpenseId] = e;
    _recurringExpenseController.add(_recurringExpenses.values.toList());
    _enqueue('recurringExpense', e.recurringExpenseId, _recurringExpenseToDoc(e));
  }

  Future<void> deleteRecurringExpense(String id) async {
    await ready;
    await _deleteRecurringExpenseFromDb(id);
    _recurringExpenses.remove(id);
    _recurringExpenseController.add(_recurringExpenses.values.toList());
    _enqueueDelete('recurringExpense', id, {});
  }

  List<RecurringExpense> get recurringExpenses => _recurringExpenses.values.toList();

  // -- AI action logs -------------------------------------------------------
  Future<void> upsertAiActionLog(AiActionLog l) async {
    await ready;
    final safeLog = AiActionLogPrivacy.sanitize(l);
    await _persistAiActionLog(safeLog);
    _aiActionLogs.add(safeLog);
    _aiActionLogController.add(List.unmodifiable(_aiActionLogs));
    _enqueue('aiActionLog', safeLog.actionId, _aiActionLogToDoc(safeLog));
  }

  List<AiActionLog> get aiActionLogs => List.unmodifiable(_aiActionLogs);

  // -- sync helpers --------------------------------------------------------
  void markUploadedChanges(List<String> ids) {
    pendingChanges.removeWhere((c) => ids.contains(c.id) || ids.contains(c.clientChangeId));
    _pendingController.add(List.unmodifiable(pendingChanges));
    _persistPendingChanges();
  }

  void markSyncChangesUpdated() {
    _pendingController.add(List.unmodifiable(pendingChanges));
    _persistPendingChanges();
  }

  Future<void> applyRemoteChange(SyncChange change) async {
    _suppressSyncQueue = true;
    try {
      await SyncEntityCodec.applyToStore(this, change);
    } finally {
      _suppressSyncQueue = false;
    }
  }

  // -----------------------------------------------------------------------
  // Private: stream emission
  // -----------------------------------------------------------------------

  Stream<List<T>> _readyListStream<T>(List<T> Function() current, Stream<List<T>> changes) async* {
    await ready;
    yield List<T>.unmodifiable(current());
    yield* changes;
  }

  Stream<T> _readyValueStream<T>(T Function() current, Stream<T> changes) async* {
    await ready;
    yield current();
    yield* changes;
  }

  void _emitExpenses() {
    final list = _expenses.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    _expenseController.add(list);
  }

  // -----------------------------------------------------------------------
  // Private: sync enqueueing (identical to LocalRepositoryStore)
  // -----------------------------------------------------------------------

  void _enqueue(String entityType, String entityId, Map<String, dynamic> data) {
    if (_suppressSyncQueue) return;
    pendingChanges.add(
      SyncChange(
        id: 'change-${++_changeCounter}',
        entityType: entityType,
        entityId: entityId,
        changeType: SyncChangeType.upsert,
        data: data,
        clientChangeId: '$entityType-$entityId-$_changeCounter',
        deviceId: 'flutter-$userId',
        userId: userId,
        timestamp: DateTime.now(),
      ),
    );
    _pendingController.add(List.unmodifiable(pendingChanges));
    _persistPendingChanges();
  }

  void _enqueueDelete(String entityType, String entityId, Map<String, dynamic> data) {
    if (_suppressSyncQueue) return;
    pendingChanges.add(
      SyncChange(
        id: 'change-${++_changeCounter}',
        entityType: entityType,
        entityId: entityId,
        changeType: SyncChangeType.delete,
        data: data,
        clientChangeId: '$entityType-$entityId-$_changeCounter',
        deviceId: 'flutter-$userId',
        userId: userId,
        timestamp: DateTime.now(),
      ),
    );
    _pendingController.add(List.unmodifiable(pendingChanges));
    _persistPendingChanges();
  }

  // -----------------------------------------------------------------------
  // Private: serialisers
  // -----------------------------------------------------------------------

  Map<String, dynamic> _goalToDoc(SavingGoal g) => {
    'goalId': g.goalId,
    'userId': g.userId,
    'name': g.name,
    'targetAmount': g.targetAmount,
    'currentAmount': g.currentAmount,
    'currency': g.currency,
    'color': g.color,
    if (g.deadline != null) 'deadline': g.deadline!.toIso8601String(),
  };

  Map<String, dynamic> _walletToDoc(WalletAccount w) => w.toEntity().toDocument();

  Map<String, dynamic> _transferToDoc(Transfer t) => {
    'transferId': t.transferId,
    'userId': t.userId,
    'fromWalletId': t.fromWalletId,
    'toWalletId': t.toWalletId,
    'amount': t.amount,
    if (t.note != null) 'note': t.note,
    'date': t.date.toIso8601String(),
    'createdAt': t.createdAt.toIso8601String(),
  };

  Map<String, dynamic> _categoryBudgetToDoc(CategoryBudget b) => {
    'budgetId': b.budgetId,
    'userId': b.userId,
    'categoryId': b.categoryId,
    'amount': b.amount,
    'month': b.month,
    'year': b.year,
    'createdAt': b.createdAt.toIso8601String(),
    'updatedAt': b.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _categoryAliasToDoc(CategoryAlias a) => {
    'aliasId': a.aliasId,
    'userId': a.userId,
    'name': a.name,
    'categoryId': a.categoryId,
    'createdAt': a.createdAt.toIso8601String(),
  };

  Map<String, dynamic> _recurringExpenseToDoc(RecurringExpense e) => {
    'recurringExpenseId': e.recurringExpenseId,
    'userId': e.userId,
    'name': e.name,
    'amount': e.amount,
    'currency': e.currency,
    'categoryId': e.categoryId,
    'frequency': e.frequency,
    'startDate': e.startDate.toIso8601String(),
    if (e.endDate != null) 'endDate': e.endDate!.toIso8601String(),
    if (e.lastGeneratedDate != null) 'lastGeneratedDate': e.lastGeneratedDate!.toIso8601String(),
    'createdAt': e.createdAt.toIso8601String(),
    'updatedAt': e.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _aiActionLogToDoc(AiActionLog l) => {
    'actionId': l.actionId,
    'userId': l.userId,
    'actionType': l.actionType,
    'input': l.input,
    if (l.output != null) 'output': l.output,
    if (l.structuredJson != null) 'structuredJson': l.structuredJson,
    'success': l.success,
    if (l.error != null) 'error': l.error,
    'quotaUsed': l.quotaUsed,
    'createdAt': l.createdAt.toIso8601String(),
  };

  // -----------------------------------------------------------------------
  // Private: Drift persistence
  // -----------------------------------------------------------------------

  Future<void> _persistExpense(Expense e) async {
    await _db.into(_db.expenses).insertOnConflictUpdate(_modelToDriftExpense(e));
  }

  Future<void> _deleteExpenseFromDb(String id) async {
    await (_db.delete(_db.expenses)..where((t) => t.expenseId.equals(id))).go();
  }

  Future<void> _persistCategory(Category c) async {
    await _db.into(_db.categories).insertOnConflictUpdate(_modelToDriftCategory(c));
  }

  Future<void> _persistBudget(Budget b) async {
    await _db.into(_db.budgets).insertOnConflictUpdate(_modelToDriftBudget(b));
  }

  Future<void> _persistSettings(UserSettings s) async {
    await _db.into(_db.settings).insertOnConflictUpdate(_modelToDriftSettings(s));
  }

  Future<void> _persistGoal(SavingGoal g) async {
    await _db.into(_db.goals).insertOnConflictUpdate(_modelToDriftSavingGoal(g));
  }

  Future<void> _deleteGoalFromDb(String id) async {
    await (_db.delete(_db.goals)..where((t) => t.goalId.equals(id))).go();
  }

  Future<void> _persistWallet(WalletAccount w) async {
    await _db.into(_db.wallets).insertOnConflictUpdate(_modelToDriftWallet(w));
  }

  Future<void> _persistTransfer(Transfer t) async {
    await _db.into(_db.transfers).insertOnConflictUpdate(_modelToDriftTransfer(t));
  }

  Future<void> _persistCategoryBudget(CategoryBudget b) async {
    await _db
        .into(_db.categoryBudgets)
        .insertOnConflictUpdate(_modelToDriftCategoryBudget(b));
  }

  Future<void> _persistCategoryAlias(CategoryAlias a) async {
    await _db
        .into(_db.categoryAliases)
        .insertOnConflictUpdate(_modelToDriftCategoryAlias(a));
  }

  Future<void> _deleteCategoryAliasFromDb(String id) async {
    await (_db.delete(_db.categoryAliases)..where((t) => t.aliasId.equals(id))).go();
  }

  Future<void> _persistRecurringExpense(RecurringExpense e) async {
    await _db
        .into(_db.recurringExpenses)
        .insertOnConflictUpdate(_modelToDriftRecurringExpense(e));
  }

  Future<void> _deleteRecurringExpenseFromDb(String id) async {
    await (_db.delete(
      _db.recurringExpenses,
    )..where((t) => t.recurringExpenseId.equals(id))).go();
  }

  Future<void> _persistAiActionLog(AiActionLog l) async {
    await _db.into(_db.aiActionLogs).insertOnConflictUpdate(_modelToDriftAiActionLog(l));
  }

  // -----------------------------------------------------------------------
  // Private: model ↔ Drift data class conversions
  // -----------------------------------------------------------------------

  DriftExpense _modelToDriftExpense(Expense e) => DriftExpense(
    expenseId: e.expenseId,
    userId: e.userId,
    categoryId: e.categoryId,
    categoryName: e.categoryName,
    categoryIcon: e.categoryIcon,
    categoryColor: e.categoryColor,
    date: e.date,
    amount: e.amount,
    description: e.description,
    merchant: e.merchant,
    tags: e.tags,
    paymentMethod: e.paymentMethod.storageValue,
    currency: e.currency,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
    source: e.source.name,
    walletAccountId: e.walletAccountId,
    walletAccountName: e.walletAccountName,
    recurringExpenseId: e.recurringExpenseId,
    aiActionId: e.aiActionId,
    moneySnapshot: e.moneySnapshot,
  );

  Expense _driftExpenseToModel(DriftExpense d) => Expense(
    expenseId: d.expenseId,
    userId: d.userId,
    category: Category.empty.copyWith(
      categoryId: d.categoryId,
      name: d.categoryName,
      icon: d.categoryIcon,
      color: d.categoryColor,
    ),
    categoryId: d.categoryId,
    categoryName: d.categoryName,
    categoryIcon: d.categoryIcon,
    categoryColor: d.categoryColor,
    date: d.date,
    amount: d.amount,
    description: d.description,
    merchant: d.merchant,
    tags: d.tags,
    paymentMethod: PaymentMethod.fromStorageValue(d.paymentMethod),
    currency: d.currency,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
    source: ExpenseSource.values.firstWhere(
      (s) => s.name == d.source,
      orElse: () => ExpenseSource.manual,
    ),
    walletAccountId: d.walletAccountId,
    walletAccountName: d.walletAccountName,
    recurringExpenseId: d.recurringExpenseId,
    aiActionId: d.aiActionId,
    moneySnapshot: d.moneySnapshot,
  );

  DriftCategory _modelToDriftCategory(Category c) => DriftCategory(
    categoryId: c.categoryId,
    userId: c.userId,
    name: c.name,
    totalExpenses: c.totalExpenses,
    icon: c.icon,
    color: c.color,
    isArchived: c.isArchived,
    createdAt: c.createdAt,
    updatedAt: c.updatedAt,
  );

  Category _driftCategoryToModel(DriftCategory d) => Category(
    categoryId: d.categoryId,
    userId: d.userId,
    name: d.name,
    totalExpenses: d.totalExpenses,
    icon: d.icon,
    color: d.color,
    isArchived: d.isArchived,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  DriftBudget _modelToDriftBudget(Budget b) => DriftBudget(
    budgetId: b.budgetId,
    userId: b.userId,
    month: b.month,
    year: b.year,
    amount: b.amount,
    currency: b.currency,
    warningThresholdPercent: b.warningThresholdPercent,
    createdAt: b.createdAt,
    updatedAt: b.updatedAt,
  );

  Budget _driftBudgetToModel(DriftBudget d) => Budget(
    budgetId: d.budgetId,
    userId: d.userId,
    month: d.month,
    year: d.year,
    amount: d.amount,
    currency: d.currency,
    warningThresholdPercent: d.warningThresholdPercent,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  DriftSettings _modelToDriftSettings(UserSettings s) => DriftSettings(
    userId: s.userId,
    appDisplayName: s.appDisplayName,
    languagePreference: s.languagePreference.storageValue,
    baseCurrency: s.baseCurrency,
    supportedCurrencies: s.supportedCurrencies,
    conversionRates: s.conversionRates,
    defaultPaymentMethod: s.defaultPaymentMethod.storageValue,
    notificationSettings: <String, dynamic>{
      'budgetAlerts': s.notificationSettings.budgetAlerts,
      'recurringReminders': s.notificationSettings.recurringReminders,
    },
    onboardingCompleted: s.onboardingCompleted,
    onboardingVersion: s.onboardingVersion,
    guidedTourCompletedVersion: s.guidedTourCompletedVersion,
    guidedTourSkippedVersion: s.guidedTourSkippedVersion,
    guidedTourLastStepId: s.guidedTourLastStepId,
    exchangeRatesUpdatedAt: s.exchangeRatesUpdatedAt,
    updatedAt: s.updatedAt,
  );

  UserSettings _driftSettingsToModel(DriftSettings d) {
    final ns = d.notificationSettings;
    return UserSettings(
      userId: d.userId,
      appDisplayName: d.appDisplayName,
      languagePreference: LanguagePreference.fromStorageValue(d.languagePreference),
      baseCurrency: d.baseCurrency,
      supportedCurrencies: d.supportedCurrencies,
      conversionRates: d.conversionRates,
      defaultPaymentMethod: PaymentMethod.fromStorageValue(d.defaultPaymentMethod),
      notificationSettings: NotificationSettings(
        budgetAlerts: ns['budgetAlerts'] as bool? ?? true,
        recurringReminders: ns['recurringReminders'] as bool? ?? true,
      ),
      onboardingCompleted: d.onboardingCompleted,
      onboardingVersion: d.onboardingVersion,
      guidedTourCompletedVersion: d.guidedTourCompletedVersion,
      guidedTourSkippedVersion: d.guidedTourSkippedVersion,
      guidedTourLastStepId: d.guidedTourLastStepId,
      exchangeRatesUpdatedAt: d.exchangeRatesUpdatedAt,
      updatedAt: d.updatedAt,
    );
  }

  DriftSavingGoal _modelToDriftSavingGoal(SavingGoal g) => DriftSavingGoal(
    goalId: g.goalId,
    userId: g.userId,
    name: g.name,
    targetAmount: g.targetAmount,
    currentAmount: g.currentAmount,
    currency: g.currency,
    deadline: g.deadline,
    color: g.color,
    isArchived: false,
    createdAt: g.createdAt,
    updatedAt: g.updatedAt,
  );

  SavingGoal _driftSavingGoalToModel(DriftSavingGoal d) => SavingGoal(
    goalId: d.goalId,
    userId: d.userId,
    name: d.name,
    targetAmount: d.targetAmount,
    currentAmount: d.currentAmount,
    currency: d.currency,
    deadline: d.deadline,
    color: d.color,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  DriftWallet _modelToDriftWallet(WalletAccount w) => DriftWallet(
    walletId: w.walletId,
    userId: w.userId,
    name: w.name,
    type: w.type,
    balance: w.balance,
    currency: w.currency,
    icon: w.icon,
    color: w.color,
    createdAt: w.createdAt,
    updatedAt: w.updatedAt,
  );

  WalletAccount _driftWalletToModel(DriftWallet d) => WalletAccount(
    walletId: d.walletId,
    userId: d.userId,
    name: d.name,
    type: d.type,
    balance: d.balance,
    currency: d.currency,
    icon: d.icon,
    color: d.color,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  DriftTransfer _modelToDriftTransfer(Transfer t) => DriftTransfer(
    transferId: t.transferId,
    userId: t.userId,
    fromWalletId: t.fromWalletId,
    toWalletId: t.toWalletId,
    amount: t.amount,
    note: t.note,
    date: t.date,
    createdAt: t.createdAt,
  );

  Transfer _driftTransferToModel(DriftTransfer d) => Transfer(
    transferId: d.transferId,
    userId: d.userId,
    fromWalletId: d.fromWalletId,
    toWalletId: d.toWalletId,
    amount: d.amount,
    note: d.note,
    date: d.date,
    createdAt: d.createdAt,
  );

  DriftCategoryBudget _modelToDriftCategoryBudget(CategoryBudget b) => DriftCategoryBudget(
    budgetId: b.budgetId,
    userId: b.userId,
    categoryId: b.categoryId,
    amount: b.amount,
    month: b.month,
    year: b.year,
    createdAt: b.createdAt,
    updatedAt: b.updatedAt,
  );

  CategoryBudget _driftCategoryBudgetToModel(DriftCategoryBudget d) => CategoryBudget(
    budgetId: d.budgetId,
    userId: d.userId,
    categoryId: d.categoryId,
    amount: d.amount,
    month: d.month,
    year: d.year,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  // -- CategoryAlias --------------------------------------------------------
  DriftCategoryAlias _modelToDriftCategoryAlias(CategoryAlias a) => DriftCategoryAlias(
    aliasId: a.aliasId,
    userId: a.userId,
    name: a.name,
    categoryId: a.categoryId,
    createdAt: a.createdAt,
  );

  CategoryAlias _driftCategoryAliasToModel(DriftCategoryAlias d) => CategoryAlias(
    aliasId: d.aliasId,
    userId: d.userId,
    name: d.name,
    categoryId: d.categoryId,
    createdAt: d.createdAt,
  );

  // -- RecurringExpense -----------------------------------------------------
  DriftRecurringExpense _modelToDriftRecurringExpense(RecurringExpense e) => DriftRecurringExpense(
    recurringExpenseId: e.recurringExpenseId,
    userId: e.userId,
    name: e.name,
    amount: e.amount,
    currency: e.currency,
    categoryId: e.categoryId,
    frequency: e.frequency,
    startDate: e.startDate,
    endDate: e.endDate,
    lastGeneratedDate: e.lastGeneratedDate,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );

  RecurringExpense _driftRecurringExpenseToModel(DriftRecurringExpense d) => RecurringExpense(
    recurringExpenseId: d.recurringExpenseId,
    userId: d.userId,
    name: d.name,
    amount: d.amount,
    currency: d.currency,
    categoryId: d.categoryId,
    frequency: d.frequency,
    startDate: d.startDate,
    endDate: d.endDate,
    lastGeneratedDate: d.lastGeneratedDate,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  // -- AiActionLog ----------------------------------------------------------
  DriftAiActionLog _modelToDriftAiActionLog(AiActionLog l) => DriftAiActionLog(
    actionId: l.actionId,
    userId: l.userId,
    actionType: l.actionType,
    input: l.input,
    output: l.output,
    structuredJson: l.structuredJson,
    success: l.success,
    error: l.error,
    quotaUsed: l.quotaUsed,
    createdAt: l.createdAt,
  );

  AiActionLog _driftAiActionLogToModel(DriftAiActionLog d) => AiActionLogPrivacy.sanitize(
    AiActionLog(
      actionId: d.actionId,
      userId: d.userId,
      actionType: d.actionType,
      input: d.input,
      output: d.output,
      structuredJson: d.structuredJson,
      success: d.success,
      error: d.error,
      quotaUsed: d.quotaUsed,
      createdAt: d.createdAt,
    ),
  );

  // -----------------------------------------------------------------------
  // Private: initial load from Drift into in-memory caches
  // -----------------------------------------------------------------------

  Future<void> _loadFromDatabase() async {
    try {
      await _loadPendingChanges();

      final expenseRows = await _db.select(_db.expenses).get();
      for (final row in expenseRows) {
        _expenses[row.expenseId] = _driftExpenseToModel(row);
      }

      final categoryRows = await _db.select(_db.categories).get();
      for (final row in categoryRows) {
        _categories[row.categoryId] = _driftCategoryToModel(row);
      }

      final budgetRows = await _db.select(_db.budgets).get();
      for (final row in budgetRows) {
        _budgets[row.budgetId] = _driftBudgetToModel(row);
      }

      final settingsRows = await _db.select(_db.settings).get();
      if (settingsRows.isNotEmpty) {
        _settings['profile'] = _driftSettingsToModel(settingsRows.first);
      }

      final goalRows = await _db.select(_db.goals).get();
      for (final row in goalRows) {
        _goals[row.goalId] = _driftSavingGoalToModel(row);
      }

      final walletRows = await _db.select(_db.wallets).get();
      for (final row in walletRows) {
        _wallets[row.walletId] = _driftWalletToModel(row);
      }

      final transferRows = await _db.select(_db.transfers).get();
      for (final row in transferRows) {
        _transfers[row.transferId] = _driftTransferToModel(row);
      }

      final categoryBudgetRows = await _db.select(_db.categoryBudgets).get();
      for (final row in categoryBudgetRows) {
        _categoryBudgets[row.budgetId] = _driftCategoryBudgetToModel(row);
      }

      final categoryAliasRows = await _db.select(_db.categoryAliases).get();
      for (final row in categoryAliasRows) {
        _categoryAliases[row.aliasId] = _driftCategoryAliasToModel(row);
      }

      final recurringExpenseRows = await _db.select(_db.recurringExpenses).get();
      for (final row in recurringExpenseRows) {
        _recurringExpenses[row.recurringExpenseId] = _driftRecurringExpenseToModel(row);
      }

      final aiActionLogRows = await _db.select(_db.aiActionLogs).get();
      for (final row in aiActionLogRows) {
        _aiActionLogs.add(_driftAiActionLogToModel(row));
      }

      // Emit initial state
      _emitExpenses();
      _categoryController.add(_categories.values.toList());
      if (_settings.containsKey('profile')) {
        _settingsController.add(_settings['profile']!);
      }
      _goalController.add(_goals.values.toList());
      _walletController.add(_wallets.values.toList());
      _transferController.add(_transfers.values.toList());
      _categoryBudgetController.add(_categoryBudgets.values.toList());
      _categoryAliasController.add(_categoryAliases.values.toList());
      _recurringExpenseController.add(_recurringExpenses.values.toList());
      _aiActionLogController.add(List.unmodifiable(_aiActionLogs));
      _pendingController.add(List.unmodifiable(pendingChanges));

      final b = budget;
      if (b != null) _budgetController.add(b);
    } catch (_) {
      // Database load failed — caches remain empty, streams will emit
      // when data is upserted later.
      rethrow;
    }
  }

  Future<void> _loadPendingChanges() async {
    try {
      final file = await _resolveSyncQueueFile();
      if (!file.existsSync()) return;
      final raw = file.readAsStringSync();
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      pendingChanges
        ..clear()
        ..addAll(
          decoded.whereType<Map<dynamic, dynamic>>().map(
            (item) => SyncChange.fromJson(Map<String, dynamic>.from(item)),
          ),
        );
      _changeCounter = pendingChanges.fold<int>(0, (max, change) {
        final parsed = int.tryParse(change.id.split('-').last);
        if (parsed == null || parsed <= max) return max;
        return parsed;
      });
    } catch (_) {
      pendingChanges.clear();
    }
  }

  void _persistPendingChanges() {
    try {
      final payload = jsonEncode(pendingChanges.map((change) => change.toJson()).toList());
      final syncQueueFile = _syncQueueFile;
      if (syncQueueFile != null) {
        syncQueueFile.parent.createSync(recursive: true);
        syncQueueFile.writeAsStringSync(payload);
        return;
      }
      _resolveSyncQueueFile().then((file) {
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(payload);
      });
    } catch (_) {}
  }

  Future<File> _resolveSyncQueueFile() async {
    final override = _syncQueueFile;
    if (override != null) return override;
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'expense_tracker_$userId.sync_queue.json'));
  }

  /// Release resources when the store is no longer needed.
  Future<void> dispose() async {
    await _expenseController.close();
    await _categoryController.close();
    await _budgetController.close();
    await _settingsController.close();
    await _goalController.close();
    await _walletController.close();
    await _transferController.close();
    await _categoryBudgetController.close();
    await _categoryAliasController.close();
    await _recurringExpenseController.close();
    await _aiActionLogController.close();
    await _pendingController.close();
    await _db.close();
  }
}

// ---------------------------------------------------------------------------
// Static helper — creates a Drift-native database connection
// ---------------------------------------------------------------------------

drift.LazyDatabase _openConnection() {
  return drift.LazyDatabase(() async {
    // Ensure the native SQLite library is loaded (provided by
    // sqlite3_flutter_libs).
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'expenses_tracker.db');
    return NativeDatabase.createInBackground(File(dbPath));
  });
}
