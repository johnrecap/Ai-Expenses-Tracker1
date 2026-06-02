import '../models/models.dart';

class AuthRepositoryException implements Exception {
  final String code;
  final String message;
  final Object? cause;

  const AuthRepositoryException({required this.code, required this.message, this.cause});

  @override
  String toString() => 'AuthRepositoryException($code): $message';
}

abstract class AuthRepository {
  Stream<AppUser> get user;
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser?> signInWithGoogle();
  Future<AppUser> signUp({required String email, required String password, String? displayName});
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<AppUser> updateDisplayName(String displayName);
  Future<AppUser> updateEmail(String email);
  Future<void> deleteAccount();
  Future<AppUser> reauthenticate({required String email, required String password});
  Future<AppUser> reauthenticateWithGoogle();
}
