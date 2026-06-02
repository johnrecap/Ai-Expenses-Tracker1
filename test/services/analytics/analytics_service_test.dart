import 'package:expenses_tracker/services/analytics/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsService', () {
    test('expense events do not send raw amount or category', () async {
      final sink = _RecordingAnalyticsSink();
      final service = AnalyticsService(sink: sink);

      await service.logAddExpense(category: 'Medical Bills', amount: 1250, currency: 'egp');

      final event = sink.events.single;
      expect(event.name, 'add_expense');
      expect(event.parameters, {
        'amount_bucket': '1000_4999',
        'currency': 'EGP',
        'has_category': true,
      });
      expect(event.parameters.values, isNot(contains('Medical Bills')));
      expect(event.parameters.values, isNot(contains(1250)));
    });

    test('goal and subscription events avoid personal names', () async {
      final sink = _RecordingAnalyticsSink();
      final service = AnalyticsService(sink: sink);

      await service.logAddGoal(name: 'Wedding Fund', targetAmount: 50000, currency: 'USD');
      await service.logSubscriptionManage(subscriptionName: 'Netflix', action: 'pause');

      expect(sink.events[0].parameters, {
        'target_bucket': 'gte_10000',
        'currency': 'USD',
        'has_name': true,
      });
      expect(sink.events[0].parameters.values, isNot(contains('Wedding Fund')));
      expect(sink.events[1].parameters, {
        'action': 'pause',
        'has_subscription_name': true,
      });
      expect(sink.events[1].parameters.values, isNot(contains('Netflix')));
    });

    test('custom events drop sensitive keys and unsafe strings', () async {
      final sink = _RecordingAnalyticsSink();
      final service = AnalyticsService(sink: sink);

      await service.logCustomEvent(
        name: 'Feature Used',
        parameters: {
          'merchant': 'Sensitive Shop',
          'amount': 250.0,
          'wallet_name': 'Personal Wallet',
          'count': 3,
          'status': 'Completed OK',
          'currency': 'egp',
        },
      );

      final event = sink.events.single;
      expect(event.name, 'feature_used');
      expect(event.parameters, {
        'count': 3,
        'status': 'completed_ok',
        'currency': 'EGP',
      });
    });
  });
}

class _RecordedEvent {
  const _RecordedEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object> parameters;
}

class _RecordingAnalyticsSink implements AnalyticsEventSink {
  final events = <_RecordedEvent>[];

  @override
  Future<void> logEvent({required String name, Map<String, Object>? parameters}) async {
    events.add(_RecordedEvent(name, parameters ?? const {}));
  }

  @override
  Future<void> logLogin({required String loginMethod}) async {
    events.add(_RecordedEvent('login', {'method': loginMethod}));
  }

  @override
  Future<void> logScreenView({required String screenName, String? screenClass}) async {
    events.add(_RecordedEvent('screen_view', {'screen': screenName}));
  }

  @override
  Future<void> logSignUp({required String signUpMethod}) async {
    events.add(_RecordedEvent('sign_up', {'method': signUpMethod}));
  }

  @override
  Future<void> setUserId({String? id}) async {}

  @override
  Future<void> setUserProperty({required String name, required String? value}) async {}
}
