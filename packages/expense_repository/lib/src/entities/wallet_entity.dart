import 'package:cloud_firestore/cloud_firestore.dart';

class WalletAccountEntity {
  final String walletId;
  final String userId;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String icon;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletAccountEntity({
    required this.walletId, required this.userId, required this.name,
    required this.type, this.balance = 0, required this.currency,
    required this.icon, required this.color, required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() => {
    'walletId': walletId, 'userId': userId, 'name': name,
    'type': type, 'balance': balance, 'currency': currency,
    'icon': icon, 'color': color,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory WalletAccountEntity.fromDocument(Map<String, dynamic> doc) {
    return WalletAccountEntity(
      walletId: doc['walletId'] as String,
      userId: doc['userId'] as String,
      name: doc['name'] as String,
      type: doc['type'] as String,
      balance: (doc['balance'] as num?)?.toDouble() ?? 0,
      currency: doc['currency'] as String,
      icon: doc['icon'] as String,
      color: doc['color'] as int,
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
      updatedAt: (doc['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class TransferEntity {
  final String transferId;
  final String userId;
  final String fromWalletId;
  final String toWalletId;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  const TransferEntity({
    required this.transferId, required this.userId,
    required this.fromWalletId, required this.toWalletId,
    required this.amount, this.note, required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toDocument() => {
    'transferId': transferId, 'userId': userId,
    'fromWalletId': fromWalletId, 'toWalletId': toWalletId,
    'amount': amount, 'note': note,
    'date': Timestamp.fromDate(date),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory TransferEntity.fromDocument(Map<String, dynamic> doc) {
    return TransferEntity(
      transferId: doc['transferId'] as String,
      userId: doc['userId'] as String,
      fromWalletId: doc['fromWalletId'] as String,
      toWalletId: doc['toWalletId'] as String,
      amount: (doc['amount'] as num).toDouble(),
      note: doc['note'] as String?,
      date: (doc['date'] as Timestamp).toDate(),
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
    );
  }
}
