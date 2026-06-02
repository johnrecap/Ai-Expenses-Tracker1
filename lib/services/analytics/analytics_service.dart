import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

abstract class AnalyticsEventSink {
  Future<void> logScreenView({required String screenName, String? screenClass});
  Future<void> logSignUp({required String signUpMethod});
  Future<void> logLogin({required String loginMethod});
  Future<void> logEvent({required String name, Map<String, Object>? parameters});
  Future<void> setUserId({String? id});
  Future<void> setUserProperty({required String name, required String? value});
}

class FirebaseAnalyticsEventSink implements AnalyticsEventSink {
  FirebaseAnalyticsEventSink(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logScreenView({required String screenName, String? screenClass}) {
    return _analytics.logScreenView(screenName: screenName, screenClass: screenClass);
  }

  @override
  Future<void> logSignUp({required String signUpMethod}) {
    return _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  @override
  Future<void> logLogin({required String loginMethod}) {
    return _analytics.logLogin(loginMethod: loginMethod);
  }

  @override
  Future<void> logEvent({required String name, Map<String, Object>? parameters}) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> setUserId({String? id}) => _analytics.setUserId(id: id);

  @override
  Future<void> setUserProperty({required String name, required String? value}) {
    return _analytics.setUserProperty(name: name, value: value);
  }
}

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();

  AnalyticsService({AnalyticsEventSink? sink}) : _sink = sink, _initialized = sink != null;
  AnalyticsService._();

  AnalyticsEventSink? _sink;
  bool _initialized = false;
  bool _disabled = false;

  bool get isAvailable => _initialized && !_disabled && _sink != null;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _sink = FirebaseAnalyticsEventSink(FirebaseAnalytics.instance);
      _initialized = true;
      debugPrint('Analytics: initialized');
    } catch (e) {
      _disabled = true;
      debugPrint('Analytics: initialization failed: $e');
    }
  }

  Future<void> _safeCall(Future<void> Function(AnalyticsEventSink sink) fn) async {
    final sink = _sink;
    if (!isAvailable || sink == null) return;
    try {
      await fn(sink);
    } catch (e) {
      debugPrint('Analytics event failed: $e');
    }
  }

  Future<void> logScreenView({required String screenName, String? screenClass}) {
    return _safeCall(
      (sink) => sink.logScreenView(
        screenName: _safeToken(screenName),
        screenClass: screenClass == null ? null : _safeToken(screenClass),
      ),
    );
  }

  Future<void> logSignUp({required String method}) {
    return _safeCall((sink) => sink.logSignUp(signUpMethod: _safeToken(method)));
  }

  Future<void> logLogin({required String method}) {
    return _safeCall((sink) => sink.logLogin(loginMethod: _safeToken(method)));
  }

  Future<void> logLogout() {
    return _safeCall((sink) => sink.logEvent(name: 'logout'));
  }

  Future<void> logAddExpense({
    required String category,
    required double amount,
    required String currency,
  }) {
    return _safeCall(
      (sink) => sink.logEvent(
        name: 'add_expense',
        parameters: {
          'amount_bucket': _amountBucket(amount),
          'currency': _safeCurrency(currency),
          'has_category': category.trim().isNotEmpty,
        },
      ),
    );
  }

  Future<void> logEditExpense({required String category, required double amount}) {
    return _safeCall(
      (sink) => sink.logEvent(
        name: 'edit_expense',
        parameters: {
          'amount_bucket': _amountBucket(amount),
          'has_category': category.trim().isNotEmpty,
        },
      ),
    );
  }

  Future<void> logDeleteExpense({required String category}) {
    return _safeCall(
      (sink) => sink.logEvent(
        name: 'delete_expense',
        parameters: {'has_category': category.trim().isNotEmpty},
      ),
    );
  }

  Future<void> logAddBudget({
    required String category,
    required double amount,
    required String currency,
  }) {
    return _safeCall(
      (sink) => sink.logEvent(
        name: 'add_budget',
        parameters: {
          'amount_bucket': _amountBucket(amount),
          'currency': _safeCurrency(currency),
          'has_category': category.trim().isNotEmpty,
        },
      ),
    );
  }

  Future<void> logAddGoal({
    required String name,
    required double targetAmount,
    required String currency,
  }) {
    return _safeCall(
      (sink) => sink.logEvent(
        name: 'add_goal',
        parameters: {
          'target_bucket': _amountBucket(targetAmount),
          'currency': _safeCurrency(currency),
          'has_name': name.trim().isNotEmpty,
        },
      ),
    );
  }

  Future<void> logSubscriptionManage({
    required String subscriptionName,
    required String action,
  }) {
    return _safeCall(
      (sink) => sink.logEvent(
        name: 'manage_subscription',
        parameters: {
          'action': _safeToken(action),
          'has_subscription_name': subscriptionName.trim().isNotEmpty,
        },
      ),
    );
  }

  Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    return _safeCall(
      (sink) => sink.logEvent(
        name: _safeToken(name),
        parameters: _safeCustomParameters(parameters),
      ),
    );
  }

  Future<void> setUserId(String? id) {
    return _safeCall((sink) => sink.setUserId(id: id));
  }

  Future<void> setUserProperty({required String name, required String? value}) {
    return _safeCall(
      (sink) => sink.setUserProperty(
        name: _safeToken(name),
        value: value == null ? null : _safeToken(value),
      ),
    );
  }
}

