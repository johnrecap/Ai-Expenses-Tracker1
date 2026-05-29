import 'package:bloc/bloc.dart';
import 'package:expense_repository/expense_repository.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _repo;

  BudgetBloc(this._repo) : super(BudgetInitial()) {
    on<BudgetLoad>(_onLoad);
    on<BudgetUpdated>(_onBudget);
    on<BudgetSave>(_onSave);
  }

  Future<void> _onLoad(BudgetLoad event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      await for (final budget in _repo.watchCurrentMonthBudget(month: event.month, year: event.year)) {
        if (budget != null) add(BudgetUpdated(budget));
      }
    } catch (_) {
      emit(const BudgetError('Failed to load budget.'));
    }
  }

  void _onBudget(BudgetUpdated event, Emitter<BudgetState> emit) {
    emit(BudgetLoaded(event.budget));
  }

  Future<void> _onSave(BudgetSave event, Emitter<BudgetState> emit) async {
    if (event.budget.amount <= 0) { emit(const BudgetError('Enter a valid amount.')); return; }
    emit(BudgetSaving(event.budget));
    try {
      await _repo.saveBudget(event.budget);
      emit(BudgetSaved(event.budget));
    } catch (_) {
      emit(const BudgetError('Failed to save budget.'));
    }
  }
}

class BudgetEvent {}
class BudgetLoad extends BudgetEvent { final int month; final int year; BudgetLoad(this.month, this.year); }
class BudgetSave extends BudgetEvent { final Budget budget; BudgetSave(this.budget); }
class BudgetUpdated extends BudgetEvent { final Budget? budget; BudgetUpdated(this.budget); }

class BudgetState { const BudgetState(); }
class BudgetInitial extends BudgetState { const BudgetInitial(); }
class BudgetLoading extends BudgetState { const BudgetLoading(); }
class BudgetLoaded extends BudgetState { final Budget? budget; const BudgetLoaded(this.budget); }
class BudgetSaving extends BudgetState { final Budget budget; const BudgetSaving(this.budget); }
class BudgetSaved extends BudgetState { final Budget budget; const BudgetSaved(this.budget); }
class BudgetError extends BudgetState { final String message; const BudgetError(this.message); }
