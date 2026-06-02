import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class SyncEntityCodec {
  SyncEntityCodec._();

  static Future<void> applyToStore(LocalStoreInterface store, SyncChange change) async {
    if (change.changeType == SyncChangeType.delete) {
      await _applyDelete(store, change);
      return;
    }

    final data = _normalizedData(change);
    switch (change.entityType) {
      case 'expense':
        await store.upsertExpense(Expense.fromEntity(ExpenseEntity.fromDocument(data)));
      case 'category':
        await store.upsertCategory(Category.fromEntity(CategoryEntity.fromDocument(data)));
      case 'budget':
        await store.upsertBudget(Budget.fromEntity(BudgetEntity.fromDocument(data)));
      case 'settings':
        await store.upsertSettings(UserSettingsEntity.fromDocument(data).toModel());
      case 'savingGoal':
        await store.upsertGoal(_savingGoalFromDocument(data));
      case 'wallet':
      case 'walletAccount':
        await store.upsertWallet(WalletAccount.fromEntity(WalletAccountEntity.fromDocument(data)));
      case 'transfer':
        await store.upsertTransfer(Transfer.fromEntity(TransferEntity.fromDocument(data)));
      case 'categoryBudget':
        await store.upsertCategoryBudget(_categoryBudgetFromDocument(data));
      case 'categoryAlias':
        await store.upsertCategoryAlias(_categoryAliasFromDocument(data));
      case 'recurringExpense':
        await store.upsertRecurringExpense(_recurringExpenseFromDocument(data));
      case 'aiActionLog':
        await store.upsertAiActionLog(_aiActionLogFromDocument(data));
    }
  }

  static Future<void> _applyDelete(LocalStoreInterface store, SyncChange change) async {
    switch (change.entityType) {
      case 'expense':
        await store.deleteExpense(change.entityId);
      case 'savingGoal':
        await store.deleteGoal(change.entityId);
      case 'categoryAlias':
        await store.deleteCategoryAlias(change.entityId);
      case 'recurringExpense':
        await store.deleteRecurringExpense(change.entityId);
    }
  }

  static Map<String, dynamic> _normalizedData(SyncChange change) {
    final data = Map<String, dynamic>.from(change.data);
    data.putIfAbsent(_idFieldFor(change.entityType), () => change.entityId);
    data.putIfAbsent('userId', () => change.userId);
    for (final key in const [
      'date',
      'createdAt',
      'updatedAt',
      'deadline',
      'startDate',
      'endDate',
      'lastGeneratedDate',
      'exchangeRatesUpdatedAt',
    ]) {
      final value = data[key];
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) data[key] = Timestamp.fromDate(parsed);
      }
    }
    return data;
  }

  static String _idFieldFor(String entityType) {
    switch (entityType) {
      case 'expense':
        return 'expenseId';
      case 'category':
        return 'categoryId';
      case 'budget':
      case 'categoryBudget':
        return 'budgetId';
      case 'savingGoal':
        return 'goalId';
      case 'wallet':
      case 'walletAccount':
        return 'walletId';
      case 'transfer':
        return 'transferId';
      case 'categoryAlias':
        return 'aliasId';
      case 'recurringExpense':
        return 'recurringExpenseId';
      case 'aiActionLog':
        return 'actionId';
      default:
        return '${entityType}Id';
    }
  }

  static SavingGoal _savingGoalFromDocument(Map<String, dynamic> data) {
    return SavingGoal(
      goalId: data['goalId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? UserSettings.defaultBaseCurrency,
      deadline: _dateOrNull(data['deadline']),
      color: data['color'] as int? ?? 0,
      createdAt: _dateOrNow(data['createdAt']),
      updatedAt: _dateOrNow(data['updatedAt']),
    );
  }

  static CategoryBudget _categoryBudgetFromDocument(Map<String, dynamic> data) {
    return CategoryBudget(
      budgetId: data['budgetId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      month: data['month'] as int? ?? 0,
      year: data['year'] as int? ?? 0,
      createdAt: _dateOrNow(data['createdAt']),
      updatedAt: _dateOrNow(data['updatedAt']),
    );
  }

  static CategoryAlias _categoryAliasFromDocument(Map<String, dynamic> data) {
    return CategoryAlias(
      aliasId: data['aliasId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      createdAt: _dateOrNow(data['createdAt']),
    );
  }

  static RecurringExpense _recurringExpenseFromDocument(Map<String, dynamic> data) {
    return RecurringExpense(
      recurringExpenseId: data['recurringExpenseId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? UserSettings.defaultBaseCurrency,
      categoryId: data['categoryId'] as String? ?? '',
      frequency: data['frequency'] as String? ?? 'monthly',
      startDate: _dateOrNow(data['startDate']),
      endDate: _dateOrNull(data['endDate']),
      lastGeneratedDate: _dateOrNull(data['lastGeneratedDate']),
      createdAt: _dateOrNow(data['createdAt']),
      updatedAt: _dateOrNow(data['updatedAt']),
    );
  }

  static AiActionLog _aiActionLogFromDocument(Map<String, dynamic> data) {
    return AiActionLog(
      actionId: data['actionId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      actionType: data['actionType'] as String? ?? 'ai_action',
      input: data['input'] as String? ?? '',
      output: data['output'] as String?,
      structuredJson: data['structuredJson'] == null
          ? null
          : Map<String, dynamic>.from(data['structuredJson'] as Map),
      success: data['success'] as bool? ?? false,
      error: data['error'] as String?,
      quotaUsed: data['quotaUsed'] as int? ?? 0,
      createdAt: _dateOrNow(data['createdAt']),
    );
  }

  static DateTime? _dateOrNull(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static DateTime _dateOrNow(Object? value) => _dateOrNull(value) ?? DateTime.now();
}
