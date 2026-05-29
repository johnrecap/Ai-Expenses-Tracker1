import 'package:bloc/bloc.dart';
import 'package:expense_repository/expense_repository.dart';

class GetExpensesBloc extends Bloc<GetExpensesEvent, GetExpensesState> {
  final ExpenseRepository expenseRepository;

  GetExpensesBloc(this.expenseRepository) : super(GetExpensesInitial()) {
    on<GetExpenses>(_onLoad);
    on<RefreshExpenses>(_onRefresh);
  }

  Future<void> _onLoad(GetExpenses event, Emitter<GetExpensesState> emit) async {
    emit(GetExpensesLoading());
    try {
      await for (final expenses in expenseRepository.watchExpenses()) {
        emit(GetExpensesSuccess(List.unmodifiable(expenses)));
      }
    } catch (_) {
      try {
        final expenses = await expenseRepository.getExpenses();
        emit(GetExpensesSuccess(List.unmodifiable(expenses)));
      } catch (_) {
        emit(const GetExpensesFailure('Failed to load expenses. Check your connection.'));
      }
    }
  }

  Future<void> _onRefresh(RefreshExpenses event, Emitter<GetExpensesState> emit) async {
    try {
      final expenses = await expenseRepository.getExpenses();
      emit(GetExpensesSuccess(List.unmodifiable(expenses)));
    } catch (_) {
      emit(const GetExpensesFailure('Failed to refresh expenses.'));
    }
  }
}

class GetExpenses extends GetExpensesEvent {}
class RefreshExpenses extends GetExpensesEvent {}

class GetExpensesEvent {
  const GetExpensesEvent();
}

class GetExpensesState {
  const GetExpensesState();
}

class GetExpensesInitial extends GetExpensesState {}

class GetExpensesLoading extends GetExpensesState {}

class GetExpensesSuccess extends GetExpensesState {
  final List<Expense> expenses;
  const GetExpensesSuccess(this.expenses);
}

class GetExpensesFailure extends GetExpensesState {
  final String message;
  const GetExpensesFailure(this.message);
}
