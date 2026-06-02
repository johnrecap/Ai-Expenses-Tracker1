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
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
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

  CollectionReference<Map<String, dynamic>> get _walletCol =>
      _firestore.collection('users/$userId/wallets');

  @override
  Future<void> createTransfer(Transfer transfer) async {
    await _col.doc(transfer.transferId).set(_transferToDoc(transfer));
  }

  @override
  Future<void> createTransferWithBalanceUpdate({
    required Transfer transfer,
    required WalletAccount source,
    required WalletAccount destination,
  }) async {
    _validateTransfer(transfer, source, destination);

    final sourceRef = _walletCol.doc(source.walletId);
    final destinationRef = _walletCol.doc(destination.walletId);
    final transferRef = _col.doc(transfer.transferId);

    await _firestore.runTransaction((transaction) async {
      final sourceSnapshot = await transaction.get(sourceRef);
      final destinationSnapshot = await transaction.get(destinationRef);

      if (!sourceSnapshot.exists || !destinationSnapshot.exists) {
        throw const WalletTransferException('Wallet no longer exists.');
      }

      final currentSource = _walletFromDoc(sourceSnapshot.data()!);
      final currentDestination = _walletFromDoc(destinationSnapshot.data()!);
      _validateTransfer(transfer, currentSource, currentDestination);

      final now = DateTime.now();
      final sourceBalance = currentSource.balance - transfer.amount;
      final destinationBalance = currentDestination.balance + transfer.amount;

      transaction.update(sourceRef, {
        'balance': sourceBalance,
        'updatedAt': Timestamp.fromDate(now),
      });
      transaction.update(destinationRef, {
        'balance': destinationBalance,
        'updatedAt': Timestamp.fromDate(now),
      });
      transaction.set(transferRef, _transferToDoc(transfer));
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
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
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

  Map<String, dynamic> _transferToDoc(Transfer transfer) => {
    'transferId': transfer.transferId, 'userId': userId,
    'fromWalletId': transfer.fromWalletId,
    'toWalletId': transfer.toWalletId,
    'amount': transfer.amount, 'note': transfer.note,
    'date': Timestamp.fromDate(transfer.date),
    'createdAt': Timestamp.fromDate(transfer.createdAt),
  };

  WalletAccount _walletFromDoc(Map<String, dynamic> d) {
    DateTime ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
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

  void _validateTransfer(
    Transfer transfer,
    WalletAccount source,
    WalletAccount destination,
  ) {
    if (transfer.fromWalletId == transfer.toWalletId) {
      throw const WalletTransferException('Choose two different wallets.');
    }
    if (transfer.amount <= 0 || transfer.amount.isNaN || transfer.amount.isInfinite) {
      throw const WalletTransferException('Enter a valid transfer amount.');
    }
    if (source.walletId != transfer.fromWalletId ||
        destination.walletId != transfer.toWalletId) {
      throw const WalletTransferException('Selected wallets do not match transfer.');
    }
    if (source.currency != destination.currency) {
      throw const WalletTransferException('Transfers need wallets with the same currency.');
    }
    if (source.balance < transfer.amount) {
      throw const WalletTransferException('Insufficient wallet balance.');
    }
  }
}
