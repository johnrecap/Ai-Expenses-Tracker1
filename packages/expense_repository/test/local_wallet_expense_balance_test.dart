import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Local wallet-linked expense balances', () {
    test('creating a wallet-linked expense reduces the wallet balance', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalExpenseRepository(store: store);
      await store.upsertWallet(_wallet(id: 'cash', balance: 1000));

      await repository.createExpense(_expense(id: 'expense-1', amount: 100, walletId: 'cash'));

      expect(store.wallets.single.balance, 900);
    });

    test('editing a wallet-linked expense applies only the balance difference', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalExpenseRepository(store: store);
      await store.upsertWallet(_wallet(id: 'cash', balance: 1000));
      await repository.createExpense(_expense(id: 'expense-1', amount: 100, walletId: 'cash'));

      await repository.updateExpense(_expense(id: 'expense-1', amount: 150, walletId: 'cash'));

      expect(store.wallets.single.balance, 850);
    });

    test('moving an expense restores the old wallet and charges the new wallet', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalExpenseRepository(store: store);
      await store.upsertWallet(_wallet(id: 'cash', name: 'Cash', balance: 1000));
      await store.upsertWallet(_wallet(id: 'bank', name: 'Bank', balance: 500));
      await repository.createExpense(_expense(id: 'expense-1', amount: 100, walletId: 'cash'));

      await repository.updateExpense(_expense(id: 'expense-1', amount: 200, walletId: 'bank'));

      expect(_walletById(store, 'cash').balance, 1000);
      expect(_walletById(store, 'bank').balance, 300);
    });

    test('deleting a wallet-linked expense restores the wallet balance', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalExpenseRepository(store: store);
      await store.upsertWallet(_wallet(id: 'cash', balance: 1000));
      await repository.createExpense(_expense(id: 'expense-1', amount: 100, walletId: 'cash'));

      await repository.deleteExpense('expense-1');

      expect(store.wallets.single.balance, 1000);
      expect(store.expenses, isEmpty);
    });

    test('currency mismatch is rejected without changing balance or saving expense', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final repository = LocalExpenseRepository(store: store);
      await store.upsertWallet(_wallet(id: 'cash', balance: 1000, currency: 'EGP'));

      await expectLater(
        repository.createExpense(
          _expense(id: 'expense-1', amount: 100, walletId: 'cash', currency: 'USD'),
        ),
        throwsA(isA<WalletTransferException>()),
      );

      expect(store.wallets.single.balance, 1000);
      expect(store.expenses, isEmpty);
    });
  });
}

WalletAccount _wallet({
  required String id,
  String? name,
  required double balance,
  String currency = 'EGP',
}) {
  final now = DateTime.utc(2026, 6, 1);
  return WalletAccount(
    walletId: id,
    userId: 'user-1',
    name: name ?? id,
    type: 'cash',
    balance: balance,
    currency: currency,
    icon: 'wallet',
    color: 0xFF336699,
    createdAt: now,
    updatedAt: now,
  );
}

Expense _expense({
  required String id,
  required double amount,
  String? walletId,
  String currency = 'EGP',
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
    description: 'Lunch',
    paymentMethod: walletId == null ? PaymentMethod.cash : PaymentMethod.wallet,
    currency: currency,
    createdAt: now,
    updatedAt: now,
    walletAccountId: walletId,
    walletAccountName: walletId,
  );
}

WalletAccount _walletById(LocalRepositoryStore store, String id) {
  return store.wallets.firstWhere((wallet) => wallet.walletId == id);
}
