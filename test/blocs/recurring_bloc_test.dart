import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/recurring_expenses/recurring_expense_bloc/recurring_expense_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'dart:async';

void main() {
  late _MockRecurringRepo repo;

  setUp(() => repo = _MockRecurringRepo());

  group('RecurringExpenseBloc', () {
    test('initial state is empty', () {
      final bloc = RecurringExpenseBloc(repo, 'u1');
      expect((bloc.state as RecurringExpenseLoaded).items, isEmpty);
    });

    test('load populates items', () async {
      repo._items = [
        RecurringExpense(
          recurringExpenseId: 'r1', userId: 'u1', name: 'Rent', amount: 1000,
          currency: 'USD', categoryId: 'c1', frequency: 'monthly',
          startDate: DateTime.now(), createdAt: DateTime.now(), updatedAt: DateTime.now(),
        ),
      ];
      final bloc = RecurringExpenseBloc(repo, 'u1');
      bloc.add(RecurringExpensesWatched());
      await Future.delayed(const Duration(milliseconds: 50));
      expect((bloc.state as RecurringExpenseLoaded).items.length, 1);
      bloc.close();
    });
  });
}

class _MockRecurringRepo implements RecurringExpenseRepository {
  List<RecurringExpense> _items = [];
  final _controller = StreamController<List<RecurringExpense>>.broadcast();

  @override Future<void> create(RecurringExpense e) async { _items.add(e); _controller.add(_items); }
  @override Future<void> update(RecurringExpense e) async {}
  @override Future<void> delete(String id) async {}
  @override Future<List<RecurringExpense>> getAll() async => _items;
  @override Stream<List<RecurringExpense>> watchAll() => _controller.stream;
}
