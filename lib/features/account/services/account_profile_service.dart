import 'dart:async';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/features/account/models/account_capabilities.dart';

class AccountActionException implements Exception {
  const AccountActionException(this.code, this.message);
  final String code;
  final String message;
  bool get requiresRecentLogin => code == 'requires-recent-login';

  @override
  String toString() => message;
}

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.code, this.message);
  final String code;
  final String message;
  bool get requiresRecentLogin => code == 'requires-recent-login';

  @override
  String toString() => message;
}

abstract class AccountProfileService {
  Future<String?> loadLocalDisplayName(AppUser user);
  Future<void> saveLocalDisplayName(AppUser user, String displayName);
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user);
  Future<void> sendPasswordReset(AppUser user);
  Future<void> updateEmail(AppUser user, String newEmail);
  Future<void> reauthenticateWithPassword(AppUser user, String password);
  Future<void> reauthenticateWithGoogle(AppUser user);
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan);
  Future<void> deleteAuthAccount(AppUser user);
}

class DefaultAccountProfileService implements AccountProfileService {
  DefaultAccountProfileService._();
  static final instance = DefaultAccountProfileService._();
  final Map<String, String> _localDisplayNames = {};

  @override
  Future<String?> loadLocalDisplayName(AppUser user) async => _localDisplayNames[user.userId];

  @override
  Future<void> saveLocalDisplayName(AppUser user, String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) throw const AccountActionException('invalid-display-name', 'Display name is required.');
    _localDisplayNames[user.userId] = trimmed;
  }

  @override
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user) async => AccountProfileCapabilities.unknown;

  @override
  Future<void> sendPasswordReset(AppUser user) async =>
      throw const AccountActionException('action-unavailable', 'Password reset not available yet.');

  @override
  Future<void> updateEmail(AppUser user, String newEmail) async =>
      throw const AccountActionException('action-unavailable', 'Email update not available yet.');

  @override
  Future<void> reauthenticateWithPassword(AppUser user, String password) async =>
      throw const AccountActionException('action-unavailable', 'Reauthentication not available yet.');

  @override
  Future<void> reauthenticateWithGoogle(AppUser user) async =>
      throw const AccountActionException('action-unavailable', 'Google reauthentication not available yet.');

  @override
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan) async =>
      throw const AccountActionException('action-unavailable', 'Account deletion backend not available yet.');

  @override
  Future<void> deleteAuthAccount(AppUser user) async =>
      throw const AccountActionException('action-unavailable', 'Account deletion backend not available yet.');
}

class UserDataDeletionPlan {
  const UserDataDeletionPlan(this.paths);
  final List<String> paths;
  static const standard = UserDataDeletionPlan([
    'users/{userId}/expenses',
    'users/{userId}/categories',
    'users/{userId}/budgets',
    'users/{userId}/wallets',
  ]);
  List<String> resolve(String userId) => paths.map((p) => p.replaceAll('{userId}', userId)).toList();
}
