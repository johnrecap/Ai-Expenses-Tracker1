import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/app/router.dart';

void main() {
  group('Route constants', () {
    test('all route constants are defined and non-empty', () {
      final routes = [
        AppRoutes.splash, AppRoutes.home, AppRoutes.expenses,
        AppRoutes.expensesNewQuick, AppRoutes.expensesNewText, AppRoutes.expensesNewReceipt,
        AppRoutes.reports, AppRoutes.budgets, AppRoutes.budgetsCategories,
        AppRoutes.budgetsMonthlyEdit, AppRoutes.goals, AppRoutes.wallets,
        AppRoutes.subscriptions, AppRoutes.aiAdvice, AppRoutes.aiHistory,
        AppRoutes.aiAssistant, AppRoutes.storyMonthly, AppRoutes.settings,
        AppRoutes.login, AppRoutes.signUp,
        AppRoutes.onboardingLanguage, AppRoutes.onboardingCurrency,
        AppRoutes.onboardingNotifications,
      ];
      for (final route in routes) {
        expect(route, isNotEmpty);
        expect(route.startsWith('/'), true);
      }
    });

    test('dynamic route patterns are valid', () {
      expect(AppRoutes.expensesEdit, contains(':expenseId'));
      expect(AppRoutes.reportsCategory, contains(':categoryId'));
    });

    test('modal routes are defined', () {
      expect(AppRoutes.expensesFilters, isNotEmpty);
      expect(AppRoutes.aiAssistant, isNotEmpty);
    });

    test('router can be created', () {
      final router = AppRouter.create();
      expect(router, isNotNull);
    });
  });
}
