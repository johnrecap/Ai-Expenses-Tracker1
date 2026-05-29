import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseCategoryAliasRepository implements CategoryAliasRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseCategoryAliasRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        assert(userId.isNotEmpty);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/categoryAliases');

  @override
  Future<void> createAlias(CategoryAlias a) async {
    await _col.doc(a.aliasId).set({
      'aliasId': a.aliasId, 'userId': a.userId, 'name': a.name,
      'categoryId': a.categoryId, 'createdAt': Timestamp.fromDate(a.createdAt),
    });
  }

  @override
  Future<void> deleteAlias(String id) async => _col.doc(id).delete();

  @override
  Future<List<CategoryAlias>> getAliases() async {
    final snap = await _col.get();
    return snap.docs.map((d) {
      final data = d.data();
      return CategoryAlias(
        aliasId: data['aliasId'] as String? ?? '',
        userId: data['userId'] as String? ?? '',
        name: data['name'] as String? ?? '',
        categoryId: data['categoryId'] as String? ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList().cast<CategoryAlias>();
  }

  @override
  Stream<List<CategoryAlias>> watchAliases() {
    return _col.snapshots().map((snap) => snap.docs.map((d) {
      final data = d.data();
      return CategoryAlias(
        aliasId: data['aliasId'] as String? ?? '',
        userId: data['userId'] as String? ?? '',
        name: data['name'] as String? ?? '',
        categoryId: data['categoryId'] as String? ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList().cast<CategoryAlias>());
  }
}
