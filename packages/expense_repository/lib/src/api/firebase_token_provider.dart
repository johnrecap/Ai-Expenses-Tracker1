import 'package:firebase_auth/firebase_auth.dart';

class RepositoryFirebaseTokenProvider {
  Future<String?> call() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      return user.getIdToken(true);
    } catch (_) {
      return null;
    }
  }
}
