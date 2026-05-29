import 'models/saving_goal.dart';

abstract class SavingGoalRepository {
  Future<void> createSavingGoal(SavingGoal goal);
  Future<void> updateSavingGoal(SavingGoal goal);
  Future<void> deleteSavingGoal(String goalId);
  Future<List<SavingGoal>> getSavingGoals();
  Stream<List<SavingGoal>> watchSavingGoals();
}
