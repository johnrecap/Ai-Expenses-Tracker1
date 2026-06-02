import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/edit_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('editing preserves hidden expense metadata', (tester) async {
    final original = _expense();
    final repository = _RecordingExpenseRepository(original);

    final router = GoRouter(
      initialLocation: '/edit',
      routes: [
        GoRoute(
          path: '/edit',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider<GetExpensesBloc>(
                create: (_) => _LoadedGetExpensesBloc(repository, original),
              ),
              BlocProvider<CreateExpenseBloc>(
                create: (_) => CreateExpenseBloc(repository),
              ),
            ],
            child: const EditExpenseScreen(expenseId: 'expense-1'),
          ),
        ),
        GoRoute(
          path: '/expenses',
          builder: (_, _) => const Scaffold(body: Text('expenses-target')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    await tester.enterText(find.byType(TextField).at(0), 'Updated coffee');
    await tester.enterText(find.byType(TextField).at(1), '75.25');

    final updateButton = find.text('Update Expense');
    await tester.ensureVisible(updateButton);
    await tester.tap(updateButton);
    await tester.pumpAndSettle();

    expect(repository.updated, isNotNull);
    final updated = repository.updated!;
    expect(updated.expenseId, original.expenseId);
    expect(updated.userId, original.userId);
    expect(updated.categoryId, original.categoryId);
    expect(updated.currency, 'AED');
    expect(updated.walletAccountId, 'wallet-1');
    expect(updated.walletAccountName, 'Main wallet');
    expect(updated.paymentMethod, PaymentMethod.wallet);
    expect(updated.source, ExpenseSource.aiText);
    expect(updated.createdAt, original.createdAt);
    expect(updated.amount, 75.25);
    expect(updated.description, 'Updated coffee');
  });
}

class _LoadedGetExpensesBloc extends GetExpensesBloc {
  _LoadedGetExpensesBloc(super.expenseRepository, Expense expense) {
    emit(GetExpensesSuccess([expense]));
  }
}

class _RecordingExpenseRepository implements ExpenseRepository {
  _RecordingExpenseRepository(this.original);

  final Expense original;
  Expense? updated;

  @override
  Future<void> createExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String expenseId) async {}

  @override
  Future<Expense?> getExpenseById(String expenseId) async => original;

  @override
  Future<List<Expense>> getExpenses() async => [original];

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async => [original];

  @override
  Future<void> updateExpense(Expense expense) async {
    updated = expense;
  }

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value([original]);
}

Expense _expense() {
  return Expense(
    expenseId: 'expense-1',
    userId: 'user-1',
    category: Category(
      categoryId: 'coffee',
      userId: 'user-1',
      name: 'Coffee',
      totalExpenses: 0,
      icon: 'local_cafe',
      color: 0xff000000,
    ),
    date: DateTime.utc(2026, 5, 31),
    amount: 50,
    description: 'Original coffee',
    paymentMethod: PaymentMethod.wallet,
    currency: 'AED',
    createdAt: DateTime.utc(2026, 5, 1),
    updatedAt: DateTime.utc(2026, 5, 1),
    source: ExpenseSource.aiText,
    walletAccountId: 'wallet-1',
    walletAccountName: 'Main wallet',
  );
}
