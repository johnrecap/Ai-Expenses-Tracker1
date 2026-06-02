import 'package:flutter_test/flutter_test.dart';
import '../fixtures/core_mock/mock_data.dart';
import '../fixtures/core_mock/mock_models.dart';

void main() {
  group('MockModels', () {
    test('MockBudget computes progress correctly', () {
      const budget = MockBudget(id: 'b1', monthLabel: 'May', cap: 100, spent: 60);
      expect(budget.progress, 0.6);
      expect(budget.remaining, 40);
    });

    test('MockBudget progress clamps to 1.0', () {
      const budget = MockBudget(id: 'b1', monthLabel: 'May', cap: 100, spent: 150);
      expect(budget.progress, 1.0);
    });

    test('MockBudget progress is 0 when cap is 0', () {
      const budget = MockBudget(id: 'b1', monthLabel: 'May', cap: 0, spent: 50);
      expect(budget.progress, 0.0);
    });

    test('MockGoal computes progress correctly', () {
      const goal = MockGoal(
        id: 'g1',
        title: 'Car',
        targetAmount: 8000,
        savedAmount: 3200,
        deadlineLabel: 'Dec',
      );
      expect(goal.progress, 0.4);
    });
  });

  group('MockData', () {
    test('currentUser is defined', () {
      expect(MockData.currentUser.displayName, isNotEmpty);
      expect(MockData.currentUser.baseCurrency, 'KWD');
    });

    test('categories are non-empty', () {
      expect(MockData.categories, isNotEmpty);
      expect(MockData.categories.length, greaterThanOrEqualTo(8));
    });

    test('expenses are non-empty', () {
      expect(MockData.expenses, isNotEmpty);
      expect(MockData.expenses.length, greaterThanOrEqualTo(8));
    });

    test('wallets are non-empty', () {
      expect(MockData.wallets, isNotEmpty);
      expect(MockData.wallets.length, greaterThanOrEqualTo(2));
    });

    test('budgets are non-empty', () {
      expect(MockData.budgets, isNotEmpty);
    });

    test('goals are non-empty', () {
      expect(MockData.goals, isNotEmpty);
      expect(MockData.goals.length, greaterThanOrEqualTo(2));
    });

    test('subscriptions are non-empty', () {
      expect(MockData.subscriptions, isNotEmpty);
      expect(MockData.subscriptions.length, greaterThanOrEqualTo(3));
    });

    test('reports are non-empty', () {
      expect(MockData.reports, isNotEmpty);
    });

    test('aiInsights are non-empty', () {
      expect(MockData.aiInsights, isNotEmpty);
      expect(MockData.aiInsights.length, greaterThanOrEqualTo(2));
    });

    test('chatMessages are non-empty', () {
      expect(MockData.chatMessages, isNotEmpty);
      expect(MockData.chatMessages.length, greaterThanOrEqualTo(3));
    });

    test('all expense IDs are unique', () {
      final ids = MockData.expenses.map((e) => e.id).toSet();
      expect(ids.length, MockData.expenses.length);
    });

    test('wallet IDs in expenses exist in wallets', () {
      final walletIds = MockData.wallets.map((w) => w.id).toSet();
      for (final expense in MockData.expenses) {
        expect(walletIds, contains(expense.walletId));
      }
    });

    test('category IDs in expenses exist in categories', () {
      final categoryIds = MockData.categories.map((c) => c.id).toSet();
      for (final expense in MockData.expenses) {
        expect(categoryIds, contains(expense.categoryId));
      }
    });
  });
}
