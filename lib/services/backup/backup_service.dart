import 'dart:convert';
import 'package:expense_repository/expense_repository.dart';

const currentBackupSchemaVersion = 1;

class BackupCollection {
  static const expenses = 'expenses';
  static const categories = 'categories';
  static const budgets = 'budgets';
  static const wallets = 'wallets';
  static const transfers = 'transfers';
  static const savingGoals = 'savingGoals';
  static const recurringExpenses = 'recurringExpenses';
  static const settings = 'settings';
  static const categoryBudgets = 'categoryBudgets';
  static const categoryAliases = 'categoryAliases';

  static const supported = [expenses, categories, budgets, wallets, transfers, savingGoals, recurringExpenses, settings, categoryBudgets, categoryAliases];
}

class BackupParseException implements Exception {
  const BackupParseException(this.message);
  final String message;
  @override
  String toString() => 'BackupParseException: $message';
}

class BackupManifest {
  final int schemaVersion;
  final String appVersion;
  final DateTime createdAt;
  final String sourceUserId;
  final List<String> collections;
  final Map<String, int> counts;
  final List<String> warnings;

  const BackupManifest({
    required this.schemaVersion, required this.appVersion, required this.createdAt,
    required this.sourceUserId, required this.collections, required this.counts,
    this.warnings = const [],
  });

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion, 'appVersion': appVersion,
    'createdAt': createdAt.toIso8601String(), 'sourceUserId': sourceUserId,
    'collections': collections, 'counts': counts, 'warnings': warnings,
  };

  static BackupManifest fromJson(Map<String, Object?> json) {
    final sv = _int(json['schemaVersion']);
    if (sv == null) throw const BackupParseException('Schema version missing.');
    if (sv < 1 || sv > currentBackupSchemaVersion) throw BackupParseException('Schema $sv not supported.');
    return BackupManifest(
      schemaVersion: sv, appVersion: json['appVersion'] as String? ?? 'unknown',
      createdAt: _date(json['createdAt']) ?? DateTime.now(),
      sourceUserId: json['sourceUserId'] as String? ?? '',
      collections: _stringList(json['collections']),
      counts: _intMap(json['counts']), warnings: _stringList(json['warnings']),
    );
  }
}

class BackupDocument {
  final BackupManifest manifest;
  final List<Expense> expenses;
  final List<Category> categories;
  final List<Budget> budgets;
  final List<CategoryBudget> categoryBudgets;
  final List<RecurringExpense> recurringExpenses;
  final List<SavingGoal> savingGoals;
  final UserSettings? settings;
  final List<CategoryAlias> categoryAliases;
  final List<WalletAccount> wallets;
  final List<Transfer> transfers;

  const BackupDocument({
    required this.manifest, this.expenses = const [], this.categories = const [],
    this.budgets = const [], this.categoryBudgets = const [],
    this.recurringExpenses = const [], this.savingGoals = const [],
    this.settings, this.categoryAliases = const [], this.wallets = const [],
    this.transfers = const [],
  });

  String toJsonString() => jsonEncode(toJson());

  Map<String, Object?> toJson() => {
    'manifest': manifest.toJson(),
    'data': {
      BackupCollection.expenses: expenses.map((e) => _encode(e.toEntity().toDocument())).toList(),
      BackupCollection.categories: categories.map((c) => _encode(c.toEntity().toDocument())).toList(),
      BackupCollection.budgets: budgets.map((b) => _encode(b.toEntity().toDocument())).toList(),
      BackupCollection.wallets: wallets.map((w) => _encode(w.toEntity().toDocument())).toList(),
      BackupCollection.transfers: transfers.map((t) => _encode(t.toEntity().toDocument())).toList(),
      if (settings != null) BackupCollection.settings: _encode(settings!.toEntity().toDocument()),
    },
  };

  static BackupDocument fromJsonString(String content) {
    final decoded = jsonDecode(content);
    if (decoded is! Map) throw const BackupParseException('Root must be object.');
    return fromJson(Map<String, Object?>.from(decoded));
  }

