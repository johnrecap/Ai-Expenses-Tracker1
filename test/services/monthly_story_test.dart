import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/screens/reports/services/monthly_financial_story_service.dart';
import 'package:expense_repository/expense_repository.dart';

void main() {
  group('MonthlyFinancialStoryService', () {
    test('returns empty message when no expenses', () {
      final service = MonthlyFinancialStoryService();
      final result = service.generateStory([]);
      expect(result, contains('No expenses'));
    });

    test('generates story with categories', () {
      final service = MonthlyFinancialStoryService();
      final expenses = [
        Expense(expenseId: '1', category: Category.empty.copyWith(name: 'Food'), date: DateTime.now(), amount: 500),
        Expense(expenseId: '2', category: Category.empty.copyWith(name: 'Food'), date: DateTime.now(), amount: 300),
        Expense(expenseId: '3', category: Category.empty.copyWith(name: 'Transport'), date: DateTime.now(), amount: 200),
      ];
      final result = service.generateStory(expenses);
      expect(result, contains('Food'));
      expect(result, contains('Transport'));
      expect(result, contains('transactions'));
    });
  });
}
