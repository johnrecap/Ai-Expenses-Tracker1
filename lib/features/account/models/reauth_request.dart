import 'account_capabilities.dart';

enum AccountSensitiveAction { updateEmail, deleteAccount }

class ReauthRequest {
  const ReauthRequest({
    required this.providerType,
    required this.action,
    this.newEmail,
  });

  final AccountProviderType providerType;
  final AccountSensitiveAction action;
  final String? newEmail;

  bool get requiresPassword => providerType == AccountProviderType.emailPassword;
  bool get usesGoogle => providerType == AccountProviderType.google;
}
