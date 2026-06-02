import 'dart:async';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/auth/auth_bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthBloc initial state is AuthInitial', () {
    final repo = _createRepo();
    final bloc = AuthBloc(repo);
    expect(bloc.state, isA<AuthInitial>());
    bloc.close();
  });

  test('AuthBloc emits AuthUnauthenticated for empty user', () async {
    final repo = _createRepo(user: AppUser.empty);
    final bloc = AuthBloc(repo);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(bloc.state, isA<AuthUnauthenticated>());
    bloc.close();
  });

  test('AuthBloc emits AuthAuthenticated for valid user', () async {
    final repo = _createRepo(
      user: const AppUser(userId: '123', email: 'test@test.com'),
    );
    final bloc = AuthBloc(repo);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(bloc.state, isA<AuthAuthenticated>());
    bloc.close();
  });

  test('AuthBloc signUp emits loading then success', () async {
    final repo = _createRepo(
      user: const AppUser(userId: '123', email: 'test@test.com'),
    );
    final bloc = AuthBloc(repo);
    bloc.add(const AuthSignUpRequested(email: 'test@test.com', password: 'pass123'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(bloc.state, isA<AuthAuthenticated>());
    bloc.close();
  });
}

_MockAuthRepo _createRepo({AppUser? user}) {
  final repo = _MockAuthRepo(user: user);
  return repo;
}

class _MockAuthRepo implements AuthRepository {
  final _controller = StreamController<AppUser>.broadcast();

  _MockAuthRepo({AppUser? user}) {
    Future<void>.delayed(Duration.zero, () {
      if (!_controller.isClosed) _controller.add(user ?? AppUser.empty);
    });
  }

  @override
  Stream<AppUser> get user => _controller.stream;
  @override
  AppUser? get currentUser => null;
  @override
  Future<AppUser> signIn({required String email, required String password}) async =>
      AppUser(userId: '1', email: email);
  @override
  Future<AppUser?> signInWithGoogle() async => const AppUser(userId: '1', email: 'g@test.com');
  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => AppUser(userId: '1', email: email, displayName: displayName);
  @override
  Future<void> signOut() async {}
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<AppUser> updateDisplayName(String displayName) async =>
      AppUser(userId: '1', email: 'a@b.com', displayName: displayName);
  @override
  Future<AppUser> updateEmail(String email) async => AppUser(userId: '1', email: email);
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<AppUser> reauthenticate({required String email, required String password}) async =>
      AppUser(userId: '1', email: email);
  @override
  Future<AppUser> reauthenticateWithGoogle() async =>
      const AppUser(userId: '1', email: 'g@test.com', providerId: 'google.com');
}
