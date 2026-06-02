import 'dart:convert';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/ai/data/ai_gateway_client.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/categories/category_bloc/category_bloc.dart';
import 'package:expenses_tracker/features/expenses/presentation/add_expense_ai_text_screen.dart';
import 'package:expenses_tracker/features/expenses/presentation/cubit/ai_expense_entry_cubit.dart';
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
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AddExpenseAiTextScreen AI quota', () {
    testWidgets('shows the remaining AI entry count near save', (tester) async {
      final harness = await _QuotaHarness.create();
      addTearDown(harness.dispose);
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        quotaCubit: harness.cubit,
      );

      expect(find.byKey(EntryQuotaStatus.aiKey), findsOneWidget);
      expect(find.text('3 left today'), findsOneWidget);
    });

    testWidgets('successful AI save consumes one AI credit and no manual credit', (
      tester,
    ) async {
      final harness = await _QuotaHarness.create();
      addTearDown(harness.dispose);
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        quotaCubit: harness.cubit,
      );
      await _enterCompleteExpense(tester);
      await _tapSave(tester);

      expect(expenseRepository.created, hasLength(1));
      expect(harness.cubit.state.aiRemaining, 2);
      expect(harness.cubit.state.normalRemaining, 5);
    });

    testWidgets('failed local save does not consume AI credit', (tester) async {
      final harness = await _QuotaHarness.create();
      addTearDown(harness.dispose);
      final expenseRepository = _RecordingExpenseRepository(failCreates: true);

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        quotaCubit: harness.cubit,
      );
      await _enterCompleteExpense(tester);
      await _tapSave(tester);

      expect(expenseRepository.created, isEmpty);
      expect(harness.cubit.state.aiRemaining, 3);
      expect(harness.cubit.state.normalRemaining, 5);
    });

    testWidgets('local parser draft save consumes AI credit after saved state', (
      tester,
    ) async {
      final harness = await _QuotaHarness.create();
      addTearDown(harness.dispose);
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        quotaCubit: harness.cubit,
      );
      await tester.enterText(
        find.byType(TextField).first,
        'spent 250 EGP on food',
      );
      await tester.tap(find.text('Parse'));
      await tester.pumpAndSettle();
      expect(find.text('AI Suggestion'), findsOneWidget);

      await _tapSave(tester);

      expect(expenseRepository.created, hasLength(1));
      expect(expenseRepository.created.single.source, ExpenseSource.aiText);
      expect(harness.cubit.state.aiRemaining, 2);
      expect(harness.cubit.state.normalRemaining, 5);
    });

    testWidgets('exhausted AI quota blocks fourth save and opens AI reward sheet', (
      tester,
    ) async {
      final harness = await _QuotaHarness.create(consumedAi: 3);
      addTearDown(harness.dispose);
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        quotaCubit: harness.cubit,
      );
      await _enterCompleteExpense(tester);
      await _tapSave(tester);

      expect(expenseRepository.created, isEmpty);
      expect(find.byType(RewardedQuotaSheet), findsOneWidget);
      expect(find.text('Watch one ad to get 2 extra AI entries today.'), findsOneWidget);
    });

    testWidgets('verified rewarded AI ad grants two credits before retry save', (
      tester,
    ) async {
      final harness = await _QuotaHarness.create(consumedAi: 3);
      addTearDown(harness.dispose);
      final expenseRepository = _RecordingExpenseRepository();
      final monetizationCubit = MonetizationCubit(
        adService: const _FakeAdService(
          rewardedResult: RewardedAdResult.verified(
            rewardEventId: 'reward-ai-1',
          ),
        ),
      );
      addTearDown(monetizationCubit.close);
      await monetizationCubit.load();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        quotaCubit: harness.cubit,
        monetizationCubit: monetizationCubit,
      );
      await _enterCompleteExpense(tester);
      await _tapSave(tester);

      expect(harness.cubit.state.aiRemaining, 0);
      await tester.tap(find.byKey(RewardedQuotaSheet.watchAdButtonKey));
      await tester.pumpAndSettle();

      expect(harness.cubit.state.aiRemaining, 2);
      expect(expenseRepository.created, isEmpty);

      await _tapSave(tester);
      expect(expenseRepository.created, hasLength(1));
      expect(harness.cubit.state.aiRemaining, 1);
      expect(harness.cubit.state.normalRemaining, 5);
    });

    testWidgets('premium bypass saves even when free AI quota is exhausted', (
      tester,
    ) async {
      final harness = await _QuotaHarness.create(
        consumedAi: 3,
        isPremium: true,
      );
      addTearDown(harness.dispose);
      final expenseRepository = _RecordingExpenseRepository();

      await _pumpAiText(
        tester,
        expenseRepository: expenseRepository,
        quotaCubit: harness.cubit,
      );
      await _enterCompleteExpense(tester);
      await _tapSave(tester);

      expect(expenseRepository.created, hasLength(1));
      expect(find.byType(RewardedQuotaSheet), findsNothing);
      expect(harness.cubit.state.aiRemaining, 0);
      expect(harness.cubit.state.normalRemaining, 5);
    });
  });

  group('AI gateway quota is separate from local AI save quota', () {
    test('gateway 429 parse failure does not consume local AI save credit', () async {
      final harness = await _QuotaHarness.create();
      addTearDown(harness.dispose);
      final cubit = AiExpenseEntryCubit(
        gatewayClient: AiGatewayClient(
          baseUri: Uri.parse('https://gateway.test'),
          tokenProvider: () async => 'token',
          httpClient: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'ok': false,
                'requestId': 'req-quota',
                'errorCode': 'quota_exceeded',
                'errorMessage': 'Daily AI limit reached.',
              }),
              429,
            ),
          ),
        ),
        expenseRepository: _RecordingExpenseRepository(),
      );
      addTearDown(cubit.close);

      cubit.textChanged('please parse this ambiguous expense');
      await cubit.parseText(
        locale: 'en',
        defaultCurrency: 'EGP',
        categories: [_category()],
      );

      expect(cubit.state.status, AiExpenseEntryStatus.quotaBlocked);
      expect(harness.cubit.state.aiRemaining, 3);
      expect(harness.cubit.state.normalRemaining, 5);
    });
  });
}

