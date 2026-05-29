import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expense_repository/expense_repository.dart';

void main() {
  late _MockExpenseRepo repo;

  setUp(() => repo = _MockExpenseRepo());

  group('CreateExpenseBloc', () {
    test('initial state is CreateExpenseInitial', () {
      final bloc = CreateExpenseBloc(repo);
      expect(bloc.state, isA<CreateExpenseInitial>());
      bloc.close();
    });

    test('create emits loading then success', () async {
      final bloc = CreateExpenseBloc(repo);
      bloc.add(CreateExpense(Expense(expenseId: '1', category: Category.empty, date: DateTime.now(), amount: 50)));
      await expectLater(bloc.stream, emitsInOrder([isA<CreateExpenseLoading>(), isA<CreateExpenseSuccess>()]));
      bloc.close();
    });

    test('delete emits loading then success', () async {
      final bloc = CreateExpenseBloc(repo);
      bloc.add(DeleteExpense('1'));
      await expectLater(bloc.stream, emitsInOrder([isA<CreateExpenseLoading>(), isA<CreateExpenseSuccess>()]));
      bloc.close();
    });
  });
}

class _MockExpenseRepo extends MockExpenseRepo {}

class MockExpenseRepo implements ExpenseRepository {
  @override Future<void> createExpense(Expense e) async {}
  @override Future<void> updateExpense(Expense e) async {}
  @override Future<void> deleteExpense(String id) async {}
  @override Future<Expense?> getExpenseById(String id) async => null;
  @override Future<List<Expense>> getExpenses() async => [];
  @override Stream<List<Expense>> watchExpenses() => Stream.value([]);
  @override Future<List<Expense>> getExpensesByFilter(ExpenseFilter f) async => [];
}
