import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseSavingGoalRepository implements SavingGoalRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseSavingGoalRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        assert(userId.isNotEmpty);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/saving_goals');

  Map<String, dynamic> _toDocument(SavingGoal g) => SavingGoalEntity(
    goalId: g.goalId, userId: g.userId, name: g.name,
    targetAmount: g.targetAmount, currentAmount: g.currentAmount,
    currency: g.currency, deadline: g.deadline, color: g.color,
    createdAt: g.createdAt, updatedAt: g.updatedAt,
  ).toDocument();

  SavingGoal _toModel(SavingGoalEntity e) => SavingGoal(
    goalId: e.goalId, userId: e.userId, name: e.name,
    targetAmount: e.targetAmount, currentAmount: e.currentAmount,
    currency: e.currency, deadline: e.deadline, color: e.color,
    createdAt: e.createdAt, updatedAt: e.updatedAt,
  );

  @override
  Future<void> createSavingGoal(SavingGoal goal) async {
    final toSave = goal.copyWith(userId: userId, updatedAt: DateTime.now());
    await _col.doc(toSave.goalId).set(_toDocument(toSave));
  }

  @override
  Future<void> updateSavingGoal(SavingGoal goal) async {
    final toSave = goal.copyWith(userId: userId, updatedAt: DateTime.now());
    await _col.doc(toSave.goalId).set(SavingGoalEntity.fromModel(toSave).toDocument(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteSavingGoal(String goalId) async {
    await _col.doc(goalId).delete();
  }

  @override
  Future<List<SavingGoal>> getSavingGoals() async {
    final snapshot = await _col.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((d) => SavingGoalEntity.fromDocument(d.data()).toModel()).toList();
  }

  @override
  Stream<List<SavingGoal>> watchSavingGoals() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => SavingGoalEntity.fromDocument(d.data()).toModel()).toList(),
    );
  }
}
