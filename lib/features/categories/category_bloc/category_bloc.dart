import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:expense_repository/expense_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repo;
  final String _userId;
  bool _seeded = false;

  CategoryBloc(this._repo, this._userId) : super(CategoryInitial()) {
    on<CategoriesWatched>(_onWatch);
    on<CreateCategory>(_onCreate);
    on<UpdateCategory>(_onUpdate);
    on<ArchiveCategory>(_onArchive);
  }

  Future<void> _onWatch(CategoriesWatched event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      await for (final categories in _repo.watchCategories()) {
        if (categories.isEmpty && !_seeded) {
          _seeded = true;
          await _seedDefaults();
        } else {
          emit(CategoryLoaded(categories));
        }
      }
    } catch (_) {
      emit(const CategoryError('Failed to load categories.'));
    }
  }

  Future<void> _onCreate(CreateCategory event, Emitter<CategoryState> emit) async {
    try {
      await _repo.createCategory(event.category);
      final updated = await _repo.getCategories();
      emit(CategoryCreated(event.category));
      emit(CategoryLoaded(updated));
    } catch (e) {
      debugPrint('CategoryBloc: create failed: $e');
      emit(CategoryError('Failed to create category: $e'));
    }
  }

  Future<void> _onUpdate(UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      await _repo.updateCategory(event.category);
      final updated = await _repo.getCategories();
      emit(CategoryUpdated(event.category));
      emit(CategoryLoaded(updated));
    } catch (e) {
      debugPrint('CategoryBloc: update failed: $e');
      emit(CategoryError('Failed to update category: $e'));
    }
  }

  Future<void> _onArchive(ArchiveCategory event, Emitter<CategoryState> emit) async {
    try {
      final currentState = state;
      if (currentState is CategoryLoaded) {
        final target = currentState.categories.firstWhere(
          (c) => c.categoryId == event.categoryId,
        );
        await _repo.archiveCategory(target);
        final updated = await _repo.getCategories();
        emit(CategoryArchived(event.categoryId));
        emit(CategoryLoaded(updated));
      }
    } catch (e) {
      debugPrint('CategoryBloc: archive failed: $e');
      emit(CategoryError('Failed to archive category: $e'));
    }
  }

  Future<void> _seedDefaults() async {
    final defaults = [
      _cat('food', 'Food', 'restaurant', 0xFFFF7043),
      _cat('transport', 'Transport', 'local_taxi', 0xFF42A5F5),
      _cat('shopping', 'Shopping', 'shopping_bag', 0xFFAB47BC),
      _cat('housing', 'Housing', 'home', 0xFF66BB6A),
      _cat('entertainment', 'Entertainment', 'movie', 0xFFFFCA28),
      _cat('healthcare', 'Healthcare', 'local_hospital', 0xFFEF5350),
      _cat('education', 'Education', 'school', 0xFF78909C),
      _cat('utilities', 'Utilities', 'bolt', 0xFF8D6E63),
      _cat('personal_care', 'Personal Care', 'face', 0xFF8D6E63),
      _cat('other', 'Other', 'more_horiz', 0xFFBDBDBD),
    ];

    for (final c in defaults) {
      try {
        await _repo.createCategory(c);
      } catch (e) {
        debugPrint('CategoryBloc: failed to seed category ${c.categoryId}: $e');
      }
    }

    try {
      final all = await _repo.getCategories();
      emit(CategoryLoaded(all));
    } catch (_) {
      emit(const CategoryError('Failed to load categories.'));
    }
  }

  Category _cat(String id, String name, String icon, int color) {
    return Category(
      categoryId: id,
      userId: _userId,
      name: name,
      icon: icon,
      color: color,
      totalExpenses: 0,
    );
  }
}
