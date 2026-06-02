import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/add_expense_ai_text_screen.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddExpenseAiTextScreen narrow layout', () {
    testWidgets('keeps long AI input inside the field at 360px in English and Arabic', (
      tester,
    ) async {
      await _setPhoneSize(tester);

      for (final locale in [const Locale('en'), const Locale('ar')]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _pumpAiText(tester, locale: locale);

        final aiInput = find.byType(TextField).first;
        final field = tester.widget<TextField>(aiInput);
        expect(field.minLines, greaterThanOrEqualTo(3));
        expect(field.maxLines, greaterThanOrEqualTo(5));
        expect(field.decoration?.hintMaxLines, greaterThanOrEqualTo(3));

        await tester.enterText(
          aiInput,
          locale.languageCode == 'ar'
              ? 'صرفت ٢٥٠ جنيه على غدا في مطعم قريب من البيت ودفعته كاش'
              : 'Spent 250 EGP on lunch at a restaurant near home and paid cash',
        );
        await tester.pump();

        expect(tester.getSize(aiInput).width, lessThanOrEqualTo(328));
        expect(find.text('Save Expense'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('save is disabled until required fields are ready', (tester) async {
      await _setPhoneSize(tester);
      await _pumpAiText(tester);

      final saveInkWell = find.ancestor(
        of: find.text('Save Expense'),
        matching: find.byType(InkWell),
      );

      expect(tester.widget<InkWell>(saveInkWell).onTap, isNull);
      expect(find.text('Add an amount before saving.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpAiText(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  const user = AppUser(userId: 'user-1', email: 'test@example.com');
  const authRepository = _StaticAuthRepository(user);
  final settings = UserSettings.defaults(
    userId: user.userId,
    onboardingCompleted: true,
    onboardingVersion: UserSettings.currentOnboardingVersion,
  );
  final expenseRepository = _RecordingExpenseRepository();

  await tester.pumpWidget(
    RepositoryProvider<ExpenseRepository>.value(
      value: expenseRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository),
          ),
          BlocProvider<CategoryBloc>(
            create: (_) => _LoadedCategoryBloc([_category()]),
          ),
          BlocProvider<WalletBloc>(
            create: (_) => _LoadedWalletBloc(const []),
          ),
          BlocProvider<SettingsCubit>(
            create: (_) => _LoadedSettingsCubit(settings),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          home: const AddExpenseAiTextScreen(),
        ),
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
