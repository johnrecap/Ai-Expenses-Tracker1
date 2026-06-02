import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_client.dart';
import 'package:expenses_tracker/features/expenses/domain/ai_expense_draft_mapper.dart';
import 'package:expenses_tracker/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AiExpenseEntryCubit', () {
    test('parse success creates editable draft', () async {
      final cubit = _cubit(
        response: http.Response(
          jsonEncode({
            'ok': true,
            'requestId': 'req-1',
            'structuredJson': {
              'intent': 'add_expense',
              'amount': 250,
              'currency': 'EGP',
              'categoryId': 'food',
              'date': '2026-05-31T00:00:00.000Z',
              'description': 'Lunch',
              'confidence': 0.9,
              'needsConfirmation': true,
            },
          }),
          200,
        ),
      );

      cubit.textChanged('دفعت 250 جنيه أكل');
      await cubit.parseText(
        locale: 'ar-EG',
        defaultCurrency: 'EGP',
        categories: [_category(id: 'food', name: 'Food')],
        now: DateTime.utc(2026, 5, 31),
      );

      expect(cubit.state.status, AiExpenseEntryStatus.draftReady);
      expect(cubit.state.input, 'دفعت 250 جنيه أكل');
      expect(cubit.state.draft?.amount, 250);
      expect(cubit.state.draft?.categoryId, 'food');
      expect(cubit.state.draft?.missingFields, isNot(contains('wallet')));
      await cubit.close();
    });

    test('quota failure keeps typed input', () async {
      final cubit = _cubit(
        response: http.Response(
          jsonEncode({
            'ok': false,
            'requestId': 'req-quota',
            'errorCode': 'quota_exceeded',
            'errorMessage': 'Provider 429: raw upstream quota stack',
          }),
          429,
        ),
      );

      cubit.textChanged('spent 50 on taxi');
      await cubit.parseText(
        locale: 'en',
        defaultCurrency: 'EGP',
        categories: const [],
      );

      expect(cubit.state.status, AiExpenseEntryStatus.quotaBlocked);
      expect(cubit.state.input, 'spent 50 on taxi');
      expect(cubit.state.errorMessage, 'Daily AI limit reached.');
      await cubit.close();
    });

    test('auth failure asks user to sign in without calling it network', () async {
      final cubit = AiExpenseEntryCubit(
        gatewayClient: AiGatewayClient(
          baseUri: Uri.parse('https://gateway.test'),
          tokenProvider: () async => '',
          httpClient: MockClient((request) async => http.Response('{}', 200)),
        ),
        expenseRepository: LocalExpenseRepository(
          store: LocalRepositoryStore(userId: 'user-1'),
        ),
      );

      cubit.textChanged('spent 50 on taxi');
      await cubit.parseText(
        locale: 'en',
        defaultCurrency: 'EGP',
        categories: const [],
      );

      expect(cubit.state.status, AiExpenseEntryStatus.authRequired);
      expect(cubit.state.errorMessage, 'Sign in to use AI.');
      await cubit.close();
    });

    test('clear amount and category text creates local draft without gateway wait', () async {
      final cubit = AiExpenseEntryCubit(
        gatewayClient: AiGatewayClient(
          baseUri: Uri.parse('https://gateway.test'),
          tokenProvider: () async => 'token',
          httpClient: MockClient((request) async {
            fail('Gateway should not be called for a clear local draft.');
          }),
        ),
        expenseRepository: LocalExpenseRepository(
          store: LocalRepositoryStore(userId: 'user-1'),
        ),
      );

      cubit.textChanged('spent 250 EGP on food');
      await cubit.parseText(
        locale: 'en',
        defaultCurrency: 'EGP',
        categories: [_category(id: 'food', name: 'Food')],
        now: DateTime.utc(2026, 6, 1),
      );

      expect(cubit.state.status, AiExpenseEntryStatus.draftReady);
      expect(cubit.state.draft?.amount, 250);
      expect(cubit.state.draft?.categoryId, 'food');
      expect(cubit.state.draft?.currency, 'EGP');
      await cubit.close();
    });

    test('network failure keeps retryable state without raw exception', () async {
      final cubit = AiExpenseEntryCubit(
        gatewayClient: AiGatewayClient(
          baseUri: Uri.parse('https://gateway.test'),
          tokenProvider: () async => 'token',
          httpClient: MockClient((request) async {
            throw Exception('socket failed with raw input');
          }),
        ),
        expenseRepository: LocalExpenseRepository(
          store: LocalRepositoryStore(userId: 'user-1'),
        ),
      );

      cubit.textChanged('spent 50 on taxi');
      await cubit.parseText(
        locale: 'en',
        defaultCurrency: 'EGP',
        categories: const [],
      );

      expect(cubit.state.status, AiExpenseEntryStatus.networkFailure);
      expect(cubit.state.errorMessage, 'Network problem.');
      expect(cubit.state.errorMessage, isNot(contains('socket failed')));
      await cubit.close();
    });

    test('gateway unavailable uses unavailable state without provider text', () async {
      final cubit = _cubit(
        response: http.Response(
          jsonEncode({
            'ok': false,
            'requestId': 'req-unavailable',
            'errorCode': 'provider_unavailable',
            'errorMessage': 'upstream provider is down',
          }),
          503,
        ),
      );

      cubit.textChanged('spent 50 on taxi');
      await cubit.parseText(
        locale: 'en',
        defaultCurrency: 'EGP',
        categories: const [],
      );

      expect(cubit.state.status, AiExpenseEntryStatus.gatewayUnavailable);
      expect(cubit.state.errorMessage, 'AI is unavailable.');
      expect(cubit.state.errorMessage, isNot(contains('upstream')));
      await cubit.close();
    });

    test('invalid response maps to safe generic failure', () async {
      final cubit = _cubit(response: http.Response('raw provider body', 200));

      cubit.textChanged('spent 50 on taxi');
      await cubit.parseText(
        locale: 'en',
        defaultCurrency: 'EGP',
        categories: const [],
      );

      expect(cubit.state.status, AiExpenseEntryStatus.parseFailed);
      expect(cubit.state.errorMessage, 'AI could not finish.');
      expect(cubit.state.errorMessage, isNot(contains('raw provider')));
      await cubit.close();
    });

    test('save success persists user-edited draft', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final wallet = _wallet(id: 'cash', name: 'Cash');
      await store.upsertWallet(wallet);
      final cubit = AiExpenseEntryCubit(
        gatewayClient: _gateway(http.Response('{}', 500)),
        expenseRepository: LocalExpenseRepository(store: store),
        expenseIdFactory: () => 'expense-1',
      );
      final category = _category(id: 'food', name: 'Food');

      cubit.updateDraft(
        AiExpenseDraftSelection(
          amount: 300,
          currency: 'EGP',
          date: DateTime.utc(2026, 5, 31),
          categoryId: 'food',
          walletAccountId: 'cash',
          description: 'Edited lunch',
          gatewayRequestId: 'req-1',
        ),
      );
      final statusExpectation = expectLater(
        cubit.stream.map((state) => state.status),
        emitsInOrder([
          AiExpenseEntryStatus.saving,
          AiExpenseEntryStatus.saved,
        ]),
      );

      await cubit.saveDraft(
        userId: 'user-1',
        categories: [category],
        wallets: [wallet],
      );
      await statusExpectation;

      expect(cubit.state.status, AiExpenseEntryStatus.saved);
      expect(store.expenses.single.description, 'Edited lunch');
      expect(store.expenses.single.amount, 300);
      await cubit.close();
    });

    test('save blocks incomplete draft without persisting', () async {
      final store = LocalRepositoryStore(userId: 'user-1');
      final cubit = AiExpenseEntryCubit(
        gatewayClient: _gateway(http.Response('{}', 500)),
        expenseRepository: LocalExpenseRepository(store: store),
      );

      cubit.updateDraft(
        const AiExpenseDraftSelection(
          amount: 20,
          currency: 'EGP',
          categoryName: 'Food',
        ),
      );
      await cubit.saveDraft(
        userId: 'user-1',
        categories: [_category(id: 'food', name: 'Food')],
        wallets: [_wallet(id: 'cash', name: 'Cash')],
      );

      expect(cubit.state.status, AiExpenseEntryStatus.draftReady);
      expect(cubit.state.errorMessage, contains('Complete missing fields'));
      expect(store.expenses, isEmpty);
      await cubit.close();
    });
  });
}

AiExpenseEntryCubit _cubit({required http.Response response}) {
  return AiExpenseEntryCubit(
    gatewayClient: _gateway(response),
    expenseRepository: LocalExpenseRepository(
      store: LocalRepositoryStore(userId: 'user-1'),
    ),
  );
}

AiGatewayClient _gateway(http.Response response) {
  return AiGatewayClient(
    baseUri: Uri.parse('https://gateway.test'),
    tokenProvider: () async => 'token',
    httpClient: MockClient((request) async => response),
  );
}

Category _category({required String id, required String name}) {
  return Category(
    categoryId: id,
    userId: 'user-1',
    name: name,
    totalExpenses: 0,
    icon: 'restaurant',
    color: 0xff000000,
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
