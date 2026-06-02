import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletBloc transfer creation', () {
    test('rejects same source and destination wallets', () async {
      final transferRepo = _RecordingTransferRepository();
      final bloc = _LoadedWalletBloc(
        wallets: [_wallet('cash', balance: 100)],
        transferRepository: transferRepo,
      );

      final emission = expectLater(
        bloc.stream,
        emits(
          isA<WalletState>().having(
            (state) => state.message,
            'message',
            'Choose two different wallets.',
          ),
        ),
      );

      bloc.add(
        CreateTransfer(
          _transfer(fromWalletId: 'cash', toWalletId: 'cash', amount: 10),
        ),
      );

      await emission;
      expect(transferRepo.balanceUpdateCalls, isEmpty);
      await bloc.close();
    });

    test('rejects non-positive transfer amount', () async {
      final transferRepo = _RecordingTransferRepository();
      final bloc = _LoadedWalletBloc(
        wallets: [
          _wallet('cash', balance: 100),
          _wallet('bank', balance: 50),
        ],
        transferRepository: transferRepo,
      );

      final emission = expectLater(
        bloc.stream,
        emits(
          isA<WalletState>().having(
            (state) => state.message,
            'message',
            'Enter a valid transfer amount.',
          ),
        ),
      );

      bloc.add(
        CreateTransfer(
          _transfer(fromWalletId: 'cash', toWalletId: 'bank', amount: 0),
        ),
      );

      await emission;
      expect(transferRepo.balanceUpdateCalls, isEmpty);
      await bloc.close();
    });

    test('rejects insufficient source balance', () async {
      final transferRepo = _RecordingTransferRepository();
      final bloc = _LoadedWalletBloc(
        wallets: [
          _wallet('cash', balance: 25),
          _wallet('bank', balance: 50),
        ],
        transferRepository: transferRepo,
      );

      final emission = expectLater(
        bloc.stream,
        emits(
          isA<WalletState>().having(
            (state) => state.message,
            'message',
            'Insufficient wallet balance.',
          ),
        ),
      );

      bloc.add(
        CreateTransfer(
          _transfer(fromWalletId: 'cash', toWalletId: 'bank', amount: 40),
        ),
      );

      await emission;
      expect(transferRepo.balanceUpdateCalls, isEmpty);
      await bloc.close();
    });

    test('rejects transfers between different currencies', () async {
      final transferRepo = _RecordingTransferRepository();
      final bloc = _LoadedWalletBloc(
        wallets: [
          _wallet('cash', balance: 100, currency: 'EGP'),
          _wallet('usd', balance: 50, currency: 'USD'),
        ],
        transferRepository: transferRepo,
      );

      final emission = expectLater(
        bloc.stream,
        emits(
          isA<WalletState>().having(
            (state) => state.message,
            'message',
            'Transfers need wallets with the same currency.',
          ),
        ),
      );

      bloc.add(
        CreateTransfer(
          _transfer(fromWalletId: 'cash', toWalletId: 'usd', amount: 40),
        ),
      );

      await emission;
      expect(transferRepo.balanceUpdateCalls, isEmpty);
      await bloc.close();
    });

    test('calls repository balance update for valid transfer', () async {
      final transferRepo = _RecordingTransferRepository();
      final bloc = _LoadedWalletBloc(
        wallets: [
          _wallet('cash', balance: 100),
          _wallet('bank', balance: 50),
        ],
        transferRepository: transferRepo,
      );
      final transfer = _transfer(
        fromWalletId: 'cash',
        toWalletId: 'bank',
        amount: 40,
      );

      final emission = expectLater(
        bloc.stream,
        emits(
          isA<WalletState>().having(
            (state) => state.status,
            'status',
            WalletStatus.loading,
          ),
        ),
      );
      bloc.add(CreateTransfer(transfer));
      await emission;

      expect(transferRepo.balanceUpdateCalls, hasLength(1));
      final call = transferRepo.balanceUpdateCalls.single;
      expect(call.transfer, same(transfer));
      expect(call.source.walletId, 'cash');
      expect(call.destination.walletId, 'bank');
      await bloc.close();
    });
  });
}

class _LoadedWalletBloc extends WalletBloc {
  _LoadedWalletBloc({
    required List<WalletAccount> wallets,
    required _RecordingTransferRepository transferRepository,
  }) : super(_FakeWalletRepository(), transferRepository) {
    emit(WalletLoaded(wallets: wallets, transfers: const []));
  }
}

class _RecordingTransferRepository implements TransferRepository {
  final balanceUpdateCalls = <_TransferBalanceUpdateCall>[];

  @override
  Future<void> createTransfer(Transfer transfer) async {}

  @override
  Future<void> createTransferWithBalanceUpdate({
    required Transfer transfer,
    required WalletAccount source,
    required WalletAccount destination,
  }) async {
    balanceUpdateCalls.add(
      _TransferBalanceUpdateCall(
        transfer: transfer,
        source: source,
        destination: destination,
      ),
    );
  }

  @override
  Future<List<Transfer>> getTransfers() async => const [];

  @override
  Stream<List<Transfer>> watchTransfers() => const Stream.empty();
}

class _TransferBalanceUpdateCall {
  const _TransferBalanceUpdateCall({
    required this.transfer,
    required this.source,
    required this.destination,
  });

  final Transfer transfer;
  final WalletAccount source;
  final WalletAccount destination;
}

class _FakeWalletRepository implements WalletAccountRepository {
  @override
  Future<void> createWallet(WalletAccount wallet) async {}

  @override
  Future<void> deleteWallet(String walletId) async {}

  @override
  Future<List<WalletAccount>> getWallets() async => const [];

  @override
  Future<void> updateWallet(WalletAccount wallet) async {}

  @override
  Stream<List<WalletAccount>> watchWallets() => const Stream.empty();
}

WalletAccount _wallet(
  String id, {
  required double balance,
  String currency = 'EGP',
}) {
  final now = DateTime.utc(2026, 5, 31);
  return WalletAccount(
    walletId: id,
    userId: 'user-1',
    name: id,
    type: 'cash',
    balance: balance,
    currency: currency,
    icon: '',
    color: 0xFF006875,
    createdAt: now,
    updatedAt: now,
  );
}

Transfer _transfer({
  required String fromWalletId,
  required String toWalletId,
  required double amount,
}) {
  final now = DateTime.utc(2026, 5, 31, 12);
  return Transfer(
    transferId: 'transfer-1',
    userId: 'user-1',
    fromWalletId: fromWalletId,
    toWalletId: toWalletId,
    amount: amount,
    date: now,
    createdAt: now,
  );
}
