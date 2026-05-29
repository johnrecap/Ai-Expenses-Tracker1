import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseCategoryRepository implements CategoryRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseCategoryRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        assert(userId.isNotEmpty);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/categories');

  @override
  Future<void> createCategory(Category category) async {
    final toSave = category.copyWith(userId: userId, updatedAt: DateTime.now());
    await _col.doc(toSave.categoryId).set(toSave.toEntity().toDocument());
  }

  @override
  Future<void> updateCategory(Category category) async {
    final toSave = category.copyWith(userId: userId, updatedAt: DateTime.now());
    await _col.doc(toSave.categoryId).set(toSave.toEntity().toDocument(), SetOptions(merge: true));
  }

  @override
  Future<void> archiveCategory(Category category) async {
    await _col.doc(category.categoryId).set({
      'userId': userId, 'isArchived': true, 'updatedAt': DateTime.now(),
    }, SetOptions(merge: true));
  }

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async {
    final snapshot = await _col.orderBy('name').get();
    return snapshot.docs
        .map((d) => Category.fromEntity(CategoryEntity.fromDocument(d.data())))
        .where((c) => includeArchived || !c.isArchived)
        .toList();
  }

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) {
    return _col.orderBy('name').snapshots().map(
      (snap) => snap.docs
          .map((d) => Category.fromEntity(CategoryEntity.fromDocument(d.data())))
          .where((c) => includeArchived || !c.isArchived)
          .toList(),
    );
  }
}
