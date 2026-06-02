import 'dart:io';

import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expense source serialization', () {
    test('serializes every Flutter expense source to a rules-accepted value', () {
      final rules = File('firestore.rules').readAsStringSync();

      for (final source in ExpenseSource.values) {
        final document = _expense(source).toEntity().toDocument();
        final serializedSource = document['source'] as String;

        expect(serializedSource, source.name);
        expect(
          _rulesAllowSource(rules, serializedSource),
          isTrue,
          reason: 'firestore.rules must accept $serializedSource',
        );
      }
    });

    test('parses legacy ai source as aiText', () {
      final entity = _expense(ExpenseSource.manual).toEntity();
      final legacyEntity = ExpenseEntity(
        expenseId: entity.expenseId,
        userId: entity.userId,
        categoryId: entity.categoryId,
        categoryName: entity.categoryName,
        categoryIcon: entity.categoryIcon,
        categoryColor: entity.categoryColor,
        date: entity.date,
        amount: entity.amount,
        description: entity.description,
        merchant: entity.merchant,
        tags: entity.tags,
        paymentMethod: entity.paymentMethod,
        currency: entity.currency,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        source: 'ai',
        walletAccountId: entity.walletAccountId,
        walletAccountName: entity.walletAccountName,
        recurringExpenseId: entity.recurringExpenseId,
        aiActionId: entity.aiActionId,
        moneySnapshot: entity.moneySnapshot,
      );

      expect(Expense.fromEntity(legacyEntity).source, ExpenseSource.aiText);
      expect(_rulesAllowSource(File('firestore.rules').readAsStringSync(), 'ai'), isTrue);
    });
  });
}

Expense _expense(ExpenseSource source) {
  return Expense(
    expenseId: 'expense-${source.name}',
    userId: 'user-1',
    category: Category(
      categoryId: 'food',
      userId: 'user-1',
      name: 'Food',
      totalExpenses: 0,
      icon: 'restaurant',
      color: 0xff000000,
      isArchived: false,
    ),
    date: DateTime.utc(2026, 5, 31),
    amount: 100,
    paymentMethod: PaymentMethod.cash,
    currency: 'EGP',
    createdAt: DateTime.utc(2026, 5, 31),
    updatedAt: DateTime.utc(2026, 5, 31),
    source: source,
  );
}

bool _rulesAllowSource(String rules, String source) {
  final sourceLiteral = "value == '$source'";
  final functionStart = rules.indexOf('function validExpenseSource(value)');
  final functionEnd = rules.indexOf('function validTagAt', functionStart);

  expect(functionStart, isNonNegative);
  expect(functionEnd, isNonNegative);

  return rules.substring(functionStart, functionEnd).contains(sourceLiteral);
}
