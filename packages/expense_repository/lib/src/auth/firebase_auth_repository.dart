import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_repository.dart';
import '../models/models.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AppUser> get user {
    return _firebaseAuth.userChanges().map((user) {
      if (user == null) return AppUser.empty;
      return AppUser.fromFirebaseUser(user);
    }).handleError((Object error) {
      debugPrint('FirebaseAuthRepository.user stream error: $error');
      return AppUser.empty;
    });
  }

  @override
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return AppUser.fromFirebaseUser(user);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthRepositoryException(
          code: 'missing-user',
          message: 'No user returned from Firebase Auth.',
        );
      }
      return AppUser.fromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        code: error.code,
        message: error.message ?? 'Sign in failed.',
      );
    }
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw const AuthRepositoryException(
          code: 'missing-google-token',
          message: 'Google sign-in did not return an authentication token.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw const AuthRepositoryException(
          code: 'missing-user',
          message: 'No user returned from Firebase Auth.',
        );
      }
      return AppUser.fromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        code: error.code,
        message: error.message ?? 'Google sign-in failed.',
      );
    }
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      var user = credential.user;
      if (user == null) {
        throw const AuthRepositoryException(
          code: 'missing-user',
          message: 'No user returned from Firebase Auth.',
        );
      }
      final trimmedDisplayName = displayName?.trim();
      if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
        await user.updateDisplayName(trimmedDisplayName);
        await user.reload();
        user = _firebaseAuth.currentUser ?? user;
      }
      return AppUser.fromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        code: error.code,
        message: error.message ?? 'Sign up failed.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        code: error.code,
        message: error.message ?? 'Password reset failed.',
      );
    }
  }

  @override
  Future<AppUser> updateDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      throw const AuthRepositoryException(
        code: 'invalid-display-name',
        message: 'Display name is required.',
      );
    }
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthRepositoryException(
        code: 'missing-user',
        message: 'No signed-in user is available.',
      );
    }
    try {
      await user.updateDisplayName(trimmed);
      await user.reload();
      return AppUser.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        code: error.code,
        message: error.message ?? 'Display name update failed.',
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthRepositoryException(
        code: 'missing-user',
        message: 'No signed-in user is available.',
      );
    }
    try {
      await user.delete();
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        code: error.code,
        message: error.message ?? 'Account deletion failed.',
      );
    }
  }

  @override
  Future<AppUser> reauthenticate({required String email, required String password}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthRepositoryException(
        code: 'missing-user',
        message: 'No signed-in user is available.',
      );
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return AppUser.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(
        code: error.code,
        message: error.message ?? 'Reauthentication failed.',
      );
    }
  }
}
