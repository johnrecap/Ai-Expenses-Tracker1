import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  DefaultAccountProfileService({
    required this.authRepository,
    this.firestore,
    RepositoryRuntimeMode? runtimeMode,
  }) : runtimeMode = runtimeMode ?? RepositoryRuntimeMode.fromEnvironment();

  final AuthRepository authRepository;
  final FirebaseFirestore? firestore;
  final RepositoryRuntimeMode runtimeMode;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  @override
  Future<String?> loadLocalDisplayName(AppUser user) async {
    final currentUser = authRepository.currentUser;
    return currentUser?.displayName ?? user.displayName;
  }

  @override
  Future<void> saveLocalDisplayName(AppUser user, String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      throw const AccountActionException('invalid-display-name', 'Display name is required.');
    }
    await _wrapAuthAction(() => authRepository.updateDisplayName(trimmed));
  }

  @override
  Future<AccountProfileCapabilities> loadCapabilities(AppUser user) async {
    final currentUser = authRepository.currentUser;
    final signedInUser = currentUser != null && currentUser.isNotEmpty ? currentUser : null;
    final effectiveUser = signedInUser ?? user;
    final providerType = _providerType(effectiveUser.providerId);
    final email = effectiveUser.email.trim();
    final canUseRemoteAuth = _isRemoteAuthUser(signedInUser);
    return AccountProfileCapabilities(
      providerType: providerType,
      canEditLocalDisplayName: runtimeMode != RepositoryRuntimeMode.localOnly || canUseRemoteAuth,
      canSendPasswordReset:
          canUseRemoteAuth && providerType == AccountProviderType.emailPassword && email.isNotEmpty,
      canUpdateEmail:
          canUseRemoteAuth && providerType == AccountProviderType.emailPassword && email.isNotEmpty,
      canDeleteAccount: runtimeMode == RepositoryRuntimeMode.localOnly
          ? canUseRemoteAuth
          : user.userId.trim().isNotEmpty,
      needsPasswordReauth: providerType == AccountProviderType.emailPassword,
    );
  }

  @override
  Future<void> sendPasswordReset(AppUser user) async {
    final email = user.email.trim();
    if (email.isEmpty) throw const AccountActionException('missing-email', 'Email is required.');
    await _wrapAuthAction(() => authRepository.resetPassword(email));
  }

  @override
  Future<void> updateEmail(AppUser user, String newEmail) async {
    final trimmed = newEmail.trim();
    if (!trimmed.contains('@')) {
      throw const AccountActionException('invalid-email', 'Enter a valid email.');
    }
    await _wrapAuthAction(() => authRepository.updateEmail(trimmed));
  }

  @override
  Future<void> reauthenticateWithPassword(AppUser user, String password) async {
    final email = user.email.trim();
    final trimmedPassword = password.trim();
    if (email.isEmpty) throw const AccountActionException('missing-email', 'Email is required.');
    if (trimmedPassword.isEmpty) {
      throw const AccountActionException('missing-password', 'Password is required.');
    }
    await _wrapAuthAction(
      () => authRepository.reauthenticate(email: email, password: trimmedPassword),
    );
  }

  @override
  Future<void> reauthenticateWithGoogle(AppUser user) async {
    await _wrapAuthAction(authRepository.reauthenticateWithGoogle);
  }

  @override
  Future<void> deleteUserData(AppUser user, UserDataDeletionPlan plan) async {
    if (runtimeMode == RepositoryRuntimeMode.localOnly) {
      return;
    }
    final userId = user.userId.trim();
    if (userId.isEmpty) {
      throw const AccountActionException('missing-user', 'No signed-in user is available.');
    }
    for (final path in plan.resolve(userId)) {
      await _deleteCollection(path);
    }
    await _db.doc('users/$userId').delete();
  }

  @override
  Future<void> deleteAuthAccount(AppUser user) async {
    final currentUser = authRepository.currentUser;
    if (runtimeMode == RepositoryRuntimeMode.localOnly && !_isRemoteAuthUser(currentUser)) {
      throw const AccountActionException('missing-user', 'No signed-in user is available.');
    }
    await _wrapAuthAction(authRepository.deleteAccount);
  }

  AccountProviderType _providerType(String? providerId) {
    switch (providerId) {
      case 'password':
        return AccountProviderType.emailPassword;
      case 'google.com':
        return AccountProviderType.google;
      default:
        return AccountProviderType.unknown;
    }
  }

  bool _isRemoteAuthUser(AppUser? user) {
    if (user == null || user.isEmpty) return false;
    return user.providerId == 'password' || user.providerId == 'google.com';
  }

  Future<void> _deleteCollection(String path) async {
    const batchSize = 400;
    while (true) {
      final snapshot = await _db.collection(path).limit(batchSize).get();
      if (snapshot.docs.isEmpty) return;
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snapshot.docs.length < batchSize) return;
    }
  }

  Future<void> _wrapAuthAction(FutureOr<Object?> Function() action) async {
    try {
      await action();
    } on AuthRepositoryException catch (error) {
      throw AccountActionException(error.code, error.message);
    }
  }
}

class UserDataDeletionPlan {
  const UserDataDeletionPlan(this.paths);
  final List<String> paths;
  static const standard = UserDataDeletionPlan([
    'users/{userId}/expenses',
    'users/{userId}/categories',
    'users/{userId}/budgets',
    'users/{userId}/categoryBudgets',
    'users/{userId}/categoryAliases',
    'users/{userId}/wallets',
    'users/{userId}/transfers',
    'users/{userId}/saving_goals',
    'users/{userId}/recurringExpenses',
    'users/{userId}/aiActions',
    'users/{userId}/settings',
  ]);
  List<String> resolve(String userId) =>
      paths.map((p) => p.replaceAll('{userId}', userId)).toList();
}
