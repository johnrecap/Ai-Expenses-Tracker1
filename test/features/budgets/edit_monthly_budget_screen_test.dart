import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/budgets/presentation/edit_monthly_budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('uses direct amount entry and saves without a slider', (tester) async {
    final budgetRepository = _FakeBudgetRepository();

    await tester.pumpWidget(_wrapScreen(budgetRepository));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Slider), findsNothing);
    expect(find.byKey(EditMonthlyBudgetScreen.amountFieldKey), findsOneWidget);

    await tester.enterText(
      find.byKey(EditMonthlyBudgetScreen.amountFieldKey),
      '12500',
    );
    await tester.tap(find.byKey(EditMonthlyBudgetScreen.saveButtonKey));
    await tester.pumpAndSettle();

    expect(budgetRepository.savedBudget?.amount, 12500);
    expect(budgetRepository.savedBudget?.userId, 'user-1');
    expect(find.text('Home route'), findsOneWidget);
  });

  testWidgets('shows a clear error when saving an empty amount', (tester) async {
    final budgetRepository = _FakeBudgetRepository();

    await tester.pumpWidget(_wrapScreen(budgetRepository));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(EditMonthlyBudgetScreen.saveButtonKey));
    await tester.pump();

    expect(find.byKey(EditMonthlyBudgetScreen.amountErrorKey), findsOneWidget);
    expect(budgetRepository.savedBudget, isNull);
  });

  testWidgets('back button returns to budgets route when there is no page to pop', (tester) async {
    final budgetRepository = _FakeBudgetRepository();

    await tester.pumpWidget(_wrapScreen(budgetRepository));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Budgets route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _wrapScreen(_FakeBudgetRepository budgetRepository) {
  const user = AppUser(userId: 'user-1', email: 'user@example.com');
  final router = GoRouter(
    initialLocation: AppRoutes.budgetsMonthlyEdit,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const Scaffold(body: Text('Home route')),
      ),
      GoRoute(
        path: AppRoutes.budgets,
        builder: (_, _) => const Scaffold(body: Text('Budgets route')),
        routes: [
          GoRoute(
            path: 'monthly/edit',
            builder: (_, _) => const EditMonthlyBudgetScreen(),
          ),
        ],
      ),
    ],
  );

  final authRepository = _FakeAuthRepository(user);

  return RepositoryProvider<AuthRepository>.value(
    value: authRepository,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository)..add(const AuthUserChanged(user)),
        ),
        BlocProvider<BudgetBloc>(
          create: (_) => BudgetBloc(budgetRepository),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
}

class _FakeBudgetRepository implements BudgetRepository {
  Budget? savedBudget;

  @override
  Future<Budget?> getCurrentMonthBudget({
    required int month,
    required int year,
  }) async => null;

  @override
  Future<void> saveBudget(Budget budget) async {
    savedBudget = budget;
  }

  @override
  Stream<Budget?> watchCurrentMonthBudget({
    required int month,
    required int year,
  }) => const Stream.empty();
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._user);

  final AppUser _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser> get user => Stream.value(_user);

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<AppUser> reauthenticate({
    required String email,
    required String password,
  }) async => _user;

  @override
  Future<AppUser> reauthenticateWithGoogle() async => _user;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async => _user;

  @override
  Future<AppUser?> signInWithGoogle() async => _user;

  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => _user;

  @override
  Future<AppUser> updateDisplayName(String displayName) async => _user;

  @override
  Future<AppUser> updateEmail(String email) async => _user;
}
