import 'package:local_auth/local_auth.dart';

abstract class BiometricAuthenticator {
  Future<bool> isSupported();
  Future<bool> authenticate();
}

class BiometricService implements BiometricAuthenticator {
  final LocalAuthentication _localAuth;

  BiometricService({LocalAuthentication? localAuthentication})
      : _localAuth = localAuthentication ?? LocalAuthentication();

  @override
  Future<bool> isSupported() async {
    try {
      final deviceSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      final available = await _localAuth.getAvailableBiometrics();
      return deviceSupported && canCheck && available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate() async {
    if (!await isSupported()) return false;
    try {
      return _localAuth.authenticate(
        localizedReason: 'Unlock Expense Tracker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
