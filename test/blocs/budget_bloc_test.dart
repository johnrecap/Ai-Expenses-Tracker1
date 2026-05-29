import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/screens/budget/blocs/budget_bloc/budget_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'dart:async';

void main() {
  late _MockBudgetRepo repo;

  setUp(() => repo = _MockBudgetRepo());

  group('BudgetBloc', () {
    test('initial state is BudgetInitial', () {
      final bloc = BudgetBloc(repo);
      expect(bloc.state, isA<BudgetInitial>());
      bloc.close();
    });

    test('load starts watching', () async {
      final bloc = BudgetBloc(repo);
      bloc.add(BudgetLoad(5, 2026));
      await Future.delayed(const Duration(milliseconds: 100));
      bloc.close();
    });

    test('save emits saving then saved', () async {
      final bloc = BudgetBloc(repo);
      bloc.add(BudgetSave(Budget(
        budgetId: 'b1', userId: 'u1', month: 5, year: 2026, amount: 500,
        currency: 'USD', warningThresholdPercent: 80,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      )));
      await expectLater(bloc.stream, emitsInOrder([isA<BudgetSaving>(), isA<BudgetSaved>()]));
      bloc.close();
    });
  });
}

class _MockBudgetRepo implements BudgetRepository {
  final _controller = StreamController<Budget?>.broadcast();

  @override Future<void> saveBudget(Budget b) async {}
  @override Future<Budget?> getCurrentMonthBudget({required int month, required int year}) async => null;
  @override Stream<Budget?> watchCurrentMonthBudget({required int month, required int year}) => _controller.stream;
}
