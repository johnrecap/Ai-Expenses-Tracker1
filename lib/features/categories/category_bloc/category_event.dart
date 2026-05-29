part of 'category_bloc.dart';

class CategoryEvent {
  const CategoryEvent();
}

class CategoriesWatched extends CategoryEvent {
  const CategoriesWatched();
}

class CreateCategory extends CategoryEvent {
  final Category category;
  const CreateCategory(this.category);
}

class UpdateCategory extends CategoryEvent {
  final Category category;
  const UpdateCategory(this.category);
}

class ArchiveCategory extends CategoryEvent {
  final String categoryId;
  const ArchiveCategory(this.categoryId);
}
