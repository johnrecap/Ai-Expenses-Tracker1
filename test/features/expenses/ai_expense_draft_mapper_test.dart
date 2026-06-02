import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_models.dart';
import 'package:expenses_tracker/features/expenses/domain/ai_expense_draft_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiExpenseDraftMapper', () {
    const mapper = AiExpenseDraftMapper();

    test('maps a complete draft to an AI-sourced expense', () {
      final category = _category(id: 'food', name: 'Food');
      final wallet = _wallet(id: 'cash', name: 'Cash');
      final draft = AiExpenseDraftSelection(
        amount: 250,
        currency: 'egp',
        date: DateTime.utc(2026, 5, 31),
        categoryId: 'food',
        walletAccountId: 'cash',
        description: 'Lunch',
        gatewayRequestId: 'req-1',
      );

      final expense = mapper.toExpense(
        draft: draft,
        userId: 'user-1',
        categories: [category],
        wallets: [wallet],
        expenseId: 'expense-1',
        now: DateTime.utc(2026, 5, 31, 13),
      );

      expect(expense.expenseId, 'expense-1');
      expect(expense.userId, 'user-1');
      expect(expense.amount, 250);
      expect(expense.currency, 'EGP');
      expect(expense.categoryId, 'food');
      expect(expense.walletAccountId, 'cash');
      expect(expense.source, ExpenseSource.aiText);
      expect(expense.aiActionId, 'req-1');
    });

    test('keeps missing fields missing for user review', () {
      final selection = mapper.fromGatewayDraft(
        response: const AiGatewayDraftResponse(
          requestId: 'req-2',
          draft: AiGatewayExpenseDraft(
            amount: 100,
            currency: 'EGP',
            description: 'Taxi',
          ),
        ),
        categories: [_category(id: 'transport', name: 'Transport')],
      );

      expect(selection.amount, 100);
      expect(selection.date, isNull);
      expect(selection.categoryId, isNull);
      expect(selection.walletAccountId, isNull);
      expect(selection.missingFields, containsAll(['date', 'category']));
      expect(selection.missingFields, isNot(contains('wallet')));
    });

    test('maps expense without a wallet as cash payment', () {
      final category = _category(id: 'food', name: 'Food');
      final draft = AiExpenseDraftSelection(
        amount: 90,
        currency: 'EGP',
        date: DateTime.utc(2026, 5, 31),
        categoryId: 'food',
        description: 'Lunch',
      );

      final expense = mapper.toExpense(
        draft: draft,
        userId: 'user-1',
        categories: [category],
        wallets: const [],
        expenseId: 'expense-2',
      );

      expect(expense.walletAccountId, isNull);
      expect(expense.walletAccountName, isNull);
      expect(expense.paymentMethod, PaymentMethod.cash);
    });

    test('uses supplied default payment method when draft has no method', () {
      final category = _category(id: 'food', name: 'Food');
      final draft = AiExpenseDraftSelection(
        amount: 90,
        currency: 'EGP',
        date: DateTime.utc(2026, 5, 31),
        categoryId: 'food',
        description: 'Lunch',
      );

      final expense = mapper.toExpense(
        draft: draft,
        userId: 'user-1',
        categories: [category],
        wallets: const [],
        expenseId: 'expense-3',
        defaultPaymentMethod: PaymentMethod.visa,
      );

      expect(expense.walletAccountId, isNull);
      expect(expense.walletAccountName, isNull);
      expect(expense.paymentMethod, PaymentMethod.visa);
    });

    test('maps gateway payment method and default fallback explicitly', () {
      final categories = [_category(id: 'transport', name: 'Transport')];

      final explicit = mapper.fromGatewayDraft(
        response: const AiGatewayDraftResponse(
          requestId: 'req-card',
          draft: AiGatewayExpenseDraft(
            amount: 100,
            currency: 'EGP',
            categoryId: 'transport',
            date: null,
            paymentMethod: 'bank_transfer',
          ),
        ),
        categories: categories,
        defaultPaymentMethod: PaymentMethod.visa,
      );

      final fallback = mapper.fromGatewayDraft(
        response: const AiGatewayDraftResponse(
          requestId: 'req-default',
          draft: AiGatewayExpenseDraft(
            amount: 100,
            currency: 'EGP',
            categoryId: 'transport',
            date: null,
          ),
        ),
        categories: categories,
        defaultPaymentMethod: PaymentMethod.visa,
      );

      expect(explicit.paymentMethod, PaymentMethod.bankTransfer);
      expect(fallback.paymentMethod, PaymentMethod.visa);
    });

    test('ignores unknown wallet suggestion without blocking save', () {
      final category = _category(id: 'food', name: 'Food');
      final draft = AiExpenseDraftSelection(
        amount: 90,
        currency: 'EGP',
        date: DateTime.utc(2026, 5, 31),
        categoryId: 'food',
        walletAccountName: 'Missing wallet',
        description: 'Lunch',
        paymentMethod: PaymentMethod.visa,
      );

      final expense = mapper.toExpense(
        draft: draft,
        userId: 'user-1',
        categories: [category],
        wallets: const [],
        expenseId: 'expense-4',
      );

      expect(expense.walletAccountId, isNull);
      expect(expense.walletAccountName, isNull);
      expect(expense.paymentMethod, PaymentMethod.visa);
    });

    test('does not choose archived category by name', () {
      final draft = AiExpenseDraftSelection(
        amount: 50,
        currency: 'EGP',
        date: DateTime.utc(2026, 5, 31),
        categoryName: 'Food',
        walletAccountId: 'cash',
      );

      expect(
        () => mapper.toExpense(
          draft: draft,
          userId: 'user-1',
          categories: [_category(id: 'old-food', name: 'Food', archived: true)],
          wallets: [_wallet(id: 'cash', name: 'Cash')],
          expenseId: 'expense-1',
        ),
        throwsA(
          isA<AiExpenseDraftMappingException>().having(
            (error) => error.missingFields,
            'missingFields',
            contains('category'),
          ),
        ),
      );
    });
  });
}

Category _category({
  required String id,
  required String name,
  bool archived = false,
}) {
  return Category(
    categoryId: id,
    userId: 'user-1',
    name: name,
    totalExpenses: 0,
    icon: 'restaurant',
    color: 0xff000000,
    isArchived: archived,
  );
}

WalletAccount _wallet({required String id, required String name}) {
  return WalletAccount(
    walletId: id,
    userId: 'user-1',
    name: name,
    type: 'cash',
    balance: 0,
    currency: 'EGP',
    icon: 'wallet',
    color: 0xff000000,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}
