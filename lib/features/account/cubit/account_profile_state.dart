part of 'account_profile_cubit.dart';

enum AccountProfileStatus {
  initial, loading, ready, savingDisplayName, sendingPasswordReset,
  updatingEmail, reauthenticating, deletingAccount, deleted, failure,
}

enum AccountProfileMessageKey {
  loadFailed, displayNameInvalid, displayNameUpdated, displayNameUpdateFailed,
  passwordResetSent, passwordResetFailed, emailInvalid, emailUpdated, emailUpdateFailed,
  reauthRequired, reauthSucceeded, reauthFailed, reauthCanceled, reauthUnavailable,
  deleteConfirmationRequired, dataDeleteFailed, authDeleteFailed, accountDeleted, accountDeleteFailed,
}

class AccountProfileState extends Equatable {
  const AccountProfileState({
    required this.user,
    required this.status,
    required this.capabilities,
    this.localDisplayName,
    this.messageKey,
    this.reauthRequest,
  });

  factory AccountProfileState.initial(AppUser user) =>
      AccountProfileState(user: user, status: AccountProfileStatus.initial, capabilities: AccountProfileCapabilities.unknown);

  final AppUser user;
  final AccountProfileStatus status;
  final AccountProfileCapabilities capabilities;
  final String? localDisplayName;
  final AccountProfileMessageKey? messageKey;
  final ReauthRequest? reauthRequest;

  bool get isBusy => [AccountProfileStatus.loading, AccountProfileStatus.savingDisplayName,
      AccountProfileStatus.sendingPasswordReset, AccountProfileStatus.updatingEmail,
      AccountProfileStatus.reauthenticating, AccountProfileStatus.deletingAccount].contains(status);

  AccountProfileState copyWith({
    AppUser? user, AccountProfileStatus? status, AccountProfileCapabilities? capabilities,
    String? localDisplayName, AccountProfileMessageKey? messageKey, ReauthRequest? reauthRequest,
    bool clearMessage = false, bool clearReauthRequest = false,
  }) {
    return AccountProfileState(
      user: user ?? this.user,
      status: status ?? this.status,
      capabilities: capabilities ?? this.capabilities,
      localDisplayName: localDisplayName ?? this.localDisplayName,
      messageKey: clearMessage ? null : messageKey ?? this.messageKey,
      reauthRequest: clearReauthRequest ? null : reauthRequest ?? this.reauthRequest,
    );
  }

  @override
  List<Object?> get props => [user.userId, user.email, status, capabilities.providerType, localDisplayName, messageKey];
}