Map<String, Object>? _safeCustomParameters(Map<String, Object>? parameters) {
  if (parameters == null || parameters.isEmpty) return null;
  final safe = <String, Object>{};
  for (final entry in parameters.entries) {
    final key = _safeToken(entry.key);
    if (_isSensitiveAnalyticsKey(key)) continue;
    final value = entry.value;
    if (value is bool) {
      safe[key] = value;
    } else if (value is int && _isSafeNumericKey(key)) {
      safe[key] = value;
    } else if (value is double && _isSafeNumericKey(key)) {
      safe[key] = value;
    } else if (value is String && _isSafeStringKey(key)) {
      safe[key] = key == 'currency' ? _safeCurrency(value) : _safeToken(value);
    }
  }
  return safe.isEmpty ? null : safe;
}

bool _isSensitiveAnalyticsKey(String key) {
  return _sensitiveKeyParts.any(key.contains);
}

const _sensitiveKeyParts = [
  'amount',
  'balance',
  'budget',
  'category',
  'cost',
  'description',
  'email',
  'expense',
  'id',
  'merchant',
  'name',
  'note',
  'price',
  'subscription',
  'target',
  'total',
  'user',
  'wallet',
];

bool _isSafeNumericKey(String key) {
  return key.endsWith('_count') || key == 'count' || key.endsWith('_index') || key == 'duration_ms';
}

bool _isSafeStringKey(String key) {
  return key == 'action' ||
      key == 'currency' ||
      key == 'method' ||
      key == 'screen' ||
      key == 'source' ||
      key == 'status' ||
      key == 'type';
}

String _safeCurrency(String value) {
  final normalized = value.trim().toUpperCase();
  final valid = RegExp(r'^[A-Z]{3}$').hasMatch(normalized);
  return valid ? normalized : 'UNK';
}

String _amountBucket(double amount) {
  if (amount < 0) return 'invalid';
  if (amount == 0) return 'zero';
  if (amount < 100) return 'lt_100';
  if (amount < 500) return '100_499';
  if (amount < 1000) return '500_999';
  if (amount < 5000) return '1000_4999';
  if (amount < 10000) return '5000_9999';
  return 'gte_10000';
}

String _safeToken(String value) {
  final normalized = value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
  final collapsed = normalized.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  if (collapsed.isEmpty) return 'unknown';
  return collapsed.length > 40 ? collapsed.substring(0, 40) : collapsed;
}
