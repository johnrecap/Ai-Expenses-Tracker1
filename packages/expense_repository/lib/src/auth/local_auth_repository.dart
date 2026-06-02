import 'dart:async';

import 'auth_repository.dart';
import '../models/models.dart';

class LocalAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser>.broadcast();
  AppUser _currentUser = AppUser.empty;

  @override
  Stream<AppUser> get user async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    return _unsupported<AppUser>();
  }

  @override
  Future<AppUser?> signInWithGoogle() {
    return _unsupported<AppUser?>();
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _unsupported<AppUser>();
  }

  @override
  Future<void> signOut() async {
    _currentUser = AppUser.empty;
    _controller.add(_currentUser);
  }

  @override
  Future<void> resetPassword(String email) {
    return _unsupported<void>();
  }

  @override
  Future<AppUser> updateDisplayName(String displayName) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      throw const AuthRepositoryException(
        code: 'invalid-display-name',
        message: 'Display name is required.',
      );
    }
    _currentUser = AppUser(
      userId: 'local-only-device',
      email: '',
      displayName: trimmed,
      providerId: 'local',
    );
    _controller.add(_currentUser);
    return Future.value(_currentUser);
  }

  @override
  Future<AppUser> updateEmail(String email) {
    return _unsupported<AppUser>();
  }

  @override
  Future<void> deleteAccount() {
    return _unsupported<void>();
  }

  @override
  Future<AppUser> reauthenticate({
    required String email,
    required String password,
  }) {
    return _unsupported<AppUser>();
  }

  @override
  Future<AppUser> reauthenticateWithGoogle() {
    return _unsupported<AppUser>();
  }

  Future<T> _unsupported<T>() {
    return Future<T>.error(
      const AuthRepositoryException(
        code: 'local-only-auth',
        message: 'Account sign-in is disabled in local-only mode.',
      ),
    );
  }
}
