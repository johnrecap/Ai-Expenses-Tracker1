import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetEntity {
  final String budgetId;
  final String userId;
  final int month;
  final int year;
  final double amount;
  final String currency;
  final int warningThresholdPercent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetEntity({
    required this.budgetId, required this.userId, required this.month,
    required this.year, required this.amount, required this.currency,
    required this.warningThresholdPercent, required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() => {
    'budgetId': budgetId, 'userId': userId, 'month': month, 'year': year,
    'amount': amount, 'currency': currency,
    'warningThresholdPercent': warningThresholdPercent,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  static BudgetEntity fromDocument(Map<String, dynamic> data) {
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    return BudgetEntity(
      budgetId: data['budgetId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      month: data['month'] as int? ?? 0,
      year: data['year'] as int? ?? 0,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'EGP',
      warningThresholdPercent: data['warningThresholdPercent'] as int? ?? 80,
      createdAt: ts(data['createdAt']),
      updatedAt: ts(data['updatedAt']),
    );
  }
}

class CategoryBudgetEntity {
  final String budgetId;
  final String userId;
  final String categoryId;
  final double amount;
  final int month;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryBudgetEntity({
    required this.budgetId, required this.userId, required this.categoryId,
    required this.amount, required this.month, required this.year,
    required this.createdAt, required this.updatedAt,
  });

  Map<String, dynamic> toDocument() => {
    'budgetId': budgetId, 'userId': userId, 'categoryId': categoryId,
    'amount': amount, 'month': month, 'year': year,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  static CategoryBudgetEntity fromDocument(Map<String, dynamic> data) {
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    return CategoryBudgetEntity(
      budgetId: data['budgetId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      month: data['month'] as int? ?? 0,
      year: data['year'] as int? ?? 0,
      createdAt: ts(data['createdAt']),
      updatedAt: ts(data['updatedAt']),
    );
  }
}
