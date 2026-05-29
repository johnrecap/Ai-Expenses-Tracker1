import 'package:bloc/bloc.dart';
import 'package:expense_repository/expense_repository.dart';

class SavingGoalBloc extends Bloc<SavingGoalEvent, SavingGoalState> {
  final SavingGoalRepository _repo;

  SavingGoalBloc(this._repo) : super(SavingGoalInitial()) {
    on<SavingGoalsWatch>(_onWatch);
    on<SavingGoalCreate>(_onCreate);
    on<SavingGoalUpdate>(_onUpdate);
    on<SavingGoalDelete>(_onDelete);
  }

  Future<void> _onWatch(SavingGoalsWatch event, Emitter<SavingGoalState> emit) async {
    emit(SavingGoalLoading());
    try {
      await for (final goals in _repo.watchSavingGoals()) {
        emit(SavingGoalSuccess(goals));
      }
    } catch (_) {
      emit(const SavingGoalFailure('Failed to load goals.'));
    }
  }

  Future<void> _onCreate(SavingGoalCreate event, Emitter<SavingGoalState> emit) async {
    if (event.goal.name.trim().isEmpty) { emit(const SavingGoalFailure('Enter a goal name.')); return; }
    if (event.goal.targetAmount <= 0) { emit(const SavingGoalFailure('Enter a positive target.')); return; }
    emit(SavingGoalSaving());
    try {
      await _repo.createSavingGoal(event.goal);
      emit(const SavingGoalActionSuccess('Goal created.'));
    } catch (_) { emit(const SavingGoalFailure('Failed to create goal.')); }
  }

  Future<void> _onUpdate(SavingGoalUpdate event, Emitter<SavingGoalState> emit) async {
    emit(SavingGoalSaving());
    try {
      await _repo.updateSavingGoal(event.goal);
      emit(const SavingGoalActionSuccess('Goal updated.'));
    } catch (_) { emit(const SavingGoalFailure('Failed to update goal.')); }
  }

  Future<void> _onDelete(SavingGoalDelete event, Emitter<SavingGoalState> emit) async {
    emit(SavingGoalSaving());
    try {
      await _repo.deleteSavingGoal(event.goalId);
      emit(const SavingGoalActionSuccess('Goal deleted.'));
    } catch (_) { emit(const SavingGoalFailure('Failed to delete goal.')); }
  }
}

class SavingGoalEvent {}
class SavingGoalsWatch extends SavingGoalEvent {}
class SavingGoalCreate extends SavingGoalEvent { final SavingGoal goal; SavingGoalCreate(this.goal); }
class SavingGoalUpdate extends SavingGoalEvent { final SavingGoal goal; SavingGoalUpdate(this.goal); }
class SavingGoalDelete extends SavingGoalEvent { final String goalId; SavingGoalDelete(this.goalId); }

class SavingGoalState { const SavingGoalState(); }
class SavingGoalInitial extends SavingGoalState { const SavingGoalInitial(); }
class SavingGoalLoading extends SavingGoalState { const SavingGoalLoading(); }
class SavingGoalSaving extends SavingGoalState { const SavingGoalSaving(); }
class SavingGoalSuccess extends SavingGoalState { final List<SavingGoal> goals; const SavingGoalSuccess(this.goals); }
class SavingGoalActionSuccess extends SavingGoalState { final String message; const SavingGoalActionSuccess(this.message); }
class SavingGoalFailure extends SavingGoalState { final String message; const SavingGoalFailure(this.message); }
