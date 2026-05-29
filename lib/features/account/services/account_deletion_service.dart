import 'package:expense_repository/expense_repository.dart';
import 'account_profile_service.dart';

class AccountDeletionService {
  const AccountDeletionService({required AccountProfileService accountProfileService})
      : _service = accountProfileService;

  final AccountProfileService _service;

  Future<void> deleteAccount({required AppUser user, required bool warningConfirmed}) async {
    if (!warningConfirmed) throw const AccountDeletionException('confirmation-required', 'Confirmation required.');
    try {
      await _service.deleteUserData(user, UserDataDeletionPlan.standard);
    } on AccountActionException catch (e) {
      throw AccountDeletionException(e.code == 'requires-recent-login' ? e.code : 'data-delete-failed', e.message);
    } catch (_) {
      throw const AccountDeletionException('data-delete-failed', 'Could not delete account data.');
    }
    try {
      await _service.deleteAuthAccount(user);
    } on AccountActionException catch (e) {
      throw AccountDeletionException(e.code == 'requires-recent-login' ? e.code : 'auth-delete-failed', e.message);
    } catch (_) {
      throw const AccountDeletionException('auth-delete-failed', 'Could not delete sign-in record.');
    }
  }
}
