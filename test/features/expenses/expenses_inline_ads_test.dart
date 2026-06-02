import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/expenses/expense_filter_cubit/expense_filter_cubit.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/expenses_list_screen.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/widgets/app_ad_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expenses inline ads', () {
    testWidgets('shows one inline ad after at least six expense rows', (tester) async {
      final monetizationCubit = await _loadedMonetizationCubit();

      await tester.pumpWidget(
        _wrapList(
          monetizationCubit: monetizationCubit,
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
      await tester.scrollUntilVisible(
        find.byKey(AppAdSlot.expensesInlineKey),
        300,
        scrollable: find.byType(Scrollable).last,
      );

      expect(find.byKey(AppAdSlot.expensesInlineKey), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Expense 7'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Expense 7'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides inline ads for short expense lists', (tester) async {
      final monetizationCubit = await _loadedMonetizationCubit();

      await tester.pumpWidget(
        _wrapList(
          monetizationCubit: monetizationCubit,
          preloadedExpenses: List.generate(
            5,
            (index) => _expense(
              id: 'expense-$index',
              description: 'Short ${index + 1}',
            ),
          ),
        ),
      );

      expect(find.byKey(AppAdSlot.expensesInlineKey), findsNothing);
      for (var i = 1; i <= 5; i++) {
        expect(find.text('Short $i'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides inline ads for premium users', (tester) async {
      final monetizationCubit = await _loadedMonetizationCubit(isPremium: true);

      await tester.pumpWidget(
        _wrapList(
          monetizationCubit: monetizationCubit,
          preloadedExpenses: List.generate(
            7,
            (index) => _expense(
              id: 'expense-$index',
              description: 'Premium ${index + 1}',
            ),
          ),
        ),
      );

      expect(find.byKey(AppAdSlot.expensesInlineKey), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Premium 7'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Premium 7'), findsOneWidget);
      expect(find.byKey(AppAdSlot.expensesInlineKey), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('collapses inline ads when the provider is unavailable', (tester) async {
      final monetizationCubit = await _loadedMonetizationCubit(adsAvailable: false);

      await tester.pumpWidget(
        _wrapList(
          monetizationCubit: monetizationCubit,
          preloadedExpenses: List.generate(
            7,
            (index) => _expense(
              id: 'expense-$index',
              description: 'Unavailable ${index + 1}',
            ),
          ),
        ),
      );

      expect(find.byKey(AppAdSlot.expensesInlineKey), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Unavailable 7'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Unavailable 7'), findsOneWidget);
      expect(find.byKey(AppAdSlot.expensesInlineKey), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _wrapList({
  required MonetizationCubit monetizationCubit,
  List<Expense> preloadedExpenses = const [],
}) {
  final expenseRepository = _StaticExpenseRepository(preloadedExpenses);

  return MaterialApp(
    theme: AppTheme.light,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<MonetizationCubit>.value(value: monetizationCubit),
        BlocProvider<GetExpensesBloc>(
          create: (_) => _LoadedGetExpensesBloc(expenseRepository, preloadedExpenses),
        ),
        BlocProvider(create: (_) => ExpenseFilterCubit()),
      ],
      child: const ExpensesListScreen(),
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
    userId: 'user-1',
    category: Category.empty.copyWith(
      categoryId: 'food',
      name: 'Food',
      icon: 'receipt_long',
      color: 0xff006875,
    ),
    categoryId: 'food',
    categoryName: 'Food',
    categoryIcon: 'receipt_long',
    categoryColor: 0xff006875,
    amount: 730,
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

class _StaticExpenseRepository implements ExpenseRepository {
  const _StaticExpenseRepository(this.expenses);

  final List<Expense> expenses;

  @override
  Future<void> createExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String expenseId) async {}

  @override
  Future<Expense?> getExpenseById(String expenseId) async => null;

  @override
  Future<List<Expense>> getExpenses() async => expenses;

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async => expenses;

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(expenses);
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
