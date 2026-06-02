import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/recurring_expenses/recurring_expense_bloc/recurring_expense_bloc.dart';
import 'package:expenses_tracker/features/subscriptions/presentation/subscriptions_center_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionsCenterScreen', () {
    testWidgets('shows only recurring items categorized as subscriptions', (tester) async {
      await _pumpSubscriptions(tester, [
        _recurring(id: 'rent', name: 'Rent', categoryId: 'housing'),
        _recurring(id: 'netflix', name: 'Netflix', categoryId: 'subscriptions'),
      ]);

      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Rent'), findsNothing);
    });

    testWidgets('keeps non-subscription recurring expenses separate', (tester) async {
      await _pumpSubscriptions(tester, [
        _recurring(id: 'rent', name: 'Rent', categoryId: 'housing'),
      ]);

      expect(find.text('No active subscriptions'), findsOneWidget);
      expect(
        find.text('Recurring expenses in other categories are kept separate.'),
        findsOneWidget,
      );
      expect(find.text('Rent'), findsNothing);
    });
  });
}

Future<void> _pumpSubscriptions(
  WidgetTester tester,
  List<RecurringExpense> items,
) async {
  await tester.pumpWidget(
    BlocProvider<RecurringExpenseBloc>(
      create: (_) => _LoadedRecurringExpenseBloc(items),
      child: MaterialApp(
        theme: AppTheme.light,
        home: const SubscriptionsCenterScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

RecurringExpense _recurring({
  required String id,
  required String name,
  required String categoryId,
}) {
  return RecurringExpense(
    recurringExpenseId: id,
    userId: 'user-1',
    name: name,
    amount: 100,
    currency: 'EGP',
    categoryId: categoryId,
    frequency: 'monthly',
    startDate: DateTime.utc(2026),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

class _LoadedRecurringExpenseBloc extends RecurringExpenseBloc {
  _LoadedRecurringExpenseBloc(List<RecurringExpense> items)
    : super(_FakeRecurringExpenseRepository(), 'user-1') {
    emit(RecurringExpenseLoaded(items));
  }
}

class _FakeRecurringExpenseRepository implements RecurringExpenseRepository {
  @override
  Future<void> create(RecurringExpense expense) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<RecurringExpense>> getAll() async => const [];

  @override
  Future<void> update(RecurringExpense expense) async {}

  @override
  Stream<List<RecurringExpense>> watchAll() => const Stream.empty();
}
