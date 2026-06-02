import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/add_expense_quick_screen.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AddExpenseQuickScreen', () {
    testWidgets('saves the displayed selected-wallet currency and wallet', (
      tester,
    ) async {
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpQuickAdd(
        tester,
        expenseRepository: expenseRepository,
        baseCurrency: 'USD',
        wallets: [_wallet(id: 'cash', name: 'Cash Wallet', currency: 'EGP')],
      );

      expect(find.text('USD'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '125.50');
      await tester.tap(find.text('Food').first);
      await tester.pump();

      final walletDropdown = find.byType(DropdownButton<String>).last;
      await tester.ensureVisible(walletDropdown);
      await tester.tap(walletDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cash Wallet').last);
      await tester.pump();

      expect(find.text('EGP'), findsOneWidget);

      final saveButton = find.text('Save Expense');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(expenseRepository.created, hasLength(1));
      final saved = expenseRepository.created.single;
      expect(saved.amount, 125.50);
      expect(saved.currency, 'EGP');
      expect(saved.walletAccountId, 'cash');
      expect(saved.walletAccountName, 'Cash Wallet');
      expect(saved.categoryId, 'food');
      expect(saved.paymentMethod, PaymentMethod.wallet);
    });

    testWidgets('saves without a wallet when no wallet exists', (tester) async {
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpQuickAdd(
        tester,
        expenseRepository: expenseRepository,
        wallets: const [],
      );

      expect(
        find.text('Wallet is optional. This expense will be saved without a wallet.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).first, '80');
      await tester.tap(find.text('Food').first);
      await tester.pump();

      final saveButton = find.text('Save Expense');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(expenseRepository.created, hasLength(1));
      final saved = expenseRepository.created.single;
      expect(saved.amount, 80);
      expect(saved.currency, 'EGP');
      expect(saved.walletAccountId, isNull);
      expect(saved.walletAccountName, isNull);
      expect(saved.paymentMethod, PaymentMethod.cash);
    });

    testWidgets('saves no-wallet expenses with the configured default payment method', (
      tester,
    ) async {
      for (final method in [
        PaymentMethod.visa,
        PaymentMethod.wallet,
        PaymentMethod.bankTransfer,
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();

        final expenseRepository = _RecordingExpenseRepository();

        await _pumpQuickAdd(
          tester,
          expenseRepository: expenseRepository,
          defaultPaymentMethod: method,
          wallets: [_wallet(id: 'cash', name: 'Cash Wallet', currency: 'EGP')],
        );

        await tester.enterText(find.byType(TextField).first, '80');
        await tester.tap(find.text('Food').first);
        await tester.pump();

        final saveButton = find.text('Save Expense');
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(expenseRepository.created, hasLength(1));
        final saved = expenseRepository.created.single;
        expect(saved.walletAccountId, isNull);
        expect(saved.walletAccountName, isNull);
        expect(saved.paymentMethod, method);
      }
    });

    testWidgets('selected wallet wins over a non-wallet default method', (tester) async {
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpQuickAdd(
        tester,
        expenseRepository: expenseRepository,
        defaultPaymentMethod: PaymentMethod.visa,
        wallets: [_wallet(id: 'cash', name: 'Cash Wallet', currency: 'EGP')],
      );

      await tester.enterText(find.byType(TextField).first, '125.50');
      await tester.tap(find.text('Food').first);
      await tester.pump();

      final walletDropdown = find.byType(DropdownButton<String>).last;
      await tester.ensureVisible(walletDropdown);
      await tester.tap(walletDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cash Wallet').last);
      await tester.pump();

      final saveButton = find.text('Save Expense');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(expenseRepository.created, hasLength(1));
      final saved = expenseRepository.created.single;
      expect(saved.walletAccountId, 'cash');
      expect(saved.walletAccountName, 'Cash Wallet');
      expect(saved.paymentMethod, PaymentMethod.wallet);
    });

    testWidgets('shows a failure message when local save fails', (tester) async {
      final expenseRepository = _RecordingExpenseRepository(failCreates: true);

      await _pumpQuickAdd(
        tester,
        expenseRepository: expenseRepository,
        wallets: const [],
      );

      await tester.enterText(find.byType(TextField).first, '80');
      await tester.tap(find.text('Food').first);
      await tester.pump();

      final saveButton = find.text('Save Expense');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Failed to save expense.'), findsOneWidget);
      expect(expenseRepository.created, isEmpty);
    });
  });
}

Future<void> _pumpQuickAdd(
  WidgetTester tester, {
  required _RecordingExpenseRepository expenseRepository,
  String baseCurrency = 'EGP',
  PaymentMethod defaultPaymentMethod = PaymentMethod.cash,
  List<WalletAccount> wallets = const [],
}) async {
  const user = AppUser(userId: 'user-1', email: 'test@example.com');
  const authRepository = _StaticAuthRepository(user);
  final settings =
      UserSettings.defaults(
        userId: user.userId,
        onboardingCompleted: true,
        onboardingVersion: UserSettings.currentOnboardingVersion,
      ).copyWith(
        baseCurrency: baseCurrency,
        defaultPaymentMethod: defaultPaymentMethod,
      );
  late final GoRouter router;
  router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AddExpenseQuickScreen(),
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const Scaffold(body: Text('Expenses')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository),
        ),
        BlocProvider<CreateExpenseBloc>(
          create: (_) => CreateExpenseBloc(expenseRepository),
        ),
        BlocProvider<CategoryBloc>(
          create: (_) => _LoadedCategoryBloc([_category()]),
        ),
        BlocProvider<WalletBloc>(
          create: (_) => _LoadedWalletBloc(wallets),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => _LoadedSettingsCubit(settings),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
}

Category _category() {
  return Category(
    categoryId: 'food',
    userId: 'user-1',
    name: 'Food',
    totalExpenses: 0,
    icon: 'restaurant',
    color: 0xff000000,
  );
}

WalletAccount _wallet({
  required String id,
  required String name,
  required String currency,
}) {
  return WalletAccount(
    walletId: id,
    userId: 'user-1',
    name: name,
    type: 'cash',
    balance: 0,
    currency: currency,
    icon: 'wallet',
    color: 0xff000000,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}

class _LoadedSettingsCubit extends SettingsCubit {
  _LoadedSettingsCubit(UserSettings settings) : super(_FakeSettingsRepository(settings)) {
    emit(SettingsSuccess(settings));
  }
}

class _LoadedCategoryBloc extends CategoryBloc {
  _LoadedCategoryBloc(List<Category> categories) : super(_FakeCategoryRepository(), 'user-1') {
    emit(CategoryLoaded(categories));
  }
}

class _LoadedWalletBloc extends WalletBloc {
  _LoadedWalletBloc(List<WalletAccount> wallets)
    : super(_FakeWalletRepository(), _FakeTransferRepository()) {
    emit(WalletLoaded(wallets: wallets, transfers: const []));
  }
}

class _RecordingExpenseRepository implements ExpenseRepository {
  _RecordingExpenseRepository({this.failCreates = false});

  final bool failCreates;
  final created = <Expense>[];

  @override
  Future<void> createExpense(Expense expense) async {
    if (failCreates) throw StateError('local write failed');
    created.add(expense);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {}

  @override
  Future<Expense?> getExpenseById(String expenseId) async => null;

  @override
  Future<List<Expense>> getExpenses() async => created;

  @override
  Future<List<Expense>> getExpensesByFilter(ExpenseFilter filter) async => created;

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(created);
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

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<void> archiveCategory(Category category) async {}

  @override
  Future<void> createCategory(Category category) async {}

  @override
  Future<List<Category>> getCategories({bool includeArchived = false}) async => const [];

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Stream<List<Category>> watchCategories({bool includeArchived = false}) => const Stream.empty();
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

class _FakeTransferRepository implements TransferRepository {
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
