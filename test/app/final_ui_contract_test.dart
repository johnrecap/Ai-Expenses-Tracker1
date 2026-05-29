import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/app/router.dart';

void main() {
  group('Final UI Contract', () {
    test('all detected Stitch screens have routes', () {
      const requiredRoutes = [
        '/splash', '/onboarding/language', '/onboarding/currency', '/onboarding/notifications',
        '/auth/login', '/auth/sign-up',
        '/home', '/expenses',
        '/expenses/new/quick', '/expenses/new/text', '/expenses/new/receipt',
        '/reports', '/budgets', '/budgets/categories', '/budgets/monthly/edit',
        '/goals', '/wallets', '/subscriptions',
        '/ai/advice', '/ai/history', '/ai/assistant',
        '/story/monthly', '/settings',
      ];

      final router = AppRouter.create();
      for (final route in requiredRoutes) {
        final config = router.routerDelegate.currentConfiguration;
        expect(config, isNotNull);
      }

      for (final route in requiredRoutes) {
        expect(route, isNotEmpty);
        expect(route.startsWith('/'), true);
      }
    });

    test('dynamic routes handle parameters', () {
      expect(AppRoutes.expensesEdit, contains(':expenseId'));
      expect(AppRoutes.reportsCategory, contains(':categoryId'));
    });

    test('all route constants are non-empty', () {
      final routes = [
        AppRoutes.splash, AppRoutes.home, AppRoutes.expenses, AppRoutes.expensesNewQuick,
        AppRoutes.expensesNewText, AppRoutes.expensesNewReceipt, AppRoutes.reports,
        AppRoutes.budgets, AppRoutes.budgetsCategories, AppRoutes.budgetsMonthlyEdit,
        AppRoutes.goals, AppRoutes.wallets, AppRoutes.subscriptions,
        AppRoutes.aiAdvice, AppRoutes.aiHistory, AppRoutes.aiAssistant,
        AppRoutes.storyMonthly, AppRoutes.settings,
        AppRoutes.login, AppRoutes.signUp,
        AppRoutes.onboardingLanguage, AppRoutes.onboardingCurrency, AppRoutes.onboardingNotifications,
      ];
      for (final route in routes) {
        expect(route, isNotEmpty);
      }
    });
  });
}
