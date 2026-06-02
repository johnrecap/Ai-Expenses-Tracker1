import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/budgets/budget_bloc/budget_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/features/expenses/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/add_expense_ai_text_screen.dart';
import 'package:expenses_tracker/features/reports/report_cubit/report_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AddExpenseAiTextScreen', () {
    testWidgets('places save action directly before manual correction fields', (
      tester,
    ) async {
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        wallets: const [],
      );

      final saveTop = tester.getTopLeft(find.text('Save Expense')).dy;
      final categoryTop = tester.getTopLeft(find.text('Category')).dy;

      expect(saveTop, lessThan(categoryTop));
    });

    testWidgets('refreshes expense-driven state after AI save', (tester) async {
      final expenseRepository = _RecordingExpenseRepository();
      final getExpensesBloc = GetExpensesBloc(expenseRepository);
      final reportCubit = ReportCubit(expenseRepository);
      final budgetRepository = _CountingBudgetRepository();
      final budgetBloc = BudgetBloc(budgetRepository);

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        getExpensesBloc: getExpensesBloc,
        reportCubit: reportCubit,
        budgetBloc: budgetBloc,
      );

      await tester.enterText(find.byType(TextField).at(1), 'AI lunch');
      await tester.enterText(find.byType(TextField).at(2), '210');
      await tester.tap(
        find
            .ancestor(
              of: find.text('Food'),
              matching: find.byType(GestureDetector),
            )
            .last,
        warnIfMissed: false,
      );
      await tester.pump();

      final saveButton = find.ancestor(
        of: find.text('Save Expense'),
        matching: find.byType(InkWell),
      );
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(getExpensesBloc.state, isA<GetExpensesSuccess>());
      expect(
        (getExpensesBloc.state as GetExpensesSuccess).expenses,
        hasLength(1),
      );
      expect(reportCubit.state.expenses, hasLength(1));
      expect(budgetRepository.watchCount, greaterThanOrEqualTo(1));
    });

    testWidgets('saves expense with selected wallet details', (tester) async {
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        wallets: [_wallet(id: 'cash', name: 'Cash Wallet', currency: 'EGP')],
      );

      await tester.enterText(find.byType(TextField).at(1), 'AI lunch');
      await tester.enterText(find.byType(TextField).at(2), '210');
      await tester.tap(
        find
            .ancestor(
              of: find.text('Food'),
              matching: find.byType(GestureDetector),
            )
            .last,
        warnIfMissed: false,
      );
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
      expect(saved.amount, 210);
      expect(saved.description, 'AI lunch');
      expect(saved.currency, 'EGP');
      expect(saved.walletAccountId, 'cash');
      expect(saved.walletAccountName, 'Cash Wallet');
      expect(saved.paymentMethod, PaymentMethod.wallet);
      expect(saved.source, ExpenseSource.aiText);
    });

    testWidgets('saves without a wallet when no wallet exists', (tester) async {
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        wallets: const [],
      );

      expect(
        find.text('Wallet is optional. This expense will be saved without a wallet.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).at(1), 'AI lunch');
      await tester.enterText(find.byType(TextField).at(2), '210');
      await tester.tap(
        find
            .ancestor(
              of: find.text('Food'),
              matching: find.byType(GestureDetector),
            )
            .last,
        warnIfMissed: false,
      );
      await tester.pump();

      final saveButton = find.text('Save Expense');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(expenseRepository.created, hasLength(1));
      final saved = expenseRepository.created.single;
      expect(saved.amount, 210);
      expect(saved.description, 'AI lunch');
      expect(saved.currency, 'EGP');
      expect(saved.walletAccountId, isNull);
      expect(saved.walletAccountName, isNull);
      expect(saved.paymentMethod, PaymentMethod.cash);
      expect(saved.source, ExpenseSource.aiText);
    });

    testWidgets('saves no-wallet AI expenses with the configured default payment method', (
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

        await _pumpAiText(
          tester,
          expenseRepository: expenseRepository,
          defaultPaymentMethod: method,
        );

        await tester.enterText(find.byType(TextField).at(1), 'AI lunch');
        await tester.enterText(find.byType(TextField).at(2), '210');
        await tester.tap(
          find
              .ancestor(
                of: find.text('Food'),
                matching: find.byType(GestureDetector),
              )
              .last,
          warnIfMissed: false,
        );
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

    testWidgets('does not auto-link the only wallet when wallet is not selected', (
      tester,
    ) async {
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        defaultPaymentMethod: PaymentMethod.visa,
        wallets: [_wallet(id: 'cash', name: 'Cash Wallet', currency: 'EGP')],
      );

      await tester.enterText(find.byType(TextField).at(1), 'AI lunch');
      await tester.enterText(find.byType(TextField).at(2), '210');
      await tester.tap(
        find
            .ancestor(
              of: find.text('Food'),
              matching: find.byType(GestureDetector),
            )
            .last,
        warnIfMissed: false,
      );
      await tester.pump();

      final saveButton = find.text('Save Expense');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(expenseRepository.created, hasLength(1));
      final saved = expenseRepository.created.single;
      expect(saved.walletAccountId, isNull);
      expect(saved.walletAccountName, isNull);
      expect(saved.paymentMethod, PaymentMethod.visa);
    });
  });
}

