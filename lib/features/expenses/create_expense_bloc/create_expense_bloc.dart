import 'package:bloc/bloc.dart';
import 'package:expense_repository/expense_repository.dart';

class CreateExpenseBloc extends Bloc<CreateExpenseEvent, CreateExpenseState> {
  final ExpenseRepository expenseRepository;

  CreateExpenseBloc(this.expenseRepository) : super(const CreateExpenseInitial()) {
    on<CreateExpense>(_onCreate);
    on<UpdateExpense>(_onUpdate);
    on<DeleteExpense>(_onDelete);
  }

  Future<void> _onCreate(CreateExpense event, Emitter<CreateExpenseState> emit) async {
    emit(const CreateExpenseLoading());
    try {
      await expenseRepository.createExpense(event.expense);
      emit(const CreateExpenseSuccess());
    } catch (e) {
      emit(const CreateExpenseFailure('Failed to save expense.'));    }
  }

  Future<void> _onUpdate(UpdateExpense event, Emitter<CreateExpenseState> emit) async {
    emit(const CreateExpenseLoading());
    try {
      await expenseRepository.updateExpense(event.expense);
      emit(const CreateExpenseSuccess());
    } catch (e) {
      emit(const CreateExpenseFailure('Failed to update expense.'));
    }
  }

  Future<void> _onDelete(DeleteExpense event, Emitter<CreateExpenseState> emit) async {
    emit(const CreateExpenseLoading());
    try {
      await expenseRepository.deleteExpense(event.expenseId);
      emit(const CreateExpenseSuccess());
    } catch (e) {
      emit(const CreateExpenseFailure('Failed to delete expense.'));
    }
  }
}

class CreateExpenseEvent {}
class CreateExpense extends CreateExpenseEvent {
  final Expense expense;
  CreateExpense(this.expense);
}
class UpdateExpense extends CreateExpenseEvent {
  final Expense expense;
  UpdateExpense(this.expense);
}
class DeleteExpense extends CreateExpenseEvent {
  final String expenseId;
  DeleteExpense(this.expenseId);
}

class CreateExpenseState { const CreateExpenseState(); }
class CreateExpenseInitial extends CreateExpenseState { const CreateExpenseInitial(); }
class CreateExpenseLoading extends CreateExpenseState { const CreateExpenseLoading(); }
class CreateExpenseSuccess extends CreateExpenseState { const CreateExpenseSuccess(); }
class CreateExpenseFailure extends CreateExpenseState {
  final String message;
  const CreateExpenseFailure(this.message);
}
