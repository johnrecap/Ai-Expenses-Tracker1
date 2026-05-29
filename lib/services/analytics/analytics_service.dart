import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _initialized = false;
  bool _disabled = false;

  FirebaseAnalytics? get analytics => _analytics;
  bool get isAvailable => _initialized && !_disabled;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _analytics = FirebaseAnalytics.instance;
      _initialized = true;
      debugPrint('Analytics: initialized');
    } catch (e) {
      _disabled = true;
      debugPrint('Analytics: initialization failed (403 = API not enabled in Firebase console): $e');
    }
  }

  Future<void> _safeCall(Future<void> Function() fn) async {
    if (!isAvailable) return;
    try {
      await fn();
    } catch (e) {
      debugPrint('Analytics event failed: $e');
    }
  }

  Future<void> logScreenView({required String screenName, String? screenClass}) {
    return _safeCall(() => _analytics!.logScreenView(screenName: screenName, screenClass: screenClass));
  }

  Future<void> logSignUp({required String method}) {
    return _safeCall(() => _analytics!.logSignUp(signUpMethod: method));
  }

  Future<void> logLogin({required String method}) {
    return _safeCall(() => _analytics!.logLogin(loginMethod: method));
  }

  Future<void> logLogout() {
    return _safeCall(() => _analytics!.logEvent(name: 'logout'));
  }

  Future<void> logAddExpense({required String category, required double amount, required String currency}) {
    return _safeCall(() => _analytics!.logEvent(name: 'add_expense', parameters: {
      'category': category,
      'amount': amount,
      'currency': currency,
    }));
  }

  Future<void> logEditExpense({required String category, required double amount}) {
    return _safeCall(() => _analytics!.logEvent(name: 'edit_expense', parameters: {
      'category': category,
      'amount': amount,
    }));
  }

  Future<void> logDeleteExpense({required String category}) {
    return _safeCall(() => _analytics!.logEvent(name: 'delete_expense', parameters: {
      'category': category,
    }));
  }

  Future<void> logAddBudget({required String category, required double amount, required String currency}) {
    return _safeCall(() => _analytics!.logEvent(name: 'add_budget', parameters: {
      'category': category,
      'amount': amount,
      'currency': currency,
    }));
  }

  Future<void> logAddGoal({required String name, required double targetAmount, required String currency}) {
    return _safeCall(() => _analytics!.logEvent(name: 'add_goal', parameters: {
      'name': name,
      'target_amount': targetAmount,
      'currency': currency,
    }));
  }

  Future<void> logSubscriptionManage({required String subscriptionName, required String action}) {
    return _safeCall(() => _analytics!.logEvent(name: 'manage_subscription', parameters: {
      'subscription_name': subscriptionName,
      'action': action,
    }));
  }

  Future<void> logCustomEvent({required String name, Map<String, Object>? parameters}) {
    return _safeCall(() => _analytics!.logEvent(name: name, parameters: parameters));
  }

  Future<void> setUserId(String? id) {
    return _safeCall(() => _analytics!.setUserId(id: id));
  }

  Future<void> setUserProperty({required String name, required String? value}) {
    return _safeCall(() => _analytics!.setUserProperty(name: name, value: value));
  }
}
