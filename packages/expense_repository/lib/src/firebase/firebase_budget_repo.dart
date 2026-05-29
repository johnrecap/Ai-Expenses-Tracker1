import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseBudgetRepository implements BudgetRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseBudgetRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        assert(userId.isNotEmpty);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/budgets');

  @override
  Future<Budget?> getCurrentMonthBudget({required int month, required int year}) async {
    final doc = await _col.doc(Budget.budgetIdFor(month: month, year: year)).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return Budget.fromEntity(BudgetEntity.fromDocument(data));
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    final now = DateTime.now();
    final toSave = budget.copyWith(
      budgetId: Budget.budgetIdFor(month: budget.month, year: budget.year),
      userId: userId,
      updatedAt: now,
      createdAt: budget.createdAt.millisecondsSinceEpoch == 0 ? now : budget.createdAt,
    );
    await _col.doc(toSave.budgetId).set(toSave.toEntity().toDocument(), SetOptions(merge: true));
  }

  @override
  Stream<Budget?> watchCurrentMonthBudget({required int month, required int year}) {
    return _col.doc(Budget.budgetIdFor(month: month, year: year)).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return Budget.fromEntity(BudgetEntity.fromDocument(data));
    });
  }
}
