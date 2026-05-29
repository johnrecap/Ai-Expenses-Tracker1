import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletAccountRepository _walletRepo;
  final TransferRepository _transferRepo;

  WalletBloc(this._walletRepo, this._transferRepo) : super(const WalletState.initial()) {
    on<WalletsWatched>(_onWatch);
    on<CreateWallet>(_onCreate);
    on<UpdateWallet>(_onUpdate);
    on<DeleteWallet>(_onDelete);
    on<CreateTransfer>(_onCreateTransfer);
  }

  Future<void> _onWatch(WalletsWatched event, Emitter<WalletState> emit) async {
    emit(state.copyWith(status: WalletStatus.loading));
    try {
      await for (final wallets in _walletRepo.watchWallets()) {
        final transfers = await _transferRepo.getTransfers();
        emit(WalletLoaded(wallets: wallets, transfers: transfers));
      }
    } catch (_) {
      emit(state.copyWith(status: WalletStatus.error, message: 'Failed to load wallets.'));
    }
  }

  Future<void> _onCreate(CreateWallet event, Emitter<WalletState> emit) async {
    try {
      await _walletRepo.createWallet(event.wallet);
      add(const WalletsWatched());
    } catch (_) {
      emit(state.copyWith(message: 'Failed to create wallet.'));
    }
  }

  Future<void> _onUpdate(UpdateWallet event, Emitter<WalletState> emit) async {
    try {
      await _walletRepo.updateWallet(event.wallet);
      add(const WalletsWatched());
    } catch (_) {
      emit(state.copyWith(message: 'Failed to update wallet.'));
    }
  }

  Future<void> _onDelete(DeleteWallet event, Emitter<WalletState> emit) async {
    try {
      await _walletRepo.deleteWallet(event.walletId);
      add(const WalletsWatched());
    } catch (_) {
      emit(state.copyWith(message: 'Failed to delete wallet.'));
    }
  }

  Future<void> _onCreateTransfer(CreateTransfer event, Emitter<WalletState> emit) async {
    try {
      await _transferRepo.createTransfer(event.transfer);
      add(const WalletsWatched());
    } catch (_) {
      emit(state.copyWith(message: 'Failed to create transfer.'));
    }
  }
}