  static BackupDocument fromJson(Map<String, Object?> json) {
    final mj = json['manifest'], dj = json['data'];
    if (mj is! Map || dj is! Map) throw const BackupParseException('Manifest/data missing.');
    final manifest = BackupManifest.fromJson(Map<String, Object?>.from(mj));
    final data = Map<String, Object?>.from(dj);
    return BackupDocument(
      manifest: manifest,
      expenses: _docs(data[BackupCollection.expenses]).map((d) => Expense.fromEntity(ExpenseEntity.fromDocument(d))).toList(),
      categories: _docs(data[BackupCollection.categories]).map((d) => Category.fromEntity(CategoryEntity.fromDocument(d))).toList(),
      budgets: _docs(data[BackupCollection.budgets]).map((d) => Budget.fromEntity(BudgetEntity.fromDocument(d))).toList(),
      wallets: _docs(data[BackupCollection.wallets]).map((d) => WalletAccount.fromEntity(WalletAccountEntity.fromDocument(d))).toList(),
      transfers: _docs(data[BackupCollection.transfers]).map((d) => Transfer.fromEntity(TransferEntity.fromDocument(d))).toList(),
    );
  }

  void validateOwnership(String expectedUserId) {
    final invalid = <String>[];
    if (expenses.any((e) => e.userId.isNotEmpty && e.userId != expectedUserId)) invalid.add(BackupCollection.expenses);
    if (categories.any((c) => c.userId.isNotEmpty && c.userId != expectedUserId)) invalid.add(BackupCollection.categories);
    if (invalid.isNotEmpty) throw BackupParseException('Data owned by different user in: ${invalid.join(', ')}.');
  }
}

class BackupSerializer {
  const BackupSerializer();

  BackupDocument createBackup({
    required String userId, required DateTime createdAt,
    String appVersion = '1.0.0',
    List<Expense> expenses = const [], List<Category> categories = const [],
    List<Budget> budgets = const [], List<WalletAccount> wallets = const [],
    List<Transfer> transfers = const [], UserSettings? settings,
  }) {
    final manifest = BackupManifest(
      schemaVersion: currentBackupSchemaVersion, appVersion: appVersion,
      createdAt: createdAt, sourceUserId: userId,
      collections: BackupCollection.supported,
      counts: {
        BackupCollection.expenses: expenses.length,
        BackupCollection.categories: categories.length,
        BackupCollection.budgets: budgets.length,
        BackupCollection.wallets: wallets.length,
        BackupCollection.transfers: transfers.length,
        BackupCollection.settings: settings == null ? 0 : 1,
      },
    );
    return BackupDocument(manifest: manifest, expenses: expenses, categories: categories, budgets: budgets, wallets: wallets, transfers: transfers, settings: settings);
  }
}

Object? _encode(Object? v) {
  if (v is DateTime) return v.toIso8601String();
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), _encode(val)));
  if (v is Iterable) return v.map(_encode).toList();
  return v;
}

List<Map<String, dynamic>> _docs(Object? v) {
  if (v == null) return const [];
  if (v is! List) throw const BackupParseException('Must be a list.');
  return v.map((i) { if (i is! Map) throw const BackupParseException('Item must be object.'); return Map<String, dynamic>.from(i); }).toList();
}

int? _int(Object? v) => v is int ? v : v is num ? v.toInt() : v is String ? int.tryParse(v) : null;

Map<String, int> _intMap(Object? v) {
  if (v is! Map) return const {};
  final r = <String, int>{};
  for (final e in v.entries) { r[e.key.toString()] = _int(e.value) ?? 0; }
  return r;
}

List<String> _stringList(Object? v) => v is List ? v.whereType<String>().toList() : const [];

DateTime? _date(Object? v) => v is DateTime ? v : v is String ? DateTime.tryParse(v) : null;
