import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/account/models/account_capabilities.dart';
import 'package:expenses_tracker/features/account/services/account_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultAccountProfileService local-only safeguards', () {
    const firebaseUser = AppUser(
      userId: 'firebase-user',
      email: 'user@example.com',
      providerId: 'password',
    );

    test('disables sign-in account actions when only the local profile exists', () async {
      final service = DefaultAccountProfileService(
        authRepository: _FakeAuthRepository(currentUser: AppUser.empty),
        runtimeMode: RepositoryRuntimeMode.localOnly,
      );

      final capabilities = await service.loadCapabilities(
        const AppUser(userId: 'local-only-device', email: '', providerId: 'local'),
      );

      expect(capabilities.providerType, AccountProviderType.unknown);
      expect(capabilities.canEditLocalDisplayName, isFalse);
      expect(capabilities.canSendPasswordReset, isFalse);
      expect(capabilities.canUpdateEmail, isFalse);
      expect(capabilities.canDeleteAccount, isFalse);
    });

    test('keeps financial data deletion as no-op in local-only mode', () async {
      final authRepository = _FakeAuthRepository(currentUser: firebaseUser);
      final service = DefaultAccountProfileService(
        authRepository: authRepository,
        runtimeMode: RepositoryRuntimeMode.localOnly,
      );

      await service.deleteUserData(firebaseUser, UserDataDeletionPlan.standard);

      expect(authRepository.deleteCalls, 0);
    });

    test('can delete Firebase sign-in account without deleting Firestore data', () async {
      final authRepository = _FakeAuthRepository(currentUser: firebaseUser);
      final service = DefaultAccountProfileService(
        authRepository: authRepository,
        runtimeMode: RepositoryRuntimeMode.localOnly,
      );

      final capabilities = await service.loadCapabilities(firebaseUser);
      expect(capabilities.canDeleteAccount, isTrue);

      await service.deleteUserData(firebaseUser, UserDataDeletionPlan.standard);
      await service.deleteAuthAccount(firebaseUser);

      expect(authRepository.deleteCalls, 1);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.currentUser});

  @override
  AppUser? currentUser;

  int deleteCalls = 0;

  @override
  Stream<AppUser> get user => Stream.value(currentUser ?? AppUser.empty);

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    currentUser = AppUser(userId: 'firebase-user', email: email, providerId: 'password');
    return currentUser!;
  }

  @override
  Future<AppUser?> signInWithGoogle() async => currentUser;

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    currentUser = AppUser(
      userId: 'firebase-user',
      email: email,
      displayName: displayName,
      providerId: 'password',
    );
    return currentUser!;
  }

  @override
  Future<void> signOut() async {
    currentUser = AppUser.empty;
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<AppUser> updateDisplayName(String displayName) async {
    final user = currentUser ?? AppUser.empty;
    currentUser = AppUser(
      userId: user.userId,
      email: user.email,
      displayName: displayName,
      providerId: user.providerId,
    );
    return currentUser!;
  }

  @override
  Future<AppUser> updateEmail(String email) async {
    final user = currentUser ?? AppUser.empty;
    currentUser = AppUser(
      userId: user.userId,
      email: email,
      displayName: user.displayName,
      providerId: user.providerId,
    );
    return currentUser!;
  }

  @override
  Future<void> deleteAccount() async {
    deleteCalls += 1;
    currentUser = AppUser.empty;
  }

  @override
  Future<AppUser> reauthenticate({required String email, required String password}) async {
    return currentUser ?? AppUser.empty;
  }

  @override
  Future<AppUser> reauthenticateWithGoogle() async {
    return currentUser ?? AppUser.empty;
  }
}
