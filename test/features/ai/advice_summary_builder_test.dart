import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/ai/domain/advice_summary_builder.dart';
import 'package:expenses_tracker/features/ai/domain/local_advice_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdviceSummaryBuilder', () {
    test('builds compact privacy-safe summary without raw expense text', () {
      final now = DateTime(2026, 5, 20);
      final food = _category('food', 'Food');
      final transport = _category('transport', 'Transport');
      const builder = AdviceSummaryBuilder();

      final summary = builder.build(
        now: now,
        expenses: [
          Expense(
            expenseId: 'e1',
            category: food,
            date: DateTime(2026, 5, 3),
            amount: 300,
            description: 'Dinner with private note',
            merchant: 'Private Merchant',
            currency: 'EGP',
          ),
          Expense(
            expenseId: 'e2',
            category: transport,
            date: DateTime(2026, 5, 4),
            amount: 100,
            description: 'Receipt OCR text should never leak',
            merchant: 'Taxi merchant',
            currency: 'EGP',
          ),
          Expense(
            expenseId: 'e3',
            category: food,
            date: DateTime(2026, 4, 10),
            amount: 200,
            description: 'Previous month private text',
            merchant: 'Old merchant',
            currency: 'EGP',
          ),
        ],
        budget: Budget(
          budgetId: '2026-05',
          userId: 'user-1',
          month: 5,
          year: 2026,
          amount: 500,
          currency: 'EGP',
          warningThresholdPercent: 80,
          createdAt: now,
          updatedAt: now,
        ),
        wallets: [
          WalletAccount(
            walletId: 'cash',
            userId: 'user-1',
            name: 'Cash',
            type: 'cash',
            balance: 700,
            currency: 'EGP',
            icon: 'wallet',
            color: 0,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        savingGoals: [
          SavingGoal(
            goalId: 'goal-1',
            userId: 'user-1',
            name: 'Emergency',
            targetAmount: 1000,
            currentAmount: 250,
            currency: 'EGP',
            color: 0,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        recurringExpenses: [
          RecurringExpense(
            recurringExpenseId: 'rec-1',
            userId: 'user-1',
            name: 'Streaming',
            amount: 90,
            currency: 'EGP',
            categoryId: 'entertainment',
            frequency: 'monthly',
            startDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      final jsonText = jsonEncode(summary.toJson());

      expect(summary.totalSpent, 400);
      expect(summary.budgetUsedPercent, 80);
      expect(summary.topCategories, hasLength(2));
      expect(summary.topCategories.first.categoryName, 'Food');
      expect(summary.categoryTrendFlags.length, lessThanOrEqualTo(5));
      expect(summary.riskFlags, contains('budget_near_limit'));
      expect(utf8.encode(jsonText).length, lessThan(10 * 1024));
      expect(jsonText, isNot(contains('Dinner with private note')));
      expect(jsonText, isNot(contains('Private Merchant')));
      expect(jsonText, isNot(contains('Receipt OCR text')));
      expect(jsonText, isNot(contains('merchant')));
      expect(jsonText, isNot(contains('description')));
      expect(jsonText, isNot(contains('receipt')));
    });

    test('caps top categories and trend flags for heavy local data', () {
      final now = DateTime(2026, 5, 20);
      final expenses = List.generate(20, (index) {
        final category = _category('cat-$index', 'Category $index');
        return Expense(
          expenseId: 'e-$index',
          category: category,
          date: DateTime(2026, 5, 1 + (index % 10)),
          amount: 10.0 + index,
          description: 'private description $index',
          merchant: 'merchant $index',
        );
      });

      final summary = const AdviceSummaryBuilder().build(
        now: now,
        expenses: expenses,
      );

      expect(summary.topCategories, hasLength(5));
      expect(summary.categoryTrendFlags.length, lessThanOrEqualTo(5));
      expect(summary.toJson()['topCategories'], hasLength(5));
    });
  });

  group('LocalAdviceGenerator', () {
    test('generates deterministic English local advice', () {
      final summary = const AdviceSummaryBuilder().build(
        now: DateTime(2026, 5, 20),
        expenses: [
          Expense(
            expenseId: 'e1',
            category: _category('food', 'Food'),
            date: DateTime(2026, 5, 1),
            amount: 900,
          ),
        ],
        budget: Budget(
          budgetId: '2026-05',
          userId: 'user-1',
          month: 5,
          year: 2026,
          amount: 1000,
          currency: 'EGP',
          warningThresholdPercent: 80,
          createdAt: DateTime(2026, 5),
          updatedAt: DateTime(2026, 5),
        ),
      );

      final advice = const LocalAdviceGenerator().generate(summary);

      expect(advice.first.title, 'Close to budget limit');
      expect(advice.any((item) => item.source == 'local'), isTrue);
      expect(advice.any((item) => item.body.contains('Food')), isTrue);
    });
  });
}

Category _category(String id, String name) {
  return Category(
    categoryId: id,
    name: name,
    totalExpenses: 0,
    icon: 'category',
    color: 0,
  );
}