Future<void> _pumpAiText(
  WidgetTester tester, {
  required _RecordingExpenseRepository expenseRepository,
  List<WalletAccount> wallets = const [],
  PaymentMethod defaultPaymentMethod = PaymentMethod.cash,
  GetExpensesBloc? getExpensesBloc,
  ReportCubit? reportCubit,
  BudgetBloc? budgetBloc,
}) async {
  const user = AppUser(userId: 'user-1', email: 'test@example.com');
  const authRepository = _StaticAuthRepository(user);
  final settings = UserSettings.defaults(
    userId: user.userId,
    onboardingCompleted: true,
    onboardingVersion: UserSettings.currentOnboardingVersion,
  ).copyWith(defaultPaymentMethod: defaultPaymentMethod);
  late final GoRouter router;
  router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AddExpenseAiTextScreen(),
      ),
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const Scaffold(body: Text('Expenses')),
      ),
      GoRoute(
        path: '/expenses/new/quick',
        builder: (context, state) => const Scaffold(body: Text('Quick')),
      ),
      GoRoute(
        path: '/expenses/new/receipt',
        builder: (context, state) => const Scaffold(body: Text('Receipt')),
      ),
    ],
  );
  addTearDown(router.dispose);
  if (getExpensesBloc != null) addTearDown(getExpensesBloc.close);
  if (reportCubit != null) addTearDown(reportCubit.close);
  if (budgetBloc != null) addTearDown(budgetBloc.close);

  await tester.pumpWidget(
    RepositoryProvider<ExpenseRepository>.value(
      value: expenseRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository),
          ),
          BlocProvider<CreateExpenseBloc>(
            create: (_) => CreateExpenseBloc(expenseRepository),
          ),
          if (getExpensesBloc != null) BlocProvider<GetExpensesBloc>.value(value: getExpensesBloc),
          if (reportCubit != null) BlocProvider<ReportCubit>.value(value: reportCubit),
          if (budgetBloc != null) BlocProvider<BudgetBloc>.value(value: budgetBloc),
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
    ),
  );
  await tester.pump();
}

class _LoadedSettingsCubit extends SettingsCubit {
  _LoadedSettingsCubit(UserSettings settings) : super(_FakeSettingsRepository(settings)) {
    emit(SettingsSuccess(settings));
  }
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
  final created = <Expense>[];

  @override
  Future<void> createExpense(Expense expense) async {
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

class _CountingBudgetRepository implements BudgetRepository {
  int watchCount = 0;

  @override
  Future<Budget?> getCurrentMonthBudget({
    required int month,
    required int year,
  }) async => null;

  @override
  Future<void> saveBudget(Budget budget) async {}

  @override
  Stream<Budget?> watchCurrentMonthBudget({
    required int month,
    required int year,
  }) {
    watchCount++;
    return Stream<Budget?>.value(null);
  }
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
