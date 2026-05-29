abstract class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';

  static const String onboardingLanguage = '/onboarding/language';
  static const String onboardingCurrency = '/onboarding/currency';
  static const String onboardingNotifications = '/onboarding/notifications';

  static const String login = '/auth/login';
  static const String signUp = '/auth/sign-up';

  static const String home = '/home';
  static const String expenses = '/expenses';
  static const String expensesNewQuick = '/expenses/new/quick';
  static const String expensesNewText = '/expenses/new/text';
  static const String expensesNewReceipt = '/expenses/new/receipt';
  static const String expensesEdit = '/expenses/:expenseId/edit';
  static const String expensesFilters = '/expenses/filters';

  static const String reports = '/reports';
  static const String reportsCategory = '/reports/category/:categoryId';

  static const String budgets = '/budgets';
  static const String budgetsCategories = '/budgets/categories';
  static const String budgetsMonthlyEdit = '/budgets/monthly/edit';

  static const String goals = '/goals';

  static const String wallets = '/wallets';

  static const String subscriptions = '/subscriptions';

  static const String aiAdvice = '/ai/advice';
  static const String aiHistory = '/ai/history';
  static const String aiAssistant = '/ai/assistant';

  static const String storyMonthly = '/story/monthly';

  static const String settings = '/settings';

  static const String notFound = '/not-found';

  static const String categories = '/categories';

  static const String securityUnlock = '/security/unlock';
  static const String securityCreatePin = '/security/create-pin';

  static const String accountProfile = '/account/profile';

  static const String subscription = '/subscription';
}
