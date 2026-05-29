part of 'wallet_bloc.dart';

class WalletEvent {
  const WalletEvent();
}

class WalletsWatched extends WalletEvent {
  const WalletsWatched();
}

class CreateWallet extends WalletEvent {
  final WalletAccount wallet;
  const CreateWallet(this.wallet);
}

class UpdateWallet extends WalletEvent {
  final WalletAccount wallet;
  const UpdateWallet(this.wallet);
}

class DeleteWallet extends WalletEvent {
  final String walletId;
  const DeleteWallet(this.walletId);
}

class CreateTransfer extends WalletEvent {
  final Transfer transfer;
  const CreateTransfer(this.transfer);
}
