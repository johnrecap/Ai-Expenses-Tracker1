import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/wallets/presentation/wallets_accounts_screen.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creates wallet from add sheet with signed-in user id and valid type', (
    tester,
  ) async {
    final walletRepository = _RecordingWalletRepository();
    const user = AppUser(userId: 'user-1', email: 'user@example.com');

    await tester.pumpWidget(
      RepositoryProvider<AuthRepository>.value(
        value: const _StaticAuthRepository(user),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) => AuthBloc(const _StaticAuthRepository(user)),
            ),
            BlocProvider<WalletBloc>(
              create: (_) =>
                  WalletBloc(walletRepository, const _FakeTransferRepository())
                    ..add(const WalletsWatched()),
            ),
            BlocProvider<SettingsCubit>(
              create: (_) => _LoadedSettingsCubit(
                UserSettings.defaults(
                  userId: user.userId,
                  onboardingCompleted: true,
                  onboardingVersion: UserSettings.currentOnboardingVersion,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const WalletsAccountsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('wallet-add-button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Cash');
    await tester.enterText(find.byType(TextField).at(1), '250');
    await tester.tap(find.byKey(const ValueKey('wallet-save-button')));
    await tester.pump();

    expect(walletRepository.created, hasLength(1));
    final wallet = walletRepository.created.single;
    expect(wallet.userId, 'user-1');
    expect(wallet.name, 'Cash');
    expect(wallet.balance, 250);
    expect(wallet.type, 'cash');
  });
}

class _RecordingWalletRepository implements WalletAccountRepository {
  final created = <WalletAccount>[];

  @override
  Future<void> createWallet(WalletAccount wallet) async {
    created.add(wallet);
  }

  @override
  Future<void> deleteWallet(String walletId) async {}

  @override
  Future<List<WalletAccount>> getWallets() async => created;

  @override
  Future<void> updateWallet(WalletAccount wallet) async {}

  @override
  Stream<List<WalletAccount>> watchWallets() => Stream.value(created);
}

class _FakeTransferRepository implements TransferRepository {
  const _FakeTransferRepository();

  @override
  Future<void> createTransfer(Transfer transfer) async {}

  @override
  Future<void> createTransferWithBalanceUpdate({
    required Transfer transfer,
    required WalletAccount source,
    required WalletAccount destination,
  }) async {}

  @override
  Future<List<Transfer>> getTransfers() async => const [];

  @override
  Stream<List<Transfer>> watchTransfers() => const Stream.empty();
}

class _LoadedSettingsCubit extends SettingsCubit {
  _LoadedSettingsCubit(UserSettings settings) : super(_FakeSettingsRepository(settings)) {
    emit(SettingsSuccess(settings));
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  UserSettings settings;

  @override
  Future<UserSettings> ensureDefaultSettings() async => settings;

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettings s) async {
    settings = s;
  }

  @override
  Future<void> updateBaseCurrency(String c) async {
    settings = settings.copyWith(baseCurrency: c);
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod m) async {
    settings = settings.copyWith(defaultPaymentMethod: m);
  }

  @override
  Future<void> updateLanguagePreference(LanguagePreference p) async {
    settings = settings.copyWith(languagePreference: p);
  }

  @override
  Stream<UserSettings> watchSettings() => Stream.value(settings);
}

class _StaticAuthRepository implements AuthRepository {
  const _StaticAuthRepository(this._user);

  final AppUser _user;

  @override
  AppUser? get currentUser => _user;

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<AppUser> reauthenticate({
    required String email,
    required String password,
  }) async => _user;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AppUser> updateEmail(String email) async => _user;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async => _user;

  @override
  Future<AppUser?> signInWithGoogle() async => _user;

  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => _user;

  @override
  Future<AppUser> updateDisplayName(String displayName) async => _user;

  @override
  Future<AppUser> reauthenticateWithGoogle() async => _user;

  @override
  Stream<AppUser> get user => Stream.value(_user);
}
