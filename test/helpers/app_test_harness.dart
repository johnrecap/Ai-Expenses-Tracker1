import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:expenses_tracker/features/onboarding/onboarding_cubit/onboarding_cubit.dart';
import 'package:expenses_tracker/features/settings/settings_cubit/settings_cubit.dart';
import 'package:expenses_tracker/l10n/app_language_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppTestHarness {
  AppTestHarness({
    AppUser? user,
    LocalRepositoryStore? store,
  }) : authRepository = TestAuthRepository(user: user),
       store = store ?? LocalRepositoryStore(userId: user?.userId ?? 'test-user');

  final TestAuthRepository authRepository;
  final LocalRepositoryStore store;

  SettingsRepository get settingsRepository => LocalSettingsRepository(store: store);

  Widget wrap(Widget child, {TextDirection? textDirection}) {
    return wrapProviders(
      MaterialApp(home: child),
      textDirection: textDirection,
    );
  }

  Widget wrapProviders(Widget child, {TextDirection? textDirection}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<SettingsRepository>.value(value: settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository),
          ),
          BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(settingsRepository),
          ),
          BlocProvider<OnboardingCubit>(
            create: (_) => OnboardingCubit(settingsRepository),
          ),
          BlocProvider<AppLanguageCubit>(
            create: (_) => AppLanguageCubit(),
          ),
        ],
        child: textDirection == null
            ? child
            : Directionality(textDirection: textDirection, child: child),
      ),
    );
  }
}

class TestAuthRepository implements AuthRepository {
  TestAuthRepository({AppUser? user}) : _currentUser = user ?? AppUser.empty;

  final _controller = StreamController<AppUser>.broadcast();
  AppUser _currentUser;

  @override
  Stream<AppUser> get user async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    _currentUser = AppUser(userId: 'test-user', email: email, providerId: 'password');
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    _currentUser = const AppUser(
      userId: 'google-user',
      email: 'google@example.com',
      providerId: 'google.com',
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _currentUser = AppUser(
      userId: 'test-user',
      email: email,
      displayName: displayName,
      providerId: 'password',
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = AppUser.empty;
    _controller.add(_currentUser);
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AppUser> updateDisplayName(String displayName) async {
    _currentUser = AppUser(
      userId: _currentUser.userId,
      email: _currentUser.email,
      displayName: displayName,
      providerId: _currentUser.providerId,
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<AppUser> updateEmail(String email) async {
    _currentUser = AppUser(
      userId: _currentUser.userId,
      email: email,
      displayName: _currentUser.displayName,
      providerId: _currentUser.providerId,
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> deleteAccount() async {
    await signOut();
  }

  @override
  Future<AppUser> reauthenticate({
    required String email,
    required String password,
  }) async {
    return _currentUser;
  }

  @override
  Future<AppUser> reauthenticateWithGoogle() async => _currentUser;
}
