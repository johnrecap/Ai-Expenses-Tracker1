import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'go_router_refresh_stream.dart';
import 'routes.dart';
import 'package:expenses_tracker/features/onboarding/presentation/splash_screen.dart';
import 'package:expenses_tracker/features/onboarding/presentation/language_screen.dart';
import 'package:expenses_tracker/features/onboarding/presentation/base_currency_screen.dart';
import 'package:expenses_tracker/features/onboarding/presentation/notifications_screen.dart';
import 'package:expenses_tracker/features/auth/presentation/login_screen.dart';
import 'package:expenses_tracker/features/auth/presentation/sign_up_screen.dart';
import 'package:expenses_tracker/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:expenses_tracker/features/expenses/presentation/expenses_list_screen.dart';
import 'package:expenses_tracker/features/expenses/presentation/add_expense_quick_screen.dart';
import 'package:expenses_tracker/features/expenses/presentation/add_expense_ai_text_screen.dart';
import 'package:expenses_tracker/features/expenses/presentation/add_expense_receipt_screen.dart';
import 'package:expenses_tracker/features/expenses/presentation/ai_expense_screen.dart';
import 'package:expenses_tracker/features/expenses/presentation/edit_expense_screen.dart';
import 'package:expenses_tracker/features/reports/presentation/reports_main_screen.dart';
import 'package:expenses_tracker/features/reports/presentation/report_drilldown_screen.dart';
import 'package:expenses_tracker/features/reports/presentation/monthly_financial_story_screen.dart';
import 'package:expenses_tracker/features/budgets/presentation/budgets_overview_screen.dart';
import 'package:expenses_tracker/features/budgets/presentation/category_budgets_list_screen.dart';
import 'package:expenses_tracker/features/budgets/presentation/edit_monthly_budget_screen.dart';
import 'package:expenses_tracker/features/goals/presentation/saving_goals_screen.dart';
import 'package:expenses_tracker/features/wallets/presentation/wallets_accounts_screen.dart';
import 'package:expenses_tracker/features/subscriptions/presentation/subscriptions_center_screen.dart';
import 'package:expenses_tracker/features/ai/presentation/ai_advice_screen.dart';
import 'package:expenses_tracker/features/ai/presentation/ai_history_screen.dart';
import 'package:expenses_tracker/features/settings/presentation/settings_screen.dart';
import 'package:expenses_tracker/features/categories/presentation/categories_screen.dart';
import 'package:expenses_tracker/features/security/presentation/unlock_screen.dart';
import 'package:expenses_tracker/features/security/presentation/create_pin_screen.dart';
import 'package:expenses_tracker/features/account/presentation/account_profile_screen.dart';
import 'package:expenses_tracker/monetization/presentation/free_premium_screen.dart';
import 'not_found_screen.dart';

class AppRouter {
  AppRouter._();

