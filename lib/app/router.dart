import 'package:go_router/go_router.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:flutter/widgets.dart';
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
  };

  static GoRouter create(
    AuthBloc authBloc, {
    RepositoryRuntimeMode runtimeMode = RepositoryRuntimeMode.localOnly,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        return redirectFor(
          authState: authBloc.state,
          path: state.matchedLocation,
          runtimeMode: runtimeMode,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          pageBuilder: (c, s) => const NoTransitionPage(child: SplashScreen()),
        ),
        GoRoute(
          path: AppRoutes.onboardingLanguage,
          pageBuilder: (c, s) => const NoTransitionPage(child: OnboardingLanguageScreen()),
        ),
        GoRoute(
          path: AppRoutes.onboardingCurrency,
          pageBuilder: (c, s) => const NoTransitionPage(child: BaseCurrencyScreen()),
        ),
        GoRoute(
          path: AppRoutes.onboardingNotifications,
          pageBuilder: (c, s) => const NoTransitionPage(child: NotificationsScreen()),
        ),
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (c, s) => const NoTransitionPage(child: LoginScreen()),
        ),
        GoRoute(
          path: AppRoutes.signUp,
          pageBuilder: (c, s) => const NoTransitionPage(child: SignUpScreen()),
        ),
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (c, s) => const NoTransitionPage(child: HomeDashboardScreen()),
        ),
        GoRoute(
          path: AppRoutes.expenses,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.home,
              child: ExpensesListScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.expensesNewQuick,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.expenses,
              child: AddExpenseQuickScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.expensesNewText,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.expenses,
              child: AddExpenseAiTextScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.expensesNewReceipt,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.expenses,
              child: AddExpenseReceiptScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.expensesNewAi,
          redirect: (c, s) => AppRoutes.expensesNewText,
          pageBuilder: (c, s) => const NoTransitionPage(child: AddExpenseAiTextScreen()),
        ),
        GoRoute(
          path: '/expenses/:expenseId/edit',
          pageBuilder: (c, s) => NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.expenses,
              child: EditExpenseScreen(expenseId: s.pathParameters['expenseId']!),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.reports,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.home,
              child: ReportsMainScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/reports/category/:categoryId',
          pageBuilder: (c, s) => NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.reports,
              child: ReportDrilldownScreen(categoryId: s.pathParameters['categoryId']!),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.budgets,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.home,
              child: BudgetsOverviewScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.budgetsCategories,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.budgets,
              child: CategoryBudgetsListScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.budgetsMonthlyEdit,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.budgets,
              child: EditMonthlyBudgetScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.goals,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.home,
              child: SavingGoalsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.wallets,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.home,
              child: WalletsAccountsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.subscriptions,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.home,
              child: SubscriptionsCenterScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.aiAdvice,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.home,
              child: AiAdviceScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.aiHistory,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.home,
              child: AiHistoryScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.storyMonthly,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.reports,
              child: MonthlyFinancialStoryScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.home,
              child: SettingsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.categories,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.settings,
              child: CategoriesScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.securityUnlock,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.settings,
              child: UnlockScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.securityCreatePin,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.settings,
              child: CreatePinScreen(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.accountProfile,
          pageBuilder: (c, s) => NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.settings,
              child: AccountProfileScreen(user: _accountProfileUser(authBloc, s.extra)),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.subscription,
          pageBuilder: (c, s) => const NoTransitionPage(
            child: _BackFallbackScope(
              fallbackRoute: AppRoutes.settings,
              child: FreePremiumScreen(),
            ),
          ),
        ),
      ],
      errorBuilder: (context, state) => const NotFoundScreen(),
    );
  }

  @visibleForTesting
  static String? redirectFor({
    required AuthState authState,
    required String path,
    required RepositoryRuntimeMode runtimeMode,
  }) {
    final isAuthenticated = authState is AuthAuthenticated;
    final isPublic = _publicRoutes.contains(path);
    if (!isAuthenticated && !isPublic) {
      return AppRoutes.login;
    }
    if (isAuthenticated && (path == AppRoutes.login || path == AppRoutes.signUp)) {
      return AppRoutes.splash;
    }
    return null;
  }

  static AppUser _accountProfileUser(AuthBloc authBloc, Object? extra) {
    if (extra is Map && extra['user'] is AppUser) {
      return extra['user'] as AppUser;
    }
    final authState = authBloc.state;
    if (authState is AuthAuthenticated) return authState.user;
    return AppUser.empty;
  }
}

class _BackFallbackScope extends StatelessWidget {
  const _BackFallbackScope({
    required this.fallbackRoute,
    required this.child,
  });

  final String fallbackRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canUseNavigatorBack = Navigator.of(context).canPop();
    return PopScope(
      canPop: canUseNavigatorBack,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (router.routeInformationProvider.value.uri.path != fallbackRoute) {
          context.go(fallbackRoute);
        }
      },
      child: child,
    );
  }
}
