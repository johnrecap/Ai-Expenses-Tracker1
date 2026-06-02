import 'dart:io';

import 'package:drift/native.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/local/drift/drift_store.dart';
import 'package:expense_repository/src/local/drift/drift_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Drift local write failures', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('drift_write_failure_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('createExpense surfaces persistence failure and does not update cache', () async {
      final harness = await _openHarness(tempDir);
      final repository = LocalExpenseRepository(store: harness.store);

      await harness.database.close();

      try {
        await expectLater(repository.createExpense(_expense(id: 'expense-1')), throwsA(anything));
        expect(harness.store.expenses, isEmpty);
      } finally {
        await harness.dispose();
      }
    });

    test('updateExpense surfaces persistence failure and keeps old cache value', () async {
      final harness = await _openHarness(tempDir);
      final repository = LocalExpenseRepository(store: harness.store);
      final original = _expense(id: 'expense-1', amount: 100);
      await harness.store.upsertExpense(original);

      await harness.database.close();

      try {
        final updated = original.copyWith(amount: 250, description: 'Updated lunch');

        await expectLater(repository.updateExpense(updated), throwsA(anything));
        expect(harness.store.expenses.single.amount, 100);
        expect(harness.store.expenses.single.description, 'Original lunch');
      } finally {
        await harness.dispose();
      }
    });

    test('deleteExpense surfaces persistence failure and keeps cache value', () async {
      final harness = await _openHarness(tempDir);
      final repository = LocalExpenseRepository(store: harness.store);
      await harness.store.upsertExpense(_expense(id: 'expense-1'));

      await harness.database.close();

      try {
        await expectLater(repository.deleteExpense('expense-1'), throwsA(anything));
        expect(harness.store.expenses.single.expenseId, 'expense-1');
      } finally {
        await harness.dispose();
      }
    });
  });
}

Future<_Harness> _openHarness(Directory tempDir) async {
  final database = AppDatabase(NativeDatabase(File(p.join(tempDir.path, 'app.sqlite'))));
  final store = DriftLocalRepositoryStore(
    userId: 'user-1',
    database: database,
    syncQueueFile: File(p.join(tempDir.path, 'queue.json')),
  );
  await store.ready;
  return _Harness(database: database, store: store);
}

Expense _expense({
  required String id,
  double amount = 125.5,
}) {
  final now = DateTime.utc(2026, 6, 1, 10);
  return Expense(
    expenseId: id,
    userId: 'user-1',
    category: Category(
      categoryId: 'food',
      userId: 'user-1',
      name: 'Food',
      totalExpenses: 0,
      icon: 'restaurant',
      color: 0xFF336699,
      createdAt: now,
      updatedAt: now,
    ),
    date: now,
    amount: amount,
    description: 'Original lunch',
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
    createdAt: now,
    updatedAt: now,
  );
}

class _Harness {
  final AppDatabase database;
  final DriftLocalRepositoryStore store;

  const _Harness({
    required this.database,
    required this.store,
  });

  Future<void> dispose() async {
    try {
      await store.dispose();
    } catch (_) {
      // Some tests close the database first to simulate a persistence failure.
    }
  }
}
