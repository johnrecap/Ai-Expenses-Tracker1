import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app/routes.dart';
import 'package:expenses_tracker/core/theme/app_theme.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/settings/presentation/settings_screen.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Settings language and currency', () {
    testWidgets('changing language keeps existing currency and onboarding state', (tester) async {
      final repository = _FakeSettingsRepository(
        UserSettings.defaults(
          userId: 'user-1',
          onboardingCompleted: true,
          onboardingVersion: UserSettings.currentOnboardingVersion,
        ).copyWith(baseCurrency: 'USD'),
      );

      await _pumpSettings(tester, repository);

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      final saved = repository.savedSettings;
      expect(saved, isNotNull);
      expect(saved!.languagePreference, LanguagePreference.english);
      expect(saved.baseCurrency, 'USD');
      expect(saved.onboardingCompleted, isTrue);
      expect(saved.requiresOnboarding, isFalse);
    });

    testWidgets('changing currency keeps existing language and onboarding state', (tester) async {
      final repository = _FakeSettingsRepository(
        UserSettings.defaults(
          userId: 'user-1',
          onboardingCompleted: true,
          onboardingVersion: UserSettings.currentOnboardingVersion,
        ).copyWith(languagePreference: LanguagePreference.arabic),
      );

      await _pumpSettings(tester, repository);

      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('USD').last);
      await tester.pumpAndSettle();

      final saved = repository.savedSettings;
      expect(saved, isNotNull);
      expect(saved!.baseCurrency, 'USD');
      expect(saved.languagePreference, LanguagePreference.arabic);
      expect(saved.onboardingCompleted, isTrue);
      expect(saved.requiresOnboarding, isFalse);
    });
  });
}

Future<void> _pumpSettings(
  WidgetTester tester,
  _FakeSettingsRepository settingsRepository,
) async {
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
  UserSettings? savedSettings;

  @override
  Future<UserSettings> ensureDefaultSettings() async => settings;

  @override
  Future<UserSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    this.settings = settings;
    savedSettings = settings;
  }

  @override
  Future<void> updateBaseCurrency(String currencyCode) async {
    settings = settings.copyWith(baseCurrency: currencyCode);
    savedSettings = settings;
  }

  @override
  Future<void> updateDefaultPaymentMethod(PaymentMethod paymentMethod) async {
    settings = settings.copyWith(defaultPaymentMethod: paymentMethod);
    savedSettings = settings;
  }

  @override
  Future<void> updateLanguagePreference(LanguagePreference languagePreference) async {
    settings = settings.copyWith(languagePreference: languagePreference);
    savedSettings = settings;
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
