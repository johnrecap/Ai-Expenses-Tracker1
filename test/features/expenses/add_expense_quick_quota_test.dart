import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/expenses/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/add_expense_quick_screen.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/features/wallets/wallet_bloc/wallet_bloc.dart';
import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/monetization/cubit/monetization_cubit.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/ad_service.dart';
import 'package:expenses_tracker/monetization/services/entry_quota_service.dart';
import 'package:expenses_tracker/monetization/services/local_entry_quota_store.dart';
import 'package:expenses_tracker/monetization/widgets/entry_quota_status.dart';
import 'package:expenses_tracker/monetization/widgets/rewarded_quota_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AddExpenseQuickScreen quota', () {
    testWidgets('shows remaining normal-entry count', (tester) async {
      final quotaCubit = await _createQuotaCubit();
      final monetizationCubit = await _createMonetizationCubit();

      await _pumpQuickAdd(
        tester,
        expenseRepository: _RecordingExpenseRepository(),
        quotaCubit: quotaCubit,
        monetizationCubit: monetizationCubit,
      );

      expect(find.byKey(EntryQuotaStatus.normalKey), findsOneWidget);
      expect(find.text('5 left today'), findsOneWidget);
    });

    testWidgets('consumes quota only after successful local save', (tester) async {
      final quotaCubit = await _createQuotaCubit();
      final monetizationCubit = await _createMonetizationCubit();
      final expenseRepository = _RecordingExpenseRepository(delayCreates: true);

      await _pumpQuickAdd(
        tester,
        expenseRepository: expenseRepository,
        quotaCubit: quotaCubit,
        monetizationCubit: monetizationCubit,
      );

      await _fillAndSave(tester);
      await tester.pump();

      expect(expenseRepository.createCalls, 1);
      expect(quotaCubit.state.normalRemaining, EntryQuotaDefaults.normalDailyLimit);

      expenseRepository.completePendingCreate();
      await tester.pumpAndSettle();

      expect(expenseRepository.created, hasLength(1));
      expect(quotaCubit.state.normalRemaining, EntryQuotaDefaults.normalDailyLimit - 1);
    });

    testWidgets('failed local save does not consume quota', (tester) async {
      final quotaCubit = await _createQuotaCubit();
      final monetizationCubit = await _createMonetizationCubit();

      await _pumpQuickAdd(
        tester,
        expenseRepository: _RecordingExpenseRepository(failCreates: true),
        quotaCubit: quotaCubit,
        monetizationCubit: monetizationCubit,
      );

      await _fillAndSave(tester);
      await tester.pumpAndSettle();

      expect(find.text('Failed to save expense.'), findsOneWidget);
      expect(quotaCubit.state.normalRemaining, EntryQuotaDefaults.normalDailyLimit);
    });

    testWidgets('sixth free manual save is blocked and opens reward sheet', (tester) async {
      final quotaCubit = await _createQuotaCubit();
      final rewardedAdService = _RewardedAdService();
      final monetizationCubit = await _createMonetizationCubit(adService: rewardedAdService);
      final expenseRepository = _RecordingExpenseRepository();

      for (var index = 0; index < EntryQuotaDefaults.normalDailyLimit; index += 1) {
        await _pumpQuickAdd(
          tester,
          expenseRepository: expenseRepository,
          quotaCubit: quotaCubit,
          monetizationCubit: monetizationCubit,
        );
        await _fillAndSave(tester, amount: '${index + 1}');
        await tester.pumpAndSettle();
      }

      expect(expenseRepository.created, hasLength(EntryQuotaDefaults.normalDailyLimit));
      expect(quotaCubit.state.normalRemaining, 0);

      await _pumpQuickAdd(
        tester,
        expenseRepository: expenseRepository,
        quotaCubit: quotaCubit,
        monetizationCubit: monetizationCubit,
      );
      await _fillAndSave(tester, amount: '99');
      await tester.pumpAndSettle();

      expect(expenseRepository.created, hasLength(EntryQuotaDefaults.normalDailyLimit));
      expect(find.byType(RewardedQuotaSheet), findsOneWidget);
      expect(find.byKey(RewardedQuotaSheet.watchAdButtonKey), findsOneWidget);

      await tester.tap(find.byKey(RewardedQuotaSheet.watchAdButtonKey));
      await tester.pumpAndSettle();

      expect(rewardedAdService.rewardedCalls, 1);
      expect(quotaCubit.state.normalRemaining, EntryQuotaDefaults.rewardedNormalGrant);
      expect(find.byType(RewardedQuotaSheet), findsNothing);
    });

    testWidgets('premium bypasses normal quota and never opens reward sheet', (tester) async {
      final quotaCubit = await _createQuotaCubit(isPremium: true);
      final monetizationCubit = await _createMonetizationCubit();
      monetizationCubit.setPremium(true);
      final expenseRepository = _RecordingExpenseRepository();

      for (var index = 0; index < EntryQuotaDefaults.normalDailyLimit + 1; index += 1) {
        await _pumpQuickAdd(
          tester,
          expenseRepository: expenseRepository,
          quotaCubit: quotaCubit,
          monetizationCubit: monetizationCubit,
        );
        await _fillAndSave(tester, amount: '${index + 1}');
        await tester.pumpAndSettle();
      }

      expect(expenseRepository.created, hasLength(EntryQuotaDefaults.normalDailyLimit + 1));
      expect(find.byType(RewardedQuotaSheet), findsNothing);
      expect(quotaCubit.state.normalRemaining, EntryQuotaDefaults.normalDailyLimit);
    });
  });
}

