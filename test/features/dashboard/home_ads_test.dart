import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/widgets/app_ad_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Home ad placement', () {
    testWidgets('shows a safe banner for free users when ads are available', (tester) async {
      final monetizationCubit = await _loadedMonetizationCubit();

      await tester.pumpWidget(_wrapHomeDashboard(monetizationCubit));

      expect(find.byKey(AppAdSlot.homeBannerKey), findsOneWidget);
      expect(find.byKey(HomeDashboardScreen.menuButtonKey), findsOneWidget);
      expect(find.byKey(HomeDashboardScreen.profileButtonKey), findsOneWidget);
      expect(find.byKey(HomeDashboardScreen.smartAddButtonKey), findsOneWidget);

      final adRect = tester.getRect(find.byKey(AppAdSlot.homeBannerKey));
      final fabRect = tester.getRect(find.byKey(HomeDashboardScreen.smartAddButtonKey));
      final menuRect = tester.getRect(find.byKey(HomeDashboardScreen.menuButtonKey));
      final profileRect = tester.getRect(find.byKey(HomeDashboardScreen.profileButtonKey));

      expect(adRect.overlaps(fabRect), isFalse);
      expect(adRect.overlaps(menuRect), isFalse);
      expect(adRect.overlaps(profileRect), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides the home banner for premium users', (tester) async {
      final monetizationCubit = await _loadedMonetizationCubit(isPremium: true);

      await tester.pumpWidget(_wrapHomeDashboard(monetizationCubit));

      expect(find.byKey(AppAdSlot.homeBannerKey), findsNothing);
      expect(find.byKey(HomeDashboardScreen.smartAddButtonKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('collapses the home banner when the provider is unavailable', (tester) async {
      final monetizationCubit = await _loadedMonetizationCubit(adsAvailable: false);

      await tester.pumpWidget(_wrapHomeDashboard(monetizationCubit));

      expect(find.byKey(AppAdSlot.homeBannerKey), findsNothing);
      expect(find.byKey(HomeDashboardScreen.smartAddButtonKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _wrapHomeDashboard(MonetizationCubit monetizationCubit) {
  final store = LocalRepositoryStore(userId: 'test-user');
  final expenseRepository = LocalExpenseRepository(store: store);
  final budgetRepository = LocalBudgetRepository(store: store);
  final settingsRepository = LocalSettingsRepository(store: store);

  return MultiBlocProvider(
    providers: [
      BlocProvider<MonetizationCubit>.value(value: monetizationCubit),
      BlocProvider<GetExpensesBloc>(
        create: (_) => _LoadedGetExpensesBloc(
          expenseRepository,
          [
            _expense(id: 'expense-1', description: 'Lunch'),
            _expense(id: 'expense-2', description: 'Coffee'),
          ],
        ),
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

Future<MonetizationCubit> _loadedMonetizationCubit({
  bool isPremium = false,
  bool adsAvailable = true,
}) async =>
    _TestMonetizationCubit(
      isPremium: isPremium,
      adsAvailable: adsAvailable,
    );

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

class _TestMonetizationCubit extends MonetizationCubit {
  _TestMonetizationCubit({
    required bool isPremium,
    required bool adsAvailable,
  }) {
    emit(
      MonetizationState(
        initialized: true,
        isPremium: isPremium,
        adsAvailable: adsAvailable,
      ),
    );
  }
}
