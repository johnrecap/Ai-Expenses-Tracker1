import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:expense_repository/expense_repository.dart';

part 'recurring_expense_event.dart';
part 'recurring_expense_state.dart';

class RecurringExpenseBloc extends Bloc<RecurringExpenseEvent, RecurringExpenseState> {
  final RecurringExpenseRepository _repo;
  final String _userId;
  StreamSubscription<List<RecurringExpense>>? _sub;

  RecurringExpenseBloc(this._repo, this._userId) : super(RecurringExpenseInitial()) {
    on<RecurringExpensesWatched>(_onWatch);
    on<RecurringExpensesUpdated>(_onUpdated);
    on<CreateRecurringExpense>(_onCreate);
    on<UpdateRecurringExpense>(_onUpdate);
    on<DeleteRecurringExpense>(_onDelete);
    on<ToggleRecurringExpenseActive>(_onToggleActive);
  }

  Future<void> _onWatch(RecurringExpensesWatched event, Emitter<RecurringExpenseState> emit) async {
    emit(RecurringExpenseLoading());
    await _sub?.cancel();
    try {
      _sub = _repo.watchAll().listen(
        (items) => add(RecurringExpensesUpdated(items)),
        onError: (_) => emit(const RecurringExpenseError('Failed to watch recurring expenses.')),
      );
    } catch (_) {
      emit(const RecurringExpenseError('Failed to load recurring expenses.'));
    }
  }

  void _onUpdated(RecurringExpensesUpdated event, Emitter<RecurringExpenseState> emit) {
    emit(RecurringExpenseLoaded(event.items));
  }

  Future<void> _onCreate(CreateRecurringExpense event, Emitter<RecurringExpenseState> emit) async {
    try {
      await _repo.create(event.expense);
    } catch (e) {
      debugPrint('RecurringExpenseBloc: create failed: $e');
      emit(RecurringExpenseError('Failed to create recurring expense: $e'));
    }
  }

  Future<void> _onUpdate(UpdateRecurringExpense event, Emitter<RecurringExpenseState> emit) async {
    try {
      await _repo.update(event.expense);
    } catch (e) {
      debugPrint('RecurringExpenseBloc: update failed: $e');
      emit(RecurringExpenseError('Failed to update recurring expense: $e'));
    }
  }

  Future<void> _onDelete(DeleteRecurringExpense event, Emitter<RecurringExpenseState> emit) async {
    try {
      await _repo.delete(event.recurringExpenseId);
    } catch (e) {
      debugPrint('RecurringExpenseBloc: delete failed: $e');
      emit(RecurringExpenseError('Failed to delete recurring expense: $e'));
    }
  }

  /// Toggle active by setting/clearing endDate.
  /// Active = endDate is null or in the future.
  Future<void> _onToggleActive(ToggleRecurringExpenseActive event, Emitter<RecurringExpenseState> emit) async {
    final item = event.expense;
    final bool currentlyActive = item.endDate == null || item.endDate!.isAfter(DateTime.now());
    final updated = item.copyWith(
      endDate: currentlyActive ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    try {
      await _repo.update(updated);
    } catch (e) {
      debugPrint('RecurringExpenseBloc: toggle active failed: $e');
      emit(RecurringExpenseError('Failed to toggle recurring expense: $e'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
