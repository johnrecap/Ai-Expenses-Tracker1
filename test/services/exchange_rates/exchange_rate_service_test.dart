import 'dart:convert';

import 'package:expenses_tracker/services/exchange_rates/exchange_rate_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ExchangeRateService', () {
    test('returns 1.0 only for identical currencies without calling the network', () async {
      var calledNetwork = false;
      final service = ExchangeRateService(
        client: MockClient((_) {
          calledNetwork = true;
          throw StateError('Network should not be called for identical currencies.');
        }),
      );

      final result = await service.getRateResult('usd', 'USD');

      expect(result.status, ExchangeRateLookupStatus.fresh);
      expect(result.rate, 1.0);
      expect(await service.getRate('USD', 'USD'), 1.0);
      expect(service.convert(42, 'USD', 'usd'), 42);
      expect(calledNetwork, isFalse);
    });

    test('returns and caches a fresh rate on successful lookup', () async {
      final service = ExchangeRateService(
        client: MockClient((request) async {
          expect(request.url.path, '/v6/latest/USD');
          return http.Response(
            jsonEncode({
              'rates': {'EGP': 50.25},
            }),
            200,
          );
        }),
      );

      final result = await service.getRateResult('USD', 'EGP');

      expect(result.status, ExchangeRateLookupStatus.fresh);
      expect(result.rate, 50.25);
      expect(service.convert(2, 'USD', 'EGP'), 100.5);
      expect(service.isStale, isFalse);
      expect(service.lastFetched, isNotNull);
    });

    test('does not silently return 1.0 when different-currency lookup fails', () async {
      final service = ExchangeRateService(
        client: MockClient((_) async => http.Response('server error', 500)),
      );

      final result = await service.getRateResult('USD', 'EGP');

      expect(result.status, ExchangeRateLookupStatus.failed);
      expect(result.rate, isNull);
      expect(result.failure, isA<ExchangeRateException>());
      await expectLater(
        service.getRate('USD', 'EGP'),
        throwsA(isA<ExchangeRateException>()),
      );
      expect(
        () => service.convert(10, 'USD', 'EGP'),
        throwsA(isA<ExchangeRateException>()),
      );
    });

    test('returns a typed failure for no-key network errors without exposing secrets', () async {
      final service = ExchangeRateService(
        client: MockClient((request) async {
          expect(request.url.host, 'open.er-api.com');
          throw http.ClientException('network unavailable', request.url);
        }),
      );

      final result = await service.getRateResult('USD', 'EGP');

      expect(result.status, ExchangeRateLookupStatus.failed);
      expect(result.failure, isA<ExchangeRateException>());
      expect(result.failure.toString(), isNot(contains('api')));
      await expectLater(
        service.getRate('USD', 'EGP'),
        throwsA(isA<ExchangeRateException>()),
      );
    });

    test('returns stale typed state when cached rate is expired and refresh fails', () async {
      var now = DateTime(2026, 5, 31, 10);
      var shouldFail = false;
      final service = ExchangeRateService(
        now: () => now,
        client: MockClient((_) async {
          if (shouldFail) {
            throw http.ClientException('network unavailable');
          }
          return http.Response(
            jsonEncode({
              'rates': {'EGP': 48.0},
            }),
            200,
          );
        }),
      );

      await expectLater(service.getRate('USD', 'EGP'), completion(48.0));

      shouldFail = true;
      now = now.add(const Duration(hours: 25));
      final result = await service.getRateResult('USD', 'EGP');

      expect(result.status, ExchangeRateLookupStatus.stale);
      expect(result.rate, 48.0);
      await expectLater(
        service.getRate('USD', 'EGP'),
        throwsA(isA<ExchangeRateStaleException>()),
      );
      expect(
        () => service.convert(2, 'USD', 'EGP'),
        throwsA(isA<ExchangeRateStaleException>()),
      );
      final conversion = service.convertResult(2, 'USD', 'EGP');
      expect(conversion.status, ExchangeRateLookupStatus.stale);
      expect(conversion.amount, 96.0);
    });
  });
}