  static final _publicRoutes = <String>{
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.signUp,
    AppRoutes.onboardingLanguage,
    AppRoutes.onboardingCurrency,
    AppRoutes.onboardingNotifications,
  };

  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final path = state.matchedLocation;
        final isPublic = _publicRoutes.contains(path);
        if (!isAuthenticated && !isPublic) return AppRoutes.login;
        if (isAuthenticated && (path == AppRoutes.login || path == AppRoutes.signUp)) return AppRoutes.home;
        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.splash, pageBuilder: (c, s) => const NoTransitionPage(child: SplashScreen())),
        GoRoute(path: AppRoutes.onboardingLanguage, pageBuilder: (c, s) => const NoTransitionPage(child: OnboardingLanguageScreen())),
        GoRoute(path: AppRoutes.onboardingCurrency, pageBuilder: (c, s) => const NoTransitionPage(child: BaseCurrencyScreen())),
        GoRoute(path: AppRoutes.onboardingNotifications, pageBuilder: (c, s) => const NoTransitionPage(child: NotificationsScreen())),
        GoRoute(path: AppRoutes.login, pageBuilder: (c, s) => const NoTransitionPage(child: LoginScreen())),
        GoRoute(path: AppRoutes.signUp, pageBuilder: (c, s) => const NoTransitionPage(child: SignUpScreen())),
        GoRoute(path: AppRoutes.home, pageBuilder: (c, s) => const NoTransitionPage(child: HomeDashboardScreen())),
        GoRoute(path: AppRoutes.expenses, pageBuilder: (c, s) => const NoTransitionPage(child: ExpensesListScreen())),
        GoRoute(path: AppRoutes.expensesNewQuick, pageBuilder: (c, s) => const NoTransitionPage(child: AddExpenseQuickScreen())),
        GoRoute(path: AppRoutes.expensesNewText, pageBuilder: (c, s) => const NoTransitionPage(child: AddExpenseAiTextScreen())),
        GoRoute(path: AppRoutes.expensesNewReceipt, pageBuilder: (c, s) => const NoTransitionPage(child: AddExpenseReceiptScreen())),
        GoRoute(path: AppRoutes.expensesNewAi, pageBuilder: (c, s) => const NoTransitionPage(child: AiExpenseScreen())),
        GoRoute(path: '/expenses/:expenseId/edit', pageBuilder: (c, s) => NoTransitionPage(child: EditExpenseScreen(expenseId: s.pathParameters['expenseId']!))),
        GoRoute(path: AppRoutes.reports, pageBuilder: (c, s) => const NoTransitionPage(child: ReportsMainScreen())),
        GoRoute(path: '/reports/category/:categoryId', pageBuilder: (c, s) => NoTransitionPage(child: ReportDrilldownScreen(categoryId: s.pathParameters['categoryId']!))),
        GoRoute(path: AppRoutes.budgets, pageBuilder: (c, s) => const NoTransitionPage(child: BudgetsOverviewScreen())),
        GoRoute(path: AppRoutes.budgetsCategories, pageBuilder: (c, s) => const NoTransitionPage(child: CategoryBudgetsListScreen())),
        GoRoute(path: AppRoutes.budgetsMonthlyEdit, pageBuilder: (c, s) => const NoTransitionPage(child: EditMonthlyBudgetScreen())),
        GoRoute(path: AppRoutes.goals, pageBuilder: (c, s) => const NoTransitionPage(child: SavingGoalsScreen())),
        GoRoute(path: AppRoutes.wallets, pageBuilder: (c, s) => const NoTransitionPage(child: WalletsAccountsScreen())),
        GoRoute(path: AppRoutes.subscriptions, pageBuilder: (c, s) => const NoTransitionPage(child: SubscriptionsCenterScreen())),
        GoRoute(path: AppRoutes.aiAdvice, pageBuilder: (c, s) => const NoTransitionPage(child: AiAdviceScreen())),
        GoRoute(path: AppRoutes.aiHistory, pageBuilder: (c, s) => const NoTransitionPage(child: AiHistoryScreen())),
        GoRoute(path: AppRoutes.storyMonthly, pageBuilder: (c, s) => const NoTransitionPage(child: MonthlyFinancialStoryScreen())),
        GoRoute(path: AppRoutes.settings, pageBuilder: (c, s) => const NoTransitionPage(child: SettingsScreen())),
        GoRoute(path: AppRoutes.categories, pageBuilder: (c, s) => const NoTransitionPage(child: CategoriesScreen())),
        GoRoute(path: AppRoutes.securityUnlock, pageBuilder: (c, s) => const NoTransitionPage(child: UnlockScreen())),
        GoRoute(path: AppRoutes.securityCreatePin, pageBuilder: (c, s) => const NoTransitionPage(child: CreatePinScreen())),
        GoRoute(path: AppRoutes.accountProfile, pageBuilder: (c, s) => NoTransitionPage(child: AccountProfileScreen(user: (s.extra as Map)['user'] as AppUser))),
        GoRoute(path: AppRoutes.subscription, pageBuilder: (c, s) => const NoTransitionPage(child: FreePremiumScreen())),
      ],
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }
}
