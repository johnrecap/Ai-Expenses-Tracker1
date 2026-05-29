import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AppUser {
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final String? providerId;

  const AppUser({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.providerId,
  });

  static final empty = const AppUser(userId: '', email: '');

  bool get isEmpty => userId.isEmpty;
  bool get isNotEmpty => userId.isNotEmpty;

  factory AppUser.fromFirebaseUser(firebase_auth.User user) {
    return AppUser(
      userId: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      providerId: user.providerData.isNotEmpty ? user.providerData.first.providerId : null,
    );
  }
}
