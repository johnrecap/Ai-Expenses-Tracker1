import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseExpenseRepo implements ExpenseRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseExpenseRepo({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        assert(userId.isNotEmpty);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/expenses');

  @override
  Future<void> createExpense(Expense expense) async {
    expense.userId = userId;
    expense.updatedAt = DateTime.now();
    await _col.doc(expense.expenseId).set(expense.toEntity().toDocument());
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    expense.userId = userId;
    expense.updatedAt = DateTime.now();
    await _col.doc(expense.expenseId).set(expense.toEntity().toDocument(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _col.doc(expenseId).delete();
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    final doc = await _col.doc(expenseId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return Expense.fromEntity(ExpenseEntity.fromDocument(data));
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final snapshot = await _col.orderBy('date', descending: true).get();
    return snapshot.docs.map((d) => Expense.fromEntity(ExpenseEntity.fromDocument(d.data()))).toList();
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return _col.orderBy('date', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => Expense.fromEntity(ExpenseEntity.fromDocument(d.data()))).toList(),
    );
  }

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async {
    Query<Map<String, dynamic>> query = _col;
    if (filter.startDate != null) query = query.where('date', isGreaterThanOrEqualTo: filter.startDate);
    if (filter.endDate != null) query = query.where('date', isLessThanOrEqualTo: filter.endDate);
    final snapshot = await query.orderBy('date', descending: true).get();
    final normalizedQuery = filter.searchQuery?.trim().toLowerCase() ?? '';
    return snapshot.docs
        .map((d) => Expense.fromEntity(ExpenseEntity.fromDocument(d.data())))
        .where((e) => normalizedQuery.isEmpty ||
            e.description.toLowerCase().contains(normalizedQuery) ||
            e.categoryName.toLowerCase().contains(normalizedQuery))
        .toList();
  }
}
