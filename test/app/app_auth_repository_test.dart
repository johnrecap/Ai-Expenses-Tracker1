import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authRepositoryForRuntime', () {
    test('uses local auth only when local-only Firebase is unavailable', () {
      const local = _FakeAuthRepository('local');
      const firebase = _FakeAuthRepository('firebase');

      final repository = authRepositoryForRuntime(
        runtimeMode: RepositoryRuntimeMode.localOnly,
        firebaseInitialized: false,
        localFactory: () => local,
        firebaseFactory: () => firebase,
      );

      expect(repository, same(local));
    });

    test('uses Firebase auth for local-only identity when Firebase is available', () {
      const local = _FakeAuthRepository('local');
      const firebase = _FakeAuthRepository('firebase');

      final repository = authRepositoryForRuntime(
        runtimeMode: RepositoryRuntimeMode.localOnly,
        firebaseInitialized: true,
        localFactory: () => local,
        firebaseFactory: () => firebase,
      );

      expect(repository, same(firebase));
    });

    test('keeps non-local runtimes on Firebase auth', () {
      const local = _FakeAuthRepository('local');
      const firebase = _FakeAuthRepository('firebase');

      final repository = authRepositoryForRuntime(
        runtimeMode: RepositoryRuntimeMode.firebaseLegacy,
        firebaseInitialized: true,
        localFactory: () => local,
        firebaseFactory: () => firebase,
      );

      expect(repository, same(firebase));
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository(this.id);

  final String id;

  @override
  AppUser? get currentUser => AppUser.empty;

  @override
  Stream<AppUser> get user => Stream.value(AppUser.empty);

  @override
  Future<AppUser> signIn({required String email, required String password}) async => AppUser.empty;

  @override
  Future<AppUser?> signInWithGoogle() async => AppUser.empty;

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => AppUser.empty;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AppUser> updateDisplayName(String displayName) async => AppUser.empty;

  @override
  Future<AppUser> updateEmail(String email) async => AppUser.empty;

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<AppUser> reauthenticate({required String email, required String password}) async {
    return AppUser.empty;
  }

  @override
  Future<AppUser> reauthenticateWithGoogle() async => AppUser.empty;
}
