import 'dart:io';

import 'package:drift/native.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/local/drift/drift_store.dart';
import 'package:expense_repository/src/local/drift/drift_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Drift local repository startup', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('drift_startup_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('expense reads wait for previously persisted data to load', () async {
      final dbFile = File(p.join(tempDir.path, 'app.sqlite'));
      final seedDb = AppDatabase(NativeDatabase(dbFile));
      await seedDb.into(seedDb.expenses).insert(_driftExpense(id: 'expense-1'));
      await seedDb.close();

      final store = DriftLocalRepositoryStore(
        userId: 'user-1',
        database: AppDatabase(NativeDatabase(dbFile)),
        syncQueueFile: File(p.join(tempDir.path, 'queue.json')),
      );
      final repository = LocalExpenseRepository(store: store);

      try {
        final expenses = await repository.getExpenses();

        expect(expenses, hasLength(1));
        expect(expenses.single.expenseId, 'expense-1');
        expect(expenses.single.description, 'Seeded lunch');
      } finally {
        await store.dispose();
      }
    });

    test('settings reads wait for previously persisted settings to load', () async {
      final dbFile = File(p.join(tempDir.path, 'app.sqlite'));
      final seedDb = AppDatabase(NativeDatabase(dbFile));
      await seedDb.into(seedDb.settings).insert(_driftSettings());
      await seedDb.close();

      final store = DriftLocalRepositoryStore(
        userId: 'user-1',
        database: AppDatabase(NativeDatabase(dbFile)),
        syncQueueFile: File(p.join(tempDir.path, 'queue.json')),
      );
      final repository = LocalSettingsRepository(store: store);

      try {
        final settings = await repository.getSettings();

        expect(settings.appDisplayName, 'Mohamed');
        expect(settings.baseCurrency, 'USD');
        expect(settings.defaultPaymentMethod, PaymentMethod.visa);
        expect(settings.onboardingCompleted, isTrue);
      } finally {
        await store.dispose();
      }
    });
  });
}

DriftExpense _driftExpense({required String id}) {
  final now = DateTime.utc(2026, 6, 1, 10);
  return DriftExpense(
    expenseId: id,
    userId: 'user-1',
    categoryId: 'food',
    categoryName: 'Food',
    categoryIcon: 'restaurant',
    categoryColor: 0xFF336699,
    date: now,
    amount: 125.5,
    description: 'Seeded lunch',
    merchant: null,
    tags: const <String>[],
    paymentMethod: PaymentMethod.cash.storageValue,
    currency: 'EGP',
    createdAt: now,
    updatedAt: now,
    source: ExpenseSource.manual.name,
    walletAccountId: null,
    walletAccountName: null,
    recurringExpenseId: null,
    aiActionId: null,
    moneySnapshot: null,
  );
}

DriftSettings _driftSettings() {
  final now = DateTime.utc(2026, 6, 1, 10);
  return DriftSettings(
    userId: 'user-1',
    appDisplayName: 'Mohamed',
    languagePreference: LanguagePreference.arabic.storageValue,
    baseCurrency: 'USD',
    supportedCurrencies: const <String>['USD', 'EGP'],
    conversionRates: const <String, double>{'EGP': 47.5},
    defaultPaymentMethod: PaymentMethod.visa.storageValue,
    notificationSettings: const <String, dynamic>{
      'budgetAlerts': true,
      'recurringReminders': true,
    },
    onboardingCompleted: true,
    onboardingVersion: UserSettings.currentOnboardingVersion,
    guidedTourCompletedVersion: 1,
    guidedTourSkippedVersion: 0,
    guidedTourLastStepId: null,
    exchangeRatesUpdatedAt: now,
    updatedAt: now,
  );
}
