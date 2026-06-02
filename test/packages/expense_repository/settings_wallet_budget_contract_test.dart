import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User settings serialization contract', () {
    test('defaults serialize to the Firestore profile document shape', () {
      final updatedAt = DateTime.utc(2026, 5, 31, 10, 15);
      final settings = UserSettings.defaults(
        userId: 'user-1',
        updatedAt: updatedAt,
      );

      final document = settings.toEntity().toDocument();

      expect(
        document.keys.toSet(),
        equals({
          'userId',
          'languagePreference',
          'baseCurrency',
          'supportedCurrencies',
          'conversionRates',
          'defaultPaymentMethod',
          'notificationSettings',
          'onboardingCompleted',
          'onboardingVersion',
          'guidedTourCompletedVersion',
          'guidedTourSkippedVersion',
          'updatedAt',
        }),
      );
      expect(document['userId'], 'user-1');
      expect(document['languagePreference'], 'system');
      expect(document['baseCurrency'], 'EGP');
      expect(
        document['supportedCurrencies'],
        equals(['EGP', 'USD', 'EUR', 'SAR', 'AED']),
      );
      expect(document['conversionRates'], isEmpty);
      expect(document['defaultPaymentMethod'], 'cash');
      expect(document['onboardingCompleted'], isFalse);
      expect(document['onboardingVersion'], 0);
      expect(
        (document['updatedAt'] as Timestamp).toDate().isAtSameMomentAs(updatedAt),
        isTrue,
      );

      expect(
        document['notificationSettings'],
        equals({
          'budgetAlerts': true,
          'recurringReminders': true,
          'subscriptionRenewals': true,
          'weeklyDigest': false,
          'aiQuotaWarnings': true,
          'dailyReminder': false,
        }),
      );
      _expectRulesFunctionAllowsFields(
        functionName: 'validSettings',
        fields: document.keys,
      );
      _expectRulesFunctionAllowsFields(
        functionName: 'validNotificationSettings',
        fields: (document['notificationSettings'] as Map<String, dynamic>).keys,
      );
    });

    test('missing notification settings parse with backwards-compatible defaults', () {
      final entity = UserSettingsEntity.fromDocument({
        'userId': 'user-1',
        'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 5, 31)),
      });

      expect(entity.languagePreference, 'system');
      expect(entity.baseCurrency, 'EGP');
      expect(entity.defaultPaymentMethod, 'cash');
      expect(entity.onboardingCompleted, isFalse);
      expect(entity.notificationSettings.budgetAlerts, isTrue);
      expect(entity.notificationSettings.recurringReminders, isTrue);
      expect(entity.notificationSettings.subscriptionRenewals, isTrue);
      expect(entity.notificationSettings.weeklyDigest, isFalse);
      expect(entity.notificationSettings.aiQuotaWarnings, isTrue);
      expect(entity.notificationSettings.dailyReminder, isFalse);
      expect(entity.notificationSettings.dailyReminderTime, isNull);
    });

    test('payment method values match Firestore rule contract', () {
      final storageValues = PaymentMethod.values.map((method) => method.storageValue).toSet();

      expect(
        storageValues,
        equals({'cash', 'visa', 'wallet', 'bank_transfer'}),
      );
      _expectRulesFunctionContains(
        functionName: 'validPaymentMethod',
        values: storageValues,
      );
    });
  });

  group('Expense wallet serialization contract', () {
    test('expense can serialize without wallet account fields', () {
      final category = Category.empty.copyWith(
        categoryId: 'food',
        name: 'Food',
        icon: 'restaurant',
        color: 0xff000000,
      );
      final expense = Expense(
        expenseId: 'expense-1',
        userId: 'user-1',
        category: category,
        date: DateTime.utc(2026, 5, 31),
        amount: 100,
        description: 'Lunch',
        paymentMethod: PaymentMethod.visa,
        currency: 'EGP',
      );

      final document = expense.toEntity().toDocument();

      expect(document['paymentMethod'], 'visa');
      expect(document.containsKey('walletAccountId'), isFalse);
      expect(document.containsKey('walletAccountName'), isFalse);
      _expectRulesFunctionAllowsFields(
        functionName: 'validExpense',
        fields: document.keys,
      );
      _expectRulesFunctionAllowsFields(
        functionName: 'validExpense',
        fields: const ['walletAccountId', 'walletAccountName'],
      );
    });
  });

  group('Wallet transfer serialization contract', () {
    test('model serializes to the Firestore transfer document shape', () {
      final date = DateTime.utc(2026, 5, 30, 9);
      final createdAt = DateTime.utc(2026, 5, 31, 10);
      final transfer = Transfer(
        transferId: 'transfer-1',
        userId: 'user-1',
        fromWalletId: 'cash-wallet',
        toWalletId: 'bank-wallet',
        amount: 250.75,
        note: 'Move savings',
        date: date,
        createdAt: createdAt,
      );

      final document = transfer.toEntity().toDocument();

      expect(
        document.keys.toSet(),
        equals({
          'transferId',
          'userId',
          'fromWalletId',
          'toWalletId',
          'amount',
          'note',
          'date',
          'createdAt',
        }),
      );
      expect(document['transferId'], 'transfer-1');
      expect(document['userId'], 'user-1');
      expect(document['fromWalletId'], 'cash-wallet');
      expect(document['toWalletId'], 'bank-wallet');
      expect(document['amount'], 250.75);
      expect(document['note'], 'Move savings');
      expect(
        (document['date'] as Timestamp).toDate().isAtSameMomentAs(date),
        isTrue,
      );
      expect(
        (document['createdAt'] as Timestamp).toDate().isAtSameMomentAs(createdAt),
        isTrue,
      );
      _expectRulesFunctionAllowsFields(
        functionName: 'validTransfer',
        fields: document.keys,
      );

      final parsed = Transfer.fromEntity(TransferEntity.fromDocument(document));
      expect(parsed.transferId, transfer.transferId);
      expect(parsed.userId, transfer.userId);
      expect(parsed.fromWalletId, transfer.fromWalletId);
      expect(parsed.toWalletId, transfer.toWalletId);
      expect(parsed.amount, transfer.amount);
      expect(parsed.note, transfer.note);
      expect(parsed.date.isAtSameMomentAs(transfer.date), isTrue);
      expect(parsed.createdAt.isAtSameMomentAs(transfer.createdAt), isTrue);
    });
  });

  group('Category budget serialization contract', () {
    test('entity serializes to the Firestore category budget document shape', () {
      final createdAt = DateTime.utc(2026, 5, 1);
      final updatedAt = DateTime.utc(2026, 5, 31);
      final entity = CategoryBudgetEntity(
        budgetId: '2026-05-food',
        userId: 'user-1',
        categoryId: 'food',
        amount: 1200,
        month: 5,
        year: 2026,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final document = entity.toDocument();

      expect(
        document.keys.toSet(),
        equals({
          'budgetId',
          'userId',
          'categoryId',
          'amount',
          'month',
          'year',
          'createdAt',
          'updatedAt',
        }),
      );
      expect(document['budgetId'], '2026-05-food');
      expect(document['userId'], 'user-1');
      expect(document['categoryId'], 'food');
      expect(document['amount'], 1200);
      expect(document['month'], 5);
      expect(document['year'], 2026);
      expect(
        (document['createdAt'] as Timestamp).toDate().isAtSameMomentAs(createdAt),
        isTrue,
      );
      expect(
        (document['updatedAt'] as Timestamp).toDate().isAtSameMomentAs(updatedAt),
        isTrue,
      );
      _expectRulesFunctionAllowsFields(
        functionName: 'validCategoryBudget',
        fields: document.keys,
      );

      final parsed = CategoryBudgetEntity.fromDocument(document);
      expect(parsed.budgetId, entity.budgetId);
      expect(parsed.userId, entity.userId);
      expect(parsed.categoryId, entity.categoryId);
      expect(parsed.amount, entity.amount);
      expect(parsed.month, entity.month);
      expect(parsed.year, entity.year);
      expect(parsed.createdAt.isAtSameMomentAs(entity.createdAt), isTrue);
      expect(parsed.updatedAt.isAtSameMomentAs(entity.updatedAt), isTrue);
    });
  });
}

void _expectRulesFunctionAllowsFields({
  required String functionName,
  required Iterable<String> fields,
}) {
  final rules = File('firestore.rules').readAsStringSync();
  final functionStart = rules.indexOf('function $functionName(');
  final nextFunctionStart = rules.indexOf('\n    function ', functionStart + 1);

  expect(functionStart, isNonNegative);
  expect(nextFunctionStart, isNonNegative);

  final functionBody = rules.substring(functionStart, nextFunctionStart);
  for (final field in fields) {
    expect(
      functionBody,
      contains("'$field'"),
      reason: 'firestore.rules $functionName must allow $field',
    );
  }
}

void _expectRulesFunctionContains({
  required String functionName,
  required Iterable<String> values,
}) {
  final rules = File('firestore.rules').readAsStringSync();
  final functionStart = rules.indexOf('function $functionName(');
  final nextFunctionStart = rules.indexOf('\n    function ', functionStart + 1);

  expect(functionStart, isNonNegative);
  expect(nextFunctionStart, isNonNegative);

  final functionBody = rules.substring(functionStart, nextFunctionStart);
  for (final value in values) {
    expect(
      functionBody,
      contains("'$value'"),
      reason: 'firestore.rules $functionName must allow $value',
    );
  }
}
