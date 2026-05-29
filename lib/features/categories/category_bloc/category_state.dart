part of 'category_bloc.dart';

class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  const CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
}

class CategoryCreated extends CategoryState {
  final Category category;
  const CategoryCreated(this.category);
}

class CategoryUpdated extends CategoryState {
  final Category category;
  const CategoryUpdated(this.category);
}

class CategoryArchived extends CategoryState {
  final String categoryId;
  const CategoryArchived(this.categoryId);
}
