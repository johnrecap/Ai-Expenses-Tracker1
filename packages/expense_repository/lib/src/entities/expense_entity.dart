import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/money_snapshot.dart';

class ExpenseEntity {
  final String expenseId;
  final String userId;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final DateTime date;
  final double amount;
  final String description;
  final String? merchant;
  final List<String> tags;
  final String paymentMethod;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String source;
  final String? walletAccountId;
  final String? walletAccountName;
  final String? recurringExpenseId;
  final String? aiActionId;
  final MoneySnapshot? moneySnapshot;

  const ExpenseEntity({
    required this.expenseId, required this.userId, required this.categoryId,
    required this.categoryName, required this.categoryIcon, required this.categoryColor,
    required this.date, required this.amount, required this.description,
    this.merchant, required this.tags, required this.paymentMethod,
    required this.currency, required this.createdAt, required this.updatedAt,
    required this.source, this.walletAccountId, this.walletAccountName,
    this.recurringExpenseId, this.aiActionId, this.moneySnapshot,
  });

  Map<String, dynamic> toDocument() {
    return {
      'expenseId': expenseId, 'userId': userId, 'categoryId': categoryId,
      'categoryName': categoryName, 'categoryIcon': categoryIcon,
      'categoryColor': categoryColor, 'date': Timestamp.fromDate(date),
      'amount': amount, 'description': description,
      if (merchant != null) 'merchant': merchant,
      'tags': tags, 'paymentMethod': paymentMethod, 'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'source': source,
      if (walletAccountId != null) 'walletAccountId': walletAccountId,
      if (walletAccountName != null) 'walletAccountName': walletAccountName,
      if (recurringExpenseId != null) 'recurringExpenseId': recurringExpenseId,
      if (aiActionId != null) 'aiActionId': aiActionId,
      if (moneySnapshot != null) 'moneySnapshot': moneySnapshot!.toJson(),
    };
  }

  static ExpenseEntity fromDocument(Map<String, dynamic> data) {
    DateTime dt(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }
    return ExpenseEntity(
      expenseId: data['expenseId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      categoryIcon: data['categoryIcon'] as String? ?? '',
      categoryColor: data['categoryColor'] as int? ?? 0,
      date: dt(data['date']),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      description: data['description'] as String? ?? '',
      merchant: data['merchant'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      paymentMethod: data['paymentMethod'] as String? ?? 'cash',
      currency: data['currency'] as String? ?? 'EGP',
      createdAt: dt(data['createdAt']),
      updatedAt: dt(data['updatedAt']),
      source: data['source'] as String? ?? 'manual',
      walletAccountId: data['walletAccountId'] as String?,
      walletAccountName: data['walletAccountName'] as String?,
      recurringExpenseId: data['recurringExpenseId'] as String?,
      aiActionId: data['aiActionId'] as String?,
      moneySnapshot: data['moneySnapshot'] != null ? MoneySnapshot.fromJson(Map<String, dynamic>.from(data['moneySnapshot'] as Map)) : null,
    );
  }
}

class ExpensePageCursor {
  final DateTime date;
  final String expenseId;
  const ExpensePageCursor({required this.date, required this.expenseId});
}

class ExpensePage {
  final List<ExpenseEntity> expenses;
  final ExpensePageCursor? nextCursor;
  final int totalCount;
  const ExpensePage({required this.expenses, this.nextCursor, required this.totalCount});
}

const int defaultExpensePageSize = 50;
