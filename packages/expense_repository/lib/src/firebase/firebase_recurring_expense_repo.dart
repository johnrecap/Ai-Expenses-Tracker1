import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseRecurringExpenseRepository implements RecurringExpenseRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseRecurringExpenseRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        assert(userId.isNotEmpty);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/recurringExpenses');

  @override
  Future<void> create(RecurringExpense item) async {
    await _col.doc(item.recurringExpenseId).set(_toDoc(item));
  }

  @override
  Future<void> update(RecurringExpense item) async {
    await _col.doc(item.recurringExpenseId).set(_toDoc(item), SetOptions(merge: true));
  }

  @override
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  @override
  Future<List<RecurringExpense>> getAll() async {
    final snapshot = await _col.get();
    return snapshot.docs.map((d) => _fromDoc(d.data())).toList();
  }

  @override
  Stream<List<RecurringExpense>> watchAll() {
    return _col.snapshots().map((snap) => snap.docs.map((d) => _fromDoc(d.data())).toList());
  }

  Map<String, dynamic> _toDoc(RecurringExpense r) => {
    'recurringExpenseId': r.recurringExpenseId, 'userId': r.userId, 'name': r.name,
    'amount': r.amount, 'currency': r.currency, 'categoryId': r.categoryId,
    'frequency': r.frequency, 'startDate': Timestamp.fromDate(r.startDate),
    if (r.endDate != null) 'endDate': Timestamp.fromDate(r.endDate!),
    if (r.lastGeneratedDate != null) 'lastGeneratedDate': Timestamp.fromDate(r.lastGeneratedDate!),
    'createdAt': Timestamp.fromDate(r.createdAt),
    'updatedAt': Timestamp.fromDate(r.createdAt),
  };

  RecurringExpense _fromDoc(Map<String, dynamic> d) {
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    DateTime? nts(dynamic v) => v is Timestamp ? v.toDate() : null;
    return RecurringExpense(
      recurringExpenseId: d['recurringExpenseId'] as String? ?? '',
      userId: d['userId'] as String? ?? '',
      name: d['name'] as String? ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      currency: d['currency'] as String? ?? 'EGP',
      categoryId: d['categoryId'] as String? ?? '',
      frequency: d['frequency'] as String? ?? 'monthly',
      startDate: ts(d['startDate']),
      endDate: nts(d['endDate']),
      lastGeneratedDate: nts(d['lastGeneratedDate']),
      createdAt: ts(d['createdAt']),
      updatedAt: ts(d['updatedAt']),
    );
  }
}
