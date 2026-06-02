import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/settings/presentation/settings_screen.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/monetization/cubit/entry_quota_cubit.dart';
import 'package:expenses_tracker/monetization/models/entry_quota.dart';
import 'package:expenses_tracker/monetization/services/entry_quota_service.dart';
import 'package:expenses_tracker/monetization/services/local_entry_quota_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Settings quota status', () {
    testWidgets('shows daily local manual and AI quota remaining', (tester) async {
      final quotaCubit = await _quotaCubit(
        normalConsumed: 1,
        aiConsumed: 2,
      );
      addTearDown(quotaCubit.close);

      await _pumpSettings(tester, quotaCubit: quotaCubit);

      await tester.ensureVisible(find.text('Daily entry limits'));

      expect(find.text('Daily entry limits'), findsOneWidget);
      expect(find.text('Manual entries'), findsOneWidget);
      expect(find.text('4 left today'), findsOneWidget);
      expect(find.text('AI entries'), findsOneWidget);
      expect(find.text('1 left today'), findsOneWidget);
      expect(find.textContaining('local to this device/account'), findsOneWidget);
      expect(find.textContaining('cloud sync'), findsNothing);
    });

    testWidgets('premium copy is ad-free and quota-free without cloud wording', (tester) async {
      final quotaCubit = await _quotaCubit(isPremium: true);
      addTearDown(quotaCubit.close);

      await _pumpSettings(tester, quotaCubit: quotaCubit);

      await tester.ensureVisible(find.text('Premium active').first);

      expect(find.text('Premium active'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Ad-free and quota-free'), findsOneWidget);
      expect(find.textContaining('Unlimited with Premium'), findsNWidgets(2));
      expect(find.textContaining('cloud sync'), findsNothing);
    });
  });
}

Future<EntryQuotaCubit> _quotaCubit({
  int normalConsumed = 0,
  int aiConsumed = 0,
  bool isPremium = false,
}) async {
  final cubit = EntryQuotaCubit(
    service: EntryQuotaService(
      store: _MemoryQuotaStore(),
      scopeId: 'settings-test-device',
      clock: () => DateTime(2026, 6, 2, 10),
    ),
    isPremium: isPremium,
  );
  await cubit.load(isPremium: isPremium);

  for (var index = 0; index < normalConsumed; index += 1) {
    await cubit.consumeAfterSuccessfulSave(
      kind: EntryQuotaKind.normal,
      operationId: 'manual-$index',
    );
  }

  for (var index = 0; index < aiConsumed; index += 1) {
    await cubit.consumeAfterSuccessfulSave(
      kind: EntryQuotaKind.ai,
      operationId: 'ai-$index',
    );
  }

  return cubit;
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

Future<void> _pumpSettings(
  WidgetTester tester, {
  required EntryQuotaCubit quotaCubit,
}) async {
  final settingsRepository = _FakeSettingsRepository(
    UserSettings.defaults(userId: 'user-1'),
  );
  final authRepository = _FakeAuthRepository();
  final router = GoRouter(
    initialLocation: AppRoutes.settings,
    routes: [
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (_) => AuthBloc(authRepository)..add(AuthUserChanged(authRepository.currentUser)),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(settingsRepository)..loadSettings(),
        ),
        BlocProvider<EntryQuotaCubit>.value(value: quotaCubit),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  UserSettings settings;

  @override
  Future<UserSettings> ensureDefaultSettings() async => settings;

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    this.settings = settings;
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    settings = settings.copyWith(baseCurrency: currencyCode);
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    settings = settings.copyWith(defaultPaymentMethod: paymentMethod);
  }

  @override
  Future<void> updateLanguagePreference(LanguagePreference languagePreference) async {
    settings = settings.copyWith(languagePreference: languagePreference);
  }

  @override
  Stream<UserSettings> watchSettings() => Stream.value(settings);
}

class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser>.broadcast();
  final _user = const AppUser(
    userId: 'user-1',
    email: 'user@example.com',
    displayName: 'User',
  );

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser> get user => _controller.stream;

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<AppUser> reauthenticate({required String email, required String password}) async => _user;

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AppUser> updateEmail(String email) async => _user;

  @override
  Future<AppUser> signIn({required String email, required String password}) async => _user;

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
}
