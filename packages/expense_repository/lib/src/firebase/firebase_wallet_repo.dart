import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseWalletAccountRepository implements WalletAccountRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseWalletAccountRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        assert(userId.isNotEmpty);

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/wallets');

  @override
  Future<void> createWallet(WalletAccount wallet) async {
    await _col.doc(wallet.walletId).set(_toDoc(wallet));
  }

  @override
  Future<void> updateWallet(WalletAccount wallet) async {
    await _col.doc(wallet.walletId).set(_toDoc(wallet), SetOptions(merge: true));
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    await _col.doc(walletId).delete();
  }

  @override
  Future<List<WalletAccount>> getWallets() async {
    final snapshot = await _col.get();
    return snapshot.docs.map((d) => _walletFromDoc(d.data())).toList().cast<WalletAccount>();
  }

  @override
  Stream<List<WalletAccount>> watchWallets() {
    return _col.snapshots().map(
      (snap) => snap.docs.map((d) => _walletFromDoc(d.data())).toList().cast<WalletAccount>(),
    );
  }

  Map<String, dynamic> _toDoc(WalletAccount w) => {
    'walletId': w.walletId, 'userId': w.userId, 'name': w.name,
    'type': w.type, 'balance': w.balance, 'currency': w.currency,
    'icon': w.icon, 'color': w.color,
    'createdAt': Timestamp.fromDate(w.createdAt),
    'updatedAt': Timestamp.fromDate(w.updatedAt),
  };

  WalletAccount _walletFromDoc(Map<String, dynamic> d) {
    DateTime ts(v) => v is Timestamp ? v.toDate() : DateTime.now();
    return WalletAccount(
      walletId: d['walletId'] as String? ?? '',
      userId: d['userId'] as String? ?? '',
      name: d['name'] as String? ?? '',
      type: d['type'] as String? ?? 'cash',
      balance: (d['balance'] as num?)?.toDouble() ?? 0,
      currency: d['currency'] as String? ?? 'EGP',
      icon: d['icon'] as String? ?? '',
      color: d['color'] as int? ?? 0xFF6C63FF,
      createdAt: ts(d['createdAt']),
      updatedAt: ts(d['updatedAt']),
    );
  }
}

class FirebaseTransferRepository implements TransferRepository {
  final String userId;
  final FirebaseFirestore _firestore;

  FirebaseTransferRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users/$userId/transfers');

  @override
  Future<void> createTransfer(Transfer transfer) async {
    await _col.doc(transfer.transferId).set({
      'transferId': transfer.transferId, 'userId': transfer.userId,
      'fromWalletId': transfer.fromWalletId, 'toWalletId': transfer.toWalletId,
      'amount': transfer.amount, 'note': transfer.note,
      'date': Timestamp.fromDate(transfer.date),
      'createdAt': Timestamp.fromDate(transfer.createdAt),
    });
  }

  @override
  Future<List<Transfer>> getTransfers() async {
    final snapshot = await _col.orderBy('date', descending: true).get();
    return snapshot.docs.map((d) => _transferFromDoc(d.data())).toList().cast<Transfer>();
  }

  @override
  Stream<List<Transfer>> watchTransfers() {
    return _col.orderBy('date', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => _transferFromDoc(d.data())).toList().cast<Transfer>(),
    );
  }

  Transfer _transferFromDoc(Map<String, dynamic> d) {
    DateTime ts(v) => v is Timestamp ? v.toDate() : DateTime.now();
    return Transfer(
      transferId: d['transferId'] as String? ?? '',
      userId: d['userId'] as String? ?? '',
      fromWalletId: d['fromWalletId'] as String? ?? '',
      toWalletId: d['toWalletId'] as String? ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      note: d['note'] as String?,
      date: ts(d['date']),
      createdAt: ts(d['createdAt']),
    );
  }
}
