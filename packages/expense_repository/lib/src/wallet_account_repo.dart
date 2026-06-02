import 'models/wallet_account.dart';

abstract class WalletAccountRepository {
  Future<void> createWallet(WalletAccount wallet);
  Future<void> updateWallet(WalletAccount wallet);
  Future<void> deleteWallet(String walletId);
  Future<List<WalletAccount>> getWallets();
  Stream<List<WalletAccount>> watchWallets();
}

abstract class TransferRepository {
  Future<void> createTransfer(Transfer transfer);
  Future<void> createTransferWithBalanceUpdate({
    required Transfer transfer,
    required WalletAccount source,
    required WalletAccount destination,
  });
  Future<List<Transfer>> getTransfers();
  Stream<List<Transfer>> watchTransfers();
}

class WalletTransferException implements Exception {
  const WalletTransferException(this.message);

  final String message;

  @override
  String toString() => message;
}
