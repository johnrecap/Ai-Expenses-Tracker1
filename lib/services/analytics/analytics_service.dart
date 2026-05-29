import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._();
  AnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  FirebaseAnalytics? get analytics => _analytics;

  Future<void> initialize() async {
    if (_initialized) return;
    _analytics = FirebaseAnalytics.instance;
    _initialized = true;
  }

  Future<void> logScreenView({required String screenName, String? screenClass}) {
    if (!_initialized) return Future.value();
    return _analytics!.logScreenView(screenName: screenName, screenClass: screenClass);
  }

  Future<void> logSignUp({required String method}) {
    if (!_initialized) return Future.value();
    return _analytics!.logSignUp(signUpMethod: method);
  }

  Future<void> logLogin({required String method}) {
    if (!_initialized) return Future.value();
    return _analytics!.logLogin(loginMethod: method);
  }

  Future<void> logLogout() {
    if (!_initialized) return Future.value();
    return _analytics!.logEvent(name: 'logout');
  }

  Future<void> logAddExpense({required String category, required double amount, required String currency}) {
    if (!_initialized) return Future.value();
    return _analytics!.logEvent(name: 'add_expense', parameters: {
      'category': category,
      'amount': amount,
      'currency': currency,
    });
  }

  Future<void> logEditExpense({required String category, required double amount}) {
    if (!_initialized) return Future.value();
    return _analytics!.logEvent(name: 'edit_expense', parameters: {
      'category': category,
      'amount': amount,
    });
  }

  Future<void> logDeleteExpense({required String category}) {
    if (!_initialized) return Future.value();
    return _analytics!.logEvent(name: 'delete_expense', parameters: {
      'category': category,
    });
  }

  Future<void> logAddBudget({required String category, required double amount, required String currency}) {
    if (!_initialized) return Future.value();
    return _analytics!.logEvent(name: 'add_budget', parameters: {
      'category': category,
      'amount': amount,
      'currency': currency,
    });
  }

  Future<void> logAddGoal({required String name, required double targetAmount, required String currency}) {
    if (!_initialized) return Future.value();
    return _analytics!.logEvent(name: 'add_goal', parameters: {
      'name': name,
      'target_amount': targetAmount,
      'currency': currency,
    });
  }

  Future<void> logSubscriptionManage({required String subscriptionName, required String action}) {
    if (!_initialized) return Future.value();
    return _analytics!.logEvent(name: 'manage_subscription', parameters: {
      'subscription_name': subscriptionName,
      'action': action,
    });
  }

  Future<void> logCustomEvent({required String name, Map<String, Object>? parameters}) {
    if (!_initialized) return Future.value();
    return _analytics!.logEvent(name: name, parameters: parameters);
  }

  Future<void> setUserId(String? id) {
    if (!_initialized) return Future.value();
    return _analytics!.setUserId(id: id);
  }

  Future<void> setUserProperty({required String name, required String? value}) {
    if (!_initialized) return Future.value();
    return _analytics!.setUserProperty(name: name, value: value);
  }
}
