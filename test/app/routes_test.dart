import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/app/router.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expense_repository/expense_repository.dart';

class _MockAuthRepo implements AuthRepository {
  @override
  AppUser get currentUser => AppUser.empty;
  @override
  Stream<AppUser> get user => Stream.value(AppUser.empty);
  @override
  Future<AppUser> signIn({required String email, required String password}) async => AppUser.empty;
  @override
  Future<AppUser> signInWithGoogle() async => AppUser.empty;
  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => AppUser.empty;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<AppUser> updateDisplayName(String name) async => AppUser.empty;
  @override
  Future<AppUser> updateEmail(String email) async => AppUser.empty;
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<AppUser> reauthenticate({required String email, required String password}) async =>
      AppUser.empty;
  @override
  Future<AppUser> reauthenticateWithGoogle() async => AppUser.empty;
}

void main() {
  group('Route constants', () {
    test('all route constants are defined and non-empty', () {
      final routes = [
        AppRoutes.splash,
        AppRoutes.home,
        AppRoutes.expenses,
        AppRoutes.expensesNewQuick,
        AppRoutes.expensesNewText,
        AppRoutes.expensesNewReceipt,
        AppRoutes.expensesNewAi,
        AppRoutes.reports,
        AppRoutes.budgets,
        AppRoutes.budgetsCategories,
        AppRoutes.budgetsMonthlyEdit,
        AppRoutes.goals,
        AppRoutes.wallets,
        AppRoutes.subscriptions,
        AppRoutes.aiAdvice,
        AppRoutes.aiHistory,
        AppRoutes.aiAssistant,
        AppRoutes.storyMonthly,
        AppRoutes.settings,
        AppRoutes.login,
        AppRoutes.signUp,
        AppRoutes.onboardingLanguage,
        AppRoutes.onboardingCurrency,
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
      final router = AppRouter.create(AuthBloc(_MockAuthRepo()));
      expect(router, isNotNull);
    });

    test('local-only mode protects core routes without login', () {
      final redirect = AppRouter.redirectFor(
        authState: AuthUnauthenticated(),
        path: AppRoutes.home,
        runtimeMode: RepositoryRuntimeMode.localOnly,
      );

      expect(redirect, AppRoutes.login);
    });

    test('local-only mode protects onboarding routes without login', () {
      final redirect = AppRouter.redirectFor(
        authState: AuthUnauthenticated(),
        path: AppRoutes.onboardingLanguage,
        runtimeMode: RepositoryRuntimeMode.localOnly,
      );

      expect(redirect, AppRoutes.login);
    });

    test('public routes stay public before login', () {
      for (final path in [AppRoutes.splash, AppRoutes.login, AppRoutes.signUp]) {
        final redirect = AppRouter.redirectFor(
          authState: AuthUnauthenticated(),
          path: path,
          runtimeMode: RepositoryRuntimeMode.localOnly,
        );

        expect(redirect, isNull);
      }
    });

    test('authenticated users leave auth screens through splash', () {
      const user = AppUser(userId: 'user-1', email: 'user@example.com');
      for (final path in [AppRoutes.login, AppRoutes.signUp]) {
        final redirect = AppRouter.redirectFor(
          authState: const AuthAuthenticated(user),
          path: path,
          runtimeMode: RepositoryRuntimeMode.localOnly,
        );

        expect(redirect, AppRoutes.splash);
      }
    });

    test('legacy Firebase mode still protects core routes without login', () {
      final redirect = AppRouter.redirectFor(
        authState: AuthUnauthenticated(),
        path: AppRoutes.home,
        runtimeMode: RepositoryRuntimeMode.firebaseLegacy,
      );

      expect(redirect, AppRoutes.login);
    });

    test('legacy AI expense route stays defined for redirect compatibility', () {
      expect(AppRoutes.expensesNewAi, '/expenses/new/ai');
      expect(AppRoutes.expensesNewText, '/expenses/new/text');
      expect(AppRoutes.expensesNewAi, isNot(AppRoutes.expensesNewText));
    });
  });
}
