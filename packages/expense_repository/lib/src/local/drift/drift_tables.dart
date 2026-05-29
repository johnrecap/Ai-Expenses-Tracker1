import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:expense_repository/src/models/money_snapshot.dart';

part 'drift_tables.g.dart';

// ---------------------------------------------------------------------------
// Type converters for complex types stored as JSON text
// ---------------------------------------------------------------------------

/// Converts List<String> ↔ JSON string for Drift columns.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    return (jsonDecode(fromDb) as List).cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// Converts Map<String, double> ↔ JSON string for Drift columns.
class StringDoubleMapConverter
    extends TypeConverter<Map<String, double>, String> {
  const StringDoubleMapConverter();

  @override
  Map<String, double> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const {};
    return Map<String, double>.from(
      (jsonDecode(fromDb) as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      ),
    );
  }

  @override
  String toSql(Map<String, double> value) => jsonEncode(value);
}

/// Converts Map<String, dynamic> ↔ JSON string (e.g. notification settings).
class JsonMapConverter
    extends TypeConverter<Map<String, dynamic>, String> {
  const JsonMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const {};
    return jsonDecode(fromDb) as Map<String, dynamic>;
  }

  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}

/// Converts MoneySnapshot? ↔ JSON string (nullable).
class MoneySnapshotConverter
    extends TypeConverter<MoneySnapshot?, String?> {
  const MoneySnapshotConverter();

  @override
  MoneySnapshot? fromSql(String? fromDb) {
    if (fromDb == null || fromDb.isEmpty) return null;
    return MoneySnapshot.fromJson(
      jsonDecode(fromDb) as Map<String, dynamic>,
    );
  }

  @override
  String? toSql(MoneySnapshot? value) =>
      value == null ? null : jsonEncode(value.toJson());
}

// ---------------------------------------------------------------------------
// Table definitions — one per entity
//
// Data class names are prefixed with "Drift" to avoid conflicts with the
// existing Firestore-oriented entity classes in lib/src/entities/.
// ---------------------------------------------------------------------------

@DataClassName('DriftExpense')
class Expenses extends Table {
  TextColumn get expenseId => text()();
  TextColumn get userId => text()();
  TextColumn get categoryId => text()();
  TextColumn get categoryName => text()();
  TextColumn get categoryIcon => text()();
  IntColumn get categoryColor => integer()();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  TextColumn get merchant => text().nullable()();
  TextColumn get tags =>
      text().map(const StringListConverter())();
  TextColumn get paymentMethod => text()();
  TextColumn get currency => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get source => text()();
  TextColumn get walletAccountId => text().nullable()();
  TextColumn get walletAccountName => text().nullable()();
  TextColumn get recurringExpenseId => text().nullable()();
  TextColumn get aiActionId => text().nullable()();
  TextColumn get moneySnapshot =>
      text().map(const MoneySnapshotConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {expenseId};
}

@DataClassName('DriftCategory')
class Categories extends Table {
  TextColumn get categoryId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  IntColumn get totalExpenses => integer()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  BoolColumn get isArchived => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {categoryId};
}

@DataClassName('DriftBudget')
class Budgets extends Table {
  TextColumn get budgetId => text()();
  TextColumn get userId => text()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  IntColumn get warningThresholdPercent => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {budgetId};
}

@DataClassName('DriftSettings')
class Settings extends Table {
  TextColumn get userId => text()();
  TextColumn get appDisplayName => text().nullable()();
  TextColumn get languagePreference => text()();
  TextColumn get baseCurrency => text()();
  TextColumn get supportedCurrencies =>
      text().map(const StringListConverter())();
  TextColumn get conversionRates =>
      text().map(const StringDoubleMapConverter())();
  TextColumn get defaultPaymentMethod => text()();
  TextColumn get notificationSettings =>
      text().map(const JsonMapConverter())();
  BoolColumn get onboardingCompleted => boolean()();
  IntColumn get onboardingVersion => integer()();
  IntColumn get guidedTourCompletedVersion => integer()();
  IntColumn get guidedTourSkippedVersion => integer()();
  TextColumn get guidedTourLastStepId => text().nullable()();
  DateTimeColumn get exchangeRatesUpdatedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName('DriftSavingGoal')
class Goals extends Table {
  TextColumn get goalId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real()();
  TextColumn get currency => text()();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get color => integer()();
  BoolColumn get isArchived => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {goalId};
}

@DataClassName('DriftWallet')
class Wallets extends Table {
  TextColumn get walletId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  RealColumn get balance => real()();
  TextColumn get currency => text()();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {walletId};
}

@DataClassName('DriftTransfer')
class Transfers extends Table {
  TextColumn get transferId => text()();
  TextColumn get userId => text()();
  TextColumn get fromWalletId => text()();
  TextColumn get toWalletId => text()();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {transferId};
}

// ---------------------------------------------------------------------------
// Category-budget table (for per-category budget tracking)
// ---------------------------------------------------------------------------

@DataClassName('DriftCategoryBudget')
class CategoryBudgets extends Table {
  TextColumn get budgetId => text()();
  TextColumn get userId => text()();
  TextColumn get categoryId => text()();
  RealColumn get amount => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {budgetId};
}

// ---------------------------------------------------------------------------
// Category-alias table
// ---------------------------------------------------------------------------

@DataClassName('DriftCategoryAlias')
class CategoryAliases extends Table {
  TextColumn get aliasId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get categoryId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {aliasId};
}

// ---------------------------------------------------------------------------
// Recurring-expense table
// ---------------------------------------------------------------------------

@DataClassName('DriftRecurringExpense')
class RecurringExpenses extends Table {
  TextColumn get recurringExpenseId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text()();
  TextColumn get categoryId => text()();
  TextColumn get frequency => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get lastGeneratedDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {recurringExpenseId};
}

// ---------------------------------------------------------------------------
// AI action-log table
// ---------------------------------------------------------------------------

@DataClassName('DriftAiActionLog')
class AiActionLogs extends Table {
  TextColumn get actionId => text()();
  TextColumn get userId => text()();
  TextColumn get actionType => text()();
  TextColumn get input => text()();
  TextColumn get output => text().nullable()();
  TextColumn get structuredJson =>
      text().map(const JsonMapConverter()).nullable()();
  BoolColumn get success => boolean()();
  TextColumn get error => text().nullable()();
  IntColumn get quotaUsed => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {actionId};
}

// ---------------------------------------------------------------------------
// Drift database annotation — lists every table
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Expenses,
    Categories,
    Budgets,
    Settings,
    Goals,
    Wallets,
    Transfers,
    CategoryBudgets,
    CategoryAliases,
    RecurringExpenses,
    AiActionLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
