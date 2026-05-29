part of 'wallet_bloc.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletState extends Equatable {
  final WalletStatus status;
  final List<WalletAccount> wallets;
  final List<Transfer> transfers;
  final String? message;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallets = const [],
    this.transfers = const [],
    this.message,
  });

  const WalletState.initial() : this();

  WalletState copyWith({
    WalletStatus? status,
    List<WalletAccount>? wallets,
    List<Transfer>? transfers,
    String? message,
    bool clearMessage = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      transfers: transfers ?? this.transfers,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, wallets, transfers, message];
}

class WalletLoaded extends WalletState {
  const WalletLoaded({
    required super.wallets,
    required super.transfers,
  }) : super(status: WalletStatus.loaded);
}
