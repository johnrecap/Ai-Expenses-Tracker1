import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseCategoryBudgetRepository implements CategoryBudgetRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseCategoryBudgetRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        assert(userId.isNotEmpty);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/categoryBudgets');

  Map<String, dynamic> _toDoc(CategoryBudget b) => CategoryBudgetEntity(
    budgetId: b.budgetId, userId: b.userId, categoryId: b.categoryId,
    amount: b.amount, month: b.month, year: b.year,
    createdAt: b.createdAt, updatedAt: b.updatedAt,
  ).toDocument();

  CategoryBudget _fromEntity(CategoryBudgetEntity e) => CategoryBudget(
    budgetId: e.budgetId, userId: e.userId, categoryId: e.categoryId,
    amount: e.amount, month: e.month, year: e.year,
    createdAt: e.createdAt, updatedAt: e.updatedAt,
  );

  @override
  Future<void> saveCategoryBudget(CategoryBudget budget) async {
    final toSave = budget.copyWith(userId: userId, updatedAt: DateTime.now());
    await _col.doc(_budgetId(budget)).set(_toDoc(toSave), SetOptions(merge: true));
  }

  @override
  Future<CategoryBudget?> getCategoryBudget({required String categoryId, required int month, required int year}) async {
    final id = _computeId(categoryId: categoryId, month: month, year: year);
    final doc = await _col.doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return _fromEntity(CategoryBudgetEntity.fromDocument(data));
  }

  @override
  Future<List<CategoryBudget>> getCategoryBudgets({required int month, required int year}) async {
    final snapshot = await _col.where('month', isEqualTo: month).where('year', isEqualTo: year).get();
    return snapshot.docs      .map((d) => _fromEntity(CategoryBudgetEntity.fromDocument(d.data()))).toList();
  }

  @override
  Stream<List<CategoryBudget>> watchCategoryBudgets({required int month, required int year}) {
    return _col.where('month', isEqualTo: month).where('year', isEqualTo: year).snapshots().map(
      (snap) => snap.docs.map((d) => _fromEntity(CategoryBudgetEntity.fromDocument(d.data()))).toList(),
    );
  }

  String _computeId({required String categoryId, required int month, required int year}) =>
      '$year-${month.toString().padLeft(2, '0')}-$categoryId';

  String _budgetId(CategoryBudget budget) => _computeId(categoryId: budget.categoryId, month: budget.month, year: budget.year);
}
