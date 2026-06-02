import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:expenses_tracker/features/dashboard/presentation/widgets/smart_add_sheet.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('HomeDashboardScreen smart add entry', () {
    testWidgets('shows one primary add FAB and no separate AI expense FAB', (tester) async {
      await tester.pumpWidget(_wrapHomeDashboard());

      expect(find.byKey(HomeDashboardScreen.smartAddButtonKey), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      final fabPadding = tester.widget<Padding>(
        find.byKey(HomeDashboardScreen.smartAddFabPaddingKey),
      );
      expect(fabPadding.padding, const EdgeInsets.only(bottom: 72));
      expect(
        find.descendant(
          of: find.byType(FloatingActionButton),
          matching: find.byIcon(Icons.auto_awesome),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens smart add sheet from the add FAB', (tester) async {
      await tester.pumpWidget(_wrapHomeDashboard());

      await tester.tap(find.byKey(HomeDashboardScreen.smartAddButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(SmartAddSheet.sheetKey), findsOneWidget);
      expect(find.byKey(SmartAddSheet.aiTextChoiceKey), findsOneWidget);
      expect(find.byKey(SmartAddSheet.quickAddChoiceKey), findsOneWidget);
      expect(find.byKey(SmartAddSheet.receiptChoiceKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not show a second add action in the top bar', (tester) async {
      await tester.pumpWidget(_wrapHomeDashboard());

      expect(find.byKey(HomeDashboardScreen.topBarAiAssistantKey), findsNothing);
      expect(find.byKey(SmartAddSheet.sheetKey), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows six recent transactions for future ad spacing', (tester) async {
      await tester.pumpWidget(
        _wrapHomeDashboard(
          preloadedExpenses: List.generate(
            7,
            (index) => _expense(
              id: 'expense-$index',
              description: 'Expense ${index + 1}',
            ),
          ),
        ),
      );

      for (var i = 1; i <= 6; i++) {
        expect(find.text('Expense $i'), findsOneWidget);
      }
      expect(find.text('Expense 7'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens the sidebar menu from the top bar', (tester) async {
      await tester.pumpWidget(_wrapHomeDashboard());

      await tester.tap(find.byKey(HomeDashboardScreen.menuButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(HomeDashboardScreen.drawerKey), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Settings'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('profile button opens the account profile route', (tester) async {
      await tester.pumpWidget(_wrapHomeDashboardRouter());

      await tester.tap(find.byKey(HomeDashboardScreen.profileButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Profile route'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _wrapHomeDashboard({List<Expense> preloadedExpenses = const []}) {
  final store = LocalRepositoryStore(userId: 'test-user');
  final expenseRepository = LocalExpenseRepository(store: store);
  final budgetRepository = LocalBudgetRepository(store: store);
  final settingsRepository = LocalSettingsRepository(store: store);

  return MultiBlocProvider(
    providers: [
      BlocProvider<GetExpensesBloc>(
        create: (_) => preloadedExpenses.isEmpty
            ? GetExpensesBloc(expenseRepository)
            : _LoadedGetExpensesBloc(expenseRepository, preloadedExpenses),
      ),
      BlocProvider<ReportCubit>(
        create: (_) => ReportCubit(expenseRepository),
      ),
      BlocProvider<BudgetBloc>(
        create: (_) => BudgetBloc(budgetRepository),
      ),
      BlocProvider<SettingsCubit>(
        create: (_) => SettingsCubit(settingsRepository),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const HomeDashboardScreen(),
    ),
  );
}

Expense _expense({
  required String id,
  required String description,
}) {
  final now = DateTime(2026, 6);
  return Expense(
    expenseId: id,
    userId: 'test-user',
    category: Category.empty.copyWith(
      categoryId: 'food',
      name: 'Food',
      icon: 'restaurant',
      color: 0xff006875,
    ),
    categoryId: 'food',
    categoryName: 'Food',
    categoryIcon: 'restaurant',
    categoryColor: 0xff006875,
    amount: 100,
    date: now,
    description: description,
    currency: 'EGP',
    createdAt: now,
    updatedAt: now,
  );
}

class _LoadedGetExpensesBloc extends GetExpensesBloc {
  _LoadedGetExpensesBloc(super.expenseRepository, List<Expense> expenses) {
    emit(GetExpensesSuccess(expenses));
  }
}

Widget _wrapHomeDashboardRouter() {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => _wrapHomeDashboardBody(),
      ),
      GoRoute(
        path: AppRoutes.accountProfile,
        builder: (_, _) => const Scaffold(body: Center(child: Text('Profile route'))),
      ),
    ],
  );

  return MaterialApp.router(
    theme: AppTheme.light,
    routerConfig: router,
  );
}

Widget _wrapHomeDashboardBody() {
  final store = LocalRepositoryStore(userId: 'test-user');
  final expenseRepository = LocalExpenseRepository(store: store);
  final budgetRepository = LocalBudgetRepository(store: store);
  final settingsRepository = LocalSettingsRepository(store: store);

  return MultiBlocProvider(
    providers: [
      BlocProvider<GetExpensesBloc>(
        create: (_) => GetExpensesBloc(expenseRepository),
      ),
      BlocProvider<ReportCubit>(
        create: (_) => ReportCubit(expenseRepository),
      ),
      BlocProvider<BudgetBloc>(
        create: (_) => BudgetBloc(budgetRepository),
      ),
      BlocProvider<SettingsCubit>(
        create: (_) => SettingsCubit(settingsRepository),
      ),
    ],
    child: const HomeDashboardScreen(),
  );
}