Future<void> _enterCompleteExpense(WidgetTester tester) async {
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
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.ancestor(
    of: find.text('Save Expense'),
    matching: find.byType(InkWell),
  );
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

Future<void> _pumpAiText(
  WidgetTester tester, {
  required _RecordingExpenseRepository expenseRepository,
  required EntryQuotaCubit quotaCubit,
  MonetizationCubit? monetizationCubit,
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
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    RepositoryProvider<ExpenseRepository>.value(
      value: expenseRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<EntryQuotaCubit>.value(value: quotaCubit),
          if (monetizationCubit != null)
            BlocProvider<MonetizationCubit>.value(value: monetizationCubit),
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
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pump();
}

class _QuotaHarness {
  _QuotaHarness._(this.cubit);

  final EntryQuotaCubit cubit;

  static Future<_QuotaHarness> create({
    int consumedAi = 0,
    bool isPremium = false,
  }) async {
    final service = EntryQuotaService(
      store: _MemoryQuotaStore(),
      scopeId: 'scope-ai-test',
      clock: () => DateTime(2026, 6, 2, 10),
    );
    for (var index = 0; index < consumedAi; index += 1) {
      await service.consumeAfterSuccessfulSave(
        kind: EntryQuotaKind.ai,
        operationId: 'preconsumed-ai-$index',
      );
    }
    final cubit = EntryQuotaCubit(service: service, isPremium: isPremium);
    await cubit.load(isPremium: isPremium);
    return _QuotaHarness._(cubit);
  }

  Future<void> dispose() async {
    await cubit.close();
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
  _RecordingExpenseRepository({this.failCreates = false});

  final bool failCreates;
  final created = <Expense>[];

  @override
  Future<void> createExpense(Expense expense) async {
    if (failCreates) {
      throw StateError('local save failed');
    }
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

class _FakeAdService implements AdService {
  const _FakeAdService({required this.rewardedResult});

  final RewardedAdResult rewardedResult;

  @override
  Future<AdServiceStatus> initialize() async => const AdServiceStatus.available();

  @override
  void dispose() {}

  @override
  Future<AdShowResult> hideBanner() async => const AdShowResult.unavailable();

  @override
  Future<AdShowResult> showBanner() async => const AdShowResult.shown();

  @override
  Future<AdShowResult> showInterstitial() async => const AdShowResult.shown();

  @override
  Future<RewardedAdResult> showRewardedAd(AdPlacement placement) async => rewardedResult;
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