Future<EntryQuotaCubit> _createQuotaCubit({bool isPremium = false}) async {
  final cubit = EntryQuotaCubit(
    service: EntryQuotaService(
      store: _MemoryQuotaStore(),
      scopeId: 'scope-1',
      clock: () => DateTime(2026, 6, 2, 10),
    ),
    isPremium: isPremium,
  );
  await cubit.load(isPremium: isPremium);
  addTearDown(() async {
    await cubit.close();
  });
  return cubit;
}

Future<MonetizationCubit> _createMonetizationCubit({
  AdService? adService,
}) async {
  final cubit = MonetizationCubit(adService: adService ?? const UnavailableAdService());
  await cubit.load();
  addTearDown(cubit.close);
  return cubit;
}

Future<void> _fillAndSave(
  WidgetTester tester, {
  String amount = '80',
}) async {
  await tester.enterText(find.byType(TextField).first, amount);
  await tester.tap(find.text('Food').first);
  await tester.pump();

  final saveButton = find.text('Save Expense');
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
}

Future<void> _pumpQuickAdd(
  WidgetTester tester, {
  required _RecordingExpenseRepository expenseRepository,
  required EntryQuotaCubit quotaCubit,
  required MonetizationCubit monetizationCubit,
  List<WalletAccount> wallets = const [],
}) async {
  const user = AppUser(userId: 'user-1', email: 'test@example.com');
  const authRepository = _StaticAuthRepository(user);
  final settings = UserSettings.defaults(
    userId: user.userId,
    onboardingCompleted: true,
    onboardingVersion: UserSettings.currentOnboardingVersion,
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
        BlocProvider<EntryQuotaCubit>.value(value: quotaCubit),
        BlocProvider<MonetizationCubit>.value(value: monetizationCubit),
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

class _RewardedAdService implements AdService {
  int rewardedCalls = 0;

  @override
  Future<AdServiceStatus> initialize() async => const AdServiceStatus.available();

  @override
  void dispose() {}

  @override
  Future<AdShowResult> hideBanner() async => const AdShowResult.shown('Banner hidden');

  @override
  Future<AdShowResult> showBanner() async => const AdShowResult.shown('Banner shown');

  @override
  Future<AdShowResult> showInterstitial() async => const AdShowResult.shown();

  @override
  Future<RewardedAdResult> showRewardedAd(AdPlacement placement) async {
    rewardedCalls += 1;
    return RewardedAdResult.verified(rewardEventId: 'normal-reward-$rewardedCalls');
  }
}

class _MemoryQuotaStore implements LocalEntryQuotaStore {
  EntryQuotaSnapshot? _snapshot;
  final _consumedOperationIds = <String>{};
  final _rewardEventIds = <String>{};

  @override
  Future<EntryQuotaSnapshot> loadSnapshot({
    required String scopeId,
    required DateTime now,
    bool isPremium = false,
  }) async {
    final date = entryQuotaDateKey(now);
    final existing = _snapshot;
    if (existing == null || existing.quotaDate != date) {
      _snapshot = EntryQuotaSnapshot.fresh(
        scopeId: scopeId,
        now: now,
        isPremium: isPremium,
      );
    } else {
      _snapshot = existing.copyWith(isPremium: isPremium);
    }
    return _snapshot!;
  }

  @override
  Future<EntryQuotaMutationResult> consume({
    required String scopeId,
    required EntryQuotaKind kind,
    required String operationId,
    required DateTime now,
    String? expenseId,
  }) async {
    var snapshot = await loadSnapshot(scopeId: scopeId, now: now);
    if (_consumedOperationIds.contains(operationId)) {
      return EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.duplicate,
        snapshot: snapshot,
        message: 'This save operation already consumed quota.',
      );
    }
    if (!snapshot.hasRemainingFor(kind)) {
      return EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.blocked,
        snapshot: snapshot,
        message: 'Daily entry quota is exhausted.',
      );
    }

    _consumedOperationIds.add(operationId);
    snapshot = switch (kind) {
      EntryQuotaKind.normal => snapshot.copyWith(
        normalConsumed: snapshot.normalConsumed + 1,
      ),
      EntryQuotaKind.ai => snapshot.copyWith(
        aiConsumed: snapshot.aiConsumed + 1,
      ),
    };
    _snapshot = snapshot;
    return EntryQuotaMutationResult(
      status: EntryQuotaMutationStatus.consumed,
      snapshot: snapshot,
      message: 'Entry quota consumed.',
    );
  }

  @override
  Future<EntryQuotaMutationResult> grantReward({
    required String scopeId,
    required EntryQuotaRewardPlacement placement,
    required String rewardEventId,
    required DateTime now,
    int? amount,
  }) async {
    var snapshot = await loadSnapshot(scopeId: scopeId, now: now);
    if (_rewardEventIds.contains(rewardEventId)) {
      return EntryQuotaMutationResult(
        status: EntryQuotaMutationStatus.duplicate,
        snapshot: snapshot,
        message: 'This reward event was already granted.',
      );
    }

    _rewardEventIds.add(rewardEventId);
    switch (placement) {
      case EntryQuotaRewardPlacement.rewardedNormalEntries:
        snapshot = snapshot.copyWith(
          normalRewardedRemaining:
              snapshot.normalRewardedRemaining +
              (amount ?? EntryQuotaDefaults.rewardedNormalGrant),
        );
      case EntryQuotaRewardPlacement.rewardedAiEntries:
        snapshot = snapshot.copyWith(
          aiRewardedRemaining:
              snapshot.aiRewardedRemaining +
              (amount ?? EntryQuotaDefaults.rewardedAiGrant),
        );
    }
    _snapshot = snapshot;
    return EntryQuotaMutationResult(
      status: EntryQuotaMutationStatus.granted,
      snapshot: snapshot,
      message: 'Rewarded entry credits granted.',
    );
  }
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
  _RecordingExpenseRepository({
    this.failCreates = false,
    this.delayCreates = false,
  });

  final bool failCreates;
  final bool delayCreates;
  final created = <Expense>[];
  int createCalls = 0;
  Completer<void>? _pendingCreate;

  @override
  Future<void> createExpense(Expense expense) async {
    createCalls += 1;
    if (delayCreates) {
      _pendingCreate = Completer<void>();
      await _pendingCreate!.future;
    }
    if (failCreates) throw StateError('local write failed');
    created.add(expense);
  }

  void completePendingCreate() {
    _pendingCreate?.complete();
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
