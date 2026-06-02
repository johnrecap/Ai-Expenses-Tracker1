import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_client.dart';
import 'package:expenses_tracker/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart';
import 'package:expenses_tracker/features/expenses/presentation/widgets/ai_expense_parse_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AiExpenseParsePanel user states', () {
    testWidgets('uses padded input surface and parses from keyboard done', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        _gateway(
          http.Response(
            jsonEncode({
              'ok': true,
              'requestId': 'req-keyboard',
              'structuredJson': {
                'amount': 50,
                'currency': 'EGP',
                'categoryId': 'food',
                'category': 'Food',
                'date': '2026-05-31T00:00:00.000Z',
                'description': 'Taxi',
              },
            }),
            200,
          ),
        ),
        categories: [_category()],
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.textInputAction, TextInputAction.done);
      expect(field.decoration?.contentPadding, isNot(EdgeInsets.zero));
      expect(field.decoration?.border, isA<OutlineInputBorder>());

      await tester.enterText(find.byType(TextField), 'spent 50 on taxi');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('AI Suggestion'), findsOneWidget);
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testWidgets('renders draft review after successful parsing', (tester) async {
      await _pumpPanel(
        tester,
        _gateway(
          http.Response(
            jsonEncode({
              'ok': true,
              'requestId': 'req-1',
              'structuredJson': {
                'amount': 50,
                'currency': 'EGP',
                'categoryId': 'food',
                'category': 'Food',
                'date': '2026-05-31T00:00:00.000Z',
                'description': 'Taxi',
              },
            }),
            200,
          ),
        ),
        categories: [_category()],
      );

      await _parse(tester);

      expect(find.text('AI Suggestion'), findsOneWidget);
      expect(find.text('50.00 EGP'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('wallet'), findsNothing);
    });

    testWidgets('infers payment method from input when gateway omits it', (tester) async {
      await _pumpPanel(
        tester,
        _gateway(
          http.Response(
            jsonEncode({
              'ok': true,
              'requestId': 'req-card',
              'structuredJson': {
                'amount': 50,
                'currency': 'EGP',
                'categoryId': 'food',
                'category': 'Food',
                'date': '2026-05-31T00:00:00.000Z',
                'description': 'Taxi',
              },
            }),
            200,
          ),
        ),
        categories: [_category()],
      );

      await _parse(tester, input: 'spent 50 on taxi by card');

      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Visa/Card'), findsOneWidget);
    });

    testWidgets('shows sign-in state when auth token is missing', (tester) async {
      await _pumpPanel(
        tester,
        AiGatewayClient(
          baseUri: Uri.parse('https://gateway.test'),
          tokenProvider: () async => '',
          httpClient: MockClient((request) async => http.Response('{}', 200)),
        ),
      );

      await _parse(tester);

      expect(find.text('Sign in to use AI.'), findsOneWidget);
      expect(find.textContaining('session is missing'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('shows daily limit state without server technical text', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        _gateway(
          http.Response(
            jsonEncode({
              'ok': false,
              'requestId': 'req-quota',
              'errorCode': 'quota_exceeded',
              'errorMessage': 'Provider 429: raw upstream quota stack',
              'quota': {
                'requestType': 'parse_text',
                'allowed': false,
                'limit': 5,
                'used': 5,
                'remaining': 0,
              },
            }),
            429,
          ),
        ),
      );

      await _parse(tester);

      expect(find.text('Daily AI limit reached.'), findsOneWidget);
      expect(find.textContaining('5/5 AI requests'), findsOneWidget);
      expect(find.textContaining('Provider 429'), findsNothing);
    });

    testWidgets('shows network state with retry action', (tester) async {
      await _pumpPanel(
        tester,
        AiGatewayClient(
          baseUri: Uri.parse('https://gateway.test'),
          tokenProvider: () async => 'token',
          httpClient: MockClient((request) async {
            throw Exception('socket failed with raw input');
          }),
        ),
      );

      await _parse(tester);

      expect(find.text('Network problem.'), findsOneWidget);
      expect(find.text('Check your connection, then retry.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('socket failed'), findsNothing);
    });

    testWidgets('shows gateway unavailable state', (tester) async {
      await _pumpPanel(
        tester,
        _gateway(
          http.Response(
            jsonEncode({
              'ok': false,
              'requestId': 'req-unavailable',
              'errorCode': 'provider_unavailable',
              'errorMessage': 'upstream provider unavailable',
            }),
            503,
          ),
        ),
      );

      await _parse(tester);

      expect(find.text('AI is unavailable.'), findsOneWidget);
      expect(find.textContaining('gateway is temporarily unavailable'), findsOneWidget);
      expect(find.textContaining('upstream provider'), findsNothing);
    });

    testWidgets('shows safe generic failure for invalid response', (
      tester,
    ) async {
      await _pumpPanel(
        tester,
        _gateway(http.Response('raw provider error body', 200)),
      );

      await _parse(tester);

      expect(find.text('AI could not finish.'), findsOneWidget);
      expect(find.textContaining('Retry or enter the expense manually'), findsOneWidget);
      expect(find.textContaining('raw provider'), findsNothing);
    });
  });
}

Future<void> _pumpPanel(
  WidgetTester tester,
  AiGatewayClient gatewayClient, {
  List<Category> categories = const [],
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider(
            create: (_) => AiExpenseEntryCubit(
              gatewayClient: gatewayClient,
              expenseRepository: LocalExpenseRepository(
                store: LocalRepositoryStore(userId: 'user-1'),
              ),
            ),
            child: AiExpenseParsePanel(
              categories: categories,
              defaultCurrency: 'EGP',
              defaultPaymentMethod: PaymentMethod.cash,
              locale: 'en',
            ),
          ),
        ),
      ),
    ),
  );
}

Category _category() {
  return Category(
    categoryId: 'food',
    userId: 'user-1',
    name: 'Food',
    totalExpenses: 0,
    icon: 'restaurant',
    color: 0xff000000,
  );
}

Future<void> _parse(
  WidgetTester tester, {
  String input = 'spent 50 on taxi',
}) async {
  await tester.enterText(find.byType(TextField), input);
  await tester.tap(find.text('Parse'));
  await tester.pumpAndSettle();
}

AiGatewayClient _gateway(http.Response response) {
  return AiGatewayClient(
    baseUri: Uri.parse('https://gateway.test'),
    tokenProvider: () async => 'token',
    httpClient: MockClient((request) async => response),
  );
}
