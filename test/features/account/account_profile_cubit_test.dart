import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/account/cubit/account_profile_cubit.dart';
import 'package:expenses_tracker/features/account/models/account_capabilities.dart';
import 'package:expenses_tracker/features/account/models/reauth_request.dart';
import 'package:expenses_tracker/features/account/services/account_deletion_service.dart';
import 'package:expenses_tracker/features/account/services/account_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = AppUser(
    userId: 'user-1',
    email: 'user@example.com',
    providerId: 'password',
  );

  test('delete account asks for reauthentication before deleting data', () async {
    final profileService = _FakeAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.emailPassword,
        canDeleteAccount: true,
        needsPasswordReauth: true,
      ),
    );
    final cubit = AccountProfileCubit(
      user: user,
      profileService: profileService,
      deletionService: AccountDeletionService(accountProfileService: profileService),
    );

    await cubit.load();
    await cubit.deleteAccount(warningConfirmed: true);

    expect(cubit.state.status, AccountProfileStatus.ready);
    expect(cubit.state.messageKey, AccountProfileMessageKey.reauthRequired);
    expect(cubit.state.reauthRequest?.action, AccountSensitiveAction.deleteAccount);
    expect(profileService.deleteUserDataCalls, 0);
    expect(profileService.deleteAuthCalls, 0);

    await cubit.close();
  });

  test('delete account proceeds after successful password reauthentication', () async {
    final profileService = _FakeAccountProfileService(
      capabilities: const AccountProfileCapabilities(
        providerType: AccountProviderType.emailPassword,
        canDeleteAccount: true,
        needsPasswordReauth: true,
      ),
    );
    final cubit = AccountProfileCubit(
      user: user,
      profileService: profileService,
      deletionService: AccountDeletionService(accountProfileService: profileService),
    );

    await cubit.load();
    await cubit.deleteAccount(warningConfirmed: true);
    await cubit.completeReauthentication(password: 'secret');

    expect(profileService.passwordReauthCalls, 1);
    expect(profileService.deleteUserDataCalls, 1);
    expect(profileService.deleteAuthCalls, 1);
    expect(cubit.state.status, AccountProfileStatus.deleted);

    await cubit.close();
  });
}

class _FakeAccountProfileService implements AccountProfileService {
  _FakeAccountProfileService({required this.capabilities});

  final AccountProfileCapabilities capabilities;
  int passwordReauthCalls = 0;
  int deleteUserDataCalls = 0;
  int deleteAuthCalls = 0;

  @override
  Future<String?> loadLocalDisplayName(AppUser user) async => user.displayName;

  @override
  Future<void> saveLocalDisplayName(AppUser user, String displayName) async {}

  @override
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user) async => capabilities;

  @override
  Future<void> sendPasswordReset(AppUser user) async {}

  @override
  Future<void> updateEmail(AppUser user, String newEmail) async {}

  @override
  Future<void> reauthenticateWithPassword(AppUser user, String password) async {
    passwordReauthCalls += 1;
  }

  @override
  Future<void> reauthenticateWithGoogle(AppUser user) async {}

  @override
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan) async {
    deleteUserDataCalls += 1;
  }

  @override
  Future<void> deleteAuthAccount(AppUser user) async {
    deleteAuthCalls += 1;
  }
}
