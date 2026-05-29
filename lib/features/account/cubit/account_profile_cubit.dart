import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/account/models/account_capabilities.dart';
import 'package:expenses_tracker/features/account/models/reauth_request.dart';
import 'package:expenses_tracker/features/account/services/account_deletion_service.dart';
import 'package:expenses_tracker/features/account/services/account_profile_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'account_profile_state.dart';

class AccountProfileCubit extends Cubit<AccountProfileState> {
  AccountProfileCubit({
    required AppUser user,
    required AccountProfileService profileService,
    required AccountDeletionService deletionService,
  })  : _profile = profileService,
        _deletion = deletionService,
        super(AccountProfileState.initial(user));

  final AccountProfileService _profile;
  final AccountDeletionService _deletion;

  Future<void> load() async {
    emit(state.copyWith(status: AccountProfileStatus.loading));
    try {
      final localDisplayName = await _profile.loadLocalDisplayName(state.user);
      final capabilities = await _profile.loadCapabilities(state.user);
      emit(state.copyWith(
        status: AccountProfileStatus.ready,
        localDisplayName: localDisplayName,
        capabilities: capabilities,
        clearMessage: true,
      ));
    } catch (_) {
      emit(state.copyWith(status: AccountProfileStatus.failure, messageKey: AccountProfileMessageKey.loadFailed));
    }
  }

  Future<void> saveDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(messageKey: AccountProfileMessageKey.displayNameInvalid));
      return;
    }
    emit(state.copyWith(status: AccountProfileStatus.savingDisplayName));
    try {
      await _profile.saveLocalDisplayName(state.user, trimmed);
      emit(state.copyWith(
        status: AccountProfileStatus.ready,
        localDisplayName: trimmed,
        messageKey: AccountProfileMessageKey.displayNameUpdated,
      ));
    } catch (_) {
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.displayNameUpdateFailed));
    }
  }

  Future<void> sendPasswordReset() async {
    emit(state.copyWith(status: AccountProfileStatus.sendingPasswordReset));
    try {
      await _profile.sendPasswordReset(state.user);
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.passwordResetSent));
    } on AccountActionException catch (e) {
      emit(state.copyWith(
        status: AccountProfileStatus.ready,
        messageKey: e.requiresRecentLogin ? AccountProfileMessageKey.reauthRequired : AccountProfileMessageKey.passwordResetFailed,
      ));
    } catch (_) {
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.passwordResetFailed));
    }
  }

  Future<void> deleteAccount({required bool warningConfirmed}) async {
    emit(state.copyWith(status: AccountProfileStatus.deletingAccount));
    try {
      await _deletion.deleteAccount(user: state.user, warningConfirmed: warningConfirmed);
      emit(state.copyWith(status: AccountProfileStatus.deleted, messageKey: AccountProfileMessageKey.accountDeleted));
    } on AccountDeletionException catch (e) {
      final reauth = e.requiresRecentLogin ? _reauthFor(AccountSensitiveAction.deleteAccount) : null;
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: _deleteMsg(e), reauthRequest: reauth));
    } catch (_) {
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.accountDeleteFailed));
    }
  }

  Future<void> updateEmail(String email) async {
    final trimmed = email.trim();
    if (!trimmed.contains('@')) {
      emit(state.copyWith(messageKey: AccountProfileMessageKey.emailInvalid));
      return;
    }
    emit(state.copyWith(status: AccountProfileStatus.updatingEmail));
    try {
      await _profile.updateEmail(state.user, trimmed);
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.emailUpdated));
    } on AccountActionException catch (e) {
      final reauth = e.requiresRecentLogin ? _reauthFor(AccountSensitiveAction.updateEmail, newEmail: trimmed) : null;
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: e.requiresRecentLogin ? AccountProfileMessageKey.reauthRequired : AccountProfileMessageKey.emailUpdateFailed, reauthRequest: reauth));
    } catch (_) {
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.emailUpdateFailed));
    }
  }

  Future<void> completeReauthentication({String? password}) async {
    final request = state.reauthRequest;
    if (request == null) return;
    emit(state.copyWith(status: AccountProfileStatus.reauthenticating));
    try {
      if (request.requiresPassword) {
        if (password == null || password.trim().isEmpty) {
          emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.reauthFailed));
          return;
        }
        await _profile.reauthenticateWithPassword(state.user, password.trim());
      } else if (request.usesGoogle) {
        await _profile.reauthenticateWithGoogle(state.user);
      } else {
        emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.reauthUnavailable, clearReauthRequest: true));
        return;
      }
      final retry = request;
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.reauthSucceeded, clearReauthRequest: true));
      await _retryAfterReauth(retry);
    } on AccountActionException catch (e) {
      final clear = ['canceled', 'user-cancelled', 'user-canceled', 'provider-unavailable', 'action-unavailable'].contains(e.code);
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.reauthFailed, clearReauthRequest: clear));
    } catch (_) {
      emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.reauthFailed));
    }
  }

  void cancelReauthentication() {
    emit(state.copyWith(status: AccountProfileStatus.ready, messageKey: AccountProfileMessageKey.reauthCanceled, clearReauthRequest: true));
  }

  AccountProfileMessageKey _deleteMsg(AccountDeletionException e) {
    if (e.requiresRecentLogin) return AccountProfileMessageKey.reauthRequired;
    switch (e.code) {
      case 'confirmation-required': return AccountProfileMessageKey.deleteConfirmationRequired;
      case 'data-delete-failed': return AccountProfileMessageKey.dataDeleteFailed;
      case 'auth-delete-failed': return AccountProfileMessageKey.authDeleteFailed;
      default: return AccountProfileMessageKey.accountDeleteFailed;
    }
  }

  ReauthRequest _reauthFor(AccountSensitiveAction action, {String? newEmail}) =>
      ReauthRequest(providerType: state.capabilities.providerType, action: action, newEmail: newEmail);

  Future<void> _retryAfterReauth(ReauthRequest request) async {
    switch (request.action) {
      case AccountSensitiveAction.updateEmail:
        final email = request.newEmail;
        if (email == null || email.trim().isEmpty) return;
        await updateEmail(email);
      case AccountSensitiveAction.deleteAccount:
        await deleteAccount(warningConfirmed: true);
    }
  }
}
