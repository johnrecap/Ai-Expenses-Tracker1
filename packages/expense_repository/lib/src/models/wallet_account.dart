class WalletAccount {
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

  const WalletAccount({
    required this.walletId, required this.userId, required this.name,
    required this.type, this.balance = 0, required this.currency,
    required this.icon, required this.color, required this.createdAt,
    required this.updatedAt,
  });

  WalletAccount copyWith({
    String? walletId, String? userId, String? name, String? type,
    double? balance, String? currency, String? icon, int? color,
    DateTime? createdAt, DateTime? updatedAt,
  }) {
    return WalletAccount(
      walletId: walletId ?? this.walletId, userId: userId ?? this.userId,
      name: name ?? this.name, type: type ?? this.type,
      balance: balance ?? this.balance, currency: currency ?? this.currency,
      icon: icon ?? this.icon, color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Transfer {
  final String transferId;
  final String userId;
  final String fromWalletId;
  final String toWalletId;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  const Transfer({
    required this.transferId, required this.userId,
    required this.fromWalletId, required this.toWalletId,
    required this.amount, this.note, required this.date,
    required this.createdAt,
  });
}
