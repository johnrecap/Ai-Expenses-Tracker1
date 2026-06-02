import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeDashboardScreen honesty', () {
    testWidgets('does not show unsupported static financial claims', (tester) async {
      await tester.pumpWidget(_wrapHomeDashboard());
      await tester.pump();

      expect(find.text('Spending is down 12%'), findsNothing);
      expect(find.text('2 due this week'), findsNothing);
      expect(find.text('Not enough data yet'), findsOneWidget);
      expect(find.text('No bill reminders yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _wrapHomeDashboard() {
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
    child: MaterialApp(
      theme: AppTheme.light,
      home: const HomeDashboardScreen(),
    ),
  );
}
