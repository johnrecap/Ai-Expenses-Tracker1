import 'package:expense_repository/src/models/expense_filter.dart';
import 'package:expense_repository/src/models/language_preference.dart';
import 'package:expense_repository/src/models/money_snapshot.dart';
import 'package:expense_repository/src/models/payment_method.dart';
import '../entities/expense_entity.dart';
import 'category.dart';
import 'sync_status.dart';

class Expense {
  String expenseId;
  String userId;
  Category _category;
  String categoryId;
  String categoryName;
  String categoryIcon;
  int categoryColor;
  DateTime date;
  double amount;
  String description;
  String? merchant;
  List<String> tags;
  PaymentMethod paymentMethod;
  String currency;
  DateTime createdAt;
  DateTime updatedAt;
  ExpenseSource source;
  String? walletAccountId;
  String? walletAccountName;
  String? recurringExpenseId;
  String? aiActionId;
  MoneySnapshot? moneySnapshot;
  SyncStatus syncStatus;
  SyncStatusReason syncStatusReason;

  Expense({
    required this.expenseId,
    required Category category,
    required this.date,
    required num amount,
    String? userId,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? categoryColor,
    String? description,
    String? merchant,
    List<String> tags = const [],
    PaymentMethod? paymentMethod,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    ExpenseSource? source,
    this.walletAccountId,
    this.walletAccountName,
    this.recurringExpenseId,
    this.aiActionId,
    this.moneySnapshot,
    SyncStatus? syncStatus,
    SyncStatusReason? syncStatusReason,
  })  : userId = userId ?? '',
        _category = category,
        categoryId = categoryId ?? category.categoryId,
        categoryName = categoryName ?? category.name,
        categoryIcon = categoryIcon ?? category.icon,
        categoryColor = categoryColor ?? category.color,
        amount = amount.toDouble(),
        description = description ?? '',
        merchant = _normalizeMerchant(merchant),
        tags = _normalizeTags(tags),
        paymentMethod = paymentMethod ?? PaymentMethod.cash,
        currency = currency ?? 'EGP',
        createdAt = createdAt ?? date,
        updatedAt = updatedAt ?? date,
        source = source ?? ExpenseSource.manual,
        syncStatus = syncStatus ?? SyncStatus.synced,
        syncStatusReason = syncStatusReason ?? SyncStatusReason.queued;

  Category get category => _category;
  set category(Category value) {
    _category = value;
    categoryId = value.categoryId;
    categoryName = value.name;
    categoryIcon = value.icon;
    categoryColor = value.color;
  }

  static final empty = Expense(
    expenseId: '', category: Category.empty, date: DateTime.now(),
    amount: 0, userId: '', description: '', tags: const [],
    paymentMethod: PaymentMethod.cash, currency: 'EGP', source: ExpenseSource.manual,
  );

  ExpenseEntity toEntity() => ExpenseEntity(
    expenseId: expenseId, userId: userId, categoryId: categoryId,
    categoryName: categoryName, categoryIcon: categoryIcon, categoryColor: categoryColor,
    date: date, amount: amount, description: description, merchant: merchant,
    tags: tags, paymentMethod: paymentMethod.storageValue, currency: currency,
    createdAt: createdAt, updatedAt: updatedAt, source: source.name,
    walletAccountId: walletAccountId, walletAccountName: walletAccountName,
    recurringExpenseId: recurringExpenseId, aiActionId: aiActionId,
    moneySnapshot: moneySnapshot,
  );

  static Expense fromEntity(ExpenseEntity entity) => Expense(
    expenseId: entity.expenseId, userId: entity.userId,
    category: Category.empty.copyWith(categoryId: entity.categoryId, name: entity.categoryName, icon: entity.categoryIcon, color: entity.categoryColor),
    categoryId: entity.categoryId, categoryName: entity.categoryName,
    categoryIcon: entity.categoryIcon, categoryColor: entity.categoryColor,
    date: entity.date, amount: entity.amount, description: entity.description,
    merchant: entity.merchant, tags: entity.tags,
    paymentMethod: PaymentMethod.fromStorageValue(entity.paymentMethod),
    currency: entity.currency, createdAt: entity.createdAt, updatedAt: entity.updatedAt,
    source: ExpenseSource.values.firstWhere((e) => e.name == entity.source, orElse: () => ExpenseSource.manual),
    walletAccountId: entity.walletAccountId, walletAccountName: entity.walletAccountName,
    recurringExpenseId: entity.recurringExpenseId, aiActionId: entity.aiActionId,
    moneySnapshot: entity.moneySnapshot,
  );

  static String? _normalizeMerchant(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static List<String> _normalizeTags(List<String> values) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final value in values) {
      final tag = value.trim();
      if (tag.isEmpty) continue;
      final key = tag.toLowerCase();
      if (seen.add(key)) normalized.add(tag);
    }
    return List.unmodifiable(normalized);
  }
}
