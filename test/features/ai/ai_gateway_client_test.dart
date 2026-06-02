import 'dart:convert';

import 'package:expenses_tracker/features/ai/data/ai_gateway_client.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AiGatewayClient', () {
    test('sends bearer token and parses expense draft', () async {
      late http.Request captured;
      final client = AiGatewayClient(
        baseUri: Uri.parse('https://gateway.test/base'),
        tokenProvider: () async => 'token-123',
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'ok': true,
              'requestId': 'req-1',
              'provider': 'gemini',
              'model': 'test-model',
              'structuredJson': {
                'intent': 'add_expense',
                'amount': 250,
                'currency': 'EGP',
                'category': 'Food',
                'date': '2026-05-31T12:00:00.000Z',
                'description': 'Lunch',
                'confidence': 0.91,
                'needsConfirmation': true,
              },
              'quota': {
                'requestType': 'parse_text',
                'allowed': true,
                'limit': 5,
                'used': 1,
                'remaining': 4,
                'resetAt': '2026-06-01T00:00:00.000Z',
              },
            }),
            200,
          );
        }),
      );

      final response = await client.parseExpense(
        AiGatewayParseTextRequest(
          input: 'دفعت 250 جنيه أكل',
          now: DateTime.utc(2026, 5, 31, 12),
          locale: 'ar-EG',
          defaultCurrency: 'EGP',
        ),
      );

      expect(captured.url.toString(), 'https://gateway.test/base/aiParse');
      expect(captured.headers['Authorization'], 'Bearer token-123');
      expect(captured.headers.containsKey('X-API-Key'), isFalse);
      expect(response.requestId, 'req-1');
      expect(response.draft.amount, 250);
      expect(response.draft.categoryName, 'Food');
      expect(response.quota?.remaining, 4);
    });

    test('throws unauthenticated before network when token is missing', () async {
      var called = false;
      final client = AiGatewayClient(
        baseUri: Uri.parse('https://gateway.test'),
        tokenProvider: () async => '',
        httpClient: MockClient((request) async {
          called = true;
          return http.Response('{}', 200);
        }),
      );

      expect(
        () => client.parseExpense(
          AiGatewayParseTextRequest(
            input: 'spent 50',
            now: DateTime.utc(2026),
            locale: 'en',
            defaultCurrency: 'EGP',
          ),
        ),
        throwsA(
          isA<AiGatewayClientException>().having(
            (error) => error.code,
            'code',
            AiGatewayErrorCode.unauthenticated,
          ),
        ),
      );
      expect(called, isFalse);
    });

    test('maps quota failure without exposing raw response body', () async {
      final client = AiGatewayClient(
        baseUri: Uri.parse('https://gateway.test'),
        tokenProvider: () async => 'token',
        httpClient: MockClient((request) async {
          return http.Response(
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
                'resetAt': '2026-06-01T00:00:00.000Z',
              },
              'debug': 'raw-secret-body',
            }),
            429,
          );
        }),
      );

      try {
        await client.parseExpense(
          AiGatewayParseTextRequest(
            input: 'spent 50',
            now: DateTime.utc(2026),
            locale: 'en',
            defaultCurrency: 'EGP',
          ),
        );
        fail('Expected quota exception');
      } on AiGatewayClientException catch (error) {
        expect(error.code, AiGatewayErrorCode.quotaExceeded);
        expect(error.message, 'Daily AI limit reached.');
        expect(error.requestId, 'req-quota');
        expect(error.quota?.remaining, 0);
        expect(error.toString(), isNot(contains('raw-secret-body')));
        expect(error.message, isNot(contains('Provider 429')));
      }
    });

    test('invalid response body becomes safe typed error', () async {
      final client = AiGatewayClient(
        baseUri: Uri.parse('https://gateway.test'),
        tokenProvider: () async => 'token',
        httpClient: MockClient((request) async {
          return http.Response('not-json raw user text', 200);
        }),
      );

      expect(
        () => client.parseExpense(
          AiGatewayParseTextRequest(
            input: 'spent 50',
            now: DateTime.utc(2026),
            locale: 'en',
            defaultCurrency: 'EGP',
          ),
        ),
        throwsA(
          isA<AiGatewayClientException>()
              .having(
                (error) => error.code,
                'code',
                AiGatewayErrorCode.invalidResponse,
              )
              .having(
                (error) => error.message,
                'message',
                'AI could not finish.',
              ),
        ),
      );
    });

    test('network failure becomes safe typed error', () async {
      final client = AiGatewayClient(
        baseUri: Uri.parse('https://gateway.test'),
        tokenProvider: () async => 'token',
        httpClient: MockClient((request) async {
          throw Exception('socket failed with raw input');
        }),
      );

      expect(
        () => client.getAdvice(
          AiGatewayAdviceRequest(
            period: 'month',
            now: DateTime.utc(2026),
            locale: 'en',
            defaultCurrency: 'EGP',
            summary: const {'total': 100},
          ),
        ),
        throwsA(
          isA<AiGatewayClientException>()
              .having(
                (error) => error.code,
                'code',
                AiGatewayErrorCode.network,
              )
              .having(
                (error) => error.message,
                'message',
                'Network problem.',
              ),
        ),
      );
    });

    test('times out slow advice requests with safe typed error', () async {
      final client = AiGatewayClient(
        baseUri: Uri.parse('https://gateway.test'),
        tokenProvider: () async => 'token',
        timeout: const Duration(milliseconds: 10),
        httpClient: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return http.Response('{}', 200);
        }),
      );

      expect(
        () => client.getAdvice(
          AiGatewayAdviceRequest(
            period: 'month',
            now: DateTime.utc(2026),
            locale: 'en',
            defaultCurrency: 'EGP',
            summary: const {'total': 100},
          ),
        ),
        throwsA(
          isA<AiGatewayClientException>()
              .having(
                (error) => error.code,
                'code',
                AiGatewayErrorCode.providerTimeout,
              )
              .having(
                (error) => error.userMessage.canRetry,
                'canRetry',
                isTrue,
              )
              .having(
                (error) => error.message,
                'message',
                isNot(contains('gateway.test')),
              ),
        ),
      );
    });
  });
}
