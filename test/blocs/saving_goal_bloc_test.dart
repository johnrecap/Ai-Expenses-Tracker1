import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/features/goals/saving_goal_bloc/saving_goal_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'dart:async';

void main() {
  test('SavingGoalBloc initial state is SavingGoalInitial', () {
    final bloc = SavingGoalBloc(_MockGoalRepo());
    expect(bloc.state, isA<SavingGoalInitial>());
    bloc.close();
  });

  test('SavingGoalBloc create validates empty name', () async {
    final bloc = SavingGoalBloc(_MockGoalRepo());
    bloc.add(
      SavingGoalCreate(
        SavingGoal(
          goalId: 'g1',
          userId: 'u1',
          name: '',
          targetAmount: 0,
          currency: 'USD',
          color: 0xFF0000,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(bloc.state, isA<SavingGoalFailure>());
    expect((bloc.state as SavingGoalFailure).message, contains('name'));
    bloc.close();
  });
}

class _MockGoalRepo implements SavingGoalRepository {
  @override
  Future<void> createSavingGoal(SavingGoal g) async {}
  @override
  Future<void> updateSavingGoal(SavingGoal g) async {}
  @override
  Future<void> deleteSavingGoal(String id) async {}
  @override
  Future<List<SavingGoal>> getSavingGoals() async => [];
  @override
  Stream<List<SavingGoal>> watchSavingGoals() => Stream.value([]);
}
