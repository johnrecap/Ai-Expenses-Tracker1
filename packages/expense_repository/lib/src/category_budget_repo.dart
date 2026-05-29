import 'models/budget.dart';

abstract class CategoryBudgetRepository {
  Future<void> saveCategoryBudget(CategoryBudget budget);
  Future<CategoryBudget?> getCategoryBudget({required String categoryId, required int month, required int year});
  Future<List<CategoryBudget>> getCategoryBudgets({required int month, required int year});
  Stream<List<CategoryBudget>> watchCategoryBudgets({required int month, required int year});
}
