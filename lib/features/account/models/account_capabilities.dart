enum AccountProviderType { emailPassword, google, unknown }

class AccountProfileCapabilities {
  const AccountProfileCapabilities({
    required this.providerType,
    this.canEditLocalDisplayName = true,
    this.canSendPasswordReset = false,
    this.canUpdateEmail = false,
    this.canDeleteAccount = true,
    this.needsPasswordReauth = false,
  });

  final AccountProviderType providerType;
  final bool canEditLocalDisplayName;
  final bool canSendPasswordReset;
  final bool canUpdateEmail;
  final bool canDeleteAccount;
  final bool needsPasswordReauth;

  static const unknown = AccountProfileCapabilities(providerType: AccountProviderType.unknown);

  String get providerLabel {
    switch (providerType) {
      case AccountProviderType.emailPassword: return 'Email/Password';
      case AccountProviderType.google: return 'Google';
      case AccountProviderType.unknown: return 'Unknown';
    }
  }
}
